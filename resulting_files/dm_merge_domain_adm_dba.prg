CREATE PROGRAM dm_merge_domain_adm:dba
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
 FREE RECORD dera_request
 RECORD dera_request(
   1 child_env_id = f8
   1 env_list[*]
     2 parent_env_id = f8
     2 child_env_id = f8
     2 relationship_type = vc
     2 pre_link_name = vc
     2 post_link_name = vc
     2 event_reason = vc
 )
 FREE RECORD dera_reply
 RECORD dera_reply(
   1 err_num = i4
   1 err_msg = vc
 )
 FREE RECORD derd_request
 RECORD derd_request(
   1 child_env_id = f8
   1 env_list[*]
     2 parent_env_id = f8
     2 child_env_id = f8
     2 relationship_type = vc
 )
 FREE RECORD derd_reply
 RECORD derd_reply(
   1 err_num = i4
   1 err_msg = vc
 )
 IF (validate(derg_request->env_id,- (1)) < 0)
  FREE RECORD derg_request
  RECORD derg_request(
    1 env_id = f8
    1 relationship_type = vc
  )
 ENDIF
 IF (validate(derg_reply->err_num,- (1)) < 0)
  FREE RECORD derg_reply
  RECORD derg_reply(
    1 parent_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 child_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 err_num = i4
    1 err_msg = vc
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
 IF ((validate(drrm_email_address->address_cnt,- (1))=- (1))
  AND (validate(drrm_email_addres->address_cnt,- (2))=- (2)))
  FREE RECORD drrm_email_address
  RECORD drrm_email_address(
    1 address_cnt = i4
    1 email_address = vc
  )
 ENDIF
 IF ((validate(drrm_event_types->det_size,- (1))=- (1))
  AND (validate(drrm_event_types->det_size,- (2))=- (2)))
  FREE RECORD drrm_event_types
  RECORD drrm_event_types(
    1 det_size = i4
    1 qual[*]
      2 event_type = vc
  )
 ENDIF
 IF ((validate(drrm_events->cur_env_id,- (1))=- (1))
  AND (validate(drrm_events->cur_env_id,- (2))=- (2)))
  FREE RECORD drrm_events
  RECORD drrm_events(
    1 file_name = vc
    1 cur_env_id = f8
    1 reltn_target_env_id = f8
    1 reltn_source_env_id = f8
    1 reltn_status = vc
    1 link_name = vc
    1 source_env_id = f8
    1 target_env_id = f8
    1 source_env_name = vc
    1 target_env_name = vc
    1 unrprtd_cnt = i4
    1 source_event_name = vc
    1 target_event_name = vc
    1 subject_text = vc
    1 status_rpt_ind = i2
    1 suppression_tm = i4
    1 qual[*]
      2 event_type = vc
      2 event_log_id = f8
      2 event_reason = vc
      2 event = vc
      2 event_key = vc
      2 msg_type_name = vc
      2 event_detail1_txt = vc
      2 event_detail2_txt = vc
      2 event_detail3_txt = vc
      2 event_dt_tm = vc
      2 event_value = f8
      2 header_ind = i2
      2 body_text[*]
        3 text_line = vc
  )
 ENDIF
 DECLARE drrm_create_subject(dcs_event_type=vc,dcs_events=vc(ref),dcs_tgt_only_ind=i2) = i2
 DECLARE drrm_generate_email_file(dgef_event_type=vc,dgef_events=vc(ref)) = i2
 DECLARE drrm_generate_email_text(dgeb_event_idx=i4,dgeb_events=vc(ref),dgeb_event_type=i4) = i2
 DECLARE drrm_send_email(subject=vc,address_list=vc,file_name=vc) = i2
 SUBROUTINE drrm_create_subject(dcs_event_type,dcs_events,dcs_tgt_only_ind)
   DECLARE dcs_subject_prefix = vc
   DECLARE dcs_file_location = vc WITH protect, noconstant(logical("CCLUSERDIR"))
   DECLARE dcs_sys = vc WITH protect, noconstant("")
   IF (validate(cursys2,"-1000")="-1000"
    AND validate(cursys2,"-9999")="-9999")
    SET dcs_sys = cursys
   ELSE
    SET dcs_sys = cursys2
   ENDIF
   SET dm_err->eproc = "Getting client specified subject prefix."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    di.info_char
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=concat("RDDSPREF",dcs_events->link_name)
     AND di.info_name="E-Mail Subject Prefix"
    DETAIL
     dcs_subject_prefix = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "No row was found in dm_info for E-Mail Subject Prefix"
    RETURN(0)
   ENDIF
   IF (dcs_tgt_only_ind=1)
    SET dcs_events->subject_text = concat(dcs_subject_prefix,": ","RDDS ",dcs_event_type," - ",
     dcs_events->target_env_name)
   ELSE
    SET dcs_events->subject_text = concat(dcs_subject_prefix,": ","RDDS ",dcs_event_type," - ",
     dcs_events->source_env_name," to ",dcs_events->target_env_name)
   ENDIF
   SET dm_err->eproc = "Writing client specified subject prefix to email file."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   IF (get_unique_file("dm_rmc_email",".txt")=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Unable to create unique file name"
    GO TO exit_drrm
   ENDIF
   IF (dcs_sys="AXP")
    SET dcs_events->file_name = build(dcs_file_location,dm_err->unique_fname)
   ELSE
    SET dcs_events->file_name = build(dcs_file_location,"/",dm_err->unique_fname)
   ENDIF
   SELECT INTO dcs_events->file_name
    FROM dummyt d
    DETAIL
     row + 1, col 1, dcs_events->subject_text
    WITH append, formfeed = none, format = variable,
     maxrow = 1, nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_generate_email_file(dgef_event_type,dgef_events)
   DECLARE dgef_size = i4
   DECLARE dgef_last_loop = i4
   DECLARE dgef_flag = i4
   SET dgef_last_loop = 0
   SET dgef_flag = 0
   SET dgef_size = 0
   WHILE (dgef_flag=0)
     SET dgef_size = (dgef_size+ 1)
     SET dm_err->eproc = "Generating E-Mail file."
     CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
     SELECT INTO dgef_events->file_name
      subject_text = dgef_events->subject_text, text_line = dgef_events->qual[dgef_size].body_text[d
      .seq].text_line
      FROM (dummyt d  WITH seq = size(dgef_events->qual[dgef_size].body_text,5))
      DETAIL
       IF ((dgef_event_type=dgef_events->qual[dgef_size].msg_type_name))
        IF ((dgef_events->qual[dgef_size].header_ind=1))
         col 1, dgef_events->qual[dgef_size].body_text[d.seq].text_line
        ELSE
         IF ((dgef_events->qual[dgef_size].event_type="Auto-Cutover Error"))
          col 5, dgef_events->qual[dgef_size].event_detail1_txt, col 22,
          "     ----     ", col 39, dgef_events->qual[dgef_size].event_detail2_txt
         ELSEIF ((dgef_events->qual[dgef_size].event_type IN ("Orphaned Mover", "Stale Mover")))
          col 2, dgef_events->qual[dgef_size].event_detail1_txt
         ELSE
          col 2, dgef_events->qual[dgef_size].body_text[d.seq].text_line
         ENDIF
        ENDIF
        row + 1
       ENDIF
      WITH append, formfeed = none, format = variable,
       maxrow = 1, nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      RETURN(0)
     ENDIF
     IF ((dgef_size=dgef_events->unrprtd_cnt))
      SET dgef_flag = 1
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_generate_email_text(dgeb_event_idx,dgeb_events,dgeb_event_type)
   DECLARE dgeb_num_lines = i4 WITH protect, noconstant(0)
   DECLARE dgeb_tstart = i4 WITH protect, noconstant(0)
   DECLARE dgeb_fstart = i4 WITH protect, noconstant(0)
   DECLARE dgeb_flstr1 = i4 WITH protect, noconstant(0)
   DECLARE dgeb_flstr2 = i4 WITH protect, noconstant(0)
   CASE (dgeb_events->qual[dgeb_event_idx].event_type)
    OF "Move Finished":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Notification"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,4)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Notification ",trim(
       cnvtstring((dgeb_event_type+ 100))),":")
     SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
      "   RDDS Movers have processed all of the pending DM_CHG_LOG rows for event ",dgeb_events->
      target_event_name,".")
     SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line =
     "   Please refer to change log report for detailed analysis of processing history."
    OF "Auto-Cutover Started":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Notification"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,3)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Notification ",trim(
       cnvtstring((dgeb_event_type+ 100))),":")
     SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
      "   Auto-Cutover process for event ",dgeb_events->target_event_name,
      " has been started by mover process: ",dgeb_events->qual[dgeb_event_idx].event_reason,".")
    OF "Auto-Cutover Finished":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Notification"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,3)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Notification ",trim(
       cnvtstring((dgeb_event_type+ 100))),":")
     SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
      "   Auto-Cutover process for event ",dgeb_events->target_event_name," has finished.")
    OF "Status Report":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Status"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,2)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Status ",trim(cnvtstring(
        (dgeb_event_idx+ 200))),":")
    OF "Stale Mover":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,9)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line concat(
       "   One or more of the mover processes for event: ",dgeb_events->target_event_name,
       " are stalled,") " and are not processing DM_CHG_LOG rows."
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line = concat(
       "   Please refer to the following log files in CCLUSERDIR of the ",dgeb_events->
       target_env_name," domain,")
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line =
      "or any remote nodes running RDDS movers, to see why."
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "-----------------------------------------"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = "          LOG FILES"
      SET dgeb_events->qual[dgeb_event_idx].body_text[9].text_line = "-----LOG FILE-----"
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = dgeb_events->qual[dgeb_event_idx
      ].event_detail1_txt
     ENDIF
    OF "Orphaned Mover":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,9)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
       "   One or more of the mover processes have abnormally terminated for event ",dgeb_events->
       target_event_name,".")
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line = concat(
       "   Please refer to the following log files in CCLUSERDIR of the ",dgeb_events->
       target_env_name," domain,")
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line =
      "or any remote nodes running RDDS movers, to see details."
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "-----------------------------------------"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = "          LOG FILES"
      SET dgeb_events->qual[dgeb_event_idx].body_text[9].text_line = "-----LOG FILE-----"
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = dgeb_events->qual[dgeb_event_idx
      ].event_detail1_txt
     ENDIF
    OF "Auto-Cutover Error":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,9)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
       "   One or more errors occurred during the Auto-Cutover that was performed for event ",
       dgeb_events->target_event_name,".")
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line = concat(
       "   Please look in the DM_MERGE_DOMAIN_ADM at the View Cutover Warnings report in the ",
       drrm_events->target_env_name," domain.")
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line =
      " domain to find the errors on the table pair(s) below."
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "---------------------------------------------------------"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line =
      "                 CUTOVER WARNINGS"
      SET dgeb_events->qual[dgeb_event_idx].body_text[9].text_line =
      "---Temporary Table-------------------Live Table----------"
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     ENDIF
    OF "Unprocessed $R Resets":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,8)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line =
      "   There are database integrity concerns for cutover that require evaluation for correction and acknowledgement."
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line =
      "   The cutover process will not be allowed to start until these rows are acknowledged."
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line = "   To view the report:"
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = concat(
       "      Merge Domain Administration Menu -> RDDS Status and Monitoring Tools -> ",
       "Dual Build Reports/Configuration")
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "      -> View Database Integrity Concerns for Cutover"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = concat(
       "   Number of Unprocessed Rows: ",cnvtstring(dgeb_events->qual[dgeb_event_idx].event_value))
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     ENDIF
    OF "Auto Cutover Dual Build Issues":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,8)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line =
      "   The mover detected that dual build was performed in the target environment.  "
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line =
      "   The cutover process will not automatically be started until these database integrity concerns are acknowledged."
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line = "   To view the report:"
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = concat(
       "      Merge Domain Administration Menu -> RDDS Status and Monitoring Tools -> ",
       "Dual Build Reports/Configuration")
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "      -> View Database Integrity Concerns for Cutover"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = concat(
       "Number of Unprocessed Rows: ",cnvtstring(dgeb_events->qual[dgeb_event_idx].event_value))
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     ENDIF
    OF "Task Queue Error":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,9)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 400))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
       "   One or more of the tasks attempting to run the ",dgeb_events->qual[dgeb_event_idx].
       event_reason," have abnormally terminated.")
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line = concat(
       "   Please refer to the following task details for explaination. ")
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line =
      "   If help is required, please log an SR to Common Service/Database Architecture/Foundations."
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "-----------------------------------------"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = "             TASK QUEUE ERRORS"
      SET dgeb_events->qual[dgeb_event_idx].body_text[9].text_line =
      "-----------------------------------------"
     ELSE
      IF (size(dgeb_events->qual[dgeb_event_idx].event_detail2_txt,1) > 100)
       SET dgeb_num_lines = (ceil((size(dgeb_events->qual[dgeb_event_idx].event_detail2_txt,1)/ 100.0
        ))+ 2)
      ELSE
       SET dgeb_num_lines = 3
      ENDIF
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,dgeb_num_lines)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = concat("   Task Description: ",
       trim(dgeb_events->qual[dgeb_event_idx].event_detail1_txt,3))
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("   Log File Name: ",trim
       (dgeb_events->qual[dgeb_event_idx].event_detail3_txt,3))
      SET dgeb_fstart = 1
      FOR (dgeb_i = 3 TO dgeb_num_lines)
        IF (dgeb_i=3)
         SET dgeb_events->qual[dgeb_event_idx].body_text[dgeb_i].text_line = concat(
          "   Error Message: ",substring(dgeb_fstart,100,dgeb_events->qual[dgeb_event_idx].
           event_detail2_txt))
         SET dgeb_fstart = (dgeb_fstart+ 100)
        ELSE
         SET dgeb_events->qual[dgeb_event_idx].body_text[dgeb_i].text_line = concat(
          "                ",substring(dgeb_fstart,100,dgeb_events->qual[dgeb_event_idx].
           event_detail2_txt))
         SET dgeb_fstart = (dgeb_fstart+ 100)
        ENDIF
      ENDFOR
      SET dgeb_num_lines = (dgeb_num_lines+ 1)
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,dgeb_num_lines)
      SET dgeb_events->qual[dgeb_event_idx].body_text[dgeb_num_lines].text_line =
      "-----------------------------------------"
     ENDIF
    OF "Task Queue Finished":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Notification"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,3)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Notification ",trim(
       cnvtstring((dgeb_event_type+ 200))),":")
     SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
      "   All of the pending tasks have been completed for the ",dgeb_events->qual[dgeb_event_idx].
      event_reason,".")
    OF "Practice":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Practice"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = "This is a test email."
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_send_email(subject,address_list,file_name)
   DECLARE dse_sys = vc
   IF (validate(cursys2,"-1000")="-1000"
    AND validate(cursys2,"-9999")="-9999")
    SET dse_sys = cursys
   ELSE
    SET dse_sys = cursys2
   ENDIF
   IF (((trim(subject)="") OR (((trim(address_list)="") OR (trim(file_name)="")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dse_sys="AXP")
    CALL dm2_push_dcl(concat('MAIL/SUBJECT="',build(subject),'" ',build(file_name),' "',
      build(address_list),'"'))
   ELSEIF (dse_sys IN ("AIX", "LNX"))
    CALL dm2_push_dcl(concat('mail -s "',subject,'" "',address_list,'" < ',
      file_name))
   ELSEIF (dse_sys="HPX")
    CALL dm2_push_dcl(concat('mailx -s "',subject,'" "',address_list,'" < ',
      file_name))
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   ENDIF
   SET stat = remove(file_name)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    RETURN(1)
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
 DECLARE drrm_determine_source_target(ddst_events=vc(ref)) = i2
 DECLARE drrm_create_link(dcl_reltn_status=vc,dcl_events=vc(ref)) = i2
 DECLARE drrm_get_env_names(dgen_events=vc(ref)) = i2
 DECLARE drrm_get_mail_list(dgml_events=vc(ref),dgml_rec=vc(ref)) = i2
 DECLARE drrm_write_email_events(dwee_event_types=vc,dwee_email_address=vc,dwee_events=vc(ref)) = i2
 SUBROUTINE drrm_determine_source_target(ddst_events)
   DECLARE ddst_source_ind = i2
   DECLARE ddst_target_ind = i2
   SET ddst_source_ind = 0
   SET ddst_target_ind = 0
   SET dm_err->eproc = "Getting current environment's ID."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    b.environment_id
    FROM dm_info a,
     dm_environment b
    PLAN (a
     WHERE a.info_name="DM_ENV_ID"
      AND a.info_domain="DATA MANAGEMENT")
     JOIN (b
     WHERE a.info_number=b.environment_id)
    DETAIL
     ddst_events->cur_env_id = b.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Error: current environment id not found."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Validating if current environment is a target environment in any open events."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    drel.event_reason, drel.paired_environment_id
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=ddst_events->cur_env_id)
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     drela.cur_environment_id, drela.paired_environment_id, drela.event_reason
     FROM dm_rdds_event_log drela
     WHERE (drela.cur_environment_id=ddst_events->cur_env_id)
      AND drela.rdds_event="End Reference Data Sync"
      AND drela.rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     ddst_events->reltn_source_env_id = drel.paired_environment_id, ddst_events->target_event_name =
     drel.event_reason, ddst_target_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Validating if current environment is a source environment in any open events."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    drel.event_reason, drel.cur_environment_id
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.paired_environment_id=ddst_events->cur_env_id)
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     drela.cur_environment_id, drela.paired_environment_id, drela.event_reason
     FROM dm_rdds_event_log drela
     WHERE (drela.paired_environment_id=ddst_events->cur_env_id)
      AND drela.rdds_event="End Reference Data Sync"
      AND drela.rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     ddst_events->reltn_target_env_id = drel.cur_environment_id, ddst_events->source_event_name =
     drel.event_reason, ddst_source_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (ddst_source_ind=0
    AND ddst_target_ind=0)
    SET ddst_events->reltn_status = "NEITHER"
   ELSEIF (ddst_source_ind=1
    AND ddst_target_ind=0)
    SET ddst_events->reltn_status = "SOURCE"
   ELSEIF (ddst_source_ind=0
    AND ddst_target_ind=1)
    SET ddst_events->reltn_status = "TARGET"
   ELSEIF (ddst_source_ind=1
    AND ddst_target_ind=1)
    SET ddst_events->reltn_status = "BOTH"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_create_link(dcl_reltn_status,dcl_events)
   IF (dcl_reltn_status="SOURCE")
    SET dcl_events->source_env_id = dcl_events->cur_env_id
    SET dcl_events->target_env_id = dcl_events->reltn_target_env_id
   ELSEIF (dcl_reltn_status="TARGET")
    SET dcl_events->source_env_id = dcl_events->reltn_source_env_id
    SET dcl_events->target_env_id = dcl_events->cur_env_id
   ELSEIF (dcl_reltn_status="NEITHER")
    SET dcl_events->source_env_id = 0
    SET dcl_events->target_env_id = dcl_events->cur_env_id
   ELSE
    SET dm_err->eproc = "This relationship is not valid. Exiting DM_RMC_RDDS_MAIL process."
    RETURN(0)
   ENDIF
   SET dcl_events->link_name = trim(cnvtstring(dcl_events->cur_env_id))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_get_env_names(dgen_events,dgen_tgt_only_ind)
   IF (dgen_tgt_only_ind != 1)
    SET dm_err->eproc = "Getting Source environment name."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     de.environment_name
     FROM dm_environment de
     WHERE (de.environment_id=dgen_events->source_env_id)
     DETAIL
      dgen_events->source_env_name = de.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "No environment name found for source environment_id."
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Getting Target environment name."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    de.environment_name
    FROM dm_environment de
    WHERE (de.environment_id=dgen_events->target_env_id)
    DETAIL
     dgen_events->target_env_name = de.environment_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = "Error encountered while selecting environment name for target."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "No environment name found for target environment_id."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_get_mail_list(dgml_events,dgml_rec)
   SET dgml_rec->address_cnt = 0
   SET dgml_rec->email_address = ""
   SET dm_err->eproc = "Retrieving E-Mail Addresses."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    di.info_name
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=concat("RDDSPREF",dgml_events->link_name)
     AND di.info_char="E-Mail Address"
    DETAIL
     dgml_rec->address_cnt = (dgml_rec->address_cnt+ 1)
     IF ((dgml_rec->address_cnt > 1))
      dgml_rec->email_address = concat(dgml_rec->email_address,", ",di.info_name)
     ELSE
      dgml_rec->email_address = di.info_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "No email addresses found."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_write_email_events(dwee_event_types,dwee_email_address,dwee_events)
   DECLARE dwee_event_loop = i4
   DECLARE dwee_write_event_cnt = i4
   DECLARE dwee_subject = c50
   SET dwee_event_loop = 0
   SET dwee_write_event_cnt = 0
   SET dwee_subject = dwee_events->subject_text
   SET dwee_write_event_cnt = (dwee_write_event_cnt+ 1)
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Report E-Mailed"
   SET auto_ver_request->qual[1].cur_environment_id = dwee_events->target_env_id
   SET auto_ver_request->qual[1].paired_environment_id = dwee_events->source_env_id
   SET auto_ver_request->qual[1].event_reason = dwee_event_types
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,dwee_write_event_cnt)
   SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail1_txt = dwee_subject
   SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail2_txt =
   dwee_email_address
   FOR (dwee_event_loop = 1 TO size(dwee_events->qual,5))
     IF ((dwee_events->qual[dwee_event_loop].header_ind=1))
      IF ((dwee_events->qual[dwee_event_loop].event_detail1_txt > ""))
       SET dwee_write_event_cnt = (dwee_write_event_cnt+ 1)
       SET stat = alterlist(auto_ver_request->qual[1].detail_qual,dwee_write_event_cnt)
       SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail1_txt =
       dwee_events->qual[dwee_event_loop].event_detail1_txt
       IF ((dwee_events->qual[dwee_event_loop].event_type="Auto-Cutover Error"))
        SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail2_txt =
        dwee_events->qual[dwee_event_loop].event_type
       ELSE
        SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail2_txt =
        dwee_events->qual[dwee_event_loop].event_detail2_txt
       ENDIF
       SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_value = dwee_events->
       qual[dwee_event_loop].event_value
      ENDIF
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Executing DM_RMC_AUTO_VERIFY_SETUP."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   EXECUTE dm_rmc_auto_verify_setup
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
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
 IF ((validate(space_info->segment_chk_extents,- (1))=- (1))
  AND (validate(space_info->segment_chk_extents,- (2))=- (2)))
  FREE RECORD space_info
  RECORD space_info(
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 extent_mgmt = vc
      2 file_cnt = i4
      2 file[*]
        3 file_id = f8
        3 auto_extend = vc
        3 bytes = f8
        3 free_bytes = f8
      2 total_spc = f8
      2 free_spc = f8
    1 segment_cnt = i4
    1 segment[*]
      2 seg_name = vc
      2 seg_type = vc
      2 tspace_name = vc
      2 bytes = f8
      2 extents = f8
      2 max_extents = f8
      2 initial_extent = f8
      2 next_extent = f8
      2 chk_extents = i2
    1 segment_chk_extents = i2
  )
 ENDIF
 DECLARE dsi_get_segment_info(gsi_obj_name=vc,gsi_obj_type=vc) = i4
 DECLARE dsi_get_tspace_info(gti_tspace_name=vc,gti_obj_type=vc) = i2
 DECLARE dsi_get_all_space_info(gas_obj_name=vc,gas_obj_type=vc) = i2
 DECLARE dsi_init_segment_space_info(null) = i2
 DECLARE dsi_init_tspace_space_info(null) = i2
 DECLARE dsi_init_all_space_info(null) = i2
 SUBROUTINE dsi_init_all_space_info(null)
  CALL dsi_init_segment_space_info(null)
  CALL dsi_init_tspace_space_info(null)
 END ;Subroutine
 SUBROUTINE dsi_init_segment_space_info(null)
  SET stat = alterlist(space_info->segment,0)
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dsi_init_tspace_space_info(null)
  SET stat = alterlist(space_info->tspace,0)
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dsi_get_all_space_info(gas_obj_name,gas_obj_type)
   DECLARE dga_tspaces = i4
   DECLARE dga_tspaces_loop = i4
   DECLARE dga_ret = i2
   SET dga_ret = dsi_get_segment_info(gas_obj_name,gas_obj_type)
   IF (dga_ret=0)
    RETURN(0)
   ENDIF
   SET dga_tspaces = size(space_info->tspace,5)
   FOR (dga_tspaces_loop = 1 TO dga_tspaces)
    SET dga_ret = dsi_get_tspace_info(space_info->tspace[dga_tspaces_loop].tspace_name,"TABLESPACE")
    IF (dga_ret=0)
     RETURN(0)
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsi_get_segment_info(gsi_obj_name,gsi_obj_type)
   DECLARE gsi_seg_loop = i4 WITH protect, noconstant(0)
   DECLARE gsi_seg_name_pos = i4 WITH protect, noconstant(0)
   DECLARE gsi_seg_size = i4 WITH protect, noconstant(0)
   DECLARE gsi_tspace_loop = i4 WITH protect, noconstant(0)
   DECLARE gsi_tspace_pos = i4 WITH protect, noconstant(0)
   DECLARE gsi_tspace_size = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Getting segment/tablespace information"
   SELECT
    IF (gsi_obj_type="TABLE")
     FROM user_segments us
     WHERE ((us.segment_name=gsi_obj_name) OR (us.segment_name IN (
     (SELECT
      ui.index_name
      FROM user_indexes ui
      WHERE ui.table_name=gsi_obj_name))))
    ELSE
     FROM user_segments us
     WHERE us.segment_name=gsi_obj_name
      AND us.segment_type=gsi_obj_type
    ENDIF
    INTO "NL:"
    DETAIL
     gsi_seg_name_pos = locateval(gsi_seg_loop,1,gsi_seg_size,us.segment_name,space_info->segment[
      gsi_seg_loop].seg_name)
     IF (gsi_seg_name_pos=0)
      gsi_seg_size = (gsi_seg_size+ 1)
      IF (mod(gsi_seg_size,10)=1)
       stat = alterlist(space_info->segment,(gsi_seg_size+ 9))
      ENDIF
      gsi_seg_name_pos = gsi_seg_size, space_info->segment[gsi_seg_name_pos].seg_name = us
      .segment_name
     ENDIF
     space_info->segment[gsi_seg_name_pos].seg_type = us.segment_type, space_info->segment[
     gsi_seg_name_pos].tspace_name = us.tablespace_name, space_info->segment[gsi_seg_name_pos].bytes
      = us.bytes,
     space_info->segment[gsi_seg_name_pos].extents = us.extents, space_info->segment[gsi_seg_name_pos
     ].max_extents = us.max_extents, space_info->segment[gsi_seg_name_pos].initial_extent = us
     .initial_extent,
     space_info->segment[gsi_seg_name_pos].next_extent = us.next_extent
     IF ((space_info->segment[gsi_seg_name_pos].max_extents < 2000000000.0))
      space_info->segment[gsi_seg_name_pos].chk_extents = 1, space_info->segment_chk_extents = 1
     ENDIF
     gsi_tspace_pos = locateval(gsi_tspace_loop,1,gsi_seg_size,us.tablespace_name,space_info->tspace[
      gsi_tspace_loop].tspace_name)
     IF (gsi_tspace_pos=0)
      gsi_tspace_size = (gsi_tspace_size+ 1)
      IF (mod(gsi_tspace_size,10)=1)
       stat = alterlist(space_info->tspace,(gsi_tspace_size+ 9))
      ENDIF
      gsi_tspace_pos = gsi_tspace_size, space_info->tspace[gsi_tspace_pos].tspace_name = us
      .tablespace_name
     ENDIF
     IF ((space_info->segment[gsi_seg_name_pos].next_extent=0))
      space_info->tspace[gsi_tspace_pos].extent_mgmt = "LOCAL"
     ELSE
      space_info->tspace[gsi_tspace_pos].extent_mgmt = "DICTIONARY"
     ENDIF
     space_info->tspace_cnt = gsi_tspace_size, space_info->segment_cnt = gsi_seg_size
    FOOT REPORT
     stat = alterlist(space_info->segment,gsi_seg_size), stat = alterlist(space_info->tspace,
      gsi_tspace_size)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsi_get_tspace_info(gti_tspace_name,gti_obj_type)
   DECLARE gti_tspace_size = i4 WITH protect, noconstant(0)
   DECLARE gti_tspace_pos = i4 WITH protect, noconstant(0)
   DECLARE gti_tspace_loop = i4 WITH protect, noconstant(0)
   DECLARE gti_file_size = i4 WITH protect, noconstant(0)
   DECLARE gti_file_pos = i4 WITH protect, noconstant(0)
   DECLARE gti_file_loop = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Getting space information for tablespaces"
   SET gti_tspace_size = size(space_info->tspace,5)
   SET gti_tspace_pos = locateval(gti_tspace_loop,1,gti_tspace_size,gti_tspace_name,space_info->
    tspace[gti_tspace_loop].tspace_name)
   IF (gti_tspace_pos != 0)
    SET space_info->tspace[gti_tspace_pos].total_spc = 0
    SET space_info->tspace[gti_tspace_pos].free_spc = 0
    SET stat = alterlist(space_info->tspace[gti_tspace_pos].file,0)
   ENDIF
   SELECT INTO "NL:"
    FROM dba_data_files ddf
    WHERE ddf.tablespace_name=gti_tspace_name
    DETAIL
     IF (gti_tspace_pos=0)
      gti_tspace_size = (gti_tspace_size+ 1), stat = alterlist(space_info->tspace,gti_tspace_size),
      gti_tspace_pos = gti_tspace_size,
      space_info->tspace[gti_tspace_pos].tspace_name = ddf.tablespace_name
     ENDIF
     gti_file_size = size(space_info->tspace[gti_tspace_pos].file,5), gti_file_pos = locateval(
      gti_file_loop,1,gti_file_size,ddf.file_id,space_info->tspace[gti_tspace_pos].file[gti_file_loop
      ].file_id)
     IF (gti_file_pos=0)
      gti_file_pos = (gti_file_size+ 1), stat = alterlist(space_info->tspace[gti_tspace_pos].file,
       gti_file_pos), space_info->tspace[gti_tspace_pos].file[gti_file_pos].file_id = ddf.file_id
     ENDIF
     space_info->tspace[gti_tspace_pos].file_cnt = size(space_info->tspace[gti_tspace_pos].file,5)
     IF (ddf.autoextensible="YES")
      space_info->tspace[gti_tspace_pos].file[gti_file_pos].auto_extend = "YES", space_info->tspace[
      gti_tspace_pos].file[gti_file_pos].bytes = ddf.maxbytes, space_info->tspace[gti_tspace_pos].
      file[gti_file_pos].free_bytes = (space_info->tspace[gti_tspace_pos].file[gti_file_pos].
      free_bytes+ (ddf.maxbytes - ddf.user_bytes)),
      space_info->tspace[gti_tspace_pos].free_spc = (space_info->tspace[gti_tspace_pos].free_spc+ (
      ddf.maxbytes - ddf.user_bytes)), space_info->tspace[gti_tspace_pos].total_spc = (space_info->
      tspace[gti_tspace_pos].total_spc+ ddf.maxbytes)
     ELSE
      space_info->tspace[gti_tspace_pos].file[gti_file_pos].auto_extend = "NO", space_info->tspace[
      gti_tspace_pos].file[gti_file_pos].bytes = ddf.user_bytes, space_info->tspace[gti_tspace_pos].
      total_spc = (space_info->tspace[gti_tspace_pos].total_spc+ ddf.user_bytes)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    FROM dba_free_space dfs
    WHERE dfs.tablespace_name=gti_tspace_name
    DETAIL
     gti_tspace_pos = locateval(gti_tspace_loop,1,gti_tspace_size,dfs.tablespace_name,space_info->
      tspace[gti_tspace_loop].tspace_name), gti_file_pos = locateval(gti_file_loop,1,space_info->
      tspace[gti_tspace_pos].file_cnt,dfs.file_id,space_info->tspace[gti_tspace_pos].file[
      gti_file_loop].file_id)
     IF ((space_info->tspace[gti_tspace_pos].file[gti_file_pos].auto_extend="NO"))
      space_info->tspace[gti_tspace_pos].file[gti_file_pos].free_bytes = (space_info->tspace[
      gti_tspace_pos].file[gti_file_pos].free_bytes+ dfs.bytes), space_info->tspace[gti_tspace_pos].
      free_spc = (space_info->tspace[gti_tspace_pos].free_spc+ dfs.bytes)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (size(trim(space_info->tspace[gti_tspace_pos].extent_mgmt))=0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name=gti_tspace_name
     DETAIL
      space_info->tspace[gti_tspace_pos].extent_mgmt = dt.extent_management
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE drcd_drp_del(drp_str=vc) = i4
 SUBROUTINE drcd_drp_del(drp_str)
   SET dm_err->eproc = "Deleting from dm_refchg_process"
   DELETE  FROM dm_refchg_process d
    WHERE d.refchg_type=patstring(drp_str)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM gv$session g
     WHERE g.audsid=d.rdbhandle_value)))
    WITH nocounter
   ;end delete
   IF (check_error("Deleting dm_refchg_process rows.") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
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
 IF (validate(derg_request->env_id,- (1)) < 0)
  FREE RECORD derg_request
  RECORD derg_request(
    1 env_id = f8
    1 relationship_type = vc
  )
 ENDIF
 IF (validate(derg_reply->err_num,- (1)) < 0)
  FREE RECORD derg_reply
  RECORD derg_reply(
    1 parent_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 child_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 err_num = i4
    1 err_msg = vc
  )
 ENDIF
 DECLARE dmai_get_cur_mod_act(dgcma_mod_out=vc(ref),dmgca_act_out=vc(ref)) = i2
 DECLARE dmai_set_mod_act(module_name=vc,action_name=vc) = null WITH protect, sql =
 "SYS.DBMS_APPLICATION_INFO.SET_MODULE", parameter
 SUBROUTINE dmai_get_cur_mod_act(dgcma_mod_out,dmgca_act_out)
   DECLARE dgcma_mod_hold = vc WITH protect, noconstant("")
   DECLARE dgcma_act_hold = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Obtaining current Module and Action"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    HEAD REPORT
     dgcma_mod_hold = vs.module, dgcma_act_hold = vs.action
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgcma_mod_out = dgcma_mod_hold
   SET dmgca_act_out = dgcma_act_hold
   RETURN(1)
 END ;Subroutine
 DECLARE drrt_recompile_trigs(drt_cur_env_id=f8,drt_paired_env_id=f8,drt_event_reason=vc) = i4
 SUBROUTINE drrt_recompile_trigs(drt_cur_env_id,drt_paired_env_id,drt_event_reason)
   FREE RECORD drrs_invalid
   RECORD drt_invalid(
     1 data[*]
       2 name = vc
   ) WITH protect
   DECLARE drt_trig_cnt = i4 WITH protect, noconstant(0)
   DECLARE drt_i = i4 WITH protect, noconstant(0)
   DECLARE drt_j = i4 WITH protect, noconstant(0)
   DECLARE drt_k = i4 WITH protect, noconstant(0)
   DECLARE drt_module_name = vc WITH protect, constant("RDDS_PROCESS")
   DECLARE drt_action_name = vc WITH protect, constant("RDDS_DDL")
   DECLARE drt_original_module = vc WITH protect, noconstant(" ")
   DECLARE drt_original_action = vc WITH protect, noconstant(" ")
   DECLARE drt_module_set_ind = i2 WITH protect, noconstant(0)
   DECLARE drt_ret = i2 WITH protect, noconstant(1)
   IF (dm2_get_rdbms_version(null)=0)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   IF ((dm2_rdbms_version->level1 >= 11))
    IF (dmai_get_cur_mod_act(drt_original_module,drt_original_action)=0)
     RETURN(- (1))
    ELSE
     SET drt_module_set_ind = 1
    ENDIF
    CALL dmai_set_mod_act(drt_module_name,drt_action_name)
   ENDIF
   EXECUTE dm_rdds_update_trig_proc
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   SET dm_err->eproc = "RECOMPILING INVALID TRIGGERS"
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    HEAD REPORT
     drt_trig_cnt = 0
    DETAIL
     drt_trig_cnt = (drt_trig_cnt+ 1)
     IF (mod(drt_trig_cnt,10)=1)
      stat = alterlist(drt_invalid->data,(drt_trig_cnt+ 9))
     ENDIF
     drt_invalid->data[drt_trig_cnt].name = d1.object_name
    FOOT REPORT
     stat = alterlist(drt_invalid->data,drt_trig_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   FOR (drt_i = 1 TO size(drt_invalid->data,5))
     CALL parser(concat("RDB ASIS(^alter trigger ",drt_invalid->data[drt_i].name," compile^) go"))
   ENDFOR
   SELECT INTO "NL:"
    d1.object_name
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    WITH nocounter, maxqual(d1,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   IF (curqual > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid triggers detected."
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   IF ((dm_err->err_ind=0))
    SET stat = alterlist(auto_ver_request->qual,size(derg_reply->child_env_list,5))
    SELECT INTO "nl:"
     ut.table_name, cnt = count(*)
     FROM user_triggers ut
     WHERE ((ut.trigger_name="REFCHG????ADD") OR (((ut.trigger_name="REFCHG????UPD") OR (ut
     .trigger_name="REFCHG????DEL")) ))
     GROUP BY ut.table_name
     HEAD REPORT
      drt_trig_cnt = 0
     DETAIL
      drt_trig_cnt = (drt_trig_cnt+ 1)
      IF (mod(drt_trig_cnt,10)=1)
       stat = alterlist(auto_ver_request->qual[1].detail_qual,(drt_trig_cnt+ 9))
      ENDIF
      auto_ver_request->qual[1].detail_qual[drt_trig_cnt].event_detail1_txt = ut.table_name,
      auto_ver_request->qual[1].detail_qual[drt_trig_cnt].event_value = cnt
     FOOT REPORT
      stat = alterlist(auto_ver_request->qual[1].detail_qual,drt_trig_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drt_ret = - (1)
     GO TO exit_drt_sub
    ENDIF
    FOR (drt_j = 1 TO size(derg_reply->child_env_list,5))
      SET auto_ver_request->qual[drt_j].rdds_event = "Add Environment Triggers"
      SET auto_ver_request->qual[drt_j].cur_environment_id = drt_cur_env_id
      SET auto_ver_request->qual[drt_j].paired_environment_id = derg_reply->child_env_list[drt_j].
      env_id
      SET auto_ver_request->qual[drt_j].event_reason = drt_event_reason
      IF (drt_j > 1)
       SET stat = alterlist(auto_ver_request->qual[drt_j].detail_qual,drt_trig_cnt)
       FOR (drt_k = 1 TO drt_trig_cnt)
        SET auto_ver_request->qual[drt_j].detail_qual[drt_k].event_detail1_txt = auto_ver_request->
        qual[1].detail_qual[drt_k].event_detail1_txt
        SET auto_ver_request->qual[drt_j].detail_qual[drt_k].event_value = auto_ver_request->qual[1].
        detail_qual[drt_k].event_value
       ENDFOR
      ENDIF
    ENDFOR
    EXECUTE dm_rmc_auto_verify_setup
    IF ((auto_ver_reply->status="F"))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drt_ret = - (1)
     GO TO exit_drt_sub
    ELSE
     COMMIT
    ENDIF
   ELSE
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
#exit_drt_sub
   IF (drt_module_set_ind=1)
    CALL dmai_set_mod_act(drt_original_module,drt_original_action)
   ENDIF
   RETURN(drt_ret)
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
 DECLARE dcs_check_cbc(null) = i2
 DECLARE dcs_gather_cbc_ctxt(dgcc_cbc_ctxts=vc(ref)) = i2
 SUBROUTINE dcs_check_cbc(null)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONFIGURATION"
     AND d.info_name="CUTOVER BY CONTEXT"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE dcs_gather_cbc_ctxt(dgcc_cbc_ctxts)
   SET stat = alterlist(dgcc_cbc_ctxts->cur_ctxt_qual,0)
   SET dgcc_cbc_ctxts->cur_ctxt_cnt = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONFIGURATION:RDDS CONTEXT TO CUTOVER"
    DETAIL
     dgcc_cbc_ctxts->cur_ctxt_cnt = (dgcc_cbc_ctxts->cur_ctxt_cnt+ 1), stat = alterlist(
      dgcc_cbc_ctxts->cur_ctxt_qual,dgcc_cbc_ctxts->cur_ctxt_cnt), dgcc_cbc_ctxts->cur_ctxt_qual[
     dgcc_cbc_ctxts->cur_ctxt_cnt].context_name = d.info_name
     IF (d.info_name="ALL")
      dgcc_cbc_ctxts->all_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(0)
 END ;Subroutine
 IF ((validate(dmam_rs->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dmam_rs
  RECORD dmam_rs(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 oe_dt_tm = f8
    1 refresh_time = vc
    1 num_procs = i4
    1 cycle_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 action = vc
      2 act_count = i4
      2 act_hour = vc
      2 action_dt = dq8
    1 det_cnt = i4
    1 det[*]
      2 table_name = vc
      2 action = vc
      2 action_dt = vc
      2 action_text = vc
      2 audsid = f8
      2 process = vc
      2 logfile = vc
  )
 ENDIF
 DECLARE dmam_gather_data(dgd_rs=vc(ref)) = null
 SUBROUTINE dmam_gather_data(dgd_rs,dgd_audsid)
   DECLARE dgd_pos = i4 WITH protect, noconstant(0)
   DECLARE dgd_ind = i2 WITH protect, noconstant(0)
   DECLARE dgd_idx = i4 WITH protect, noconstant(0)
   DECLARE dgd_lvidx = i4 WITH protect, noconstant(0)
   IF ((dgd_rs->cur_id=0.0))
    SET dm_err->eproc = "Getting current environment_id."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"
     DETAIL
      dgd_rs->cur_id = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No local environment_id set.  Please use DM_SET_ENV_ID to set one."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF ((dgd_rs->src_id=0.0))
    SET dm_err->eproc = "Getting environment_id of open event."
    SELECT INTO "NL:"
     FROM dm_rdds_event_log d
     WHERE (d.cur_environment_id=dgd_rs->cur_id)
      AND d.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND  NOT (list(d.paired_environment_id,d.event_reason) IN (
     (SELECT
      d1.paired_environment_id, d1.event_reason
      FROM dm_rdds_event_log d1
      WHERE (d1.cur_environment_id=dgd_rs->cur_id)
       AND d1.rdds_event_key="ENDREFERENCEDATASYNC")))
     DETAIL
      dgd_rs->src_id = d.paired_environment_id, dgd_rs->oe_name = concat(trim(d.event_reason),"(",
       format(d.event_dt_tm,"dd-mmm-yy HH:MM:SS;;q"),")"), dgd_rs->oe_dt_tm = d.event_dt_tm
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("No open event detected for target environment ",dgd_rs->cur_name,
      ". The mover activity report will not run.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF ((((dgd_rs->src_name <= " ")) OR ((dgd_rs->cur_name <= " "))) )
    SET dm_err->eproc = "Getting getting source environment name."
    SELECT INTO "NL:"
     FROM dm_environment d
     WHERE d.environment_id IN (dgd_rs->src_id, dgd_rs->cur_id)
     DETAIL
      IF ((d.environment_id=dgd_rs->cur_id))
       dgd_rs->cur_name = d.environment_name
      ELSE
       dgd_rs->src_name = d.environment_name
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF ((dgd_rs->cur_name <= " "))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No environment_id in DM_ENVIORNMENT.  Please use DM_SET_ENV_ID to set one."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ELSEIF ((dgd_rs->src_name <= " "))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No environment_id in DM_ENVIORNMENT for source environment_id ",trim(
      cnvtstring(dgd_rs->src_id)))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET dgd_rs->refresh_time = concat("As of ",format(cnvtdatetime(curdate,curtime3),
     "dd-mmm-yy HH:MM:SS;;q")," (auto refresh in 30 sec)")
   IF ((dgd_rs->oe_dt_tm > 0.0))
    SET dm_err->eproc = "Query for Mover Activity"
    SET dgd_rs->cnt = 0
    SET stat = alterlist(dgd_rs->qual,0)
    SELECT INTO "nl:"
     act_hour = format(d.audit_dt_tm,"DD-MMM-YYYY HH;;D"), d.action, d.table_name,
     cnt = count(*), ord_dt = max(d.audit_dt_tm)
     FROM dm_chg_log_audit d
     WHERE d.action IN ("INSERT", "UPDATE", "BATCH END", "RTBLCREATE", "FAILREASON",
     "BATCH START", "DELETE")
      AND d.audit_dt_tm >= cnvtdatetime(dgd_rs->oe_dt_tm)
     GROUP BY format(d.audit_dt_tm,"DD-MMM-YYYY HH;;D"), d.table_name, d.action
     ORDER BY ord_dt DESC, d.action, d.table_name
     DETAIL
      dgd_ind = 0
      IF (d.action="BATCH*")
       dgd_pos = locateval(dgd_pos,1,dgd_rs->cnt,d.action,dgd_rs->qual[dgd_pos].action,
        act_hour,dgd_rs->qual[dgd_pos].act_hour)
       IF (dgd_pos > 0)
        dgd_rs->qual[dgd_pos].act_count = (dgd_rs->qual[dgd_pos].act_count+ cnt), dgd_ind = 1
       ENDIF
      ENDIF
      IF (dgd_ind=0)
       dgd_rs->cnt = (dgd_rs->cnt+ 1)
       IF (mod(dgd_rs->cnt,10)=1)
        stat = alterlist(dgd_rs->qual,(dgd_rs->cnt+ 9))
       ENDIF
       dgd_rs->qual[dgd_rs->cnt].table_name = d.table_name, dgd_rs->qual[dgd_rs->cnt].action = d
       .action
       IF (d.action="BATCH*")
        dgd_rs->qual[dgd_rs->cnt].table_name = " "
       ELSEIF (d.action="FAILREASON")
        dgd_rs->qual[dgd_rs->cnt].action = "NO MERGE"
       ELSEIF (d.action="RTBLCREATE")
        dgd_rs->qual[dgd_rs->cnt].action = "TEMP TABLE CREATED"
       ELSEIF (d.action IN ("INSERT", "UPDATE"))
        dgd_rs->qual[dgd_rs->cnt].action = "INSERT/UPDATE"
       ENDIF
       dgd_rs->qual[dgd_rs->cnt].act_hour = act_hour, dgd_rs->qual[dgd_rs->cnt].act_count = cnt,
       dgd_rs->qual[dgd_rs->cnt].action_dt = ord_dt
      ENDIF
     FOOT REPORT
      stat = alterlist(dgd_rs->qual,dgd_rs->cnt), dgd_rs->qual[1].act_hour = concat(dgd_rs->qual[1].
       act_hour,"**"), dgd_rs->qual[dgd_rs->cnt].act_hour = concat(act_hour,"**")
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   SET dm_err->eproc = "Query for number of mover processes"
   SELECT INTO "NL:"
    cnt = count(*)
    FROM dm_refchg_process d
    WHERE d.refchg_type="MOVER PROCESS"
     AND  NOT (d.refchg_status IN ("WRITING HANG FILE", "ORPHANED MOVER", "HANGING MOVER"))
     AND (d.env_source_id=dgd_rs->src_id)
     AND d.rdbhandle_value IN (
    (SELECT
     audsid
     FROM gv$session))
    DETAIL
     dgd_rs->num_procs = cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (dgd_audsid > 0)
    SET dgd_rs->det_cnt = 0
    SET stat = alterlist(dgd_rs->det,0)
    SELECT INTO "nl:"
     FROM dm_chg_log_audit d
     WHERE d.action IN ("INSERT", "UPDATE", "BATCH END", "RTBLCREATE", "FAILREASON",
     "BATCH START", "DELETE")
      AND d.audit_dt_tm >= cnvtdatetime(dgd_rs->oe_dt_tm)
      AND d.updt_applctx=dgd_audsid
     ORDER BY d.audit_dt_tm DESC, d.action, d.table_name
     DETAIL
      dgd_rs->det_cnt = (dgd_rs->det_cnt+ 1)
      IF (mod(dgd_rs->det_cnt,10)=1)
       stat = alterlist(dgd_rs->det,(dgd_rs->det_cnt+ 9))
      ENDIF
      dgd_rs->det[dgd_rs->det_cnt].table_name = d.table_name, dgd_rs->det[dgd_rs->det_cnt].action = d
      .action
      IF (d.action="BATCH*")
       dgd_rs->det[dgd_rs->det_cnt].table_name = " "
      ELSEIF (d.action="FAILREASON")
       dgd_rs->det[dgd_rs->det_cnt].action = "NO MERGE"
      ELSEIF (d.action="RTBLCREATE")
       dgd_rs->det[dgd_rs->det_cnt].action = "TEMP TABLE CREATED"
      ELSEIF (d.action IN ("INSERT", "UPDATE"))
       dgd_rs->det[dgd_rs->det_cnt].action = "INSERT/UPDATE"
      ENDIF
      dgd_rs->det[dgd_rs->det_cnt].action_dt = format(d.audit_dt_tm,"dd-mmm-yy HH:MM:SS;;q"), dgd_rs
      ->det[dgd_rs->det_cnt].action_text = d.text, dgd_rs->det[dgd_rs->det_cnt].audsid = d
      .updt_applctx,
      dgd_rs->det[dgd_rs->det_cnt].process = "Not Active", dgd_rs->det[dgd_rs->det_cnt].logfile =
      "Not Available"
     FOOT REPORT
      stat = alterlist(dgd_rs->det,dgd_rs->det_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    SET dm_err->eproc = "Query for mover process ids"
    SELECT INTO "NL:"
     FROM v$session v
     WHERE v.audsid=dgd_audsid
     DETAIL
      FOR (dgd_lvidx = 1 TO dgd_rs->det_cnt)
        dgd_rs->det[dgd_lvidx].process = v.process
      ENDFOR
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    SET dm_err->eproc = "Query for mover log files"
    SELECT INTO "NL:"
     FROM dm_refchg_process drp
     WHERE drp.rdbhandle_value=dgd_audsid
     DETAIL
      FOR (dgd_lvidx = 1 TO dgd_rs->det_cnt)
        dgd_rs->det[dgd_lvidx].logfile = drp.log_file
      ENDFOR
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   SET dm_err->eproc = "Checking last cycle time"
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="RDDS STOP TIME"
    DETAIL
     dgd_rs->cycle_time = concat(trim(cnvtstring(datetimediff(cnvtdatetime(curdate,curtime3),d
         .info_date,4)))," minutes ago")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ELSEIF (curqual=0)
    SET dgd_rs->cycle_time = "Not Yet Cycled"
   ENDIF
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
 DECLARE parse_string(i_string=vc,i_string_delim=vc,io_string_rs=vc(ref)) = null
 DECLARE encode_html_string(io_string=vc) = vc
 DECLARE copy_xsl(i_template_name=vc,i_file_name=vc) = i2
 DECLARE dmda_get_file_name(i_env_id=f8,i_env_name=vc,i_mnu_hdg=vc,i_default_name=vc,i_file_xtn=vc,
  i_type=vc) = vc
 SUBROUTINE parse_string(i_string,i_string_delim,io_string_rs)
   DECLARE ps_delim_len = i4 WITH protect, noconstant(size(i_string_delim))
   DECLARE ps_str_len = i4 WITH protect, noconstant(size(i_string))
   DECLARE ps_start = i4 WITH protect, noconstant(1)
   DECLARE ps_pos = i4 WITH protect, noconstant(0)
   DECLARE ps_num_found = i4 WITH protect, noconstant(0)
   DECLARE ps_idx = i4 WITH protect, noconstant(0)
   DECLARE ps_loop = i4 WITH protect, noconstant(0)
   DECLARE ps_temp_string = vc WITH protect, noconstant("")
   SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   SET ps_num_found = size(io_string_rs->qual,5)
   WHILE (ps_pos > 0)
     SET ps_num_found = (ps_num_found+ 1)
     SET ps_temp_string = substring(ps_start,(ps_pos - ps_start),i_string)
     IF (ps_num_found > 1)
      SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
       values)
     ELSE
      SET ps_idx = 0
     ENDIF
     IF (ps_idx=0)
      SET stat = alterlist(io_string_rs->qual,ps_num_found)
      SET io_string_rs->qual[ps_num_found].values = ps_temp_string
     ELSE
      SET ps_num_found = (ps_num_found - 1)
     ENDIF
     SET ps_start = (ps_pos+ ps_delim_len)
     SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   ENDWHILE
   IF (ps_start <= ps_str_len)
    SET ps_num_found = (ps_num_found+ 1)
    SET ps_temp_string = substring(ps_start,((ps_str_len - ps_start)+ 1),i_string)
    IF (ps_num_found > 1)
     SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
      values)
    ELSE
     SET ps_idx = 0
    ENDIF
    IF (ps_idx=0)
     SET stat = alterlist(io_string_rs->qual,ps_num_found)
     SET io_string_rs->qual[ps_num_found].values = ps_temp_string
    ELSE
     SET ps_num_found = (ps_num_found - 1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE encode_html_string(i_string)
   SET i_string = replace(i_string,"&","&amp;",0)
   SET i_string = replace(i_string,"<","&lt;",0)
   SET i_string = replace(i_string,">","&gt;",0)
   RETURN(i_string)
 END ;Subroutine
 SUBROUTINE copy_xsl(i_template_name,i_file_name)
   SET dm_err->eproc = "Copying Stylesheet"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE cx_cmd = vc WITH protect, noconstant("")
   DECLARE cx_status = i4 WITH protect, noconstant(0)
   IF (cursys="AXP")
    SET cx_cmd = concat("COPY CER_INSTALL:",trim(i_template_name,3)," CCLUSERDIR:",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ELSE
    SET cx_cmd = concat("cp $cer_install/",trim(i_template_name,3)," $CCLUSERDIR/",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dmda_get_file_name(i_env_id,i_env_name,i_mnu_hdg,i_default_name,i_file_xtn,i_type)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgfn_file_name = vc
   DECLARE dgfn_menu = i2
   DECLARE dgfn_file_xtn = vc
   DECLARE dgfn_default_name = vc
   IF (findstring(".",i_file_xtn)=0)
    SET dgfn_file_xtn = cnvtlower(concat(".",i_file_xtn))
   ELSE
    SET dgfn_file_xtn = cnvtlower(i_file_xtn)
   ENDIF
   IF (findstring(".",i_default_name) > 0)
    SET dgfn_default_name = cnvtlower(substring(1,(findstring(".",i_default_name) - 1),i_default_name
      ))
   ELSE
    SET dgfn_default_name = cnvtlower(i_default_name)
   ENDIF
   CALL check_lock("RDDS FILENAME LOCK",concat(dgfn_default_name,dgfn_file_xtn),drl_reply)
   IF ((drl_reply->status="F"))
    RETURN("-1")
   ELSEIF ((drl_reply->status="Z"))
    SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
         currdbhandle))),dgfn_default_name)),currdbhandle)
   ENDIF
   SET stat = initrec(drl_reply)
   SET dgfn_menu = 0
   WHILE (dgfn_menu=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,concat("***  ",i_mnu_hdg,"  ***"))
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(i_env_id))
     CALL text(4,40,i_env_name)
     CALL text(7,3,concat("Please enter a file name for ",i_type," (0 to exit): "))
     CALL text(9,3,"NOTE: This will overwrite any file in CCLUSERDIR with the same name.")
     SET accept = nopatcheck
     CALL accept(7,70,"P(30);C",trim(build(dgfn_default_name,dgfn_file_xtn)))
     SET accept = patcheck
     SET dgfn_file_name = curaccept
     IF (dgfn_file_name="0")
      SET dgfn_menu = 1
      RETURN("-1")
     ENDIF
     IF (findstring(".",dgfn_file_name)=0)
      SET dgfn_file_name = concat(dgfn_file_name,dgfn_file_xtn)
     ENDIF
     IF (size(dgfn_file_name) > 30)
      SET dgfn_file_name = concat(trim(substring(1,(30 - size(dgfn_file_xtn)),dgfn_file_name)),
       dgfn_file_xtn)
     ENDIF
     CALL check_lock("RDDS FILENAME LOCK",dgfn_file_name,drl_reply)
     IF ((drl_reply->status="F"))
      RETURN("-1")
     ENDIF
     IF (cnvtlower(substring(findstring(".",dgfn_file_name),size(dgfn_file_name,1),dgfn_file_name))
      != cnvtlower(dgfn_file_xtn))
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgfn_file_xtn))
      CALL pause(5)
     ELSEIF ((drl_reply->status="Z"))
      CALL text(20,3,concat("File name ",dgfn_file_name,
        " is currently locked, please choose a different filename."))
      CALL pause(5)
      IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
        currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
       SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name
         ),trim(currdbhandle))
      ELSE
       SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
            currdbhandle))),dgfn_file_name)),trim(currdbhandle))
      ENDIF
     ELSE
      CALL get_lock("RDDS FILENAME LOCK",dgfn_file_name,1,drl_reply)
      IF ((drl_reply->status="F"))
       RETURN("-1")
      ELSEIF ((drl_reply->status="Z"))
       CALL text(20,3,concat("File name ",dgfn_file_name,
         " is currently locked, please choose a different filename."))
       CALL pause(5)
       IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
         currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
        SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),
          dgfn_file_name),trim(currdbhandle))
       ELSE
        SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
             currdbhandle))),dgfn_file_name)),trim(currdbhandle))
       ENDIF
      ELSE
       SET dgfn_menu = 1
      ENDIF
     ENDIF
     SET stat = initrec(drl_reply)
   ENDWHILE
   RETURN(dgfn_file_name)
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
 IF (validate(drcec_request)=0)
  FREE RECORD drcec_request
  RECORD drcec_request(
    1 cur_env_id = f8
  )
 ENDIF
 IF (validate(drcec_reply)=0)
  FREE RECORD drcec_reply
  RECORD drcec_reply(
    1 ret_msg = vc
    1 ret_val = i4
  )
 ENDIF
 DECLARE drdc_wrap_menu_lines(dwml_str=vc,dwml_cur_row_pos=i4,dwml_cur_col_pos=i4,
  dwml_multi_line_buffer=vc,dwml_max_lines=i4,
  dwml_max_col=i4) = i4
 DECLARE drdc_get_name(dgn_name=vc,dgn_file=vc) = vc
 DECLARE drdc_file_success(dfs_name=vc,dfs_file_name=vc,dfs_error_ind=i2) = null
 IF ((validate(dclm_rs->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_rs
  RECORD dclm_rs(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_tier = i4
    1 del_row_ind = i2
    1 max_tier = i4
    1 num_procs = i4
    1 nomv_ind = i2
    1 mover_stale_ind = i2
    1 cycle_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 ctp_str = vc
    1 cts_str = vc
    1 group_ind = i2
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 reporting_cnt = i4
    1 reporting_qual[*]
      2 log_type = vc
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 non_ctxt_cnt = i4
    1 non_ctxt_qual[*]
      2 values = vc
  )
 ENDIF
 IF ((validate(dclm_all->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_all
  RECORD dclm_all(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 type_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 lt_cnt = i4
  )
 ENDIF
 IF ((validate(dclm_issues->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_issues
  RECORD dclm_issues(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 max_lines = i4
    1 cur_rs_pos = i4
    1 ctp_str = vc
    1 sort_flag = i4
    1 cur_flag = i4
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 lt_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 inv_ind = i2
      2 log_msg = vc
      2 child_type = vc
      2 log_type_sum = i4
      2 child_cnt_sum = i4
      2 tab_cnt = i4
      2 tab_qual[*]
        3 table_name = vc
        3 row_cnt = i4
  )
 ENDIF
 SUBROUTINE drdc_wrap_menu_lines(dwml_str,dwml_cur_row_pos,dwml_cur_col_pos,dwml_multi_line_buffer,
  dwml_max_lines,dwml_max_col)
   DECLARE dwml_temp_str = vc WITH protect, noconstant("")
   DECLARE dwml_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dwml_partial_str = vc WITH protect, noconstant("")
   DECLARE dwml_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dwml_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dwml_max_val = i4 WITH protect, noconstant(0)
   SET dwml_max_val = dwml_max_col
   IF (dwml_max_val=0)
    SET dwml_max_val = 132
   ENDIF
   SET dwml_temp_str = dwml_str
   SET dwml_done_ind = 0
   WHILE (dwml_done_ind=0)
     IF (size(dwml_temp_str) < dwml_max_val)
      SET dwml_partial_str = dwml_temp_str
      SET dwml_done_ind = 1
     ELSE
      SET dwml_partial_str = substring(1,value(dwml_max_val),dwml_temp_str)
      SET dwml_stop_pos = findstring(" ",dwml_partial_str,1,1)
      IF (dwml_stop_pos=0)
       SET dwml_stop_pos = dwml_max_val
      ENDIF
      SET dwml_partial_str = substring(1,dwml_stop_pos,dwml_temp_str)
      IF (dwml_multi_line_buffer >= " ")
       SET dwml_temp_str = concat(dwml_multi_line_buffer,substring((dwml_stop_pos+ 1),(size(
          dwml_temp_str) - dwml_stop_pos),dwml_temp_str))
      ELSE
       SET dwml_temp_str = substring((dwml_stop_pos+ 1),(size(dwml_temp_str) - dwml_stop_pos),
        dwml_temp_str)
      ENDIF
     ENDIF
     IF (((dwml_line_cnt+ 1)=dwml_max_lines)
      AND dwml_done_ind=0
      AND dwml_max_lines > 0)
      SET dwml_partial_str = concat(substring(1,(dwml_max_val - 3),dwml_partial_str),"...")
      SET dwml_done_ind = 1
     ENDIF
     CALL text(dwml_cur_row_pos,dwml_cur_col_pos,dwml_partial_str)
     SET dwml_cur_row_pos = (dwml_cur_row_pos+ 1)
     SET dwml_line_cnt = (dwml_line_cnt+ 1)
   ENDWHILE
   RETURN(dwml_cur_row_pos)
 END ;Subroutine
 SUBROUTINE drdc_get_name(dgn_name,dgn_file)
   SET dm_err->eproc = "Getting report file name"
   DECLARE dgn_file_name = vc WITH protect, noconstant("")
   DECLARE dgn_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgn_title = vc WITH protect, noconstant("")
   SET dgn_title = concat("*** ",dgn_name," ***")
   WHILE (dgn_done_ind=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgn_title)/ 2))),dgn_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgn_name,
       " report to extract into. (0 to exit): "))
     CALL accept(7,15,"P(30);CU",value(dgn_file))
     SET dgn_file_name = curaccept
     SET dgn_file_name = cnvtlower(dgn_file_name)
     IF (dgn_file_name="0")
      RETURN("-1")
      CALL text(20,3,"No extract will be made")
      CALL pause(3)
      SET dgn_done_ind = 1
     ENDIF
     IF (findstring(".",dgn_file_name)=0)
      SET dgn_file_name = concat(dgn_file_name,".csv")
      SET dgn_done_ind = 1
     ENDIF
     IF (substring(findstring(".",dgn_file_name),size(dgn_file_name,1),dgn_file_name) != ".csv")
      CALL text(20,3,"Invalid file type, file extension must be .csv")
      CALL pause(3)
     ELSE
      SET dgn_done_ind = 1
     ENDIF
   ENDWHILE
   RETURN(dgn_file_name)
 END ;Subroutine
 SUBROUTINE drdc_file_success(dfs_name,dfs_file_name,dfs_error_ind)
   DECLARE dfs_title = vc WITH protect, noconstant("")
   DECLARE dfs_pos = i4 WITH protect, noconstant(0)
   SET dfs_title = concat("*** ",dfs_name," ***")
   IF (dfs_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report complete!")
    CALL text(7,3,
     "For optimal viewing, the following file needs to be moved from CCLUSERDIR to a PC:")
    CALL text(8,3,"-----------------------------")
    CALL text(9,3,dfs_file_name)
    CALL text(10,3,"-----------------------------")
    CALL text(12,3,"Press enter to return:")
    CALL accept(12,26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report was not successful.  The following error occurred!")
    SET dfs_pos = drdc_wrap_menu_lines(dm_err->emsg,7,3,"   ",0,
     120)
    CALL text((dfs_pos+ 1),3,"Press enter to return:")
    CALL accept((dfs_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
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
 DECLARE drcm_get_imp_file(dgf_name=vc,dgf_file=vc,dgf_xtn=vc) = vc
 DECLARE drcm_check_context(dcc_ctxt_name=vc,dcc_null_allowed_ind=i2) = i2
 DECLARE drcm_file_complete(dfc_name=vc,dfc_files=vc(ref),dvc_type=vc,dfc_error_ind=i2) = null
 DECLARE check_error_gui(ceg_proc=vc,ceg_menu_screen=vc,ceg_env_name=vc,ceg_env_id=f8) = i4
 DECLARE drcm_dbase_connect(ddc_password=vc(ref),ddc_sid=vc(ref)) = i4
 DECLARE drcm_retry_connect(retry_reason=vc) = i4
 DECLARE drcm_check_user(null) = i2
 IF ((validate(drcm_files->cnt,- (2))=- (2)))
  FREE RECORD drcm_files
  RECORD drcm_files(
    1 cnt = i4
    1 qual[*]
      2 file_name = vc
  )
 ENDIF
 SUBROUTINE drcm_get_imp_file(dgf_name,dgf_file,dgf_xtn)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgf_file_name = vc WITH protect, noconstant("")
   DECLARE dgf_full_file = vc WITH protect, noconstant("")
   DECLARE dgf_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgf_valid_ind = i2 WITH protect, noconstant(1)
   DECLARE dgf_title = vc WITH protect, noconstant("")
   SET dgf_title = concat("*** ",dgf_name," ***")
   WHILE (dgf_done_ind=0)
     SET dgf_valid_ind = 1
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgf_title)/ 2))),dgf_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgf_name,
       " to be imported from (0 to exit): "))
     CALL text(9,3,concat("Example: myfilename",dgf_xtn))
     CALL text(10,3,concat("NOTE: File must be located in CCLUSERDIR "))
     SET accept = nopatcheck
     CALL accept(7,3,"P(30);CU",value(dgf_file))
     SET accept = patcheck
     SET dgf_file_name = curaccept
     SET dgf_file_name = cnvtlower(dgf_file_name)
     IF (dgf_file_name="0")
      RETURN("0")
     ENDIF
     IF (findstring(".",dgf_file_name)=0)
      SET dgf_file_name = concat(dgf_file_name,dgf_xtn)
     ELSEIF (substring(findstring(".",dgf_file_name),((size(dgf_file_name,1) - findstring(".",
       dgf_file_name))+ 1),dgf_file_name) != dgf_xtn)
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgf_xtn))
      CALL pause(3)
      SET dgf_valid_ind = 0
     ENDIF
     IF (size(dgf_file_name,1) >= 31)
      SET dgf_valid_ind = 0
     ENDIF
     IF (dgf_valid_ind=1)
      SET dgf_full_file = concat(trim(logical("CCLUSERDIR")),"/",dgf_file_name)
      IF (findfile(value(dgf_full_file))=0)
       SET message = window
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,4,132)
       CALL text(3,(66 - ceil((size(dgf_title)/ 2))),dgf_title)
       CALL text(6,3,concat(dgf_file_name," could not be found in CCLLUSERDIR."))
       CALL text(7,3,"Please ensure file is located in CCLUSERDIR")
       CALL text(10,3,"Press enter to continue.")
       CALL accept(10,28,"P;E"," ")
      ELSE
       SET dgf_done_ind = 1
      ENDIF
      SET dgf_file_name = dgf_full_file
     ENDIF
   ENDWHILE
   RETURN(dgf_file_name)
 END ;Subroutine
 SUBROUTINE drcm_check_context(dcc_ctxt_name,dcc_null_allowed_ind)
   DECLARE dcc_valid_ind = i2 WITH protect, noconstant(0)
   IF (size(trim(dcc_ctxt_name),1) <= 24
    AND dcc_ctxt_name != "ALL"
    AND findstring(":",dcc_ctxt_name)=0
    AND size(trim(dcc_ctxt_name),1) > 0
    AND ((dcc_ctxt_name != "NULL"
    AND dcc_null_allowed_ind=0) OR (dcc_ctxt_name="NULL"
    AND dcc_null_allowed_ind=1)) )
    SET dcc_valid_ind = 1
   ELSE
    SET dcc_valid_ind = 0
   ENDIF
   RETURN(dcc_valid_ind)
 END ;Subroutine
 SUBROUTINE drcm_file_complete(dfc_name,dfc_files,dfc_type,dfc_num,dfc_error_ind,dfc_env_name,
  dfc_env_id)
   DECLARE dfc_title = vc WITH protect, noconstant("")
   DECLARE dfc_pos = i4 WITH protect, noconstant(0)
   DECLARE dfc_loop = i4 WITH protect, noconstant(0)
   DECLARE dfc_line = i4 WITH protect, noconstant(11)
   SET dfc_title = concat("*** ",dfc_name," ***")
   IF (dfc_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,(66 - ceil((size(dfc_title)/ 2))),dfc_title)
    CALL text(4,75,"ENVIRONMENT ID:")
    CALL text(4,20,"ENVIRONMENT NAME:")
    CALL text(4,95,cnvtstring(dfc_env_id))
    CALL text(4,40,dfc_env_name)
    CALL text(7,3,concat(dfc_type," complete!"))
    IF (dfc_type="Export")
     CALL text(8,3,concat(trim(cnvtstring(dfc_num))," rows were exported"))
    ENDIF
    CALL text(9,3,
     "For optimal viewing, the following file(s) needs to be moved from CCLUSERDIR to a PC:")
    CALL text(10,3,"-----------------------------")
    FOR (dfc_loop = 1 TO dfc_files->cnt)
     CALL text(dfc_line,3,dfc_files->qual[dfc_loop].file_name)
     SET dfc_line = (dfc_line+ 1)
    ENDFOR
    CALL text(dfc_line,3,"-----------------------------")
    CALL text((dfc_line+ 2),3,"Press enter to return:")
    CALL accept((dfc_line+ 2),26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,(66 - ceil((size(dfc_title)/ 2))),dfc_title)
    CALL text(7,3,concat(dfc_type," was not successful.  The following error occurred!"))
    SET dfc_pos = drdc_wrap_menu_lines(dm_err->emsg,8,3,"   ",0,
     120)
    CALL text((dfc_pos+ 1),3,"Press enter to return:")
    CALL accept((dfc_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE check_error_gui(ceg_proc,ceg_menu_screen,ceg_env_name,ceg_env_id)
   DECLARE ceg_error = i4 WITH protect, noconstant(0)
   DECLARE ceg_size = i4 WITH protect, noconstant(0)
   SET ceg_error = check_error(ceg_proc)
   IF (ceg_error != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,7,132)
    CALL text(3,floor(((66 - 5) - (size(ceg_menu_screen)/ 2))),concat("***  ",ceg_menu_screen,"  ***"
      ))
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,ceg_env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(ceg_env_id))
    SET ceg_size = size(dm_err->emsg)
    CALL text(9,3,trim(substring(1,125,dm_err->emsg)))
    IF (ceg_size > 125)
     CALL text(10,3,trim(substring(126,125,dm_err->emsg)))
    ENDIF
    CALL text(12,3,"Press ENTER to continue")
    CALL accept(12,28,"P;E"," ")
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE drcm_dbase_connect(ddc_password,ddc_sid)
   DECLARE dc_retry_ans = i2 WITH protect, noconstant(0)
   DECLARE dc_db_name = vc WITH protect, noconstant(" ")
   DECLARE dc_con_db_name = vc WITH protect, noconstant(" ")
   DECLARE dc_attempt_connection = i2 WITH protect, noconstant(0)
   DECLARE dc_ind = i2 WITH protect, noconstant(0)
   DECLARE dc_db_tab = vc WITH protect, noconstant(" ")
   SET dc_ind = dm2_get_rdbms_version(null)
   IF (dc_ind=0)
    RETURN(- (1))
   ENDIF
   IF ((dm2_rdbms_version->level1 >= 12))
    SET dc_db_tab = "V$PDBS"
   ELSE
    SET dc_db_tab = "V$DATABASE"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dc_db_tab) db)
    DETAIL
     dc_db_name = db.name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Get current database name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   WHILE (dc_attempt_connection=0)
     SET dm2_install_schema->dbase_name = dc_db_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = ""
     SET dm2_install_schema->connect_str = ""
     EXECUTE dm2_connect_to_dbase "PC"
     IF ((dm_err->err_ind=1))
      IF ((dm_err->emsg="User quit process*"))
       SET retry_ans = drcm_retry_connect("Q")
       IF (retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (retry_ans=2)
        RETURN(- (1))
       ENDIF
      ELSE
       RETURN(- (1))
      ENDIF
     ELSE
      SET ddc_password = dm2_install_schema->p_word
      SET ddc_sid = dm2_install_schema->connect_str
      SELECT INTO "nl:"
       FROM (parser(dc_db_tab) db)
       DETAIL
        dc_con_db_name = db.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = "Get current database name"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      IF (dc_db_name != dc_con_db_name)
       SET retry_ans = drcm_retry_connect("D")
       IF (retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (retry_ans=2)
        RETURN(- (1))
       ENDIF
      ELSE
       SET dc_attempt_connection = 1
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drcm_retry_connect(retry_reason)
   CALL clear(1,1)
   SET width = 132
   IF (retry_reason="D")
    CALL text(11,3,
     "   Database connect information provided for WRONG database.  Movers cannot be started.")
    CALL text(13,3,concat("     Menu started in database ",dc_db_name))
    CALL text(14,3,concat("     Connect information provided for database ",dc_con_db_name))
   ELSE
    CALL text(11,3,"   Unable to make database connection")
    CALL text(12,21,"   or")
    CALL text(13,3,"   Database connect information provided is incorrect.")
   ENDIF
   CALL text(20,3,"   Would you like to retry database connection? (Y/N)")
   CALL accept(20,59,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    RETURN(1)
   ELSE
    RETURN(2)
    CALL clear(1,1)
    SET width = 132
    CALL text(11,3,"   Please EXIT out of this CCL session and start a new one")
    CALL text(20,20,"Press ENTER to continue")
    CALL accept(20,60,"P;E"," ")
    SET dm_err->eproc = "DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION."
    CALL disp_msg(dm_err->err_msg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(2)
   ENDIF
 END ;Subroutine
 SUBROUTINE drcm_check_user(null)
   DECLARE dcu_ret = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
     AND cnvtupper(p.username) IN ("SYSTEM", "SYSTEMOE", "CERNER")
    DETAIL
     dcu_ret = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(- (1))
   ENDIF
   RETURN(dcu_ret)
 END ;Subroutine
 DECLARE drrd_get_realm(null) = vc
 SUBROUTINE drrd_get_realm(null)
   DECLARE dgr_env_name = vc WITH protect, noconstant(" ")
   DECLARE dgr_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgr_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgr_domain = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Get environment name via environment logical"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (cursys="AXP")
    SET dgr_domain = "-1"
    RETURN(dgr_domain)
   ENDIF
   SET dgr_env_name = cnvtlower(trim(logical("environment")))
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
    CALL clear(1,1)
    CALL echo(concat("ENVIRONMENT LOGICAL:",dgr_env_name))
   ENDIF
   IF (trim(dgr_env_name) <= " ")
    SET dm_err->emsg = "Environment logical is not valued."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("-1")
   ENDIF
   SET dm_err->eproc = "Checking for domain name in registry"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgr_cmd = concat("$cer_exe/lreg -getp \\environment\\",dgr_env_name," Domain")
   SET dm_err->disp_dcl_err_ind = 0
   SET dgr_no_error = dm2_push_dcl(dgr_cmd)
   IF (dgr_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN("-1")
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN("-1")
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
     CALL pause(3)
    ENDIF
   ENDIF
   IF (((findstring("unable",dm_err->errtext,1,1)) OR ((((dm_err->errtext="")) OR (((findstring(
    "key not found",dm_err->errtext,1,1)) OR (findstring("property not found",dm_err->errtext,1,1)))
   )) )) )
    SET dgr_no_error = 1
    SET dgr_domain = "NOPARMRETURNED"
   ELSE
    SET dgr_domain = dm_err->errtext
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("domain_value: <<",dgr_domain,">>"))
   ENDIF
   IF (dgr_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("-1")
   ENDIF
   RETURN(cnvtupper(dgr_domain))
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
 DECLARE dbase_connect(dc_connect_info=vc(ref)) = null
 DECLARE retry_connect(retry_reason=vc,rc_orig_name=vc,rc_new_name=vc) = i2
 DECLARE gather_num_procs(gnp_header=vc) = i4
 SUBROUTINE dbase_connect(dc_connect_info)
   DECLARE dc_retry_ans = i2
   DECLARE dc_db_name = vc
   DECLARE dc_con_db_name = vc
   DECLARE dc_attempt_connection = i2 WITH protect, noconstant(0)
   DECLARE dc_ind = i2 WITH protect, noconstant(0)
   DECLARE dc_db_tab = vc WITH protect, noconstant(" ")
   SET dc_ind = dm2_get_rdbms_version(null)
   IF (dc_ind=0)
    RETURN(null)
   ENDIF
   IF ((dm2_rdbms_version->level1 >= 12))
    SET dc_db_tab = "V$PDBS"
   ELSE
    SET dc_db_tab = "V$DATABASE"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dc_db_tab) db)
    DETAIL
     dc_db_name = db.name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Get current database name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   WHILE (dc_attempt_connection=0)
     SET dm2_install_schema->dbase_name = dc_db_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = ""
     SET dm2_install_schema->connect_str = ""
     EXECUTE dm2_connect_to_dbase "PC"
     IF ((dm_err->err_ind=1))
      IF ((dm_err->emsg="User quit process*"))
       SET dc_retry_ans = retry_connect("Q",dc_db_name,"")
       IF (dc_retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (dc_retry_ans=2)
        RETURN(null)
       ENDIF
      ELSE
       RETURN(null)
      ENDIF
     ELSE
      SET dc_connect_info->db_password = dm2_install_schema->p_word
      SET dc_connect_info->db_sid = dm2_install_schema->connect_str
      SELECT INTO "nl:"
       FROM (parser(dc_db_tab) db)
       DETAIL
        dc_con_db_name = db.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = "Get current database name"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(null)
      ENDIF
      IF (dc_db_name != dc_con_db_name)
       SET dc_retry_ans = retry_connect("D",dc_db_name,dc_con_db_name)
       IF (dc_retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (dc_retry_ans=2)
        RETURN(null)
       ENDIF
      ELSE
       SET dc_attempt_connection = 1
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE retry_connect(retry_reason,rc_orig_name,rc_new_name)
   CALL clear(1,1)
   SET width = 132
   IF (retry_reason="D")
    CALL text(11,3,
     "   Database connect information provided for WRONG database.  Movers cannot be started.")
    CALL text(13,3,concat("     Menu started in database ",rc_orig_name))
    CALL text(14,3,concat("     Connect information provided for database ",rc_new_name))
   ELSE
    CALL text(11,3,"   Unable to make database connection")
    CALL text(12,21,"   or")
    CALL text(13,3,
     "   Database connect information provided is incorrect.  Movers cannot be started.")
   ENDIF
   CALL text(20,3,"   Would you like to retry database connection? (Y/N)")
   CALL accept(20,59,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    RETURN(1)
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL text(11,3,"   Please EXIT out of this CCL session and start a new one")
    CALL text(20,20,"Press ENTER to continue")
    CALL accept(20,60,"P;E"," ")
    SET dm_err->eproc = "DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION."
    CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(2)
   ENDIF
 END ;Subroutine
 SUBROUTINE gather_num_procs(gnp_header)
   DECLARE gnp_ret_num = i4 WITH protect, noconstant(0)
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,floor((66 - (size(gnp_header)/ 2))),gnp_header)
   CALL text(7,3,
    "How many processes do you want to start (This is in addition to any processes which may already be running): "
    )
   CALL text(8,3,"Input 0 to start no processes and exit.")
   CALL accept(7,112,"999",0)
   SET gnp_ret_num = curaccept
   RETURN(gnp_ret_num)
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
 DECLARE dmda_con = i2 WITH protect, noconstant(0)
 DECLARE reltn_type = vc WITH protect, constant("REFERENCE MERGE")
 DECLARE logfile_name = vc WITH protect
 DECLARE re_dtrig = c1 WITH protect
 DECLARE return_val = c1 WITH protect
 DECLARE srm_env_id = f8 WITH noconstant(0.0)
 DECLARE srm_env_name = vc
 DECLARE no_log_ind = c1
 DECLARE no_log_apc_ind = c1
 DECLARE cutover_flag = i2
 DECLARE meta_data_trigger_refresh_global_ind = i2
 DECLARE no_confirm = i2 WITH protect, noconstant(0)
 DECLARE nohup_submit_logfile = vc WITH protect
 DECLARE tgt_env_id = f8 WITH noconstant(0.0)
 DECLARE tgt_env_name = vc WITH noconstant("")
 DECLARE dmda_check_status = i2 WITH protect, noconstant(0)
 DECLARE dmda_cd_ret = vc WITH protect, noconstant(" ")
 DECLARE dmda_dm_pkg_vers = vc WITH protect, noconstant("DOMAIN MANAGEMENT")
 DECLARE manage_merge_domain(null) = null
 DECLARE merge_domain_view(null) = null
 DECLARE merge_domain_add(null) = null
 DECLARE merge_domain_delete(null) = null
 DECLARE add_triggers(i_regen_type_ind=i2) = null
 DECLARE autoadd_triggers(i_regen_type_ind=i2) = null
 DECLARE confirm_display(domain_name=vc,trg_flag=i2) = c1
 DECLARE chg_log_src(null) = null
 DECLARE chg_log_tgt(null) = null
 DECLARE chg_log_rpt(null) = null
 DECLARE dmda_manage_change_log_triggers(null) = null
 DECLARE source_environment_change(null) = null
 DECLARE get_src_env_id(sub_title=vc,sub_confirm_ind=i2) = null
 DECLARE manage_rdds_context(add_only_ind=i2,orig_cntxt=vc) = i2
 DECLARE auto_planned_cutover(null) = c1
 DECLARE modify_environment_config(null) = null
 DECLARE cutover_configure_movers(null) = null
 DECLARE target_reactivation(null) = null
 DECLARE mover_batch_size(null) = null
 DECLARE set_log_level(null) = null
 DECLARE cutover_configuration(null) = null
 DECLARE start_cutover(null) = null
 DECLARE view_cutover_movers(null) = null
 DECLARE view_cutover_warnings(null) = null
 DECLARE get_cutover_status_reports(i_detail=i2,i_source_env_id=f8,v_tabs=vc(ref)) = null
 DECLARE view_free_space(null) = null
 DECLARE view_cutover_contexts(vcc_cbc_ind=i2) = null
 DECLARE manage_context_to_set(i_context_to_pull=vc) = i2
 DECLARE dmda_manage_rdds_event(null) = null
 DECLARE dmda_open_rdds_event(ore_src_env_id=f8) = i2
 DECLARE dmda_close_rdds_event(null) = null
 DECLARE dmda_start_rdds_movers(dsrm_refresh_trig_ind=i2) = null
 DECLARE dmda_drop_old_r(null) = null
 DECLARE dmda_setup_and_monitor(null) = null
 DECLARE dmda_monitor_tools(null) = null
 DECLARE dmda_ref_data_audit(null) = null
 DECLARE dmda_ref_data_audit_setup(null) = null
 DECLARE dmda_ref_data_audit_run(null) = null
 DECLARE ptam_confirm(pc_target_env_id=f8) = c1
 DECLARE ptam_setup(ps_target_env_id=f8) = null
 DECLARE auto_planned_cut_modify(apcm_target_env_id=f8) = null
 DECLARE chg_log_vers(null) = null
 DECLARE modify_unmapped_setting(null) = null
 DECLARE dmda_disp_backfill_msgs(dbm_sc_explode=i2,dbm_ptam_check=i2,dbm_dcl_check=i2,dbm_srm_check=
  i2,dbm_mov_check=i2,
  dbm_pkw_check=i2,dbm_mov_check=i2,dbm_src_sc_explode=i2) = i2
 DECLARE dmda_pkw_prompt(pp_mov_check=i2) = i2
 DECLARE connect_info_display(null) = c1
 DECLARE mc_confirm_screen(process=vc,num=i4) = null
 DECLARE get_tgt_env_id(sub_title=vc,sub_confirm_ind=i2) = null
 DECLARE dmda_content_context_rpt(null) = null
 DECLARE dmda_reset_chld_xcptns(null) = i2
 DECLARE dmda_move_chld_exceptions(null) = null
 DECLARE dm_chld_xcptn_rpt(null) = null
 DECLARE dmda_ptam_dual_bld_trg_setting(dpds_tgt_env_name=vc,dpds_target_env_id=f8,dpds_cutover_type=
  vc,dpds_ptam_answer=c1) = i2
 DECLARE dm_close_event_chk(i_tgt_name=vc,i_tgt_id=f8,i_open_evt_id=f8) = i2
 DECLARE dmda_dual_build_config(null) = i4
 DECLARE dmda_db_trig_ack(ddta_info_dt_tm=dq8,ddta_file_name=vc) = i4
 DECLARE dmda_db_trig_config(ddtc_src_env_id=f8) = i4
 DECLARE dmda_manage_post_domain_copy(null) = null
 DECLARE dmda_start_xlat_backfill(null) = null
 DECLARE dmda_get_xlat_backfill_info(gxb_info=vc(ref)) = null
 DECLARE dmda_view_xlat_backfill(null) = null
 DECLARE dmda_open_evt_rpt(null) = null
 DECLARE dmda_get_num_bbproc(null) = i4
 DECLARE start_ref_mover(null) = null
 DECLARE dmda_val_post_domain_copy(null) = null
 DECLARE dmda_configure_rdds_settings(null) = null
 DECLARE dmda_config_cutover(i_source_env_id=f8) = i2
 DECLARE dmda_config_dual_build(i_source_env_id=f8,i_ptam_cfg=i2) = i2
 DECLARE dmda_config_ptam(i_source_env_id=f8,i_dual_build_cfg=i2) = i2
 DECLARE dmda_repref_trig_confirm(i_child_env_id=f8,i_child_env_name=vc) = c1
 DECLARE add_trigger_tasks(null) = null
 DECLARE dmda_mvr_mons(null) = i2
 DECLARE dmda_draw_event_box(ddeb_row_pos=i4,ddeb_col_pos=i4,ddeb_status_ind=i2,ddeb_event_rs=vc(ref)
  ) = null
 DECLARE mover_reset_time(null) = null
 DECLARE cancel_sched_ac(null) = null
 DECLARE cancel_sched_dml(null) = null
 DECLARE dmda_get_default_context(dgdc_ctxt_to_pull=vc) = vc
 DECLARE dmda_check_mig_settings(dcms_ack_ind=i2,dcms_oe_name=vc,dcms_proc_name=vc) = i2
 IF (validate(trg_regen_reason,"X")="X")
  DECLARE trg_regen_reason = vc
  SET trg_regen_reason = "Manual regeneration via menu"
 ENDIF
 IF (validate(dm_get_seq_val,"X")="X")
  DECLARE dm_get_seq_val = vc
  SET dm_get_seq_val = "Automatic match via menu"
 ENDIF
 FREE RECORD dmda_mr
 RECORD dmda_mr(
   1 env_id = f8
   1 env_name = vc
 )
 FREE RECORD r_table
 RECORD r_table(
   1 tabs[*]
     2 tab_name = vc
     2 ccl_def_ind = i2
     2 env_list = vc
   1 tabs_cnt = i4
   1 envs[*]
     2 parent_env_id = f8
     2 uncutover_rows_ind = i2
     2 valid_env_ind = i2
   1 envs_cnt = i4
   1 r_cleanup[*]
     2 message = vc
   1 cleanup_cnt = i4
 )
 FREE RECORD drop_request
 RECORD drop_request(
   1 drop_after_day = i4
 )
 FREE RECORD dcl_request
 RECORD dcl_request(
   1 target_id = f8
   1 log_id = f8
 )
 RECORD dcl_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
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
 FREE RECORD dcxr_request
 RECORD dcxr_request(
   1 qual[*]
     2 context_name = vc
     2 log_id = f8
     2 table_name = vc
     2 log_type = vc
     2 pk_where = vc
     2 updt_dt_tm = vc
     2 updt_task = i4
     2 updt_id = f8
     2 exception_id = f8
 )
 RECORD ddbc_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD doer_request
 RECORD doer_request(
   1 target_env_id = f8
   1 open_event_id = f8
   1 xml_file_name = vc
 ) WITH protect
 FREE RECORD doer_reply
 RECORD doer_reply(
   1 status = vc
   1 error_msg = vc
 ) WITH protect
 FREE RECORD dmda_drbb_request
 RECORD dmda_drbb_request(
   1 dgnb_com_batch = vc
   1 db_password = vc
   1 db_sid = vc
   1 cur_env_name = vc
   1 dmoe_num_proc = i4
   1 src_env_name = vc
   1 cbc_ind = i2
 )
 FREE RECORD dmda_event_info
 RECORD dmda_event_info(
   1 event_status = vc
   1 event_name = vc
   1 event_date = f8
   1 event_src_id = f8
   1 event_src_name = vc
   1 open_event_flg = i4
 )
 FREE RECORD dlir_types
 RECORD dlir_types(
   1 cnt = i4
   1 qual[*]
     2 type = vc
     2 cnt = i4
 )
 FREE RECORD dmda_connect_info
 RECORD dmda_connect_info(
   1 db_password = vc
   1 db_sid = vc
 )
 SET message = window
 SET meta_data_trigger_refresh_global_ind = 0
 SET meta_data_trigger_refresh_global_ind = 0
 CALL check_logfile("dm_merge_domain_adm",".log","DM_MERGE_DOMAIN_ADM LOGFILE")
 SET dm_err->eproc = "Beginning dm_merge_domain_adm"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET logfile_name = dm_err->logfile
 SET cutover_flag = 1
 SELECT INTO "nl:"
  FROM dm_info a,
   dm_environment b
  PLAN (a
   WHERE a.info_name="DM_ENV_ID"
    AND a.info_domain="DATA MANAGEMENT")
   JOIN (b
   WHERE a.info_number=b.environment_id)
  DETAIL
   dmda_mr->env_id = b.environment_id, dmda_mr->env_name = b.environment_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dm_err->eproc = "Fatal Error: current environment id not found"
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Gathering Domain Management release installed"
 SELECT INTO "NL:"
  FROM dm_ocd_log dol
  WHERE (dol.environment_id=dmda_mr->env_id)
   AND dol.project_type="README"
   AND dol.project_name="4102"
   AND dol.status="SUCCESS"
   AND dol.message="DOMAIN MANAGEMENT*"
   AND dol.project_instance IN (
  (SELECT
   max(dl.project_instance)
   FROM dm_ocd_log dl
   WHERE dl.environment_id=dol.environment_id
    AND dl.project_type=dol.project_type
    AND dl.project_name=dol.project_name
    AND dl.status=dol.status))
  DETAIL
   dmda_dm_pkg_vers = substring(1,(findstring("Successfully",dol.message,1,1) - 1),dol.message)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
  ROLLBACK
 ENDIF
 WHILE (dmda_con=0)
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL dmda_draw_event_box(8,75,0,dmda_event_info)
   CALL box(1,1,5,132)
   CALL text(3,43,concat("***  MERGE ",dmda_dm_pkg_vers," ***"))
   CALL text(4,75,"ENVIRONMENT ID:")
   CALL text(4,20,"ENVIRONMENT NAME:")
   CALL text(4,95,cnvtstring(dmda_mr->env_id))
   CALL text(4,40,dmda_mr->env_name)
   CALL text(7,3,"Please choose from the following options:")
   CALL text(9,3,"1 Manage environment relationship")
   CALL text(10,3,"2 Manage change log triggers")
   CALL text(11,3,"3 Change log summary reports")
   CALL text(12,3,"4 Manage data movers")
   CALL text(13,3,"5 Manage RDDS Post Domain Copy")
   IF (cutover_flag=1)
    CALL text(14,3,"6 Manage Cutover")
   ENDIF
   CALL text(15,3,"7 Manage RDDS Events")
   CALL text(16,3,"8 RDDS Status and Monitoring Tools")
   CALL text(17,3,"9 Manage User-Context Mappings")
   CALL text(18,3,"0 Exit")
   CALL accept(7,50,"99",0
    WHERE curaccept IN (1, 2, 3, 4, 5,
    6, 7, 8, 9, 0))
   CASE (curaccept)
    OF 1:
     CALL manage_merge_domain(null)
    OF 2:
     SET dmda_cd_ret = confirm_display("SOURCE",0)
     IF (dmda_cd_ret="Y")
      CALL dmda_manage_change_log_triggers(null)
     ENDIF
    OF 3:
     CALL chg_log_rpt(null)
    OF 4:
     CALL mover_management(null)
    OF 5:
     CALL dmda_manage_post_domain_copy(null)
    OF 6:
     IF (cutover_flag=0)
      CALL text(20,3,"This option is not available at this time.")
      CALL pause(3)
     ELSE
      CALL cutover_configuration(null)
     ENDIF
    OF 7:
     CALL dmda_manage_rdds_event(null)
    OF 8:
     CALL dmda_setup_and_monitor(null)
    OF 9:
     SET dmda_cd_ret = confirm_display("SOURCE",0)
     IF (dmda_cd_ret="Y")
      EXECUTE dm_context_merge_adm
      IF ((dm_err->err_ind=1))
       GO TO exit_program
      ENDIF
     ENDIF
    OF 0:
     SET dmda_con = 1
   ENDCASE
 ENDWHILE
 SUBROUTINE dmda_manage_change_log_triggers(null)
   DECLARE chg_log_con = i2 WITH protect, noconstant(0)
   SET chg_log_con = 0
   WHILE (chg_log_con=0)
     CALL dm2_rdds_init_display(null)
     CALL box(1,1,5,132)
     CALL text(3,30,"***  CHANGE LOG TRIGGER AND USER-CONTEXT MAPPING MANAGEMENT  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,"Please choose from the following options:")
     CALL text(9,3,"1 Add/refresh change log triggers")
     CALL text(10,3,"2 View change log trigger history")
     CALL text(11,3,"3 Allow/disallow unmapped users to make changes")
     CALL text(12,3,"4 Manage User-Context Mappings")
     CALL text(13,3,"5 View Trigger Creation Progress")
     CALL text(17,3,"0 Exit")
     CALL dmda_draw_event_box(8,75,0,dmda_event_info)
     CALL accept(7,50,"99",0
      WHERE curaccept IN (1, 2, 3, 4, 5,
      0))
     CASE (curaccept)
      OF 1:
       CALL add_triggers(null)
      OF 2:
       EXECUTE dm2_hist_chg_log_triggers
       IF ((dm_err->err_ind=1))
        GO TO exit_program
       ENDIF
      OF 3:
       IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
        IF ((xxcclseclogin->loggedin != 1))
         CALL text(20,3,
          "In order to perform this action, you are required to be logged in securely to the Millennium database"
          )
         CALL text(21,3,"Press Enter to continue to login prompt.")
         CALL accept(21,45,"P;E"," ")
        ENDIF
       ENDIF
       CALL modify_unmapped_setting(null)
      OF 4:
       EXECUTE dm_context_merge_adm
       IF ((dm_err->err_ind=1))
        GO TO exit_program
       ENDIF
      OF 5:
       CALL drtq_view_task_process("REFRESH TRIGGER PROCESS")
      OF 0:
       SET chg_log_con = 1
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE manage_merge_domain(null)
   DECLARE ora_continue = i2 WITH protect, noconstant(0)
   DECLARE re_man_val = c1 WITH protect
   DECLARE dmda_trigger_flag = i2 WITH protect, noconstant(0)
   DECLARE dmda_trg_exist = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    dt.trigger_name
    FROM dm2_user_triggers dt
    WHERE dt.trigger_name IN ("REFCHG????ADD", "REFCHG????UPD", "REFCHG????DEL")
    WITH maxqual(dt,1), nocounter
   ;end select
   IF (curqual > 0)
    SET dmda_trg_exist = 1
   ENDIF
   WHILE (ora_continue=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Manage Environment Relationship ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,3,"Choose from the following options: ")
     CALL text(11,3,"1 Add child domain relation")
     CALL text(12,3,"2 Remove child domain relation")
     CALL text(13,3,"3 View domain relationships")
     CALL text(14,3,"4 Source environment change event")
     CALL text(15,3,"5 Modify environment configuration")
     IF (dmda_trigger_flag=1
      AND dmda_trg_exist=1)
      CALL text(19,3,"NOTE: Domain relationship was changed!")
      CALL text(20,3,"Change log triggers will be recreated when you return to main menu (Press 0)")
     ELSE
      CALL text(18,3,"0 Exit")
     ENDIF
     CALL dmda_draw_event_box(10,75,0,dmda_event_info)
     CALL accept(9,45,"9",0
      WHERE curaccept IN (1, 2, 3, 4, 5,
      0))
     CASE (curaccept)
      OF 1:
       CALL merge_domain_add(null)
      OF 2:
       CALL merge_domain_delete(null)
      OF 3:
       CALL merge_domain_view(null)
      OF 4:
       CALL source_environment_change(null)
      OF 5:
       CALL modify_environment_config(null)
      OF 0:
       SET ora_continue = 1
       IF (dmda_trigger_flag=1)
        CALL autoadd_triggers(dmda_trg_exist)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE merge_domain_view(null)
   DECLARE child_env_size = i4 WITH protect, noconstant(0)
   DECLARE env_total_cnt = i4 WITH protect
   DECLARE mdv_ptam_return = i2 WITH protect, noconstant(0)
   SET derg_request->env_id = dmda_mr->env_id
   SET derg_request->relationship_type = reltn_type
   EXECUTE dm_get_env_reltn
   IF ((derg_reply->err_num > 0))
    CALL text(12,3,derg_reply->err_msg)
    CALL text(13,3,"ERROR: can't get information for dm_env_reltn!")
    CALL disp_msg(derg_reply->err_msg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    GO TO exit_program
   ELSE
    SET env_total_cnt = size(derg_reply->child_env_list,5)
    FREE RECORD ptam_rec
    RECORD ptam_rec(
      1 qual[*]
        2 ptam_check = vc
    )
    IF (size(derg_reply->child_env_list,5) > 0)
     SET child_env_size = size(derg_reply->child_env_list,5)
    ELSE
     SET child_env_size = 1
    ENDIF
    SET stat = alterlist(ptam_rec->qual,env_total_cnt)
    FOR (env_cnt = 1 TO env_total_cnt)
     SET mdv_ptam_return = drcr_get_ptam_config(dmda_mr->env_id,derg_reply->child_env_list[env_cnt].
      env_id)
     IF (mdv_ptam_return=1)
      SET ptam_rec->qual[env_cnt].ptam_check = "Yes"
     ELSEIF (mdv_ptam_return=0)
      SET ptam_rec->qual[env_cnt].ptam_check = "No"
     ELSE
      SET ptam_rec->qual[env_cnt].ptam_check = "Not Configured"
     ENDIF
    ENDFOR
    SELECT INTO mine
     FROM (dummyt d  WITH seq = child_env_size)
     HEAD REPORT
      col 0, "View Target Environments for Current Environment(", col + 1,
      dmda_mr->env_name, col + 1, dmda_mr->env_id,
      col + 1, ")"
     HEAD PAGE
      row + 2, col 1, "TARGET ENVIRONMENT NAME",
      col 30, "TARGET ENVIRONMENT ID", col 60,
      "DATABASE LINK", col 80, "PENDING TARGET AS MASTER",
      row + 1
     DETAIL
      row + 1, col 1, derg_reply->child_env_list[d.seq].env_name,
      col 30, derg_reply->child_env_list[d.seq].env_id
      IF (currdb="ORACLE")
       IF (daf_is_not_blank(derg_reply->child_env_list[d.seq].post_link_name))
        col 60, "Yes"
       ELSE
        col 60, "No"
       ENDIF
      ELSEIF (currdb="DB2UDB")
       IF (daf_is_not_blank(derg_reply->child_env_list[d.seq].pre_link_name))
        col 60, "Yes"
       ELSE
        col 60, "No"
       ENDIF
      ENDIF
      col 80, ptam_rec->qual[d.seq].ptam_check
     WITH nocounter
    ;end select
   ENDIF
   SET stat = alterlist(derg_reply->parent_env_list,0)
   SET stat = alterlist(derg_reply->child_env_list,0)
 END ;Subroutine
 SUBROUTINE merge_domain_add(null)
   DECLARE dmda_link = vc WITH protect
   DECLARE sbr_drop = vc WITH protect
   DECLARE dmda_confirm = vc WITH protect
   DECLARE pass_val = i4 WITH protect, noconstant(0)
   DECLARE add_emsg = vc WITH protect
   DECLARE re_add_val = c1 WITH protect
   DECLARE dera_valid_env_ind = c1 WITH protect
   DECLARE dera_rel_type = vc WITH protect, noconstant(" ")
   DECLARE mda_trig_ret = c1 WITH protect, noconstant(" ")
   FREE RECORD dmda_add
   RECORD dmda_add(
     1 passwd = vc
     1 link = vc
     1 dmda_link = vc
     1 parent_env_id = f8
     1 parent_env_name = vc
     1 user_name = vc
     1 child_env_id = f8
     1 child_env_name = vc
   )
   IF (dmda_trg_exist=1)
    SET re_add_val = confirm_display("SOURCE",1)
   ELSE
    SET re_add_val = confirm_display("SOURCE",0)
   ENDIF
   IF (re_add_val="N")
    RETURN
   ENDIF
   SET pass_val = dmda_user_input(null)
   IF (pass_val=1)
    SET stat = alterlist(dera_request->env_list,1)
    SET dera_request->child_env_id = dmda_add->child_env_id
    SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
    SET dera_request->env_list[1].child_env_id = dmda_add->child_env_id
    SET dera_request->env_list[1].relationship_type = reltn_type
    EXECUTE dm_add_env_reltn
    SET stat = alterlist(dera_request->env_list,0)
    SET dera_request->child_env_id = 0
    IF ((dera_reply->err_num > 0))
     CALL text(12,3,dera_reply->err_msg)
     CALL text(13,3,"Insertion failed! Action aborted..")
     CALL pause(2)
     CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ELSE
     CALL text(12,3,"Is this the correct environment id? (Y, N)")
     CALL accept(12,75,"P;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (cnvtupper(curaccept)="N")
      SET stat = alterlist(derd_request->env_list,1)
      SET derd_request->child_env_id = dmda_add->child_env_id
      SET derd_request->env_list[1].child_env_id = dmda_add->child_env_id
      SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
      SET derd_request->env_list[1].relationship_type = reltn_type
      EXECUTE dm_del_env_reltn
      IF ((derd_reply->err_num > 0))
       CALL text(12,3,derd_reply->err_msg)
       CALL text(13,3,"Deletion failed! Action abort...")
       CALL disp_msg(derd_reply->err_msg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       GO TO exit_program
      ENDIF
      SET stat = alterlist(derd_request->env_list,0)
      SET derd_request->child_env_id = 0
     ELSE
      CALL clear(16,1)
      CALL text(16,3,"The relationship was added for this target domain:  ")
      CALL text(16,55,cnvtstring(dmda_add->child_env_id))
      SELECT INTO "nl:"
       FROM dm_environment de
       WHERE (de.environment_id=dmda_add->child_env_id)
       DETAIL
        dmda_add->child_env_name = de.environment_name
       WITH nocounter
      ;end select
      CALL text(16,65,dmda_add->child_env_name)
      CALL text(18,3,"Press Enter to continue:")
      CALL accept(18,40,"P;E"," ")
      SET mda_trig_ret = dmda_repref_trig_confirm(dmda_add->child_env_id,dmda_add->child_env_name)
      IF (mda_trig_ret="N")
       CALL no_log_confirm(null)
       IF (no_log_apc_ind="Y")
        IF (no_log_ind="Y")
         CALL ins_no_log_row(null)
         SET dera_valid_env_ind = ptam_confirm(dmda_add->child_env_id)
        ENDIF
       ELSE
        SET dera_valid_env_ind = "N"
        SET stat = alterlist(derd_request->env_list,1)
        SET derd_request->child_env_id = dmda_add->child_env_id
        SET derd_request->env_list[1].child_env_id = dmda_add->child_env_id
        SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
        SET derd_request->env_list[1].relationship_type = reltn_type
        EXECUTE dm_del_env_reltn
        SET stat = alterlist(derd_request->env_list,1)
        SET derd_request->child_env_id = dmda_add->child_env_id
        SET derd_request->env_list[1].child_env_id = dmda_add->child_env_id
        SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
        SET derd_request->env_list[1].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
        EXECUTE dm_del_env_reltn
       ENDIF
       IF (dera_valid_env_ind="Y")
        SET dmda_trigger_flag = 1
        DELETE  FROM dm_info di
         WHERE di.info_domain="RDDS CONFIGURATION"
          AND di.info_name=concat("RELTN_ACTIVE:",trim(cnvtstring(dmda_add->child_env_id,20)))
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ELSE
         COMMIT
        ENDIF
       ELSE
        SET dmda_trigger_flag = 0
        IF (no_log_apc_ind="Y")
         SET stat = alterlist(derd_request->env_list,1)
         SET derd_request->child_env_id = dmda_add->child_env_id
         SET derd_request->env_list[1].child_env_id = dmda_add->child_env_id
         SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
         SET derd_request->env_list[1].relationship_type = reltn_type
         EXECUTE dm_del_env_reltn
         SET stat = alterlist(derd_request->env_list,0)
         SET stat = alterlist(derd_request->env_list,1)
         SET derd_request->child_env_id = dmda_add->child_env_id
         SET derd_request->env_list[1].child_env_id = dmda_add->child_env_id
         SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
         SET derd_request->env_list[1].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
         EXECUTE dm_del_env_reltn
         SELECT INTO "NL:"
          der.relationship_type
          FROM dm_env_reltn der
          WHERE (parent_env_id=dmda_mr->env_id)
           AND (der.child_env_id=dmda_add->child_env_id)
           AND der.relationship_type IN ("AUTO CUTOVER", "PLANNED CUTOVER")
          DETAIL
           dera_rel_type = der.relationship_type
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc) != 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ROLLBACK
         ENDIF
         IF (curqual > 0)
          IF (dera_rel_type="AUTO CUTOVER")
           SET derd_request->child_env_id = dmda_add->child_env_id
           SET derd_request->env_list[1].child_env_id = dmda_add->child_env_id
           SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
           SET derd_request->env_list[1].relationship_type = "AUTO CUTOVER"
           EXECUTE dm_del_env_reltn
          ELSE
           SET derd_request->child_env_id = dmda_add->child_env_id
           SET derd_request->env_list[1].child_env_id = dmda_add->child_env_id
           SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
           SET derd_request->env_list[1].relationship_type = "PLANNED CUTOVER"
           EXECUTE dm_del_env_reltn
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_repref_trig_confirm(i_child_env_id,i_child_env_name)
   DECLARE drtc_return = c1 WITH protect, noconstant("")
   DECLARE drtc_trg_exist = i2 WITH protect, noconstant(0)
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Replicate/Refresh Trigger Regeneration Confirmation ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(8,3,concat("Is this new child environment, ",trim(i_child_env_name)," (",trim(cnvtstring
      (i_child_env_id)),"), about to be created as part of a replicate or refresh? (Y/N)"))
   CALL accept(11,90,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   SET drtc_return = curaccept
   IF (drtc_return="Y")
    SELECT INTO "nl:"
     dt.trigger_name
     FROM dm2_user_triggers dt
     WHERE dt.trigger_name IN ("REFCHG????ADD", "REFCHG????UPD", "REFCHG????DEL")
     WITH maxqual(dt,1), nocounter
    ;end select
    SET drtc_trg_exist = curqual
    SET dmda_trigger_flag = 1
    CALL autoadd_triggers(drtc_trg_exist)
    SET dmda_trigger_flag = 0
   ENDIF
   RETURN(drtc_return)
 END ;Subroutine
 SUBROUTINE ins_no_log_row(null)
   SET stat = alterlist(dera_request->env_list,1)
   SET dera_request->child_env_id = dmda_add->child_env_id
   SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
   SET dera_request->env_list[1].child_env_id = dmda_add->child_env_id
   SET dera_request->env_list[1].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
   EXECUTE dm_add_env_reltn
   SET stat = alterlist(dera_request->env_list,0)
   SET dera_request->child_env_id = 0
   IF ((dera_reply->err_num > 0))
    CALL text(12,3,dera_reply->err_msg)
    CALL text(13,3,"Insertion failed! Action aborted..")
    CALL pause(2)
    SET dm_err->eproc = "Inserting 'RDDS MOVER CHANGES NOT LOGGED' to DM_ENV_RELTN"
    CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    GO TO exit_program
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Full Circle Relation Setup"
   SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
   SET auto_ver_request->qual[1].paired_environment_id = dmda_add->child_env_id
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    SET dm_err->eproc = auto_ver_reply->status_msg
    SET dm_err->err_ind = 1
    CALL disp_msg(auto_ver_reply->status_msg,dm_err->logfile,1)
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ELSE
    COMMIT
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_user_input(null)
   DECLARE ret_val = i2 WITH protect, noconstant(1)
   DECLARE dmda_size = i4 WITH protect, noconstant(0)
   DECLARE dmda_posuser = i4 WITH protect, noconstant(0)
   DECLARE dmda_pospsw = i4 WITH protect, noconstant(0)
   DECLARE dmda_poslink = i4 WITH protect, noconstant(0)
   DECLARE dmda_holder = vc WITH protect
   DECLARE insert_validate = i2 WITH protect, noconstant(0)
   DECLARE insert_con = i2 WITH protect, noconstant(0)
   CALL clear(1,1)
   CALL text(3,40,"*** Add Target Environment ***")
   CALL text(5,3,"Please input target environment id(0 to exit): ")
   WHILE (insert_validate=0)
     CALL clear(20,1)
     CALL text(23,05,"HELP: Press <SHIFT><F5>     ")
     SET help =
     SELECT INTO "nl:"
      de.environment_id, de.environment_name
      FROM dm_environment de
      WHERE  NOT (de.environment_id IN (
      (SELECT
       der.child_env_id
       FROM dm_env_reltn der
       WHERE (parent_env_id=dmda_mr->env_id)
        AND relationship_type=reltn_type)))
       AND (( NOT (de.environment_id IN (
      (SELECT
       d.parent_env_id
       FROM dm_env_reltn d
       WHERE (child_env_id=dmda_mr->env_id)
        AND relationship_type=reltn_type)))) OR (de.environment_id IN (
      (SELECT
       d.parent_env_id
       FROM dm_env_reltn d
       WHERE (child_env_id=dmda_mr->env_id)
        AND relationship_type="RDDS MOVER CHANGES NOT LOGGED"))))
       AND (de.environment_id != dmda_mr->env_id)
      ORDER BY de.environment_id
     ;end select
     CALL accept(5,70,"P(15);CU","0")
     IF (curaccept="0")
      SET insert_validate = 1
      SET insert_con = 1
      SET ret_val = 0
     ELSEIF (cnvtreal(curaccept)=0)
      CALL text(20,3,"Please input number for this field!")
      CALL pause(3)
     ELSE
      SELECT INTO "nl:"
       FROM dm_environment de
       WHERE  NOT (de.environment_id IN (
       (SELECT
        der.child_env_id
        FROM dm_env_reltn der
        WHERE (parent_env_id=dmda_mr->env_id)
         AND relationship_type=reltn_type)))
        AND (( NOT (de.environment_id IN (
       (SELECT
        d.parent_env_id
        FROM dm_env_reltn d
        WHERE (child_env_id=dmda_mr->env_id)
         AND relationship_type=reltn_type)))) OR (de.environment_id IN (
       (SELECT
        d.parent_env_id
        FROM dm_env_reltn d
        WHERE (child_env_id=dmda_mr->env_id)
         AND relationship_type="RDDS MOVER CHANGES NOT LOGGED"))))
        AND (de.environment_id != dmda_mr->env_id)
        AND de.environment_id=cnvtreal(curaccept)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET insert_validate = 1
      ELSE
       CALL clear(20,1)
       CALL text(20,3,"Invalid environment ID")
       CALL pause(3)
      ENDIF
     ENDIF
   ENDWHILE
   CALL clear(20,1)
   IF (insert_con=0)
    SET dmda_add->child_env_id = cnvtreal(curaccept)
    SET help = off
   ENDIF
   RETURN(ret_val)
 END ;Subroutine
 SUBROUTINE no_log_confirm(null)
   SELECT INTO "nl:"
    FROM dm_env_reltn d
    WHERE (d.child_env_id=dmda_mr->env_id)
     AND (d.parent_env_id=dmda_add->child_env_id)
     AND d.relationship_type=reltn_type
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,7,132)
    CALL text(3,40,"***  No Logging Confirmation ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(8,3,concat("Is this a Full Circle RDDS relationship? (Y/N)"))
    CALL accept(11,90,"P;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    SET no_log_ind = curaccept
   ELSE
    SET no_log_ind = "Y"
   ENDIF
   IF (cutover_flag=1)
    SET no_log_apc_ind = auto_planned_cutover(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE merge_domain_delete(null)
   DECLARE del_env_id = f8 WITH protect, noconstant(0)
   DECLARE display_msg = vc WITH protect
   DECLARE sbr_drop_del = vc WITH protect
   DECLARE del_env_name = vc WITH protect
   DECLARE del_con = i2 WITH protect, noconstant(0)
   DECLARE del_validate = i2 WITH protect, noconstant(0)
   DECLARE del_rel_type = vc WITH protect, noconstant(" ")
   DECLARE mdd_temp_return = i2 WITH protect, noconstant(0)
   IF (dmda_trg_exist=1)
    SET re_add_val = confirm_display("SOURCE",1)
   ELSE
    SET re_add_val = confirm_display("SOURCE",0)
   ENDIF
   IF (re_add_val="N")
    RETURN
   ENDIF
   CALL clear(1,1)
   CALL text(3,35,"***  Delete Target Environment   ***")
   CALL text(5,3,"Please input target environment id: ")
   WHILE (del_validate=0)
     CALL clear(20,01,74)
     CALL text(23,05,"HELP: Press <SHIFT><F5>  0 to exit")
     SET help =
     SELECT INTO "nl:"
      d.child_env_id, de.environment_name
      FROM dm_env_reltn d,
       dm_environment de,
       dummyt dt
      PLAN (d
       WHERE (d.parent_env_id=dmda_mr->env_id)
        AND d.relationship_type=reltn_type)
       JOIN (dt)
       JOIN (de
       WHERE de.environment_id=d.child_env_id)
      ORDER BY d.child_env_id
      WITH nocounter, outerjoin = dt
     ;end select
     CALL accept(5,70,"P(15);CU","0")
     IF (curaccept="0")
      SET del_validate = 1
      SET del_con = 1
     ELSEIF (cnvtreal(curaccept)=0)
      CALL text(20,3,"Please input number for this field!")
      CALL pause(3)
     ELSE
      SELECT INTO "nl:"
       d.child_env_id
       FROM dm_env_reltn d
       WHERE (d.parent_env_id=dmda_mr->env_id)
        AND d.relationship_type=reltn_type
        AND d.child_env_id=cnvtreal(curaccept)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET del_validate = 1
      ELSE
       CALL clear(20,1)
       CALL text(20,3,"Invalid environment ID")
       CALL pause(3)
      ENDIF
     ENDIF
   ENDWHILE
   IF (del_con=0)
    SET del_env_id = cnvtreal(curaccept)
    SET help = off
    CALL clear(23,05,74)
    SELECT INTO "nl:"
     FROM dm_environment de
     WHERE de.environment_id=del_env_id
     DETAIL
      del_env_name = de.environment_name
     WITH nocounter
    ;end select
    SET display_msg = build("The relationship to environment (",del_env_name,"/",del_env_id,
     ") will be removed")
    CALL text(7,3,display_msg)
    CALL text(9,3,"Would you like to continue?(Y/N)")
    CALL accept(9,40,"P;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     SET stat = alterlist(derd_request->env_list,1)
     SET derd_request->child_env_id = del_env_id
     SET derd_request->env_list[1].child_env_id = del_env_id
     SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
     SET derd_request->env_list[1].relationship_type = reltn_type
     EXECUTE dm_del_env_reltn
     SET stat = alterlist(derd_request->env_list,0)
     SET derd_request->child_env_id = 0
     SET stat = alterlist(derd_request->env_list,1)
     SET derd_request->child_env_id = del_env_id
     SET derd_request->env_list[1].child_env_id = del_env_id
     SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
     SET derd_request->env_list[1].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
     EXECUTE dm_del_env_reltn
     SET mdd_temp_return = drcr_get_cutover_config(dmda_mr->env_id,del_env_id)
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
     ENDIF
     IF (mdd_temp_return >= 0)
      SET derd_request->child_env_id = del_env_id
      SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
      SET derd_request->env_list[1].child_env_id = del_env_id
      IF (mdd_temp_return=0)
       SET derd_request->env_list[1].relationship_type = "AUTO CUTOVER"
      ELSE
       SET derd_request->env_list[1].relationship_type = "PLANNED CUTOVER"
      ENDIF
      EXECUTE dm_del_env_reltn
     ENDIF
     SET mdd_temp_return = drcr_get_ptam_config(dmda_mr->env_id,del_env_id)
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (mdd_temp_return >= 0)
      SET derd_request->child_env_id = del_env_id
      SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
      SET derd_request->env_list[1].child_env_id = del_env_id
      IF (mdd_temp_return=0)
       SET derd_request->env_list[1].relationship_type = "NO PENDING TARGET AS MASTER"
      ELSE
       SET derd_request->env_list[1].relationship_type = "PENDING TARGET AS MASTER"
      ENDIF
      EXECUTE dm_del_env_reltn
     ENDIF
     SET mdd_temp_return = drcr_get_dual_build_config(dmda_mr->env_id,del_env_id)
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (mdd_temp_return >= 0)
      SET derd_request->child_env_id = del_env_id
      SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
      SET derd_request->env_list[1].child_env_id = del_env_id
      IF (mdd_temp_return=0)
       SET derd_request->env_list[1].relationship_type = "ALLOW DUAL BUILD"
      ELSE
       SET derd_request->env_list[1].relationship_type = "BLOCK DUAL BUILD"
      ENDIF
      EXECUTE dm_del_env_reltn
     ENDIF
     SET stat = alterlist(derd_request->env_list,0)
     SET derd_request->child_env_id = 0
     IF ((derd_reply->err_num > 0))
      CALL text(12,3,derd_reply->err_msg)
      CALL text(13,3,"Deletion failed! Action abort...")
      CALL disp_msg(derd_reply->err_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ELSE
      CALL clear(13,1)
      CALL text(14,3,"The relationship was removed from this domain:")
      CALL text(14,55,cnvtstring(del_env_id))
      CALL text(14,65,del_env_name)
      CALL text(18,3,"Press Enter to continue:")
      CALL accept(18,40,"P;E"," ")
      SET dmda_trigger_flag = 1
     ENDIF
    ENDIF
   ENDIF
   CALL clear(23,05,74)
 END ;Subroutine
 SUBROUTINE autoadd_triggers(i_regen_type_ind)
  DECLARE at_trig_cnt = i2 WITH protect, noconstant(0)
  IF (dmda_trigger_flag > 0)
   SET accept = time(10)
   CALL clear(16,1)
   CALL text(18,3,"This program is going to recreate the change logging triggers for this domain!")
   CALL text(19,3,"Press C to continue(automatic recreation in 10 seconds if no response):")
   CALL accept(19,80,"A;CU","C"
    WHERE curaccept IN ("C", "c"))
   SET accept = notime
   SET message = nowindow
   IF (i_regen_type_ind=0)
    CALL add_trigger_tasks(null)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ELSE
    IF ((drrt_recompile_trigs(dmda_mr->env_id,0.0,"Update Trigger Proc Only")=- (1)))
     GO TO exit_program
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE add_triggers(null)
   SET re_atrig = confirm_display("SOURCE",0)
   IF (re_atrig="Y")
    SET message = nowindow
    CALL add_trigger_tasks(null)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   SET message = window
   SET width = 132
 END ;Subroutine
 SUBROUTINE add_trigger_tasks(null)
   DECLARE att_proc_cnt = i2 WITH protect, noconstant(0)
   DECLARE att_ndx = i2 WITH protect, noconstant(0)
   DECLARE att_com_batch = vc WITH protect, noconstant("")
   DECLARE att_cur_logfile = vc WITH protect, noconstant("")
   DECLARE att_execute_str = vc WITH protect, noconstant("")
   DECLARE att_dcl_stat = i4 WITH protect, noconstant(0)
   SET dmda_check_status = drtq_check_task_process("REFRESH TRIGGER PROCESS")
   IF (dmda_check_status=4)
    CALL clear(1,1)
    SET message = window
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  Create RDDS Triggers ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(12,3," There are currently active background processes refreshing the triggers.")
    CALL text(13,3,
     ' You can go to option 5 in the "Manage change log triggers" menu to monitor them.')
    CALL text(24,20,"Press ENTER to continue")
    CALL accept(24,60,"P;HCU","N")
   ELSEIF (dmda_check_status IN (1, 2, 3))
    CALL clear(1,1)
    SET message = window
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  Create RDDS Triggers ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(12,3,"    How many trigger creation processes do you want to start (minimum of 1): ")
    CALL accept(12,80,"99",4
     WHERE curaccept > 0)
    SET att_proc_cnt = curaccept
    IF (cursys="AXP")
     CALL text(15,3,"    Which batch queue would you like this COM proc submitted to?")
     CALL accept(15,70,"P(30);c")
     SET att_com_batch = curaccept
    ENDIF
    CALL dbase_connect(dmda_connect_info)
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg("Gathering connection information",dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (drtq_delete_task_process("REFRESH TRIGGER PROCESS")="F")
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
    SET stat = initrec(task_info)
    SET task_info->environment_id = dmda_mr->env_id
    SET task_info->process_name = "REFRESH TRIGGER PROCESS"
    SET task_info->total = 2
    SET stat = alterlist(task_info->qual,task_info->total)
    SET task_info->qual[1].task_level = 20
    SET task_info->qual[1].task_name = "execute DM_RMC_EXPLODE_TRIG_TASK go"
    SET task_info->qual[1].task_desc = "Generating tasks for parallel trigger regen"
    SET task_info->qual[1].task_request = replace(replace(concat(
       "<VAR_DEF>declare drtw_process_name = vc go</VAR_DEF>",
       "<VAR_DEF>declare trg_regen_reason = vc go</VAR_DEF>",
       "<VAL_SET>set drtw_process_name = 'REFRESH TRIGGER PROCESS' go</VAL_SET> ",
       "<VAL_SET>set trg_regen_reason = 'Manual regen from menu' go</VAL_SET>"),"<src_env_id>",trim(
       cnvtstring(0)),0),"<tgt_env_id>",trim(cnvtstring(dmda_mr->env_id)),0)
    IF (check_open_event(dmda_mr->env_id,0.0)=0)
     SET task_info->total = 2
     SET stat = alterlist(task_info->qual,task_info->total)
     SET task_info->qual[2].task_level = 10
     SET task_info->qual[2].task_desc = "Refreshing local meta-data"
     SET task_info->qual[2].task_name =
     'execute dm2_refresh_local_meta_data with replace("REQUEST","MD_REQUEST") go'
     SET task_info->qual[2].task_request = replace(replace(concat(
        "<REC_DEF>record md_request (1 remote_env_id = f8 1 local_env_id = f8 1 post_link_name = vc) go</REC_DEF> ",
        "<VAL_SET>set md_request->remote_env_id = <src_env_id>.0 go</VAL_SET> ",
        "<VAL_SET>set md_request->local_env_id = <tgt_env_id>.0 go</VAL_SET>"),"<src_env_id>",trim(
        cnvtstring(0)),0),"<tgt_env_id>",trim(cnvtstring(dmda_mr->env_id)),0)
     SET task_info->qual[1].task_request = replace(replace(concat(
        "<VAR_DEF>declare drtw_process_name = vc go</VAR_DEF>",
        "<VAR_DEF>declare trg_regen_reason = vc go</VAR_DEF>",
        "<VAL_SET>set drtw_process_name = 'REFRESH TRIGGER PROCESS' go</VAL_SET> ",
        "<VAL_SET>set trg_regen_reason = 'Manual regen from menu with no open event' go</VAL_SET>"),
       "<src_env_id>",trim(cnvtstring(0)),0),"<tgt_env_id>",trim(cnvtstring(dmda_mr->env_id)),0)
    ENDIF
    IF (drtq_insert_task_process(task_info,1)="F")
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
    FOR (att_ndx = 1 TO att_proc_cnt)
      SET att_cur_logfile = dm_err->unique_fname
      IF (get_unique_file("rdds_run_proc",".log")=0)
       SET nohup_submit_logfile = "rdds_run_proc.log"
       SET dm_err->err_ind = 0
      ELSE
       SET nohup_submit_logfile = dm_err->unique_fname
      ENDIF
      SET dm_err->unique_fname = att_cur_logfile
      IF (cursys="AXP")
       SET att_execute_str = concat("SUBMIT /QUE=",att_com_batch,
        " cer_proc:rdds_run_proc.com /param=(",'"REFRESH TRIGGER PROCESS",',dmda_connect_info->
        db_password,
        ",",dmda_connect_info->db_sid,") /log=CCLUSERDIR:",nohup_submit_logfile)
      ELSE
       SET att_execute_str = concat("nohup $cer_proc/rdds_run_proc.ksh 'REFRESH TRIGGER PROCESS' ",
        dmda_connect_info->db_password," ",dmda_connect_info->db_sid," > $CCLUSERDIR/",
        nohup_submit_logfile," 2>&1 &")
      ENDIF
      CALL echo(att_execute_str)
      CALL dcl(att_execute_str,size(att_execute_str),att_dcl_stat)
      IF (att_dcl_stat=0)
       SET dm_err->eproc = concat("Error connecting to: ",att_dcl_stat)
       CALL disp_msg(" ",dm_err->logfile,0)
       GO TO exit_program
      ENDIF
    ENDFOR
    CALL mc_confirm_screen("trigger",att_proc_cnt)
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_log_rpt(null)
  DECLARE clr_con = i2 WITH protect, noconstant(0)
  WHILE (clr_con=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,40,"***  Change Log Summary Reports ***")
    CALL text(7,3,"Choose from the following options: ")
    CALL text(9,3,"1 View remaining chg log summary (source)")
    CALL text(10,3,"2 View reference data mover failure report")
    CALL text(11,3,"3 View remaining chg log rows that require the ptam_match_hash backfill")
    CALL text(17,3,"0 Exit")
    CALL dmda_draw_event_box(8,80,0,dmda_event_info)
    CALL accept(7,50,"9",0
     WHERE curaccept IN (1, 2, 3, 0))
    CASE (curaccept)
     OF 1:
      CALL chg_log_src(null)
     OF 2:
      CALL chg_log_tgt(null)
     OF 3:
      CALL chg_log_vers(null)
     OF 0:
      SET clr_con = 1
    ENDCASE
  ENDWHILE
 END ;Subroutine
 SUBROUTINE chg_log_src(null)
  SET re_dtrig = confirm_display("SOURCE",0)
  IF (re_dtrig="Y")
   CALL clear(17,1)
   CALL text(17,3,"Getting report....")
   EXECUTE dm2_src_chg_log_summary
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE chg_log_tgt(null)
  SET re_dtrig = confirm_display("TARGET",0)
  IF (re_dtrig="Y")
   EXECUTE dm2_tgt_chg_log_summary
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE confirm_display(domain_name,trg_flag)
   CALL clear(20,1)
   CALL text(20,38,"!!!WARNING: ONLY execute this program in")
   CALL text(20,80,domain_name)
   IF (domain_name="REPLICATE TARGET")
    CALL text(20,96," domain!!!")
   ELSE
    CALL text(20,87," domain!!!")
   ENDIF
   IF (trg_flag=1)
    CALL text(22,3,
     "NOTE: Adding or removing domain relationships will cause the change log triggers to be recreated"
     )
   ENDIF
   CALL text(24,3,"Would you like to continue?(Y/N)")
   CALL accept(24,40,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE stop_ref_mover(null)
   SET message = nowindow
   UPDATE  FROM dm_info
    SET info_number = 0
    WHERE info_domain=patstring(concat("MERGE*",cnvtstring(dmda_mr->env_id)))
     AND info_name="RDDS MOVERS TO RUN"
    WITH nocounter
   ;end update
   IF (check_error("Can not update 'RDDS MOVERS TO RUN' to 0") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   COMMIT
   EXECUTE dm2_stop_data_movers
   SET message = window
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Stopping All RDDS Movers"
   SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
   SET auto_ver_request->qual[1].paired_environment_id = 0
   SET auto_ver_request->qual[1].event_reason = "Stop all movers through menu"
   EXECUTE dm_rmc_auto_verify_setup
   IF (auto_ver_reply="F")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
    GO TO exit_program
   ELSE
    COMMIT
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE mover_management(null)
   DECLARE mover_con = i2 WITH protect, noconstant(0)
   DECLARE mm_ret_val = c1
   DECLARE mm_ret_val2 = c1
   DECLARE mm_mig_check = i2 WITH protect, noconstant(0)
   DECLARE mm_freeze_check = i2 WITH protect, noconstant(0)
   IF (no_confirm=0)
    SET mm_ret_val = confirm_display("TARGET",0)
   ELSE
    SET mm_ret_val = "Y"
   ENDIF
   SET no_confirm = 0
   IF (mm_ret_val="Y")
    WHILE (mover_con=0)
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,7,132)
      CALL text(3,40,"***  Manage Data Movers ***")
      CALL text(5,20,"Environment Name:")
      CALL text(5,40,dmda_mr->env_name)
      CALL text(5,65,"Environment ID:")
      CALL text(5,85,cnvtstring(dmda_mr->env_id))
      CALL text(9,3,"Choose from the following options: ")
      CALL text(11,3,"1 Stop all data movers")
      CALL text(12,3,"2 Start data movers")
      CALL text(13,3,"3 View data movers")
      IF (cutover_flag=1)
       CALL text(14,3,"4 Configure data movers")
      ENDIF
      CALL text(15,3,"5 Monitor Mover Progress")
      CALL text(17,3,"0 Exit")
      CALL dmda_draw_event_box(10,75,0,dmda_event_info)
      CALL accept(9,45,"9",0
       WHERE curaccept IN (1, 2, 3, 4, 5,
       0))
      CASE (curaccept)
       OF 1:
        CALL stop_ref_mover(null)
       OF 2:
        SET mm_mig_check = dmda_check_mig_settings(1,dmda_event_info->event_name,"RDDS Mover")
        IF (((mm_mig_check=1) OR ((dm_err->err_ind=1))) )
         SET mover_con = 1
        ELSE
         SET mm_freeze_check = drrm_check_freeze(dmda_mr->env_id)
         IF (mm_freeze_check=1)
          SET dm_err->err_ind = 1
          SET dm_err->emsg = concat(
           "There is currently a migration schema freeze in place.  Movers will not be ",
           "allowed to start.  Please work with the integration architect to know when schema freeze will be over."
           )
         ENDIF
         IF (check_error_gui("Checking for Migration Schema Freeze","Manage Data Movers",dmda_mr->
          env_name,dmda_mr->env_id)=1)
          SET mover_con = 1
         ELSE
          SET srm_ret_val2 = connect_info_display(null)
          IF (srm_ret_val2="Y")
           CALL start_ref_mover(null)
          ELSE
           SET mover_con = 1
          ENDIF
         ENDIF
        ENDIF
       OF 3:
        CALL view_ref_mover(null)
       OF 4:
        IF (cutover_flag=0)
         CALL text(20,3,"This option is not available at this time.")
         CALL pause(3)
        ELSE
         CALL cutover_configure_movers(null)
        ENDIF
       OF 5:
        CALL dmda_mvr_mons(null)
        SET message = window
        SET accept = notime
       OF 0:
        SET mover_con = 1
      ENDCASE
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE start_ref_mover(null)
   CALL clear(1,1)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL parser("cclseclogin go")
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = ""
      SET dm_err->err_ind = 0
     ENDIF
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "Starting Data Movers"
      SET dm_err->emsg = "User not logged in cclseclogin"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   IF (curgroup != 0)
    CALL clear(1,1)
    CALL text(15,3,
     "RDDS movers cannot be started at this time because the current user does not have required Group 0 privileges."
     )
    CALL text(17,20,"Press ENTER to return to the previous menu.")
    CALL accept(17,64,"P;E"," ")
    SET help = off
    SET validate = off
    RETURN
   ENDIF
   DECLARE srm_num_mover = i4
   DECLARE srm_info_domain = vc
   DECLARE srm_nbr = i4
   DECLARE srm_tot_domain = vc
   DECLARE srm_m_exist = i2
   DECLARE srm_info_number = i4
   DECLARE srm_rdds_context_ind = i2 WITH protect
   DECLARE srm_rdds_context_call = i2 WITH protect, noconstant(0)
   DECLARE srm_open_event_source = f8
   DECLARE srm_open_event_target = f8
   DECLARE srm_open_event_reason = vc
   DECLARE srm_dmda_mover_cutover_off_ind = i2
   DECLARE srm_open_event_dt_tm = dq8
   DECLARE srm_del_ind = i4 WITH protect, noconstant(0)
   DECLARE srm_last_evt_log = f8 WITH protect, noconstant(0.0)
   DECLARE srm_orig_cntxt = vc WITH protect, noconstant("")
   DECLARE srm_for_cnt = i4 WITH protect, noconstant(0)
   DECLARE srm_line = i4 WITH protect, noconstant(0)
   DECLARE srm_open_event_id = f8 WITH protect, noconstant(0.0)
   DECLARE srm_open_event_src_name = vc WITH protect, noconstant("")
   DECLARE srm_mock_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE srm_xlat_bckfll_ind = i2 WITH protect, noconstant(0)
   SET srm_m_exist = 0
   SET srm_info_number = 60
   CALL dbase_connect(dmda_connect_info)
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg("Gathering connection information",dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL get_src_env_id("Start Ref Movers",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   SET srm_mock_env_id = drmmi_get_mock_id(dmda_mr->env_id)
   IF (srm_mock_env_id < 0.0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET srm_xlat_bckfll_ind = check_xlat_backfill(srm_env_id,dmda_mr->env_id,srm_mock_env_id)
   COMMIT
   IF (srm_xlat_bckfll_ind=0)
    CALL clear(19,1)
    CALL text(20,3,concat(
      "It has been detected that all sequence match rows have not had their translations",
      " backfilled."))
    CALL text(21,3,concat("We advise that the backfill process be performed first by choosing ",
      " 'Manage Translate Backfill Process' from the main menu."))
    CALL text(24,3,"Press enter to return to main menu: ")
    CALL accept(24,45,"P;E"," ")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM dm_env_reltn der
    WHERE (der.child_env_id=dmda_mr->env_id)
     AND der.parent_env_id=srm_env_id
     AND der.relationship_type IN ("AUTO CUTOVER", "PLANNED CUTOVER")
    WITH nocounter
   ;end select
   IF (curqual=0
    AND cutover_flag=1)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  Manage Data Movers ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(11,3,"   Cutover configuration is NOT complete, no mover will start")
    CALL text(12,20,"Press ENTER to continue")
    CALL accept(12,60,"P;E"," ")
    ROLLBACK
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND drel.paired_environment_id != srm_env_id
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND paired_environment_id != srm_env_id
      AND rdds_event="End Reference Data Sync"
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     srm_open_event_target = drel.cur_environment_id, srm_open_event_source = drel
     .paired_environment_id, srm_open_event_reason = drel.event_reason,
     srm_open_event_dt_tm = drel.event_dt_tm, srm_open_event_id = drel.dm_rdds_event_log_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Looking for an open event for an alternate source."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND (drel.cur_environment_id=dmda_mr->env_id)
      AND drel.paired_environment_id=srm_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE (cur_environment_id=dmda_mr->env_id)
       AND paired_environment_id=srm_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     DETAIL
      srm_open_event_target = drel.cur_environment_id, srm_open_event_source = drel
      .paired_environment_id, srm_open_event_reason = drel.event_reason,
      srm_open_event_dt_tm = drel.event_dt_tm, srm_open_event_id = drel.dm_rdds_event_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = "Looking for an open event for the current source."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual=0)
     SET srm_open_event = dmda_open_rdds_event(srm_env_id)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     RETURN
    ELSE
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Manage Data Movers ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(14,3,"Should the RDDS merge continue running under the following event?")
     CALL text(15,3,concat("Event: ",srm_open_event_reason))
     SET accept = nopatcheck
     CALL accept(16,40,"P;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     SET accept = patcheck
     IF (curaccept="Y")
      SET meta_data_trigger_refresh_global_ind = 0
      SET srm_rdds_context_ind = 1
      IF (srm_rdds_context_ind=1)
       SELECT INTO "nl:"
        FROM dm_rdds_event_log d
        WHERE d.dm_rdds_event_log_id IN (
        (SELECT
         max(dm_rdds_event_log_id)
         FROM dm_rdds_event_log l
         WHERE (l.cur_environment_id=dmda_mr->env_id)
          AND l.paired_environment_id=srm_env_id
          AND l.rdds_event_key="STARTINGRDDSMOVER"
          AND l.event_dt_tm >= cnvtdatetime(srm_open_event_dt_tm)))
        DETAIL
         srm_last_evt_log = d.dm_rdds_event_log_id
        WITH nocounter
       ;end select
       IF (check_error("Finding movers run in this event.") != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (curqual > 0)
        SELECT INTO "nl:"
         FROM dm_rdds_event_detail d
         WHERE d.dm_rdds_event_log_id=srm_last_evt_log
          AND d.event_detail1_txt="CONTEXTS TO PULL"
         DETAIL
          IF (daf_is_not_blank(srm_orig_cntxt))
           srm_orig_cntxt = concat(srm_orig_cntxt,"::",d.event_detail2_txt)
          ELSE
           srm_orig_cntxt = d.event_detail2_txt
          ENDIF
         WITH nocounter
        ;end select
        IF (check_error("Finding contexts pulled by last mover.") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        SET srm_rdds_context_call = manage_rdds_context(1,srm_orig_cntxt)
       ELSE
        SET srm_rdds_context_call = manage_rdds_context(0,"")
       ENDIF
       IF (srm_rdds_context_call=0)
        CALL disp_msg("Failed during MANAGE_RDDS_CONTEXT subroutine",dm_err->logfile,1)
        GO TO exit_program
       ELSEIF (srm_rdds_context_call=2)
        ROLLBACK
        RETURN
       ENDIF
      ELSE
       UPDATE  FROM dm_info di
        SET di.info_char = "NULL", di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (di
         .updt_cnt+ 1),
         di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task
          = reqinfo->updt_task
        WHERE di.info_domain="RDDS CONTEXT"
         AND di.info_name="CONTEXTS TO PULL"
        WITH nocounter
       ;end update
       IF (curqual=0)
        INSERT  FROM dm_info di
         SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXTS TO PULL", di.info_char =
          "NULL",
          di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
           curdate,curtime3),
          di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
         WITH nocounter
        ;end insert
       ENDIF
       UPDATE  FROM dm_info di
        SET di.info_char = "NULL", di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (di
         .updt_cnt+ 1),
         di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task
          = reqinfo->updt_task
        WHERE di.info_domain="RDDS CONTEXT"
         AND di.info_name="CONTEXT TO SET"
        WITH nocounter
       ;end update
       IF (curqual=0)
        INSERT  FROM dm_info di
         SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXT TO SET", di.info_char = "NULL",
          di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
           curdate,curtime3),
          di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
         WITH nocounter
        ;end insert
       ENDIF
      ENDIF
      IF (check_error("Can not load RDDS Context DM_INFO row") != 0)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      CALL dmda_start_rdds_movers(meta_data_trigger_refresh_global_ind)
     ELSE
      IF (dm_close_event_chk(dmda_mr->env_name,dmda_mr->env_id,srm_open_event_id)=1)
       CALL clear(1,1)
       SET message = window
       SET width = 132
       CALL box(1,1,7,132)
       CALL text(3,40,"***  Close An RDDS Event  ***")
       CALL text(5,20,"Environment Name:")
       CALL text(5,40,dmda_mr->env_name)
       CALL text(5,65,"Environment ID:")
       CALL text(5,85,cnvtstring(dmda_mr->env_id))
       SELECT INTO "nl:"
        FROM dm_environment de
        WHERE de.environment_id=srm_open_event_source
        DETAIL
         srm_open_event_src_name = de.environment_name
        WITH nocounter
       ;end select
       IF (check_error("Error finding environment name for environment id specified") != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (size(r_table->r_cleanup,5) > 0)
        CALL text(8,3,concat(
          "Uncutover $R rows will also be purged for the following Source environments ",
          "which do not have a valid RDDS relationship."))
        CALL text(10,3,"Environment Name (Environment ID)")
       ENDIF
       SET srm_line = 10
       FOR (srm_for_cnt = 1 TO size(r_table->r_cleanup,5))
        SET srm_line = (srm_line+ 1)
        CALL text(srm_line,3,r_table->r_cleanup[srm_for_cnt].message)
       ENDFOR
       SET srm_line = (srm_line+ 2)
       CALL text(srm_line,3,concat("Can the following RDDS open event be closed for source: ",trim(
          srm_open_event_src_name,3)," (",trim(cnvtstring(srm_open_event_source)),") ?"))
       SET srm_line = (srm_line+ 1)
       CALL text(srm_line,3,concat("Event: ",srm_open_event_reason))
       SET accept = nopatcheck
       CALL accept(srm_line,40,"P;CU","N"
        WHERE curaccept IN ("Y", "N"))
       SET accept = patcheck
       IF (curaccept="Y")
        EXECUTE dm_rmc_bookmark_end srm_open_event_source, srm_open_event_target,
        srm_open_event_reason
        IF ((dm_err->err_ind=1))
         ROLLBACK
         RETURN
        ENDIF
        SET srm_open_event = dmda_open_rdds_event(srm_open_event_source)
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        RETURN
       ELSE
        SET dm_err->emsg =
        "The current RDDS open event needs to be closed before continuing. Exiting the DM_MERGE_DOMAIN_ADM menu."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        CALL clear(1,1)
        CALL text(15,3,
         "The current RDDS open event needs to be closed before continuing. Exiting the menu program."
         )
        CALL text(16,20,"Press ENTER to return to the previous menu.")
        CALL accept(16,64,"P;E"," ")
        SET help = off
        SET validate = off
        RETURN
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (curqual=1)
    IF (dm_close_event_chk(dmda_mr->env_name,dmda_mr->env_id,srm_open_event_id)=1)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Close An RDDS Event ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     SELECT INTO "nl:"
      FROM dm_environment de
      WHERE de.environment_id=srm_open_event_source
      DETAIL
       srm_open_event_src_name = de.environment_name
      WITH nocounter
     ;end select
     IF (check_error("Error finding environment name for environment id specified") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     CALL text(8,3,concat("To start movers for source: ",trim(srm_env_name)," (",trim(cnvtstring(
         srm_env_id,20,1),3),"), a new event needs to be open,"))
     CALL text(9,3,concat(" but there is currently an open event for source ",trim(
        srm_open_event_src_name)," (",trim(cnvtstring(srm_open_event_source,20,1),3),
       ") that has to be closed first."))
     IF (size(r_table->r_cleanup,5) > 0)
      CALL text(11,3,concat(
        "Uncutover $R rows will also be purged for the following Source environments ",
        "which do not have a valid RDDS relationship."))
      CALL text(12,3,"Environment Name (Environment ID)")
     ENDIF
     SET srm_line = 12
     FOR (srm_for_cnt = 1 TO size(r_table->r_cleanup,5))
      SET srm_line = (srm_line+ 1)
      CALL text(srm_line,3,r_table->r_cleanup[srm_for_cnt].message)
     ENDFOR
     SET srm_line = (srm_line+ 2)
     CALL text(srm_line,3,concat("Can the following RDDS open event ",trim(srm_open_event_reason,3),
       "  be closed for source: ",trim(srm_open_event_src_name)," (",
       trim(cnvtstring(srm_open_event_source,20,1),3),") ?"))
     SET srm_line = (srm_line+ 1)
     CALL text(srm_line,3,concat("Event: ",srm_open_event_reason))
     SET accept = nopatcheck
     CALL accept(srm_line,40,"P;CU","N"
      WHERE curaccept IN ("Y", "N"))
     SET accept = patcheck
     IF (curaccept="Y")
      EXECUTE dm_rmc_bookmark_end srm_open_event_source, srm_open_event_target, srm_open_event_reason
      IF ((dm_err->err_ind=1))
       ROLLBACK
       RETURN
      ENDIF
      SET srm_open_event = dmda_open_rdds_event(srm_open_event_source)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      RETURN
     ELSE
      SET dm_err->emsg = concat("Event ",srm_open_event_reason," for source environment: ",trim(
        cnvtstring(srm_open_event_source)),
       " is currently open. You cannot open a new RDDS event while another event is open.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      CALL clear(1,1)
      CALL text(15,3,concat("Event: ",srm_open_event_reason))
      CALL text(16,3,concat("For source environment: ",trim(srm_open_event_src_name,3)," ",trim(
         cnvtstring(srm_open_event_source))," is currently open."))
      CALL text(17,3,"You cannot open a new RDDS event in this target while another event is open.")
      CALL text(18,20,"Press ENTER to return to the previous menu.")
      CALL accept(18,64,"P;E"," ")
      SET help = off
      SET validate = off
      RETURN
     ENDIF
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "There are multiple RDDS events open. Please contact the IAC. Exiting the DM_MERGE_DOMAIN_ADM menu."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE view_ref_mover(null)
   DECLARE srm_loop = i4
   DECLARE vrm_mvr_cnt = vc
   DECLARE srm_count = i4
   DECLARE srm_count2 = i4
   DECLARE rdds_movers = i4
   DECLARE pre_env_id = f8 WITH noconstant(0.0)
   FREE RECORD srm_source
   RECORD srm_source(
     1 srm_cnt = i4
     1 list[*]
       2 env_id = f8
       2 info_domain = vc
       2 env_name = vc
       2 distr_cnt = i4
       2 cnt = i4
       2 env[*]
         3 cnt = i4
         3 process_name = vc
         3 status = vc
         3 log_file = vc
   )
   SELECT INTO "nl:"
    FROM dm_info di,
     dm_env_reltn der,
     dm_environment de
    PLAN (di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID")
     JOIN (der
     WHERE di.info_number=der.child_env_id
      AND der.relationship_type=reltn_type)
     JOIN (de
     WHERE de.environment_id=der.parent_env_id)
    ORDER BY de.environment_id
    DETAIL
     srm_count = (srm_count+ 1)
     IF (mod(srm_count,10)=1)
      stat = alterlist(srm_source->list,(srm_count+ 9))
     ENDIF
     srm_source->list[srm_count].env_id = der.parent_env_id, srm_source->list[srm_count].env_name =
     de.environment_name, srm_source->list[srm_count].info_domain = build("MERGE",cnvtstring(der
       .parent_env_id),cnvtstring(dmda_mr->env_id)),
     srm_source->list[srm_count].cnt = 0
    FOOT REPORT
     stat = alterlist(srm_source->list,srm_count), srm_source->srm_cnt = srm_count
    WITH nocounter
   ;end select
   IF ((srm_source->srm_cnt=0))
    SELECT INTO mine
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      col 40, "*** View Data Movers ***", row + 2,
      col 20, "Source Env Name:", col 40,
      dmda_mr->env_name, col 65, "Source Env ID:",
      col 85, dmda_mr->env_id, row + 2
     DETAIL
      col 3, "There is no parent relationship setup for current environment"
     WITH nocounter
    ;end select
   ELSE
    SET rdds_movers = 0
    IF (cutover_flag=1)
     SELECT INTO "NL:"
      FROM dm_refchg_process drp,
       (dummyt d  WITH seq = srm_source->srm_cnt)
      PLAN (d)
       JOIN (drp
       WHERE drp.refchg_type IN ("MOVER PROCESS", "ORPHANED MOVER")
        AND (drp.env_source_id=srm_source->list[d.seq].env_id)
        AND drp.rdbhandle_value IN (
       (SELECT
        audsid
        FROM gv$session)))
      DETAIL
       srm_count2 = (srm_count2+ 1)
       IF (mod(srm_count2,10)=1)
        stat = alterlist(srm_source->list[d.seq].env,(srm_count2+ 9))
       ENDIF
       srm_source->list[d.seq].env[srm_count2].process_name = cnvtstring(drp.process_name),
       srm_source->list[d.seq].env[srm_count2].log_file = drp.log_file, srm_source->list[d.seq].env[
       srm_count2].cnt = srm_count2
       IF (drp.refchg_status IN ("HANGING MOVER", "ORPHANED MOVER", "WRITING HANGING FILE"))
        srm_source->list[d.seq].env[srm_count2].status = "HANGING MOVER"
       ELSEIF (drp.refchg_type="MOVER PROCESS")
        srm_source->list[d.seq].env[srm_count2].status = "RUNNING MOVER"
       ELSE
        srm_source->list[d.seq].env[srm_count2].status = drp.refchg_type
       ENDIF
      FOOT REPORT
       stat = alterlist(srm_source->list[d.seq].env,srm_count2), srm_source->list[d.seq].cnt =
       srm_count2
      WITH nocounter
     ;end select
     SELECT INTO mine
      FROM (dummyt d  WITH seq = srm_source->srm_cnt)
      HEAD REPORT
       col 35, "*** View RDDS Movers ***", row + 2,
       col 2, "Number of movers running in ", col 31,
       dmda_mr->env_name, row + 2, col 2,
       "Source Env Name", col 20, "Source Env ID",
       col 39, "Mover Count", col 52,
       "Mover Status", col 72, "Process ID",
       col 95, "Log File", row + 1,
       pre_env_id = 0.0
      DETAIL
       IF ((srm_source->list[d.seq].env_id != pre_env_id))
        row + 1, col 2, srm_source->list[d.seq].env_name,
        col 20, srm_source->list[d.seq].env_id
        FOR (srm_loop = 1 TO srm_source->list[d.seq].cnt)
          vrm_mvr_cnt = cnvtstring(srm_source->list[d.seq].env[srm_loop].cnt), col 39, vrm_mvr_cnt,
          col 52, srm_source->list[d.seq].env[srm_loop].status, col 72,
          srm_source->list[d.seq].env[srm_loop].process_name, col 95, srm_source->list[d.seq].env[
          srm_loop].log_file,
          row + 1
        ENDFOR
        row + 1
       ENDIF
      FOOT REPORT
       pre_env_id = srm_source->list[d.seq].env_id
      WITH nocounter, maxcol = 150
     ;end select
    ELSE
     SELECT INTO mine
      FROM dm_info di,
       (dummyt d  WITH seq = srm_source->srm_cnt)
      PLAN (d)
       JOIN (di
       WHERE ((di.info_name="RDDS MOVERS RUNNING") OR (di.info_name="RDDS MOVERS TO RUN"))
        AND (di.info_domain=srm_source->list[d.seq].info_domain))
      HEAD REPORT
       col 35, "*** View Data Movers ***", row + 2,
       col 0, "Environment Id", col 18,
       "Environment Name", col 45, "Number of RDDS Movers Running",
       col 85, "Number of RDDS Movers to Run", row + 2,
       pre_env_id = 0.0
      DETAIL
       IF ((srm_source->list[d.seq].env_id != pre_env_id))
        row + 1, col 0, srm_source->list[d.seq].env_id,
        col 18, srm_source->list[d.seq].env_name
       ENDIF
       IF (di.info_name="RDDS MOVERS RUNNING")
        col 45, di.info_number
       ELSEIF (di.info_name="RDDS MOVERS TO RUN")
        col 85, di.info_number
       ENDIF
       pre_env_id = srm_source->list[d.seq].env_id
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (check_error("view RDDS movers information") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE get_src_env_id(sub_title,sub_confirm_ind)
  DECLARE env_confirmed = i2 WITH protect, noconstant(0)
  WHILE (env_confirmed=0)
    IF (srm_env_id=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
     CALL text(3,40,concat("*** ",sub_title," ***"))
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(8,3,"1. Please input source environment id (Enter 0 to exit):")
     SET help =
     SELECT INTO "nl:"
      der.parent_env_id, de.environment_name
      FROM dm_info di,
       dm_env_reltn der,
       dm_environment de
      PLAN (di
       WHERE di.info_domain="DATA MANAGEMENT"
        AND di.info_name="DM_ENV_ID")
       JOIN (der
       WHERE di.info_number=der.child_env_id
        AND der.relationship_type=reltn_type
        AND der.post_link_name IS NOT null
        AND der.post_link_name != " ")
       JOIN (de
       WHERE ((de.environment_id=der.parent_env_id) UNION (
       (SELECT
        parent_env_id = 0, environment_name = "(Exit)"
        FROM dual))) )
      ORDER BY 2
      WITH nocounter
     ;end select
     SET validate =
     SELECT INTO "nl:"
      der.parent_env_id
      FROM dm_info di,
       dm_env_reltn der
      PLAN (di
       WHERE di.info_domain="DATA MANAGEMENT"
        AND di.info_name="DM_ENV_ID")
       JOIN (der
       WHERE di.info_number=der.child_env_id
        AND der.relationship_type=reltn_type
        AND der.parent_env_id=cnvtreal(curaccept)
        AND der.post_link_name IS NOT null
        AND ((der.post_link_name != " ") UNION (
       (SELECT
        parent_env_id = 0
        FROM dual
        WHERE cnvtreal(curaccept)=0))) )
      WITH nocounter
     ;end select
     SET validate = 2
     CALL accept(8,70,"N(15);CU","0")
     CALL clear(23,1)
     SET srm_env_id = cnvtreal(trim(curaccept,3))
     SELECT INTO "nl:"
      FROM dm_environment de
      WHERE de.environment_id=srm_env_id
      DETAIL
       srm_env_name = de.environment_name
      WITH nocounter
     ;end select
     SET help = off
     SET validate = off
     CALL clear(23,1)
    ENDIF
    IF (srm_env_id != 0)
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,concat("*** ",sub_title," ***"))
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,03,concat("Your current selected environment is : ",srm_env_name))
     CALL text(10,03,concat("With an environment_id of            : ",cnvtstring(srm_env_id)))
     IF (sub_confirm_ind=1)
      CALL text(12,3,"Continue? [(Y)es / (N)o / e(X)it]")
      CALL accept(12,38,"P;CU","Y"
       WHERE curaccept IN ("Y", "N", "X"))
     ELSE
      CALL text(12,3,"Continue? [(Y)es / (N)o]")
      CALL accept(12,29,"P;CU","Y"
       WHERE curaccept IN ("Y", "N"))
     ENDIF
    ELSE
     SET env_confirmed = 1
     SET srm_env_name = ""
    ENDIF
    IF (curaccept="Y")
     SET env_confirmed = 1
    ELSEIF (curaccept="N")
     SET srm_env_id = 0
     SET srm_env_name = ""
    ELSEIF (curaccept="X")
     SET env_confirmed = 1
     SET srm_env_id = 0
     SET srm_env_name = ""
    ENDIF
  ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_manage_post_domain_copy(null)
   DECLARE dmpdc_ret_val = c1
   DECLARE dmpdc_line_d = vc WITH protect, noconstant("")
   DECLARE dmpdc_continue_ind = i2 WITH protect, noconstant(0)
   FREE RECORD rdds_setup_info
   RECORD rdds_setup_info(
     1 list[*]
       2 setup_summary_str = vc
       2 target_env_id = f8
       2 target_env_name = vc
       2 source_env_id = f8
       2 source_env_name = vc
       2 target_reltn_str = vc
       2 source_reltn_str = vc
       2 target_fc_str = vc
       2 source_fc_str = vc
       2 target_seq_match_str = vc
       2 source_seq_match_str = vc
       2 target_refchg_trig_str = vc
       2 source_refchg_trig_str = vc
       2 target_dblink_str = vc
       2 source_dblink_str = vc
       2 target_xlat_backfill_str = vc
       2 source_xlat_backfill_str = vc
       2 mock_ea_user_realm_str = vc
   )
   FREE RECORD drrs_reply
   RECORD drrs_reply(
     1 status_flg = i4
     1 err_msg = vc
   )
   SET dmpdc_line_d = fillstring(50,"=")
   IF (no_confirm=0)
    SET dmpdc_ret_val = confirm_display("REPLICATE TARGET",0)
   ELSE
    SET dmpdc_ret_val = "Y"
   ENDIF
   SET no_confirm = 0
   IF (dmpdc_ret_val="Y")
    SET stat = alterlist(rdds_setup_info->list,1)
    SET rdds_setup_info->list[1].target_env_id = dmda_mr->env_id
    SET rdds_setup_info->list[1].target_env_name = dmda_mr->env_name
    WHILE (dmpdc_continue_ind=0)
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,7,132)
      CALL text(3,40,"***  Manage Post Domain Copy ***")
      CALL text(5,20,"Environment Name:")
      CALL text(5,40,dmda_mr->env_name)
      CALL text(5,65,"Environment ID:")
      CALL text(5,85,cnvtstring(dmda_mr->env_id))
      CALL text(9,3,"Choose from the following options: ")
      CALL text(11,3,"1 Setup RDDS Post Domain Copy")
      CALL text(12,3,"2 Validate RDDS Setup Post Domain Copy")
      CALL text(13,3,"3 Start Translation Backfill Process")
      CALL text(14,3,"4 View Translation Backfill Process")
      CALL text(15,3,"5 Configure RDDS Settings")
      CALL text(17,3,"0 Exit")
      CALL dmda_draw_event_box(10,75,0,dmda_event_info)
      CALL accept(9,45,"9",0
       WHERE curaccept IN (1, 2, 3, 4, 5,
       0))
      CASE (curaccept)
       OF 1:
        EXECUTE dm_rmc_rdds_setup  WITH replace("REPLY","DRRS_REPLY")
        IF ((drrs_reply->status_flg=- (1)))
         SET message = nowindow
         CALL disp_msg(drrs_reply->err_msg,dm_err->logfile,1)
         GO TO exit_program
        ELSEIF ((drrs_reply->status_flg=- (2)))
         SET message = nowindow
         CALL disp_msg(drrs_reply->err_msg,dm_err->logfile,1)
         SET dm_err->eproc = "DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION."
         CALL disp_msg("",dm_err->logfile,0)
         GO TO exit_program
        ELSEIF ((drrs_reply->status_flg=1))
         CALL dmda_val_post_domain_copy(null)
        ELSE
         SET message = window
        ENDIF
       OF 2:
        CALL text(19,3,"Generating report. Please wait...")
        CALL dmda_val_post_domain_copy(null)
       OF 3:
        SET dmpdc_ret_val2 = connect_info_display(null)
        IF (dmpdc_ret_val2="Y")
         CALL dmda_start_xlat_backfill(null)
        ELSE
         SET dmpdc_continue_ind = 1
        ENDIF
       OF 4:
        CALL dmda_view_xlat_backfill(null)
       OF 5:
        CALL dmda_configure_rdds_settings(null)
       OF 0:
        SET dmpdc_continue_ind = 1
      ENDCASE
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_configure_rdds_settings(null)
   DECLARE dcrr_src_env_id = f8 WITH protect, noconstant(- (1.0))
   DECLARE dcrr_src_env_name = vc WITH protect, noconstant("")
   DECLARE dcrr_orig_cutover_setting = i2 WITH protect, noconstant(- (2))
   DECLARE dcrr_orig_ptam_setting = i2 WITH protect, noconstant(- (2))
   DECLARE dcrr_orig_dual_build_setting = i2 WITH protect, noconstant(- (2))
   DECLARE dcrr_new_cutover_setting = i2 WITH protect, noconstant(- (2))
   DECLARE dcrr_new_ptam_setting = i2 WITH protect, noconstant(- (2))
   DECLARE dcrr_new_dual_build_setting = i2 WITH protect, noconstant(- (2))
   DECLARE dcrr_orig_cutover_setting_vc = vc WITH protect, noconstant("")
   DECLARE dcrr_new_setting_ind = i2 WITH protect, noconstant(0)
   DECLARE dcrr_continue_ind = i2 WITH protect, noconstant(1)
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Configure RDDS Settings ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
   CALL text(9,3,
    "Please input the source environment id you want to configure the relationship for (Enter 0 to exit):"
    )
   SET help =
   SELECT INTO "nl:"
    de.environment_id, de.environment_name
    FROM dm_environment de,
     dm_env_reltn der
    WHERE de.environment_id > 0
     AND de.environment_id=der.parent_env_id
     AND (der.child_env_id=dmda_mr->env_id)
     AND ((der.relationship_type="REFERENCE MERGE") UNION (
    (SELECT
     environment_id = 0, environment_name = "(Exit)"
     FROM dual)))
    ORDER BY 2
    WITH nocounter
   ;end select
   SET validate =
   SELECT INTO "nl:"
    der.parent_env_id
    FROM dm_env_reltn der
    WHERE der.parent_env_id=cnvtreal(curaccept)
     AND de.environment_id=der.environment_id
     AND (der.child_env_id=dmda_mr->env_id)
     AND ((der.relationship_type="REFERENCE MERGE") UNION (
    (SELECT
     child_env_id = 0
     FROM dual
     WHERE cnvtreal(curaccept)=0)))
    WITH nocounter
   ;end select
   SET validate = 2
   CALL accept(9,105,"N(15);CU","0")
   CALL clear(23,1)
   SET dcrr_src_env_id = cnvtreal(trim(curaccept,3))
   IF (dcrr_src_env_id=0)
    SET dcrr_continue_ind = 0
   ENDIF
   SET validate = off
   SELECT INTO "nl:"
    FROM dm_environment d
    WHERE d.environment_id=dcrr_src_env_id
    DETAIL
     dcrr_src_env_name = d.environment_name
    WITH nocounter
   ;end select
   SET dcrr_orig_cutover_setting = drcr_get_cutover_config(dcrr_src_env_id,dmda_mr->env_id)
   SET dcrr_orig_ptam_setting = drcr_get_ptam_config(dcrr_src_env_id,dmda_mr->env_id)
   SET dcrr_orig_dual_build_setting = drcr_get_dual_build_config(dcrr_src_env_id,dmda_mr->env_id)
   SET dcrr_new_cutover_setting = drcr_get_cutover_config(dcrr_src_env_id,dmda_mr->env_id)
   SET dcrr_new_ptam_setting = drcr_get_ptam_config(dcrr_src_env_id,dmda_mr->env_id)
   SET dcrr_new_dual_build_setting = drcr_get_dual_build_config(dcrr_src_env_id,dmda_mr->env_id)
   WHILE (dcrr_continue_ind=1)
     CALL clear(3,1,132)
     CALL text(3,40,"***  Configure RDDS Relationship ***")
     CALL clear(9,1)
     CALL text(9,3,concat("Configuration for relationship with ",trim(dcrr_src_env_name)," (",trim(
        cnvtstring(dcrr_src_env_id)),"):"))
     CALL text(11,40,"Current Settings")
     CALL text(12,40,fillstring(40,"-"))
     CALL text(13,3,"1) Cutover")
     CALL text(14,3,"2) Dual Build")
     CALL text(15,3,"3) Pending Target as Master")
     CALL text(13,40,drcr_get_config_text("CUTOVER",dcrr_orig_cutover_setting))
     CALL text(14,40,drcr_get_config_text("DUAL BUILD",dcrr_orig_dual_build_setting))
     CALL text(15,40,drcr_get_config_text("PTAM",dcrr_orig_ptam_setting))
     IF (dcrr_new_setting_ind=1)
      CALL text(11,80,"Pending Settings")
      CALL text(12,80,fillstring(40,"-"))
      CALL text(13,80,drcr_get_config_text("CUTOVER",dcrr_new_cutover_setting))
      CALL text(14,80,drcr_get_config_text("DUAL BUILD",dcrr_new_dual_build_setting))
      CALL text(15,80,drcr_get_config_text("PTAM",dcrr_new_ptam_setting))
     ENDIF
     CALL text(18,3,"Choose which setting to change (0 to exit):")
     CALL accept(18,50,"9",0
      WHERE curaccept IN (1, 2, 3, 0))
     CASE (curaccept)
      OF 1:
       SET dcrr_new_cutover_setting = dmda_config_cutover(dcrr_src_env_id)
       IF (dcrr_new_cutover_setting != dcrr_orig_cutover_setting)
        SET dcrr_new_setting_ind = 1
       ENDIF
      OF 2:
       SET dcrr_new_dual_build_setting = dmda_config_dual_build(dcrr_src_env_id,dcrr_new_ptam_setting
        )
       IF (dcrr_new_dual_build_setting != dcrr_orig_dual_build_setting)
        SET dcrr_new_setting_ind = 1
       ENDIF
      OF 3:
       SET dcrr_new_ptam_setting = dmda_config_ptam(dcrr_src_env_id,dcrr_new_dual_build_setting)
       IF (dcrr_new_ptam_setting != dcrr_orig_ptam_setting)
        SET dcrr_new_setting_ind = 1
       ENDIF
      OF 0:
       SET dcrr_continue_ind = 0
       IF (dcrr_new_cutover_setting=dcrr_orig_cutover_setting
        AND dcrr_new_dual_build_setting=dcrr_orig_dual_build_setting
        AND dcrr_new_ptam_setting=dcrr_orig_ptam_setting)
        ROLLBACK
       ELSE
        CALL clear(9,1)
        CALL text(9,3,concat("New configuration for relationship with ",trim(dcrr_src_env_name)," (",
          trim(cnvtstring(dcrr_src_env_id)),"):"))
        CALL text(11,40,"Old Settings")
        CALL text(11,80,"New Settings")
        CALL text(12,40,fillstring(80,"-"))
        CALL text(13,3,"1) Cutover")
        CALL text(14,3,"2) Dual Build")
        CALL text(15,3,"3) Pending Target as Master")
        CALL text(13,40,drcr_get_config_text("CUTOVER",dcrr_orig_cutover_setting))
        CALL text(14,40,drcr_get_config_text("DUAL BUILD",dcrr_orig_dual_build_setting))
        CALL text(15,40,drcr_get_config_text("PTAM",dcrr_orig_ptam_setting))
        CALL text(13,80,drcr_get_config_text("CUTOVER",dcrr_new_cutover_setting))
        CALL text(14,80,drcr_get_config_text("DUAL BUILD",dcrr_new_dual_build_setting))
        CALL text(15,80,drcr_get_config_text("PTAM",dcrr_new_ptam_setting))
        IF (dcrr_new_dual_build_setting=0
         AND dcrr_new_cutover_setting=0)
         CALL text(18,3,concat("WARNING!: Auto Cutover will not proceed if a possible Dual Build",
           " scenario is detected, manual acknowledgement required."))
        ENDIF
        CALL text(21,3,"Accept these changes? [(Y)es, (N)o]")
        CALL accept(21,40,"P;CU","Y"
         WHERE curaccept IN ("Y", "N"))
        CASE (curaccept)
         OF "Y":
          IF (dcrr_new_dual_build_setting != dcrr_orig_dual_build_setting)
           IF (dcrr_src_env_id=dmda_get_oe_src_id(dmda_mr->env_id))
            EXECUTE dm_refchg_dual_build_reject dcrr_new_dual_build_setting
            IF (check_error(dm_err->eproc) != 0)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             SET readme_data->status = "F"
             SET readme_data->message = dm_err->emsg
             GO TO exit_program
            ENDIF
            SET stat = alterlist(auto_ver_request->qual,1)
            SET auto_ver_request->qual[1].rdds_event = "Dual Build Trigger Change"
            SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
            SET auto_ver_request->qual[1].paired_environment_id = dcrr_src_env_id
            SET auto_ver_request->qual[1].event_reason = "RDDS Menu Setting Change"
            SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
            SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt =
            "Compile DM_REFCHG_DUAL_BUILD_REJECT"
            SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = ""
            SET auto_ver_request->qual[1].detail_qual[1].event_value = dcrr_new_dual_build_setting
            EXECUTE dm_rmc_auto_verify_setup
            IF ((auto_ver_reply->status="F"))
             ROLLBACK
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             GO TO exit_program
            ELSE
             COMMIT
            ENDIF
           ENDIF
           SET dm_err->eproc =
           "Deleting DM_ENV_RELTN for the Dual Build setting and adding an Event row."
           IF (dcrr_orig_dual_build_setting > 0)
            SET stat = alterlist(derd_request->env_list,1)
            SET dera_request->child_env_id = dmda_mr->env_id
            SET dera_request->env_list[1].parent_env_id = dcrr_src_env_id
            SET dera_request->env_list[1].child_env_id = dmda_mr->env_id
            SET derd_request->env_list[1].relationship_type = drcr_get_config_text("DUAL BUILD",
             dcrr_orig_dual_build_setting)
            EXECUTE dm_del_env_reltn
           ENDIF
           SET dm_err->eproc = "Adding DM_ENV_RELTN and Event row for the Dual Build setting."
           SET stat = alterlist(dera_request->env_list,1)
           SET dera_request->child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].parent_env_id = dcrr_src_env_id
           SET dera_request->env_list[1].child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].relationship_type = drcr_get_config_text("DUAL BUILD",
            dcrr_new_dual_build_setting)
           SET dera_request->env_list[1].event_reason = "Menu Trigger Change"
           EXECUTE dm_add_env_reltn
           SET stat = alterlist(dera_request->env_list,0)
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            SET dm_err->err_ind = 1
            GO TO exit_program
           ENDIF
          ENDIF
          IF (dcrr_new_cutover_setting != dcrr_orig_cutover_setting)
           SET dm_err->eproc =
           "Deleting DM_ENV_RELTN for the Cutover setting and adding an Event row."
           IF (dcrr_orig_cutover_setting > 0)
            SET stat = alterlist(derd_request->env_list,1)
            SET dera_request->child_env_id = dmda_mr->env_id
            SET dera_request->env_list[1].parent_env_id = dcrr_src_env_id
            SET dera_request->env_list[1].child_env_id = dmda_mr->env_id
            SET derd_request->env_list[1].relationship_type = drcr_get_config_text("CUTOVER",
             dcrr_orig_cutover_setting)
            EXECUTE dm_del_env_reltn
           ENDIF
           SET dm_err->eproc = "Adding DM_ENV_RELTN and Event row for the Cutover setting."
           SET stat = alterlist(dera_request->env_list,1)
           SET dera_request->child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].parent_env_id = dcrr_src_env_id
           SET dera_request->env_list[1].child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].relationship_type = drcr_get_config_text("CUTOVER",
            dcrr_new_cutover_setting)
           EXECUTE dm_add_env_reltn
           SET stat = alterlist(dera_request->env_list,0)
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            SET dm_err->err_ind = 1
            GO TO exit_program
           ENDIF
          ENDIF
          IF (dcrr_new_ptam_setting != dcrr_orig_ptam_setting)
           SET dm_err->eproc = "Deleting DM_ENV_RELTN for the PTAM setting and adding an Event row."
           IF (dcrr_orig_cutover_setting > 0)
            SET stat = alterlist(derd_request->env_list,1)
            SET dera_request->child_env_id = dmda_mr->env_id
            SET dera_request->env_list[1].parent_env_id = dcrr_src_env_id
            SET dera_request->env_list[1].child_env_id = dmda_mr->env_id
            SET derd_request->env_list[1].relationship_type = drcr_get_config_text("PTAM",
             dcrr_orig_ptam_setting)
            EXECUTE dm_del_env_reltn
           ENDIF
           SET dm_err->eproc = "Adding DM_ENV_RELTN and Event row for the PTAM setting."
           SET stat = alterlist(dera_request->env_list,1)
           SET dera_request->child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].parent_env_id = dcrr_src_env_id
           SET dera_request->env_list[1].child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].relationship_type = drcr_get_config_text("PTAM",
            dcrr_new_ptam_setting)
           EXECUTE dm_add_env_reltn
           SET stat = alterlist(dera_request->env_list,0)
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            SET dm_err->err_ind = 1
            GO TO exit_program
           ENDIF
          ENDIF
          COMMIT
         OF "N":
          ROLLBACK
        ENDCASE
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_config_cutover(i_source_env_id)
   DECLARE dcc_src_env_name = vc WITH protect, noconstant("")
   DECLARE dcc_current_setting = i2 WITH protect, noconstant(- (2))
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Merge and Cutover Auto/Planned Configuration ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   SELECT INTO "nl:"
    FROM dm_environment d
    WHERE d.environment_id=i_source_env_id
    DETAIL
     dcc_src_env_name = d.environment_name
    WITH nocounter
   ;end select
   SET dcc_current_setting = drcr_get_cutover_config(i_source_env_id,dmda_mr->env_id)
   CALL text(9,3,concat("Current Cutover Configuration for relationship with source environment ",
     trim(dcc_src_env_name),":  ",trim(drcr_get_config_text("CUTOVER",dcc_current_setting))))
   CALL text(14,3,"Should this relationship be configured for Auto-cutover or Planned cutover? ")
   CALL text(14,80,"[(A)uto-cutover / (P)lanned cutover / e(X)it]")
   CALL accept(14,126,"P;CU","_"
    WHERE curaccept IN ("A", "P", "X"))
   CASE (curaccept)
    OF "A":
     RETURN(0)
    OF "P":
     RETURN(1)
    OF "X":
     RETURN(dcc_current_setting)
   ENDCASE
 END ;Subroutine
 SUBROUTINE dmda_config_dual_build(i_source_env_id,i_ptam_cfg)
   DECLARE dcdb_src_env_name = vc WITH protect, noconstant("")
   DECLARE dcdb_current_setting = i2 WITH protect, noconstant(- (2))
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,7,132)
   CALL text(3,50,"***  Dual Build Configuration ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   SELECT INTO "nl:"
    FROM dm_environment d
    WHERE d.environment_id=i_source_env_id
    DETAIL
     dcdb_src_env_name = d.environment_name
    WITH nocounter
   ;end select
   SET dcdb_current_setting = drcr_get_dual_build_config(i_source_env_id,dmda_mr->env_id)
   IF (i_ptam_cfg=1)
    CALL text(13,5,concat(
      "WARNING!: This domain cannot be configured to block dual build while it is "))
    CALL text(14,14,"already setup as a Pending Target as Master environment.")
    CALL text(16,20,"Press ENTER to return to the previous menu.")
    CALL accept(16,64,"P;E"," ")
    RETURN(dcdb_current_setting)
   ENDIF
   CALL text(9,3,concat("Current Dual Build Configuration for relationship with source environment ",
     trim(dcdb_src_env_name),":  ",trim(drcr_get_config_text("DUAL BUILD",dcdb_current_setting))))
   CALL text(14,3,
    "Should this relationship be configured for RDDS triggers to block dual build? [(Y)es, (N)o, e(X)it]"
    )
   CALL accept(14,105,"P;CU","Y"
    WHERE curaccept IN ("Y", "N", "X"))
   CASE (curaccept)
    OF "Y":
     RETURN(1)
    OF "N":
     RETURN(0)
    OF "X":
     RETURN(dcdb_current_setting)
   ENDCASE
 END ;Subroutine
 SUBROUTINE dmda_config_ptam(i_source_env_id,i_dual_build_cfg)
   DECLARE dcp_src_env_name = vc WITH protect, noconstant("")
   DECLARE dcp_current_setting = i2 WITH protect, noconstant(- (2))
   DECLARE dcp_reverse_setting = i2 WITH protect, noconstant(- (2))
   DECLARE dcp_open_event = i2 WITH protect, noconstant(- (2))
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Pending Target as Mater Configuration ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   SET dcp_current_setting = drcr_get_ptam_config(i_source_env_id,dmda_mr->env_id)
   IF (drcr_get_full_circle_config(i_source_env_id,dmda_mr->env_id)=0)
    CALL text(13,20,
     "Only domains in a full circle relationship can be configured as pending target as master.")
    CALL text(15,20,"Press ENTER to return to the previous menu.")
    CALL accept(15,64,"P;E"," ")
    RETURN(dcp_current_setting)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment d
    WHERE d.environment_id=i_source_env_id
    DETAIL
     dcp_src_env_name = d.environment_name
    WITH nocounter
   ;end select
   SET dcp_reverse_setting = drcr_get_ptam_config(dmda_mr->env_id,i_source_env_id)
   IF (dcp_reverse_setting=1)
    CALL text(13,3,concat("The other domain in the relationship (",trim(dcp_drc_env_name),
      ") is already configured as pending target as master.  "))
    CALL text(14,3,"Only one domain in a relationship can be designated as pending target as master."
     )
    CALL text(16,20,"Press ENTER to return to the previous menu.")
    CALL accept(16,64,"P;E"," ")
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking for open events"
   SET dcp_open_event = check_open_event(dmda_mr->env_id,i_source_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (dcp_open_event=1)
    CALL text(13,3,
     "There is currently an open event between these domains so pending target as master configuration is"
     )
    CALL text(14,3,
     "not an option.  All open events must be closed before pending target as master can be configured."
     )
    CALL text(16,20,"Press ENTER to return to the previous menu.")
    CALL accept(16,64,"P;E"," ")
    RETURN(dcp_current_setting)
   ENDIF
   IF (i_dual_build_cfg=1)
    CALL text(13,5,concat("WARNING!: This domain cannot be configured as a Master domain while the ")
     )
    CALL text(14,16,"Dual Build Triggers are configured as BLOCKING.")
    CALL text(16,20,"Press ENTER to return to the previous menu.")
    CALL accept(16,64,"P;E"," ")
    RETURN(0)
   ENDIF
   CALL text(9,3,concat(
     "Current Pending Target as Master Configuration for relationship with source environment ",trim(
      dcp_src_env_name),":  ",trim(drcr_get_config_text("DUAL BUILD",dcp_current_setting))))
   CALL text(14,3,concat("Should reference changes built in ",trim(dmda_mr->env_name,3),
     " be treated as MASTER so that changes merged from "))
   CALL text(15,3,concat(dcp_src_env_name," will not overwrite? "))
   CALL text(15,35,"[(Y)es / (N)o / e(X)it]")
   CALL accept(15,60,"P;CU","_"
    WHERE curaccept IN ("Y", "N", "X"))
   CASE (curaccept)
    OF "Y":
     RETURN(1)
    OF "N":
     RETURN(0)
    OF "X":
     RETURN(dcp_current_setting)
   ENDCASE
 END ;Subroutine
 SUBROUTINE dmda_val_post_domain_copy(null)
   DECLARE dmpdc_str_link = vc WITH protect, noconstant("")
   DECLARE dmpdc_src_db_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmpdc_tgt_db_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmpdc_src_db_name = vc WITH protect, noconstant("")
   DECLARE dmpdc_tgt_db_name = vc WITH protect, noconstant("")
   DECLARE dmpdc_dblink_ind = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_verify_link_ind = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_db_id_verify_ind = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_env_id_verify_ind = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_rdl_validation_ind = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_det_dt_tm = dq8 WITH protect
   DECLARE dmpdc_tgt_invalid_trig_cnt = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_src_invalid_trig_cnt = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_tgt_valid_trig_cnt = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_src_valid_trig_cnt = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_tgt_detail_row_cnt = i2 WITH protect, noconstant(- (1))
   DECLARE dmpdc_src_detail_row_cnt = i2 WITH protect, noconstant(- (1))
   DECLARE dmda_trigger_flag = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_src_env_name = vc WITH protect, noconstant("")
   DECLARE dmpdc_tgt_env_name = vc WITH protect, noconstant("")
   DECLARE dmpdc_rpt_msg_line1 = vc WITH protect, noconstant("")
   DECLARE dmpdc_rpt_msg_line2 = vc WITH protect, noconstant("")
   DECLARE dmpdc_rpt_msg_line3 = vc WITH protect, noconstant("")
   DECLARE dmpdc_seqmatch_link = vc WITH protect, noconstant("")
   DECLARE dmpdc_seqmatch_src = vc WITH protect, noconstant("")
   DECLARE dmpdc_src_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmpdc_mock_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmpdc_parent_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmpdc_child_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmpdc_build_source_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmpdc_build_source_env_name = vc WITH protect, noconstant("")
   DECLARE dmpdc_temp_str = vc WITH protect, noconstant("")
   DECLARE dmpdc_flex_source_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmpdc_er_row_cnt = i2 WITH protect, noconstant(0)
   DECLARE dmpdc_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dmpdc_realm = vc WITH protect, noconstant("")
   DECLARE dmpdc_reltn_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dmpdc_parent_envs
   RECORD dmpdc_parent_envs(
     1 qual[*]
       2 parent_env_id = f8
       2 parent_env_name = vc
   )
   SELECT INTO "nl:"
    d.info_number
    FROM dm_info d
    WHERE d.info_domain="RDDS REPLICATE INFO"
     AND d.info_name="DOMAIN REPLICATE SOURCE"
    DETAIL
     rdds_setup_info->list[1].source_env_id = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET dmpdc_rdl_validation_ind = 0
    CALL clear(1,1)
    CALL text(15,20,
     "This domain was either not replicated or replication validation is not possible.")
    CALL text(17,20,"Press ENTER to return to the previous menu.")
    CALL accept(18,64,"P;E"," ")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    d.info_char
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND d.info_char=concat(trim(cnvtstring(rdds_setup_info->list[1].target_env_id)),".0")
    DETAIL
     IF (d.info_name="RDDS_MOCK_ENV_ID")
      dmpdc_mock_env_id = d.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET dmpdc_rdl_validation_ind = 0
    CALL clear(1,1)
    CALL text(15,20,"The MOCK environment id info does not appear to be setup correctly.")
    CALL text(16,20,"Access the RDDS menu option 'Manage Post Domain Copy' (option 5) and then ")
    CALL text(17,20,"'Setup RDDS Post Domain Copy' (option 1) to begin MOCK setup.")
    CALL text(19,20,"Press ENTER to return to the previous menu.")
    CALL accept(20,64,"P;E"," ")
    RETURN
   ENDIF
   IF (dmpdc_mock_env_id > 0)
    SELECT INTO "nl:"
     FROM dm_env_reltn d,
      dm_environment de
     WHERE (d.child_env_id=rdds_setup_info->list[1].target_env_id)
      AND d.relationship_type="REFERENCE MERGE"
      AND (d.parent_env_id != rdds_setup_info->list[1].source_env_id)
      AND d.parent_env_id=de.environment_id
      AND de.environment_name != "OLD <*"
      AND  EXISTS (
     (SELECT
      "x"
      FROM dm_env_reltn d1
      WHERE d1.child_env_id=dmpdc_mock_env_id
       AND d1.parent_env_id=d.parent_env_id
       AND d1.relationship_type="REFERENCE MERGE"))
     DETAIL
      dmpdc_build_source_env_id = d.parent_env_id, dmpdc_reltn_cnt = (dmpdc_reltn_cnt+ 1), stat =
      alterlist(dmpdc_parent_envs->qual,dmpdc_reltn_cnt),
      dmpdc_parent_envs->qual[dmpdc_reltn_cnt].parent_env_id = d.parent_env_id, dmpdc_parent_envs->
      qual[dmpdc_reltn_cnt].parent_env_name = de.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (dmpdc_reltn_cnt > 1)
     SET dmpdc_rdl_validation_ind = 0
     CALL clear(1,1)
     CALL text(5,20,
      "We have detected the following possibilities for a BUILD SOURCE environment to use for this Mock merge."
      )
     CALL text(6,20,
      "If one of the listed environments is from a prior merge and hasn't been cleaned up, please follow the"
      )
     CALL text(7,20,
      "instructions in the RDDS User Guide document to clean up the old merge relationship. If the ")
     CALL text(8,20,
      "environments listed are valid, please log an SR to the SWx Database Architecture queue.")
     CALL text(10,20,"Environment ID           Environment Name")
     FOR (dmpdc_reltn_cnt = 1 TO size(dmpdc_parent_envs->qual,5))
      SET dmpdc_line_cnt = (dmpdc_reltn_cnt+ 10)
      IF (dmpdc_line_cnt < 21)
       CALL text(dmpdc_line_cnt,20,cnvtstring(dmpdc_parent_envs->qual[dmpdc_reltn_cnt].parent_env_id,
         20,1))
       CALL text(dmpdc_line_cnt,45,dmpdc_parent_envs->qual[dmpdc_reltn_cnt].parent_env_name)
      ENDIF
     ENDFOR
     CALL text(23,20,"Press ENTER to return to the previous menu.")
     CALL accept(23,64,"P;E"," ")
     RETURN
    ENDIF
    SELECT INTO "nl:"
     d.environment_name
     FROM dm_environment d
     WHERE d.environment_id=dmpdc_build_source_env_id
     DETAIL
      dmpdc_build_source_env_name = d.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET dmpdc_flex_source_id = dmpdc_build_source_env_id
   ELSE
    SET dmpdc_flex_source_id = rdds_setup_info->list[1].source_env_id
   ENDIF
   IF ((rdds_setup_info->list[1].source_env_id > 0.0))
    SELECT INTO "nl:"
     d.environment_name
     FROM dm_environment d
     WHERE (d.environment_id=rdds_setup_info->list[1].source_env_id)
     DETAIL
      rdds_setup_info->list[1].source_env_name = d.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE (drel.cur_environment_id=rdds_setup_info->list[1].target_env_id)
      AND drel.paired_environment_id=dmpdc_flex_source_id
      AND drel.rdds_event_key="CREATINGDBLINK"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual > 0)
     SET dmpdc_dblink_ind = 1
     SET dmpdc_str_link = concat("@MERGE",trim(cnvtstring(dmpdc_flex_source_id)),trim(cnvtstring(
        rdds_setup_info->list[1].target_env_id)))
     SELECT INTO "nl:"
      udl.db_link
      FROM user_db_links udl
      WHERE udl.db_link=patstring(concat("MERGE",trim(cnvtstring(dmpdc_flex_source_id)),trim(
         cnvtstring(rdds_setup_info->list[1].target_env_id)),".*"))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (curqual > 0)
      SET dmpdc_verify_link_ind = 1
      SELECT INTO "nl:"
       v.dbid
       FROM v$database v
       DETAIL
        dmpdc_tgt_db_id = v.dbid, dmpdc_tgt_db_name = v.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      SELECT INTO "nl:"
       v.dbid
       FROM (parser(concat("v$database",dmpdc_str_link)) v)
       DETAIL
        dmpdc_src_db_id = v.dbid, dmpdc_src_db_name = v.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       CALL clear(8,1)
       CALL text(15,3,concat("Database link ",dmpdc_str_link,
         " error. Please verify TNS names and remote database are functioning."))
       CALL text(16,3,dm_err->emsg)
       CALL text(17,20,"Press ENTER to return to the previous menu.")
       CALL accept(17,64,"P;E"," ")
       GO TO exit_program
      ENDIF
      IF (((dmpdc_tgt_db_id != dmpdc_src_db_id) OR (dmpdc_tgt_db_name != dmpdc_src_db_name)) )
       SET dmpdc_db_id_verify_ind = 1
       SELECT INTO "nl:"
        d.info_number
        FROM (parser(concat("dm_info",dmpdc_str_link)) d)
        WHERE d.info_domain="DATA MANAGEMENT"
         AND d.info_name="DM_ENV_ID"
        DETAIL
         dmpdc_src_id = d.info_number
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (dmpdc_src_id=dmpdc_flex_source_id)
        SET dmpdc_env_id_verify_ind = 1
       ELSE
        SELECT INTO "nl:"
         FROM dm_environment d
         WHERE d.environment_id=dmpdc_src_id
         DETAIL
          dmpdc_src_env_name = d.environment_name
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        CALL clear(8,1)
        CALL text(15,3,build("Database link ",dmpdc_str_link," points to unexpected environment ",
          dmpdc_src_env_name," (",
          dmpdc_src_id,")."))
        CALL text(16,3,"Please run 'Setup RDDS Post Domain Copy'.")
        CALL text(17,20,"Press ENTER to return to the previous menu.")
        CALL accept(17,64,"P;E"," ")
        SET dmpdc_env_id_verify_ind = 0
       ENDIF
      ELSE
       SET dmpdc_db_id_verify_ind = 0
      ENDIF
     ELSE
      CALL clear(8,1)
      CALL text(15,3,concat("Database link ",dmpdc_str_link," not found in DBA_DB_LINKS."))
      CALL text(16,3,"Please run 'Setup RDDS Post Domain Copy.")
      CALL text(17,20,"Press ENTER to return to the previous menu.")
      CALL accept(17,64,"P;E"," ")
      SET dmpdc_verify_link_ind = 0
     ENDIF
    ELSE
     SET dmpdc_dblink_ind = 0
    ENDIF
   ELSE
    SET dmpdc_rep_src = 0.0
   ENDIF
   IF (((dmpdc_env_id_verify_ind=1) OR (dmpdc_rdl_validation_ind=1)) )
    SELECT INTO "nl:"
     FROM dm_env_reltn der
     WHERE der.parent_env_id=dmpdc_flex_source_id
      AND (der.child_env_id=rdds_setup_info->list[1].target_env_id)
      AND der.relationship_type="REFERENCE MERGE"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual > 0)
     SET rdds_setup_info->list[1].target_reltn_str = "Yes"
    ELSE
     SET rdds_setup_info->list[1].target_reltn_str = "No"
    ENDIF
    SELECT INTO "nl:"
     FROM dm_env_reltn der
     WHERE (der.parent_env_id=rdds_setup_info->list[1].target_env_id)
      AND der.child_env_id=dmpdc_flex_source_id
      AND der.relationship_type="REFERENCE MERGE"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    IF (curqual > 0)
     SET rdds_setup_info->list[1].source_reltn_str = "Yes"
    ELSE
     SET rdds_setup_info->list[1].source_reltn_str = "No"
    ENDIF
    IF (dmpdc_mock_env_id > 0)
     SET dmpdc_parent_id = rdds_setup_info->list[1].target_env_id
     SET dmpdc_child_id = dmpdc_build_source_env_id
    ELSE
     SET dmpdc_parent_id = rdds_setup_info->list[1].target_env_id
     SET dmpdc_child_id = rdds_setup_info->list[1].source_env_id
    ENDIF
    SELECT INTO "nl:"
     FROM dm_env_reltn der
     WHERE der.parent_env_id=dmpdc_child_id
      AND der.child_env_id=dmpdc_parent_id
      AND der.relationship_type="RDDS MOVER CHANGES NOT LOGGED"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual > 0)
     SET rdds_setup_info->list[1].target_fc_str = "Yes"
    ELSE
     SET rdds_setup_info->list[1].target_fc_str = "No"
    ENDIF
    SELECT INTO "nl:"
     FROM dm_env_reltn der
     WHERE der.parent_env_id=dmpdc_parent_id
      AND der.child_env_id=dmpdc_child_id
      AND der.relationship_type="RDDS MOVER CHANGES NOT LOGGED"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual > 0)
     SET rdds_setup_info->list[1].source_fc_str = "Yes"
    ELSE
     SET rdds_setup_info->list[1].source_fc_str = "No"
    ENDIF
    IF (dmpdc_mock_env_id > 0)
     SET dmpdc_parent_id = rdds_setup_info->list[1].source_env_id
     SET dmpdc_child_id = dmpdc_build_source_env_id
    ELSE
     SET dmpdc_parent_id = rdds_setup_info->list[1].target_env_id
     SET dmpdc_child_id = rdds_setup_info->list[1].source_env_id
    ENDIF
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE drel.cur_environment_id=dmpdc_parent_id
      AND drel.paired_environment_id=dmpdc_child_id
      AND drel.rdds_event_key="CREATINGSEQUENCEMATCHROW"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET dmpdc_seqmatch_link = concat("MERGE",trim(cnvtstring(dmpdc_child_id,20),3),trim(cnvtstring(
       dmpdc_parent_id,20),3),"SEQMATCH")
    SET dmpdc_seqmatch_src = concat("MERGE",trim(cnvtstring(dmpdc_parent_id,20),3),trim(cnvtstring(
       dmpdc_child_id,20),3),"SEQMATCH")
    IF (curqual >= 1)
     SELECT INTO "nl:"
      z = count(DISTINCT d.info_name)
      FROM dm_info d
      WHERE d.info_domain=dmpdc_seqmatch_link
      DETAIL
       IF (z >= 30)
        rdds_setup_info->list[1].target_seq_match_str = "Yes"
       ELSE
        rdds_setup_info->list[1].target_seq_match_str = "No"
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SET rdds_setup_info->list[1].target_seq_match_str = "No"
    ENDIF
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE drel.cur_environment_id=dmpdc_child_id
      AND drel.paired_environment_id=dmpdc_parent_id
      AND drel.rdds_event_key="CREATINGSEQUENCEMATCHROW"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual >= 1)
     SELECT INTO "nl:"
      z = count(DISTINCT d.info_name)
      FROM (parser(concat("dm_info",dmpdc_str_link)) d)
      WHERE d.info_domain=dmpdc_seqmatch_src
      DETAIL
       IF (z >= 30)
        rdds_setup_info->list[1].source_seq_match_str = "Yes"
       ELSE
        rdds_setup_info->list[1].source_seq_match_str = "No"
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SET rdds_setup_info->list[1].source_seq_match_str = "No"
    ENDIF
    IF (dmpdc_mock_env_id > 0)
     SET dmpdc_parent_id = rdds_setup_info->list[1].target_env_id
     SET dmpdc_child_id = dmpdc_build_source_env_id
    ELSE
     SET dmpdc_parent_id = rdds_setup_info->list[1].target_env_id
     SET dmpdc_child_id = rdds_setup_info->list[1].source_env_id
    ENDIF
    SELECT INTO "nl:"
     FROM dm_rdds_event_log ad
     WHERE ad.cur_environment_id=dmpdc_parent_id
      AND ad.paired_environment_id=dmpdc_child_id
      AND ad.rdds_event_key="ADDENVIRONMENTTRIGGERS"
      AND  NOT ( EXISTS (
     (SELECT
      "X"
      FROM dm_rdds_event_log drp
      WHERE drp.cur_environment_id=dmpdc_parent_id
       AND drp.paired_environment_id=dmpdc_child_id
       AND drp.rdds_event_key="DROPENVIRONMENTTRIGGERS"
       AND drp.event_dt_tm > ad.event_dt_tm)))
      AND  NOT ( EXISTS (
     (SELECT
      "X"
      FROM dm_rdds_event_log drp
      WHERE drp.cur_environment_id=dmpdc_parent_id
       AND drp.rdds_event_key="TASKQUEUEERROR"
       AND drp.event_reason IN ("REFRESH TRIGGER PROCESS")
       AND drp.event_dt_tm > ad.event_dt_tm
       AND  NOT ( EXISTS (
      (SELECT
       "X"
       FROM dm_rdds_event_log drp2
       WHERE drp2.cur_environment_id=dmpdc_parent_id
        AND drp2.rdds_event_key="TASKQUEUEFINISHED"
        AND drp2.event_reason IN ("REFRESH TRIGGER PROCESS")
        AND drp2.event_dt_tm > drp.event_dt_tm))))))
     WITH nocounter, maxqual(ad,1)
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual > 0)
     SELECT INTO "nl:"
      u.trigger_name, o.status, e.name
      FROM user_triggers u,
       user_objects o,
       user_errors e
      WHERE u.trigger_name="REFCHG*"
       AND u.trigger_name != "REFCHG*MC*"
       AND u.status="ENABLED"
       AND o.object_name=u.trigger_name
       AND o.object_type="TRIGGER"
       AND e.name=outerjoin(u.trigger_name)
      HEAD REPORT
       dmpdc_tgt_invalid_trig_cnt = 0, dmpdc_tgt_valid_trig_cnt = 0
      DETAIL
       IF (o.status="INVALID"
        AND e.name > " ")
        dmpdc_tgt_invalid_trig_cnt = (dmpdc_tgt_invalid_trig_cnt+ 1)
       ELSE
        dmpdc_tgt_valid_trig_cnt = (dmpdc_tgt_valid_trig_cnt+ 1)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     IF (dmpdc_tgt_invalid_trig_cnt=0)
      SET rdds_setup_info->list[1].target_refchg_trig_str = "Yes"
     ELSE
      SET rdds_setup_info->list[1].target_refchg_trig_str = "No"
     ENDIF
    ELSE
     SET rdds_setup_info->list[1].target_refchg_trig_str = "No"
    ENDIF
    SELECT INTO "nl:"
     FROM dm_rdds_event_log ad
     WHERE ad.cur_environment_id=dmpdc_child_id
      AND ad.paired_environment_id=dmpdc_parent_id
      AND ad.rdds_event_key="ADDENVIRONMENTTRIGGERS"
      AND  NOT ( EXISTS (
     (SELECT
      "X"
      FROM dm_rdds_event_log drp
      WHERE drp.cur_environment_id=dmpdc_child_id
       AND drp.paired_environment_id=dmpdc_parent_id
       AND drp.rdds_event_key="DROPENVIRONMENTTRIGGERS"
       AND drp.event_dt_tm > ad.event_dt_tm)))
      AND  NOT ( EXISTS (
     (SELECT
      "X"
      FROM dm_rdds_event_log drp
      WHERE drp.cur_environment_id=dmpdc_child_id
       AND drp.rdds_event_key="TASKQUEUEERROR"
       AND drp.event_reason IN ("REFRESH TRIGGER PROCESS")
       AND drp.event_dt_tm > ad.event_dt_tm
       AND  NOT ( EXISTS (
      (SELECT
       "X"
       FROM dm_rdds_event_log drp2
       WHERE drp2.cur_environment_id=dmpdc_parent_id
        AND drp2.rdds_event_key="TASKQUEUEFINISHED"
        AND drp2.event_reason IN ("REFRESH TRIGGER PROCESS")
        AND drp2.event_dt_tm > drp.event_dt_tm))))))
     WITH nocounter, maxqual(ad,1)
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    IF (curqual > 0)
     SELECT INTO "nl:"
      d.object_name, o.status
      FROM (parser(concat("user_triggers",dmpdc_str_link)) u),
       (parser(concat("user_objects",dmpdc_str_link)) o),
       (parser(concat("user_errors",dmpdc_str_link)) e)
      WHERE u.trigger_name="REFCHG*"
       AND u.trigger_name != "REFCHG*MC*"
       AND u.status="ENABLED"
       AND o.object_name=u.trigger_name
       AND o.object_type="TRIGGER"
       AND e.name=outerjoin(u.trigger_name)
      HEAD REPORT
       dmpdc_src_invalid_trig_cnt = 0, dmpdc_src_valid_trig_cnt = 0
      DETAIL
       IF (o.status="INVALID"
        AND e.name > " ")
        dmpdc_src_invalid_trig_cnt = (dmpdc_src_invalid_trig_cnt+ 1)
       ELSE
        dmpdc_src_valid_trig_cnt = (dmpdc_src_valid_trig_cnt+ 1)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     IF (dmpdc_src_invalid_trig_cnt=0)
      SET rdds_setup_info->list[1].source_refchg_trig_str = "Yes"
     ELSE
      SET rdds_setup_info->list[1].source_refchg_trig_str = "No"
     ENDIF
    ELSE
     SET rdds_setup_info->list[1].source_refchg_trig_str = "No"
    ENDIF
    IF (dmpdc_dblink_ind=1)
     SET rdds_setup_info->list[1].target_dblink_str = "Yes"
    ELSE
     SET rdds_setup_info->list[1].target_dblink_str = "No"
    ENDIF
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE drel.cur_environment_id=dmpdc_child_id
      AND drel.paired_environment_id=dmpdc_parent_id
      AND drel.rdds_event_key="CREATINGDBLINK"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual > 0)
     SET rdds_setup_info->list[1].source_dblink_str = "Yes"
    ELSE
     IF (dmpdc_mock_env_id > 0)
      SET rdds_setup_info->list[1].source_dblink_str = "N/A"
     ELSE
      SET rdds_setup_info->list[1].source_dblink_str = "No"
     ENDIF
    ENDIF
    IF (dmpdc_mock_env_id > 0)
     SET dmpdc_parent_id = rdds_setup_info->list[1].source_env_id
     SET dmpdc_child_id = dmpdc_build_source_env_id
    ELSE
     SET dmpdc_parent_id = rdds_setup_info->list[1].target_env_id
     SET dmpdc_child_id = rdds_setup_info->list[1].source_env_id
    ENDIF
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
      AND drel.cur_environment_id=dmpdc_parent_id
      AND drel.paired_environment_id=dmpdc_child_id
     DETAIL
      IF (cnvtint(drel.event_reason) > dmpdc_er_row_cnt)
       dmpdc_er_row_cnt = cnvtint(drel.event_reason)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SELECT INTO "nl:"
     y = count(DISTINCT dred.event_detail1_txt)
     FROM dm_rdds_event_detail dred,
      dm_rdds_event_log drel
     WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
      AND drel.cur_environment_id=dmpdc_parent_id
      AND drel.paired_environment_id=dmpdc_child_id
      AND dred.dm_rdds_event_log_id=drel.dm_rdds_event_log_id
     DETAIL
      dmpdc_tgt_detail_row_cnt = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (dmpdc_tgt_detail_row_cnt >= dmpdc_er_row_cnt
     AND dmpdc_tgt_detail_row_cnt > 0)
     SET rdds_setup_info->list[1].target_xlat_backfill_str = "Yes"
    ELSE
     SET rdds_setup_info->list[1].target_xlat_backfill_str = "No"
    ENDIF
    SET dmpdc_er_row_cnt = 0
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
      AND drel.cur_environment_id=dmpdc_child_id
      AND drel.paired_environment_id=dmpdc_parent_id
     DETAIL
      IF (cnvtint(drel.event_reason) > dmpdc_er_row_cnt)
       dmpdc_er_row_cnt = cnvtint(drel.event_reason)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SELECT INTO "nl:"
     y = count(DISTINCT dred.event_detail1_txt)
     FROM dm_rdds_event_detail dred,
      dm_rdds_event_log drel
     WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
      AND drel.cur_environment_id=dmpdc_child_id
      AND drel.paired_environment_id=dmpdc_parent_id
      AND dred.dm_rdds_event_log_id=drel.dm_rdds_event_log_id
     DETAIL
      dmpdc_src_detail_row_cnt = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (dmpdc_src_detail_row_cnt >= dmpdc_er_row_cnt
     AND dmpdc_src_detail_row_cnt > 0)
     SET rdds_setup_info->list[1].source_xlat_backfill_str = "Yes"
    ELSE
     SET rdds_setup_info->list[1].source_xlat_backfill_str = "No"
    ENDIF
    IF (dmpdc_mock_env_id > 0)
     SELECT INTO "nl:"
      FROM user_tables u
      WHERE table_name="EA_USER3615$R"
      WITH nocounter
     ;end select
     IF (check_error_gui(dm_err->eproc,"Manage Post Domain Copy",dmda_mr->env_name,dmda_mr->env_id)
      != 0)
      RETURN(null)
     ENDIF
     IF (curqual > 0)
      SET dmpdc_realm = drrd_get_realm(null)
      IF ((dm_err->debug_flag > 0))
       SET message = window
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,7,132)
       CALL text(3,40,"***  Manage Post Domain Copy ***")
       CALL text(5,20,"Environment Name:")
       CALL text(5,40,dmda_mr->env_name)
       CALL text(5,65,"Environment ID:")
       CALL text(5,85,cnvtstring(dmda_mr->env_id))
      ENDIF
      IF (dmpdc_realm IN ("NOPARMRETURNED", "-1"))
       SET rdds_setup_info->list[1].mock_ea_user_realm_str = "No"
      ELSE
       SET rdds_setup_info->list[1].mock_ea_user_realm_str = "Yes"
      ENDIF
     ELSE
      SET rdds_setup_info->list[1].mock_ea_user_realm_str = "Yes"
     ENDIF
    ELSE
     SET rdds_setup_info->list[1].mock_ea_user_realm_str = "Yes"
    ENDIF
    IF ((rdds_setup_info->list[1].target_reltn_str="Yes")
     AND (rdds_setup_info->list[1].source_reltn_str="Yes")
     AND (rdds_setup_info->list[1].target_fc_str="Yes")
     AND (rdds_setup_info->list[1].source_fc_str="Yes")
     AND (rdds_setup_info->list[1].target_seq_match_str="Yes")
     AND (rdds_setup_info->list[1].source_seq_match_str="Yes")
     AND (rdds_setup_info->list[1].target_refchg_trig_str="Yes")
     AND (rdds_setup_info->list[1].source_refchg_trig_str="Yes")
     AND (rdds_setup_info->list[1].target_dblink_str="Yes")
     AND (((rdds_setup_info->list[1].source_dblink_str="Yes")) OR ((rdds_setup_info->list[1].
    source_dblink_str="N/A")))
     AND (rdds_setup_info->list[1].target_xlat_backfill_str="Yes")
     AND (rdds_setup_info->list[1].source_xlat_backfill_str="Yes")
     AND (rdds_setup_info->list[1].mock_ea_user_realm_str="Yes"))
     SET rdds_setup_info->list[1].setup_summary_str = "Complete"
    ELSE
     SET rdds_setup_info->list[1].setup_summary_str = "Incomplete"
    ENDIF
    SELECT INTO mine
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      row + 1, col 40, "***  Validate RDDS Setup Post Domain Copy ***",
      row + 2, col 20, "Environment Name:",
      col 40, rdds_setup_info->list[1].target_env_name, col 65,
      "Environment ID:", col 85, rdds_setup_info->list[1].target_env_id
      IF (dmpdc_mock_env_id > 0)
       row + 1, col 40, "(RDDS-mock domain)",
       bld_source = build("(",cnvtstring(dmpdc_build_source_env_id,20,1),")"), col 67,
       "Build source: ",
       dmpdc_build_source_env_name, " ", bld_source,
       row + 1
      ELSE
       row + 2
      ENDIF
      col 3, "RDDS Setup Summary: ", col 24,
      rdds_setup_info->list[1].setup_summary_str, rep_source = build("(",cnvtstring(rdds_setup_info->
        list[1].source_env_id,20,1),")"), col 63,
      "Replicate source: ", rdds_setup_info->list[1].source_env_name, " ",
      rep_source, row + 2
      IF (dmpdc_mock_env_id > 0)
       dmpdc_tgt_env_name = concat(dmpdc_build_source_env_name," -> ",rdds_setup_info->list[1].
        target_env_name)
      ELSE
       dmpdc_tgt_env_name = concat(rdds_setup_info->list[1].source_env_name," -> ",rdds_setup_info->
        list[1].target_env_name)
      ENDIF
      col 3, dmpdc_tgt_env_name
      IF (dmpdc_mock_env_id > 0)
       dmpdc_src_env_name = concat(rdds_setup_info->list[1].target_env_name," -> ",
        dmpdc_build_source_env_name)
      ELSE
       dmpdc_src_env_name = concat(rdds_setup_info->list[1].target_env_name," -> ",rdds_setup_info->
        list[1].source_env_name)
      ENDIF
      col 70, dmpdc_src_env_name, row + 1,
      col 3, dmpdc_line_d, col 70,
      dmpdc_line_d, row + 1, col 3,
      "RDDS Domain Relationship:", col 40, rdds_setup_info->list[1].source_reltn_str,
      col 70, "RDDS Domain Relationship:", col 110,
      rdds_setup_info->list[1].target_reltn_str, row + 1, col 3,
      "Change Log Triggers:", col 40, rdds_setup_info->list[1].source_refchg_trig_str,
      col 70, "Change Log Triggers:", col 110,
      rdds_setup_info->list[1].target_refchg_trig_str, row + 1, col 3,
      "Full Circle Configuration:", col 40, rdds_setup_info->list[1].source_fc_str,
      col 70, "Full Circle Configuration:", col 110,
      rdds_setup_info->list[1].target_fc_str, row + 1, col 3,
      "Sequence Match Performed:", col 40, rdds_setup_info->list[1].source_seq_match_str,
      col 70, "Sequence Match Performed:", col 110,
      rdds_setup_info->list[1].target_seq_match_str, row + 1, col 3,
      "RDDS Database Link:", col 40, rdds_setup_info->list[1].source_dblink_str,
      col 70, "RDDS Database Link:", col 110,
      rdds_setup_info->list[1].target_dblink_str, row + 1, col 3,
      "Translation Backfill:", col 40, rdds_setup_info->list[1].source_xlat_backfill_str,
      col 70, "Translation Backfill:", col 110,
      rdds_setup_info->list[1].target_xlat_backfill_str
      IF (dmpdc_mock_env_id > 0)
       row + 1, col 3, "Registry Key Domain Found:",
       col 40, rdds_setup_info->list[1].mock_ea_user_realm_str
      ENDIF
      IF ((rdds_setup_info->list[1].target_refchg_trig_str="No"))
       row + 2, dmpdc_rpt_msg_line1 = concat("WARNING: Change logging triggers not detected in ",
        rdds_setup_info->list[1].target_env_name,
        ".  Triggers will be recreated when you return to main menu."), dmda_trigger_flag = 1,
       col 3, dmpdc_rpt_msg_line1
      ELSE
       dmda_trigger_flag = 0
      ENDIF
      IF ((rdds_setup_info->list[1].source_refchg_trig_str="No"))
       IF (dmpdc_mock_env_id > 0)
        dmpdc_temp_str = dmpdc_build_source_env_name
       ELSE
        dmpdc_temp_str = rdds_setup_info->list[1].source_env_name
       ENDIF
       row + 1, dmpdc_rpt_msg_line2 = concat("If Change Logging Triggers do not exist in ",
        dmpdc_temp_str," and RDDS use is intended, triggers will need to be immediately "), col 4,
       dmpdc_rpt_msg_line2, dmpdc_rpt_msg_line3 = concat("created in ",dmpdc_temp_str,
        ".  Refer to RDDS Setup steps for instructions."), row + 1,
       col 4, dmpdc_rpt_msg_line3
      ENDIF
      IF (dmpdc_mock_env_id > 0)
       dmpdc_rpt_msg_line1 = concat(
        "If you have not done so already, please run DM2_RDDS_COPY_UTILITY in build source domain ",
        trim(dmpdc_build_source_env_name),":",cnvtstring(dmpdc_build_source_env_id,20)), row + 2, col
        4,
       dmpdc_rpt_msg_line1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (dmda_trigger_flag=1)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  Validate RDDS Setup Post Domain Copy ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL autoadd_triggers(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE source_environment_change(null)
   CALL clear(20,1)
   CALL text(20,3,
    "This function is currently unavailable...press enter to make a different selection.")
   CALL accept(20,90,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
 END ;Subroutine
 SUBROUTINE manage_rdds_context(add_only_ind,orig_cntxt)
   DECLARE s_context_to_pull = vc WITH protect, noconstant("")
   DECLARE s_context_set = vc WITH protect, noconstant("")
   DECLARE s_user_option_main = c1 WITH protect, noconstant("")
   DECLARE s_user_option_pull = c1 WITH protect, noconstant("")
   DECLARE s_user_option_set = c1 WITH protect, noconstant("")
   DECLARE s_while_ind = i2 WITH protect, noconstant(0)
   DECLARE s_while2_ind = i2 WITH protect, noconstant(0)
   DECLARE s_str_first_100 = vc WITH protect, noconstant("")
   DECLARE s_str_format_100 = vc WITH protect, noconstant("")
   DECLARE s_str_remain = vc WITH protect, noconstant("")
   DECLARE s_col_pos = i2 WITH protect, noconstant(0)
   DECLARE s_temp_str = vc WITH protect, noconstant("")
   DECLARE s_del_str = vc WITH protect, noconstant("")
   DECLARE s_invalid_ind = i2 WITH protect, noconstant(0)
   DECLARE s_user_option_set_cont = c1 WITH protect, noconstant("")
   DECLARE s_db_link = vc WITH protect, noconstant("")
   DECLARE s_db_link_tname = vc WITH protect, noconstant("")
   DECLARE s_string_match = vc
   DECLARE s_default_context = vc
   DECLARE s_temp_str = vc
   DECLARE s_first_null = i2
   DECLARE cts_check = i2
   DECLARE s_cnt_default = vc WITH protect, noconstant("Y")
   DECLARE s_add_context_to_pull = vc WITH protect, noconstant("")
   DECLARE s_substr_line = i4 WITH protect, noconstant(0)
   DECLARE s_breakup_stop = i4 WITH protect, noconstant(0)
   DECLARE s_breakup_str_ret = vc WITH protect, noconstant("")
   DECLARE mrc_cbc_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_env_reltn d
    WHERE d.relationship_type="REFERENCE MERGE"
     AND d.parent_env_id=srm_env_id
     AND (d.child_env_id=dmda_mr->env_id)
    DETAIL
     s_db_link = trim(d.post_link_name,3)
    WITH nocounter
   ;end select
   SET s_db_link_tname = concat("DM_CHG_LOG",s_db_link)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CONTEXT"
     AND di.info_name="CONTEXTS TO PULL"
    DETAIL
     s_context_to_pull = di.info_char
    WITH nocounter
   ;end select
   SET s_while_ind = 0
   WHILE (s_while_ind=0)
     SET help =
     SELECT DISTINCT
      context_name = d.context_name
      FROM (value(s_db_link_tname) d)
      WHERE (d.target_env_id=dmda_mr->env_id)
       AND d.log_type="REFCHG"
       AND ((d.context_name > "") UNION (
      (SELECT
       "ALL"
       FROM dual
       WHERE ((1=1) UNION (
       (SELECT
        "NULL"
        FROM dual
        WHERE 1=1))) )))
      WITH nocounter
     ;end select
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,"*** Manage RDDS Context ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     IF (daf_is_not_blank(s_user_option_pull))
      SET s_user_option_main = "E"
     ELSE
      CALL text(9,3,"Current Source Context(s) to Pull:")
      CALL text(10,3,"----------------------------------")
      IF (size(s_context_to_pull,1) > 100)
       SET stat = initrec(dmda_breakup_str)
       SET dmda_breakup_str->str_text = s_context_to_pull
       SET dmda_breakup_str->str_delim = "::"
       SET dmda_breakup_str->str_delim_ind = 2
       SET dmda_breakup_str->str_limit = 100
       SET s_breakup_str_ret = drmm_breakup_string(dmda_breakup_str)
       IF (s_breakup_str_ret="S")
        IF (size(dmda_breakup_str->substr,5) >= 2)
         CALL text(11,3,trim(dmda_breakup_str->substr[1].str,3))
         CALL text(12,3,trim(dmda_breakup_str->substr[2].str,3))
         IF (size(dmda_breakup_str->substr,5) > 2)
          CALL text(14,3,'Use "View All" to display all contexts to pull for this event.')
         ENDIF
        ELSE
         CALL text(11,3,trim(dmda_breakup_str->substr[1].str,3))
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Unable to break apart CONTEXTS TO PULL string."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
      ELSE
       IF (daf_is_not_blank(s_context_to_pull))
        CALL text(11,3,s_context_to_pull)
       ELSE
        CALL text(11,3,"<NONE>")
       ENDIF
      ENDIF
      IF (add_only_ind=1)
       IF (daf_is_not_blank(orig_cntxt))
        CALL text(21,3,
         "Contexts to pull listed above are locked for the duration of the event and cannot be removed."
         )
       ENDIF
      ENDIF
      IF (daf_is_not_blank(s_context_to_pull))
       IF (size(dmda_breakup_str->substr,5) > 2)
        CALL text(15,3,"E=Edit, X=Exit, C=Continue, V=View All")
        CALL accept(16,3,"P;CU","C"
         WHERE curaccept IN ("E", "C", "X", "V"))
       ELSE
        CALL text(15,3,"E=Edit, X=Exit, C=Continue")
        CALL accept(16,3,"P;CU","C"
         WHERE curaccept IN ("E", "C", "X"))
       ENDIF
       SET s_user_option_main = curaccept
      ELSE
       CALL text(15,3,"E=Edit, X=Exit")
       CALL accept(16,3,"P;CU","E"
        WHERE curaccept IN ("E", "X"))
       SET s_user_option_main = curaccept
      ENDIF
     ENDIF
     CASE (s_user_option_main)
      OF "E":
       IF (add_only_ind=1)
        SELECT INTO "NL:"
         FROM dm_refchg_process d
         WHERE d.refchg_type="MOVER PROCESS"
          AND  EXISTS (
         (SELECT
          "X"
          FROM gv$session g
          WHERE g.audsid=d.rdbhandle_value))
         WITH nocounter
        ;end select
        IF (check_error("Check if any MOVER PROCESS is running in the current environment.") != 0)
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        IF (curqual > 0)
         SET dm_err->emsg = concat("There is currently a mover running in this environment.",
          " You cannot edit contexts to pull until all movers are stopped.")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         CALL clear(1,1)
         CALL text(15,3,concat("There is currently a mover running in this environment.",
           " You cannot edit contexts to pull until all movers are stopped."))
         CALL text(16,20,"Press ENTER to return to the previous menu.")
         CALL accept(16,64,"P;E"," ")
         SET help = off
         SET validate = off
         RETURN(2)
        ENDIF
       ENDIF
       IF (s_context_to_pull="NULL"
        AND s_first_null=0)
        SET s_user_option_pull = "E"
        SET s_first_null = 1
       ELSE
        CALL clear(8,1)
        CALL text(9,3,"Current Source Context(s) to Pull:")
        CALL text(10,3,"----------------------------------")
        IF (size(s_context_to_pull,1) > 100)
         SET stat = initrec(dmda_breakup_str)
         SET dmda_breakup_str->str_text = s_context_to_pull
         SET dmda_breakup_str->str_delim = "::"
         SET dmda_breakup_str->str_delim_ind = 2
         SET dmda_breakup_str->str_limit = 100
         SET s_breakup_str_ret = drmm_breakup_string(dmda_breakup_str)
         IF (s_breakup_str_ret="S")
          IF (size(dmda_breakup_str->substr,5) >= 2)
           CALL text(11,3,dmda_breakup_str->substr[1].str)
           CALL text(12,3,dmda_breakup_str->substr[2].str)
           IF (size(dmda_breakup_str->substr,5) > 2)
            CALL text(14,3,'Use "View All" to display all contexts to pull for this event.')
           ENDIF
          ELSE
           CALL text(11,3,dmda_breakup_str->substr[1].str)
          ENDIF
         ELSE
          SET dm_err->err_ind = 1
          SET dm_err->emsg = "Unable to break apart CONTEXTS TO PULL string."
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_program
         ENDIF
        ELSE
         IF (daf_is_not_blank(s_context_to_pull))
          CALL text(11,3,s_context_to_pull)
         ELSE
          CALL text(11,3,"<NONE>")
         ENDIF
        ENDIF
        IF (add_only_ind=1)
         IF (daf_is_not_blank(orig_cntxt))
          CALL text(21,3,
           "Contexts to pull listed above are locked for the duration of the event and cannot be removed."
           )
         ENDIF
        ENDIF
        IF (add_only_ind=0)
         IF (size(dmda_breakup_str->substr,5) > 2)
          CALL text(15,3,"R=Reset, A=Add, D=Delete, X=Exit, C=Continue, V=View All")
          CALL accept(16,3,"P;CU","C"
           WHERE curaccept IN ("R", "A", "D", "C", "X",
           "V"))
         ELSE
          CALL text(15,3,"R=Reset, A=Add, D=Delete, X=Exit, C=Continue")
          CALL accept(16,3,"P;CU","C"
           WHERE curaccept IN ("R", "A", "D", "C", "X"))
         ENDIF
        ELSE
         IF (daf_is_not_blank(s_context_to_pull))
          IF (s_context_to_pull != orig_cntxt)
           CALL text(15,3,"A=Add, X=Exit, C=Continue, R=Remove changes, V=View All")
           CALL accept(16,3,"P;CU","C"
            WHERE curaccept IN ("A", "C", "R", "X", "V"))
          ELSE
           CALL text(15,3,"A=Add, X=Exit, C=Continue, V=View All")
           CALL accept(16,3,"P;CU","C"
            WHERE curaccept IN ("A", "C", "X", "V"))
          ENDIF
         ELSE
          CALL text(15,3,"A=Add, X=Exit")
          CALL accept(16,3,"P;CU","A"
           WHERE curaccept IN ("A", "X"))
         ENDIF
        ENDIF
        SET s_user_option_pull = curaccept
        CASE (s_user_option_pull)
         OF "R":
          IF (add_only_ind=0)
           SET s_context_to_pull = "NULL"
          ELSE
           SET s_context_to_pull = orig_cntxt
          ENDIF
         OF "A":
          CALL clear(8,1)
          CALL text(9,3,"Choose a Source Context to Pull")
          CALL text(10,3,"     from the Help Menu:")
          CALL text(14,3,"Gathering contexts from source. Please wait.")
          CALL accept(12,3,"P(24);CUF")
          IF (daf_is_not_blank(s_context_to_pull))
           SET s_add_context_to_pull = trim(curaccept,3)
           IF (size(concat(s_context_to_pull,"::",s_add_context_to_pull),1) > 2000
            AND s_add_context_to_pull != "ALL")
            CALL clear(17,1)
            CALL text(17,3,concat("Warning !! Adding context ",s_add_context_to_pull,
              " will exceed the length of contexts to pull allowed. !!"))
            CALL text(18,3,"Press enter to continue")
            CALL accept(18,30,"P;E"," ")
           ELSE
            SET s_context_to_pull = concat(s_add_context_to_pull,"::",s_context_to_pull)
           ENDIF
          ELSE
           SET s_context_to_pull = trim(curaccept,3)
          ENDIF
          IF (findstring(":ALL:",concat(":",s_context_to_pull,":")) > 0)
           SET s_context_to_pull = "ALL"
          ENDIF
         OF "E":
          CALL clear(8,1)
          CALL text(9,3,"Choose a Source Context to Pull")
          CALL text(10,3,"     from the Help Menu:")
          CALL accept(12,3,"P(24);CUF")
          SET s_context_to_pull = trim(curaccept,3)
         OF "D":
          CALL clear(8,1)
          CALL text(9,3,"Choose a Source Context to Pull ")
          CALL text(10,3," from the Help Menu to Delete:")
          SET s_temp_str = replace(s_context_to_pull,"::",",")
          SET help = fix(value(s_temp_str))
          CALL accept(12,3,"P(24);CF")
          SET s_del_str = trim(curaccept,3)
          SET s_del_str = concat("|",trim(replace(concat("::",s_context_to_pull,"::"),concat(":",
              s_del_str,":"),""),3),"|")
          SET s_del_str = replace(s_del_str,"::::","::")
          SET s_del_str = replace(s_del_str,"|::","")
          SET s_del_str = replace(s_del_str,"::|","")
          SET s_del_str = replace(s_del_str,"|","")
          SET s_context_to_pull = trim(s_del_str,3)
         OF "C":
          IF (daf_is_blank(s_context_to_pull))
           SET s_context_to_pull = "NULL"
          ENDIF
         OF "X":
          RETURN(2)
         OF "V":
          SET message = nowindow
          SELECT INTO mine
           contexts_to_pull = s_context_to_pull
           FROM dual
           WITH nocounter
          ;end select
          SET message = window
        ENDCASE
       ENDIF
      OF "C":
       IF (daf_is_blank(s_context_to_pull))
        SET s_context_to_pull = "NULL"
       ENDIF
      OF "X":
       RETURN(2)
      OF "V":
       SET message = nowindow
       SELECT INTO mine
        contexts_to_pull = s_context_to_pull
        FROM dual
        WITH nocounter
       ;end select
       SET message = window
     ENDCASE
     IF (((s_user_option_main="C") OR (s_user_option_pull="C")) )
      CALL clear(17,1)
      IF (s_context_to_pull != orig_cntxt
       AND add_only_ind=1)
       CALL text(17,3,concat(
         "Warning: The newly added contexts to pull cannot be changed after starting movers ",
         "without first closing the event."))
       SET s_cnt_default = " "
      ENDIF
      CALL text(18,3,"Are you sure that you would like to continue with the chosen contexts to pull?"
       )
      CALL text(19,3,"[(Y)es / (N)o / e(X)it]")
      CALL accept(21,3,"P;CU",s_cnt_default
       WHERE curaccept IN ("Y", "N", "X"))
      CASE (curaccept)
       OF "N":
        SET s_while_ind = 0
       OF "X":
        RETURN(2)
       OF "Y":
        SET s_while_ind = 1
      ENDCASE
     ENDIF
   ENDWHILE
   UPDATE  FROM dm_info di
    SET di.info_char = trim(s_context_to_pull,3), di.updt_applctx = reqinfo->updt_applctx, di
     .updt_cnt = (di.updt_cnt+ 1),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
     reqinfo->updt_task
    WHERE di.info_domain="RDDS CONTEXT"
     AND di.info_name="CONTEXTS TO PULL"
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXTS TO PULL", di.info_char = trim(
       s_context_to_pull,3),
      di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error("Can not load RDDS 'Contexts to Pull' DM_INFO row") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET s_while_ind = 1
   ELSE
    COMMIT
   ENDIF
   IF ((dm_err->err_ind > 0))
    SET s_while_ind = 1
   ENDIF
   SET help = off
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   SET s_string_match = "*::*"
   SET mrc_cbc_ind = dcs_check_cbc(null)
   IF (((s_context_to_pull=patstring(s_string_match)) OR (s_context_to_pull="ALL")) )
    IF (mrc_cbc_ind=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,45,"*** Group or Maintain Context ***")
     CALL text(9,3,
      "Do you want the Merge and Cutover process to maintain each individual context to pull in the target domain?"
      )
     CALL text(11,3,
      "Answering 'Y' will make sure that each context name being pulled in this merge is applied one at a time to"
      )
     CALL text(12,3,
      "the target domain, allowing you to pull these context names individually again into the next domain."
      )
     CALL text(14,3,
      "Answering 'N' will group all the context names being pulled into one new context name in the target domain,"
      )
     CALL text(15,3,
      "only allowing you to pull all of these context names together into the next domain using the")
     CALL text(16,3,"single new context name (context to set).")
     CALL text(18,20,"(Y/N)")
     CALL accept(18,40,"A;CU",""
      WHERE curaccept IN ("Y", "N"))
    ELSE
     SET curaccept = "Y"
    ENDIF
    IF (curaccept="N")
     UPDATE  FROM dm_info di
      SET di.info_number = 1, di.updt_id = reqinfo->updt_id, di.updt_cnt = (di.updt_cnt+ 1),
       di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_task = reqinfo->updt_task, di
       .updt_applctx = reqinfo->updt_applctx
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="CONTEXT GROUP_IND"
      WITH nocounter
     ;end update
     IF (check_error("Can not modify CONTEXT GROUP_IND") != 0)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXT GROUP_IND", di.info_number = 1,
        di.info_long_id = 0, di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0,
        di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_id = reqinfo->updt_id, di.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (check_error("Can not add CONTEXT GROUP_IND") != 0)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
     ENDIF
     SET cts_check = manage_context_to_set(s_context_to_pull)
     IF (cts_check=2)
      IF ((dm_err->err_ind > 0))
       RETURN(0)
      ELSE
       RETURN(2)
      ENDIF
     ENDIF
    ELSE
     UPDATE  FROM dm_info di
      SET di.info_number = 0, di.updt_id = reqinfo->updt_id, di.updt_cnt = (di.updt_cnt+ 1),
       di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_task = reqinfo->updt_task, di
       .updt_applctx = reqinfo->updt_applctx
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="CONTEXT GROUP_IND"
      WITH nocounter
     ;end update
     IF (check_error("Can not modify CONTEXT GROUP_IND") != 0)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXT GROUP_IND", di.info_number = 0,
        di.info_long_id = 0, di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0,
        di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_id = reqinfo->updt_id, di.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (check_error("Can not add CONTEXT GROUP_IND") != 0)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_char = "", di.updt_id = reqinfo->updt_id, di.updt_cnt = (di.updt_cnt+ 1),
       di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_task = reqinfo->updt_task, di
       .updt_applctx = reqinfo->updt_applctx
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="CONTEXT TO SET"
      WITH nocounter
     ;end update
     IF (check_error("Can not clear CONTEXT TO SET") != 0)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     COMMIT
     IF (((s_context_to_pull=patstring("NULL::*")) OR (((s_context_to_pull=patstring("*::NULL")) OR (
     ((s_context_to_pull=patstring("*::NULL::*")) OR (s_context_to_pull="ALL")) )) )) )
      SET s_default_context = dmda_get_default_context(s_context_to_pull)
     ENDIF
    ENDIF
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = 1, di.updt_id = reqinfo->updt_id, di.updt_cnt = (di.updt_cnt+ 1),
      di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_task = reqinfo->updt_task, di
      .updt_applctx = reqinfo->updt_applctx
     WHERE di.info_domain="RDDS CONTEXT"
      AND di.info_name="CONTEXT GROUP_IND"
     WITH nocounter
    ;end update
    IF (check_error("Can not modify CONTEXT GROUP_IND") != 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXT GROUP_IND", di.info_number = 1,
       di.info_long_id = 0, di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_id = reqinfo->updt_id, di.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (check_error("Can not add CONTEXT GROUP_IND") != 0)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
    IF (s_context_to_pull="NULL")
     SET s_default_context = dmda_get_default_context(s_context_to_pull)
     UPDATE  FROM dm_info di
      SET di.info_char = trim(s_default_context,3), di.updt_applctx = reqinfo->updt_applctx, di
       .updt_cnt = (di.updt_cnt+ 1),
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
       reqinfo->updt_task
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="CONTEXT TO SET"
      WITH nocounter
     ;end update
     IF (check_error("Cannot load RDDS 'Context to Set' DM_INFO row") != 0)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXT TO SET", di.info_char = trim(
         s_default_context,3),
        di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
     IF (check_error("Cannot load RDDS 'Context to Set' DM_INFO row") != 0)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
     ELSE
      COMMIT
     ENDIF
    ELSEIF (mrc_cbc_ind=0)
     SET cts_check = manage_context_to_set(s_context_to_pull)
     IF (cts_check=2)
      IF ((dm_err->err_ind > 0))
       RETURN(0)
      ELSE
       RETURN(2)
      ENDIF
     ENDIF
    ELSE
     UPDATE  FROM dm_info di
      SET di.info_char = trim(s_context_to_pull,3), di.updt_applctx = reqinfo->updt_applctx, di
       .updt_cnt = (di.updt_cnt+ 1),
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
       reqinfo->updt_task
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="CONTEXT TO SET"
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXT TO SET", di.info_char = trim(
         s_context_to_pull,3),
        di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
     IF (check_error("Can not load RDDS 'Context to Set' DM_INFO row") != 0)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE auto_planned_cutover(null)
   DECLARE apc_cutover_answer = vc WITH protect, noconstant("")
   DECLARE apc_default_message = vc WITH protect, noconstant("")
   DECLARE apc_new_default_message = vc WITH protect, noconstant("")
   DECLARE apc_dual_bld_setting = f8 WITH protect, noconstant(0.0)
   DECLARE apc_ptam_setting = i2 WITH protect, noconstant(0)
   DECLARE apc_tgt_env_name = vc WITH protect, noconstant("")
   DECLARE apc_db_link = vc WITH protect, noconstant("")
   DECLARE apc_continue = i2 WITH protect, noconstant(0)
   DECLARE apc_temp_return = i2 WITH protect, noconstant(0)
   CALL clear(1,1)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL parser("cclseclogin go")
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = ""
      SET dm_err->err_ind = 0
     ENDIF
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "Configuring Auto/Planned Cutover"
      SET dm_err->emsg = "User not logged in cclseclogin"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   SET apc_ptam_setting = drcr_get_ptam_config(dmda_mr->env_id,dmda_add->child_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE (de.environment_id=dmda_add->child_env_id)
    DETAIL
     apc_tgt_env_name = de.environment_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET apc_temp_return = drcr_get_cutover_config(dmda_mr->env_id,dmda_add->child_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((apc_temp_return=- (1)))
    SET apc_default_message = "NOT YET CONFIGURED FOR THIS RELATIONSHIP"
   ELSEIF (apc_temp_return=0)
    SET apc_default_message = "AUTO CUTOVER"
   ELSE
    SET apc_default_message = "PLANNED CUTOVER"
   ENDIF
   SET apc_dual_build_setting = drcr_get_dual_build_config(dmda_mr->env_id,dmda_add->child_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET apc_dual_bld_setting = 2.0
   ENDIF
   IF ((apc_dual_build_setting=- (1.0)))
    SET apc_dual_bld_setting = 2.0
   ENDIF
   WHILE (apc_continue=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Merge and Cutover Auto/Planned Confirmation ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(8,3,concat("Current Configuration for target ",apc_tgt_env_name,":",apc_db_link))
     CALL text(9,5,"Cutover Type")
     IF (apc_default_message="AUTO CUTOVER")
      IF (apc_dual_bld_setting=2.0)
       CALL text(9,48,concat("-  ",apc_default_message))
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(12,5,"PTAM SETTING")
       IF (apc_ptam_setting=1)
        CALL text(12,48,concat("-  ",apc_tgt_env_name," IS MASTER"))
       ELSEIF (apc_ptam_setting=0)
        CALL text(12,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(12,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ELSEIF (apc_dual_bld_setting=1.0)
       CALL text(9,48,concat("-  ",apc_default_message))
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NO")
       CALL text(12,5,"PTAM SETTING")
       IF (apc_ptam_setting=1)
        CALL text(12,48,concat("-  ",apc_tgt_env_name," IS MASTER"))
       ELSEIF (apc_ptam_setting=0)
        CALL text(12,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(12,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ELSE
       CALL text(9,48,concat("-  ",apc_default_message))
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  YES")
       CALL text(12,5,"PTAM SETTING")
       IF (apc_ptam_setting=1)
        CALL text(12,48,concat("-  ",apc_tgt_env_name," IS MASTER"))
       ELSEIF (apc_ptam_setting=0)
        CALL text(12,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(12,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ENDIF
     ELSE
      CALL text(9,48,concat("-  ",apc_default_message))
      IF (apc_dual_bld_setting=2.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      ELSEIF (apc_dual_bld_setting=1.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NO")
      ELSE
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  YES")
      ENDIF
      CALL text(12,5,"PTAM SETTING")
      IF (apc_ptam_setting=1)
       CALL text(12,48,concat("-  ",apc_tgt_env_name," IS MASTER"))
      ELSEIF (apc_ptam_setting=0)
       CALL text(12,48,"-  NO MASTER DOMAIN IS SET")
      ELSE
       CALL text(12,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      ENDIF
     ENDIF
     CALL text(14,3,"Should this relationship be configured for Auto-cutover or Planned cutover? ")
     CALL text(14,80,"[(A)uto-cutover / (P)lanned cutover / e(X)it]")
     CALL text(16,3,concat("WARNING: Do not setup Auto-cutover if the ",apc_tgt_env_name,
       " domain is a production environment."))
     CALL clear(17,1)
     CALL text(18,3,concat(
       "Auto-cutover can be configured to automatically start the cutover, at an appointed time, up to 3 days ",
       "in the future."))
     CALL text(19,3,concat(
       "If the Auto-cutover is scheduled for a future time, it is a requirement that any dual build be ",
       "acknowledged before selecting "))
     CALL text(20,3,concat(
       "the future date/time. Any dual build that occurs after future cutover has been setup, will ",
       "automatically be acknowledged and can"))
     CALL text(21,3,
      "be found in a report with the name of the open event. For more information see the RDDS User Guide."
      )
     CALL accept(14,126,"P;CU","_"
      WHERE curaccept IN ("A", "P", "X"))
     SET apc_cutover_answer = curaccept
     IF (apc_cutover_answer="X")
      ROLLBACK
      RETURN("N")
     ELSEIF (apc_cutover_answer="A")
      SET apc_new_default_message = "AUTO CUTOVER"
      CALL clear(14,1)
      CALL clear(15,1)
      CALL clear(16,1)
      CALL clear(17,1)
      CALL clear(18,1)
      CALL clear(19,1)
      CALL clear(20,1)
      CALL clear(21,1)
      CALL text(14,3,concat("New Configuration for target ",apc_tgt_env_name,":"))
      CALL text(15,5,"Cutover Type")
      IF (apc_dual_bld_setting=2.0)
       CALL text(15,48,concat("-  ",apc_new_default_message))
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(18,5,"PTAM SETTING")
       IF (apc_ptam_setting=1)
        CALL text(18,48,concat("-  ",apc_tgt_env_name," IS MASTER"))
       ELSEIF (apc_ptam_setting=0)
        CALL text(18,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(18,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ELSEIF (apc_dual_bld_setting=1.0)
       CALL text(15,48,concat("-  ",apc_new_default_message))
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NO")
       CALL text(18,5,"PTAM SETTING")
       IF (apc_ptam_setting=1)
        CALL text(18,48,concat("-  ",apc_tgt_env_name," IS MASTER"))
       ELSEIF (apc_ptam_setting=0)
        CALL text(18,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(18,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ELSE
       CALL text(15,48,concat("-  ",apc_new_default_message))
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  YES")
       CALL text(18,5,"PTAM SETTING")
       IF (apc_ptam_setting=1)
        CALL text(18,48,concat("-  ",apc_tgt_env_name," IS MASTER"))
       ELSEIF (apc_ptam_setting=0)
        CALL text(18,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(18,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ENDIF
     ELSE
      SET apc_new_default_message = "PLANNED CUTOVER"
      CALL clear(14,1)
      CALL clear(15,1)
      CALL clear(16,1)
      CALL clear(17,1)
      CALL clear(18,1)
      CALL clear(19,1)
      CALL text(14,3,concat("New Configuration for target ",apc_tgt_env_name,":"))
      CALL text(15,5,"Cutover Type")
      CALL text(15,48,concat("-  ",apc_new_default_message))
      IF (apc_dual_bld_setting=2.0)
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      ELSEIF (apc_dual_bld_setting=1.0)
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NO")
      ELSE
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  YES")
      ENDIF
      CALL text(18,5,"PTAM SETTING")
      IF (apc_ptam_setting=1)
       CALL text(18,48,concat("-  ",apc_tgt_env_name," IS MASTER"))
      ELSEIF (apc_ptam_setting=0)
       CALL text(18,48,"-  NO MASTER DOMAIN IS SET")
      ELSE
       CALL text(18,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      ENDIF
     ENDIF
     CALL text(21,3,"Confirm configuration changes? [(Y)es / (N)o] ")
     CALL accept(21,50,"P;CU","N"
      WHERE curaccept IN ("Y", "N"))
     SET apc_cutover_answer = curaccept
     IF (apc_cutover_answer="Y")
      SET apc_continue = 1
      SET stat = alterlist(dera_request->env_list,1)
      SET dera_request->child_env_id = dmda_add->child_env_id
      SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
      SET dera_request->env_list[1].child_env_id = dmda_add->child_env_id
      SET dera_request->env_list[1].relationship_type = apc_new_default_message
      EXECUTE dm_add_env_reltn
      RETURN(apc_cutover_answer)
     ELSE
      SET apc_continue = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE modify_environment_config(null)
   DECLARE target_env_id = f8
   DECLARE select_validate = i2 WITH protect, noconstant
   DECLARE display_confirm_reply = vc
   DECLARE mec_con = i2 WITH protect, noconstant(0)
   SET display_confirm_reply = confirm_display("SOURCE",0)
   IF (display_confirm_reply="N")
    RETURN
   ENDIF
   CALL clear(1,1)
   CALL text(3,35,"***  Select Target Environment   ***")
   CALL text(5,3,"Please input target environment id: ")
   WHILE (select_validate=0)
     CALL clear(20,01,74)
     CALL text(23,05,"HELP: Press <SHIFT><F5>  0 to exit")
     SET help =
     SELECT INTO "nl:"
      d.child_env_id, de.environment_name
      FROM dm_env_reltn d,
       dm_environment de,
       dummyt dt
      PLAN (d
       WHERE (d.parent_env_id=dmda_mr->env_id)
        AND d.relationship_type=reltn_type)
       JOIN (dt)
       JOIN (de
       WHERE de.environment_id=d.child_env_id)
      ORDER BY d.child_env_id
      WITH nocounter, outerjoin = dt
     ;end select
     CALL accept(5,70,"P(15);CU","0")
     IF (curaccept="0")
      SET select_validate = 1
      SET mec_con = 1
     ELSEIF (cnvtreal(curaccept)=0)
      CALL text(20,3,"Please input number for this field!")
      CALL pause(3)
     ELSE
      SELECT INTO "nl:"
       der.child_env_id
       FROM dm_env_reltn der
       WHERE (der.parent_env_id=dmda_mr->env_id)
        AND der.relationship_type=reltn_type
        AND der.child_env_id=cnvtreal(curaccept)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET select_validate = 1
      ELSE
       CALL clear(20,1)
       CALL text(20,3,"Invalid environment ID")
       CALL pause(3)
      ENDIF
     ENDIF
   ENDWHILE
   SET target_env_id = cnvtreal(curaccept)
   WHILE (mec_con=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Environment Configuration ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,3,"Choose from the following options: ")
     IF (cutover_flag=1)
      CALL text(11,3,"1 Configure auto cutover")
     ENDIF
     CALL text(12,3,"2 Configure pending target as master")
     CALL text(15,3,"0 Exit")
     CALL accept(9,45,"9",0
      WHERE curaccept IN (1, 2, 0))
     CASE (curaccept)
      OF 1:
       IF (cutover_flag=0)
        CALL text(20,3,"This option is not available at this time.")
        CALL pause(3)
       ELSE
        CALL auto_planned_cut_modify(target_env_id)
       ENDIF
      OF 2:
       CALL ptam_setup(target_env_id)
      OF 0:
       SET mec_con = 1
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE auto_planned_cut_modify(apcm_target_env_id)
   DECLARE apcm_modify_answer = vc WITH protect, noconstant("")
   DECLARE apcm_default_message = vc WITH protect, noconstant("")
   DECLARE apcm_new_default_message = vc WITH protect, noconstant("")
   DECLARE apcm_dual_bld_setting = f8 WITH protect, noconstant(0.0)
   DECLARE apcm_ptam_setting = i2 WITH protect, noconstant(0)
   DECLARE apcm_tgt_env_name = vc WITH protect, noconstant("")
   DECLARE apc_db_link = vc WITH protect, noconstant("")
   DECLARE apc_continue = i2 WITH protect, noconstant(0)
   DECLARE apcm_temp_return = i2 WITH protect, noconstant(0)
   CALL clear(1,1)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL parser("cclseclogin go")
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = ""
      SET dm_err->err_ind = 0
     ENDIF
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "Configuring Auto/Planned Cutover"
      SET dm_err->emsg = "User not logged in cclseclogin"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   SET apcm_ptam_setting = drcr_get_ptam_config(dmda_mr->env_id,apcm_target_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE de.environment_id=apcm_target_env_id
    DETAIL
     apcm_tgt_env_name = de.environment_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET apcm_temp_return = drcr_get_cutover_config(dmda_mr->env_id,apcm_target_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((apcm_temp_return=- (1)))
    SET apcm_default_message = "NOT YET CONFIGURED FOR THIS RELATIONSHIP"
   ELSEIF (apcm_temp_return=0)
    SET apcm_default_message = "AUTO CUTOVER"
   ELSE
    SET apcm_default_message = "PLANNED CUTOVER"
   ENDIF
   SET apcm_dual_build_setting = drcr_get_dual_build_config(dmda_mr->env_id,apcm_target_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET apcm_dual_bld_setting = 2.0
   ENDIF
   IF ((apcm_dual_build_setting=- (1.0)))
    SET apcm_dual_bld_setting = 2.0
   ENDIF
   WHILE (apc_continue=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Merge and Cutover Auto/Planned Confirmation ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(8,3,concat("Current Configuration for target ",apcm_tgt_env_name,":"))
     CALL text(9,5,"Cutover Type")
     IF (apcm_default_message="AUTO CUTOVER")
      IF (apcm_dual_bld_setting=2.0)
       CALL text(9,48,concat("-  ",apcm_default_message))
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(12,5,"PTAM SETTING")
       IF (apcm_ptam_setting=1)
        CALL text(12,48,concat("-  ",apcm_tgt_env_name," IS MASTER"))
       ELSEIF (apcm_ptam_setting=0)
        CALL text(12,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(12,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ELSEIF (apcm_dual_bld_setting=1.0)
       CALL text(9,48,concat("-  ",apcm_default_message))
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NO")
       CALL text(12,5,"PTAM SETTING")
       IF (apcm_ptam_setting=1)
        CALL text(12,48,concat("-  ",apcm_tgt_env_name," IS MASTER"))
       ELSEIF (apcm_ptam_setting=0)
        CALL text(12,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(12,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ELSEIF (apcm_dual_bld_setting=0.0)
       CALL text(9,48,concat("-  ",apcm_default_message))
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  YES")
       CALL text(12,5,"PTAM SETTING")
       IF (apcm_ptam_setting=1)
        CALL text(12,48,concat("-  ",apcm_tgt_env_name," IS MASTER"))
       ELSEIF (apcm_ptam_setting=0)
        CALL text(12,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(12,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ENDIF
     ELSE
      CALL text(9,48,concat("-  ",apcm_default_message))
      IF (apcm_dual_bld_setting=2.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      ELSEIF (apcm_dual_bld_setting=1.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NO")
      ELSEIF (apcm_dual_bld_setting=0.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  YES")
      ENDIF
      CALL text(12,5,"PTAM SETTING")
      IF (apcm_ptam_setting=1)
       CALL text(12,48,concat("-  ",apcm_tgt_env_name," IS MASTER"))
      ELSEIF (apcm_ptam_setting=0)
       CALL text(12,48,"-  NO MASTER DOMAIN IS SET")
      ELSE
       CALL text(12,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      ENDIF
     ENDIF
     CALL text(14,3,"Should this relationship be configured for Auto-cutover or Planned cutover? ")
     CALL text(14,80,"[(A)uto-cutover / (P)lanned cutover / e(X)it]")
     CALL text(16,3,concat("WARNING: Do not setup Auto-cutover if the ",apcm_tgt_env_name,
       " domain is a production environment."))
     CALL clear(17,1)
     CALL text(18,3,concat(
       "Auto-cutover can be configured to automatically start the cutover, at an appointed time, up to 3 days ",
       "in the future."))
     CALL text(19,3,concat(
       "If the Auto-cutover is scheduled for a future time, it is a requirement that any dual build be ",
       "acknowledged before selecting "))
     CALL text(20,3,concat(
       "the future date/time. Any dual build that occurs after future cutover has been setup, will ",
       "automatically be acknowledged and can"))
     CALL text(21,3,
      "be found in a report with the name of the open event. For more information see the RDDS User Guide."
      )
     CALL accept(14,126,"P;CU","_"
      WHERE curaccept IN ("A", "P", "X"))
     SET apcm_modify_answer = curaccept
     IF (apcm_modify_answer="X")
      ROLLBACK
      RETURN
     ELSEIF (apcm_modify_answer="A")
      SET apcm_new_default_message = "AUTO CUTOVER"
      CALL clear(14,1)
      CALL clear(15,1)
      CALL clear(16,1)
      CALL clear(17,1)
      CALL clear(18,1)
      CALL clear(19,1)
      CALL clear(20,1)
      CALL clear(21,1)
      CALL text(14,3,concat("New Configuration for target ",tgt_env_name,":"))
      CALL text(15,5,"Cutover Type")
      IF (apcm_dual_bld_setting=2.0)
       CALL text(15,48,concat("-  ",apcm_new_default_message))
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(18,5,"PTAM SETTING")
       IF (apcm_ptam_setting=1)
        CALL text(18,48,concat("-  ",apcm_tgt_env_name," IS MASTER"))
       ELSEIF (apcm_ptam_setting=0)
        CALL text(18,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(18,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ELSEIF (apcm_dual_bld_setting=1.0)
       CALL text(15,48,concat("-  ",apcm_new_default_message))
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NO")
       CALL text(18,5,"PTAM SETTING")
       IF (apcm_ptam_setting=1)
        CALL text(18,48,concat("-  ",apcm_tgt_env_name," IS MASTER"))
       ELSEIF (apcm_ptam_setting=0)
        CALL text(18,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(18,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ELSE
       CALL text(15,48,concat("-  ",apcm_new_default_message))
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  YES")
       CALL text(18,5,"PTAM SETTING")
       IF (apcm_ptam_setting=1)
        CALL text(18,48,concat("-  ",apcm_tgt_env_name," IS MASTER"))
       ELSEIF (apcm_ptam_setting=0)
        CALL text(18,48,"-  NO MASTER DOMAIN IS SET")
       ELSE
        CALL text(18,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       ENDIF
      ENDIF
     ELSE
      SET apcm_new_default_message = "PLANNED CUTOVER"
      CALL clear(14,1)
      CALL clear(15,1)
      CALL clear(16,1)
      CALL clear(17,1)
      CALL clear(18,1)
      CALL clear(19,1)
      CALL text(14,3,concat("New Configuration for target ",tgt_env_name,":"))
      CALL text(15,5,"Cutover Type")
      CALL text(15,48,concat("-  ",apcm_new_default_message))
      IF (apcm_dual_bld_setting=2.0)
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      ELSEIF (apcm_dual_bld_setting=1.0)
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NO")
      ELSE
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  YES")
      ENDIF
      CALL text(18,5,"PTAM SETTING")
      IF (apcm_ptam_setting=1)
       CALL text(18,48,concat("-  ",apcm_tgt_env_name," IS MASTER"))
      ELSEIF (apcm_ptam_setting=0)
       CALL text(18,48,"-  NO MASTER DOMAIN IS SET")
      ELSE
       CALL text(18,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      ENDIF
     ENDIF
     CALL text(21,3,"Confirm configuration changes? [(Y)es / (N)o] ")
     CALL accept(21,50,"P;CU","N"
      WHERE curaccept IN ("Y", "N"))
     SET apcm_modify_answer = curaccept
     IF (apcm_modify_answer="Y")
      SET apc_continue = 1
      UPDATE  FROM dm_env_reltn der
       SET der.relationship_type = apcm_new_default_message
       WHERE (der.parent_env_id=dmda_mr->env_id)
        AND der.child_env_id=apcm_target_env_id
        AND der.relationship_type IN ("AUTO CUTOVER", "PLANNED CUTOVER")
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc) != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
      ENDIF
      IF (curqual=0)
       SET stat = alterlist(dera_request->env_list,1)
       SET dera_request->child_env_id = apcm_target_env_id
       SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
       SET dera_request->env_list[1].child_env_id = apcm_target_env_id
       SET dera_request->env_list[1].relationship_type = apcm_new_default_message
       EXECUTE dm_add_env_reltn
      ENDIF
      SET stat = alterlist(auto_ver_request->qual,1)
      SET stat = alterlist(auto_ver_request->qual[1].detail_qual,0)
      SET auto_ver_request->qual[1].rdds_event = "Auto/Planned Relationship Change"
      SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
      SET auto_ver_request->qual[1].paired_environment_id = apcm_target_env_id
      EXECUTE dm_rmc_auto_verify_setup
      IF ((auto_ver_reply->status="F"))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       SET stat = initrec(auto_ver_request)
       SET stat = initrec(auto_ver_reply)
      ELSE
       COMMIT
       SET stat = initrec(auto_ver_request)
       SET stat = initrec(auto_ver_reply)
      ENDIF
     ELSE
      SET apc_continue = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE cutover_configure_movers(null)
   DECLARE mover_con = i2 WITH protect, noconstant(0)
   DECLARE mm_ret_val = c1
   SET mm_ret_val = confirm_display("TARGET",0)
   IF (mm_ret_val="Y")
    WHILE (mover_con=0)
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,7,132)
      CALL text(3,40,"***  Configure Data Movers ***")
      CALL text(5,20,"Environment Name:")
      CALL text(5,40,dmda_mr->env_name)
      CALL text(5,65,"Environment ID:")
      CALL text(5,85,cnvtstring(dmda_mr->env_id))
      CALL text(9,3,"Choose from the following options: ")
      CALL text(11,3,"1 Target Reactivations")
      CALL text(12,3,"2 Mover Batch Size")
      CALL text(13,3,"3 Mover Log Level")
      CALL text(14,3,"4 Change Log Reset Time")
      CALL text(15,3,"5 Child Exception Reset")
      CALL text(17,3,"0 Exit")
      CALL text(20,3,"Please note that any changes made will not be committed to the database until")
      CALL text(21,3,"you exit the dm_merge_domain_adm menu program")
      CALL accept(9,45,"9",0
       WHERE curaccept IN (1, 2, 3, 4, 5,
       0))
      CASE (curaccept)
       OF 1:
        CALL target_reactivation(null)
       OF 2:
        CALL mover_batch_size(null)
       OF 3:
        CALL set_log_level(null)
       OF 4:
        CALL mover_reset_time(null)
       OF 5:
        CALL dmda_move_chld_exceptions(null)
       OF 0:
        SET mover_con = 1
      ENDCASE
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE target_reactivation(null)
   DECLARE active_ind_merge = i4
   DECLARE default_message = vc
   DECLARE user_answer = vc
   SELECT INTO "NL:"
    d.info_number
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="RDDS ACTIVE_IND MERGE"
    DETAIL
     active_ind_merge = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET default_message = "Current setting: You have not set this option yet."
   ELSEIF (active_ind_merge=1)
    SET default_message =
    "Current setting: Reactivate inactive rows in the target if the source row is active"
   ELSE
    SET default_message = "Current setting: Do not reactive inactive rows in target(default)"
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Target Reactivation ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(8,3,
    "The RDDS mover(s) can be configured to allow the reactivation of an inactive row in the target environment."
    )
   CALL text(9,3,"The default for this behavior keeps the inactive target row in its' current state."
    )
   CALL text(10,3,"Would you like to re-activate rows in target (Y/N)?")
   CALL text(11,3,default_message)
   CALL accept(14,90,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   SET user_answer = curaccept
   IF (user_answer="Y")
    UPDATE  FROM dm_info di
     SET di.info_number = 1
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS ACTIVE_IND MERGE"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_number = 1, di.info_domain = "DATA MANAGEMENT", di.info_name =
       "RDDS ACTIVE_IND MERGE"
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
     ENDIF
    ENDIF
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS ACTIVE_IND MERGE"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_number = 0, di.info_domain = "DATA MANAGEMENT", di.info_name =
       "RDDS ACTIVE_IND MERGE"
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
     ENDIF
    ENDIF
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Target Reactivation Setting"
   SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
   SET auto_ver_request->qual[1].paired_environment_id = 0
   IF (user_answer="Y")
    SET auto_ver_request->qual[1].detail_qual[1].event_value = 1
   ELSE
    SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
   ENDIF
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    CALL disp_msg(auto_ver_reply->status_msg,dm_err->logfile,1)
    ROLLBACK
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ELSE
    COMMIT
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE mover_batch_size(null)
   DECLARE batch_size = f8
   SELECT INTO "NL:"
    di.info_number
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="RDDS BATCH SIZE"
    DETAIL
     batch_size = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
   ENDIF
   IF (curqual=0)
    SET batch_size = 200
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Set Mover Batch Size ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(8,3,
    "The RDDS mover(s) select rows in batches from the dm_chg_log for subsequent merge processing.")
   CALL text(9,3,"Changing this setting allows more work to be performed per batch.")
   CALL text(10,3,"The batch size range can be from 1 to 4000.")
   CALL text(12,3,concat("What would you like the batch size to be set at? Current batch size is: ",
     cnvtstring(batch_size)))
   CALL accept(12,90,"P(5);CU","0")
   SET batch_size = cnvtreal(curaccept)
   IF (((batch_size < 1) OR (batch_size > 4000)) )
    CALL clear(20,1)
    CALL text(20,3,
     "Invalid batch size entered. The acceptable range for the mover batch size is 1-4000. Please try again."
     )
    CALL pause(3)
    CALL mover_batch_size(null)
   ENDIF
   UPDATE  FROM dm_info di
    SET di.info_number = batch_size
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="RDDS BATCH SIZE"
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = batch_size, di.info_domain = "DATA MANAGEMENT", di.info_name =
      "RDDS BATCH SIZE"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
    ENDIF
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Mover Batch Size Setting"
   SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
   SET auto_ver_request->qual[1].paired_environment_id = 0
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
   SET auto_ver_request->qual[1].detail_qual[1].event_value = batch_size
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    CALL disp_msg(auto_ver_reply->status_msg,dm_err->logfile,1)
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
    GO TO exit_program
   ELSE
    COMMIT
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE set_log_level(null)
   DECLARE log_level_answer = vc
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Set RDDS Log Level ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(8,3,
    "The RDDS movers have the ability to reduce the amount of data that is written to the DM_CHG_LOG_AUDIT"
    )
   CALL text(9,3,
    "table. If the option is set to reduce logging, then only INSERT,UPDATE,DELETE,FAILREASON,BATCH START and "
    )
   CALL text(10,3,"BATCH END actions will be written to the table.")
   CALL text(12,3,"Would you like to reduce the number of rows written to DM_CHG_LOG_AUDIT? (Y/N)")
   CALL accept(14,90,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   SET log_level_answer = curaccept
   IF (log_level_answer="Y")
    UPDATE  FROM dm_info di
     SET di.info_number = 1
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS LOG LEVEL"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_number = 1, di.info_domain = "DATA MANAGEMENT", di.info_name = "RDDS LOG LEVEL"
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
     ENDIF
    ENDIF
   ELSE
    UPDATE  FROM dm_info di
     SET info_number = 0
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS LOG LEVEL"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_number = 0, di.info_domain = "DATA MANAGEMENT", di.info_name = "RDDS LOG LEVEL"
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
     ENDIF
    ENDIF
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Mover Log Level Setting"
   SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
   SET auto_ver_request->qual[1].paired_environment_id = 0
   IF (log_level_answer="Y")
    SET auto_ver_request->qual[1].detail_qual[1].event_value = 1
   ELSE
    SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
   ENDIF
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    CALL disp_msg(auto_ver_reply->status_msg,dm_err->logfile,1)
    ROLLBACK
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ELSE
    COMMIT
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE cutover_configuration(null)
   DECLARE cutover_con = i2 WITH protect, noconstant(0)
   DECLARE mm_ret_val = c1
   DECLARE srm_ret_val2 = c1
   DECLARE cc_cbc_ind = i2 WITH protect, noconstant(0)
   DECLARE cc_row_pos = i4 WITH protect, noconstant(0)
   DECLARE cc_task_flag = i4 WITH protect, noconstant(0)
   DECLARE cc_mig_check = i2 WITH protect, noconstant(0)
   IF (no_confirm=0)
    SET mm_ret_val = confirm_display("TARGET",0)
   ELSE
    SET mm_ret_val = "Y"
   ENDIF
   IF (mm_ret_val="Y")
    SET cc_cbc_ind = dcs_check_cbc(null)
    IF (check_error_gui(dm_err->eproc,"Cutover Process Management",dmda_mr->env_name,dmda_mr->env_id)
     != 0)
     SET cutover_con = 1
    ENDIF
    WHILE (cutover_con=0)
     SET cc_task_flag = drtq_check_task_process("SCHEDULED AUTO-CUTOVER")
     IF (cc_task_flag <= 0)
      CALL check_error_gui(dm_err->eproc,"Cutover Process Management",dmda_mr->env_name,dmda_mr->
       env_id)
      SET cutover_con = 1
     ELSE
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,7,132)
      CALL text(3,40,"***  Cutover Process Management ***")
      CALL text(5,20,"Environment Name:")
      CALL text(5,40,dmda_mr->env_name)
      CALL text(5,65,"Environment ID:")
      CALL text(5,85,cnvtstring(dmda_mr->env_id))
      CALL text(9,3,"Choose from the following options: ")
      CALL text(11,3,"1 Start Cutover Process")
      CALL text(12,3,"2 View Cutover Processes")
      CALL text(13,3,"3 View Cutover Status")
      CALL text(14,3,"4 View Cutover Warnings")
      CALL text(15,3,"5 View Cutover Free Space Report")
      CALL text(16,3,"6 View Contexts to Cutover")
      IF (cc_task_flag=3)
       CALL text(17,3,"7 Cancel Scheduled Auto Cutover")
       CALL text(18,3,"0 Exit")
      ELSE
       CALL text(17,3,"0 Exit")
      ENDIF
      CALL dmda_draw_event_box(10,75,0,dmda_event_info)
      IF (cc_task_flag=3)
       CALL accept(9,45,"9",0
        WHERE curaccept IN (1, 2, 3, 4, 5,
        6, 7, 0))
      ELSE
       CALL accept(9,45,"9",0
        WHERE curaccept IN (1, 2, 3, 4, 5,
        6, 0))
      ENDIF
      CASE (curaccept)
       OF 1:
        SET cc_mig_check = dmda_check_mig_settings(1,dmda_event_info->event_name,"RDDS Cutover")
        IF (((cc_mig_check=1) OR ((dm_err->err_ind=1))) )
         SET cutover_con = 1
        ELSE
         SET srm_ret_val2 = connect_info_display(null)
         IF (srm_ret_val2="Y")
          CALL start_cutover(null)
         ELSE
          SET cutover_con = 1
         ENDIF
        ENDIF
       OF 2:
        CALL view_cutover_movers(null)
       OF 3:
        CALL view_cutover_status(null)
       OF 4:
        CALL view_cutover_warnings(null)
       OF 5:
        CALL view_free_space(null)
       OF 6:
        CALL view_cutover_contexts(cc_cbc_ind)
       OF 7:
        CALL cancel_sched_ac(null)
       OF 0:
        SET cutover_con = 1
      ENDCASE
     ENDIF
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE start_cutover(null)
   DECLARE sc_dcl_stat = i4 WITH protect, noconstant(0)
   DECLARE sc_pw_string = vc
   DECLARE sc_execute_str = vc
   DECLARE sc_path_str = vc
   DECLARE sc_val_started = i4 WITH protect, noconstant(0)
   DECLARE sc_val_to_start = i4 WITH protect, noconstant(0)
   DECLARE sc_process_num = i4 WITH protect, noconstant(0)
   DECLARE sc_start_over = i4
   DECLARE sc_com_batch = vc
   DECLARE sc_cutover_cnt = i4
   DECLARE sc_cur_logfile = vc
   DECLARE sc_cbc_ind = i2 WITH protect, noconstant(0)
   DECLARE sc_del_ctxt = vc WITH protect, noconstant("")
   DECLARE sc_cbc_while = i2 WITH protect, noconstant(0)
   DECLARE sc_ctxt_loop = i4 WITH protect, noconstant(0)
   DECLARE sc_str_len = i4 WITH protect, noconstant(0)
   DECLARE sc_start = i4 WITH protect, noconstant(0)
   DECLARE sc_pos = i4 WITH protect, noconstant(0)
   DECLARE sc_context_str = vc WITH protect, noconstant("")
   DECLARE sc_ctx_loop = i4 WITH protect, noconstant(0)
   DECLARE sc_ctxt_tmp = vc WITH protect, noconstant("")
   DECLARE sc_help_str = vc WITH protect, noconstant("")
   DECLARE sc_max_ind = i2 WITH protect, noconstant(0)
   DECLARE sc_ctxt_row = i4 WITH protect, noconstant(0)
   DECLARE sc_idx = i4 WITH protect, noconstant(0)
   DECLARE sc_min_code_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("15-OCT-2002 12:00:00"))
   DECLARE sc_auto_cut_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("15-SEP-2002 12:00:00"))
   DECLARE sc_ask_auto_cut = i2 WITH protect, noconstant(0)
   DECLARE sc_ask_done_ind = i2 WITH protect, noconstant(0)
   DECLARE sc_date_idx = i4 WITH protect, noconstant(0)
   DECLARE sc_time = i4 WITH protect, noconstant(0)
   DECLARE sc_time_str = vc WITH protect, noconstant("")
   DECLARE sc_hour = i4 WITH protect, noconstant(0)
   DECLARE sc_min = i4 WITH protect, noconstant(0)
   DECLARE sc_time_done_ind = i2 WITH protect, noconstant(0)
   DECLARE sc_realm = vc WITH protect, noconstant("")
   DECLARE sc_ea_flag = i2 WITH protect, noconstant(0)
   CALL clear(1,1)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL parser("cclseclogin go")
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = ""
      SET dm_err->err_ind = 0
     ENDIF
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "Starting Cutover"
      SET dm_err->emsg = "User not logged in cclseclogin"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   DECLARE sc_num_mover = i4
   DECLARE sc_open_event_target = f8
   DECLARE sc_open_event_source = f8
   DECLARE sc_open_event_reason = vc
   FREE RECORD b_request
   RECORD b_request(
     1 num_cutover_processes = i4
     1 source_env_id = f8
   )
   FREE RECORD b_reply
   RECORD b_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD sc_ready
   RECORD sc_ready(
     1 status = vc
     1 err_msg = vc
     1 cutover_ready_ind = i2
   ) WITH protect
   FREE RECORD sc_dates
   RECORD sc_dates(
     1 cnt = i4
     1 qual[*]
       2 date_str = vc
   )
   FREE RECORD drsac_request
   RECORD drsac_request(
     1 environment_id = f8
     1 source_env_id = f8
     1 cut_proc_cnt = i4
     1 cut_dt_tm = dq8
     1 db_pw = vc
     1 db_conn = vc
     1 db_batch = vc
   )
   FREE RECORD sc_cbc
   RECORD sc_cbc(
     1 ctxt_cnt = i4
     1 cur_ctxt_cnt = i4
     1 all_ind = i2
     1 tab_cnt = i4
     1 ctxt_qual[*]
       2 context_name = vc
     1 cur_ctxt_qual[*]
       2 context_name = vc
     1 tab_qual[*]
       2 table_name = vc
   )
   FREE RECORD env_list
   RECORD env_list(
     1 env_cnt = i4
     1 list[*]
       2 env_id = f8
       2 env_name = vc
   )
   CALL dbase_connect(dmda_connect_info)
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg("Gathering connection information",dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL get_src_env_id("Start Cutover Process",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   SET message = window
   SELECT INTO "nl:"
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND drel.paired_environment_id != srm_env_id
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND paired_environment_id != srm_env_id
      AND rdds_event="End Reference Data Sync"
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     sc_open_event_target = drel.cur_environment_id, sc_open_event_source = drel
     .paired_environment_id, sc_open_event_reason = drel.event_reason
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND (drel.cur_environment_id=dmda_mr->env_id)
      AND drel.paired_environment_id=srm_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE (cur_environment_id=dmda_mr->env_id)
       AND paired_environment_id=srm_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     DETAIL
      sc_open_event_target = drel.cur_environment_id, sc_open_event_source = drel
      .paired_environment_id, sc_open_event_reason = drel.event_reason
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual=0)
     SET dm_err->emsg =
     "There are no current RDDS events open for this relationship. You must open a new RDDS event to continue. Exiting menu."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL clear(1,1)
     CALL text(15,3,
      "There are no current RDDS events open for this relationship. You must open a new RDDS event to continue. Exiting menu."
      )
     CALL text(16,20,"Press ENTER to return to the previous menu.")
     CALL accept(16,64,"P;E"," ")
     SET help = off
     SET validate = off
     RETURN
    ELSE
     SET dm_err->eproc = "Checking for unacknowledged dual build."
     EXECUTE dm_rmc_check_unprocessed  WITH replace("REPLY","SC_READY")
     IF ((sc_ready->status="F"))
      SET dm_err->emsg = sc_ready->err_msg
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF ((sc_ready->cutover_ready_ind=0))
      SET dm_err->emsg = concat(
       "There are unacknowledged dual build changes detected which are preventing Cutover.  ",
       "Access the RDDS menu option 'Acknowledge Database Integrity Concerns' to accept dual build risks to ",
       "proceed with Cutover.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL clear(1,1)
      CALL text(15,3,
       "There are unacknowledged dual build changes detected which are preventing Cutover. ")
      CALL text(16,3,concat(
        "Access the RDDS menu option 'Acknowledge Database Integrity Concerns for Cutover' to accept ",
        "dual build risks to proceed"))
      CALL text(17,3,"with Cutover.")
      CALL text(18,20,"Press ENTER to return to the previous menu.")
      CALL accept(18,64,"P;E"," ")
      SET help = off
      SET validate = off
      RETURN
     ENDIF
     SET dm_err->eproc =
     "Determining if there are REFCHG triggers logging to additional target environments"
     SELECT INTO "nl:"
      FROM dm_env_reltn der,
       dm_environment d
      WHERE (der.parent_env_id=dmda_mr->env_id)
       AND der.child_env_id != srm_env_id
       AND der.relationship_type="REFERENCE MERGE"
       AND d.environment_id=der.child_env_id
      DETAIL
       env_list->env_cnt = (env_list->env_cnt+ 1), stat = alterlist(env_list->list,env_list->env_cnt),
       env_list->list[env_list->env_cnt].env_id = der.child_env_id,
       env_list->list[env_list->env_cnt].env_name = d.environment_name
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET dm_err->eproc = concat(
       "There are REFCHG triggers logging to additional target environments.  This may cause performance degradation",
       " during cutover. ")
      CALL disp_msg(" ",dm_err->logfile,0)
      CALL clear(8,1)
      CALL text(10,3,
       "WARNING!:There are REFCHG triggers logging to additional target environment(s). ")
      CALL text(11,12,"This may cause a performance degradation during cutover. ")
      CALL text(13,3,"Triggers are logging to the following additional target environment(s): ")
      SET sc_pos = 14
      FOR (sc_idx = 1 TO env_list->env_cnt)
       IF (sc_idx=6)
        SET sc_pos = 14
       ENDIF
       IF (sc_idx BETWEEN 6 AND 10)
        CALL text(sc_pos,40,concat(trim(cnvtstring(env_list->list[sc_idx].env_id))," ",env_list->
          list[sc_idx].env_name))
        SET sc_pos = (sc_pos+ 1)
       ELSEIF (sc_idx > 10)
        SET sc_idx = env_list->env_cnt
        CALL text(sc_pos,6,"...view full list in Manage environment relationship menu...")
        SET sc_pos = (sc_pos+ 1)
       ELSE
        CALL text(sc_pos,6,concat(trim(cnvtstring(env_list->list[sc_idx].env_id))," ",env_list->list[
          sc_idx].env_name))
        SET sc_pos = (sc_pos+ 1)
       ENDIF
      ENDFOR
      IF ((((env_list->env_cnt <= 5)) OR ((env_list->env_cnt >= 10))) )
       SET sc_pos = (sc_pos+ 1)
      ELSE
       SET sc_pos = 20
      ENDIF
      CALL text(sc_pos,3,concat("Environment relationships can be managed using menu option: "))
      SET sc_pos = (sc_pos+ 1)
      CALL text(sc_pos,6,concat(
        "Merge Domain Administration Menu -> Manage environment relationship."))
      SET sc_pos = (sc_pos+ 2)
      CALL text(sc_pos,3,"Continue starting cutover? [(Y)es / (N)o / e(X)it]")
      CALL accept(sc_pos,55,"P;CU"
       WHERE curaccept IN ("Y", "N", "X"))
      SET sc_pos = 0
      SET sc_idx = 0
      IF (curaccept IN ("N", "X"))
       RETURN
      ENDIF
     ENDIF
     SET message = window
     SET sc_cbc_ind = dcs_check_cbc(null)
     IF (sc_cbc_ind=1)
      SELECT INTO "nl:"
       FROM user_tables u
       WHERE u.table_name="*$R"
       DETAIL
        sc_cbc->tab_cnt = (sc_cbc->tab_cnt+ 1)
        IF (mod(sc_cbc->tab_cnt,100)=1)
         stat = alterlist(sc_cbc->tab_qual,(sc_cbc->tab_cnt+ 99))
        ENDIF
        sc_cbc->tab_qual[sc_cbc->tab_cnt].table_name = u.table_name
       FOOT REPORT
        stat = alterlist(sc_cbc->tab_qual,sc_cbc->tab_cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      CALL video(b)
      CALL text(20,80,"Gathering data.  Please wait...")
      FOR (sc_r_tab = 1 TO sc_cbc->tab_cnt)
       SELECT DISTINCT INTO "nl:"
        r.rdds_context_name
        FROM (parser(sc_cbc->tab_qual[sc_r_tab].table_name) r)
        WHERE r.rdds_status_flag < 9000
         AND r.rdds_source_env_id=srm_env_id
        DETAIL
         IF (findstring("::",r.rdds_context_name)=0)
          IF (locateval(sc_ctx_loop,1,sc_cbc->ctxt_cnt,r.rdds_context_name,sc_cbc->ctxt_qual[
           sc_ctx_loop].context_name)=0)
           sc_cbc->ctxt_cnt = (sc_cbc->ctxt_cnt+ 1), stat = alterlist(sc_cbc->ctxt_qual,sc_cbc->
            ctxt_cnt), sc_cbc->ctxt_qual[sc_cbc->ctxt_cnt].context_name = r.rdds_context_name
          ENDIF
         ELSE
          sc_context_str = r.rdds_context_name, sc_str_len = size(sc_context_str), sc_start = 1,
          sc_pos = findstring("::",sc_context_str,sc_start)
          WHILE (sc_pos > 0)
            sc_ctxt_tmp = substring(sc_start,(sc_pos - sc_start),sc_context_str)
            IF (locateval(sc_ctx_loop,1,sc_cbc->ctxt_cnt,sc_ctxt_tmp,sc_cbc->ctxt_qual[sc_ctx_loop].
             context_name)=0)
             sc_cbc->ctxt_cnt = (sc_cbc->ctxt_cnt+ 1), stat = alterlist(sc_cbc->ctxt_qual,sc_cbc->
              ctxt_cnt), sc_cbc->ctxt_qual[sc_cbc->ctxt_cnt].context_name = sc_ctxt_tmp
            ENDIF
            sc_start = (sc_pos+ 2), sc_pos = findstring("::",sc_context_str,sc_start)
          ENDWHILE
          IF (sc_start <= sc_str_len)
           sc_ctxt_tmp = substring(sc_start,((sc_str_len - sc_start)+ 1),sc_context_str)
           IF (locateval(sc_ctx_loop,1,sc_cbc->ctxt_cnt,sc_ctxt_tmp,sc_cbc->ctxt_qual[sc_ctx_loop].
            context_name)=0)
            sc_cbc->ctxt_cnt = (sc_cbc->ctxt_cnt+ 1), stat = alterlist(sc_cbc->ctxt_qual,sc_cbc->
             ctxt_cnt), sc_cbc->ctxt_qual[sc_cbc->ctxt_cnt].context_name = sc_ctxt_tmp
           ENDIF
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
      ENDFOR
      CALL video(n)
      SET sc_cbc_while = 1
      WHILE (sc_cbc_while=1)
        SET stat = alterlist(sc_cbc->cur_ctxt_qual,0)
        SET sc_cbc->cur_ctxt_cnt = 0
        IF (dcs_gather_cbc_ctxt(sc_cbc) < 0)
         RETURN
        ENDIF
        CALL clear(1,1)
        CALL box(1,1,7,132)
        CALL text(3,40,"*** Manage RDDS Cutover Context ***")
        CALL text(5,20,"Environment Name:")
        CALL text(5,40,dmda_mr->env_name)
        CALL text(5,65,"Environment ID:")
        CALL text(5,85,cnvtstring(dmda_mr->env_id))
        CALL text(9,3,"Current Context(s) to Cutover:")
        CALL text(10,3,"----------------------------------")
        SET sc_ctxt_row = 11
        SET sc_max_ind = 0
        IF ((sc_cbc->cur_ctxt_cnt > 0))
         FOR (sc_ctxt_loop = 1 TO sc_cbc->cur_ctxt_cnt)
           IF (((sc_ctxt_row > 20) OR (sc_max_ind=1)) )
            SET sc_tmp_row = (sc_ctxt_row - 10)
            IF (sc_ctxt_row=21)
             SET sc_max_ind = 1
            ENDIF
            CALL text((sc_ctxt_row - 10),35,sc_cbc->cur_ctxt_qual[sc_ctxt_loop].context_name)
            SET sc_ctxt_row = (sc_ctxt_row+ 1)
           ELSE
            CALL text(sc_ctxt_row,3,sc_cbc->cur_ctxt_qual[sc_ctxt_loop].context_name)
            SET sc_ctxt_row = (sc_ctxt_row+ 1)
           ENDIF
         ENDFOR
        ELSE
         CALL text(sc_ctxt_row,3,"<NONE>")
        ENDIF
        IF (sc_max_ind=1)
         SET sc_ctxt_row = 22
        ELSE
         SET sc_ctxt_row = (sc_ctxt_row+ 2)
        ENDIF
        SET accept = nopatcheck
        IF ((sc_cbc->cur_ctxt_cnt=0))
         CALL text(sc_ctxt_row,3,"A=Add, X=Exit")
         CALL accept((sc_ctxt_row+ 1),3,"P;CU","A"
          WHERE curaccept IN ("A", "X"))
        ELSEIF ((sc_cbc->cur_ctxt_cnt=1))
         CALL text(sc_ctxt_row,3,"R=Reset, A=Add, X=Exit, C=Continue")
         CALL accept((sc_ctxt_row+ 1),3,"P;CU","C"
          WHERE curaccept IN ("R", "A", "X", "C"))
        ELSE
         CALL text(sc_ctxt_row,3,"R=Reset, A=Add, D=Delete, X=Exit, C=Continue")
         CALL accept((sc_ctxt_row+ 1),3,"P;CU","C"
          WHERE curaccept IN ("R", "A", "D", "X", "C"))
        ENDIF
        SET sc_user_opt = curaccept
        SET accept = patcheck
        CASE (sc_user_opt)
         OF "X":
          SET cutover_con = 1
          RETURN
         OF "A":
          IF (((((sc_cbc->ctxt_cnt - sc_cbc->cur_ctxt_cnt)=0)
           AND (sc_cbc->cur_ctxt_cnt > 0)
           AND (sc_cbc->ctxt_cnt=0)) OR ((sc_cbc->all_ind=1))) )
           CALL clear(1,1)
           CALL box(1,1,7,132)
           CALL text(3,40,"*** Manage RDDS Cutover Context ***")
           CALL text(5,20,"Environment Name:")
           CALL text(5,40,dmda_mr->env_name)
           CALL text(5,65,"Environment ID:")
           CALL text(5,85,cnvtstring(dmda_mr->env_id))
           IF ((sc_cbc->all_ind=1))
            CALL text(9,3,"All contexts are already selected to cut-over.")
           ELSE
            CALL text(9,3,"There are no more contexts available to cut-over.")
           ENDIF
           CALL text(10,3,"Press ENTER to return to the previous menu.")
           CALL accept(10,64,"P;E"," ")
          ELSE
           SET sc_help_str = notrim(substring(1,31,"'ALL"))
           FOR (sc_ctx_loop = 1 TO sc_cbc->ctxt_cnt)
             IF (locateval(sc_idx,1,sc_cbc->cur_ctxt_cnt,sc_cbc->ctxt_qual[sc_ctx_loop].context_name,
              sc_cbc->cur_ctxt_qual[sc_idx].context_name)=0)
              SET sc_help_str = concat(notrim(sc_help_str),",")
              SET sc_help_str = notrim(concat(sc_help_str,substring(1,31,sc_cbc->ctxt_qual[
                 sc_ctx_loop].context_name)))
             ENDIF
           ENDFOR
           SET sc_help_str = concat(notrim(sc_help_str),"'")
           SET help = pos(15,52)
           SET help = fix(value(replace(sc_help_str,"'","")))
           CALL accept((sc_ctxt_row+ 1),3,"P(30);CUPF")
           SET sc_ctxt_to_add = curaccept
           IF (sc_ctxt_to_add="ALL")
            SET sc_cbc->all_ind = 1
            DELETE  FROM dm_info d
             WHERE d.info_domain="RDDS CONFIGURATION:RDDS CONTEXT TO CUTOVER"
             WITH nocounter
            ;end delete
            IF (check_error("Can not delete RDDS 'Context to Cutover' DM_INFO row") != 0)
             ROLLBACK
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             GO TO exit_program
            ELSE
             COMMIT
            ENDIF
           ENDIF
           INSERT  FROM dm_info d
            SET d.info_domain = "RDDS CONFIGURATION:RDDS CONTEXT TO CUTOVER", d.info_name =
             sc_ctxt_to_add, d.updt_applctx = reqinfo->updt_applctx,
             d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->
             updt_id,
             d.updt_task = reqinfo->updt_task
            WITH nocounter
           ;end insert
           IF (check_error("Can not load RDDS 'Context to Cutover' DM_INFO row") != 0)
            ROLLBACK
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            GO TO exit_program
           ELSE
            COMMIT
           ENDIF
          ENDIF
          SET help = off
         OF "R":
          SET stat = alterlist(sc_cbc->cur_ctxt_qual,0)
          SET sc_cbc->cur_ctxt_cnt = 0
          SET sc_cbc->all_ind = 0
          DELETE  FROM dm_info d
           WHERE d.info_domain="RDDS CONFIGURATION:RDDS CONTEXT TO CUTOVER"
           WITH nocounter
          ;end delete
          IF (check_error(dm_err->eproc)=1)
           ROLLBACK
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ELSE
           COMMIT
          ENDIF
         OF "C":
          SET sc_cbc_while = 0
         OF "D":
          SET help =
          SELECT
           d.info_name
           FROM dm_info d
           WHERE d.info_domain="RDDS CONFIGURATION:RDDS CONTEXT TO CUTOVER"
          ;end select
          CALL accept((sc_ctxt_row+ 1),3,"P(30);CUF")
          SET sc_del_ctxt = curaccept
          DELETE  FROM dm_info d
           WHERE d.info_domain="RDDS CONFIGURATION:RDDS CONTEXT TO CUTOVER"
            AND d.info_name=sc_del_ctxt
           WITH nocounter
          ;end delete
          IF (check_error(dm_err->eproc)=1)
           ROLLBACK
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ELSE
           COMMIT
          ENDIF
        ENDCASE
      ENDWHILE
     ENDIF
     SET sc_cutover_cnt = 0
     SELECT INTO "nl:"
      sc_cnt = count(*)
      FROM dm_refchg_process d
      WHERE d.refchg_type="CUTOVER PROCESS*"
       AND d.env_source_id=srm_env_id
       AND (d.rdbhandle_value=
      (SELECT
       audsid
       FROM gv$session))
      DETAIL
       sc_cutover_cnt = sc_cnt
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM user_tables ut
      WHERE ut.table_name="EA_USER3615$R"
      WITH nocounter
     ;end select
     IF (check_error_gui(dm_err->eproc,"Start Cutover Process",dmda_mr->env_name,dmda_mr->env_id) !=
     0)
      RETURN(null)
     ENDIF
     IF (curqual > 0)
      SELECT INTO "nl:"
       FROM ea_user3615$r r
       WHERE r.rdds_status_flag < 9000
       DETAIL
        sc_ea_flag = 1
       WITH nocounter
      ;end select
      IF (check_error_gui(dm_err->eproc,"Start Cutover Process",dmda_mr->env_name,dmda_mr->env_id)
       != 0)
       RETURN(null)
      ENDIF
     ENDIF
     IF (sc_ea_flag=1)
      SET sc_realm = drrd_get_realm(null)
     ENDIF
     SET sc_start_over = 0
     WHILE (sc_start_over=0)
       CALL clear(1,1)
       SET message = window
       SET width = 132
       CALL box(1,1,7,132)
       CALL text(3,40,"***  Manage Cutover Process ***")
       CALL text(5,20,"Environment Name:")
       CALL text(5,40,dmda_mr->env_name)
       CALL text(5,65,"Environment ID:")
       CALL text(5,85,cnvtstring(dmda_mr->env_id))
       CALL text(9,3,concat("Cutover process will continue for event ",sc_open_event_reason))
       CALL text(10,3,concat("Number of cutovers currently running: ",cnvtstring(sc_cutover_cnt)))
       CALL text(12,3,"How many cutover processes do you want to start: ")
       CALL text(13,3,"(This is in addition to any cutover processes which may already be running)")
       IF (sc_ea_flag=1)
        CALL text(20,3,concat("***NOTE: New users will be added using the registry key domain: ",
          sc_realm,".***"))
       ENDIF
       CALL accept(12,55,"999",0)
       SET sc_num_mover = curaccept
       SET b_request->num_cutover_processes = sc_num_mover
       SET b_request->source_env_id = srm_env_id
       IF (cursys="AXP")
        CALL text(15,3,"    Which batch queue would you like this COM proc submitted to?")
        CALL accept(15,70,"P(30);c")
        SET sc_com_batch = curaccept
       ENDIF
       CALL text(24,3,"Continue? [(Y)es / (N)o / e(X)it]")
       CALL accept(24,38,"P;CU","Y"
        WHERE curaccept IN ("Y", "N", "X"))
       SET no_confirm = 0
       IF (curaccept="N")
        SET sc_start_over = 0
       ELSEIF (curaccept="X")
        SET sc_start_over = 1
        SET no_confirm = 1
       ELSEIF (curaccept="Y")
        IF (sc_num_mover < 1)
         CALL text(24,3,
          "You have chosen to start 0 cutover processes.  Please enter a value more than 0.")
         CALL accept(24,85,"P;HCU","N")
         SET sc_start_over = 0
        ELSE
         SET message = nowindow
         IF (drcr_get_cutover_config(srm_env_id,dmda_mr->env_id)=0)
          SELECT INTO "NL:"
           y = max(event_dt_tm)
           FROM dm_rdds_event_log d
           WHERE d.cur_environment_id=srm_env_id
            AND (d.paired_environment_id=dmda_mr->env_id)
            AND d.rdds_event_key="AUTOPLANNEDRELATIONSHIPCHANGE"
            AND d.rdds_event="Auto/Planned Relationship Change"
           DETAIL
            sc_auto_cut_dt_tm = y
           WITH nocounter
          ;end select
          IF (check_error_gui(dm_err->eproc,"Start Cutover Process",dmda_mr->env_name,dmda_mr->env_id
           ) != 0)
           RETURN(null)
          ENDIF
          IF (sc_auto_cut_dt_tm=0.0)
           SET sc_auto_cut_dt_tm = cnvtdatetime("15-SEP-2002 12:00:00")
          ENDIF
          SELECT INTO "NL:"
           y = min(updt_dt_tm)
           FROM dm_rdds_req_install_env d
           WHERE (d.environment_id=dmda_mr->env_id)
            AND d.req_type="CODE"
            AND d.req_name="RDDS"
            AND d.req_version_nbr >= 46
           DETAIL
            sc_min_code_dt_tm = y
           WITH nocounter
          ;end select
          IF (check_error_gui(dm_err->eproc,"Start Cutover Process",dmda_mr->env_name,dmda_mr->env_id
           ) != 0)
           RETURN(null)
          ENDIF
          IF (sc_min_code_dt_tm=0.0)
           SET sc_min_code_dt_tm = cnvtdatetime("15-OCT-2002 12:00:00")
          ENDIF
          IF (cnvtdatetime(sc_auto_cut_dt_tm) > cnvtdatetime(sc_min_code_dt_tm))
           SET sc_ask_auto_cut = 1
          ENDIF
         ENDIF
         IF (sc_ask_auto_cut=1)
          WHILE (sc_ask_done_ind=0)
            CALL clear(1,1)
            SET message = window
            SET width = 132
            CALL box(1,1,7,132)
            CALL text(3,40,"***  Manage Cutover Process ***")
            CALL text(5,20,"Environment Name:")
            CALL text(5,40,dmda_mr->env_name)
            CALL text(5,65,"Environment ID:")
            CALL text(5,85,cnvtstring(dmda_mr->env_id))
            CALL text(9,3,"Would you like to schedule this cutover for a future time? (Y/N)")
            SET sc_time_str = cnvtlower(cnvtalphanum(trim(substring(1,26,sc_open_event_reason))))
            CALL text(11,3,concat(
              "By selecting 'Y' to the question, you will be prompted to choose a ",
              "date/time, within 3 days from now, that you would like"))
            CALL text(12,3,concat("the cutover to automatically start.  Any dual build that occurs",
              " before the cutover starts will automatically be"))
            CALL text(13,3,concat("acknowledged and can be found in the dual build report in ",
              "CCLUSERDIR with the name of '",sc_time_str,".xml'"))
            CALL text(14,3,
             "This file will be overwritten if it already exists in CCLUSERDIR at time of creation.")
            CALL accept(9,68,"P;CU"
             WHERE curaccept IN ("Y", "N"))
            IF (curaccept="Y")
             CALL text(24,3,"Continue? [(Y)es / (N)o / e(X)it]")
             CALL accept(24,38,"P;CU","Y"
              WHERE curaccept IN ("Y", "N", "X"))
             IF (curaccept="Y")
              SET sc_ask_done_ind = 1
             ELSEIF (curaccept="X")
              SET sc_ask_done_ind = 1
              RETURN(null)
             ENDIF
            ELSE
             SET sc_ask_done_ind = 1
             SET sc_ask_auto_cut = 0
            ENDIF
          ENDWHILE
         ENDIF
         IF (sc_ask_auto_cut=1)
          SET sc_ask_done_ind = 0
          WHILE (sc_ask_done_ind=0)
            CALL clear(1,1)
            SET message = window
            SET width = 132
            CALL box(1,1,7,132)
            CALL text(3,40,"***  Manage Cutover Process ***")
            CALL text(5,20,"Environment Name:")
            CALL text(5,40,dmda_mr->env_name)
            CALL text(5,65,"Environment ID:")
            CALL text(5,85,cnvtstring(dmda_mr->env_id))
            SET sc_dates->cnt = (sc_dates->cnt+ 5)
            SET stat = alterlist(sc_dates->qual,5)
            SET sc_dates->qual[1].date_str = format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY;;D")
            SET sc_dates->qual[2].date_str = format(cnvtlookahead("1,D",cnvtdatetime(curdate,curtime3
               )),"DD-MMM-YYYY;;D")
            SET sc_dates->qual[3].date_str = format(cnvtlookahead("2,D",cnvtdatetime(curdate,curtime3
               )),"DD-MMM-YYYY;;D")
            SET sc_dates->qual[4].date_str = format(cnvtlookahead("3,D",cnvtdatetime(curdate,curtime3
               )),"DD-MMM-YYYY;;D")
            SET sc_dates->qual[5].date_str = "Exit"
            CALL text(9,3,"Future Cutover: Yes")
            CALL text(10,3,
             "Please choose a day, within in the next 72 hours, when the cutover should be started.")
            SET help =
            SELECT INTO "NL:"
             date = sc_dates->qual[d.seq].date_str
             FROM (dummyt d  WITH seq = 5)
             WHERE 1=1
             WITH nocounter
            ;end select
            CALL accept(11,68,"A(11);CUF")
            SET help = off
            IF (curhelp IN (0, 5))
             SET sc_ask_done_ind = 1
             RETURN(null)
            ELSE
             SET sc_date_idx = curhelp
             SET sc_time_done_ind = 0
             WHILE (sc_time_done_ind=0)
               CALL box(1,1,7,132)
               CALL text(3,40,"***  Manage Cutover Process ***")
               CALL text(5,20,"Environment Name:")
               CALL text(5,40,dmda_mr->env_name)
               CALL text(5,65,"Environment ID:")
               CALL text(5,85,cnvtstring(dmda_mr->env_id))
               CALL text(13,3,concat(
                 "Please choose the time, in military format, when the cutover should be ",
                 "started. (9999 to Exit)"))
               CALL text(14,3,
                "The format accepted is HHMM where HH is hours (00 - 23) and MM is minutes (00-59)")
               CALL accept(13,99,"9(4)")
               SET sc_time = curaccept
               IF (sc_time=9999)
                SET sc_time_done_ind = 1
                SET sc_ask_done_ind = 1
                RETURN(null)
               ELSE
                SET sc_time_str = cnvtstring(sc_time)
                IF (sc_time < 10)
                 SET sc_time_str = concat("000",sc_time_str)
                ELSEIF (sc_time < 100)
                 SET sc_time_str = concat("00",sc_time_str)
                ELSEIF (sc_time < 1000)
                 SET sc_time_str = concat("0",sc_time_str)
                ENDIF
                SET sc_hour = cnvtint(substring(1,2,sc_time_str))
                SET sc_min = cnvtint(substring(3,2,sc_time_str))
                IF (sc_hour BETWEEN 0 AND 23
                 AND sc_min BETWEEN 0 AND 59)
                 SET sc_time_str = concat(substring(1,2,sc_time_str),":",substring(3,2,sc_time_str))
                 IF (sc_date_idx=1
                  AND cnvtdatetime(curdate,cnvttime2(sc_time_str,"HH:MM")) <= cnvtdatetime(curdate,
                  curtime3))
                  CALL text(24,3,"Invalid Input. Please choose a time in the future.")
                  CALL pause(3)
                  CALL clear(24,1)
                 ELSE
                  SET sc_time_done_ind = 1
                 ENDIF
                ELSE
                 CALL text(24,3,"Invalid Input")
                 CALL pause(3)
                 CALL clear(24,1)
                ENDIF
               ENDIF
             ENDWHILE
            ENDIF
            SET sc_dates->qual[sc_date_idx].date_str = concat(sc_dates->qual[sc_date_idx].date_str,
             " ",sc_time_str)
            CALL text(16,3,concat("Cutover will be scheduled for ",sc_dates->qual[sc_date_idx].
              date_str,", and will start within 15 minutes of that time."))
            CALL text(24,3,"Confirm? [(Y)es / (N)o / e(X)it]")
            CALL accept(24,38,"P;CU","Y"
             WHERE curaccept IN ("Y", "N", "X"))
            IF (curaccept="Y")
             SET drsac_request->environment_id = dmda_mr->env_id
             SET drsac_request->source_env_id = srm_env_id
             SET drsac_request->cut_proc_cnt = sc_num_mover
             SET drsac_request->cut_dt_tm = cnvtdatetime(sc_dates->qual[sc_date_idx].date_str)
             SET drsac_request->db_pw = dmda_connect_info->db_password
             SET drsac_request->db_conn = dmda_connect_info->db_sid
             SET drsac_request->db_batch = sc_com_batch
             EXECUTE dm_rmc_setup_auto_cut
             IF (check_error_gui(dm_err->eproc,"Start Cutover Process",dmda_mr->env_name,dmda_mr->
              env_id) != 0)
              RETURN(null)
             ENDIF
             SET sc_ask_done_ind = 1
             SET sc_start_over = 1
            ELSEIF (curaccept="X")
             SET sc_ask_done_ind = 1
             RETURN(null)
            ENDIF
          ENDWHILE
         ELSE
          CALL cancel_sched_dml(null)
          SET sc_start_over = 1
          SET sc_val_started = 0
          CALL stop_ref_mover(null)
          FOR (sc_ndx = 1 TO sc_num_mover)
            SELECT INTO "nl:"
             "x"
             FROM dm_refchg_process
             WHERE env_source_id=srm_env_id
              AND rdbhandle_value IN (
             (SELECT
              audsid
              FROM gv$session))
              AND refchg_type=concat("CUTOVER PROCESS",trim(cnvtstring(sc_ndx)))
              AND refchg_status="IN PROGRESS"
            ;end select
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             GO TO exit_program
            ENDIF
            SET sc_cur_logfile = dm_err->unique_fname
            IF (get_unique_file("rdds_run_cutover",".log")=0)
             SET nohup_submit_logfile = "rdds_run_cutover.log"
             SET dm_err->err_ind = 0
            ELSE
             SET nohup_submit_logfile = dm_err->unique_fname
            ENDIF
            SET dm_err->unique_fname = sc_cur_logfile
            IF (curqual=0)
             SET sc_process_num = sc_ndx
             IF (cursys="AXP")
              SET sc_execute_str = concat("SUBMIT /QUE=",sc_com_batch,
               " cer_proc:rdds_run_cutover.com /param=(",trim(cnvtstring(srm_env_id)),".0,",
               trim(cnvtstring(sc_process_num)),",",dmda_connect_info->db_password,",",
               dmda_connect_info->db_sid,
               ") /log=CCLUSERDIR:",nohup_submit_logfile)
             ELSE
              SET sc_execute_str = concat("nohup $cer_proc/rdds_run_cutover.ksh ",trim(cnvtstring(
                 srm_env_id)),".0 ",trim(cnvtstring(sc_process_num))," ",
               dmda_connect_info->db_password," ",dmda_connect_info->db_sid," > $CCLUSERDIR/",
               nohup_submit_logfile,
               " 2>&1 &")
             ENDIF
             CALL dcl(sc_execute_str,size(sc_execute_str),sc_dcl_stat)
             IF (sc_dcl_stat=0)
              SET dm_err->eproc = concat("Error connecting to: ",sc_dcl_stat)
              CALL disp_msg(" ",dm_err->logfile,0)
              GO TO exit_program
             ENDIF
             SET sc_val_started = (sc_val_started+ 1)
            ENDIF
          ENDFOR
          IF (sc_val_started < sc_num_mover)
           SET sc_val_to_start = (sc_num_mover - sc_val_started)
           FOR (sc_ndx = 1 TO sc_val_to_start)
             SET sc_process_num = (sc_ndx+ sc_num_mover)
             IF (cursys="AXP")
              SET sc_execute_str = concat("SUBMIT /QUE=",sc_com_batch,
               " cer_proc:rdds_run_cutover.com /param=(",trim(cnvtstring(srm_env_id)),".0,",
               trim(cnvtstring(sc_process_num)),",",dmda_connect_info->db_password,",",
               dmda_connect_info->db_sid,
               ") /log=CCLUSERDIR:",nohup_submit_logfile)
             ELSE
              SET sc_execute_str = concat("nohup $cer_proc/rdds_run_cutover.ksh ",trim(cnvtstring(
                 srm_env_id)),".0 ",trim(cnvtstring(sc_process_num))," ",
               dmda_connect_info->db_password," ",dmda_connect_info->db_sid," > $CCLUSERDIR/",
               nohup_submit_logfile,
               " 2>&1 &")
             ENDIF
             CALL dcl(sc_execute_str,size(sc_execute_str),sc_dcl_stat)
             IF (sc_dcl_stat=0)
              SET dm_err->eproc = concat("Error connecting to: ",sc_dcl_stat)
              CALL disp_msg(" ",dm_err->logfile,0)
              GO TO exit_program
             ENDIF
           ENDFOR
          ENDIF
          CALL mc_confirm_screen("cutover",sc_num_mover)
          SET message = window
         ENDIF
        ENDIF
       ENDIF
     ENDWHILE
     IF (sc_num_mover > 0)
      SET stat = alterlist(auto_ver_request->qual,1)
      SET auto_ver_request->qual[1].rdds_event = "Cutover Started"
      SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
      SET auto_ver_request->qual[1].paired_environment_id = srm_env_id
      IF ((drsac_request->cut_proc_cnt > 0))
       SET auto_ver_request->qual[1].event_reason = "Pre-Scheduled Cutover"
      ENDIF
      SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
      SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "Number of Cutovers Started"
      SET auto_ver_request->qual[1].detail_qual[1].event_value = sc_num_mover
      IF (sc_cbc_ind=1)
       IF ((sc_cbc->cur_ctxt_cnt=0))
        IF (dcs_gather_cbc_ctxt(sc_cbc) < 0)
         RETURN
        ENDIF
       ENDIF
       FOR (sc_ctxt_loop = 1 TO sc_cbc->cur_ctxt_cnt)
         SET stat = alterlist(auto_ver_request->qual[1].detail_qual,(sc_ctxt_loop+ 1))
         SET auto_ver_request->qual[1].detail_qual[(sc_ctxt_loop+ 1)].event_detail1_txt =
         "RDDS CONTEXT TO CUTOVER"
         SET auto_ver_request->qual[1].detail_qual[(sc_ctxt_loop+ 1)].event_detail2_txt = sc_cbc->
         cur_ctxt_qual[sc_ctxt_loop].context_name
       ENDFOR
      ENDIF
      EXECUTE dm_rmc_auto_verify_setup
      IF ((auto_ver_reply->status="F"))
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET stat = initrec(auto_ver_reply)
       SET stat = initrec(auto_ver_request)
       GO TO exit_program
      ELSE
       SET message = nowindow
       COMMIT
       SET stat = initrec(auto_ver_reply)
       SET stat = initrec(auto_ver_request)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET dm_err->emsg = concat("Event ",sc_open_event_reason," for source environment: ",trim(
      cnvtstring(sc_open_event_source)),
     " is currently open. You cannot open a new RDDS event while another event is open.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL clear(1,1)
    CALL text(15,3,concat("Event: ",sc_open_event_reason))
    CALL text(16,3,concat("For source environment: ",trim(cnvtstring(sc_open_event_source)),
      " is currently open."))
    CALL text(17,3,"You cannot open a new RDDS event while another event is open.")
    CALL text(18,20,"Press ENTER to return to the previous menu.")
    CALL accept(18,64,"P;E"," ")
    SET help = off
    SET validate = off
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE view_cutover_movers(null)
   DECLARE vcm_del_ind = i4 WITH protect, noconstant(0)
   CALL get_src_env_id("View Cutover Processes",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   SET vcm_del_ind = drcd_drp_del("CUTOVER PROCESS*")
   IF (vcm_del_ind=0)
    COMMIT
   ELSE
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SELECT
    process_name = drp.refchg_type, status = drp.refchg_status
    FROM dm_refchg_process drp
    WHERE drp.refchg_type="CUTOVER PROCESS*"
     AND drp.env_source_id=srm_env_id
     AND drp.rdbhandle_value IN (
    (SELECT
     audsid
     FROM gv$session))
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE view_cutover_status(null)
   DECLARE v_loop = i2 WITH noconstant(1)
   DECLARE vcs_cbc_ind = i2 WITH protect, noconstant(0)
   FREE RECORD vcw_tabs
   RECORD vcw_tabs(
     1 qual[*]
       2 tab_name = vc
       2 completed_count = i4
       2 remaining_count = i4
       2 ctxt_completed_count = i4
       2 ctxt_remaining_count = i4
       2 9000_count = i4
       2 9001_count = i4
       2 9002_count = i4
       2 9003_count = i4
       2 9004_count = i4
       2 9000up_count = i4
       2 process_flag = i2
       2 has_warning = i2
       2 has_def = i2
       2 start_date = f8
       2 end_date = f8
     1 qual_cnt = i2
     1 complete_rows = i4
     1 remaining_rows = i4
     1 complete_tab = i2
     1 remaining_tab = i2
     1 ctxt_complete_rows = i4
     1 ctxt_remaining_rows = i4
     1 ctxt_complete_tab = i4
     1 ctxt_remaining_tab = i4
     1 warning_tab = i2
     1 proc_cnt = i2
     1 no_oragen = i2
     1 cbc_ind = i2
   )
   CALL get_src_env_id("View Cutover Mover Status",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   SET message = window
   CALL get_cutover_status_reports(0,srm_env_id,vcw_tabs)
   CALL video(n)
   SET vcs_cbc_ind = vcw_tabs->cbc_ind
   WHILE (v_loop=1)
     CALL clear(1,1)
     SET width = 132
     SET accept = time(30)
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Cutover Process Management ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     IF ((vcw_tabs->no_oragen=1))
      CALL text(8,3,
       "*** Warning: There are $R tables that are missing a CCL Definition. Have a DBA user run this report to correct this.***"
       )
     ENDIF
     CALL text(9,3,"Status: ")
     IF ((vcw_tabs->remaining_rows=0))
      CALL text(9,12,"Completed")
     ELSEIF ((vcw_tabs->ctxt_remaining_rows=0))
      CALL text(9,12,"Completed (Selected Contexts Only)")
     ELSEIF ((vcw_tabs->proc_cnt > 0))
      CALL text(9,12,"In Progress")
     ELSE
      CALL text(9,12,"Stalled")
     ENDIF
     CALL text(10,3,"Tables with warnings:")
     CALL text(10,26,concat(trim(cnvtstring(vcw_tabs->warning_tab))," tables"))
     IF ((vcw_tabs->cbc_ind=0))
      CALL text(12,3,"Completed Activity:")
      CALL text(12,33,concat(trim(cnvtstring(vcw_tabs->complete_tab))," tables"))
      CALL text(12,58,concat(trim(cnvtstring(vcw_tabs->complete_rows))," rows"))
      CALL text(13,3,"Remaining Activity:")
      CALL text(13,33,concat(trim(cnvtstring(vcw_tabs->remaining_tab))," tables"))
      CALL text(13,58,concat(trim(cnvtstring(vcw_tabs->remaining_rows))," rows"))
     ELSE
      CALL text(11,38,"All Contexts")
      CALL text(11,72,"Selected Contexts")
      CALL text(12,3,"Completed Activity:")
      CALL text(12,33,concat(trim(cnvtstring(vcw_tabs->complete_tab))," tables"))
      CALL text(12,49,concat(trim(cnvtstring(vcw_tabs->complete_rows))," rows"))
      CALL text(12,68,concat(trim(cnvtstring(vcw_tabs->ctxt_complete_tab))," tables"))
      CALL text(12,84,concat(trim(cnvtstring(vcw_tabs->ctxt_complete_rows))," rows"))
      CALL text(13,3,"Remaining Activity:")
      CALL text(13,33,concat(trim(cnvtstring(vcw_tabs->remaining_tab))," tables"))
      CALL text(13,49,concat(trim(cnvtstring(vcw_tabs->remaining_rows))," rows"))
      CALL text(13,68,concat(trim(cnvtstring(vcw_tabs->ctxt_remaining_tab))," tables"))
      CALL text(13,84,concat(trim(cnvtstring(vcw_tabs->ctxt_remaining_rows))," rows"))
     ENDIF
     CALL text(16,3,"Choose from the following options for detail reports: ")
     CALL text(17,3,"1 Processing List")
     CALL text(18,3,"2 Pending Processing List")
     CALL text(19,3,"3 Processed List")
     CALL text(20,3,"4 View Cutover Warnings")
     CALL text(21,3,"5 View Contexts to Cutover")
     CALL text(22,3,"6 Refresh List")
     CALL text(23,3,"0 Exit")
     CALL accept(16,61,"9",6
      WHERE curaccept IN (1, 2, 3, 4, 5,
      6, 0))
     SET accept = notime
     SET stat = initrec(vcw_tabs)
     CASE (curaccept)
      OF 1:
       CALL get_cutover_status_reports(curaccept,srm_env_id,vcw_tabs)
      OF 2:
       CALL get_cutover_status_reports(curaccept,srm_env_id,vcw_tabs)
      OF 3:
       CALL get_cutover_status_reports(curaccept,srm_env_id,vcw_tabs)
      OF 4:
       CALL view_cutover_warnings(null)
       CALL get_cutover_status_reports(0,srm_env_id,vcw_tabs)
      OF 5:
       CALL view_cutover_contexts(vcs_cbc_ind)
       CALL get_cutover_status_reports(0,srm_env_id,vcw_tabs)
      OF 6:
       CALL get_cutover_status_reports(0,srm_env_id,vcw_tabs)
      OF 0:
       SET v_loop = 0
     ENDCASE
     CALL video(n)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE view_cutover_warnings(null)
   IF (srm_env_id=0)
    CALL get_src_env_id("View Cutover Warnings",1)
    IF (srm_env_id=0)
     RETURN
    ENDIF
   ENDIF
   DECLARE v_message = vc
   DECLARE v_warning = vc
   DECLARE v_temp = f8
   DECLARE v_warning2 = vc WITH protect, noconstant("")
   DECLARE v_warning3 = vc WITH protect, noconstant("")
   DECLARE v_message2 = vc WITH protect, noconstant("")
   DECLARE v_message3 = vc WITH protect, noconstant("")
   DECLARE v_temp2 = f8 WITH protect, noconstant(0.0)
   DECLARE v_temp3 = f8 WITH protect, noconstant(0.0)
   DECLARE v_temp4 = f8 WITH protect, noconstant(0.0)
   DECLARE v_decrement_val = i4 WITH protect, noconstant(0)
   SELECT
    d.table_name, d.message, d.error_msg,
    d.row_select_txt, d.dml_txt
    FROM dm_refchg_warning d
    WHERE d.warning_type="TABLE PROCESSING ERROR"
     AND d.source_env_id=srm_env_id
    ORDER BY d.table_name
    HEAD REPORT
     col 0, "Table Name", col 31,
     "Warning Message", col 88, "Error Message",
     col 145, "$R Row With Warning", col 222,
     "Failed DML Statement", row + 1, filldash = fillstring(449,"-"),
     col 0, filldash, row + 1
    DETAIL
     v_message = substring(1,30,d.table_name), col 0, v_message,
     v_warning = d.message, v_message = substring(1,55,v_warning), v_temp = size(v_warning,1),
     v_warning = substring(56,(cnvtint(v_temp) - 55),v_warning), v_temp = size(v_warning,1), col 31,
     v_message, v_warning2 = d.error_msg, v_message2 = substring(1,55,v_warning2),
     v_temp2 = size(v_warning2,1), v_warning2 = substring(56,(cnvtint(v_temp2) - 55),v_warning2),
     v_temp2 = size(v_warning2,1),
     col 88, v_message2, v_message = d.row_select_txt,
     col 145, v_message, v_warning3 = trim(d.dml_txt),
     v_message3 = substring(1,200,v_warning3), v_temp3 = size(v_warning3,1), v_warning3 = substring(
      201,(cnvtint(v_temp3) - 200),v_warning3),
     v_temp3 = size(v_warning3,1), col 222, v_message3,
     row + 1, v_temp4 = ceil(maxval((v_temp/ 55),(v_temp2/ 55),(v_temp3/ 200)))
     WHILE (v_temp4 > 0)
       v_message = substring(1,55,v_warning), col 31, v_message,
       v_message2 = substring(1,55,v_warning2), col 88, v_message2,
       v_message3 = substring(1,200,v_warning3), col 222, v_message3,
       v_warning = substring(56,(cnvtint(v_temp) - 55),v_warning), v_warning2 = substring(56,(cnvtint
        (v_temp2) - 55),v_warning2), v_warning3 = substring(201,(cnvtint(v_temp3) - 200),v_warning3),
       v_temp = size(v_warning,1), v_temp2 = size(v_warning2,1), v_temp3 = size(v_warning3,1),
       v_temp4 = (v_temp4 - 1), row + 1
     ENDWHILE
    WITH nocounter, formfeed = none, maxrow = 1,
     maxcol = 450
   ;end select
 END ;Subroutine
 SUBROUTINE view_free_space(null)
   CALL get_src_env_id("View Cutover Free Space Report",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   DECLARE v_idx = i4 WITH protect, noconstant(0)
   DECLARE v_pad_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_batch_size = i4 WITH protect, constant(100)
   DECLARE v_estart = i4 WITH protect, noconstant(1)
   DECLARE v_loop_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_index = i4 WITH protect, noconstant(0)
   DECLARE v_index2 = i4 WITH protect, noconstant(0)
   FREE RECORD vfs_tabs
   RECORD vfs_tabs(
     1 qual[*]
       2 tab_name = vc
       2 completed_count = i4
       2 remaining_count = i4
       2 ctxt_completed_count = i4
       2 ctxt_remaining_count = i4
       2 9000_count = i4
       2 9001_count = i4
       2 9002_count = i4
       2 9003_count = i4
       2 9004_count = i4
       2 9000up_count = i4
       2 process_flag = i2
       2 has_warning = i2
       2 has_def = i2
       2 start_date = f8
       2 end_date = f8
     1 tspace[*]
       2 tspace_name = vc
       2 rows_to_process = i4
       2 space_usage = f8
     1 qual_cnt = i2
     1 tspace_cnt = i2
     1 complete_rows = i4
     1 remaining_rows = i4
     1 complete_tab = i2
     1 remaining_tab = i2
     1 ctxt_complete_rows = i4
     1 ctxt_remaining_rows = i4
     1 ctxt_complete_tab = i4
     1 ctxt_remaining_tab = i4
     1 warning_tab = i2
     1 proc_cnt = i2
     1 no_oragen = i2
     1 cbc_ind = i2
   )
   CALL get_cutover_status_reports(0,srm_env_id,vfs_tabs)
   SET v_idx = 0
   SET v_loop_cnt = ceil((cnvtreal(vfs_tabs->qual_cnt)/ v_batch_size))
   SET v_pad_cnt = (v_loop_cnt * v_batch_size)
   SET stat = alterlist(vfs_tabs->qual,v_pad_cnt)
   FOR (i = (vfs_tabs->qual_cnt+ 1) TO v_pad_cnt)
     SET vfs_tabs->qual[i].tab_name = vfs_tabs->qual[vfs_tabs->qual_cnt].tab_name
   ENDFOR
   SELECT INTO "nl:"
    ut.tablespace_name
    FROM user_tables ut,
     (dummyt d  WITH seq = value(v_loop_cnt))
    PLAN (d
     WHERE initarray(v_estart,evaluate(d.seq,1,1,(v_estart+ v_batch_size))))
     JOIN (ut
     WHERE expand(v_idx,v_estart,((v_estart+ v_batch_size) - 1),ut.table_name,vfs_tabs->qual[v_idx].
      tab_name))
    HEAD REPORT
     loc = 0
    DETAIL
     v_index = locateval(loc,1,vfs_tabs->qual_cnt,ut.table_name,vfs_tabs->qual[loc].tab_name),
     v_index2 = locateval(loc,1,vfs_tabs->tspace_cnt,ut.tablespace_name,vfs_tabs->tspace[loc].
      tspace_name)
     IF (v_index2 > 0)
      vfs_tabs->tspace[v_index2].rows_to_process = (vfs_tabs->tspace[v_index2].rows_to_process+
      vfs_tabs->qual[v_index].remaining_count)
     ELSE
      vfs_tabs->tspace_cnt = (vfs_tabs->tspace_cnt+ 1), stat = alterlist(vfs_tabs->tspace,vfs_tabs->
       tspace_cnt), vfs_tabs->tspace[vfs_tabs->tspace_cnt].tspace_name = ut.tablespace_name,
      vfs_tabs->tspace[vfs_tabs->tspace_cnt].rows_to_process = vfs_tabs->qual[v_index].
      remaining_count
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(vfs_tabs->qual,vfs_tabs->qual_cnt)
   SET v_idx = 0
   SET v_loop_cnt = ceil((cnvtreal(vfs_tabs->tspace_cnt)/ v_batch_size))
   SET v_pad_cnt = (v_loop_cnt * v_batch_size)
   SET stat = alterlist(vfs_tabs->tspace,v_pad_cnt)
   FOR (i = (vfs_tabs->tspace_cnt+ 1) TO v_pad_cnt)
     SET vfs_tabs->tspace[i].tspace_name = vfs_tabs->tspace[vfs_tabs->tspace_cnt].tspace_name
   ENDFOR
   SELECT
    dfs.tablespace_name, space = sum((dfs.bytes/ (1024 * 1024)))
    FROM dba_free_space dfs,
     (dummyt d  WITH seq = v_loop_cnt)
    PLAN (d
     WHERE initarray(v_estart,evaluate(d.seq,1,1,(v_estart+ v_batch_size))))
     JOIN (dfs
     WHERE expand(v_idx,v_estart,((v_estart+ v_batch_size) - 1),dfs.tablespace_name,vfs_tabs->tspace[
      v_idx].tspace_name))
    GROUP BY dfs.tablespace_name
    HEAD REPORT
     loc = 0, col 0, "Tablespace Name",
     col 29, "Rows to be processed by cutover", col 70,
     "Current Free space (MB)", row + 1
    DETAIL
     v_index = locateval(loc,1,vfs_tabs->tspace_cnt,dfs.tablespace_name,vfs_tabs->tspace[loc].
      tspace_name)
     IF ((vfs_tabs->tspace[v_index].rows_to_process > 0))
      col 0, dfs.tablespace_name, col 49,
      vfs_tabs->tspace[v_index].rows_to_process, col 71, space,
      row + 1
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(vfs_tabs->tspace,vfs_tabs->tspace_cnt)
 END ;Subroutine
 SUBROUTINE view_cutover_contexts(vcc_cbc_ind)
   IF (vcc_cbc_ind=1)
    SELECT INTO "MINE"
     context_name = d.info_name
     FROM dm_info d
     WHERE d.info_domain="RDDS CONFIGURATION:RDDS CONTEXT TO CUTOVER"
     ORDER BY d.info_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ELSE
    CALL clear(8,1)
    CALL text(12,25,concat("Cutover by Context was not selected for this event"))
    CALL text(14,30,"Press enter to return to the cutover menu: ")
    CALL accept(14,74,"P;E"," ")
   ENDIF
 END ;Subroutine
 SUBROUTINE get_cutover_status_reports(i_detail,i_source_env_id,v_tabs)
   DECLARE v_dba = i2 WITH noconstant(0)
   DECLARE v_temp = vc
   DECLARE v_info_domain = vc
   DECLARE v_idx = i4 WITH protect, noconstant(0)
   DECLARE v_pad_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_batch_size = i4 WITH protect, constant(100)
   DECLARE v_estart = i4 WITH protect, noconstant(1)
   DECLARE v_loop_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_del_ind = i4 WITH protect, noconstant(0)
   DECLARE gcsr_event_dt_tm = vc WITH protect, noconstant("")
   DECLARE gcsr_event_name = vc WITH protect, noconstant("")
   DECLARE gcsr_ctxt_str = vc WITH protect, noconstant(" ")
   DECLARE gcsr_idx = i4 WITH protect, noconstant(0)
   DECLARE gcsr_exist = i2 WITH protect, noconstant(0)
   FREE RECORD gcsr_cbc_ctxts
   RECORD gcsr_cbc_ctxts(
     1 cur_ctxt_cnt = i4
     1 all_ind = i2
     1 cur_ctxt_qual[*]
       2 context_name = vc
   )
   IF ((dm_err->debug_flag > 1))
    SET message = nowindow
   ELSE
    CALL video(b)
    CALL text(20,80,"Gathering data.  Please wait...")
   ENDIF
   SET v_del_ind = drcd_drp_del("CUTOVER PROCESS*")
   IF (v_del_ind=0)
    COMMIT
   ELSE
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables u
    WHERE u.table_name="*$R"
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(v_tabs->qual,(cnt+ 9))
     ENDIF
     v_tabs->qual[cnt].tab_name = u.table_name
    FOOT REPORT
     stat = alterlist(v_tabs->qual,cnt), v_tabs->qual_cnt = cnt
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM duaf
    WHERE user_name=curuser
     AND group_name="DBA"
    WITH nocounter
   ;end select
   SET v_dba = curqual
   SELECT INTO "nl:"
    s_cnt = count(*)
    FROM dm_refchg_process d
    WHERE d.refchg_type="CUTOVER PROCESS*"
     AND d.env_source_id=i_source_env_id
     AND d.refchg_status="IN PROGRESS"
     AND (d.rdbhandle_value=
    (SELECT
     audsid
     FROM gv$session))
    DETAIL
     v_tabs->proc_cnt = s_cnt
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    drel.event_reason, drel.event_dt_tm
    FROM dm_rdds_event_log drel
    WHERE (cur_environment_id=dmda_mr->env_id)
     AND paired_environment_id=i_source_env_id
     AND rdds_event_key="BEGINREFERENCEDATASYNC"
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND paired_environment_id=i_source_env_id
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     gcsr_event_dt_tm = format(drel.event_dt_tm,";;q"), gcsr_event_name = drel.event_reason
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET v_tabs->cbc_ind = dcs_check_cbc(null)
   IF ((v_tabs->cbc_ind < 0))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ELSEIF ((v_tabs->cbc_ind=1))
    CALL dcs_gather_cbc_ctxt(gcsr_cbc_ctxts)
    IF ((gcsr_cbc_ctxts->all_ind=0))
     FOR (gcsr_idx = 1 TO gcsr_cbc_ctxts->cur_ctxt_cnt)
       SET gcsr_cbc_ctxts->cur_ctxt_qual[gcsr_idx].context_name = concat("::",gcsr_cbc_ctxts->
        cur_ctxt_qual[gcsr_idx].context_name,"::")
     ENDFOR
    ENDIF
   ENDIF
   FOR (i = 1 TO v_tabs->qual_cnt)
     SELECT INTO "nl:"
      FROM dtable d
      WHERE (d.table_name=v_tabs->qual[i].tab_name)
      DETAIL
       v_tabs->qual[i].has_def = 1
      WITH nocounter
     ;end select
     IF ((v_tabs->qual[i].has_def=0))
      IF (v_dba=1)
       EXECUTE oragen3 v_tabs->qual[i].tab_name
       SET v_tabs->qual[i].has_def = 1
      ELSE
       SET v_tabs->no_oragen = 1
      ENDIF
     ENDIF
     IF ((v_tabs->qual[i].has_def=1))
      SELECT INTO "nl:"
       q_count = count(*), d.rdds_status_flag
       FROM (parser(v_tabs->qual[i].tab_name) d)
       WHERE d.rdds_dt_tm >= cnvtdatetime(gcsr_event_dt_tm)
       GROUP BY d.rdds_status_flag
       DETAIL
        IF (d.rdds_status_flag=9999)
         v_tabs->qual[i].completed_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (d.rdds_status_flag=9000)
         v_tabs->qual[i].9000_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (d.rdds_status_flag=9002)
         v_tabs->qual[i].9002_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (d.rdds_status_flag=9003)
         v_tabs->qual[i].9003_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (d.rdds_status_flag=9004)
         v_tabs->qual[i].9004_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (((d.rdds_status_flag > 9004) OR (d.rdds_status_flag=9001)) )
         v_tabs->qual[i].9000up_count = (v_tabs->qual[i].9000up_count+ q_count), v_tabs->
         complete_rows = (v_tabs->complete_rows+ q_count)
        ELSE
         v_tabs->qual[i].remaining_count = (v_tabs->qual[i].remaining_count+ q_count), v_tabs->
         remaining_rows = (v_tabs->remaining_rows+ q_count)
        ENDIF
       WITH nocounter
      ;end select
      IF ((v_tabs->qual[i].remaining_count=0)
       AND (v_tabs->qual[i].completed_count > 0))
       SET v_tabs->complete_tab = (v_tabs->complete_tab+ 1)
      ENDIF
      IF ((v_tabs->qual[i].remaining_count > 0))
       SET v_tabs->remaining_tab = (v_tabs->remaining_tab+ 1)
      ENDIF
      IF ((v_tabs->cbc_ind=1)
       AND (gcsr_cbc_ctxts->all_ind=0))
       SELECT INTO "nl:"
        q_count = count(*), d.rdds_status_flag, d.rdds_context_name
        FROM (parser(v_tabs->qual[i].tab_name) d)
        WHERE d.rdds_dt_tm >= cnvtdatetime(gcsr_event_dt_tm)
        GROUP BY d.rdds_status_flag, d.rdds_context_name
        DETAIL
         gcsr_ctxt_str = concat("::",trim(d.rdds_context_name,3),"::"), gcsr_exist = 0
         FOR (gcsr_idx = 1 TO gcsr_cbc_ctxts->cur_ctxt_cnt)
           IF (findstring(gcsr_cbc_ctxts->cur_ctxt_qual[gcsr_idx].context_name,gcsr_ctxt_str) > 0)
            gcsr_exist = 1, gcsr_idx = gcsr_cbc_ctxts->cur_ctxt_cnt
           ENDIF
         ENDFOR
         IF (d.rdds_status_flag >= 9000
          AND gcsr_exist=1)
          v_tabs->ctxt_complete_rows = (v_tabs->ctxt_complete_rows+ q_count), v_tabs->qual[i].
          ctxt_completed_count = (v_tabs->qual[i].ctxt_completed_count+ q_count)
         ELSEIF (gcsr_exist=1)
          v_tabs->qual[i].ctxt_remaining_count = (v_tabs->qual[i].ctxt_remaining_count+ q_count),
          v_tabs->ctxt_remaining_rows = (v_tabs->ctxt_remaining_rows+ q_count)
         ENDIF
        WITH nocounter
       ;end select
       IF ((v_tabs->qual[i].ctxt_remaining_count=0)
        AND (v_tabs->qual[i].completed_count > 0))
        SET v_tabs->ctxt_complete_tab = (v_tabs->ctxt_complete_tab+ 1)
       ENDIF
       IF ((v_tabs->qual[i].ctxt_remaining_count > 0))
        SET v_tabs->ctxt_remaining_tab = (v_tabs->ctxt_remaining_tab+ 1)
       ENDIF
      ELSE
       SET v_tabs->qual[i].ctxt_completed_count = v_tabs->qual[i].ctxt_completed_count
       SET v_tabs->qual[i].ctxt_remaining_count = v_tabs->qual[i].remaining_count
       SET v_tabs->ctxt_complete_rows = v_tabs->complete_rows
       SET v_tabs->ctxt_remaining_rows = v_tabs->remaining_rows
       SET v_tabs->ctxt_complete_tab = v_tabs->complete_tab
       SET v_tabs->ctxt_remaining_tab = v_tabs->remaining_tab
      ENDIF
      SELECT INTO "nl:"
       FROM dm_refchg_warning d
       WHERE (d.table_name=v_tabs->qual[i].tab_name)
        AND d.warning_type="TABLE PROCESSING ERROR"
        AND d.source_env_id=i_source_env_id
       WITH nocounter
      ;end select
      SET v_tabs->qual[i].has_warning = curqual
      IF (curqual > 0)
       SET v_tabs->warning_tab = (v_tabs->warning_tab+ 1)
      ENDIF
     ENDIF
   ENDFOR
   IF (i_detail > 0)
    SET v_info_domain = concat("RDDS CUTOVER::",cnvtstring(i_source_env_id))
    SET v_idx = 0
    SET v_loop_cnt = ceil((cnvtreal(v_tabs->qual_cnt)/ v_batch_size))
    SET v_pad_cnt = (v_loop_cnt * v_batch_size)
    SET stat = alterlist(v_tabs->qual,v_pad_cnt)
    FOR (i = (v_tabs->qual_cnt+ 1) TO v_pad_cnt)
      SET v_tabs->qual[i].tab_name = v_tabs->qual[v_tabs->qual_cnt].tab_name
    ENDFOR
    SELECT INTO "nl:"
     FROM dm_info di,
      (dummyt d  WITH seq = value(v_loop_cnt))
     PLAN (d
      WHERE initarray(v_estart,evaluate(d.seq,1,1,(v_estart+ v_batch_size))))
      JOIN (di
      WHERE di.info_domain=v_info_domain
       AND expand(v_idx,v_estart,((v_estart+ v_batch_size) - 1),di.info_name,v_tabs->qual[v_idx].
       tab_name))
     HEAD REPORT
      loc = 0
     DETAIL
      v_index = locateval(loc,1,v_tabs->qual_cnt,di.info_name,v_tabs->qual[loc].tab_name), v_tabs->
      qual[v_index].process_flag = di.info_number, v_tabs->qual[v_index].start_date = di.info_date,
      v_tabs->qual[v_index].end_date = di.updt_dt_tm
     WITH nocounter
    ;end select
    SET stat = alterlist(v_tabs->qual,v_tabs->qual_cnt)
   ENDIF
   IF (i_detail=1)
    SET v_idx = 0
    SET v_loop_cnt = ceil((cnvtreal(v_tabs->qual_cnt)/ v_batch_size))
    SET v_pad_cnt = (v_loop_cnt * v_batch_size)
    SET stat = alterlist(v_tabs->qual,v_pad_cnt)
    FOR (i = (v_tabs->qual_cnt+ 1) TO v_pad_cnt)
      SET v_tabs->qual[i].tab_name = v_tabs->qual[v_tabs->qual_cnt].tab_name
    ENDFOR
    SELECT
     drs.cur_stmt_nbr, drs.stmt_cnt, drs.cur_stmt_dt_tm
     FROM dm_refchg_stat drs,
      (dummyt d  WITH seq = value(v_loop_cnt))
     PLAN (d
      WHERE initarray(v_estart,evaluate(d.seq,1,1,(v_estart+ v_batch_size))))
      JOIN (drs
      WHERE drs.source_env_id=i_source_env_id
       AND drs.stat_type="CUTOVER"
       AND expand(v_idx,v_estart,((v_estart+ v_batch_size) - 1),drs.table_name,v_tabs->qual[v_idx].
       tab_name))
     ORDER BY drs.table_name
     HEAD REPORT
      loc = 0, col 40, "Processing List",
      row + 1, col 0, "Status: "
      IF ((v_tabs->remaining_rows=0))
       col + 2, "Completed"
      ELSEIF ((v_tabs->ctxt_remaining_rows=0))
       col + 2, "Completed (Selected Contexts Only)"
      ELSEIF ((v_tabs->proc_cnt > 0))
       col + 2, "In Progress"
      ELSE
       col + 2, "Stalled"
      ENDIF
      row + 1, col 0, "Tables with warnings:",
      col 30, v_tabs->warning_tab, col + 2,
      "tables", row + 1, row + 1,
      row + 1, col 0, "Table Name",
      col 32, "Rows to Process", col 49,
      "Stmt Running", col 65, "Time current stmt started",
      row + 1
     DETAIL
      v_index = locateval(loc,1,v_tabs->qual_cnt,drs.table_name,v_tabs->qual[loc].tab_name)
      IF ((v_tabs->qual[v_index].process_flag=1))
       col 0, drs.table_name, col 32,
       v_tabs->qual[v_index].ctxt_remaining_count, v_temp = concat(trim(cnvtstring(drs.cur_stmt_nbr)),
        " of ",trim(cnvtstring(drs.stmt_cnt))), col 49,
       v_temp, v_temp = format(drs.cur_stmt_dt_tm,";;q"), col 65,
       v_temp, row + 1
      ENDIF
     WITH nocounter, formfeed = none, maxrow = 1
    ;end select
    SET stat = alterlist(v_tabs->qual,v_tabs->qual_cnt)
   ELSEIF (i_detail=2)
    SELECT INTO mine
     FROM (dummyt d  WITH seq = value(v_tabs->qual_cnt))
     PLAN (d)
     ORDER BY v_tabs->qual[d.seq].tab_name
     HEAD REPORT
      col 50, "Pending Processing List", row + 1,
      col 0, "Status: "
      IF ((v_tabs->remaining_rows=0))
       col + 2, "Completed"
      ELSEIF ((v_tabs->ctxt_remaining_rows=0))
       col + 2, "Completed (Selected Contexts Only)"
      ELSEIF ((v_tabs->proc_cnt > 0))
       col + 2, "In Progress"
      ELSE
       col + 2, "Stalled"
      ENDIF
      row + 1, col 0, "Tables with warnings:",
      col 30, v_tabs->warning_tab, col + 2,
      "tables", row + 1, row + 1,
      col 0, "Table Name", col 32,
      "Rows to Process", row + 1
     DETAIL
      IF ((v_tabs->qual[d.seq].remaining_count > 0))
       col 0, v_tabs->qual[d.seq].tab_name, col 32,
       v_tabs->qual[d.seq].ctxt_remaining_count, row + 1
      ENDIF
     WITH nocounter, formfeed = none, maxrow = 1
    ;end select
   ELSEIF (i_detail=3)
    SET v_idx = 0
    SET v_loop_cnt = ceil((cnvtreal(v_tabs->qual_cnt)/ v_batch_size))
    SET v_pad_cnt = (v_loop_cnt * v_batch_size)
    SET stat = alterlist(v_tabs->qual,v_pad_cnt)
    FOR (i = (v_tabs->qual_cnt+ 1) TO v_pad_cnt)
      SET v_tabs->qual[i].tab_name = v_tabs->qual[v_tabs->qual_cnt].tab_name
    ENDFOR
    SELECT
     drs.ins_row_cnt, drs.upd_row_cnt, drs.del_row_cnt
     FROM dm_refchg_stat drs,
      (dummyt d  WITH seq = value(v_loop_cnt))
     PLAN (d
      WHERE initarray(v_estart,evaluate(d.seq,1,1,(v_estart+ v_batch_size))))
      JOIN (drs
      WHERE drs.source_env_id=i_source_env_id
       AND drs.stat_type="CUTOVER"
       AND expand(v_idx,v_estart,((v_estart+ v_batch_size) - 1),drs.table_name,v_tabs->qual[v_idx].
       tab_name))
     ORDER BY drs.table_name
     HEAD REPORT
      loc = 0, row + 1, col 0,
      "Cutover activity since the event ", gcsr_event_name, " was opened on ",
      gcsr_event_dt_tm, row + 1, row + 1,
      col 0, "Number of processes running: ", v_tabs->proc_cnt,
      row + 1, col 0, "Completed Activity:",
      col 30, v_tabs->complete_tab, col + 2,
      "tables", col 55, v_tabs->complete_rows,
      col + 2, "rows", row + 1,
      col 0, "Remaining Activity", col 30,
      v_tabs->remaining_tab, col + 2, "tables",
      col 55, v_tabs->remaining_rows, col + 2,
      "rows", row + 1, col 0,
      "Tables with warnings:", col 30, v_tabs->warning_tab,
      col + 2, "tables", row + 1,
      row + 1, row + 1, col 0,
      "Table Name", col 32, "Inserted",
      col 42, "Updated", col 52,
      "Deleted", col 62, "Set Aside Manually",
      col 85, "Combined Away Values", col 110,
      "PTAM Set Aside", col 130, "Unique Constraint Violations",
      col 165, "Others", col 180,
      "Time Started", col 205, "Time Completed",
      row + 1, col 68, "(9000)",
      col 92, "(9002)", col 114,
      "(9003)", col 140, "(9004)",
      row + 1
     DETAIL
      v_index = locateval(loc,1,v_tabs->qual_cnt,drs.table_name,v_tabs->qual[loc].tab_name)
      IF ((v_tabs->qual[v_index].process_flag=2))
       col 0, v_tabs->qual[v_index].tab_name, v_temp = trim(cnvtstring(drs.ins_row_cnt)),
       col 32, v_temp, v_temp = trim(cnvtstring(drs.upd_row_cnt)),
       col 42, v_temp, v_temp = trim(cnvtstring(drs.del_row_cnt)),
       col 51, v_temp, v_temp = format(v_tabs->qual[v_index].start_date,";;q"),
       col 62, v_tabs->qual[v_index].9000_count, col 85,
       v_tabs->qual[v_index].9002_count, col 110, v_tabs->qual[v_index].9003_count,
       col 130, v_tabs->qual[v_index].9004_count, col 165,
       v_tabs->qual[v_index].9000up_count, col 180, v_temp,
       v_temp = format(v_tabs->qual[v_index].end_date,";;q"), col 205, v_temp,
       row + 1
      ENDIF
     WITH nocounter, formfeed = none, maxrow = 1,
      maxcol = 250
    ;end select
    SET stat = alterlist(v_tabs->qual,v_tabs->qual_cnt)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    SET message = window
   ELSE
    CALL video(n)
   ENDIF
 END ;Subroutine
 SUBROUTINE manage_context_to_set(i_context_to_pull)
   DECLARE s_while_ind = i2 WITH noconstant(1)
   DECLARE s_invalid_ind = i2
   SET s_while2_ind = 0
   WHILE (s_while2_ind=0)
     SET s_invalid_ind = 0
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="CONTEXT TO SET"
      DETAIL
       s_context_set = di.info_char
      WITH nocounter
     ;end select
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,"*** Manage RDDS Context ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,3,"Current Source Context(s) to Pull:")
     CALL text(10,3,"----------------------------------")
     IF (size(i_context_to_pull,1) > 100)
      SET s_str_first_100 = substring(1,100,i_context_to_pull)
      SET s_col_pos = findstring("::",s_str_first_100,1,1)
      SET s_str_format_100 = substring(1,(s_col_pos - 1),s_str_first_100)
      SET s_str_remain = substring(s_col_pos,size(i_context_to_pull,1),i_context_to_pull)
      CALL text(11,3,trim(s_str_format_100,3))
      CALL text(12,3,trim(s_str_remain,3))
     ELSE
      CALL text(11,3,i_context_to_pull)
     ENDIF
     CALL text(13,3,"Current Context to Set:")
     CALL text(14,3,"-----------------------")
     CALL text(15,3,s_context_set)
     CALL text(12,60,"** 'ALL' is not a valid Context to Set")
     CALL text(14,60,"** 'NULL' is only valid for Context to Set when Source ")
     CALL text(15,60,"   Context(s) to Pull is 'NULL'")
     CALL text(17,60,"** ':' is not allowed in Context to Set name")
     CALL clear(18,1)
     CALL text(18,3,"E=Edit, X=Exit, C=Continue")
     CALL accept(19,3,"P;CU","C"
      WHERE curaccept IN ("E", "C", "X"))
     SET s_user_option_set = curaccept
     CASE (s_user_option_set)
      OF "E":
       CALL clear(18,1)
       CALL text(18,3,"Edit Context to Set:")
       CALL accept(19,3,"P(24);CUH","")
       SET s_context_set = trim(curaccept,3)
       CALL clear(15,3,30)
       CALL text(15,3,s_context_set)
      OF "C":
       SET s_while2_ind = 1
      OF "X":
       RETURN(2)
     ENDCASE
     IF (findstring("::",i_context_to_pull) > 0
      AND findstring(concat(":",s_context_set,":"),concat(":",i_context_to_pull,":")) > 0)
      SET s_invalid_ind = 1
     ENDIF
     IF (i_context_to_pull != "NULL"
      AND s_context_set="NULL")
      SET s_invalid_ind = 1
     ENDIF
     IF (s_context_set="ALL")
      SET s_invalid_ind = 1
     ENDIF
     IF (findstring(":",s_context_set) > 0)
      SET s_invalid_ind = 1
     ENDIF
     IF (daf_is_blank(s_context_set))
      CALL text(23,3,"** Context to Set Must be Specified -- C=Continue, X=Exit")
      CALL accept(24,3,"P;CU","C"
       WHERE curaccept IN ("C", "X"))
      SET s_user_option_set_cont = curaccept
      CASE (s_user_option_set_cont)
       OF "X":
        RETURN(2)
       OF "C":
        SET s_while2_ind = 0
      ENDCASE
     ELSE
      IF (s_invalid_ind=0)
       UPDATE  FROM dm_info di
        SET di.info_char = trim(s_context_set,3), di.updt_applctx = reqinfo->updt_applctx, di
         .updt_cnt = (di.updt_cnt+ 1),
         di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task
          = reqinfo->updt_task
        WHERE di.info_domain="RDDS CONTEXT"
         AND di.info_name="CONTEXT TO SET"
        WITH nocounter
       ;end update
       IF (curqual=0)
        INSERT  FROM dm_info di
         SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXT TO SET", di.info_char = trim(
           s_context_set,3),
          di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
           curdate,curtime3),
          di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
         WITH nocounter
        ;end insert
       ENDIF
       IF (check_error("Can not load RDDS 'Context to Set' DM_INFO row") != 0)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET s_while2_ind = 1
       ELSE
        COMMIT
       ENDIF
      ELSE
       SET s_context_set = ""
       SET s_while2_ind = 0
      ENDIF
     ENDIF
     IF ((dm_err->err_ind > 0))
      SET s_while2_ind = 1
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_start_rdds_movers(dsrm_refresh_trig_ind)
   DECLARE srm_ptam_check = i4
   DECLARE srm_sc_explode = i4 WITH noconstant(1)
   DECLARE srm_dcl_check = i4
   DECLARE srm_dcl_stat = i4
   DECLARE srm_com_file_name = vc
   DECLARE srm_ksh_file_name = vc
   DECLARE srm_pw_string = vc
   DECLARE srm_execute_str = vc
   DECLARE srm_path_str = vc
   DECLARE srm_menu_mover = i4
   DECLARE srm_intr_mover = i4
   DECLARE srm_start_over = i4
   DECLARE srm_com_batch = vc
   DECLARE srm_cur_logfile = vc
   DECLARE srm_src_explode_ind = i2 WITH noconstant(1)
   DECLARE srm_avr_cnt = i4
   DECLARE srm_mvr_ctx_pull = vc
   DECLARE srm_mvr_ctx_end = i4
   DECLARE srm_mvr_ctx_len = i4
   DECLARE srm_temp_string = vc
   DECLARE srm_string_size = i2
   FREE RECORD srm_request
   RECORD srm_request(
     1 post_link_name = vc
     1 target_env_id = f8
     1 source_env_id = f8
   )
   IF (dm2_rdds_get_tgt_id(dm2_ref_data_doc)=0)
    GO TO exit_program
   ENDIF
   IF ((dm2_ref_data_doc->mock_target_id != dm2_ref_data_doc->env_target_id))
    CALL dm2_rdds_init_display(null)
    CALL box(1,1,7,132)
    CALL text(3,40,"***  Manage Data Movers ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(09,03,"This environment has been configured as a mock_target.")
    CALL text(10,03,"Any existing translations or sequence match rows will be used")
    CALL text(11,03,"in processing change log rows from the build_source to mock_target.")
    CALL text(14,03,"Do you want to continue (Y/N)?")
    CALL accept(14,40,"P;CU"," "
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     RETURN
    ENDIF
   ENDIF
   SET dm_err->eproc = "Executing dm2_rdds_val_reltn"
   EXECUTE dm2_rdds_val_reltn srm_env_id
   IF ((dm_err->err_ind > 0))
    GO TO exit_program
   ENDIF
   SET drcr_config_info->source_env_id = srm_env_id
   SET drcr_config_info->target_env_id = dmda_mr->env_id
   CALL drcr_check_all_config(drcr_config_info)
   IF ((drcr_config_info->error_ind=1))
    SET message = nowindow
    CALL disp_msg(drcr_config_info->error_msg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((drcr_config_info->config_complete_ind=0))
    SELECT INTO "MINE"
     HEAD REPORT
      srm_temp_string = fillstring(110,"*"), col 0, srm_temp_string,
      row + 1
     DETAIL
      srm_string_size = size(drcr_config_info->error_msg,1)
      WHILE (srm_string_size > 0)
        IF (srm_string_size > 110)
         srm_temp_string = trim(substring(1,110,drcr_config_info->error_msg),3), drcr_config_info->
         error_msg = substring(111,(srm_string_size - 110),drcr_config_info->error_msg),
         srm_string_size = size(drcr_config_info->error_msg,1)
        ELSE
         srm_temp_string = trim(drcr_config_info->error_msg,3), srm_string_size = 0
        ENDIF
        col 0, srm_temp_string, row + 1
      ENDWHILE
     FOOT REPORT
      srm_temp_string = fillstring(110,"*"), col 0, srm_temp_string,
      row + 1
     WITH nocounter
    ;end select
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM dm_env_reltn
    WHERE parent_env_id=srm_env_id
     AND (child_env_id=dmda_mr->env_id)
     AND relationship_type="PENDING TARGET AS MASTER"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET srm_ptam_check = curqual
   SELECT INTO "NL:"
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event_key="ENDPTAMMATCHHASHBACKFILL"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND drel.paired_environment_id=srm_env_id
     AND drel.event_dt_tm > cnvtdatetime(srm_open_event_dt_tm)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET srm_dcl_check = curqual
   SET srm_msg = dmda_disp_backfill_msgs(srm_sc_explode,srm_ptam_check,srm_dcl_check,0,1,
    srm_src_explode_ind)
   IF (srm_msg=0)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ELSEIF (srm_msg=1)
    RETURN
   ENDIF
   SET srm_menu_mover = 0
   SET srm_inter_mover = 0
   SELECT INTO "NL:"
    FROM dm_refchg_process drp
    WHERE drp.refchg_type="MOVER PROCESS"
     AND  NOT (drp.refchg_status IN ("WRITING HANG FILE", "ORPHANED MOVER", "HANGING MOVER"))
     AND drp.env_source_id=srm_env_id
     AND drp.rdbhandle_value IN (
    (SELECT
     audsid
     FROM gv$session))
    DETAIL
     srm_inter_mover = (srm_inter_mover+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   WHILE (srm_start_over=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Manage Data Movers ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,3,concat(" Number of movers running: ",cnvtstring(srm_inter_mover)))
     CALL text(12,3,
      "    How many movers do you want to start (This is in addition to any movers which may already be"
      )
     CALL text(13,3,
      "     running. If you would like to reduce the number of movers running then you must")
     CALL text(14,3,"     first stop all movers): ")
     CALL accept(14,35,"999",0)
     SET srm_num_mover = curaccept
     SET srm_info_domain = concat("MERGE",trim(cnvtstring(srm_env_id)),trim(cnvtstring(dmda_mr->
        env_id)))
     SET srm_tot_domain = concat("MERGE*",trim(cnvtstring(dmda_mr->env_id)))
     IF (cursys="AXP")
      CALL text(16,3,"    Which batch queue would you like this COM proc submitted to?")
      CALL accept(16,70,"P(30);c")
      SET srm_com_batch = curaccept
     ENDIF
     CALL text(24,3,"Continue? [(Y)es / (N)o / e(X)it]")
     CALL accept(24,38,"P;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     SET no_confirm = 0
     IF (curaccept="N")
      SET srm_start_over = 0
     ELSEIF (curaccept="X")
      SET srm_start_over = 1
      SET no_confirm = 1
     ELSEIF (curaccept="Y")
      IF (srm_num_mover < 1)
       CALL text(24,3,"You have chosen to start 0 movers.  Please enter a value more than 0.")
       CALL accept(24,74,"P;HCU","N")
       SET srm_start_over = 0
      ELSE
       SET srm_start_over = 1
       SET dm_err->eproc = "Update RDDS MOVERS TO RUN in table DM_INFO"
       CALL disp_msg(" ",dm_err->logfile,0)
       UPDATE  FROM dm_info
        SET info_number = srm_num_mover, updt_dt_tm = sysdate, updt_cnt = (updt_cnt+ 1)
        WHERE info_domain=patstring(srm_info_domain)
         AND info_name="RDDS MOVERS TO RUN"
        WITH nocounter
       ;end update
       IF (curqual=0)
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
        ENDIF
        INSERT  FROM dm_info
         SET info_number = srm_num_mover, info_domain = srm_info_domain, info_name =
          "RDDS MOVERS TO RUN",
          updt_dt_tm = sysdate, updt_cnt = 0
         WITH nocounter
        ;end insert
       ENDIF
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN
       ENDIF
       SET srm_msg = dmda_disp_backfill_msgs(srm_sc_explode,srm_ptam_check,srm_dcl_check,1,1,
        srm_src_explode_ind)
       IF (srm_msg=0)
        ROLLBACK
        SET message = nowindow
        CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
        GO TO exit_program
       ELSEIF (srm_msg=1)
        ROLLBACK
        CALL clear(1,1)
        SET dm_err->eproc = "User chose not to run correct DCL script"
        CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
        RETURN
       ELSEIF (srm_msg=2)
        COMMIT
        SET dm_err->eproc = "Correcting dm_chg_log for the Pending Target as Master environment"
        CALL disp_msg(" ",dm_err->logfile,0)
        SET dcl_request->target_id = srm_env_id
        SET dcl_request->log_id = 0
        EXECUTE dm_rmc_correct_dcl  WITH replace("REQUEST","DCL_REQUEST"), replace("REPLY",
         "DCL_REPLY")
        IF ((dcl_reply->status_data.status="F"))
         SET message = nowindow
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         GO TO exit_program
        ENDIF
        SELECT INTO "NL:"
         FROM dm_rdds_event_log drel
         WHERE drel.rdds_event_key="ENDPTAMMATCHHASHBACKFILL"
          AND (drel.cur_environment_id=dmda_mr->env_id)
          AND drel.paired_environment_id=srm_env_id
          AND drel.event_dt_tm > cnvtdatetime(srm_open_event_dt_tm)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         SET message = nowindow
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        IF (curqual=0)
         SET message = nowindow
         SET dm_err->eproc = "Checking event row for PK VersID Backfill (ENDPTAMMATCHHASHBACKFILL)"
         SET dm_err->emsg = "PK VersID Backfill has not been completed; cannot start movers"
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         GO TO exit_program
        ENDIF
       ENDIF
       SELECT INTO "nl:"
        FROM dm_info d
        WHERE d.info_domain IN ("DM_STAT_GATHER", "DATA MANAGEMENT")
         AND d.info_name IN ("DM2_CYCLE_DATA_MOVERS", "RDDS CYCLE MOVER FREQUENCY")
        DETAIL
         IF (d.info_domain="DATA MANAGEMENT"
          AND d.info_name="RDDS CYCLE MOVER FREQUENCY")
          srm_info_number = d.info_number
         ELSEIF (d.info_domain="DM_STAT_GATHER"
          AND d.info_name="DM2_CYCLE_DATA_MOVERS")
          srm_m_exist = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (check_error("Query 'DM2_CYCLE_DATA_MOVERS' from dm_info table") != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (srm_m_exist=0)
        INSERT  FROM dm_info
         SET info_domain = "DM_STAT_GATHER", info_name = "DM2_CYCLE_DATA_MOVERS", info_number =
          srm_info_number,
          info_char = "ROUTINE", info_date = sysdate
         WITH nocounter
        ;end insert
        IF (check_error("Insert into table dm_info") != 0)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        COMMIT
       ENDIF
       SET message = nowindow
       COMMIT
       IF ((dm_err->err_ind=1))
        GO TO exit_program
       ENDIF
       FOR (srm_ndx = 1 TO srm_num_mover)
         SET srm_cur_logfile = dm_err->unique_fname
         IF (get_unique_file("rdds_run_mover",".log")=0)
          SET nohup_submit_logfile = "rdds_run_mover.log"
          SET dm_err->err_ind = 0
         ELSE
          SET nohup_submit_logfile = dm_err->unique_fname
         ENDIF
         SET dm_err->unique_fname = srm_cur_logfile
         IF (cursys="AXP")
          SET srm_execute_str = concat("SUBMIT /QUE=",srm_com_batch,
           " cer_proc:rdds_run_mover.com /param=(",trim(cnvtstring(srm_env_id)),".0,",
           dmda_connect_info->db_password,",",dmda_connect_info->db_sid,") /log=CCLUSERDIR:",
           nohup_submit_logfile)
         ELSE
          SET srm_execute_str = concat("nohup $cer_proc/rdds_run_mover.ksh ",trim(cnvtstring(
             srm_env_id)),".0 ",dmda_connect_info->db_password," ",
           dmda_connect_info->db_sid," > $CCLUSERDIR/",nohup_submit_logfile," 2>&1 &")
         ENDIF
         CALL dcl(srm_execute_str,size(srm_execute_str),srm_dcl_stat)
         IF (srm_dcl_stat=0)
          SET dm_err->eproc = concat("Error connecting to: ",srm_dcl_stat)
          CALL disp_msg(" ",dm_err->logfile,0)
          GO TO exit_program
         ENDIF
       ENDFOR
       CALL mc_confirm_screen("merge",srm_num_mover)
      ENDIF
     ENDIF
   ENDWHILE
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Starting RDDS Movers"
   SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
   SET auto_ver_request->qual[1].paired_environment_id = srm_env_id
   SET auto_ver_request->qual[1].event_reason = "Movers starting through menu"
   SET srm_avr_cnt = 1
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,srm_avr_cnt)
   SET auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_detail1_txt =
   "Number of Movers Started"
   SET auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_value = srm_num_mover
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE info_domain="RDDS CONTEXT"
     AND info_name IN ("CONTEXTS TO PULL", "CONTEXT TO SET", "CONTEXT GROUP_IND", "DEFAULT CONTEXT")
    DETAIL
     IF (d.info_name IN ("CONTEXT TO SET", "DEFAULT CONTEXT"))
      srm_avr_cnt = (srm_avr_cnt+ 1), stat = alterlist(auto_ver_request->qual[1].detail_qual,
       srm_avr_cnt), auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_detail1_txt = d
      .info_name,
      auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_detail2_txt = d.info_char
     ELSEIF (d.info_name="CONTEXT GROUP_IND")
      srm_avr_cnt = (srm_avr_cnt+ 1), stat = alterlist(auto_ver_request->qual[1].detail_qual,
       srm_avr_cnt), auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_detail1_txt = d
      .info_name,
      auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_value = d.info_number
     ELSEIF (d.info_name="CONTEXTS TO PULL")
      srm_mvr_ctx_pull = d.info_char
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Query dm_info for RDDS CONTEXT information") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET srm_mvr_ctx_end = 0
   WHILE (srm_mvr_ctx_end=0)
     IF (size(srm_mvr_ctx_pull,1) > 250)
      SET srm_avr_cnt = (srm_avr_cnt+ 1)
      SET srm_mvr_ctx_len = findstring("::",substring(1,250,srm_mvr_ctx_pull),1,1)
      SET stat = alterlist(auto_ver_request->qual[1].detail_qual,srm_avr_cnt)
      SET auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_detail1_txt = "CONTEXTS TO PULL"
      SET auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_detail2_txt = substring(1,(
       srm_mvr_ctx_len - 1),srm_mvr_ctx_pull)
      SET srm_mvr_ctx_pull = substring(srm_mvr_ctx_len,(size(srm_mvr_ctx_pull,1) - srm_mvr_ctx_len),
       srm_mvr_ctx_pull)
     ELSE
      SET srm_avr_cnt = (srm_avr_cnt+ 1)
      SET stat = alterlist(auto_ver_request->qual[1].detail_qual,srm_avr_cnt)
      SET auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_detail1_txt = "CONTEXTS TO PULL"
      SET auto_ver_request->qual[1].detail_qual[srm_avr_cnt].event_detail2_txt = srm_mvr_ctx_pull
      SET srm_mvr_ctx_end = 1
     ENDIF
   ENDWHILE
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET stat = initrec(auto_ver_reply)
    SET stat = initrec(auto_ver_request)
    GO TO exit_program
   ELSE
    SET message = nowindow
    COMMIT
    SET stat = initrec(auto_ver_reply)
    SET stat = initrec(auto_ver_request)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_manage_rdds_event(null)
   DECLARE dsmme_user_input = i2
   DECLARE dsmme_done_flag = i2
   DECLARE dsmme_open_event = vc WITH protect, noconstant("")
   DECLARE dsmme_oe_ind = i4 WITH protect, noconstant(0)
   DECLARE dsmme_open_dt_tm = vc WITH protect, noconstant("")
   DECLARE dmre_tmp_event_name = vc WITH protect, noconstant("")
   DECLARE dmre_tmp_src_env_name = vc WITH protect, noconstant("")
   DECLARE dmre_tmp_src_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmre_tmp_event_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE dmre_tmp_event_log_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmre_oe_task_ind = i4 WITH protect, noconstant(0)
   DECLARE dmre_task_err_ind = i4 WITH protect, noconstant(0)
   DECLARE dmre_oe_progress_msg = vc WITH protect, noconstant("")
   DECLARE dmre_mig_check = i2 WITH protect, noconstant(0)
   SET dsmme_done_flag = 0
   WHILE (dsmme_done_flag=0)
     SET stat = initrec(dmda_event_info)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL dmda_draw_event_box(7,75,1,dmda_event_info)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET help = off
      SET validate = off
      SET dsmme_done_flag = 1
      RETURN(dsmme_done_flag)
     ENDIF
     CALL box(1,1,5,132)
     CALL text(3,44,"***  MANAGE RDDS EVENTS  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,"Please choose from the following options:")
     CALL text(9,3,"1 Open/Continue a RDDS event")
     CALL text(10,3,"2 View Open Event Status/Errors")
     CALL text(11,3,"3 Close an open RDDS event")
     CALL text(12,3,"4 View Open Event Report")
     CALL text(13,3,"5 Drop old $R tables")
     CALL text(15,3,"0 Exit")
     CALL accept(7,50,"9",0
      WHERE curaccept IN (1, 2, 3, 4, 5,
      0))
     SET dsmme_user_input = curaccept
     CASE (dsmme_user_input)
      OF 1:
       CALL dmda_open_rdds_event(0.0)
      OF 2:
       CALL drtq_view_task_process("OPEN EVENT PROCESS")
       SET message = window
      OF 3:
       CALL dmda_close_rdds_event(null)
      OF 4:
       CALL dmda_open_evt_rpt(null)
      OF 5:
       SET dmre_mig_check = dmda_check_mig_settings(0,dmda_event_info->event_name,"drop old $R")
       IF (((dmre_mig_check=1) OR ((dm_err->err_ind=1))) )
        SET dsmme_done_flag = 1
       ELSE
        CALL dmda_drop_old_r(null)
       ENDIF
      OF 0:
       SET dsmme_done_flag = 1
       SET help = off
       SET validate = off
     ENDCASE
   ENDWHILE
   SET stat = initrec(dmda_event_info)
 END ;Subroutine
 SUBROUTINE dmda_open_rdds_event(ore_src_env_id)
   DECLARE dmoe_done_flag = i2
   DECLARE dmoe_new_event_name = vc
   DECLARE dmoe_open_event = vc
   DECLARE dmoe_open_source = f8
   DECLARE dmoe_tgt_env_name = vc
   DECLARE dmoe_exit_ind = i2
   DECLARE dmoe_ptam_setting = i2 WITH protect, noconstant(0)
   DECLARE oe_ptam_check = i2
   DECLARE oe_sc_explode = i2 WITH noconstant(1)
   DECLARE oe_dcl_check = i2
   DECLARE oe_msg = i2
   DECLARE oe_src_explode_ind = i2 WITH noconstant(1)
   DECLARE dmoe_ret_val = vc WITH protect, noconstant("")
   DECLARE dmoe_inprcs_ind = i2 WITH protect, noconstant(0)
   DECLARE dmoe_ptam_ind = i2 WITH protect, noconstant(0)
   DECLARE dmoe_skip_ind = i2 WITH protect, noconstant(0)
   DECLARE dmoe_ret_status = vc WITH protect, noconstant("")
   DECLARE dmoe_tmp_event_name = vc WITH protect, noconstant("")
   DECLARE dmoe_tmp_src_env_name = vc WITH protect, noconstant("")
   DECLARE dmoe_tmp_src_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmoe_accept = i4 WITH protect, noconstant(0)
   DECLARE dmoe_accept2 = vc WITH protect, noconstant("")
   DECLARE dmoe_counter = i2 WITH protect, noconstant(0)
   DECLARE dmoe_string_size = i2 WITH protect, noconstant(0)
   DECLARE dmoe_temp_string = vc WITH protect, noconstant("")
   DECLARE dmoe_auto_cut_ind = i2 WITH protect, noconstant(0)
   DECLARE dore_mig_check = i2 WITH protect, noconstant(0)
   IF (curgroup != 0)
    CALL clear(1,1)
    CALL text(15,3,
     "A new event cannot be opened because the current user does not have Group 0 privileges required to open an event."
     )
    CALL text(17,20,"Press ENTER to return to the previous menu.")
    CALL accept(17,64,"P;E"," ")
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ENDIF
   SET dm_err->eproc = "Check for in process open event"
   SET dmoe_inprcs_ind = drtq_check_task_process("OPEN EVENT PROCESS")
   IF (dmoe_inprcs_ind=4)
    SET dmoe_inprcs_ind = 1
   ELSEIF (dmoe_inprcs_ind=3)
    SET dmoe_inprcs_ind = 2
   ELSE
    SET dmoe_inprcs_ind = 0
    SELECT INTO "nl:"
     FROM dm_refchg_process drp
     WHERE refchg_type="RDDS OPEN EVENT"
      AND refchg_status="RDDS OPEN EVENT"
      AND rdbhandle_value IN (
     (SELECT
      audsid
      FROM gv$session))
     DETAIL
      dmoe_inprcs_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET help = off
     SET validate = off
     SET dmoe_exit_ind = 1
     RETURN(dmoe_exit_ind)
    ENDIF
   ENDIF
   IF (dmoe_inprcs_ind=1)
    CALL clear(1,1)
    SET message = window
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  RDDS Open Event  ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(9,3,"Due to an event already in progress an additional event cannot be started.")
    CALL text(21,3,"Press Enter to return to the previous menu.")
    CALL accept(21,45,"P;E"," ")
    SET dmda_drbb_request->dmoe_num_proc = 0
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ELSEIF (dmoe_inprcs_ind=2)
    SET dm_err->eproc = "Gathering task queue data for open event process"
    SELECT INTO "nl:"
     FROM dm_rdds_event_detail d
     WHERE d.dm_rdds_event_log_id IN (
     (SELECT
      l.dm_rdds_event_log_id
      FROM dm_rdds_event_log l
      WHERE l.rdds_event_key="TASKQUEUESTARTED"
       AND (l.cur_environment_id=dmda_mr->env_id)
       AND l.paired_environment_id=0
       AND l.event_reason="OPEN EVENT PROCESS"
       AND l.event_dt_tm IN (
      (SELECT
       max(l2.event_dt_tm)
       FROM dm_rdds_event_log l2
       WHERE (l2.cur_environment_id=dmda_mr->env_id)
        AND l2.paired_environment_id=0
        AND l2.rdds_event_key="TASKQUEUESTARTED"
        AND l2.event_reason="OPEN EVENT PROCESS"))))
     DETAIL
      IF (d.event_detail1_txt="EVENT_NAME")
       dmoe_tmp_event_name = d.event_detail2_txt
      ELSEIF (d.event_detail1_txt="EVENT_SOURCE_NAME")
       dmoe_tmp_src_env_name = d.event_detail2_txt
      ELSEIF (d.event_detail1_txt="EVENT_SOURCE_ID")
       dmoe_tmp_src_env_id = cnvtreal(d.event_detail2_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET help = off
     SET validate = off
     SET dmoe_exit_ind = 1
     RETURN(dmoe_exit_ind)
    ENDIF
    WHILE (dmoe_inprcs_ind=2)
      CALL clear(1,1)
      SET message = window
      SET width = 132
      CALL box(1,1,7,132)
      CALL text(3,40,"***  RDDS Open Event  ***")
      CALL text(5,20,"Environment Name:")
      CALL text(5,40,dmda_mr->env_name)
      CALL text(5,65,"Environment ID:")
      CALL text(5,85,cnvtstring(dmda_mr->env_id))
      CALL text(9,3,concat("Open event ",dmoe_tmp_event_name," has failed for the source ",
        dmoe_tmp_src_env_name," ",
        trim(cnvtstring(dmoe_tmp_src_env_id)),"."))
      CALL text(11,3,"Please choose from the following options:")
      CALL text(12,3,"1 View Open Event Status")
      CALL text(13,3,"2 Continue with current open event process")
      CALL text(14,3,"3 Start a new open event process")
      CALL text(16,3,"0 Exit")
      CALL accept(11,50,"9",0
       WHERE curaccept IN (1, 2, 3, 0))
      SET dmoe_accept = curaccept
      CASE (dmoe_accept)
       OF 1:
        CALL drtq_view_task_process("OPEN EVENT PROCESS")
       OF 2:
        SET dmoe_new_event_name = dmoe_tmp_event_name
        SET dmda_drbb_request->src_env_name = dmoe_tmp_src_env_name
        SET srm_env_id = dmoe_tmp_src_env_id
        SET dmoe_skip_ind = 1
        SET dmoe_inprcs_ind = 0
       OF 3:
        CALL clear(8,1)
        SET message = window
        SET width = 132
        CALL text(9,3,concat(
          "The open event process will start from the begining. Continue? [(Y)es / (N)o / e(X)it]"))
        CALL accept(9,91,"P;CU","Y"
         WHERE curaccept IN ("Y", "N", "X"))
        SET dmoe_accept2 = curaccept
        CASE (dmoe_accept2)
         OF "X":
          SET dmoe_inprcs_ind = 0
          SET dmoe_exit_ind = 0
          RETURN(dmoe_exit_ind)
         OF "N":
          SET dmoe_inprcs_ind = 2
         OF "Y":
          DELETE  FROM dm_rdds_event_log drel
           WHERE drel.rdds_event="Begin Reference Data Sync"
            AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
            AND (drel.cur_environment_id=dmda_mr->env_id)
            AND drel.paired_environment_id=dmoe_tmp_src_env_id
            AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
           (SELECT
            cur_environment_id, paired_environment_id, event_reason
            FROM dm_rdds_event_log
            WHERE (cur_environment_id=dmda_mr->env_id)
             AND paired_environment_id=dmoe_tmp_src_env_id
             AND rdds_event="End Reference Data Sync"
             AND rdds_event_key="ENDREFERENCEDATASYNC")))
           WITH nocounter
          ;end delete
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dsmme_done_flag = 1
           SET dmoe_inprcs_ind = 0
           SET dmoe_exit_ind = 1
           RETURN(dmoe_exit_ind)
          ENDIF
          SET dmoe_ret_status = drtq_delete_task_process("OPEN EVENT PROCESS")
          IF (dmoe_ret_status="F")
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dsmme_done_flag = 1
           SET dmoe_inprcs_ind = 0
           SET dmoe_exit_ind = 1
           RETURN(dmoe_exit_ind)
          ENDIF
          SET dmoe_skip_ind = 0
          SET dmoe_inprcs_ind = 0
        ENDCASE
       OF 0:
        SET dmoe_inprcs_ind = 0
        SET help = off
        SET validate = off
        SET dmoe_exit_ind = 0
        RETURN(dmoe_exit_ind)
      ENDCASE
    ENDWHILE
   ENDIF
   IF (ore_src_env_id=0
    AND dmoe_skip_ind=0)
    CALL get_src_env_id("Open An RDDS Event",1)
   ENDIF
   IF (srm_env_id=0)
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ENDIF
   IF (dmoe_skip_ind=0)
    SET dm_err->eproc = "Gathering source environment_name"
    SELECT INTO "nl:"
     FROM dm_environment d
     WHERE d.environment_id=srm_env_id
     DETAIL
      dmda_drbb_request->src_env_name = d.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET help = off
     SET validate = off
     SET dmoe_exit_ind = 1
     RETURN(dmoe_exit_ind)
    ENDIF
   ENDIF
   SET drcr_config_info->source_env_id = srm_env_id
   SET drcr_config_info->target_env_id = dmda_mr->env_id
   CALL drcr_check_all_config(drcr_config_info)
   IF ((drcr_config_info->error_ind=1))
    SET message = nowindow
    CALL disp_msg(drcr_config_info->error_msg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((drcr_config_info->config_complete_ind=0))
    CALL clear(1,1)
    SET dmoe_string_size = size(drcr_config_info->error_msg,1)
    SET dmoe_counter = 15
    WHILE (dmoe_string_size > 0)
      IF (dmoe_string_size > 110)
       SET dmoe_temp_string = trim(substring(1,110,drcr_config_info->error_msg),3)
       SET drcr_config_info->error_msg = substring(111,(dmoe_string_size - 110),drcr_config_info->
        error_msg)
       SET dmoe_string_size = size(drcr_config_info->error_msg,1)
      ELSE
       SET dmoe_temp_string = trim(drcr_config_info->error_msg,3)
       SET dmoe_string_size = 0
      ENDIF
      CALL text(dmoe_counter,3,dmoe_temp_string)
      SET dmoe_counter = (dmoe_counter+ 1)
    ENDWHILE
    CALL text(dmoe_counter,20,"Press ENTER to return to the previous menu.")
    CALL accept(dmoe_counter,64,"P;E"," ")
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ENDIF
   SET drvc_request->current_env_id = dmda_mr->env_id
   SET drvc_request->paired_env_id = srm_env_id
   EXECUTE dm_rdds_version_check  WITH replace("REQUEST","DRVC_REQUEST"), replace("REPLY",
    "DRVC_REPLY")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Valid Status Ind: ",trim(cnvtstring(drvc_reply->valid_status_ind)))
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((drvc_reply->valid_status_ind=0))
    SET dm_err->emsg = concat("The event cannot be opened because ",drvc_reply->message)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL clear(1,1)
    CALL text(15,3,"A new event cannot be opened because: ")
    CALL text(16,3,drvc_reply->message)
    CALL text(17,20,"Press ENTER to return to the previous menu.")
    CALL accept(17,64,"P;E"," ")
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ENDIF
   SET dm_err->eproc = "Checking for an already open event"
   SELECT INTO "NL:"
    drel.event_reason, drel.paired_environment_id
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND drel.paired_environment_id != srm_env_id
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND paired_environment_id != srm_env_id
      AND rdds_event="End Reference Data Sync"
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     dmoe_open_event = drel.event_reason, dmoe_open_source = drel.paired_environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ENDIF
   IF (curqual=0)
    SELECT INTO "NL:"
     drel.event_reason, drel.paired_environment_id
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND (drel.cur_environment_id=dmda_mr->env_id)
      AND drel.paired_environment_id=srm_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE (cur_environment_id=dmda_mr->env_id)
       AND paired_environment_id=srm_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     DETAIL
      dmoe_open_event = drel.event_reason, dmoe_open_source = drel.paired_environment_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET help = off
     SET validate = off
     SET dmoe_exit_ind = 1
     RETURN(dmoe_exit_ind)
    ENDIF
    IF (curqual=0
     AND dmoe_skip_ind=0)
     SET dmoe_done_flag = 0
     WHILE (dmoe_done_flag=0)
       SET help = off
       SET validate = off
       CALL clear(23,1)
       SET message = window
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,7,132)
       CALL text(3,40,"*** Choose A New Event Name ***")
       CALL text(5,20,"Environment Name:")
       CALL text(5,40,dmda_mr->env_name)
       CALL text(5,65,"Environment ID:")
       CALL text(5,85,cnvtstring(dmda_mr->env_id))
       CALL text(8,3," Please create a new distinct RDDS event name. (0 to exit):")
       CALL accept(8,70,"P(30);CU","0")
       SET dmoe_new_event_name = trim(curaccept,3)
       SELECT INTO "NL:"
        der.event_reason
        FROM dm_info di,
         dm_rdds_event_log der
        PLAN (di
         WHERE di.info_domain="DATA MANAGEMENT"
          AND di.info_name="DM_ENV_ID")
         JOIN (der
         WHERE di.info_number=der.cur_environment_id
          AND der.rdds_event="Begin Reference Data Sync"
          AND der.rdds_event_key="BEGINREFERENCEDATASYNC"
          AND der.event_reason=dmoe_new_event_name)
        WITH nocounter
       ;end select
       IF (curqual != 0)
        CALL text(20,3,"That event name is already in use, please choose a new distinct event name.")
        CALL pause(3)
       ELSE
        SET dmoe_done_flag = 1
       ENDIF
       IF (dmoe_new_event_name="0")
        SET help = off
        SET validate = off
        SET dmoe_exit_ind = 1
        RETURN(dmoe_exit_ind)
       ENDIF
     ENDWHILE
    ELSEIF (dmoe_skip_ind=0)
     SET dm_err->emsg = concat("Event ",dmoe_open_event," for source environment: ",trim(cnvtstring(
        dmoe_open_source)),
      " is currently open. You cannot open a new RDDS event while another event is open.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL clear(1,1)
     CALL text(15,3,concat("Event: ",dmoe_open_event))
     CALL text(16,3,concat("For source environment: ",trim(cnvtstring(dmoe_open_source)),
       " is currently open."))
     CALL text(17,3,"You cannot open a new RDDS event while another event is open.")
     CALL text(18,20,"Press ENTER to return to the previous menu.")
     CALL accept(18,64,"P;E"," ")
     SET help = off
     SET validate = off
     SET dmoe_exit_ind = 1
     RETURN(dmoe_exit_ind)
    ENDIF
   ELSE
    SET dm_err->emsg = concat("Event ",dmoe_open_event," for source environment: ",trim(cnvtstring(
       dmoe_open_source)),
     " is currently open. You cannot open a new RDDS event while another event is open.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL clear(1,1)
    CALL text(15,3,concat("Event: ",dmoe_open_event))
    CALL text(16,3,concat("For source environment: ",trim(cnvtstring(dmoe_open_source)),
      " is currently open."))
    CALL text(17,3,"You cannot open a new RDDS event while another event is open.")
    CALL text(18,20,"Press ENTER to return to the previous menu.")
    CALL accept(18,64,"P;E"," ")
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ENDIF
   SET dore_mig_check = dmda_check_mig_settings(1,dmoe_new_event_name,"Open Event")
   IF (((dore_mig_check=1) OR ((dm_err->err_ind=1))) )
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Checking for PTAM status"
   SELECT INTO "NL:"
    FROM dm_env_reltn er
    WHERE (er.parent_env_id=drvc_request->paired_env_id)
     AND (er.child_env_id=drvc_request->current_env_id)
     AND er.relationship_type="PENDING TARGET AS MASTER"
   ;end select
   IF (curqual > 0)
    SET dmoe_ptam_ind = 1
   ELSE
    SET dmoe_ptam_ind = 0
   ENDIF
   SET dmoe_ret_val = connect_info_display(null)
   IF (dmoe_ret_val="N")
    RETURN(1)
   ELSE
    CALL clear(1,1)
    IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
     IF ((xxcclseclogin->loggedin != 1))
      CALL parser("cclseclogin go")
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = ""
       SET dm_err->err_ind = 0
      ENDIF
      IF ((xxcclseclogin->loggedin != 1))
       SET message = nowindow
       SET dm_err->eproc = "Open event process"
       SET dm_err->emsg = "User not logged in cclseclogin"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
     ENDIF
    ENDIF
    CALL dbase_connect(dmda_connect_info)
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg("Gathering connection information",dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (dmoe_skip_ind=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"*** Open An RDDS Event ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,3,concat("Would you like the ",dmoe_new_event_name,
       " event to use the cutover by context logic? [(Y)es/(N)o/e(X)it]"))
     CALL text(11,3,
      "The cutover by context logic allows only selected contexts that are merged into the temproary tables to be "
      )
     CALL text(12,3,
      "cutover, while leaving other contexts in the temporary tables alone.  Using this configuration means that you"
      )
     CALL text(13,3,"must maintain CONTEXT_NAME values that are being pulled by the RDDS mover.")
     SET accept = nopatcheck
     CALL accept(9,117,"P(5);CU","N")
     CASE (curaccept)
      OF "Y":
       SET dmda_drbb_request->cbc_ind = 1
      OF "N":
       SET dmda_drbb_request->cbc_ind = 0
      OF "X":
       SET dmoe_exit_ind = 1
       SET dsmme_done_flag = 1
       RETURN(dmoe_exit_ind)
     ENDCASE
     SET accept = patcheck
     SET dmoe_auto_cut_ind = drcr_get_cutover_config(srm_env_id,dmda_mr->env_id)
    ENDIF
    SET dmda_drbb_request->dmoe_num_proc = dmda_get_num_bbproc(null)
    IF ((dmda_drbb_request->dmoe_num_proc > 0))
     EXECUTE dm_rmc_bookmark_begin srm_env_id, dmda_mr->env_id, dmoe_new_event_name,
     1, dmoe_ptam_ind, 1
     IF (check_error_gui(dm_err->eproc,"Open An RDDS Event",dmda_mr->env_name,dmda_mr->env_id) != 0)
      SET help = off
      SET validate = off
      SET dmoe_exit_ind = 1
      RETURN(dmoe_exit_ind)
     ENDIF
     IF ((dmda_drbb_request->dmoe_num_proc > 0))
      SET message = window
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,5,132)
      CALL text(3,44,"***  Open An RDDS Event  ***")
      CALL text(4,75,"ENVIRONMENT ID:")
      CALL text(4,20,"ENVIRONMENT NAME:")
      CALL text(4,95,cnvtstring(dmda_mr->env_id))
      CALL text(4,40,dmda_mr->env_name)
      CALL text(7,3,concat("You have started ",trim(cnvtstring(dmda_drbb_request->dmoe_num_proc)),
        " processes to open the RDDS event."))
      CALL text(8,3,concat("You can view the status of the open event process in the View Open Event",
        " Status option in the MANAGE RDDS EVENTS menu."))
      CALL text(16,20,"Press ENTER to return to the previous menu.")
      CALL accept(16,64,"P;E"," ")
     ENDIF
     SET help = off
     SET validate = off
     SET dmoe_exit_ind = 0
     RETURN(dmoe_exit_ind)
    ENDIF
   ENDIF
   SET help = off
   SET validate = off
   SET dmoe_exit_ind = 0
   RETURN(dmoe_exit_ind)
 END ;Subroutine
 SUBROUTINE dmda_close_rdds_event(null)
   DECLARE dmce_done_flag = i2
   DECLARE dmce_old_event_name = vc
   DECLARE dcre_del_ind = i4 WITH protect, noconstant(0)
   DECLARE dcre_for_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcre_line = i4 WITH protect, noconstant(0)
   DECLARE dcre_old_event_id = f8 WITH protect, noconstant(0.0)
   CALL get_src_env_id("Close An RDDS Event",1)
   IF (srm_env_id=0)
    SET help = off
    SET validate = off
    RETURN
   ENDIF
   CALL clear(23,1)
   SET message = window
   CALL clear(1,1)
   SET width = 132
   SELECT INTO "NL:"
    drel.event_reason
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND drel.paired_environment_id=srm_env_id
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND paired_environment_id=srm_env_id
      AND rdds_event="End Reference Data Sync"
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     dcre_old_event_id = drel.dm_rdds_event_log_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL box(1,1,7,132)
    CALL text(8,3," There are no events for this relationship that are currently open.")
    CALL pause(3)
   ELSE
    CALL box(1,1,7,132)
    CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
    CALL text(3,40,"*** Choose An Event To Close ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(8,3," Please choose an RDDS event to close. (0 to exit):")
    CALL text(9,3," Use the help to view current event names that are currently open.")
    SET help =
    SELECT INTO "NL:"
     drel.event_reason
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND (drel.cur_environment_id=dmda_mr->env_id)
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE (cur_environment_id=dmda_mr->env_id)
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET help = off
     SET validate = off
     RETURN
    ENDIF
    SET validate =
    SELECT INTO "NL:"
     drel.event_reason
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND (drel.cur_environment_id=dmda_mr->env_id)
      AND drel.event_reason=trim(curaccept,3)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET help = off
     SET validate = off
     RETURN
    ENDIF
    CALL accept(8,70,"P(30);CU","0")
    SET dmce_old_event_name = trim(curaccept,3)
    IF (dmce_old_event_name="0")
     SET help = off
     SET validate = off
     RETURN
    ENDIF
    SET help = off
    SET validate = off
    IF (dm_close_event_chk(dmda_mr->env_name,dmda_mr->env_id,dcre_old_event_id)=1)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Close An RDDS Event ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     IF (size(r_table->r_cleanup,5) > 0)
      CALL text(8,3,concat(
        "Uncutover $R rows will also be purged for the following Source environments ",
        "which do not have a valid RDDS relationship."))
      CALL text(10,3,"Environment Name (Environment ID)")
     ENDIF
     SET dcre_line = 10
     FOR (dcre_for_cnt = 1 TO size(r_table->r_cleanup,5))
      SET dcre_line = (dcre_line+ 1)
      CALL text(dcre_line,3,r_table->r_cleanup[dcre_for_cnt].message)
     ENDFOR
     SET dcre_line = (dcre_line+ 2)
     CALL text(dcre_line,3,concat("Are you sure you want to close the ",dmce_old_event_name,
       " event? (Y/N)"))
     SET dcre_line = (dcre_line+ 1)
     CALL accept(dcre_line,65,"P;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="N")
      SET help = off
      SET validate = off
      RETURN
     ENDIF
     EXECUTE dm_rmc_bookmark_end srm_env_id, dmda_mr->env_id, dmce_old_event_name
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   SET help = off
   SET validate = off
 END ;Subroutine
 SUBROUTINE dmda_drop_old_r(null)
   SET message = nowindow
   SELECT INTO "NL:"
    drel.event_reason, drel.paired_environment_id
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND paired_environment_id=drel.paired_environment_id
      AND rdds_event="End Reference Data Sync"
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET help = off
    SET validate = off
    RETURN
   ENDIF
   IF (curqual=0)
    SET drop_request->drop_after_day = 30
    EXECUTE dm_rmc_drop_old_r  WITH replace("REQUEST","DROP_REQUEST")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ELSE
    SET dm_err->emsg =
    "There is an open event for the current environment.  $Rs can not be deleted until the event is closed."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL clear(1,1)
    CALL text(15,3,
     "There is an open event for the current environment.  $Rs can not be deleted until the event is closed."
     )
    CALL text(16,20,"Press ENTER to return to the previous menu.")
    CALL accept(16,64,"P;E"," ")
    SET help = off
    SET validate = off
    RETURN
   ENDIF
   SET help = off
   SET validate = off
   CALL clear(1,1)
   SET message = window
 END ;Subroutine
 SUBROUTINE dmda_setup_and_monitor(null)
   DECLARE dsam_back = i2
   DECLARE dsam_ret_val = c1
   DECLARE dsam_val = i4
   DECLARE dsam_mig_check = i2 WITH protect, noconstant(0)
   WHILE (dsam_back=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,43,"***  RDDS STATUS AND MONITORING TOOLS  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,"Please choose from the following options:")
     CALL text(9,3,"1 RDDS Status Reports")
     CALL text(10,3,"2 Manage Monitoring Preferences")
     CALL text(11,3,"3 RDDS Reference Data Audit")
     CALL text(12,3,"4 RDDS Change Log Diagnostic Utility")
     CALL text(13,3,"5 RDDS Content Across Contexts Report")
     CALL text(14,3,"6 View Existing Child Exceptions")
     CALL text(15,3,"7 Reset Existing Child Exceptions")
     CALL text(16,3,"8 Dual Build Reports/Configuration")
     CALL text(18,3,"0 Exit")
     CALL dmda_draw_event_box(8,75,0,dmda_event_info)
     CALL accept(7,50,"99",0
      WHERE curaccept IN (1, 2, 3, 4, 5,
      6, 7, 8, 0))
     CASE (curaccept)
      OF 1:
       EXECUTE dm_auto_verify_rpt
       IF ((dm_err->err_ind=1))
        GO TO exit_program
       ENDIF
      OF 2:
       CALL dmda_monitor_tools(null)
      OF 3:
       SET dsam_mig_check = dmda_check_mig_settings(1,dmda_event_info->event_name,"RDDS Audit")
       IF (((dsam_mig_check=1) OR ((dm_err->err_ind=1))) )
        SET dsam_back = 1
       ELSE
        CALL dmda_ref_data_audit(null)
       ENDIF
      OF 4:
       SET dsam_ret_val = confirm_display("TARGET",0)
       IF (dsam_ret_val="Y")
        SET dsam_mig_check = dmda_check_mig_settings(1,dmda_event_info->event_name,
         "RDDS Change Log Diagnostic")
        IF (((dsam_mig_check=1) OR ((dm_err->err_ind=1))) )
         SET dsam_back = 1
        ELSE
         EXECUTE dm_dcl_report  WITH replace("REPLY","DCL_REPLY")
         IF ((dm_err->err_ind=1))
          GO TO exit_program
         ENDIF
        ENDIF
       ENDIF
      OF 5:
       SET dsam_ret_val = confirm_display("SOURCE",0)
       IF (dsam_ret_val="Y")
        CALL dmda_content_context_rpt(null)
       ENDIF
      OF 6:
       SET dsam_ret_val = confirm_display("TARGET",0)
       IF (dsam_ret_val="Y")
        CALL dm_chld_xcptn_rpt(null)
       ENDIF
      OF 7:
       SET dsam_ret_val = confirm_display("TARGET",0)
       IF (dsam_ret_val="Y")
        SET dsam_val = dmda_reset_chld_xcptns(null)
        IF (dsam_val=1)
         SET dsam_back = 1
        ENDIF
       ENDIF
      OF 8:
       SET dsam_ret_val = confirm_display("TARGET",0)
       IF (dsam_ret_val="Y")
        SET message = nowindow
        SET dsam_val = dmda_dual_build_config(null)
        IF ((dsam_val=- (1)))
         SET dsam_back = 1
        ELSEIF (dsam_val=1)
         GO TO exit_program
        ENDIF
       ENDIF
      OF 0:
       SET dsam_back = 1
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_monitor_tools(null)
   DECLARE dmt_low = i4
   DECLARE dmt_high = i4
   DECLARE dmt_incr = i4 WITH constant(14)
   DECLARE dmt_choice = i4
   DECLARE dmt_total = i4
   DECLARE dmt_up = i4
   DECLARE dmt_down = i4
   DECLARE dmt_str = vc
   DECLARE dmt_num = i4
   DECLARE dmt_over = i4
   DECLARE dmt_sub_menu = i4
   DECLARE dmt_back_up = i4
   DECLARE dmt_while_prefix = i2
   DECLARE dmt_while_freq = i2
   DECLARE dmt_while_suppress = i2
   DECLARE dmt_set_prefix = vc
   DECLARE dmt_freq_choice = i4
   DECLARE dmt_suppress_time = i4
   DECLARE dmt_frequency_choice = vc
   DECLARE dmt_frequency_time = i4
   DECLARE dmt_prefix = vc
   DECLARE dmt_idx2 = i4
   DECLARE idx3 = i4
   DECLARE dmt_set_suppress = i4
   DECLARE dmt_email_set = i4
   DECLARE dmt_temp_supp = vc
   DECLARE dmt_idx = i4
   DECLARE dmt_temp_email = vc
   DECLARE dmt_temp_freq = vc
   DECLARE dmt_set_cnt = i4
   DECLARE dmt_edown = i4
   DECLARE dmt_elow = i4
   DECLARE dmt_eincr = i4 WITH constant(10)
   DECLARE dmt_ehigh = i4
   DECLARE dmt_etotal = i4
   DECLARE dmt_eover = i4
   DECLARE dmt_eup = i4
   DECLARE dmt_estr = vc
   DECLARE dmt_enum = i4
   DECLARE dmt_echoice = i4
   DECLARE dmt_delete_cur = i4
   DECLARE dmt_cp_idx = i4
   DECLARE dmt_schoice = i4
   DECLARE dmt_sdown = i4
   DECLARE dmt_slow = i4
   DECLARE dmt_sincr = i4 WITH constant(10)
   DECLARE dmt_sover = i4
   DECLARE dmt_shigh = i4
   DECLARE dmt_stotal = i4
   DECLARE dmt_sup = i4
   DECLARE dmt_sidx = i4
   DECLARE dmt_sidx2 = i4
   DECLARE dmt_sstr = vc
   DECLARE dmt_snum = i4
   DECLARE dmt_add_email_choice = i4
   DECLARE dmt_email_edit_choice = i4
   DECLARE dmt_freq_def = i4
   DECLARE dmt_freq_time_choice = i4
   DECLARE dmt_s_temp_id = vc
   DECLARE dmt_t_temp_id = vc
   DECLARE dmt_env_confirmed = i2 WITH protect, noconstant(0)
   DECLARE dmt_tgt_env_name = vc WITH protect, noconstant("")
   DECLARE dmt_tgt_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmt_env_str = vc WITH protect, noconstant("")
   DECLARE dmt_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmt_i = i4 WITH protect, noconstant(0)
   DECLARE dmt_idx2 = i4 WITH protect, noconstant(0)
   SET dmt_while_prefix = 0
   SET dmt_while_freq = 0
   SET dmt_while_suppress = 0
   SET dmt_choice = 0
   FREE RECORD dmt_env
   RECORD dmt_env(
     1 cnt = i4
     1 qual[*]
       2 source_id = f8
       2 source_name = vc
       2 target_id = f8
       2 target_name = vc
       2 setup_pos = i4
   ) WITH protect
   WHILE (dmt_env_confirmed=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
     CALL text(3,40,concat("*** RDDS STATUS AND MONITORING TOOLS ***"))
     CALL text(4,20,"Environment Name:")
     CALL text(4,40,dmda_mr->env_name)
     CALL text(4,65,"Environment ID:")
     CALL text(4,85,cnvtstring(dmda_mr->env_id))
     CALL text(7,3,
      "Please input environment id you would like to set-up monitoring preferences for (Enter 0 to exit):"
      )
     SET help =
     SELECT INTO "nl:"
      de.environment_id, de.environment_name
      FROM dm_environment de
      WHERE ((de.environment_id > 0) UNION (
      (SELECT
       environment_id = 0, environment_name = "(Exit)"
       FROM dual)))
      ORDER BY 2
      WITH nocounter
     ;end select
     SET validate =
     SELECT INTO "nl:"
      de.environment_id
      FROM dm_environment de
      WHERE ((de.environment_id=cnvtreal(curaccept)) UNION (
      (SELECT
       child_env_id = 0
       FROM dual
       WHERE cnvtreal(curaccept)=0)))
      WITH nocounter
     ;end select
     SET validate = 2
     CALL accept(7,105,"N(15);CU","0")
     CALL clear(23,1)
     SET dmt_tgt_env_id = cnvtreal(trim(curaccept,3))
     SET validate = off
     IF (dmt_tgt_env_id=0)
      SET dmt_env_confirmed = 1
     ELSE
      SET dm_err->eproc = "Gathering environment name"
      SELECT INTO "nl:"
       FROM dm_environment d
       WHERE d.environment_id=dmt_tgt_env_id
       DETAIL
        dmt_tgt_env_name = d.environment_name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      SET dm_err->eproc = "Filling out default values"
      SELECT INTO "nl:"
       FROM dm2_admin_dm_info dadi
       WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
        AND dadi.info_name="Report Frequency"
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm2_admin_dm_info dadi
        SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi.info_name =
         "Report Frequency", dadi.info_char = "Daily",
         dadi.info_number = 6
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        GO TO exit_program
       ELSE
        COMMIT
       ENDIF
      ENDIF
      SELECT INTO "nl:"
       FROM dm2_admin_dm_info dadi
       WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
        AND dadi.info_name="Suppression Duration"
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm2_admin_dm_info dadi
        SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi.info_name =
         "Suppression Duration", dadi.info_number = 2
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        GO TO exit_program
       ELSE
        COMMIT
       ENDIF
      ENDIF
      SET dmt_sub_menu = 0
      WHILE (dmt_sub_menu=0)
        SET width = 132
        SET message = window
        CALL clear(1,1)
        CALL box(1,1,5,132)
        CALL text(3,45,"***  MONITORING PREFERENCES SETUP  ***")
        CALL text(4,20,"Environment Name:")
        CALL text(4,40,dmt_tgt_env_name)
        CALL text(4,65,"Environment ID:")
        CALL text(4,85,cnvtstring(dmt_tgt_env_id))
        CALL text(7,3,"Please choose from the following options:")
        CALL text(9,3,"1 View current settings")
        CALL text(10,3,"2 Manage E-Mail addresses")
        CALL text(11,3,"3 Manage warning message suppression")
        CALL text(12,3,"4 Manage status report frequency")
        CALL text(13,3,"5 Manage E-Mail subject prefix")
        CALL text(14,3,"6 Replicate monitoring preferences from another environment")
        CALL text(15,3,"7 Send test E-Mail")
        CALL text(17,3,"0 Exit")
        CALL accept(7,50,"99",0
         WHERE curaccept IN (1, 2, 3, 4, 5,
         6, 7, 0))
        CASE (curaccept)
         OF 1:
          SET dm_err->eproc = "View current settings"
          FREE RECORD dmt_view
          RECORD dmt_view(
            1 cnt = i4
            1 prefix = vc
            1 suppress = i4
            1 frequency = vc
            1 frequency_time = i4
            1 qual[*]
              2 email = vc
          ) WITH protect
          SET dmt_s_temp_id = ""
          SET dmt_t_temp_id = ""
          SELECT INTO "nl:"
           FROM dm2_admin_dm_info dadi
           WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
           ORDER BY dadi.info_name
           HEAD REPORT
            dmt_view->cnt = 0
           DETAIL
            IF (dadi.info_char="E-Mail Address")
             dmt_view->cnt = (dmt_view->cnt+ 1)
             IF (mod(dmt_view->cnt,10)=1)
              stat = alterlist(dmt_view->qual,(dmt_view->cnt+ 9))
             ENDIF
             dmt_view->qual[dmt_view->cnt].email = dadi.info_name
            ELSEIF (dadi.info_name="Report Frequency")
             dmt_view->frequency = dadi.info_char
             IF (dadi.info_char="Daily")
              dmt_view->frequency_time = dadi.info_number
             ENDIF
            ELSEIF (dadi.info_name="Suppression Duration")
             dmt_view->suppress = dadi.info_number
            ELSEIF (dadi.info_name="E-Mail Subject Prefix")
             dmt_view->prefix = dadi.info_char
            ENDIF
           FOOT REPORT
            stat = alterlist(dmt_view->qual,dmt_view->cnt)
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ENDIF
          SET dmt_t_temp_id = concat(trim(dmt_tgt_env_name)," (",trim(cnvtstring(dmt_tgt_env_id)),")"
           )
          IF ((dmt_view->frequency="Daily"))
           SET dmt_temp_freq = concat(trim(dmt_view->frequency)," at ",trim(cnvtstring(dmt_view->
              frequency_time)),":00"," (24hr clock)")
          ELSE
           SET dmt_temp_freq = trim(dmt_view->frequency)
          ENDIF
          SET dmt_temp_supp = trim(cnvtstring(dmt_view->suppress))
          SET message = nowindow
          SELECT
           *
           FROM (dummyt d  WITH seq = value(dmt_view->cnt))
           HEAD REPORT
            rpt_loop = 0, col 50, "CURRENT SETTINGS FOR",
            row + 1, col 42, "ENVIRONMENT:",
            col 57, dmt_t_temp_id, row + 2,
            col 2, "Warning Suppression Time in hours: ", col 37,
            dmt_temp_supp, row + 1, col 2,
            "Status Report Frequency: ", col 28, dmt_temp_freq,
            row + 1, col 2, "E-Mail Prefix: "
            IF (daf_is_not_blank(dmt_view->prefix))
             col 18, dmt_view->prefix
            ELSE
             col 18, "Not Set"
            ENDIF
            row + 1, col 2, "E-Mail Addresses:",
            row + 1
           DETAIL
            rpt_loop = (rpt_loop+ 1)
            IF ((dmt_view->cnt > 0))
             row + 1, col 2, dmt_view->qual[rpt_loop].email
            ENDIF
           FOOT REPORT
            row + 2, col 2, "End of Report"
           WITH nocounter, formfeed = none, maxrow = 1
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ENDIF
          SET message = window
         OF 2:
          SET dmt_email_set = 0
          WHILE (dmt_email_set=0)
            FREE RECORD dmt_email
            RECORD dmt_email(
              1 cnt = i4
              1 qual[*]
                2 email = vc
            ) WITH protect
            SET dm_err->eproc = "Setting up e-mails"
            SET stat = alterlist(dmt_email->qual,0)
            SELECT INTO "nl:"
             FROM dm2_admin_dm_info dadi
             WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
              AND dadi.info_char="E-Mail Address"
             ORDER BY dadi.info_name
             HEAD REPORT
              dmt_email->cnt = 0
             DETAIL
              dmt_email->cnt = (dmt_email->cnt+ 1)
              IF (mod(dmt_email->cnt,10)=1)
               stat = alterlist(dmt_email->qual,(dmt_email->cnt+ 9))
              ENDIF
              dmt_email->qual[dmt_email->cnt].email = dadi.info_name
             FOOT REPORT
              stat = alterlist(dmt_email->qual,dmt_email->cnt)
             WITH nocounter
            ;end select
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             GO TO exit_program
            ENDIF
            SET dmt_elow = 1
            SET dmt_etotal = dmt_email->cnt
            IF (dmt_etotal < dmt_eincr)
             SET dmt_ehigh = dmt_etotal
            ELSE
             SET dmt_ehigh = dmt_eincr
            ENDIF
            SET dmt_eup = 0
            SET dmt_edown = 0
            SET dmt_echoice = 0
            WHILE (dmt_echoice=0)
              SET dmt_back_up = 0
              SET dmt_temp_email = ""
              CALL clear(1,1)
              CALL box(1,1,6,132)
              CALL text(2,50,"***  E-MAIL SETTINGS FOR  ***")
              CALL text(3,20,"Environment Name:")
              CALL text(3,40,dmt_tgt_env_name)
              CALL text(3,65,"Environment ID:")
              CALL text(3,85,cnvtstring(dmt_tgt_env_id))
              CALL text(5,2,"Line #")
              CALL text(5,30,"E-MAIL")
              IF (dmt_edown=1)
               SET dmt_elow = (dmt_elow+ dmt_eincr)
               IF (((dmt_ehigh+ dmt_eincr) > dmt_etotal))
                SET dmt_eover = ((dmt_ehigh+ dmt_eincr) - dmt_etotal)
                SET dmt_ehigh = dmt_etotal
               ELSE
                SET dmt_eover = 0
                SET dmt_ehigh = (dmt_ehigh+ dmt_eincr)
               ENDIF
              ELSEIF (dmt_eup=1)
               IF (((dmt_elow - dmt_eincr) >= 1))
                SET dmt_elow = (dmt_elow - dmt_eincr)
                SET dmt_ehigh = ((dmt_ehigh - dmt_eincr)+ dmt_eover)
                SET dmt_eover = 0
               ENDIF
              ENDIF
              SET dmt_eup = 0
              SET dmt_edown = 0
              SET row_num = 7
              FOR (idx = dmt_elow TO dmt_ehigh)
                CALL text(row_num,2,concat(trim(cnvtstring(idx)),")"))
                CALL text(row_num,20,dmt_email->qual[idx].email)
                SET row_num = (row_num+ 1)
              ENDFOR
              IF (((dmt_elow+ dmt_eincr) <= dmt_etotal))
               CALL text(22,3,"D) Page Down")
              ENDIF
              IF (dmt_elow > dmt_eincr)
               CALL text(21,3,"U) Page Up")
              ENDIF
              CALL text(24,3,"0) Exit")
              CALL text(23,3,"A-Add,E-Edit,R-Remove")
              CALL accept(23,25,"PPP;CU","0")
              SET dmt_estr = trim(curaccept)
              IF (dmt_estr IN ("R", "E"))
               IF (dmt_etotal > 0)
                CALL text(23,30,concat("Choose line # (",trim(cnvtstring(dmt_elow)),"-",trim(
                   cnvtstring(dmt_ehigh)),") to edit/remove"))
                CALL accept(23,67,"999"
                 WHERE curaccept >= dmt_elow
                  AND curaccept <= dmt_ehigh)
                SET dmt_enum = curaccept
                CALL text(23,72,"Continue ?( (Y)es/(N)o )")
                CALL accept(23,97,"P;CU","Y"
                 WHERE curaccept IN ("Y", "N"))
                IF (curaccept="N")
                 SET dmt_back_up = 1
                ENDIF
               ELSE
                SET dmt_back_up = 1
               ENDIF
              ENDIF
              IF (dmt_back_up=1)
               SET dmt_echoice = 1
              ELSE
               IF (dmt_estr="0")
                SET dmt_echoice = 1
                SET dmt_email_set = 1
               ELSEIF (dmt_estr="A")
                SET dmt_add_email_choice = 0
                WHILE (dmt_add_email_choice=0)
                  CALL clear(1,1)
                  CALL box(1,1,5,132)
                  CALL text(3,50,"***  ADD E-MAIL FOR  ***")
                  CALL text(4,45,concat("ENVIRONMENT: ",trim(dmt_tgt_env_name)," (",trim(cnvtstring(
                      dmt_tgt_env_id)),")"))
                  CALL text(11,40,"Please input an e-mail address and press enter")
                  CALL accept(10,10,"P(110);C"," ")
                  SET dmt_temp_email = trim(curaccept)
                  CALL text(14,10,"Continue ?( (Y)es/(N)o/e(X)it )")
                  CALL accept(14,43,"P;CU","Y"
                   WHERE curaccept IN ("Y", "N", "X"))
                  IF (curaccept="Y")
                   SET dmt_idx2 = 0
                   SET dmt_idx2 = locateval(idx3,1,dmt_email->cnt,dmt_temp_email,dmt_email->qual[idx3
                    ].email)
                   IF (dmt_idx2 > 0)
                    CALL text(20,10,"This e-mail already exists for the current environment")
                    CALL pause(5)
                    SET dmt_echoice = 1
                    SET dmt_add_email_choice = 1
                   ELSEIF (daf_is_not_blank(dmt_temp_email))
                    INSERT  FROM dm2_admin_dm_info dadi
                     SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi
                      .info_name = dmt_temp_email, dadi.info_char = "E-Mail Address"
                     WITH nocounter
                    ;end insert
                    IF (check_error(dm_err->eproc)=1)
                     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                     ROLLBACK
                     GO TO exit_program
                    ELSE
                     COMMIT
                     SET dmt_echoice = 1
                     SET dmt_add_email_choice = 1
                    ENDIF
                   ELSE
                    SET dmt_echoice = 1
                    SET dmt_add_email_choice = 1
                   ENDIF
                  ELSEIF (curaccept="X")
                   SET dmt_add_email_choice = 1
                   SET dmt_echoice = 1
                  ENDIF
                ENDWHILE
               ELSEIF (dmt_estr="R")
                DELETE  FROM dm2_admin_dm_info dadi
                 WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
                  AND dadi.info_char="E-Mail Address"
                  AND (dadi.info_name=dmt_email->qual[dmt_enum].email)
                 WITH nocounter
                ;end delete
                IF (check_error(dm_err->eproc)=1)
                 CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                 ROLLBACK
                 GO TO exit_program
                ELSE
                 COMMIT
                 SET dmt_echoice = 1
                ENDIF
               ELSEIF (dmt_estr="E")
                SET dmt_email_edit_choice = 0
                WHILE (dmt_email_edit_choice=0)
                  CALL clear(1,1)
                  CALL box(1,1,5,132)
                  CALL text(3,50,"***  EDIT E-MAIL FOR  ***")
                  CALL text(4,45,concat("ENVIRONMENT: ",trim(dmt_tgt_env_name)," (",trim(cnvtstring(
                      dmt_tgt_env_id)),")"))
                  CALL text(11,50,"Please edit the e-mail address and press enter")
                  CALL accept(10,10,"P(110);C",dmt_email->qual[dmt_enum].email
                   WHERE trim(curaccept) > "")
                  SET dmt_temp_email = trim(curaccept)
                  CALL text(14,10,"Continue? ( (Y)es/(N)o/e(X)it )")
                  CALL accept(14,43,"P;CU","Y"
                   WHERE curaccept IN ("Y", "N", "X"))
                  IF (curaccept="Y")
                   SET dmt_idx2 = 0
                   SET dmt_idx2 = locateval(idx3,1,dmt_email->cnt,dmt_temp_email,dmt_email->qual[idx3
                    ].email)
                   IF (dmt_idx2 > 0)
                    CALL text(20,10,
                     "This e-mail already exists for the current environment, nothing was modified")
                    CALL pause(5)
                    SET dmt_echoice = 1
                    SET dmt_email_edit_choice = 1
                   ELSE
                    UPDATE  FROM dm2_admin_dm_info dadi
                     SET dadi.info_name = dmt_temp_email
                     WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
                      AND dadi.info_char="E-Mail Address"
                      AND (dadi.info_name=dmt_email->qual[dmt_enum].email)
                     WITH nocounter
                    ;end update
                    IF (check_error(dm_err->eproc)=1)
                     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                     ROLLBACK
                     GO TO exit_program
                    ELSE
                     COMMIT
                     SET dmt_echoice = 1
                     SET dmt_email_edit_choice = 1
                    ENDIF
                   ENDIF
                  ELSEIF (curaccept="X")
                   SET dmt_echoice = 1
                   SET dmt_email_edit_choice = 1
                  ENDIF
                ENDWHILE
               ELSEIF (dmt_estr="U")
                IF (dmt_elow > dmt_eincr)
                 SET dmt_eup = 1
                ELSE
                 CALL text(23,58,"Invalid Entry")
                 CALL pause(2)
                ENDIF
               ELSEIF (dmt_estr="D")
                IF (((dmt_elow+ dmt_eincr) <= dmt_etotal))
                 SET dmt_edown = 1
                ELSE
                 CALL text(23,58,"Invalid Entry")
                 CALL pause(2)
                ENDIF
               ELSE
                CALL text(23,58,"Invalid Entry")
                CALL pause(2)
               ENDIF
              ENDIF
            ENDWHILE
          ENDWHILE
         OF 3:
          SET dmt_while_suppress = 0
          WHILE (dmt_while_suppress=0)
            SET dm_err->eproc = "Setting up Suppression Time"
            CALL clear(1,1)
            CALL box(1,1,5,132)
            CALL text(3,45,"***  SUPRESSION TIME SETTINGS FOR  ***")
            CALL text(4,45,concat("ENVIRONMENT: ",trim(dmt_tgt_env_name)," (",trim(cnvtstring(
                dmt_tgt_env_id)),")"))
            SELECT INTO "nl:"
             FROM dm2_admin_dm_info dadi
             WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
              AND dadi.info_name="Suppression Duration"
             DETAIL
              dmt_suppress_time = dadi.info_number
             WITH nocounter
            ;end select
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             GO TO exit_program
            ENDIF
            IF (curqual != 0)
             CALL text(7,21,concat(trim(cnvtstring(dmt_suppress_time))," hour(s)"))
            ELSE
             CALL text(7,21,"Not Set")
            ENDIF
            CALL text(7,3,"Current setting:")
            CALL text(9,3,"Similar messages should be suppressed for:")
            CALL text(9,51,"hour(s).")
            CALL accept(9,47,"999",dmt_suppress_time
             WHERE curaccept >= 0)
            SET dmt_set_suppress = curaccept
            CALL text(20,3,"Continue ? ( (Y)es/(N)o/e(X)it )")
            CALL accept(20,48,"A;CU","Y"
             WHERE curaccept IN ("Y", "N", "X"))
            IF (curaccept="Y")
             UPDATE  FROM dm2_admin_dm_info dadi
              SET dadi.info_number = dmt_set_suppress
              WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
               AND dadi.info_name="Suppression Duration"
              WITH nocounter
             ;end update
             IF (check_error(dm_err->eproc)=1)
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              ROLLBACK
              GO TO exit_program
             ELSE
              COMMIT
             ENDIF
             IF (curqual=0)
              INSERT  FROM dm2_admin_dm_info dadi
               SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi
                .info_name = "Suppression Duration", dadi.info_number = dmt_set_suppress,
                dadi.updt_cnt = 0, dadi.updt_dt_tm = sysdate, dadi.updt_applctx = reqinfo->
                updt_applctx,
                dadi.updt_id = reqinfo->updt_id, dadi.updt_task = reqinfo->updt_task
               WITH nocounter
              ;end insert
              IF (check_error(dm_err->eproc)=1)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               ROLLBACK
               GO TO exit_program
              ELSE
               COMMIT
              ENDIF
             ENDIF
             SET dmt_while_suppress = 1
            ELSEIF (curaccept="X")
             SET dmt_while_suppress = 1
            ENDIF
          ENDWHILE
         OF 4:
          SET dmt_while_freq = 0
          WHILE (dmt_while_freq=0)
            SET dm_err->eproc = "Setting up Frequency Time"
            CALL clear(1,1)
            CALL box(1,1,5,132)
            CALL text(3,45,"***  REPORT FREQUENCY SETTINGS FOR  ***")
            CALL text(4,45,concat("ENVIRONMENT: ",trim(dmt_tgt_env_name)," (",trim(cnvtstring(
                dmt_tgt_env_id)),")"))
            SELECT INTO "nl:"
             FROM dm2_admin_dm_info dadi
             WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
              AND dadi.info_name="Report Frequency"
             DETAIL
              dmt_frequency_choice = dadi.info_char
              IF (dadi.info_char="Daily")
               dmt_frequency_time = dadi.info_number
              ENDIF
             WITH nocounter
            ;end select
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             GO TO exit_program
            ENDIF
            IF (curqual != 0)
             CALL text(7,21,trim(dmt_frequency_choice))
             IF (dmt_frequency_choice="Daily")
              CALL text(7,28,concat("at ",trim(cnvtstring(dmt_frequency_time)),":00 (24hr clock)"))
             ENDIF
            ELSE
             CALL text(7,21,"Not Set")
            ENDIF
            SET dmt_freq_def = 0
            IF (dmt_frequency_choice="Never")
             SET dmt_freq_def = 1
            ELSEIF (dmt_frequency_choice="Daily")
             SET dmt_freq_def = 2
            ELSEIF (dmt_frequency_choice="Hourly")
             SET dmt_freq_def = 3
            ENDIF
            CALL text(7,3,"Current setting:")
            CALL text(9,3,"How often would you like to receive status reports ?")
            CALL text(11,3,"1 Never")
            CALL text(12,3,"2 Daily")
            CALL text(13,3,"3 Hourly")
            CALL accept(9,56,"99",dmt_freq_def
             WHERE curaccept IN (1, 2, 3))
            SET dmt_freq_choice = curaccept
            SET dmt_freq_time_choice = 0
            IF (dmt_freq_choice=2)
             CALL text(15,3,"At what hour would you like the notification sent ? (0-23): ")
             CALL accept(15,64,"99",dmt_frequency_time
              WHERE curaccept >= 0
               AND curaccept <= 23)
             SET dmt_freq_time_choice = curaccept
            ENDIF
            CALL text(20,3,"Continue ? ( (Y)es/(N)o/e(X)it )")
            CALL accept(20,50,"A;CU","Y"
             WHERE curaccept IN ("Y", "N", "X"))
            IF (curaccept="Y")
             CASE (dmt_freq_choice)
              OF 1:
               UPDATE  FROM dm2_admin_dm_info dadi
                SET dadi.info_char = "Never"
                WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
                 AND dadi.info_name="Report Frequency"
                WITH nocounter
               ;end update
               IF (check_error(dm_err->eproc)=1)
                CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                ROLLBACK
                GO TO exit_program
               ELSE
                COMMIT
               ENDIF
               IF (curqual=0)
                INSERT  FROM dm2_admin_dm_info dadi
                 SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi
                  .info_name = "Report Frequency", dadi.info_char = "Never",
                  dadi.updt_cnt = 0, dadi.updt_dt_tm = sysdate, dadi.updt_applctx = reqinfo->
                  updt_applctx,
                  dadi.updt_id = reqinfo->updt_id, dadi.updt_task = reqinfo->updt_task
                 WITH nocounter
                ;end insert
                IF (check_error(dm_err->eproc)=1)
                 CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                 ROLLBACK
                 GO TO exit_program
                ELSE
                 COMMIT
                ENDIF
               ENDIF
              OF 2:
               UPDATE  FROM dm2_admin_dm_info dadi
                SET dadi.info_char = "Daily", dadi.info_number = dmt_freq_time_choice
                WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
                 AND dadi.info_name="Report Frequency"
                WITH nocounter
               ;end update
               IF (check_error(dm_err->eproc)=1)
                CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                ROLLBACK
                GO TO exit_program
               ELSE
                COMMIT
               ENDIF
               IF (curqual=0)
                INSERT  FROM dm2_admin_dm_info dadi
                 SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi
                  .info_name = "Report Frequency", dadi.info_char = "Daily",
                  dadi.info_number = dmt_freq_time_choice, dadi.updt_cnt = 0, dadi.updt_dt_tm =
                  sysdate,
                  dadi.updt_applctx = reqinfo->updt_applctx, dadi.updt_id = reqinfo->updt_id, dadi
                  .updt_task = reqinfo->updt_task
                 WITH nocounter
                ;end insert
                IF (check_error(dm_err->eproc)=1)
                 CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                 ROLLBACK
                 GO TO exit_program
                ELSE
                 COMMIT
                ENDIF
               ENDIF
              OF 3:
               UPDATE  FROM dm2_admin_dm_info dadi
                SET dadi.info_char = "Hourly"
                WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
                 AND dadi.info_name="Report Frequency"
                WITH nocounter
               ;end update
               IF (check_error(dm_err->eproc)=1)
                CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                ROLLBACK
                GO TO exit_program
               ELSE
                COMMIT
               ENDIF
               IF (curqual=0)
                INSERT  FROM dm2_admin_dm_info dadi
                 SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi
                  .info_name = "Report Frequency", dadi.info_char = "Hourly",
                  dadi.updt_cnt = 0, dadi.updt_dt_tm = sysdate, dadi.updt_applctx = reqinfo->
                  updt_applctx,
                  dadi.updt_id = reqinfo->updt_id, dadi.updt_task = reqinfo->updt_task
                 WITH nocounter
                ;end insert
                IF (check_error(dm_err->eproc)=1)
                 CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                 ROLLBACK
                 GO TO exit_program
                ELSE
                 COMMIT
                ENDIF
               ENDIF
             ENDCASE
             SET dmt_while_freq = 1
            ELSEIF (curaccept="X")
             SET dmt_while_freq = 1
            ENDIF
          ENDWHILE
         OF 5:
          SET dmt_while_prefix = 0
          SET dmt_prefix = ""
          WHILE (dmt_while_prefix=0)
            SET dm_err->eproc = "Setting up Prefix"
            CALL clear(1,1)
            CALL box(1,1,5,132)
            CALL text(3,45,"***  E-MAIL PREFIX SETTINGS FOR  ***")
            CALL text(4,45,concat("ENVIRONMENT: ",trim(dmt_tgt_env_name)," (",trim(cnvtstring(
                dmt_tgt_env_id)),")"))
            SELECT INTO "nl:"
             FROM dm2_admin_dm_info dadi
             WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
              AND dadi.info_name="E-Mail Subject Prefix"
             DETAIL
              dmt_prefix = dadi.info_char
             WITH nocounter
            ;end select
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             GO TO exit_program
            ENDIF
            IF (curqual != 0)
             IF (daf_is_not_blank(dmt_prefix))
              CALL text(7,21,trim(dmt_prefix))
             ELSE
              CALL text(7,21,"Not Set")
             ENDIF
            ELSE
             CALL text(7,21,"Not Set")
            ENDIF
            CALL text(7,3,"Current setting:")
            CALL text(9,3,"Please input a 10 character prefix:")
            CALL text(10,3,
             "This string will be appended to the beginning of the notification e-mail's subject line"
             )
            CALL accept(9,40,"PPPPPPPPPP;C",trim(dmt_prefix))
            SET dmt_set_prefix = curaccept
            CALL text(20,3,"Continue?( (Y)es/(N)o/e(X)it )")
            CALL accept(20,36,"A;CU","Y"
             WHERE curaccept IN ("Y", "N", "X"))
            IF (curaccept="Y")
             UPDATE  FROM dm2_admin_dm_info dadi
              SET dadi.info_char = dmt_set_prefix
              WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
               AND dadi.info_name="E-Mail Subject Prefix"
              WITH nocounter
             ;end update
             IF (check_error(dm_err->eproc)=1)
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              ROLLBACK
              GO TO exit_program
             ELSE
              COMMIT
             ENDIF
             IF (curqual=0)
              INSERT  FROM dm2_admin_dm_info dadi
               SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi
                .info_name = "E-Mail Subject Prefix", dadi.info_char = dmt_set_prefix,
                dadi.updt_cnt = 0, dadi.updt_dt_tm = sysdate, dadi.updt_applctx = reqinfo->
                updt_applctx,
                dadi.updt_id = reqinfo->updt_id, dadi.updt_task = reqinfo->updt_task
               WITH nocounter
              ;end insert
              IF (check_error(dm_err->eproc)=1)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               ROLLBACK
               GO TO exit_program
              ELSE
               COMMIT
              ENDIF
             ENDIF
             SET dmt_while_prefix = 1
            ELSEIF (curaccept="X")
             SET dmt_while_prefix = 1
            ENDIF
          ENDWHILE
         OF 6:
          SET dm_err->eproc = "Copy settings from another environment"
          SET dmt_delete_cur = 0
          SELECT INTO "nl:"
           FROM dm2_admin_dm_info dadi
           WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ENDIF
          IF (curqual > 0)
           CALL text(20,3,"Monitoring preferences for this environment have already been set.")
           CALL text(21,3,
            "If you continue forward these setting will be deleted. Continue ? ( (Y)es/(N)o )")
           CALL accept(21,86,"P;CU","Y"
            WHERE curaccept IN ("Y", "N"))
           IF (curaccept="Y")
            SET dmt_delete_cur = 1
            DELETE  FROM dm2_admin_dm_info dadi
             WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
             WITH nocounter
            ;end delete
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             ROLLBACK
             GO TO exit_program
            ELSE
             COMMIT
            ENDIF
           ENDIF
          ELSE
           SET dmt_delete_cur = 1
          ENDIF
          IF (dmt_delete_cur=1)
           SELECT INTO "nl:"
            FROM dm2_admin_dm_info dadi
            WHERE dadi.info_domain="RDDSPREF*"
             AND dadi.info_domain != "RDDSPREF*|*"
            HEAD REPORT
             dmt_env->cnt = 0
            DETAIL
             dmt_env_str = dadi.info_domain, dmt_env_id = cnvtreal(concat(substring((findstring(
                 "RDDSPREF",dmt_env_str)+ 8),((size(dmt_env_str,1) - (findstring("RDDSPREF",
                 dmt_env_str)+ 8))+ 1),dmt_env_str),".0"))
             IF (locateval(dmt_i,1,dmt_env->cnt,dmt_env_id,dmt_env->qual[dmt_i].target_id)=0)
              dmt_env->cnt = (dmt_env->cnt+ 1)
              IF (mod(dmt_env->cnt,10)=1)
               stat = alterlist(dmt_env->qual,(dmt_env->cnt+ 9))
              ENDIF
              dmt_env->qual[dmt_env->cnt].target_id = dmt_env_id
             ENDIF
            FOOT REPORT
             stat = alterlist(dmt_env->qual,dmt_env->cnt)
            WITH nocounter
           ;end select
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            GO TO exit_program
           ENDIF
           SELECT INTO "nl:"
            FROM dm_environment de
            WHERE expand(dmt_idx,1,dmt_env->cnt,de.environment_id,dmt_env->qual[dmt_idx].target_id)
            DETAIL
             dmt_i = locateval(dmt_idx2,1,dmt_env->cnt,de.environment_id,dmt_env->qual[dmt_idx2].
              target_id), dmt_env->qual[dmt_i].target_name = de.environment_name
            WITH nocounter
           ;end select
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            GO TO exit_program
           ENDIF
           SET dmt_set_cnt = 0
           FOR (dmt_cp_idx = 1 TO dmt_env->cnt)
             SELECT INTO "nl:"
              FROM dm2_admin_dm_info dadi
              WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_cp_idx].
                 target_id)))
               AND info_char="E-Mail Address"
              WITH nocounter
             ;end select
             IF (check_error(dm_err->eproc)=1)
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              GO TO exit_program
             ENDIF
             IF (curqual > 0)
              SET dmt_set_cnt = (dmt_set_cnt+ 1)
              SET dmt_env->qual[dmt_cp_idx].setup_pos = dmt_set_cnt
             ELSE
              SET dmt_env->qual[dmt_cp_idx].setup_pos = - (1)
             ENDIF
           ENDFOR
           SET dmt_slow = 1
           SET dmt_stotal = dmt_set_cnt
           IF (dmt_stotal < dmt_sincr)
            SET dmt_shigh = dmt_stotal
           ELSE
            SET dmt_shigh = dmt_sincr
           ENDIF
           SET dmt_sdown = 0
           SET dmt_sup = 0
           SET dmt_schoice = 0
           WHILE (dmt_schoice=0)
             CALL clear(1,1)
             CALL box(1,1,6,132)
             CALL text(2,50,"***  COPY SETTINGS FOR  ***")
             CALL text(3,45,concat("ENVIRONMENT: ",trim(dmt_tgt_env_name)," (",trim(cnvtstring(
                 dmt_tgt_env_id)),")"))
             CALL text(5,2,"Line #")
             CALL text(5,20,"COPY FROM ENVIRONMENT")
             IF (dmt_sdown=1)
              SET dmt_slow = (dmt_slow+ dmt_sincr)
              IF (((dmt_shigh+ dmt_sincr) > dmt_stotal))
               SET dmt_sover = ((dmt_shigh+ dmt_sincr) - dmt_stotal)
               SET dmt_shigh = dmt_stotal
              ELSE
               SET dmt_sover = 0
               SET dmt_shigh = (dmt_shigh+ dmt_sincr)
              ENDIF
             ELSEIF (dmt_sup=1)
              IF (((dmt_slow - dmt_sincr) >= 1))
               SET dmt_slow = (dmt_slow - dmt_sincr)
               SET dmt_shigh = ((dmt_shigh - dmt_sincr)+ dmt_sover)
               SET dmt_sover = 0
              ENDIF
             ENDIF
             SET dmt_sup = 0
             SET dmt_sdown = 0
             SET row_num = 8
             FOR (idx = dmt_slow TO dmt_shigh)
               CALL text(row_num,2,concat(trim(cnvtstring(idx)),")"))
               SET dmt_sidx = 0
               SET dmt_sidx = locateval(dmt_sidx2,1,dmt_env->cnt,idx,dmt_env->qual[dmt_sidx2].
                setup_pos)
               CALL text(row_num,20,cnvtstring(dmt_env->qual[dmt_sidx].target_id))
               CALL text(row_num,40,dmt_env->qual[dmt_sidx].target_name)
               SET row_num = (row_num+ 1)
             ENDFOR
             IF (((dmt_slow+ dmt_sincr) <= dmt_stotal))
              CALL text(22,3,"D) Page Down")
             ENDIF
             IF (dmt_slow > dmt_sincr)
              CALL text(21,3,"U) Page Up")
             ENDIF
             CALL text(24,3,"0) Exit")
             CALL text(23,3,concat("Choose line # (",trim(cnvtstring(dmt_slow)),"-",trim(cnvtstring(
                 dmt_shigh)),")"))
             CALL accept(23,27,"PPP;CU","0")
             SET dmt_sstr = trim(curaccept)
             SET dmt_snum = - (1)
             IF (isnumeric(dmt_sstr)=1)
              SET dmt_snum = cnvtint(dmt_sstr)
              IF (dmt_snum != 0
               AND ((dmt_snum < dmt_slow) OR (dmt_snum > dmt_shigh)) )
               CALL text(23,58,"Invalid Entry")
               CALL pause(2)
               SET dmt_snum = - (1)
              ELSE
               CALL text(23,32,"Continue ? ( (Y)es/(N)o )")
               CALL accept(23,59,"P;CU","Y"
                WHERE curaccept IN ("Y", "N"))
               IF (curaccept="N")
                SET dmt_snum = - (1)
               ENDIF
              ENDIF
             ELSEIF (dmt_sstr="U")
              IF (dmt_slow > dmt_sincr)
               SET dmt_sup = 1
              ELSE
               CALL text(23,58,"Invalid Entry")
               CALL pause(2)
              ENDIF
             ELSEIF (dmt_sstr="D")
              IF (((dmt_slow+ dmt_sincr) <= dmt_stotal))
               SET dmt_sdown = 1
              ELSE
               CALL text(23,58,"Invalid Entry")
               CALL pause(2)
              ENDIF
             ELSE
              CALL text(23,58,"Invalid Entry")
              CALL pause(2)
             ENDIF
             IF ((dmt_snum > - (1)))
              IF (dmt_snum=0)
               SET dmt_schoice = 1
              ELSE
               SET dmt_sidx = 0
               SET dmt_sidx = locateval(dmt_sidx2,1,dmt_env->cnt,dmt_snum,dmt_env->qual[dmt_sidx2].
                setup_pos)
               INSERT  FROM dm2_admin_dm_info dadi
                (dadi.info_domain, dadi.info_name, dadi.info_char,
                dadi.info_number)(SELECT
                 concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id))), dadi2.info_name, dadi2
                 .info_char,
                 dadi2.info_number
                 FROM dm2_admin_dm_info dadi2
                 WHERE dadi2.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_sidx].
                    target_id))))
                WITH nocounter
               ;end insert
               IF (check_error(dm_err->eproc)=1)
                CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                ROLLBACK
                GO TO exit_program
               ELSE
                COMMIT
                SET dmt_schoice = 1
               ENDIF
              ENDIF
             ENDIF
           ENDWHILE
          ENDIF
         OF 7:
          SET dm_err->eproc = "Sending test e-mail"
          FREE RECORD dmt_mail_list
          RECORD dmt_mail_list(
            1 cnt = i4
            1 qual[*]
              2 email = vc
          )
          CALL clear(1,1)
          SET stat = alterlist(drrm_events->qual,1)
          SET drrm_events->qual[1].event_type = "Practice"
          SET drrm_events->target_env_id = dmt_tgt_env_id
          SET drrm_events->link_name = trim(cnvtstring(dmt_tgt_env_id))
          SET drrm_events->file_name = "testst.txt"
          SET drrm_events->unrprtd_cnt = 1
          SET dm_err->err_ind = 0
          IF (drrm_get_mail_list(drrm_events,drrm_email_address)=0)
           SET dm_err->err_ind = 1
          ENDIF
          IF ((dm_err->err_ind=0))
           SELECT INTO "nl:"
            FROM dm2_admin_dm_info dadi
            WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_tgt_env_id)))
             AND dadi.info_char="E-Mail Address"
            ORDER BY dadi.info_name
            HEAD REPORT
             dmt_mail_list->cnt = 0
            DETAIL
             dmt_mail_list->cnt = (dmt_mail_list->cnt+ 1)
             IF (mod(dmt_mail_list->cnt,10)=1)
              stat = alterlist(dmt_mail_list->qual,(dmt_mail_list->cnt+ 9))
             ENDIF
             dmt_mail_list->qual[dmt_mail_list->cnt].email = dadi.info_name
            FOOT REPORT
             stat = alterlist(dmt_mail_list->qual,dmt_mail_list->cnt)
            WITH nocounter
           ;end select
           SET message = nowindow
           CALL clear(1,1)
           SELECT
            *
            FROM (dummyt d  WITH seq = value(dmt_mail_list->cnt))
            HEAD REPORT
             rpt_loop = 0, col 50, "CURRENT EMAILS",
             row + 1, col 2, "The e-mails below will receive the test message:",
             row + 1
            DETAIL
             rpt_loop = (rpt_loop+ 1)
             IF ((dmt_mail_list->cnt > 0))
              row + 1, col 2, dmt_mail_list->qual[rpt_loop].email
             ENDIF
            FOOT REPORT
             row + 2, col 2, "End of e-mail list"
            WITH nocounter, formfeed = none, maxrow = 1
           ;end select
           SET message = window
           CALL clear(1,1)
           CALL box(1,1,5,132)
           CALL text(2,50,"***  TEST E-MAILS FOR  ***")
           CALL text(3,45,concat("ENVIRONMENT: ",trim(dmt_tgt_env_name)," (",trim(cnvtstring(
               dmt_tgt_env_id)),")"))
           CALL text(13,40,"Ready to send test e-mail.")
           CALL text(14,40,"Continue ? ( (Y)es/(N)o )")
           CALL accept(14,67,"X;CU","N"
            WHERE curaccept IN ("Y", "N"))
           IF (curaccept="Y")
            IF ((dm_err->err_ind=0))
             IF (drrm_get_env_names(drrm_events,1)=0)
              SET dm_err->err_ind = 1
             ENDIF
            ENDIF
            IF ((dm_err->err_ind=0))
             IF (drrm_create_subject("Test",drrm_events,1)=0)
              SET dm_err->err_ind = 1
             ENDIF
            ENDIF
            IF ((dm_err->err_ind=0))
             IF (drrm_generate_email_text(1,drrm_events,1)=0)
              SET dm_err->err_ind = 1
             ENDIF
            ENDIF
            IF ((dm_err->err_ind=0))
             IF (drrm_generate_email_file("Practice",drrm_events)=0)
              SET dm_err->err_ind = 1
             ENDIF
            ENDIF
            IF ((dm_err->err_ind=0))
             IF (drrm_send_email(drrm_events->subject_text,drrm_email_address->email_address,
              drrm_events->file_name)=0)
              SET dm_err->err_ind = 1
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF ((dm_err->err_ind=1))
           CALL clear(1,1)
           SET width = 132
           CALL text(10,50,"ERROR OCCURED")
           CALL text(12,3,dm_err->eproc)
           CALL pause(5)
          ENDIF
          SET dm_err->err_ind = 0
         OF 0:
          SET dmt_sub_menu = 1
        ENDCASE
      ENDWHILE
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_ref_data_audit(null)
   DECLARE drda_back = i2
   SET drda_back = 0
   WHILE (drda_back=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,43,"***  RDDS REFERENCE DATA AUDIT  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,"Please choose from the following options:")
     CALL text(9,3,"1 Manage Audit Settings")
     CALL text(10,3,"2 Run Audit Report")
     CALL text(12,3,"0 Exit")
     CALL accept(7,50,"99",0
      WHERE curaccept IN (1, 2, 3, 0))
     CASE (curaccept)
      OF 1:
       CALL dmda_ref_data_audit_setup(null)
      OF 2:
       CALL dmda_ref_data_audit_run(null)
      OF 0:
       SET drda_back = 1
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_ref_data_audit_setup(null)
   DECLARE drdas_back = i2
   DECLARE drdas_old_size = i4
   DECLARE drdas_new_size = i4
   DECLARE drdas_tempqual = i4 WITH protect, noconstant(0)
   SET drdas_back = 0
   SET dm_err->eproc = "Setting up default audit size"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CONFIGURATION"
     AND di.info_name="AUDIT_REPORT_SAMPLE_SIZE"
    DETAIL
     drdas_old_size = di.info_number
    WITH nocounter
   ;end select
   SET drdas_tempqual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (drdas_tempqual=0)
    SET drdas_old_size = 25
    INSERT  FROM dm_info di
     SET di.info_domain = "RDDS CONFIGURATION", di.info_name = "AUDIT_REPORT_SAMPLE_SIZE", di
      .info_number = drdas_old_size,
      di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     GO TO exit_program
    ELSE
     COMMIT
    ENDIF
   ENDIF
   WHILE (drdas_back=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,43,"***  AUDIT REPORT SAMPLE SIZE  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,concat("Currently the sample size is: ",trim(cnvtstring(drdas_old_size)),
       ". This is the number of rows the Audit Report will return when it is run on a single table.")
      )
     CALL text(9,3,"New sample size for Audit Report:")
     CALL accept(9,37,"999999",drdas_old_size
      WHERE curaccept > 0
       AND curaccept <= 999999)
     SET drdas_new_size = curaccept
     CALL text(20,3,"Continue?( (Y)es/(N)o/e(X)it )")
     CALL accept(20,36,"A;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     CASE (curaccept)
      OF "Y":
       SET dm_err->eproc = "Inserting/updating audit size"
       UPDATE  FROM dm_info di
        SET di.info_number = drdas_new_size
        WHERE di.info_domain="RDDS CONFIGURATION"
         AND di.info_name="AUDIT_REPORT_SAMPLE_SIZE"
        WITH nocounter
       ;end update
       SET drdas_tempqual = curqual
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        GO TO exit_program
       ELSE
        COMMIT
       ENDIF
       IF (drdas_tempqual=0)
        INSERT  FROM dm_info di
         SET di.info_domain = "RDDS CONFIGURATION", di.info_name = "AUDIT_REPORT_SAMPLE_SIZE", di
          .info_number = drdas_new_size,
          di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
           curdate,curtime3),
          di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
         WITH nocounter
        ;end insert
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         GO TO exit_program
        ELSE
         COMMIT
        ENDIF
       ENDIF
       SET drdas_back = 1
      OF "X":
       SET drdas_back = 1
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_ref_data_audit_run(null)
   DECLARE drdar_back = i2
   DECLARE drdar_rep_name = vc WITH noconstant("")
   DECLARE drdar_context_ind = vc
   DECLARE drdar_tab_name = vc
   DECLARE drdar_size_ind = vc
   DECLARE drdar_source_id = f8
   DECLARE drdar_cgl_ind = vc
   DECLARE drdar_output_ind = vc
   DECLARE drdar_sample_size = i4
   DECLARE s_context_to_audit = vc WITH protect, noconstant("")
   DECLARE s_cntxt_updt_dt_tm = f8 WITH protext, noconstant(0.0)
   DECLARE s_user_option_main = c1 WITH protect, noconstant("")
   DECLARE s_user_option_pull = c1 WITH protect, noconstant("")
   DECLARE s_while_ind = i2 WITH protect, noconstant(0)
   DECLARE s_str_first_100 = vc WITH protect, noconstant("")
   DECLARE s_str_format_100 = vc WITH protect, noconstant("")
   DECLARE s_str_remain = vc WITH protect, noconstant("")
   DECLARE s_col_pos = i2 WITH protect, noconstant(0)
   DECLARE s_temp_str = vc WITH protect, noconstant("")
   DECLARE s_del_str = vc WITH protect, noconstant("")
   DECLARE s_invalid_ind = i2 WITH protect, noconstant(0)
   DECLARE s_exit_context_menu = i2 WITH protect, noconstant(0)
   DECLARE s_db_link = vc WITH protect, noconstant("")
   DECLARE s_db_link_tname = vc WITH protect, noconstant("")
   DECLARE s_string_match = vc
   DECLARE s_default_context = vc
   DECLARE s_temp_str = vc
   DECLARE s_first_null = i2
   DECLARE s_context_loop_cnt = i4 WITH protect, noconstant(0)
   DECLARE cts_check = i2
   DECLARE s_count = i2 WITH protect, noconstant(0)
   DECLARE s_valid_entry_ind = i4 WITH protect, noconstant(0)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE inum = i2 WITH protect, noconstant(0)
   DECLARE idx = i2 WITH protect, noconstant(0)
   DECLARE drdar_xml_name = vc
   DECLARE drdar_sum_name = vc
   DECLARE drdar_xsl_name = vc
   DECLARE drdam_ext_pos = i4
   DECLARE drdar_tab_ind = i2
   DECLARE drdar_tempqual = i4 WITH protect, noconstant(0)
   FREE RECORD temp_context_list
   RECORD temp_context_list(
     1 list[*]
       2 context_name = c50
   )
   SET drdar_back = 0
   WHILE (drdar_back=0)
     SET message = window
     CALL get_src_env_id("RDDS REFERENCE DATA AUDIT",1)
     IF (srm_env_id != 0)
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,5,132)
      CALL text(3,43,"***  RDDS REFERENCE DATA AUDIT  ***")
      CALL text(4,75,"ENVIRONMENT ID:")
      CALL text(4,20,"ENVIRONMENT NAME:")
      CALL text(4,95,cnvtstring(dmda_mr->env_id))
      CALL text(4,40,dmda_mr->env_name)
      CALL text(7,3,concat("Source to run audit on: ",cnvtstring(srm_env_id)))
      CALL text(8,3,"Enter the name for the output XML file:")
      CALL accept(8,50,"P(35);C","audit.xml"
       WHERE trim(curaccept) > "")
      SET drdar_rep_name = trim(curaccept)
      CALL text(9,3,
       "Limit the output of the audit to specific Context Name(s) in the Source Change Log? ( (Y)es/(N)o ):"
       )
      CALL accept(9,104,"P;CU","Y"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="Y")
       SET drdar_context_ind = "YES"
       SET s_context_loop_cnt = 0
       SELECT INTO "nl:"
        FROM dm_env_reltn d
        WHERE d.relationship_type="REFERENCE MERGE"
         AND d.parent_env_id=srm_env_id
         AND (d.child_env_id=dmda_mr->env_id)
        DETAIL
         s_db_link = trim(d.post_link_name,3)
        WITH nocounter
       ;end select
       SET s_db_link_tname = concat("DM_CHG_LOG",s_db_link)
       SET s_while_ind = 0
       WHILE (s_while_ind=0)
         SET s_context_loop_cnt = (s_context_loop_cnt+ 1)
         SET help =
         SELECT
          context_name = trim(temp_context_list->list[d.seq].context_name,3)
          FROM (dummyt d  WITH seq = size(temp_context_list->list,5))
          ORDER BY context_name
          WITH nocounter
         ;end select
         SELECT INTO "NL:"
          FROM dm_info d
          WHERE d.info_domain="RDDS CONTEXT"
           AND d.info_name="CONTEXTS TO AUDIT"
          DETAIL
           s_context_to_audit = d.info_char, s_cntxt_updt_dt_tm = cnvtdatetime(d.updt_dt_tm)
          WITH nocounter
         ;end select
         IF (check_error("Error getting contexts to audit dm_info row.") != 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_program
         ENDIF
         SELECT INTO "NL:"
          FROM dm_rdds_event_detail dred
          WHERE dred.event_detail1_txt="CONTEXTS TO PULL"
           AND dred.updt_dt_tm > cnvtdatetime(s_cntxt_updt_dt_tm)
           AND dred.dm_rdds_event_log_id IN (
          (SELECT
           max(d.dm_rdds_event_log_id)
           FROM dm_rdds_event_log d
           WHERE (d.cur_environment_id=dmda_mr->env_id)
            AND d.paired_environment_id=srm_env_id
            AND d.rdds_event_key="STARTINGRDDSMOVER"))
          DETAIL
           s_context_to_audit = concat(s_context_to_audit,"::",dred.event_detail2_txt)
          WITH nocounter
         ;end select
         IF (check_error("Error checking for a recent mover's contexts to pull.") != 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_program
         ENDIF
         IF (s_context_to_audit="ALL")
          SET s_context_to_audit = ""
          SET s_user_option_main = "E"
          SET s_user_option_pull = "A"
         ENDIF
         IF (daf_is_not_blank(s_user_option_pull))
          SET s_user_option_main = "E"
         ELSE
          CALL clear(11,1)
          CALL clear(12,1)
          CALL clear(13,1)
          CALL text(11,3,
           "Tables to be audited will be limited to those found in the following context names:")
          CALL text(12,3,
           "------------------------------------------------------------------------------------")
          SET stat = initrec(dmda_breakup_str)
          SET dmda_breakup_str->str_text = s_context_to_audit
          SET dmda_breakup_str->str_delim = "::"
          SET dmda_breakup_str->str_delim_ind = 2
          SET dmda_breakup_str->str_limit = 100
          SET s_breakup_str_ret = drmm_breakup_string(dmda_breakup_str)
          IF (s_breakup_str_ret="S")
           IF (size(dmda_breakup_str->substr,5) >= 2)
            CALL text(13,3,trim(dmda_breakup_str->substr[1].str,3))
            CALL text(14,3,trim(dmda_breakup_str->substr[2].str,3))
            IF (size(dmda_breakup_str->substr,5) > 2)
             CALL text(16,3,"To display all the contexts please use the View All option.")
            ENDIF
           ELSE
            CALL text(13,3,trim(dmda_breakup_str->substr[1].str,3))
           ENDIF
          ELSE
           SET dm_err->err_ind = 1
           SET dm_err->emsg = "Unable to break apart CONTEXTS TO PULL string."
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ENDIF
          CALL text(17,3,"E=Edit, C=Continue, V=View All")
          CALL accept(18,3,"P;CU","C"
           WHERE curaccept IN ("E", "C", "V"))
          SET s_user_option_main = curaccept
         ENDIF
         CASE (s_user_option_main)
          OF "E":
           IF (s_context_loop_cnt=1)
            CALL clear(10,1)
            CALL clear(11,1)
            CALL clear(12,1)
            CALL clear(13,1)
            CALL text(10,3,"Retrieving the list of context names......... ")
            SELECT DISTINCT INTO "NL:"
             d.context_name
             FROM (value(s_db_link_tname) d)
             WHERE (d.target_env_id=dmda_mr->env_id)
              AND d.log_type > ""
              AND ((d.context_name >= "") UNION (
             (SELECT
              "NULL"
              FROM dual
              WHERE 1=1)))
             HEAD REPORT
              s_count = 0
             DETAIL
              s_count = (s_count+ 1)
              IF (mod(s_count,20)=1)
               stat = alterlist(temp_context_list->list,(s_count+ 19))
              ENDIF
              temp_context_list->list[s_count].context_name = d.context_name
             FOOT REPORT
              stat = alterlist(temp_context_list->list,s_count)
             WITH nocounter
            ;end select
           ENDIF
           IF (size(temp_context_list->list,5)=1)
            SET index = locateval(inum,1,size(temp_context_list->list,5),"NULL",temp_context_list->
             list[inum].context_name)
           ELSE
            SET index = 0
           ENDIF
           IF (index > 0)
            CALL clear(10,1)
            CALL clear(11,1)
            CALL clear(13,1)
            CALL clear(14,1)
            CALL text(11,3,"********* ONLY CONTEXT NAME FOUND IS NULL ********")
            CALL text(13,3,"   Exit will return to the previous menu. ")
            CALL text(14,3,"   Continue will execute audit without respect to context_name. ")
            CALL text(16,3,"E=Exit, C=Continue")
            CALL accept(17,3,"P;CU","C"
             WHERE curaccept IN ("E", "C"))
            IF (curaccept="E")
             SET s_while_ind = 1
             SET s_context_to_audit = ""
             SET drdar_back = 1
            ELSE
             SET s_exit_context_menu = 1
             SET s_while_ind = 1
             SET s_context_to_audit = ""
            ENDIF
           ELSE
            IF (daf_is_blank(s_context_to_audit))
             CALL clear(10,1)
             CALL clear(11,1)
             CALL clear(12,1)
             CALL text(11,3,"Choose a Source Context to Audit")
             CALL text(12,3,"     from the Help Menu:")
             CALL accept(14,3,"P(24);CUF"
              WHERE trim(curaccept) > "")
             SET index = locateval(inum,1,size(temp_context_list->list,5),curaccept,temp_context_list
              ->list[inum].context_name)
             IF (index=0)
              SET s_valid_entry_ind = 0
              WHILE (s_valid_entry_ind=0)
                CALL clear(10,1)
                CALL clear(11,1)
                CALL clear(12,1)
                CALL text(11,3,"Invalid context name entered!")
                CALL text(12,3,"Please select a valid context name from the Help Menu:")
                CALL accept(14,3,"P(24);CUF"
                 WHERE trim(curaccept) > "")
                SET s_valid_entry_ind = locateval(idx,1,size(temp_context_list->list,5),curaccept,
                 temp_context_list->list[idx].context_name)
              ENDWHILE
             ENDIF
             SET s_context_to_audit = trim(curaccept,3)
            ELSE
             CALL clear(10,1)
             CALL clear(11,1)
             CALL clear(12,1)
             CALL clear(13,1)
             CALL text(11,3,
              "Tables to be audited will be limited to those found in the following context names:")
             CALL text(12,3,
              "------------------------------------------------------------------------------------")
             SET stat = initrec(dmda_breakup_str)
             SET dmda_breakup_str->str_text = s_context_to_audit
             SET dmda_breakup_str->str_delim = "::"
             SET dmda_breakup_str->str_delim_ind = 2
             SET dmda_breakup_str->str_limit = 100
             SET s_breakup_str_ret = drmm_breakup_string(dmda_breakup_str)
             IF (s_breakup_str_ret="S")
              IF (size(dmda_breakup_str->substr,5) >= 2)
               CALL text(13,3,trim(dmda_breakup_str->substr[1].str,3))
               CALL text(14,3,trim(dmda_breakup_str->substr[2].str,3))
               IF (size(dmda_breakup_str->substr,5) > 2)
                CALL text(16,3,"To display all the contexts please use the View All option.")
               ENDIF
              ELSE
               CALL text(13,3,trim(dmda_breakup_str->substr[1].str,3))
              ENDIF
             ELSE
              SET dm_err->err_ind = 1
              SET dm_err->emsg = "Unable to break apart CONTEXTS TO PULL string."
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              GO TO exit_program
             ENDIF
             CALL text(17,3,"R=Reset, A=Add, D=Delete, C=Continue, V=View All")
             CALL accept(18,3,"P;CU","C"
              WHERE curaccept IN ("R", "A", "D", "C", "V"))
             SET s_user_option_pull = curaccept
             CASE (s_user_option_pull)
              OF "R":
               SET s_context_loop_cnt = (s_context_loop_cnt+ 1)
               SET s_context_to_audit = ""
               CALL clear(11,1)
               CALL clear(12,1)
               CALL text(11,3,"Choose a Source Context to Audit")
               CALL text(12,3,"     from the Help Menu:")
               CALL accept(14,3,"P(24);CUF"
                WHERE trim(curaccept) > "")
               SET index = locateval(inum,1,size(temp_context_list->list,5),curaccept,
                temp_context_list->list[inum].context_name)
               IF (index=0)
                SET s_valid_entry_ind = 0
                WHILE (s_valid_entry_ind=0)
                  CALL clear(10,1)
                  CALL clear(11,1)
                  CALL clear(12,1)
                  CALL text(11,3,"Invalid context name entered!")
                  CALL text(12,3,"Please select a valid context name from the Help Menu:")
                  CALL accept(14,3,"P(24);CUF"
                   WHERE trim(curaccept) > "")
                  SET s_valid_entry_ind = locateval(idx,1,size(temp_context_list->list,5),curaccept,
                   temp_context_list->list[idx].context_name)
                ENDWHILE
               ENDIF
               SET s_context_to_audit = trim(curaccept,3)
              OF "A":
               SET s_context_loop_cnt = (s_context_loop_cnt+ 1)
               CALL clear(11,1)
               CALL clear(12,1)
               CALL text(11,3,"Choose a Source Context to Audit")
               CALL text(12,3,"     from the Help Menu:")
               CALL accept(14,3,"P(24);CUF"
                WHERE trim(curaccept) > "")
               SET index = locateval(inum,1,size(temp_context_list->list,5),curaccept,
                temp_context_list->list[inum].context_name)
               IF (index=0)
                SET s_valid_entry_ind = 0
                WHILE (s_valid_entry_ind=0)
                  CALL clear(10,1)
                  CALL clear(11,1)
                  CALL clear(12,1)
                  CALL text(11,3,"Invalid context name entered!")
                  CALL text(12,3,"Please select a valid context name from the Help Menu:")
                  CALL accept(14,3,"P(24);CUF"
                   WHERE trim(curaccept) > "")
                  SET s_valid_entry_ind = locateval(idx,1,size(temp_context_list->list,5),curaccept,
                   temp_context_list->list[idx].context_name)
                ENDWHILE
               ENDIF
               IF (daf_is_not_blank(s_context_to_audit))
                SET s_context_to_audit = concat(trim(curaccept,3),"::",s_context_to_audit)
               ELSE
                SET s_context_to_audit = trim(curaccept,3)
               ENDIF
              OF "D":
               SET s_context_loop_cnt = (s_context_loop_cnt+ 1)
               CALL clear(11,1)
               CALL clear(12,1)
               CALL text(11,3,"Choose a Source Context to Audit ")
               CALL text(12,3," from the Help Menu to Delete:")
               SET s_temp_str = replace(s_context_to_audit,"::",",")
               SET help = fix(value(s_temp_str))
               CALL accept(14,3,"P(24);CF"
                WHERE trim(curaccept) > "")
               SET s_del_str = trim(curaccept,3)
               SET s_del_str = concat("|",trim(replace(concat("::",s_context_to_audit,"::"),concat(
                   ":",s_del_str,":"),""),3),"|")
               SET s_del_str = replace(s_del_str,"::::","::")
               SET s_del_str = replace(s_del_str,"|::","")
               SET s_del_str = replace(s_del_str,"::|","")
               SET s_del_str = replace(s_del_str,"|","")
               SET s_context_to_audit = trim(s_del_str,3)
              OF "C":
               SET s_while_ind = 1
              OF "V":
               SET message = nowindow
               SELECT INTO mine
                contexts_to_pull = s_context_to_audit
                FROM dual
               ;end select
               SET message = window
               CALL clear(1,1)
               SET width = 132
               CALL box(1,1,5,132)
               CALL text(3,43,"***  RDDS REFERENCE DATA AUDIT  ***")
               CALL text(4,75,"ENVIRONMENT ID:")
               CALL text(4,20,"ENVIRONMENT NAME:")
               CALL text(4,95,cnvtstring(dmda_mr->env_id))
               CALL text(4,40,dmda_mr->env_name)
               CALL text(7,3,concat("Source to run audit on: ",cnvtstring(srm_env_id)))
               CALL text(8,3,"Enter the name for the output XML file:")
               CALL text(8,50,drdar_rep_name)
               CALL text(9,3,concat("Limit the output of the audit to specific Context Name(s) ",
                 "in the Source Change Log? ( (Y)es/(N)o ):"))
               CALL text(9,104,"Y")
             ENDCASE
            ENDIF
           ENDIF
          OF "C":
           SET s_while_ind = 1
          OF "V":
           SET message = nowindow
           SELECT INTO mine
            contexts_to_pull = s_context_to_audit
            FROM dual
            WITH nocounter
           ;end select
           SET message = window
           CALL clear(1,1)
           SET width = 132
           CALL box(1,1,5,132)
           CALL text(3,43,"***  RDDS REFERENCE DATA AUDIT  ***")
           CALL text(4,75,"ENVIRONMENT ID:")
           CALL text(4,20,"ENVIRONMENT NAME:")
           CALL text(4,95,cnvtstring(dmda_mr->env_id))
           CALL text(4,40,dmda_mr->env_name)
           CALL text(7,3,concat("Source to run audit on: ",cnvtstring(srm_env_id)))
           CALL text(8,3,"Enter the name for the output XML file:")
           CALL text(8,50,drdar_rep_name)
           CALL text(9,3,
            "Limit the output of the audit to specific Context Name(s) in the Source Change Log? ( (Y)es/(N)o ):"
            )
           CALL text(9,104,"Y")
         ENDCASE
         IF (daf_is_not_blank(s_context_to_audit))
          UPDATE  FROM dm_info di
           SET di.info_char = trim(s_context_to_audit,3), di.updt_applctx = reqinfo->updt_applctx, di
            .updt_cnt = (di.updt_cnt+ 1),
            di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di
            .updt_task = reqinfo->updt_task
           WHERE di.info_domain="RDDS CONTEXT"
            AND di.info_name="CONTEXTS TO AUDIT"
           WITH nocounter
          ;end update
          IF (curqual=0)
           INSERT  FROM dm_info di
            SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXTS TO AUDIT", di.info_char =
             trim(s_context_to_audit,3),
             di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
              curdate,curtime3),
             di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
            WITH nocounter
           ;end insert
          ENDIF
         ENDIF
         IF (check_error("Can not load RDDS 'Contexts to Audit' DM_INFO row") != 0)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET s_while_ind = 1
         ELSE
          COMMIT
         ENDIF
       ENDWHILE
       SET help = off
       CALL clear(16,1)
       CALL clear(17,1)
       CALL clear(18,1)
       IF (s_exit_context_menu=0)
        CALL clear(15,1)
        SET drdar_tab_name = "*"
        CALL text(15,3,"The sample size will be limited to a default of 25 rows per table")
        SET drdar_size_ind = "YES"
        CALL text(16,3,"The Source change log information will be displayed for all rows, by default"
         )
        SET drdar_cgl_ind = "YES"
        CALL text(17,3,
         "The audit output will be limited to data with corresponding change log rows, by default")
        SET drdar_output_ind = "YES"
        SET drdam_ext_pos = findstring(".",drdar_rep_name)
        IF (drdam_ext_pos=0)
         SET drdar_sum_name = concat(drdar_rep_name,"_summary.xml")
         SET drdar_xml_name = concat(drdar_rep_name,".xml")
        ELSE
         SET drdar_xml_name = drdar_rep_name
         SET drdar_sum_name = concat(substring(1,(drdam_ext_pos - 1),drdar_rep_name),"_summary",
          substring(drdam_ext_pos,size(drdar_rep_name,1),drdar_rep_name))
        ENDIF
        SET drdar_xsl_name = replace(drdar_xml_name,".xml",".xsl")
        CALL text(18,3,concat(
          "Audit 1 is excluded since the audit output has been limited to valid Source change log rows",
          " and specific context name(s): "))
        CALL text(19,50,trim(s_context_to_audit,3))
        CALL text(20,3,
         "The following 3 files will be created by the Audit Report and found in CCLUSERDIR upon completion:"
         )
        CALL text(21,50,drdar_xml_name)
        CALL text(22,50,drdar_sum_name)
        CALL text(23,50,drdar_xsl_name)
        CALL text(24,3,"Continue?( (Y)es/(N)o/e(X)it )")
        CALL accept(24,36,"A;CU","Y"
         WHERE curaccept IN ("Y", "N", "X"))
        IF (curaccept="X")
         SET drdar_back = 1
        ELSEIF (curaccept="Y")
         SET message = nowindow
         EXECUTE dm_rdds_audit drdar_rep_name, drdar_tab_name, srm_env_id,
         drdar_cgl_ind, drdar_size_ind, drdar_output_ind,
         drdar_context_ind
         GO TO exit_program
        ENDIF
       ELSE
        CALL clear(10,1)
        CALL clear(11,1)
        CALL clear(13,1)
        CALL clear(14,1)
        SET drdar_context_ind = "NO"
        CALL text(10,3,"Enter table name or pattern to be audited:")
        SET accept = nopatcheck
        SET drdar_tab_ind = 0
        WHILE (drdar_tab_ind=0)
          CALL accept(10,50,"P(35);CU","*"
           WHERE trim(curaccept) > "")
          SET drdar_tab_name = trim(curaccept)
          SELECT INTO "nl:"
           FROM user_tables ut
           WHERE ut.table_name=patstring(drdar_tab_name)
           WITH nocounter
          ;end select
          SET drdar_tempqual = curqual
          IF (check_error("Obtaining audit report sample size")=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ENDIF
          IF (drdar_tempqual > 0)
           SET drdar_tab_ind = 1
          ENDIF
        ENDWHILE
        SET accept = patcheck
        IF (findstring("\*",drdar_tab_name,1,0)=0)
         SELECT INTO "nl:"
          FROM dm_info di
          WHERE di.info_domain="RDDS CONFIGURATION"
           AND di.info_name="AUDIT_REPORT_SAMPLE_SIZE"
          DETAIL
           drdar_sample_size = di.info_number
          WITH nocounter
         ;end select
         SET drdar_tempqual = curqual
         IF (check_error("Obtaining audit report sample size")=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_program
         ENDIF
         IF (drdar_tempqual=0)
          SET drdar_sample_size = 25
         ENDIF
         CALL text(11,3,concat("Limit the sample size for the above table to ",trim(cnvtstring(
             drdar_sample_size))," rows ? ( (Y)es/(N)o ):"))
         CALL accept(11,76,"P;CU","Y"
          WHERE curaccept IN ("Y", "N"))
         IF (curaccept="Y")
          SET drdar_size_ind = "YES"
         ELSE
          SET drdar_size_ind = "NO"
         ENDIF
        ELSE
         CALL text(11,3,"The sample size will be limited to a default of 25 rows per table")
         SET drdar_size_ind = "YES"
        ENDIF
        CALL clear(15,1)
        CALL clear(16,1)
        CALL clear(17,1)
        CALL text(12,3,
         "Display Source change log information beyond the sample size? ( (Y)es/(N)o ):")
        IF (findstring("\*",drdar_tab_name,1,0)=0)
         CALL accept(12,80,"P;CU","Y"
          WHERE curaccept IN ("Y", "N"))
        ELSE
         CALL accept(12,80,"P;CU","N"
          WHERE curaccept IN ("Y", "N"))
        ENDIF
        IF (curaccept="Y")
         SET drdar_cgl_ind = "YES"
        ELSE
         SET drdar_cgl_ind = "NO"
        ENDIF
        CALL text(13,3,"Limit output to data with corresponding change rows only? ( (Y)es/(N)o ):")
        IF (findstring("\*",drdar_tab_name,1,0)=0)
         CALL accept(13,78,"P;CU","Y"
          WHERE curaccept IN ("Y", "N"))
        ELSE
         CALL accept(13,78,"P;CU","N"
          WHERE curaccept IN ("Y", "N"))
        ENDIF
        IF (curaccept="Y")
         SET drdar_output_ind = "YES"
        ELSE
         SET drdar_output_ind = "NO"
        ENDIF
        SET drdam_ext_pos = findstring(".",drdar_rep_name)
        IF (drdam_ext_pos=0)
         SET drdar_sum_name = concat(drdar_rep_name,"_summary.xml")
         SET drdar_xml_name = concat(drdar_rep_name,".xml")
        ELSE
         SET drdar_xml_name = drdar_rep_name
         SET drdar_sum_name = concat(substring(1,(drdam_ext_pos - 1),drdar_rep_name),"_summary",
          substring(drdam_ext_pos,size(drdar_rep_name,1),drdar_rep_name))
        ENDIF
        SET drdar_xsl_name = replace(drdar_xml_name,".xml",".xsl")
        IF (drdar_output_ind="YES")
         CALL text(15,3,
          "Audit 1 is excluded since the audit output has been limited to valid Source change log rows."
          )
        ENDIF
        CALL text(16,3,
         "The following 3 files will be created by the Audit Report and found in CCLUSERDIR upon completion:"
         )
        CALL text(18,50,drdar_xml_name)
        CALL text(19,50,drdar_sum_name)
        CALL text(20,50,drdar_xsl_name)
        CALL text(22,3,"Continue?( (Y)es/(N)o/e(X)it )")
        CALL accept(22,36,"A;CU","Y"
         WHERE curaccept IN ("Y", "N", "X"))
        IF (curaccept="X")
         SET drdar_back = 1
        ELSEIF (curaccept="Y")
         SET message = nowindow
         EXECUTE dm_rdds_audit drdar_rep_name, drdar_tab_name, srm_env_id,
         drdar_cgl_ind, drdar_size_ind, drdar_output_ind,
         drdar_context_ind
         GO TO exit_program
        ENDIF
       ENDIF
      ELSE
       CALL clear(10,1)
       CALL clear(11,1)
       CALL clear(13,1)
       CALL clear(14,1)
       SET drdar_context_ind = "NO"
       CALL text(10,3,"Enter table name or pattern to be audited:")
       SET accept = nopatcheck
       SET drdar_tab_ind = 0
       WHILE (drdar_tab_ind=0)
         CALL accept(10,50,"P(35);CU","*"
          WHERE trim(curaccept) > "")
         SET drdar_tab_name = trim(curaccept)
         SELECT INTO "nl:"
          FROM user_tables ut
          WHERE ut.table_name=patstring(drdar_tab_name)
          WITH nocounter
         ;end select
         SET drdar_tempqual = curqual
         IF (check_error("Obtaining audit report sample size")=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_program
         ENDIF
         IF (drdar_tempqual > 0)
          SET drdar_tab_ind = 1
         ENDIF
       ENDWHILE
       SET accept = patcheck
       IF (findstring("\*",drdar_tab_name,1,0)=0)
        SELECT INTO "nl:"
         FROM dm_info di
         WHERE di.info_domain="RDDS CONFIGURATION"
          AND di.info_name="AUDIT_REPORT_SAMPLE_SIZE"
         DETAIL
          drdar_sample_size = di.info_number
         WITH nocounter
        ;end select
        SET drdar_tempqual = curqual
        IF (check_error("Obtaining audit report sample size")=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        IF (drdar_tempqual=0)
         SET drdar_sample_size = 25
        ENDIF
        CALL text(11,3,concat("Limit the sample size for the above table to ",trim(cnvtstring(
            drdar_sample_size))," rows ? ( (Y)es/(N)o ):"))
        CALL accept(11,76,"P;CU","Y"
         WHERE curaccept IN ("Y", "N"))
        IF (curaccept="Y")
         SET drdar_size_ind = "YES"
        ELSE
         SET drdar_size_ind = "NO"
        ENDIF
       ELSE
        CALL text(11,3,"The sample size will be limited to a default of 25 rows per table")
        SET drdar_size_ind = "YES"
       ENDIF
       CALL clear(15,1)
       CALL clear(16,1)
       CALL clear(17,1)
       CALL text(12,3,"Display Source change log information beyond the sample size? ( (Y)es/(N)o ):"
        )
       IF (findstring("\*",drdar_tab_name,1,0)=0)
        CALL accept(12,80,"P;CU","Y"
         WHERE curaccept IN ("Y", "N"))
       ELSE
        CALL accept(12,80,"P;CU","N"
         WHERE curaccept IN ("Y", "N"))
       ENDIF
       IF (curaccept="Y")
        SET drdar_cgl_ind = "YES"
       ELSE
        SET drdar_cgl_ind = "NO"
       ENDIF
       CALL text(13,3,"Limit output to data with corresponding change rows only? ( (Y)es/(N)o ):")
       IF (findstring("\*",drdar_tab_name,1,0)=0)
        CALL accept(13,78,"P;CU","Y"
         WHERE curaccept IN ("Y", "N"))
       ELSE
        CALL accept(13,78,"P;CU","N"
         WHERE curaccept IN ("Y", "N"))
       ENDIF
       IF (curaccept="Y")
        SET drdar_output_ind = "YES"
       ELSE
        SET drdar_output_ind = "NO"
       ENDIF
       SET drdam_ext_pos = findstring(".",drdar_rep_name)
       IF (drdam_ext_pos=0)
        SET drdar_sum_name = concat(drdar_rep_name,"_summary.xml")
        SET drdar_xml_name = concat(drdar_rep_name,".xml")
       ELSE
        SET drdar_xml_name = drdar_rep_name
        SET drdar_sum_name = concat(substring(1,(drdam_ext_pos - 1),drdar_rep_name),"_summary",
         substring(drdam_ext_pos,size(drdar_rep_name,1),drdar_rep_name))
       ENDIF
       SET drdar_xsl_name = replace(drdar_xml_name,".xml",".xsl")
       IF (drdar_output_ind="YES")
        CALL text(15,3,
         "Audit 1 is excluded since the audit output has been limited to valid Source change log rows."
         )
       ENDIF
       CALL text(16,3,
        "The following 3 files will be created by the Audit Report and found in CCLUSERDIR upon completion:"
        )
       CALL text(18,50,drdar_xml_name)
       CALL text(19,50,drdar_sum_name)
       CALL text(20,50,drdar_xsl_name)
       CALL text(22,3,"Continue?( (Y)es/(N)o/e(X)it )")
       CALL accept(22,36,"A;CU","Y"
        WHERE curaccept IN ("Y", "N", "X"))
       IF (curaccept="X")
        SET drdar_back = 1
       ELSEIF (curaccept="Y")
        SET message = nowindow
        EXECUTE dm_rdds_audit drdar_rep_name, drdar_tab_name, srm_env_id,
        drdar_cgl_ind, drdar_size_ind, drdar_output_ind,
        drdar_context_ind
        GO TO exit_program
       ENDIF
      ENDIF
     ELSE
      SET drdar_back = 1
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE ptam_confirm(pc_target_env_id)
   DECLARE pc_ptam_answer = vc WITH protect, noconstant("")
   DECLARE pc_default_message = vc WITH protect, noconstant("")
   DECLARE pc_dual_bld_setting = f8 WITH protect, noconstant(0.0)
   DECLARE pc_dual_bld_trg_flag = i2 WITH protect, noconstant(0)
   DECLARE pc_cur_ptam_setting = i2 WITH protect, noconstant(0)
   DECLARE pc_new_ptam_setting = i2 WITH protect, noconstant(0)
   DECLARE pc_tgt_env_name = vc WITH protect, noconstant("")
   DECLARE pc_db_link = vc WITH protect, noconstant("")
   DECLARE pc_continue = i2 WITH protect, noconstant(0)
   DECLARE pc_ptam_confirm_answer = vc WITH protect, noconstant("")
   DECLARE pc_rev_ptam = i4 WITH protect, noconstant(0)
   DECLARE pc_temp_return = i2 WITH protect, noconstant(0)
   CALL clear(1,1)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL parser("cclseclogin go")
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = ""
      SET dm_err->err_ind = 0
     ENDIF
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "Configuring PTAM"
      SET dm_err->emsg = "User not logged in cclseclogin"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   SET pc_cur_ptam_setting = drcr_get_ptam_config(dmda_mr->env_id,pc_target_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE de.environment_id=pc_target_env_id
    DETAIL
     pc_tgt_env_name = trim(de.environment_name,3)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET pc_temp_return = drcr_get_cutover_config(dmda_mr->env_id,pc_target_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((pc_temp_return=- (1)))
    SET pc_default_message = "NOT YET CONFIGURED FOR THIS RELATIONSHIP"
   ELSEIF (pc_temp_return=0)
    SET pc_default_message = "AUTO CUTOVER"
   ELSE
    SET pc_default_message = "PLANNED CUTOVER"
   ENDIF
   SET pc_dual_bld_setting = drcr_get_dual_build_config(dmda_mr->env_id,pc_target_env_id)
   IF ((pc_dual_bld_setting=- (1)))
    SET pc_dual_bld_setting = 2.0
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET pc_dual_bld_setting = 2.0
   ENDIF
   SET dm_err->eproc = "Checking for existing PTAM relationship"
   SET pc_rev_ptam = drcr_get_ptam_config(pc_target_env_id,dmda_mr->env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   WHILE (pc_continue=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Pending Target as Master Configuration  ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(8,3,concat("Current Configuration for target ",pc_tgt_env_name,":"))
     IF (pc_cur_ptam_setting=0
      AND pc_dual_bld_setting=2.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,"-  NO MASTER DOMAIN IS SET")
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(12,5,"Cutover Type")
      CALL text(12,48,concat("-  ",pc_default_message))
     ELSEIF (pc_cur_ptam_setting=0
      AND pc_dual_bld_setting=1.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,"-  NO MASTER DOMAIN IS SET")
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  BLOCKING")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  NO")
      CALL text(12,5,"Cutover Type")
      CALL text(12,48,concat("-  ",pc_default_message))
     ELSEIF (pc_cur_ptam_setting=0
      AND pc_dual_bld_setting=0.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,"-  NO MASTER DOMAIN IS SET")
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  NOT BLOCKING")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  YES")
      CALL text(12,5,"Cutover Type")
      IF (pc_default_message="AUTO CUTOVER")
       CALL text(12,48,concat("-  ",pc_default_message,
         "   WARNING!: Auto Cutover will not proceed if a possible Dual Build"))
       CALL text(13,76,"scenario is detected, manual acknowledgement required.")
      ELSE
       CALL text(12,48,concat("-  ",pc_default_message))
      ENDIF
     ELSEIF (pc_cur_ptam_setting=1
      AND pc_dual_bld_setting=2.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,concat("-  ",pc_tgt_env_name," IS MASTER"))
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(12,5,"Cutover Type")
      CALL text(12,48,concat("-  ",pc_default_message))
     ELSEIF (pc_cur_ptam_setting=1
      AND pc_dual_bld_setting=1.0)
      CALL text(9,5,concat("WARNING!: The ",tgt_env_name,
        " target domain cannot be configured as a Master domain while the "))
      CALL text(10,14,
       "Dual Build Triggers are configured as BLOCKING.  To modify the Dual Build Triggers configuration "
       )
      CALL text(11,14,concat("log into ",pc_tgt_env_name,
        " and use the Dual Build Reports/Configuration Menu found at the ","following path: "))
      CALL text(13,5,concat(
        "Merge Domain Administration Menu -> RDDS Status and Monitoring Tools -> ",
        "Dual Build Reports/Configuration."))
      CALL text(14,3,"Press ENTER to return to the previous menu.")
      CALL accept(14,46,"P;E"," ")
      RETURN("N")
     ELSEIF (pc_cur_ptam_setting=1
      AND pc_dual_bld_setting=0.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,concat("-  ",pc_tgt_env_name," IS MASTER"))
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  NOT BLOCKING")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  YES")
      CALL text(12,5,"Cutover Type")
      IF (pc_default_message="AUTO CUTOVER")
       CALL text(12,48,concat("-  ",pc_default_message,
         "   WARNING!: Auto Cutover will not proceed if a possible Dual Build"))
       CALL text(13,76,"scenario is detected, manual acknowledgement required.")
      ELSE
       CALL text(12,48,concat("-  ",pc_default_message))
      ENDIF
     ELSEIF ((pc_cur_ptam_setting=- (1)))
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      IF (pc_dual_bld_setting=2.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(12,5,"Cutover Type")
       CALL text(12,48,concat("-  ",pc_default_message))
      ELSEIF (pc_dual_bld_setting=1.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NO")
       CALL text(12,5,"Cutover Type")
       CALL text(12,48,concat("-  ",pc_default_message))
      ELSEIF (pc_dual_bld_setting=0.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  YES")
       CALL text(12,5,"Cutover Type")
       IF (pc_default_message="AUTO CUTOVER")
        CALL text(12,48,concat("-  ",pc_default_message,
          "   WARNING!: Auto Cutover will not proceed if a possible Dual Build"))
        CALL text(13,76,"scenario is detected, manual acknowledgement required.")
       ELSE
        CALL text(12,48,concat("-  ",pc_default_message))
       ENDIF
      ENDIF
     ENDIF
     IF (pc_rev_ptam <= 0)
      CALL text(14,3,concat("Should reference changes built in ",trim(pc_tgt_env_name,3),
        " be treated as MASTER so that changes merged from "))
      CALL text(15,3,concat(dmda_mr->env_name," will not overwrite? "))
      CALL text(15,35,"[(Y)es / (N)o / e(X)it]")
      CALL accept(15,60,"P;CU","_"
       WHERE curaccept IN ("Y", "N", "X"))
      SET pc_ptam_answer = curaccept
     ELSEIF (pc_rev_ptam=1)
      CALL text(14,3,concat("Since the source environment, ",trim(dmda_mr->env_name,3),
        ", is already configured as MASTER, the"," target environment, ",trim(pc_tgt_env_name,3),
        ", "))
      CALL text(15,3,"cannot be configured as MASTER.")
      SET pc_ptam_answer = "N"
      CALL text(17,3,"Do you wish to continue? [(Y)es / (N)o]")
      CALL accept(17,50,"P;CU","_"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="N")
       SET pc_ptam_answer = "X"
      ELSE
       SET pc_ptam_answer = "N"
      ENDIF
     ENDIF
     IF (pc_ptam_answer="X")
      ROLLBACK
      RETURN("N")
     ELSEIF (pc_ptam_answer="Y")
      SET pc_new_ptam_setting = 1
      CALL clear(14,1)
      CALL text(14,3,concat("New Configuration for target ",pc_tgt_env_name,":"))
      CALL text(15,5,"PTAM SETTING")
      CALL text(15,48,concat("-  ",pc_tgt_env_name," IS MASTER"))
      CALL text(16,5,"Dual Build Triggers")
      CALL text(16,48,"-  NOT BLOCKING")
      CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(17,48,"-  YES")
      CALL text(18,5,"Cutover Type")
      IF (pc_default_message="AUTO CUTOVER")
       CALL text(18,48,concat("-  ",pc_default_message,
         "   WARNING!: Auto Cutover will not proceed if a possible Dual Build"))
       CALL text(19,76,"scenario is detected, manual acknowledgement required.")
      ELSE
       CALL text(18,48,concat("-  ",pc_default_message))
      ENDIF
     ELSEIF (pc_ptam_answer="N")
      SET pc_new_ptam_setting = 0
      CALL clear(14,1)
      CALL text(14,3,concat("New Configuration for target ",pc_tgt_env_name,":"))
      CALL text(15,5,"PTAM SETTING")
      CALL text(15,48,"-  NO MASTER DOMAIN IS SET")
      CALL text(16,5,"Dual Build Triggers")
      CALL text(16,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(17,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(18,5,"Cutover Type")
      IF (pc_default_message="AUTO CUTOVER"
       AND pc_dual_bld_setting=0)
       CALL text(18,48,concat("-  ",pc_default_message,
         "   WARNING!: Auto Cutover will not proceed if a possible Dual Build"))
       CALL text(19,76,"scenario is detected, manual acknowledgement required.")
      ELSE
       CALL text(18,48,concat("-  ",pc_default_message))
      ENDIF
     ENDIF
     CALL text(21,3,"Confirm configuration changes? [(Y)es / (N)o] ")
     CALL accept(21,50,"P;CU","N"
      WHERE curaccept IN ("Y", "N"))
     SET pc_ptam_confirm_answer = curaccept
     IF (pc_ptam_confirm_answer="Y")
      IF (pc_ptam_answer="Y")
       SET dm_err->eproc = "Configure Dual Build Triggers based upon the PTAM setting"
       SET pc_dual_bld_trg_flag = dmda_ptam_dual_bld_trg_setting(pc_tgt_env_name,pc_target_env_id,
        pc_default_message,pc_ptam_answer)
       IF (pc_dual_bld_trg_flag=2)
        RETURN("N")
       ELSEIF (pc_dual_bld_trg_flag=1)
        SET pc_continue = 1
        SET stat = initrec(dera_request)
        SET stat = alterlist(dera_request->env_list,1)
        SET dera_request->child_env_id = pc_target_env_id
        SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
        SET dera_request->env_list[1].child_env_id = pc_target_env_id
        SET dera_request->env_list[1].relationship_type = "PENDING TARGET AS MASTER"
        EXECUTE dm_add_env_reltn
        IF ((dera_reply->err_num > 0))
         CALL text(15,3,dera_reply->err_msg)
         CALL text(16,3,"Insertion failed! Action aborted..")
         CALL pause(2)
         SET dm_err->eproc = "Inserting 'PENDING TARGET AS MASTER' to DM_ENV_RELTN"
         CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         GO TO exit_program
        ENDIF
        RETURN("Y")
       ELSEIF (pc_dual_bld_trg_flag=0)
        SET pc_continue = 0
       ENDIF
      ELSEIF (pc_ptam_answer="N")
       SET stat = initrec(dera_request)
       SET stat = alterlist(dera_request->env_list,1)
       SET dera_request->child_env_id = pc_target_env_id
       SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
       SET dera_request->env_list[1].child_env_id = pc_target_env_id
       SET dera_request->env_list[1].relationship_type = "NO PENDING TARGET AS MASTER"
       EXECUTE dm_add_env_reltn
       IF ((dera_reply->err_num > 0))
        CALL text(15,3,dera_reply->err_msg)
        CALL text(16,3,"Insertion failed! Action aborted..")
        CALL pause(2)
        SET dm_err->eproc = "Inserting 'NO PENDING TARGET AS MASTER' to DM_ENV_RELTN"
        CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
        SET dm_err->err_ind = 1
        GO TO exit_program
       ENDIF
       SET dm_err->eproc = "Configure Dual Build Triggers based upon the PTAM setting"
       SET pc_dual_bld_trg_flag = dmda_ptam_dual_bld_trg_setting(pc_tgt_env_name,pc_target_env_id,
        pc_default_message,pc_ptam_answer)
       IF (pc_dual_bld_trg_flag=2)
        RETURN("N")
       ELSEIF (pc_dual_bld_trg_flag=1)
        SET pc_continue = 1
        RETURN("Y")
       ELSEIF (pc_dual_bld_trg_flag=0)
        SET pc_continue = 0
       ENDIF
      ENDIF
     ELSE
      SET pc_continue = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE ptam_setup(ps_target_env_id)
   DECLARE ps_ptam_answer = vc WITH protect, noconstant("")
   DECLARE ps_ptam_confirm_answer = vc WITH protect, noconstant("")
   DECLARE ps_default_message = vc WITH protect, noconstant("")
   DECLARE ps_dual_bld_setting = f8 WITH protect, noconstant(0.0)
   DECLARE ps_dual_bld_trg_flag = i2 WITH protect, noconstant(0)
   DECLARE ps_cur_ptam_setting = i2 WITH protect, noconstant(0)
   DECLARE ps_new_ptam_setting = i2 WITH protect, noconstant(0)
   DECLARE ps_tgt_env_name = vc WITH protect, noconstant("")
   DECLARE ps_db_link = vc WITH protect, noconstant("")
   DECLARE ps_continue = i2 WITH protect, noconstant(0)
   DECLARE ps_temp_return = f8 WITH protect, noconstant(0.0)
   CALL clear(1,1)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL parser("cclseclogin go")
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = ""
      SET dm_err->err_ind = 0
     ENDIF
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "Configuring Auto/Planned Cutover"
      SET dm_err->emsg = "User not logged in cclseclogin"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = "Checking for full circle relationship"
   SELECT INTO "NL:"
    FROM dm_env_reltn r
    WHERE (r.parent_env_id=dmda_mr->env_id)
     AND r.child_env_id=ps_target_env_id
     AND r.relationship_type="RDDS MOVER CHANGES NOT LOGGED"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    CALL clear(1,1)
    CALL text(15,3,
     "These domains do not have a full circle relationship set up so pending target as master is not an option."
     )
    CALL text(18,20,"Press ENTER to return to the previous menu.")
    CALL accept(18,64,"P;E"," ")
    RETURN
   ENDIF
   SET dm_err->eproc = "Checking for existing PTAM relationship"
   SELECT INTO "NL:"
    FROM dm_env_reltn der
    WHERE der.relationship_type="PENDING TARGET AS MASTER"
     AND (der.child_env_id=dmda_mr->env_id)
     AND der.parent_env_id=ps_target_env_id
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual > 0)
    CALL clear(1,1)
    CALL text(15,3,
     "This domain already has a pending target as master relationship set up.  Only one relationship can"
     )
    CALL text(16,3,"be designated as pending target as master.")
    CALL text(18,20,"Press ENTER to return to the previous menu.")
    CALL accept(18,64,"P;E"," ")
    RETURN
   ENDIF
   SET dm_err->eproc = "Checking for open events"
   SET ps_oe_check = check_open_event(ps_target_env_id,dmda_mr->env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (ps_oe_check=1)
    CALL clear(1,1)
    CALL text(15,3,
     "There is currently an open event between these domains so pending target as master configuration is"
     )
    CALL text(16,3,
     "not an option.  All open events must be closed before pending target as master can be configured."
     )
    CALL text(18,20,"Press ENTER to return to the previous menu.")
    CALL accept(18,64,"P;E"," ")
    RETURN
   ENDIF
   SET ps_cur_ptam_setting = drcr_get_ptam_config(dmda_mr->env_id,ps_target_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE de.environment_id=ps_target_env_id
    DETAIL
     ps_tgt_env_name = trim(de.environment_name,3)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET ps_temp_return = drcr_get_cutover_config(dmda_mr->env_id,ps_target_env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((ps_temp_return=- (1)))
    SET ps_default_message = "NOT YET CONFIGURED FOR THIS RELATIONSHIP"
   ELSEIF (ps_temp_return=0)
    SET ps_default_message = "AUTO CUTOVER"
   ELSE
    SET ps_default_message = "PLANNED CUTOVER"
   ENDIF
   SET ps_dual_bld_setting = drcr_get_dual_build_config(dmda_mr->env_id,ps_target_env_id)
   IF ((ps_dual_bld_setting=- (1)))
    SET ps_dual_bld_setting = 2.0
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET ps_dual_bld_setting = 2.0
   ENDIF
   WHILE (ps_continue=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Pending Target as Master Configuration  ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(8,3,concat("Current Configuration for target ",ps_tgt_env_name,":"))
     IF (ps_cur_ptam_setting=1
      AND ps_dual_bld_setting=2.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,concat("-  ",ps_tgt_env_name," IS MASTER"))
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(12,5,"Cutover Type")
      CALL text(12,48,concat("-  ",ps_default_message))
     ELSEIF (ps_cur_ptam_setting=1
      AND ps_dual_bld_setting=1.0)
      CALL text(9,5,concat("WARNING!: The ",ps_tgt_env_name,
        " target domain cannot be configured as a Master domain while the "))
      CALL text(10,14,
       "Dual Build Triggers are configured as BLOCKING.  To modify the Dual Build Triggers configuration "
       )
      CALL text(11,14,concat("log into ",ps_tgt_env_name,
        " and use the Dual Build Reports/Configuration Menu found at the ","following path: "))
      CALL text(13,5,concat(
        "Merge Domain Administration Menu -> RDDS Status and Monitoring Tools -> ",
        "Dual Build Reports/Configuration."))
      CALL text(15,3,"Press ENTER to return to the previous menu.")
      CALL accept(15,46,"P;E"," ")
      RETURN
     ELSEIF (ps_cur_ptam_setting=1
      AND ps_dual_bld_setting=0.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,concat("-  ",ps_tgt_env_name," IS MASTER"))
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  NOT BLOCKING")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  YES")
      CALL text(12,5,"Cutover Type")
      CALL text(12,48,concat("-  ",ps_default_message))
     ELSEIF (ps_cur_ptam_setting=0
      AND ps_dual_bld_setting=2.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,"-  NO MASTER DOMAIN IS SET")
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      CALL text(12,5,"Cutover Type")
      CALL text(12,48,concat("-  ",ps_default_message))
     ELSEIF (ps_cur_ptam_setting=0
      AND ps_dual_bld_setting=1.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,"-  NO MASTER DOMAIN IS SET")
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  BLOCKING")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  NO")
      CALL text(12,5,"Cutover Type")
      CALL text(12,48,concat("-  ",ps_default_message))
     ELSEIF (ps_cur_ptam_setting=0
      AND ps_dual_bld_setting=0.0)
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,"-  NO MASTER DOMAIN IS SET")
      CALL text(10,5,"Dual Build Triggers")
      CALL text(10,48,"-  NOT BLOCKING")
      CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(11,48,"-  YES")
      CALL text(12,5,"Cutover Type")
      CALL text(12,48,concat("-  ",ps_default_message))
     ELSEIF ((ps_cur_ptam_setting=- (1)))
      CALL text(9,5,"PTAM SETTING")
      CALL text(9,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
      IF (ps_dual_bld_setting=2.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(12,5,"Cutover Type")
       CALL text(12,48,concat("-  ",ps_default_message))
      ELSEIF (ps_dual_bld_setting=1.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  NO")
       CALL text(12,5,"Cutover Type")
       CALL text(12,48,concat("-  ",ps_default_message))
      ELSEIF (ps_dual_bld_setting=0.0)
       CALL text(10,5,"Dual Build Triggers")
       CALL text(10,48,"-  NOT BLOCKING")
       CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(11,48,"-  YES")
       CALL text(12,5,"Cutover Type")
       CALL text(12,48,concat("-  ",ps_default_message))
      ENDIF
     ENDIF
     CALL text(14,3,concat("Should reference changes built in ",trim(ps_tgt_env_name,3),
       " be treated as MASTER so that changes merged from "))
     CALL text(15,3,concat(dmda_mr->env_name," will not overwrite? "))
     CALL text(15,35,"[(Y)es / (N)o / e(X)it]")
     CALL accept(15,60,"P;CU","_"
      WHERE curaccept IN ("Y", "N", "X"))
     SET ps_ptam_answer = curaccept
     IF (ps_ptam_answer="X")
      ROLLBACK
      RETURN
     ELSEIF (ps_ptam_answer="Y")
      SET ps_new_ptam_setting = 1
      CALL clear(14,1)
      CALL text(14,3,concat("New Configuration for target ",ps_tgt_env_name,":"))
      CALL text(15,5,"PTAM SETTING")
      CALL text(15,48,concat("-  ",ps_tgt_env_name," IS MASTER"))
      CALL text(16,5,"Dual Build Triggers")
      CALL text(16,48,"-  NOT BLOCKING")
      CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
      CALL text(17,48,"-  YES")
      CALL text(18,5,"Cutover Type")
      CALL text(18,48,concat("-  ",ps_default_message))
     ELSEIF (ps_ptam_answer="N")
      SET ps_new_ptam_setting = 0
      CALL clear(14,1)
      CALL text(14,3,concat("New Configuration for target ",ps_tgt_env_name,":"))
      IF (ps_dual_bld_setting=2.0)
       CALL text(15,5,"PTAM SETTING")
       CALL text(15,48,"-  NO MASTER DOMAIN IS SET")
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NOT YET CONFIGURED FOR THIS RELATIONSHIP")
       CALL text(18,5,"Cutover Type")
       CALL text(18,48,concat("-  ",ps_default_message))
      ELSEIF (ps_dual_bld_setting=1.0)
       CALL text(15,5,"PTAM SETTING")
       CALL text(15,48,"-  NO MASTER DOMAIN IS SET")
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NO")
       CALL text(18,5,"Cutover Type")
       CALL text(18,48,concat("-  ",ps_default_message))
      ELSEIF (ps_dual_bld_setting=0.0)
       CALL text(15,5,"PTAM SETTING")
       CALL text(15,48,"-  NO MASTER DOMAIN IS SET")
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  YES")
       CALL text(18,5,"Cutover Type")
       CALL text(18,48,concat("-  ",ps_default_message))
      ENDIF
     ENDIF
     CALL text(21,3,"Confirm configuration changes? [(Y)es / (N)o] ")
     CALL accept(21,50,"P;CU","N"
      WHERE curaccept IN ("Y", "N"))
     SET ps_ptam_confirm_answer = curaccept
     IF (ps_ptam_confirm_answer="N")
      SET ps_continue = 0
     ELSEIF (ps_ptam_confirm_answer="Y")
      IF (ps_cur_ptam_setting > ps_new_ptam_setting)
       SET dm_err->eproc = "Configure Dual Build Triggers based upon the PTAM setting"
       SET ps_dual_bld_trg_flag = dmda_ptam_dual_bld_trg_setting(ps_tgt_env_name,ps_target_env_id,
        ps_default_message,ps_ptam_answer)
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (ps_dual_bld_trg_flag=2)
        RETURN
       ELSEIF (ps_dual_bld_trg_flag=1)
        SET ps_continue = 1
        SET stat = initrec(derd_request)
        SET stat = alterlist(derd_request->env_list,1)
        SET derd_request->child_env_id = ps_target_env_id
        SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
        SET derd_request->env_list[1].child_env_id = ps_target_env_id
        SET derd_request->env_list[1].relationship_type = "PENDING TARGET AS MASTER"
        EXECUTE dm_del_env_reltn
        IF ((derd_reply->err_num > 0))
         CALL text(15,3,derd_reply->err_msg)
         CALL text(16,3,"Deletion failed! Action abort...")
         SET dm_err->eproc = "DELETING 'PENDING TARGET AS MASTER' from DM_ENV_RELTN"
         CALL disp_msg(derd_reply->err_msg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         GO TO exit_program
        ENDIF
        SET stat = initrec(dera_request)
        SET stat = alterlist(dera_request->env_list,1)
        SET dera_request->child_env_id = ps_target_env_id
        SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
        SET dera_request->env_list[1].child_env_id = ps_target_env_id
        SET dera_request->env_list[1].relationship_type = "NO PENDING TARGET AS MASTER"
        EXECUTE dm_add_env_reltn
        IF ((dera_reply->err_num > 0))
         CALL text(15,3,dera_reply->err_msg)
         CALL text(16,3,"Insertion failed! Action aborted..")
         CALL pause(2)
         SET dm_err->eproc = "Inserting 'NO PENDING TARGET AS MASTER' to DM_ENV_RELTN"
         CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         GO TO exit_program
        ENDIF
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        RETURN
       ELSEIF (ps_dual_bld_trg_flag=0)
        SET ps_continue = 0
       ENDIF
      ELSEIF (ps_cur_ptam_setting < ps_new_ptam_setting)
       SET dm_err->eproc = "Configure Dual Build Triggers based upon the PTAM setting"
       SET ps_dual_bld_trg_flag = dmda_ptam_dual_bld_trg_setting(ps_tgt_env_name,ps_target_env_id,
        ps_default_message,ps_ptam_answer)
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (ps_dual_bld_trg_flag=2)
        RETURN
       ELSEIF (ps_dual_bld_trg_flag=1)
        SET ps_continue = 1
        SET stat = initrec(dera_request)
        SET stat = alterlist(dera_request->env_list,1)
        SET dera_request->child_env_id = ps_target_env_id
        SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
        SET dera_request->env_list[1].child_env_id = ps_target_env_id
        IF (ps_new_ptam_setting=1)
         SET dera_request->env_list[1].relationship_type = "PENDING TARGET AS MASTER"
         SET dm_err->eproc = "Inserting 'PENDING TARGET AS MASTER' to DM_ENV_RELTN"
         IF (ps_cur_ptam_setting=0)
          SET stat = initrec(derd_request)
          SET stat = alterlist(derd_request->env_list,1)
          SET derd_request->child_env_id = ps_target_env_id
          SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
          SET derd_request->env_list[1].child_env_id = ps_target_env_id
          SET derd_request->env_list[1].relationship_type = "NO PENDING TARGET AS MASTER"
          EXECUTE dm_del_env_reltn
          IF ((derd_reply->err_num > 0))
           CALL text(15,3,derd_reply->err_msg)
           CALL text(16,3,"Deletion failed! Action abort...")
           SET dm_err->eproc = "DELETING 'NO PENDING TARGET AS MASTER' from DM_ENV_RELTN"
           CALL disp_msg(derd_reply->err_msg,dm_err->logfile,1)
           SET dm_err->err_ind = 1
           GO TO exit_program
          ENDIF
         ENDIF
        ELSE
         SET dera_request->env_list[1].relationship_type = "NO PENDING TARGET AS MASTER"
         SET dm_err->eproc = "Inserting 'NO PENDING TARGET AS MASTER' to DM_ENV_RELTN"
        ENDIF
        EXECUTE dm_add_env_reltn
        IF ((dera_reply->err_num > 0))
         CALL text(15,3,dera_reply->err_msg)
         CALL text(16,3,"Insertion failed! Action aborted..")
         CALL pause(2)
         CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         GO TO exit_program
        ENDIF
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
       ELSE
        SET ps_continue = 0
       ENDIF
      ELSEIF (ps_cur_ptam_setting=ps_new_ptam_setting)
       SET dm_err->eproc = "Configure Dual Build Triggers based upon the PTAM setting"
       SET ps_dual_bld_trg_flag = dmda_ptam_dual_bld_trg_setting(ps_tgt_env_name,ps_target_env_id,
        ps_default_message,ps_ptam_answer)
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (ps_dual_bld_trg_flag=0)
        SET ps_continue = 0
       ELSE
        RETURN
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   RETURN
 END ;Subroutine
 SUBROUTINE chg_log_vers(null)
   DECLARE select_validate = i2
   DECLARE target_env_id = f8
   FREE RECORD clv_request
   RECORD clv_request(
     1 table_name = vc
     1 table_suffix = vc
   )
   SET clv_request->table_name = "*"
   RECORD clv_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET select_validate = 0
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,35,"***  Select PTAM Source Environment   ***")
   CALL text(7,3,"Please input a PTAM source environment id: ")
   WHILE (select_validate=0)
     CALL clear(20,01,74)
     CALL text(23,05,"HELP: Press <SHIFT><F5>  0 to exit")
     SET help =
     SELECT INTO "nl:"
      d.parent_env_id, de.environment_name
      FROM dm_env_reltn d,
       dm_environment de,
       dummyt dt
      PLAN (d
       WHERE (d.child_env_id=dmda_mr->env_id)
        AND d.relationship_type="PENDING TARGET AS MASTER")
       JOIN (dt)
       JOIN (de
       WHERE de.environment_id=d.parent_env_id)
      ORDER BY d.parent_env_id
      WITH nocounter, outerjoin = dt
     ;end select
     CALL accept(7,70,"P(15);CU","0")
     IF (cnvtreal(curaccept)=0)
      RETURN
     ELSE
      SELECT INTO "nl:"
       der.parent_env_id
       FROM dm_env_reltn der
       WHERE (der.child_env_id=dmda_mr->env_id)
        AND der.relationship_type="PENDING TARGET AS MASTER"
        AND der.parent_env_id=cnvtreal(curaccept)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET select_validate = 1
      ELSE
       CALL clear(20,1)
       CALL text(20,3,"Invalid environment ID")
       CALL pause(3)
      ENDIF
     ENDIF
   ENDWHILE
   SET target_env_id = cnvtreal(curaccept)
   SET message = window
   CALL clear(1,1)
   SET dm_err->eproc = "Checking remaining rows that need a new version id"
   SELECT
    count(*)
    FROM dm_chg_log dcl
    WHERE  NOT (dcl.ptam_match_hash IN (
    (SELECT
     d.ptam_match_hash
     FROM dm_pk_where d
     WHERE d.table_name=dcl.table_name)))
     AND dcl.log_type IN ("REFCHG", "NORDDS", "PKWREF", "PKWNOR")
     AND dcl.target_env_id=target_env_id
     AND  EXISTS (
    (SELECT
     "x"
     FROM dm_pk_where dpw
     WHERE dpw.table_name=dcl.table_name))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_disp_backfill_msgs(dbm_sc_explode,dbm_ptam_check,dbm_dcl_check,dbm_pkw_check,
  dbm_mov_check,dbm_src_sc_explode)
   DECLARE dbm_pos = i4
   DECLARE dbm_tspace_size = i4
   DECLARE dbm_seg_pos = i4
   DECLARE dbm_seg_size = i4
   DECLARE dbm_str_id = vc
   DECLARE dbm_open_event_dt_tm = dq8
   SET dm_err->eproc = "Obtaining tablespace/segment information for DM_CHG_LOG"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dsi_init_all_space_info(null)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (dsi_get_segment_info("DM_CHG_LOG","TABLE")=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET dbm_tspace_size = space_info->tspace_cnt
   SET dbm_seg_size = space_info->segment_cnt
   SET dbm_str_id = trim(cnvtstring(srm_env_id))
   IF (((dbm_sc_explode=0) OR (((dbm_dcl_check=0
    AND dbm_ptam_check > 0
    AND dbm_pkw_check=1) OR (dbm_src_sc_explode=0)) )) )
    SET dm_err->eproc = "Display backfill messages to ccl browser screen."
    SELECT INTO "MINE"
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      IF (dbm_mov_check=0)
       row + 1, col 1, "A new RDDS event was opened successfully.",
       row + 1
      ENDIF
      IF (dbm_sc_explode=0
       AND dbm_ptam_check > 0
       AND dbm_dcl_check=0
       AND ((dbm_pkw_check=0) OR (dbm_mov_check=0)) )
       row + 1, col 1,
       "These two scripts cannot be run at the same time.  Run the DM_SINGLE_COMMIT_EXPLODE script to completion",
       row + 1, col 1, "before beginning the DM_RMC_CORRECT_DCL script.",
       row + 1
      ENDIF
      IF (dbm_sc_explode=0
       AND ((dbm_pkw_check=0) OR (dbm_mov_check=0)) )
       row + 1, col 1,
       "In order to ensure the DM_CHG_LOG entries are in the correct format, run the following script in the",
       col + 1, dmda_mr->env_name, row + 1,
       col 1,
       "domain prior to starting movers.  This script can be run in multiple sessions if needed.",
       row + 1,
       col 1, "DM_SINGLE_COMMIT_EXPLODE GO", row + 1
      ENDIF
      IF (dbm_ptam_check > 0
       AND dbm_dcl_check=0
       AND ((dbm_sc_explode=0) OR (dbm_pkw_check=1)) )
       row + 1, col 1, "In order to ensure the DM_CHG_LOG for the",
       col + 1, dmda_mr->env_name, col + 1,
       "domain is correct for use with Pending Target as Master (PTAM),", row + 1, col 1,
       "run the following script in the", col + 1, dmda_mr->env_name,
       col + 1, "domain prior to starting movers.", row + 1,
       col 1, "This script can be run in multiple sessions if needed.", row + 1,
       col 1, "DM_RMC_CORRECT_DCL", col + 1,
       dbm_str_id, ".0, 0 GO", row + 1
      ENDIF
      IF (dbm_src_sc_explode=0
       AND ((dbm_pkw_check=0) OR (dbm_mov_check=0)) )
       row + 1, col 1,
       "In order to ensure the DM_CHG_LOG entries are in the correct format, run the following script in the",
       col + 1, srm_env_name, row + 1,
       col 1,
       "domain prior to starting movers.  This script can be run in multiple sessions if needed.",
       row + 1,
       col 1, "DM_SINGLE_COMMIT_EXPLODE GO", row + 1
      ENDIF
      row + 1, col 1, "Please scroll all the way to the bottom to view the entire message.",
      row + 1, col 1,
      "The process(es) above may add a variable number of rows to the table DM_CHG_LOG and its indexes, depending",
      row + 1, col 1,
      "on the size of that table and the data in it.  Please make sure the following tablespace(s) have sufficient",
      row + 1, col 1, "free space to avoid space issues during the execution of above process(es).",
      row + 2
      FOR (dbm_pos = 1 TO dbm_tspace_size)
        col 1, space_info->tspace[dbm_pos].tspace_name, row + 1
      ENDFOR
      IF ((space_info->segment.chk_extents=1))
       row + 1, col 1,
       "Please make sure the following objects have sufficient max_extents to avoid extent issues during the",
       row + 1, col 1, "execution of above process(es).",
       row + 2
       FOR (dbm_seg_pos = 1 TO dbm_seg_size)
         IF ((space_info->segment[dbm_seg_pos].chk_extents=1))
          col 1, space_info->segment[dbm_seg_pos].seg_name, row + 1
         ENDIF
       ENDFOR
      ENDIF
      IF (((dbm_sc_explode=0) OR (dbm_src_sc_explode=0))
       AND dbm_mov_check=1)
       row + 1, col 1,
       "You will be returned to the previous menu immediately and data movers will not be started.  You will have to",
       row + 1, col 1,
       "complete execution of the above scripts and then attempt to start data movers through this menu at a later time.",
       row + 1
      ENDIF
      row + 1, col 1, "End of report"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((dbm_sc_explode=0) OR (dbm_src_sc_explode=0)) )
     RETURN(1)
    ELSEIF (dbm_ptam_check > 0
     AND dbm_dcl_check=0
     AND dbm_pkw_check > 0)
     IF (dmda_pkw_prompt(dbm_mov_check)=1)
      RETURN(2)
     ELSE
      RETURN(1)
     ENDIF
    ELSE
     RETURN(3)
    ENDIF
   ENDIF
   RETURN(3)
 END ;Subroutine
 SUBROUTINE dmda_pkw_prompt(pp_mov_check)
   SET dm_err->eproc = "Promp user to run dm_rmc_correct_dcl."
   CALL clear(1,1)
   CALL text(8,3,concat("Please run the following script in the ",dmda_mr->env_name,
     " domain to ensure that DM_CHG_LOG is correct for use with"))
   CALL text(9,3,
    "Pending Target as Master (PTAM).  This script can be run in multiple sessions if needed.")
   CALL text(10,3,concat("DM_RMC_CORRECT_DCL ",trim(cnvtstring(srm_env_id)),".0, 0 GO"))
   CALL text(12,3,"Would you like to have the script above started in this CCL session(Y/N)?")
   CALL text(14,3,
    "If you answer 'Yes', the above script will be executed in this CCL session and this telnet session"
    )
   CALL text(15,3,"will have to remain connected for the duration of this script execution.")
   IF (pp_mov_check=1)
    CALL text(16,3,
     "Once the above script has completed successfully, the data movers will be started and you will be"
     )
    CALL text(17,3,"returned to the previous menu.")
    CALL text(19,3,"If you answer 'No' you will be returned to the previous menu immediately.")
    CALL text(20,3,
     "Data movers will not be started.  You will have to complete execution of the above script in another"
     )
    CALL text(21,3,"session and then attempt to start data movers through this menu at a later time."
     )
   ELSE
    CALL text(17,3,"If you answer 'No' you will be returned to the previous menu immediately.")
   ENDIF
   CALL accept(12,89,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    RETURN(1)
   ELSEIF (curaccept="N")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE modify_unmapped_setting(null)
   DECLARE mus_back = i2
   DECLARE mus_num = f8
   DECLARE mus_str = vc
   DECLARE mus_install_date = f8
   DECLARE mus_trigger_date = f8
   SET dm_err->eproc = "Allow / Disallow unmapped users to make changes in the domain"
   CALL clear(1,1)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL parser("cclseclogin go")
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "Modifying Unmapped Settings"
      SET dm_err->emsg = "User not logged in cclseclogin"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CONFIGURATION"
     AND di.info_name="UNMAPPED UDC ALLOWED"
    DETAIL
     mus_num = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   IF (((curqual=0) OR (mus_num != 0)) )
    SET mus_str = "ALLOW"
   ELSE
    SET mus_str = "DISALLOW"
   ENDIF
   SET mus_back = 0
   WHILE (mus_back=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,43,"***  UNMAPPED CONTEXT USERS  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,
      "Choosing to disallow unmapped users from making changes will prevent users from making changes on RDDS"
      )
     CALL text(8,3,"tracked tables if the user name is not mapped to a build context.")
     CALL text(10,3,concat("Current Setting: ",mus_str))
     CALL text(12,3,"Should unmapped users be allowed to make changes? (Y/N)")
     CALL accept(12,72,"A;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      IF (mus_str="DISALLOW")
       CALL text(20,3,"Do you wish to continue? ( (Y)es/(N)o/e(X)it )")
       CALL accept(20,72,"A;CU","Y"
        WHERE curaccept IN ("Y", "N", "X"))
       IF (curaccept="Y")
        UPDATE  FROM dm_info di
         SET di.info_number = 1.0, di.updt_id = reqinfo->updt_id, di.updt_cnt = (di.updt_cnt+ 1),
          di.updt_task = reqinfo->updt_task, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
          .updt_applctx = reqinfo->updt_applctx
         WHERE di.info_domain="RDDS CONFIGURATION"
          AND di.info_name="UNMAPPED UDC ALLOWED"
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ENDIF
        IF (curqual=0)
         INSERT  FROM dm_info di
          SET di.info_number = 1.0, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
           di.updt_task = reqinfo->updt_task, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
           .updt_applctx = reqinfo->updt_applctx,
           di.info_domain = "RDDS CONFIGURATION", di.info_name = "UNMAPPED UDC ALLOWED"
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc) != 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          ROLLBACK
          GO TO exit_program
         ENDIF
        ENDIF
        COMMIT
        EXECUTE dm_rmc_check_unmapped
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ELSE
         SET stat = alterlist(auto_ver_request->qual,1)
         SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
         SET auto_ver_request->qual[1].rdds_event = "Unmapped User Context Change"
         SET auto_ver_request->qual[1].paired_environment_id = 0
         SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
         SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "INFO NUMBER VALUE"
         SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = "ALLOW UNMAPPED USERS"
         SET auto_ver_request->qual[1].detail_qual[1].event_value = 1
         EXECUTE dm_rmc_auto_verify_setup
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          ROLLBACK
          GO TO exit_program
         ELSE
          COMMIT
         ENDIF
        ENDIF
        SET mus_back = 1
       ELSEIF (curaccept="X")
        SET mus_back = 1
       ENDIF
      ELSE
       CALL text(20,3,"Do you wish to continue? ( (Y)es/(N)o/e(X)it )")
       CALL accept(20,72,"A;CU","Y"
        WHERE curaccept IN ("Y", "N", "X"))
       IF (curaccept="Y")
        SET mus_back = 1
       ELSEIF (curaccept="X")
        SET mus_back = 1
       ENDIF
      ENDIF
     ELSEIF (curaccept="N")
      IF (mus_str="ALLOW")
       SELECT INTO "nl:"
        FROM dm_refchg_prsnl_ctx_r dr
        WHERE dr.active_ind=1
         AND dr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND dr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_program
       ENDIF
       IF (curqual=0)
        CALL text(14,3,
         "You have chosen to disallow unmapped users from making changes. Currently there are no actively "
         )
        CALL text(15,3,
         "mapped users to contexts in this domain. No changes will be allowed on reference tables tracked "
         )
        CALL text(16,3,"by RDDS until a context to user mapping is created.")
       ENDIF
       CALL text(20,3,"Do you wish to continue? ( (Y)es/(N)o/e(X)it )")
       CALL accept(20,72,"A;CU","Y"
        WHERE curaccept IN ("Y", "N", "X"))
       IF (curaccept="Y")
        UPDATE  FROM dm_info di
         SET di.info_number = 0.0, di.updt_id = reqinfo->updt_id, di.updt_cnt = (di.updt_cnt+ 1),
          di.updt_task = reqinfo->updt_task, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
          .updt_applctx = reqinfo->updt_applctx
         WHERE di.info_domain="RDDS CONFIGURATION"
          AND di.info_name="UNMAPPED UDC ALLOWED"
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ENDIF
        IF (curqual=0)
         INSERT  FROM dm_info di
          SET di.info_number = 0.0, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
           di.updt_task = reqinfo->updt_task, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
           .updt_applctx = reqinfo->updt_applctx,
           di.info_domain = "RDDS CONFIGURATION", di.info_name = "UNMAPPED UDC ALLOWED"
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc) != 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          ROLLBACK
          GO TO exit_program
         ENDIF
        ENDIF
        COMMIT
        EXECUTE dm_rmc_check_unmapped
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ELSE
         SET stat = alterlist(auto_ver_request->qual,1)
         SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
         SET auto_ver_request->qual[1].rdds_event = "Unmapped User Context Change"
         SET auto_ver_request->qual[1].paired_environment_id = 0
         SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
         SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "INFO NUMBER VALUE"
         SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = "DISALLOW UNMAPPED USERS"
         SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
         EXECUTE dm_rmc_auto_verify_setup
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          ROLLBACK
          GO TO exit_program
         ELSE
          COMMIT
         ENDIF
        ENDIF
        SET mus_back = 1
       ELSEIF (curaccept="X")
        SET mus_back = 1
       ENDIF
      ELSE
       CALL text(20,3,"Do you wish to continue? ( (Y)es/(N)o/e(X)it )")
       CALL accept(20,72,"A;CU","Y"
        WHERE curaccept IN ("Y", "N", "X"))
       IF (curaccept="Y")
        SET mus_back = 1
       ELSEIF (curaccept="X")
        SET mus_back = 1
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE connect_info_display(null)
   CALL clear(18,1)
   CALL text(19,22,"!!!WARNING: The next few screens will prompt you for the following: ")
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL text(20,22,"   CCLSECLOGIN information.")
    ENDIF
   ENDIF
   IF (cursys="AXP")
    CALL text(21,22,"   The TARGET domain V500 database password, connect string and batch queue.")
   ELSE
    CALL text(21,22,"   The TARGET domain V500 database password and connect string.")
   ENDIF
   CALL text(22,22,"Please have this information ready!!!")
   CALL text(24,3,"Would you like to continue?(Y/N)")
   CALL accept(24,40,"P;CU"," "
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE mc_confirm_screen(process,num)
   DECLARE mcs_process_type = vc
   DECLARE mcs_num = i4
   SET mcs_process_type = process
   SET mcs_num = num
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,7,132)
   IF (mcs_process_type="trigger")
    CALL text(3,40,"***  Create RDDS Triggers ***")
   ELSE
    CALL text(3,40,"***  Manage Data Movers ***")
   ENDIF
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   IF (mcs_process_type="merge")
    CALL text(15,03,
     "  You can use 'View data movers' from the next menu to monitor the number of movers running.")
    CALL text(16,03,
     "  For details on each RDDS mover instance started, view the rdds_run_mover*.log file(s) in CCLUSERDIR."
     )
   ELSEIF (mcs_process_type="cutover")
    CALL text(15,03,
     "  You can use 'View Cutover Processes' from the next menu to monitor the number of cutovers running."
     )
    CALL text(16,03,
     "  For details on each RDDS cutover instance started, view the rdds_run_cutover*.log file(s) in CCLUSERDIR."
     )
   ELSEIF (mcs_process_type="xlat_bckfll")
    CALL text(15,03,concat(
      "  You can use 'View Translation Backfill Progress' from the next menu to monitor the number of",
      " processes running."))
    CALL text(16,03,concat(
      "  For details on each RDDS Translation Backfill instance started, view the ",
      "rdds_run_xlat_rdm*.log file(s) in CCLUSERDIR."))
   ELSEIF (mcs_process_type="trigger")
    CALL text(15,03,concat(
      "  You can use 'View Trigger Creation Progress' from the 'Manage change log triggers' menu "))
    CALL text(16,03," to monitor the processes running.")
    CALL text(17,03,concat("  For details on each Trigger Creation process started, view the ",
      "rdds_run_proc*.log file(s) in CCLUSERDIR."))
   ENDIF
   CALL text(24,20,"Press ENTER to continue")
   CALL accept(24,60,"P;HCU","N")
 END ;Subroutine
 SUBROUTINE dmda_content_context_rpt(null)
   DECLARE dccr_back = i2 WITH protect, noconstant(0)
   DECLARE dccr_event = vc WITH protect, noconstant("")
   DECLARE dccr_open_dt = dq8 WITH protect, noconstant(0.0)
   DECLARE dccr_end_dt = dq8 WITH protect, noconstant(0.0)
   DECLARE dccr_qual = i2 WITH protect, noconstant(0)
   DECLARE dccr_file_name = vc WITH protect, noconstant("")
   CALL get_tgt_env_id("RDDS CONTENT ACROSS CONTEXTS REPORT",1)
   IF (tgt_env_id > 0)
    WHILE (dccr_back=0)
      SET message = window
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,5,132)
      CALL text(3,43,"***  RDDS CONTENT ACROSS CONTEXTS REPORT  ***")
      CALL text(4,75,"ENVIRONMENT ID:")
      CALL text(4,20,"ENVIRONMENT NAME:")
      CALL text(4,95,cnvtstring(dmda_mr->env_id))
      CALL text(4,40,dmda_mr->env_name)
      CALL text(7,3,
       "For data accuracy, this report can only be run against the most recently opened RDDS event")
      SELECT INTO "nl:"
       drel.event_reason
       FROM dm_rdds_event_log drel
       WHERE drel.cur_environment_id=tgt_env_id
        AND (drel.paired_environment_id=dmda_mr->env_id)
        AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
        AND  NOT ( EXISTS (
       (SELECT
        1
        FROM dm_rdds_event_log drel2
        WHERE drel2.cur_environment_id=tgt_env_id
         AND (drel2.paired_environment_id=dmda_mr->env_id)
         AND drel2.rdds_event_key="ENDREFERENCEDATASYNC"
         AND drel.event_reason=drel2.event_reason)))
       DETAIL
        dccr_event = drel.event_reason, dccr_open_dt = drel.event_dt_tm
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      SET dccr_qual = curqual
      IF (dccr_qual=0)
       SELECT INTO "nl:"
        FROM dm_rdds_event_log drel,
         dm_rdds_event_log drel2
        WHERE drel.cur_environment_id=tgt_env_id
         AND (drel.paired_environment_id=dmda_mr->env_id)
         AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
         AND drel.event_reason=drel2.event_reason
         AND drel2.cur_environment_id=tgt_env_id
         AND (drel2.paired_environment_id=dmda_mr->env_id)
         AND drel2.rdds_event_key="ENDREFERENCEDATASYNC"
        ORDER BY drel.event_dt_tm DESC
        DETAIL
         dccr_event = drel.event_reason, dccr_open_dt = drel.event_dt_tm, dccr_end_dt = drel2
         .event_dt_tm
        WITH nocounter, maxrec = 1
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       SET dccr_qual = curqual
      ENDIF
      IF (dccr_qual=0)
       CALL text(9,3,"No RDDS events detected. This report cannot be run without RDDS events.")
       CALL text(12,3,"Return to the previous menu? [(Y)es]")
       CALL accept(12,40,"P;CU","Y"
        WHERE curaccept IN ("Y"))
       SET dccr_back = 1
      ELSE
       CALL text(9,3,concat("Target Domain: ",tgt_env_name))
       CALL text(10,3,concat("Event detected: ",dccr_event))
       CALL text(11,3,concat("Event opened: ",format(dccr_open_dt,";;q")))
       IF (dccr_end_dt > 0.0)
        CALL text(12,3,concat("Event closed: ",format(dccr_end_dt,";;q")))
       ENDIF
       CALL text(14,3,"Continue? [(Y)es / (N)o]")
       CALL accept(14,29,"P;CU","Y"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        CALL clear(13,1)
        CALL text(14,3,"Enter the name for the output XML file (0 to exit): ")
        CALL accept(14,70,"X(30);CU","0")
        SET dccr_file_name = trim(curaccept,3)
        IF (dccr_file_name="0")
         SET dccr_back = 1
        ELSE
         CALL text(16,3,
          "The following 2 files will be created by this report and found in CCLUSERDIR upon completion:"
          )
         CALL text(17,50,concat(cnvtlower(dccr_file_name),".xml"))
         CALL text(18,50,concat(cnvtlower(dccr_file_name),".xsl"))
         CALL text(20,3,concat("Note: Depending on the size of your DM_CHG_LOG table ",
           "this report might take several minutes to complete."))
         CALL text(22,3,"Continue? [(Y)es / (N)o / e(X)it]")
         CALL accept(22,38,"P;CU","Y"
          WHERE curaccept IN ("Y", "N", "X"))
         IF (curaccept="Y")
          CALL clear(22,1)
          CALL video(b)
          CALL text(22,3,"Generating report...")
          EXECUTE dm_rmc_sp_report dmda_mr->env_id, tgt_env_id, dccr_event,
          dccr_file_name
          SET dccr_back = 1
          CALL video(n)
         ELSEIF (curaccept="X")
          SET dccr_back = 1
         ENDIF
        ENDIF
       ELSE
        SET dccr_back = 1
       ENDIF
      ENDIF
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE get_tgt_env_id(sub_title,sub_confirm_ind)
  DECLARE env_confirmed = i2 WITH protect, noconstant(0)
  WHILE (env_confirmed=0)
    IF (tgt_env_id=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
     CALL text(3,40,concat("*** ",sub_title," ***"))
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(8,3,"1. Please input target environment id (Enter 0 to exit):")
     SET help =
     SELECT INTO "nl:"
      der.child_env_id, de.environment_name
      FROM dm_info di,
       dm_env_reltn der,
       dm_environment de
      PLAN (di
       WHERE di.info_domain="DATA MANAGEMENT"
        AND di.info_name="DM_ENV_ID")
       JOIN (der
       WHERE di.info_number=der.parent_env_id
        AND der.relationship_type=reltn_type
        AND der.post_link_name IS NOT null
        AND der.post_link_name != " ")
       JOIN (de
       WHERE ((de.environment_id=der.child_env_id) UNION (
       (SELECT
        parent_env_id = 0, environment_name = "(Exit)"
        FROM dual))) )
      ORDER BY 2
      WITH nocounter
     ;end select
     SET validate =
     SELECT INTO "nl:"
      der.child_env_id
      FROM dm_info di,
       dm_env_reltn der
      PLAN (di
       WHERE di.info_domain="DATA MANAGEMENT"
        AND di.info_name="DM_ENV_ID")
       JOIN (der
       WHERE di.info_number=der.parent_env_id
        AND der.relationship_type=reltn_type
        AND der.parent_env_id=cnvtreal(curaccept)
        AND der.post_link_name IS NOT null
        AND ((der.post_link_name != " ") UNION (
       (SELECT
        child_env_id = 0
        FROM dual
        WHERE cnvtreal(curaccept)=0))) )
      WITH nocounter
     ;end select
     SET validate = 2
     CALL accept(8,70,"N(15);CU","0")
     CALL clear(23,1)
     SET tgt_env_id = cnvtreal(trim(curaccept,3))
     SELECT INTO "nl:"
      FROM dm_environment de
      WHERE de.environment_id=tgt_env_id
      DETAIL
       tgt_env_name = de.environment_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     SET help = off
     SET validate = off
     CALL clear(23,1)
    ENDIF
    IF (tgt_env_id != 0)
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,concat("*** ",sub_title," ***"))
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,03,concat("Your current selected TARGET environment is : ",tgt_env_name))
     CALL text(10,03,concat("With an environment_id of            : ",cnvtstring(tgt_env_id)))
     IF (sub_confirm_ind=1)
      CALL text(12,3,"Continue? [(Y)es / (N)o / e(X)it]")
      CALL accept(12,38,"P;CU","Y"
       WHERE curaccept IN ("Y", "N", "X"))
     ELSE
      CALL text(12,3,"Continue? [(Y)es / (N)o]")
      CALL accept(12,29,"P;CU","Y"
       WHERE curaccept IN ("Y", "N"))
     ENDIF
    ELSE
     SET env_confirmed = 1
     SET tgt_env_name = ""
    ENDIF
    IF (curaccept="Y")
     SET env_confirmed = 1
    ELSEIF (curaccept="N")
     SET tgt_env_id = 0
     SET tgt_env_name = ""
    ELSEIF (curaccept="X")
     SET env_confirmed = 1
     SET tgt_env_id = 0
     SET tgt_env_name = ""
    ENDIF
  ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_move_chld_exceptions(null)
   DECLARE mce_reset_ind = i2 WITH protect, noconstant(0)
   CALL get_src_env_id("Child Exception Reset",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONFIGURATION"
     AND d.info_name=concat("CHILDEXCPTN",trim(cnvtstring(srm_env_id)),trim(cnvtstring(dmda_mr->
       env_id)))
    DETAIL
     mce_reset_ind = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ELSEIF (curqual=0)
    SET mce_reset_ind = 1
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Child Exception Reset ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(9,3,
    "When the RDDS mover processes data and removes an old exception on a primary key value in the ")
   CALL text(10,3,
    "source, the mover also has the ability to automatically reset child rows linked to that primary key."
    )
   CALL text(11,3,
    "The reset is limited to child rows in any context pulled during the current event.")
   CALL text(13,3,"Child Exception Reset Configuration:")
   IF (mce_reset_ind=1)
    CALL text(13,41,"Enabled")
   ELSE
    CALL text(13,41,"Disabled")
   ENDIF
   CALL text(15,3,
    "Would you like the mover to automatically reset these child rows? [(Y)es / (N)o / e(X)it]")
   CALL accept(15,110,"P;CU","Y"
    WHERE curaccept IN ("Y", "N", "X"))
   IF (curaccept="Y")
    UPDATE  FROM dm_info
     SET info_number = 1
     WHERE info_domain="RDDS CONFIGURATION"
      AND info_name=concat("CHILDEXCPTN",trim(cnvtstring(srm_env_id)),trim(cnvtstring(dmda_mr->env_id
        )))
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ELSEIF (curqual=0)
     INSERT  FROM dm_info
      SET info_domain = "RDDS CONFIGURATION", info_name = concat("CHILDEXCPTN",trim(cnvtstring(
          srm_env_id)),trim(cnvtstring(dmda_mr->env_id))), info_number = 1
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
    SET stat = alterlist(auto_ver_request->qual,1)
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
    SET auto_ver_request->qual[1].rdds_event = "CHILD EXCEPTION SETTING CHANGE"
    SET auto_ver_request->qual[1].event_reason = ""
    SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
    SET auto_ver_request->qual[1].paired_environment_id = srm_env_id
    SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "Configuration Setting"
    SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = "Reset"
    SET auto_ver_request->qual[1].detail_qual[1].event_value = 1
    EXECUTE dm_rmc_auto_verify_setup
    COMMIT
   ELSEIF (curaccept="N")
    UPDATE  FROM dm_info
     SET info_number = 0
     WHERE info_domain="RDDS CONFIGURATION"
      AND info_name=concat("CHILDEXCPTN",trim(cnvtstring(srm_env_id)),trim(cnvtstring(dmda_mr->env_id
        )))
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ELSEIF (curqual=0)
     INSERT  FROM dm_info
      SET info_domain = "RDDS CONFIGURATION", info_name = concat("CHILDEXCPTN",trim(cnvtstring(
          srm_env_id)),trim(cnvtstring(dmda_mr->env_id))), info_number = 0
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
    SET stat = alterlist(auto_ver_request->qual,1)
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
    SET auto_ver_request->qual[1].rdds_event = "CHILD EXCEPTION SETTING CHANGE"
    SET auto_ver_request->qual[1].event_reason = ""
    SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
    SET auto_ver_request->qual[1].paired_environment_id = srm_env_id
    SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "Configuration Setting"
    SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = "Do Not Reset"
    SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
    EXECUTE dm_rmc_auto_verify_setup
    COMMIT
   ELSEIF (curaccept="X")
    RETURN
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE dmda_reset_chld_xcptns(null)
   DECLARE drcx_src_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE drcx_dcle_cnt = i4 WITH protect, noconstant(0)
   DECLARE drcx_mrg_link = vc WITH protect, noconstant("")
   DECLARE drcx_event_name = vc WITH protect, noconstant("")
   DECLARE drcx_src_env_name = vc WITH protect, noconstant("")
   DECLARE dcxr_chld_cnt = i4 WITH protect, noconstant(0)
   DECLARE drcx_reset_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcl_idx = i4 WITH protect, noconstant(0)
   FREE RECORD drcx_dcle
   RECORD drcx_dcle(
     1 qual[*]
       2 dcle_id = f8
   )
   SELECT INTO "NL:"
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND rdds_event="End Reference Data Sync"
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     drcx_src_env_id = drel.paired_environment_id, drcx_event_name = drel.event_reason
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ELSEIF (curqual=0)
    CALL clear(15,1)
    CALL text(20,3,
     "There is currently no open event.  This report cannot be run after the event has been closed.")
    CALL text(21,3,"Press ENTER to return to the previous menu.")
    CALL accept(21,50,"P;E"," ")
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_env_reltn der
    WHERE der.relationship_type="REFERENCE MERGE"
     AND der.parent_env_id=drcx_src_env_id
     AND (der.child_env_id=dmda_mr->env_id)
    DETAIL
     drcx_mrg_link = der.post_link_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    GO TO exit_program
   ENDIF
   IF (drcx_src_env_id > 0)
    SELECT INTO "NL:"
     FROM dm_environment de
     WHERE de.environment_id=drcx_src_env_id
     DETAIL
      drcx_src_env_name = de.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,7,132)
    CALL text(3,40,"***  Reset Child Exceptions ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(9,3,concat("WARNING: Child exception rows are about to be reset to REFCHG for event ",
      drcx_event_name))
    CALL text(10,3,concat("and source environment ",drcx_src_env_name,
      " Continue? [(Y)es / (N)o / e(X)it]"))
    CALL accept(10,85,"P;CU","Y"
     WHERE curaccept IN ("Y", "N", "X"))
    IF (curaccept="Y")
     IF (validate(dcxr_request->table_name,"qwe")="qwe"
      AND validate(dcxr_request->table_name,"asd")="asd")
      SET dm_err->eproc = "Gathering Exception Rows"
      SELECT DISTINCT INTO "NL:"
       d.dm_chg_log_exception_id
       FROM (parser(concat("DM_CHG_LOG_EXCEPTION",drcx_mrg_link)) d)
       WHERE (d.target_env_id=dmda_mr->env_id)
        AND d.log_type="DELETE"
       DETAIL
        drcx_dcle_cnt = (drcx_dcle_cnt+ 1)
        IF (mod(drcx_dcle_cnt,10)=1)
         stat = alterlist(drcx_dcle->qual,(drcx_dcle_cnt+ 9))
        ENDIF
        drcx_dcle->qual[drcx_dcle_cnt].dcle_id = d.dm_chg_log_exception_id
       FOOT REPORT
        stat = alterlist(drcx_dcle->qual,drcx_dcle_cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       GO TO exit_program
      ENDIF
      FOR (dcle_cnt = 1 TO size(drcx_dcle->qual,5))
        SET drfdx_request->db_link = drcx_mrg_link
        SET drfdx_request->exception_id = drcx_dcle->qual[dcle_cnt].dcle_id
        SET drfdx_request->target_env_id = dmda_mr->env_id
        EXECUTE dm_rmc_find_dcl_xcptn  WITH replace("REQUEST","DRFDX_REQUEST"), replace("REPLY",
         "DRFDX_REPLY")
        FOR (dcl_rows = 1 TO size(drfdx_reply->row,5))
          IF ((drfdx_reply->row[dcl_rows].current_context_ind=1))
           SET dcxr_chld_cnt = (dcxr_chld_cnt+ 1)
           IF (mod(dcxr_chld_cnt,10)=1)
            SET stat = alterlist(dcxr_request->qual,(dcxr_chld_cnt+ 9))
           ENDIF
           SET dcxr_request->qual[dcxr_chld_cnt].context_name = drfdx_reply->row[dcl_rows].
           context_name
           SET dcxr_request->qual[dcxr_chld_cnt].log_id = drfdx_reply->row[dcl_rows].log_id
           SET dcxr_request->qual[dcxr_chld_cnt].table_name = drfdx_reply->row[dcl_rows].table_name
           SET dcxr_request->qual[dcxr_chld_cnt].log_type = drfdx_reply->row[dcl_rows].log_type
           SET dcxr_request->qual[dcxr_chld_cnt].pk_where = drfdx_reply->row[dcl_rows].pk_where
           SET dcxr_request->qual[dcxr_chld_cnt].updt_dt_tm = format(drfdx_reply->row[dcl_rows].
            updt_dt_tm,";;Q")
           SET dcxr_request->qual[dcxr_chld_cnt].updt_task = drfdx_reply->row[dcl_rows].updt_task
           SET dcxr_request->qual[dcxr_chld_cnt].updt_id = drfdx_reply->row[dcl_rows].updt_id
          ENDIF
        ENDFOR
      ENDFOR
      SET stat = alterlist(dcxr_request->qual,dcxr_chld_cnt)
     ENDIF
     UPDATE  FROM (parser(concat("DM_CHG_LOG",drcx_mrg_link)) dcl)
      SET dcl.log_type = "REFCHG", dcl.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcl
       .dm_chg_log_exception_id = 0,
       dcl.chg_log_reason_txt = ""
      WHERE expand(dcl_idx,1,size(dcxr_request->qual,5),dcl.log_id,dcxr_request->qual[dcl_idx].log_id
       )
      WITH nocounter
     ;end update
     SET drcx_reset_cnt = curqual
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ELSE
      COMMIT
      CALL clear(15,1)
      CALL text(20,3,concat(trim(cnvtstring(drcx_reset_cnt)),
        " child exception rows have been reset to REFCHG in the DM_CHG_LOG."))
      CALL text(21,3,"Press ENTER to return to the previous menu.")
      CALL accept(21,50,"P;E"," ")
      RETURN(0)
     ENDIF
    ELSEIF (curaccept="N")
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE dm_chld_xcptn_rpt(null)
   FREE RECORD dcxr_dcle
   RECORD dcxr_dcle(
     1 qual[*]
       2 dcle_id = f8
   )
   DECLARE dcxr_src_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dcxr_merge_link = vc WITH protect, noconstant("")
   DECLARE dcxr_dcle_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcxr_chld_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcxr_line = vc WITH protect, constant(fillstring(273,"-"))
   DECLARE pkw_sze = i4 WITH protect, noconstant(0)
   DECLARE pkw_strt = i4 WITH protect, noconstant(0)
   DECLARE dcxr_pkw_print = vc WITH protect, noconstant("")
   DECLARE dcxr_event_name = vc WITH protect, noconstant("")
   SELECT INTO "NL:"
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND rdds_event="End Reference Data Sync"
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     dcxr_src_env_id = drel.paired_environment_id, dcxr_event_name = drel.event_reason
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN
   ELSEIF (curqual=0)
    SET dm_err->emsg =
    "There is currently no open event.  This report cannot be run after the event has been closed."
    SET message = nowindow
    CALL clear(15,1)
    CALL text(20,3,
     "There is currently no open event.  This report cannot be run after the event has been closed.")
    CALL text(21,3,"Press ENTER to return to the previous menu.")
    CALL accept(21,50,"P;E"," ")
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM dm_env_reltn dr
    WHERE dr.relationship_type="REFERENCE MERGE"
     AND dr.parent_env_id=dcxr_src_env_id
     AND (dr.child_env_id=dmda_mr->env_id)
    DETAIL
     dcxr_merge_link = trim(dr.post_link_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM (parser(concat("dm_chg_log_exception",dcxr_merge_link)) d)
    WHERE (d.target_env_id=dmda_mr->env_id)
     AND d.log_type="DELETE"
    DETAIL
     dcxr_dcle_cnt = (dcxr_dcle_cnt+ 1)
     IF (mod(dcxr_dcle_cnt,10)=1)
      stat = alterlist(dcxr_dcle->qual,(dcxr_dcle_cnt+ 9))
     ENDIF
     dcxr_dcle->qual[dcxr_dcle_cnt].dcle_id = d.dm_chg_log_exception_id
    FOOT REPORT
     stat = alterlist(dcxr_dcle->qual,dcxr_dcle_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN
   ENDIF
   FOR (dcle_cnt = 1 TO size(dcxr_dcle->qual,5))
     SET drfdx_request->db_link = dcxr_merge_link
     SET drfdx_request->exception_id = dcxr_dcle->qual[dcle_cnt].dcle_id
     SET drfdx_request->target_env_id = dmda_mr->env_id
     EXECUTE dm_rmc_find_dcl_xcptn  WITH replace("REQUEST","DRFDX_REQUEST"), replace("REPLY",
      "DRFDX_REPLY")
     FOR (dcl_rows = 1 TO size(drfdx_reply->row,5))
       IF ((drfdx_reply->row[dcl_rows].current_context_ind=1))
        SET dcxr_chld_cnt = (dcxr_chld_cnt+ 1)
        IF (mod(dcxr_chld_cnt,10)=1)
         SET stat = alterlist(dcxr_request->qual,(dcxr_chld_cnt+ 9))
        ENDIF
        SET dcxr_request->qual[dcxr_chld_cnt].context_name = drfdx_reply->row[dcl_rows].context_name
        SET dcxr_request->qual[dcxr_chld_cnt].log_id = drfdx_reply->row[dcl_rows].log_id
        SET dcxr_request->qual[dcxr_chld_cnt].table_name = drfdx_reply->row[dcl_rows].table_name
        SET dcxr_request->qual[dcxr_chld_cnt].log_type = drfdx_reply->row[dcl_rows].log_type
        SET dcxr_request->qual[dcxr_chld_cnt].pk_where = drfdx_reply->row[dcl_rows].pk_where
        SET dcxr_request->qual[dcxr_chld_cnt].updt_dt_tm = format(drfdx_reply->row[dcl_rows].
         updt_dt_tm,";;Q")
        SET dcxr_request->qual[dcxr_chld_cnt].updt_task = drfdx_reply->row[dcl_rows].updt_task
        SET dcxr_request->qual[dcxr_chld_cnt].updt_id = drfdx_reply->row[dcl_rows].updt_id
        SET dcxr_request->qual[dcxr_chld_cnt].exception_id = drfdx_request->exception_id
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(dcxr_request->qual,dcxr_chld_cnt)
   IF (dcxr_chld_cnt=0)
    CALL clear(7,1)
    CALL text(7,3,concat("There are currently no existing child exceptions for the ",dcxr_event_name,
      " event."))
    CALL text(8,3,"Press ENTER to return to the previous menu.")
    CALL accept(8,50,"P;E"," ")
    RETURN
   ELSE
    SELECT INTO mine
     FROM (dummyt d  WITH seq = size(dcxr_request->qual,5))
     HEAD REPORT
      row + 1, col 1, "LOG_ID",
      col 20, "LOG_TYPE", col 30,
      "TABLE_NAME", col 65, "PK_WHERE",
      col 155, "UPDT_ID", col 175,
      "UPDT_DT_TM", col 195, "UPDT_TASK",
      col 215, "CONTEXT_NAME", col 240,
      "DM_CHG_LOG_EXCEPTION_ID", row + 1, col 1,
      dcxr_line, row + 1
     DETAIL
      col 1, dcxr_request->qual[d.seq].log_id, col 20,
      dcxr_request->qual[d.seq].log_type, col 30, dcxr_request->qual[d.seq].table_name,
      col 155, dcxr_request->qual[d.seq].updt_id, col 175,
      dcxr_request->qual[d.seq].updt_dt_tm, col 195, dcxr_request->qual[d.seq].updt_task,
      col 215, dcxr_request->qual[d.seq].context_name, col 240,
      dcxr_request->qual[d.seq].exception_id
      IF (size(dcxr_request->qual[d.seq].pk_where,1) <= 90)
       col 65, dcxr_request->qual[d.seq].pk_where
      ELSE
       pkw_sze = size(dcxr_request->qual[d.seq].pk_where,1), pkw_strt = 1
       WHILE (((pkw_strt+ 90) < pkw_sze))
         dcxr_pkw_print = substring(pkw_strt,90,dcxr_request->qual[d.seq].pk_where)
         IF (pkw_strt=1)
          col 65, dcxr_pkw_print
         ELSE
          row + 1, col 65, dcxr_pkw_print
         ENDIF
         pkw_strt = (pkw_strt+ 90)
       ENDWHILE
       dcxr_pkw_print = substring(pkw_strt,((pkw_sze - pkw_strt)+ 1),dcxr_request->qual[d.seq].
        pk_where), row + 1, col 65,
       dcxr_pkw_print
      ENDIF
      row + 1
     WITH nocounter, maxcol = 275
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_close_event_chk(i_tgt_name,i_tgt_id,i_open_evt_id)
   DECLARE cec_idx = i4
   DECLARE cec_pos = i4
   DECLARE cec_for_loop = i4
   DECLARE cec_valid_uncut_ind = i2
   DECLARE cec_env_name = vc
   DECLARE cec_msg_len = i4
   DECLARE cec_tmp_msg = vc
   DECLARE cec_event_name = vc
   DECLARE cec_event_src = f8
   DECLARE cec_event_src_name = vc
   SET drcec_request->cur_env_id = i_tgt_id
   EXECUTE dm_rmc_close_event_chk
   IF ((drcec_reply->ret_val=- (1)))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET help = off
    SET validate = off
    RETURN(0)
   ELSEIF ((drcec_reply->ret_val=0))
    SET dm_err->emsg = drcec_reply->ret_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SELECT INTO "nl:"
     FROM dm_rdds_event_log drel
     WHERE drel.dm_rdds_event_log_id=i_open_evt_id
      AND drel.cur_environment_id=i_tgt_id
     DETAIL
      cec_event_name = drel.event_reason, cec_event_src = drel.paired_environment_id
     WITH nocounter
    ;end select
    CALL clear(1,1)
    CALL text(3,40,"***  Close An RDDS Event ***")
    CALL box(1,1,7,132)
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,i_tgt_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(i_tgt_id))
    CALL text(15,3,concat("Event: ",cec_event_name))
    CALL text(16,3,concat("For source environment: ",trim(cec_event_src_name)," - ",trim(cnvtstring(
        cec_event_src))," is currently open."))
    CALL text(17,3,drcec_reply->ret_msg)
    CALL text(18,20,"Press ENTER to return to the previous menu.")
    CALL accept(18,64,"P;E"," ")
    SET help = off
    SET validate = off
    RETURN(0)
   ENDIF
   RETURN(drec_reply->ret_val)
 END ;Subroutine
 SUBROUTINE dmda_dual_build_config(null)
   DECLARE ddbc_back = i2 WITH protect, noconstant(0)
   DECLARE ddbc_trg_ind = i2 WITH protect, noconstant(0)
   DECLARE ddbc_info_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE ddbc_rtable_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE ddbc_ptam_ind = vc WITH protect, noconstant("")
   DECLARE ddbc_file_name = vc WITH protect, noconstant("")
   DECLARE ddbc_cutover_type = vc WITH protect, noconstant("")
   DECLARE ddbc_ret = i4 WITH protect, noconstant(0)
   DECLARE ddbc_src_env_id = f8 WITH protect, noconstant(0.0)
   CALL clear(1,1)
   WHILE (ddbc_back=0)
     SET message = window
     SET accept = nopatcheck
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,43,"***  DUAL BUILD REPORTS AND CONFIGURATION  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,"Please choose from the following options:")
     CALL text(9,3,"1 View Database Integrity Concerns for Cutover")
     CALL text(10,3,"2 Acknowledge Database Integrity Concerns for Cutover")
     CALL text(11,3,"3 View Uptime RDDS Errors (ORA-2020x)")
     CALL text(12,3,"4 Dual Build Trigger Configuration")
     CALL text(18,3,"0 Exit")
     CALL accept(7,50,"99",0
      WHERE curaccept IN (1, 2, 3, 4, 0))
     CASE (curaccept)
      OF 1:
       SET ddbc_ret = dmda_db_report(1)
       IF ((ddbc_ret=- (1)))
        SET ddbc_back = 0
       ENDIF
      OF 2:
       CALL clear(1,1)
       IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
        IF ((xxcclseclogin->loggedin != 1))
         CALL parser("cclseclogin go")
         IF (check_error(dm_err->eproc)=1)
          SET dm_err->emsg = ""
          SET dm_err->err_ind = 0
         ENDIF
         IF ((xxcclseclogin->loggedin != 1))
          SET message = nowindow
          SET dm_err->eproc = "Dual Build Reports and Configuration"
          SET dm_err->emsg = "User not logged in to cclseclogin"
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_program
         ENDIF
        ENDIF
       ENDIF
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,5,132)
       CALL text(3,43,"***  DUAL BUILD REPORTS AND CONFIGURATION  ***")
       CALL text(4,75,"ENVIRONMENT ID:")
       CALL text(4,20,"ENVIRONMENT NAME:")
       CALL text(4,95,cnvtstring(dmda_mr->env_id))
       CALL text(4,40,dmda_mr->env_name)
       SET ddbc_src_env_id = dmda_get_oe_src_id(dmda_mr->env_id)
       IF ((ddbc_src_env_id=- (2)))
        CALL text(7,3,
         "There is currently no open event, database integrity concerns cannot be acknowledged at this time."
         )
        CALL text(9,3,"Press ENTER to return to the previous menu.")
        CALL accept(9,64,"P;E"," ")
        SET ddbc_back = 0
       ELSEIF (ddbc_src_env_id > 0)
        SELECT INTO "NL:"
         FROM dm_env_reltn der
         WHERE der.relationship_type="PENDING TARGET AS MASTER"
          AND der.parent_env_id=ddbc_src_env_id
          AND (der.child_env_id=dmda_mr->env_id)
         DETAIL
          ddbc_ptam_ind = concat("(",dmda_mr->env_name,") IS MASTER")
         WITH nocounter
        ;end select
        IF (curqual=0)
         SET ddbc_ptam_ind = "NO MASTER DOMAIN IS SET"
        ELSEIF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         RETURN(- (1))
        ENDIF
        SET ddbc_trg_ind = drcr_get_dual_build_config(ddbc_src_env_id,dmda_mr->env_id)
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         RETURN(- (1))
        ENDIF
        SELECT INTO "nl:"
         y = max(d.updt_dt_tm)
         FROM dm_refchg_rtable_reset d
         WHERE d.reset_status IN ("UNPROCESSED", "SEVERE")
         DETAIL
          ddbc_rtable_dt_tm = y
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         RETURN(- (1))
        ENDIF
        SELECT INTO "nl:"
         FROM dm_info di
         WHERE di.info_domain="RDDS REPORT VIEWED"
          AND di.info_name="VIEW DUAL BUILD PROBLEMS"
         DETAIL
          ddbc_info_dt_tm = di.updt_dt_tm, ddbc_file_name = di.info_char
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 1
         RETURN(- (1))
        ENDIF
        IF (ddbc_trg_ind=0
         AND findstring("IS MASTER",ddbc_ptam_ind)=0)
         CALL clear(7,1)
         CALL text(9,3,concat(
           "The RDDS triggers that monitor dual build are currently not blocking changes in ",dmda_mr
           ->env_name,"."))
         CALL text(10,3,concat("If additional reference data changes occur in ",dmda_mr->env_name,
           ", this report may need to be viewed and acknowledged again."))
         CALL text(12,3,
          "Would you like to modify dual build trigger configuration now? [(Y)es / (N)o ]")
         CALL accept(12,93,"P;CU","Y"
          WHERE curaccept IN ("Y", "N"))
        ELSEIF ((ddbc_trg_ind=- (1)))
         CALL clear(7,1)
         CALL text(9,3,concat(
           "The RDDS triggers that monitor dual build are currently not configured in ",dmda_mr->
           env_name,"."))
         CALL text(10,3,"The report cannot be viewed until configuration is complete.")
         CALL text(12,3,
          "Would you like to modify dual build trigger configuration now? [(Y)es / (N)o ]")
         CALL accept(12,93,"P;CU","Y"
          WHERE curaccept IN ("Y", "N"))
         IF (curaccept="N")
          RETURN(- (1))
         ENDIF
        ELSE
         SET curaccept = "N"
        ENDIF
        CASE (curaccept)
         OF "Y":
          SET ddbc_ret = dmda_db_trig_config(ddbc_src_env_id)
          IF ((ddbc_ret=- (1)))
           RETURN(- (1))
          ENDIF
          IF (ddbc_rtable_dt_tm > ddbc_info_dt_tm)
           CALL clear(7,1)
           CALL text(9,3,
            "WARNING!: New dual build changes have been detected that have not been viewed.")
           CALL text(11,3,
            "Only dual build changes that were viewed in the Database Integrity Concerns Report on ",
            format(ddbc_info_dt_tm,";;Q"))
           CALL text(12,3,
            "will be acknowledged at this time.  A new report will need to be generated in order to",
            " acknowledge all ")
           CALL text(13,3,"dual build changes.")
           CALL text(24,3,"Would you like to generate a new report now? [(Y)es / (N)o / e(X)it]")
           CALL accept(24,74,"P;CU","Y"
            WHERE curaccept IN ("Y", "N", "X"))
          ELSE
           SET curaccept = "N"
          ENDIF
          CASE (curaccept)
           OF "Y":
            SET ddbc_ret = dmda_db_report(1)
            IF ((ddbc_ret=- (1)))
             RETURN(- (1))
            ENDIF
           OF "N":
            SET ddbc_ret = dmda_db_trig_ack(ddbc_info_dt_tm,ddbc_file_name)
            IF ((ddbc_ret=- (1)))
             SET ddbc_back = 0
            ELSE
             SET ddbc_back = 1
            ENDIF
           OF "X":
            RETURN(- (1))
          ENDCASE
         OF "N":
          IF (ddbc_rtable_dt_tm > ddbc_info_dt_tm)
           CALL clear(7,1)
           CALL text(9,3,
            "WARNING!: New dual build changes have been detected that have not been viewed.")
           CALL text(11,3,concat(
             "Only dual build changes that were viewed in the Database Integrity Concerns Report on ",
             format(ddbc_info_dt_tm,";;Q")))
           CALL text(12,3,
            "will be acknowledged at this time.  A new report will need to be generated in order to acknowledge"
            )
           CALL text(13,3,"all dual build changes.")
           CALL text(24,3,"Would you like to generate a new report now? [(Y)es / (N)o / e(X)it]")
           CALL accept(24,74,"P;CU","Y"
            WHERE curaccept IN ("Y", "N", "X"))
          ELSE
           SET curaccept = "N"
          ENDIF
          CASE (curaccept)
           OF "Y":
            SET ddbc_ret = dmda_db_report(1)
            IF ((ddbc_ret=- (1)))
             RETURN(- (1))
            ENDIF
            SET ddbc_back = 1
           OF "N":
            SET ddbc_ret = dmda_db_trig_ack(ddbc_info_dt_tm,ddbc_file_name)
            IF (ddbc_ret >= 0)
             SET ddbc_back = 0
            ELSEIF ((ddbc_ret=- (1)))
             RETURN(- (1))
            ENDIF
           OF "X":
            RETURN(- (1))
          ENDCASE
        ENDCASE
       ELSE
        RETURN(- (1))
       ENDIF
      OF 3:
       SET ddbc_ret = dmda_db_report(2)
       IF ((ddbc_ret=- (1)))
        SET ddbc_back = 0
       ENDIF
      OF 4:
       CALL clear(1,1)
       IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
        IF ((xxcclseclogin->loggedin != 1))
         CALL parser("cclseclogin go")
         IF (check_error(dm_err->eproc)=1)
          SET dm_err->emsg = ""
          SET dm_err->err_ind = 0
         ENDIF
         IF ((xxcclseclogin->loggedin != 1))
          SET message = nowindow
          SET dm_err->eproc = "Dual Build Reports and Configuration"
          SET dm_err->emsg = "User not logged in to cclseclogin"
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_program
         ENDIF
        ENDIF
       ENDIF
       CALL get_src_env_id("Dual Build Reports and Configuration",1)
       IF (srm_env_id=0)
        SET ddbc_back = 0
       ELSE
        SET ddbc_ret = dmda_db_trig_config(srm_env_id)
        IF ((ddbc_ret=- (1)))
         RETURN(- (1))
        ENDIF
       ENDIF
      OF 0:
       RETURN(0)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_db_trig_config(ddtc_src_env_id)
   DECLARE ddtc_trg_ind = vc WITH protect, noconstant("")
   DECLARE ddtc_ack_ind = vc WITH protect, noconstant("")
   DECLARE ddtc_detail2_txt = vc WITH protect, noconstant("")
   DECLARE ddtc_info_num = i2 WITH protect, noconstant(0)
   DECLARE ddtc_continue = i2 WITH protect, noconstant(0)
   DECLARE ddtc_ptam_ind = vc WITH protect, noconstant("")
   DECLARE ddtc_cutover_type = vc WITH protect, noconstant("")
   DECLARE ddtc_temp_return = f8 WITH protect, noconstant(0.0)
   SET ddtc_temp_return = drcr_get_dual_build_config(ddtc_src_env_id,dmda_mr->env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(- (1))
   ENDIF
   IF (ddtc_temp_return=1)
    SET ddtc_trg_ind = "BLOCKING"
    SET ddtc_ack_ind = "NO"
   ELSEIF (ddtc_temp_return=0)
    SET ddtc_trg_ind = "NOT BLOCKING"
    SET ddtc_ack_ind = "YES"
   ELSE
    SET ddtc_trg_ind = "NOT CONFIGURED YET FOR THIS RELATIONSHIP"
    SET ddtc_ack_ind = "N/A"
   ENDIF
   SET ddtc_temp_return = drcr_get_ptam_config(ddtc_src_env_id,dmda_mr->env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(- (1))
   ENDIF
   IF (ddtc_temp_return=1)
    SET ddtc_ptam_ind = concat("(",dmda_mr->env_name,") IS MASTER")
   ELSEIF (ddtc_temp_return=0)
    SET ddtc_ptam_ind = "NO MASTER DOMAIN IS SET"
   ELSE
    SET ddtc_ptam_ind = "NOT CONFIGURED YET FOR THIS RELATIONSHIP"
   ENDIF
   SET ddtc_temp_return = drcr_get_cutover_config(ddtc_src_env_id,dmda_mr->env_id)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(- (1))
   ENDIF
   IF (ddtc_temp_return=1)
    SET ddtc_cutover_type = "PLANNED CUTOVER"
   ELSEIF (ddtc_temp_return=0)
    SET ddtc_cutover_type = "AUTO CUTOVER"
   ELSE
    SET ddtc_cutover_type = "NOT CONFIGURED YET FOR THIS RELATIONSHIP"
   ENDIF
   WHILE (ddtc_continue=0)
     SET accept = nopatcheck
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,5,132)
     CALL text(3,43,"***  DUAL BUILD REPORTS AND CONFIGURATION  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(8,3,concat("Current Configuration for source ",srm_env_name,":"))
     CALL text(9,5,"Dual Build Triggers")
     CALL text(9,48,concat("-  ",ddtc_trg_ind))
     CALL text(10,5,"PTAM SETTING")
     CALL text(10,48,concat("-  ",ddtc_ptam_ind))
     CALL text(11,5,"Dual Build/Cutover Manual Acknowledgement")
     CALL text(11,48,concat("-  ",ddtc_ack_ind))
     CALL text(12,5,"Cutover Type")
     CALL text(12,48,concat("-  ",ddtc_cutover_type))
     IF (findstring("IS MASTER",ddtc_ptam_ind) > 0)
      CALL text(18,3,concat("WARNING!: The (",dmda_mr->env_name,
        ") target domain cannot be configured to block dual build changes while the domain is "))
      CALL text(19,3,"configured as PTAM.")
      CALL text(21,20,"Press ENTER to return to the previous menu.")
      CALL accept(21,64,"P;E"," ")
      RETURN(- (2))
     ELSE
      CALL text(24,3,
       "Should this relationship be configured for RDDS triggers to block dual build? [(Y)es / (N)o / e(X)it]"
       )
      CALL accept(24,106,"P;CU","Y"
       WHERE curaccept IN ("Y", "N", "X"))
      CASE (curaccept)
       OF "Y":
        SET ddtc_trg_ind = "BLOCKING"
        SET ddtc_detail2_txt = "Block Dual Build"
        SET ddtc_info_num = 1
        CALL clear(14,1)
        CALL text(14,3,concat("New Configuration for source ",srm_env_name,":"))
        CALL text(15,5,"Dual Build Triggers")
        CALL text(15,48,concat("-  ",ddtc_trg_ind))
        CALL text(16,5,"PTAM SETTING")
        CALL text(16,48,concat("-  ",ddtc_ptam_ind))
        CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
        CALL text(17,48,concat("-  ",ddtc_ack_ind))
        CALL text(18,5,"Cutover Type")
        CALL text(18,48,concat("-  ",ddtc_cutover_type))
        CALL text(21,3,"Confirm configuration changes? [(Y)es / (N)o ]")
        CALL accept(21,51,"P;CU","N"
         WHERE curaccept IN ("Y", "N"))
        CASE (curaccept)
         OF "Y":
          SET message = nowindow
          SET ddtc_continue = 1
          UPDATE  FROM dm_env_reltn der
           SET der.relationship_type = "BLOCK DUAL BUILD"
           WHERE der.parent_env_id=srm_env_id
            AND (der.child_env_id=dmda_mr->env_id)
            AND der.relationship_type IN ("ALLOW DUAL BUILD", "BLOCK DUAL BUILD")
           WITH nocounter
          ;end update
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 1
           RETURN(- (1))
          ELSEIF (curqual=0)
           SET stat = alterlist(dera_request->env_list,1)
           SET dera_request->child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].parent_env_id = srm_env_id
           SET dera_request->env_list[1].child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].relationship_type = "BLOCK DUAL BUILD"
           EXECUTE dm_add_env_reltn
           SET stat = alterlist(dera_request->env_list,0)
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            SET dm_err->err_ind = 1
            RETURN(- (1))
           ELSE
            COMMIT
           ENDIF
          ELSE
           COMMIT
          ENDIF
         OF "N":
          SET ddtc_continue = 0
        ENDCASE
       OF "N":
        SET ddtc_trg_ind = "NOT BLOCKING"
        SET ddtc_detail2_txt = "Allow Dual Build"
        SET ddtc_info_num = 0
        CALL clear(14,1)
        CALL text(14,3,concat("New Configuration for source ",srm_env_name,":"))
        CALL text(15,5,"Dual Build Triggers")
        CALL text(15,48,concat("-  ",ddtc_trg_ind))
        CALL text(16,5,"PTAM SETTING")
        CALL text(16,48,concat("-  ",ddtc_ptam_ind))
        CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
        CALL text(17,48,concat("-  ",ddtc_ack_ind))
        CALL text(18,5,"Cutover Type")
        CALL text(18,48,concat("-  ",ddtc_cutover_type))
        CALL text(21,3,"Confirm configuration changes? [(Y)es / (N)o ]")
        CALL accept(21,51,"P;CU","N"
         WHERE curaccept IN ("Y", "N"))
        CASE (curaccept)
         OF "Y":
          SET message = nowindow
          SET ddtc_continue = 1
          UPDATE  FROM dm_env_reltn der
           SET der.relationship_type = "ALLOW DUAL BUILD"
           WHERE der.parent_env_id=srm_env_id
            AND (der.child_env_id=dmda_mr->env_id)
            AND der.relationship_type IN ("ALLOW DUAL BUILD", "BLOCK DUAL BUILD")
           WITH nocounter
          ;end update
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 1
           RETURN(- (1))
          ELSEIF (curqual=0)
           SET stat = alterlist(dera_request->env_list,1)
           SET dera_request->child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].parent_env_id = srm_env_id
           SET dera_request->env_list[1].child_env_id = dmda_mr->env_id
           SET dera_request->env_list[1].relationship_type = "ALLOW DUAL BUILD"
           EXECUTE dm_add_env_reltn
           SET stat = alterlist(dera_request->env_list,0)
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            SET dm_err->err_ind = 1
            RETURN(- (1))
           ELSE
            COMMIT
           ENDIF
          ELSE
           COMMIT
          ENDIF
         OF "N":
          SET ddtc_continue = 0
        ENDCASE
       OF "X":
        RETURN(- (1))
      ENDCASE
     ENDIF
   ENDWHILE
   IF (srm_env_id=dmda_get_oe_src_id(dmda_mr->env_id))
    EXECUTE dm_refchg_dual_build_reject ddtc_info_num
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(- (1))
    ENDIF
    SET stat = alterlist(auto_ver_request->qual,1)
    SET auto_ver_request->qual[1].rdds_event = "Dual Build Trigger Change"
    SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
    SET auto_ver_request->qual[1].paired_environment_id = srm_env_id
    SET auto_ver_request->qual[1].event_reason = "Menu Trigger Change"
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,2)
    SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "DM_ENV_RELTN Change"
    SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = ddtc_detail2_txt
    SET auto_ver_request->qual[1].detail_qual[1].event_value = ddtc_info_num
    SET auto_ver_request->qual[1].detail_qual[2].event_detail1_txt =
    "Compile DM_REFCHG_DUAL_BUILD_REJECT"
    SET auto_ver_request->qual[1].detail_qual[2].event_value = ddtc_info_num
    SET dm_err->eproc = "Executing DM_RMC_AUTO_VERIFY_SETUP."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    EXECUTE dm_rmc_auto_verify_setup
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(- (1))
    ENDIF
   ELSE
    SET stat = alterlist(auto_ver_request->qual,1)
    SET auto_ver_request->qual[1].rdds_event = "Dual Build Trigger Change"
    SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
    SET auto_ver_request->qual[1].paired_environment_id = srm_env_id
    SET auto_ver_request->qual[1].event_reason = "Menu Trigger Change"
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
    SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "DM_ENV_RELTN Change"
    SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = ddtc_detail2_txt
    SET auto_ver_request->qual[1].detail_qual[1].event_value = ddtc_info_num
    SET dm_err->eproc = "Executing DM_RMC_AUTO_VERIFY_SETUP."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    EXECUTE dm_rmc_auto_verify_setup
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(- (1))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_db_trig_ack(ddta_info_dt_tm,ddta_file_name)
   DECLARE ddta_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE ddta_temp_date = vc WITH protect, noconstant("")
   DECLARE ddta_done_flg = i2 WITH protect, noconstant(0)
   DECLARE ddta_tot_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dradb_request
   RECORD dradb_request(
     1 src_id = f8
     1 tgt_id = f8
     1 event_reason = vc
     1 ack_dt_tm = dq8
   )
   FREE RECORD dradb_reply
   RECORD dradb_reply(
     1 tot_cnt = i4
   )
   SET accept = nopatcheck
   SET ddta_temp_date = format(ddta_info_dt_tm,";;Q")
   CALL get_src_env_id("Acknowledge Dual Build",1)
   IF (srm_env_id=0.0)
    RETURN(- (1))
   ENDIF
   CALL clear(7,1)
   CALL text(9,3,
    "By acknowledging the dual build issues, you are accepting risk of all database integrity concerns that"
    )
   CALL text(10,3,concat("affect functionality in ",dmda_mr->env_name,
     " after cutover that were not resolved."))
   CALL text(12,3,concat("All Database Integrity Concerns that were viewed in ",ddta_file_name," on ",
     ddta_temp_date))
   CALL text(13,3,concat("will be acknowledged by ",curuser))
   CALL text(24,3,"Continue? [(Y)es / (N)o / E(x)it ]")
   CALL accept(24,38,"P;CU","Y"
    WHERE curaccept IN ("Y", "N", "X"))
   CASE (curaccept)
    OF "Y":
     SET dradb_request->src_id = srm_env_id
     SET dradb_request->tgt_id = dmda_mr->env_id
     SET dradb_request->event_reason = "Menu Acknowledge"
     SET dradb_request->ack_dt_tm = ddta_info_dt_tm
     EXECUTE dm_rmc_ack_dual_build
     IF ((dm_err->err_ind=1))
      IF (check_error_gui(dm_err->eproc,"Acknowledge Dual Build",dmda_mr->env_name,dmda_mr->env_id)
       != 0)
       ROLLBACK
       RETURN(- (1))
      ENDIF
     ENDIF
     SET ddta_tot_cnt = dradb_reply->tot_cnt
     CALL clear(7,1)
     CALL text(9,3,concat(trim(cnvtstring(ddta_tot_cnt)),
       " Database Integrity Concerns that were viewed in ",ddta_file_name," on ",ddta_temp_date))
     CALL text(10,3,concat("were acknowledged by ",curuser))
     CALL text(21,20,"Press ENTER to return to the previous menu.")
     CALL accept(21,64,"P;E"," ")
     RETURN(1)
    OF "N":
     RETURN(0)
    OF "X":
     RETURN(- (1))
   ENDCASE
 END ;Subroutine
 SUBROUTINE dmda_get_oe_src_id(dgos_env_id)
   DECLARE dgos_src_env_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND drel.cur_environment_id=dgos_env_id
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log d
     WHERE d.cur_environment_id=dgos_env_id
      AND d.rdds_event="End Reference Data Sync"
      AND d.rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     dgos_src_env_id = drel.paired_environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(- (1))
   ELSEIF (curqual=0)
    RETURN(- (2))
   ENDIF
   RETURN(dgos_src_env_id)
 END ;Subroutine
 SUBROUTINE dmda_db_report(ddr_rpt_type)
   DECLARE ddr_src_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE ddr_file_name = vc WITH protect, noconstant("")
   DECLARE ddr_tmp_err_ind = i2 WITH protect, noconstant(0)
   DECLARE ddr_tmp_err_msg = vc WITH protect, noconstant("")
   SET ddr_src_env_id = dmda_get_oe_src_id(dmda_mr->env_id)
   IF (ddr_src_env_id > 0)
    SET ddr_file_name = dmda_get_file_name(dmda_mr->env_id,dmda_mr->env_name,
     "DUAL BUILD AUDIT REPORT","dual_build_audit",".xml",
     "report")
    IF (ddr_file_name != "-1")
     SET message = nowindow
     EXECUTE dm_rmc_dual_build_rpt ddr_rpt_type, ddr_src_env_id, ddr_file_name WITH replace(
      "DDBR_STATUS","DDBC_REPLY")
     IF ((dm_err->err_ind=1))
      SET ddr_tmp_err_ind = dm_err->err_ind
      SET ddr_tmp_err_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
     CALL remove_lock("RDDS FILENAME LOCK",ddr_file_name,currdbhandle,drl_reply)
     IF (ddr_tmp_err_ind=1)
      SET dm_err->err_ind = ddr_tmp_err_ind
      SET dm_err->emsg = ddr_tmp_err_msg
     ENDIF
     IF ((((ddbc_reply->status_data.status="S")) OR ((ddbc_reply->status_data.status="Z"))) )
      UPDATE  FROM dm_info
       SET updt_dt_tm = cnvtdatetime(curdate,curtime3), info_char = ddr_file_name
       WHERE info_domain="RDDS REPORT VIEWED"
        AND info_name="VIEW DUAL BUILD PROBLEMS"
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       RETURN(- (1))
      ELSEIF (curqual=0)
       INSERT  FROM dm_info
        SET info_domain = "RDDS REPORT VIEWED", info_name = "VIEW DUAL BUILD PROBLEMS", updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         info_char = ddr_file_name
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm_err->err_ind = 1
        RETURN(- (1))
       ELSE
        COMMIT
       ENDIF
      ELSE
       COMMIT
      ENDIF
      IF ((ddbc_reply->status_data.status="Z")
       AND ddr_rpt_type=1)
       UPDATE  FROM dm_refchg_rtable_reset
        SET reset_status = "PROCESSED"
        WHERE reset_status IN ("UNPROCESSED", "SEVERE")
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm_err->err_ind = 1
        RETURN(- (1))
       ELSE
        COMMIT
       ENDIF
      ENDIF
      IF ((ddbc_reply->status_data.status="Z"))
       SET accept = nopatcheck
       SET message = window
       SET width = 132
       CALL clear(1,1)
       CALL box(1,1,5,132)
       CALL text(3,43,"***  DUAL BUILD REPORTS AND CONFIGURATION  ***")
       CALL text(4,75,"ENVIRONMENT ID:")
       CALL text(4,20,"ENVIRONMENT NAME:")
       CALL text(4,95,cnvtstring(dmda_mr->env_id))
       CALL text(4,40,dmda_mr->env_name)
       CALL text(7,3,"There are currently no database integrity concerns to report.")
       CALL text(9,3,"Press Enter to return to previous menu.")
       CALL accept(9,43,"P;E"," ")
       RETURN(0)
      ENDIF
      GO TO exit_program
     ELSE
      GO TO exit_program
     ENDIF
    ELSE
     RETURN(- (1))
    ENDIF
   ELSEIF ((ddr_src_env_id=- (2)))
    SET accept = nopatcheck
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,5,132)
    CALL text(3,43,"***  DUAL BUILD REPORTS AND CONFIGURATION  ***")
    CALL text(4,75,"ENVIRONMENT ID:")
    CALL text(4,20,"ENVIRONMENT NAME:")
    CALL text(4,95,cnvtstring(dmda_mr->env_id))
    CALL text(4,40,dmda_mr->env_name)
    CALL text(7,3,
     "There is currently no open event, database integrity concerns cannot be reported at this time."
     )
    CALL text(9,3,"Press ENTER to return to the previous menu.")
    CALL accept(9,50,"P;E"," ")
    RETURN(0)
   ELSE
    RETURN(- (1))
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_ptam_dual_bld_trg_setting(dpds_tgt_env_name,dpds_target_env_id,dpds_cutover_type,
  dpds_ptam_answer)
   DECLARE dpds_dual_bld_flag = i2 WITH protect, noconstant(0)
   DECLARE dpds_dual_bld_answer = c1 WITH protect, noconstant("")
   DECLARE dpds_continue = i2 WITH protect, noconstant(0)
   IF (dpds_ptam_answer="Y")
    UPDATE  FROM dm_env_reltn der
     SET der.relationship_type = "ALLOW DUAL BUILD"
     WHERE (der.parent_env_id=dmda_mr->env_id)
      AND der.child_env_id=dpds_target_env_id
      AND der.relationship_type IN ("ALLOW DUAL BUILD", "BLOCK DUAL BUILD")
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET stat = initrec(dera_request)
     SET stat = alterlist(dera_request->env_list,1)
     SET dera_request->child_env_id = dpds_target_env_id
     SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
     SET dera_request->env_list[1].child_env_id = dpds_target_env_id
     SET dera_request->env_list[1].relationship_type = "ALLOW DUAL BUILD"
     EXECUTE dm_add_env_reltn
     IF ((dera_reply->err_num > 0))
      CALL text(21,3,dera_reply->err_msg)
      CALL text(22,3,"Insertion failed! Action aborted..")
      CALL pause(2)
      SET dm_err->eproc = "Inserting 'ALLOW DUAL BUILD' to DM_ENV_RELTN"
      CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
    ENDIF
    SET dm_err->eproc = "Inserting 'DUAL BUILD TRIGGER CHANGE' admin event"
    SET stat = alterlist(auto_ver_request->qual,1)
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
    SET auto_ver_request->qual[1].rdds_event = "DUAL BUILD TRIGGER CHANGE"
    SET auto_ver_request->qual[1].event_reason = "New Child Env - Forced Setting"
    SET auto_ver_request->qual[1].paired_environment_id = dmda_mr->env_id
    SET auto_ver_request->qual[1].cur_environment_id = dpds_target_env_id
    SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "DM_ENV_RELTN Change"
    SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = "ALLOW DUAL BUILD"
    SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
    EXECUTE dm_rmc_auto_verify_setup
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     GO TO exit_program
    ELSE
     COMMIT
    ENDIF
    SET dpds_dual_bld_flag = 1
    RETURN(dpds_dual_bld_flag)
   ELSEIF (dpds_ptam_answer="N")
    WHILE (dpds_continue=0)
      CALL clear(14,1)
      CALL text(14,3,
       "Should this relationship be configured for RDDS triggers to block dual build? [(Y)es, (N)o, e(X)it]"
       )
      CALL accept(14,105,"P;CU","Y"
       WHERE curaccept IN ("Y", "N", "X"))
      SET dpds_dual_bld_answer = curaccept
      IF (dpds_dual_bld_answer="X")
       SET dpds_dual_bld_flag = 2
       RETURN(dpds_dual_bld_flag)
      ELSEIF (dpds_dual_bld_answer="Y")
       CALL clear(14,1)
       CALL text(14,3,concat("New Configuration for target ",dpds_tgt_env_name,":"))
       CALL text(15,5,"PTAM SETTING")
       CALL text(15,48,"-  NO MASTER DOMAIN IS SET")
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  NO")
       CALL text(18,5,"Cutover Type")
       CALL text(18,48,concat("-  ",dpds_cutover_type))
       CALL text(20,3,"Confirm configuration changes? [(Y)es / (N)o] ")
       CALL accept(20,50,"P;CU","N"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        UPDATE  FROM dm_env_reltn der
         SET der.relationship_type = "BLOCK DUAL BUILD"
         WHERE (der.parent_env_id=dmda_mr->env_id)
          AND der.child_env_id=dpds_target_env_id
          AND der.relationship_type IN ("ALLOW DUAL BUILD", "BLOCK DUAL BUILD")
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET stat = initrec(dera_request)
         SET stat = alterlist(dera_request->env_list,1)
         SET dera_request->child_env_id = dpds_target_env_id
         SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
         SET dera_request->env_list[1].child_env_id = dpds_target_env_id
         SET dera_request->env_list[1].relationship_type = "BLOCK DUAL BUILD"
         EXECUTE dm_add_env_reltn
         IF ((dera_reply->err_num > 0))
          CALL text(21,3,dera_reply->err_msg)
          CALL text(22,3,"Insertion failed! Action aborted..")
          CALL pause(2)
          SET dm_err->eproc = "Inserting 'BLOCK DUAL BUILD' to DM_ENV_RELTN"
          CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
          SET dm_err->err_ind = 1
          GO TO exit_program
         ENDIF
        ENDIF
        SET dm_err->eproc = "Inserting 'DUAL BUILD TRIGGER CHANGE' admin event"
        SET stat = alterlist(auto_ver_request->qual,1)
        SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
        SET auto_ver_request->qual[1].rdds_event = "DUAL BUILD TRIGGER CHANGE"
        SET auto_ver_request->qual[1].event_reason = "New Child Env - Forced Setting"
        SET auto_ver_request->qual[1].paired_environment_id = dmda_mr->env_id
        SET auto_ver_request->qual[1].cur_environment_id = dpds_target_env_id
        SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "DM_ENV_RELTN Change"
        SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = "BLOCK DUAL BUILD"
        SET auto_ver_request->qual[1].detail_qual[1].event_value = 1
        EXECUTE dm_rmc_auto_verify_setup
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ELSE
         COMMIT
        ENDIF
        SET dpds_continue = 1
        SET dpds_dual_bld_flag = 1
        RETURN(dpds_dual_bld_flag)
       ELSEIF (curaccept="N")
        SET dpds_continue = 1
       ENDIF
      ELSEIF (dpds_dual_bld_answer="N")
       CALL clear(14,1)
       CALL text(14,3,concat("New Configuration for target ",dpds_tgt_env_name,":"))
       CALL text(15,5,"PTAM SETTING")
       CALL text(15,48,"-  NO MASTER DOMAIN IS SET")
       CALL text(16,5,"Dual Build Triggers")
       CALL text(16,48,"-  NOT BLOCKING")
       CALL text(17,5,"Dual Build/Cutover Manual Acknowledgement")
       CALL text(17,48,"-  YES")
       CALL text(18,5,"Cutover Type")
       CALL text(18,48,concat("-  ",dpds_cutover_type))
       CALL text(20,3,"Confirm configuration changes? [(Y)es / (N)o] ")
       CALL accept(20,50,"P;CU","N"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        UPDATE  FROM dm_env_reltn der
         SET der.relationship_type = "ALLOW DUAL BUILD"
         WHERE (der.parent_env_id=dmda_mr->env_id)
          AND der.child_env_id=dpds_target_env_id
          AND der.relationship_type IN ("ALLOW DUAL BUILD", "BLOCK DUAL BUILD")
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET stat = initrec(dera_request)
         SET stat = alterlist(dera_request->env_list,1)
         SET dera_request->child_env_id = dpds_target_env_id
         SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
         SET dera_request->env_list[1].child_env_id = dpds_target_env_id
         SET dera_request->env_list[1].relationship_type = "ALLOW DUAL BUILD"
         EXECUTE dm_add_env_reltn
         IF ((dera_reply->err_num > 0))
          CALL text(21,3,dera_reply->err_msg)
          CALL text(22,3,"Insertion failed! Action aborted..")
          CALL pause(2)
          SET dm_err->eproc = "Inserting 'ALLOW DUAL BUILD' to DM_ENV_RELTN"
          CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
          SET dm_err->err_ind = 1
          GO TO exit_program
         ENDIF
        ENDIF
        SET dm_err->eproc = "Inserting 'DUAL BUILD TRIGGER CHANGE' admin event"
        SET stat = alterlist(auto_ver_request->qual,1)
        SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
        SET auto_ver_request->qual[1].rdds_event = "DUAL BUILD TRIGGER CHANGE"
        SET auto_ver_request->qual[1].event_reason = "New Child Env - Forced Setting"
        SET auto_ver_request->qual[1].paired_environment_id = dmda_mr->env_id
        SET auto_ver_request->qual[1].cur_environment_id = dpds_target_env_id
        SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "DM_ENV_RELTN Change"
        SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = "ALLOW DUAL BUILD"
        SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
        EXECUTE dm_rmc_auto_verify_setup
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ELSE
         COMMIT
        ENDIF
        SET dpds_continue = 1
        SET dpds_dual_bld_flag = 1
        RETURN(dpds_dual_bld_flag)
       ELSEIF (curaccept="N")
        SET dpds_continue = 0
       ENDIF
      ENDIF
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_start_xlat_backfill(null)
   DECLARE sxb_dcl_stat = i4 WITH protect, noconstant(0)
   DECLARE sxb_inter_backfill = i2 WITH protect, noconstant(0)
   DECLARE sxb_start_over = i2 WITH protect, noconstant(0)
   DECLARE sxb_num_proc = i2 WITH protect, noconstant(0)
   DECLARE sxb_ndx = i2 WITH protect, noconstant(0)
   DECLARE sxb_avr_cnt = i2 WITH protect, noconstant(0)
   DECLARE sxb_com_batch = vc WITH protect, noconstant("")
   DECLARE sxb_cur_logfile = vc WITH protect, noconstant("")
   DECLARE sxb_execute_str = vc WITH protect, noconstant("")
   CALL clear(1,1)
   CALL dbase_connect(dmda_connect_info)
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg("Gathering connection information",dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SELECT INTO "NL:"
    FROM dm_refchg_process drp
    WHERE drp.refchg_type="TRANSLATION BACKFILL"
     AND drp.refchg_status="XLAT BCKFLL RUNNING"
     AND drp.rdbhandle_value IN (
    (SELECT
     audsid
     FROM gv$session))
    DETAIL
     sxb_inter_backfill = (sxb_inter_backfill+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   WHILE (sxb_start_over=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Manage Translation Backfill Processes ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,3,concat(" Number of translation backfill processes running: ",cnvtstring(
        sxb_inter_backfill)))
     CALL text(12,3,
      "    How many processes do you want to start (This is in addition to any processes which may already be"
      )
     CALL text(13,3,"     running.): ")
     SET accept = nopatcheck
     CALL accept(13,35,"999",0)
     SET sxb_num_proc = curaccept
     IF (cursys="AXP")
      CALL text(16,3,"    Which batch queue would you like this COM proc submitted to?")
      CALL accept(16,70,"P(30);c")
      SET sxb_com_batch = curaccept
     ENDIF
     CALL text(24,3,"Continue? [(Y)es / (N)o / e(X)it]")
     CALL accept(24,38,"P;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     SET accept = patcheck
     SET no_confirm = 0
     IF (curaccept="N")
      SET sxb_start_over = 0
     ELSEIF (curaccept="X")
      SET sxb_start_over = 1
      SET no_confirm = 1
     ELSEIF (curaccept="Y")
      IF (sxb_num_proc < 1)
       CALL text(24,3,"You have chosen to start 0 processes.  Please enter a value more than 0.")
       CALL accept(24,74,"P;HCU","N")
       SET sxb_start_over = 0
      ELSE
       SET sxb_start_over = 1
       FOR (sxb_ndx = 1 TO sxb_num_proc)
         SET sxb_cur_logfile = dm_err->unique_fname
         IF (get_unique_file("rdds_run_xlats_rdm",".log")=0)
          SET nohup_submit_logfile = "rdds_run_xlats_rdm.log"
          SET dm_err->err_ind = 0
         ELSE
          SET nohup_submit_logfile = dm_err->unique_fname
         ENDIF
         SET dm_err->unique_fname = sxb_cur_logfile
         IF (cursys="AXP")
          SET sxb_execute_str = concat("SUBMIT /QUE=",sxb_com_batch,
           " cer_proc:rdds_run_xlats_rdm.com /param=(",dmda_connect_info->db_password,",",
           dmda_connect_info->db_sid,") /log=CCLUSERDIR:",nohup_submit_logfile)
         ELSE
          SET sxb_execute_str = concat("nohup $cer_proc/rdds_run_xlats_rdm.ksh ",dmda_connect_info->
           db_password," ",dmda_connect_info->db_sid," > $CCLUSERDIR/",
           nohup_submit_logfile," 2>&1 &")
         ENDIF
         CALL dcl(sxb_execute_str,size(sxb_execute_str),sxb_dcl_stat)
         IF (sxb_dcl_stat=0)
          SET dm_err->eproc = concat("Error connecting to: ",sxb_dcl_stat)
          CALL disp_msg(" ",dm_err->logfile,0)
          GO TO exit_program
         ENDIF
       ENDFOR
       CALL mc_confirm_screen("xlat_bckfll",sxb_num_proc)
      ENDIF
     ENDIF
   ENDWHILE
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Translation Backfill Started"
   SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
   SET sxb_avr_cnt = 1
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,sxb_avr_cnt)
   SET auto_ver_request->qual[1].detail_qual[sxb_avr_cnt].event_detail1_txt =
   "Number of backfill processes"
   SET auto_ver_request->qual[1].detail_qual[sxb_avr_cnt].event_value = sxb_num_proc
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET stat = initrec(auto_ver_reply)
    SET stat = initrec(auto_ver_request)
    GO TO exit_program
   ELSE
    SET message = nowindow
    COMMIT
    SET stat = initrec(auto_ver_reply)
    SET stat = initrec(auto_ver_request)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_get_xlat_backfill_info(gxb_info)
   DECLARE gxb_inter_backfill = i2 WITH protect, noconstant(0)
   DECLARE gxb_num1 = i4 WITH protect, noconstant(0)
   DECLARE gxb_audit_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Obtaining DM_REFCHG_PROCESS translation backfill rows"
   SELECT INTO "NL:"
    drp.refchg_type, drp.last_action_dt_tm, drp.rdbhandle_value
    FROM dm_refchg_process drp
    WHERE drp.refchg_status="XLAT BCKFLL RUNNING"
     AND drp.rdbhandle_value IN (
    (SELECT
     audsid
     FROM gv$session))
    HEAD REPORT
     gxb_inter_backfill = 0
    DETAIL
     gxb_inter_backfill = (gxb_inter_backfill+ 1)
     IF (mod(gxb_inter_backfill,10)=1)
      stat = alterlist(gxb_info->qual,(gxb_inter_backfill+ 9))
     ENDIF
     gxb_info->qual[gxb_inter_backfill].refchg_type = drp.refchg_type, gxb_info->qual[
     gxb_inter_backfill].last_action_dt_tm = format(drp.last_action_dt_tm,";;Q"), gxb_info->qual[
     gxb_inter_backfill].rdbhandle_value = drp.rdbhandle_value,
     gxb_info->qual[gxb_inter_backfill].process_cnt = gxb_inter_backfill, gxb_audit_cnt = 1, stat =
     alterlist(gxb_info->qual[gxb_inter_backfill].audit_rows,gxb_audit_cnt),
     gxb_info->qual[gxb_inter_backfill].audit_rows[gxb_audit_cnt].audit_text =
     "Process starting to backfill sequences...", gxb_info->qual[gxb_inter_backfill].audit_rows[
     gxb_audit_cnt].audit_action = "CREATEXLAT"
    FOOT REPORT
     stat = alterlist(gxb_info->qual,gxb_inter_backfill)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET dm_err->eproc = "Obtaining DM_CHG_LOG_AUDIT rows for each process"
   SET gxb_info->long_row_cnt = 0
   SELECT INTO "nl:"
    dcla.text, dcla.action, dcla.updt_dt_tm
    FROM dm_chg_log_audit dcla,
     (dummyt d  WITH seq = gxb_inter_backfill)
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dcla
     WHERE dcla.updt_dt_tm >= cnvtdatetime(gxb_info->qual[d.seq].last_action_dt_tm)
      AND dcla.action="CREATEXLAT"
      AND dcla.updt_applctx=cnvtreal(gxb_info->qual[d.seq].rdbhandle_value))
    ORDER BY dcla.updt_dt_tm
    HEAD REPORT
     gxb_audit_cnt = 0
    DETAIL
     index = locateval(gxb_num1,1,gxb_inter_backfill,dcla.updt_applctx,gxb_info->qual[gxb_num1].
      rdbhandle_value)
     IF (index > 0)
      gxb_audit_cnt = 1, stat = alterlist(gxb_info->qual[index].audit_rows,gxb_audit_cnt), gxb_info->
      qual[index].audit_rows[gxb_audit_cnt].audit_text = trim(dcla.text,3),
      gxb_info->qual[index].audit_rows[gxb_audit_cnt].audit_action = trim(dcla.action,3)
     ENDIF
    FOOT REPORT
     FOR (gxb_num1 = 1 TO gxb_inter_backfill)
       IF (size(gxb_info->qual[gxb_num1].audit_rows[1].audit_text) > 115)
        gxb_info->long_row_cnt = (gxb_info->long_row_cnt+ 1)
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_view_xlat_backfill(null)
   DECLARE vxb_loop = i2 WITH protect, noconstant(1)
   DECLARE vxb_xlat_status = i2 WITH protect, noconstant(0)
   DECLARE vxb_str_first_95 = vc WITH protect, noconstant("")
   DECLARE vxb_col_pos = i2 WITH protect, noconstant(0)
   DECLARE vxb_str_format_95 = vc WITH protect, noconstant("")
   DECLARE vxb_str_remain = vc WITH protect, noconstant("")
   DECLARE vxb_low = i2 WITH protect, noconstant(0)
   DECLARE vxb_high = i2 WITH protect, noconstant(0)
   DECLARE vxb_total = i2 WITH protect, noconstant(0)
   DECLARE vxb_incr = i2 WITH protect, noconstant(0)
   DECLARE vxb_over = i2 WITH protect, noconstant(0)
   DECLARE vxb_up = i2 WITH protect, noconstant(0)
   DECLARE vxb_down = i2 WITH protect, noconstant(0)
   DECLARE vxb_num = i2 WITH protect, noconstant(0)
   DECLARE vxb_str = vc WITH protect, noconstant("")
   DECLARE dvxb_loop = i4 WITH protect, noconstant(0)
   DECLARE dvxb_idx = i4 WITH protect, noconstant(0)
   DECLARE dvxb_mock_id = f8 WITH protect, noconstant(0)
   DECLARE dvxb_counter = i4 WITH protect, noconstant(0)
   DECLARE dvxb_command_str = vc WITH protect, noconstant("")
   FREE RECORD xlat_process_info
   RECORD xlat_process_info(
     1 long_row_cnt = i4
     1 qual[*]
       2 refchg_type = vc
       2 last_action_dt_tm = vc
       2 rdbhandle_value = f8
       2 process_cnt = i2
       2 audit_rows[*]
         3 audit_text = vc
         3 audit_action = vc
   )
   FREE RECORD dvxb_seq
   RECORD dvxb_seq(
     1 event_cnt = i4
     1 incomplete_ind = i2
     1 valid_src_cnt = i4
     1 src_cnt = i4
     1 src_qual[*]
       2 db_link = vc
       2 src_id = f8
       2 valid_ind = i2
       2 seq_limit_cnt = i4
       2 src_env_name = vc
       2 num_complete = i4
   )
   SET dvxb_mock_id = drmmi_get_mock_id(dmda_mr->env_id)
   IF (dvxb_mock_id < 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF ((dvxb_mock_id != dmda_mr->env_id)
    AND validate(rdds_run_xlat_backfill_anyway,- (99)) < 0)
    SET message = window
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  Translation Backfill Process Management ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(8,3,"Translation backfill does not need to be performed in the RDDS-mock domain.")
    CALL text(9,3,"If needed, translation backfill is performed in the build source domain.")
    CALL text(10,3,
     'Please view the "Validate RDDS Post Domain Copy" report to check status of translation backfill.'
     )
    CALL text(11,3,"Press Enter to return to menu.")
    CALL accept(11,45,"P;E"," ")
    RETURN
   ENDIF
   CALL dmda_get_xlat_backfill_info(xlat_process_info)
   SELECT INTO "nl:"
    FROM dm_env_reltn der,
     dm_environment de
    WHERE (der.child_env_id=dmda_mr->env_id)
     AND der.relationship_type="REFERENCE MERGE"
     AND trim(der.post_link_name) > ""
     AND der.post_link_name IS NOT null
     AND de.environment_id=der.parent_env_id
    HEAD REPORT
     dvxb_seq->src_cnt = 0
    DETAIL
     dvxb_seq->src_cnt = (dvxb_seq->src_cnt+ 1), stat = alterlist(dvxb_seq->src_qual,dvxb_seq->
      src_cnt), dvxb_seq->src_qual[dvxb_seq->src_cnt].db_link = der.post_link_name,
     dvxb_seq->src_qual[dvxb_seq->src_cnt].src_id = der.parent_env_id, dvxb_seq->src_qual[dvxb_seq->
     src_cnt].valid_ind = 0, dvxb_seq->src_qual[dvxb_seq->src_cnt].src_env_name = de.environment_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   FOR (dvxb_loop = 1 TO dvxb_seq->src_cnt)
     SELECT INTO "nl:"
      FROM (parser(build("v$database",dvxb_seq->src_qual[dvxb_loop].db_link)) d)
      WHERE  NOT (d.name IN (
      (SELECT
       vd.name
       FROM v$database vd)))
      WITH maxqual(d,1), nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->err_ind = 0
     ENDIF
     IF (curqual != 0)
      SET dvxb_seq->src_qual[dvxb_loop].valid_ind = 1
      SET dvxb_seq->valid_src_cnt = (dvxb_seq->valid_src_cnt+ 1)
     ENDIF
     IF ((dvxb_seq->src_qual[dvxb_loop].valid_ind=1))
      SELECT INTO "nl:"
       FROM dm_rdds_event_log d
       WHERE d.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
        AND (d.cur_environment_id=dmda_mr->env_id)
        AND (d.paired_environment_id=dvxb_seq->src_qual[dvxb_loop].src_id)
        AND d.event_reason > ""
       DETAIL
        IF ((cnvtint(d.event_reason) > dvxb_seq->src_qual[dvxb_loop].seq_limit_cnt))
         dvxb_seq->src_qual[dvxb_loop].seq_limit_cnt = cnvtint(d.event_reason)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   WHILE (vxb_loop=1)
     SET message = window
     CALL video(n)
     CALL clear(1,1)
     SET width = 132
     SET accept = time(30)
     SET accept = scroll
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Translation Backfill Process Management ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     SET dvxb_seq->event_cnt = 0
     SET dvxb_seq->incomplete_ind = 0
     SELECT INTO "nl:"
      l.paired_environment_id, cnt = count(DISTINCT d.event_detail1_txt)
      FROM dm_rdds_event_detail d,
       dm_rdds_event_log l
      WHERE (l.cur_environment_id=dmda_mr->env_id)
       AND l.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
       AND l.dm_rdds_event_log_id=d.dm_rdds_event_log_id
      GROUP BY l.paired_environment_id
      ORDER BY cnt
      DETAIL
       dvxb_idx = locateval(dvxb_loop,1,dvxb_seq->src_cnt,l.paired_environment_id,dvxb_seq->src_qual[
        dvxb_loop].src_id)
       IF (dvxb_idx > 0)
        dvxb_seq->src_qual[dvxb_idx].num_complete = cnt
        IF ((dvxb_seq->src_qual[dvxb_idx].valid_ind=1))
         dvxb_seq->event_cnt = (dvxb_seq->event_cnt+ 1)
         IF ((cnt < dvxb_seq->src_qual[dvxb_idx].seq_limit_cnt))
          dvxb_seq->incomplete_ind = 1
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     IF ((dvxb_seq->event_cnt < dvxb_seq->valid_src_cnt))
      SET dvxb_seq->incomplete_ind = 1
     ENDIF
     IF ((dvxb_seq->incomplete_ind=0))
      SET vxb_xlat_status = 1
     ELSE
      SET vxb_xlat_status = 0
     ENDIF
     CALL text(8,3,"Status: ")
     IF (vxb_xlat_status=1)
      CALL text(8,12,"Completed")
     ELSEIF (size(xlat_process_info->qual,5)=0)
      CALL text(8,12,concat("Stalled: There are 0 backfill processes running. ",
        "Please check the dm_rmc_seq_xlats*.log files in CCLUSERDIR for errors."))
     ELSE
      CALL text(8,12,concat("In Progress: There are ",trim(cnvtstring(size(xlat_process_info->qual,5),
          20))," backfill processes running."))
     ENDIF
     SET vxb_line_nbr = 8
     SET dvxb_counter = 0
     FOR (dvxb_loop = 1 TO dvxb_seq->src_cnt)
       IF ((dvxb_seq->src_qual[dvxb_loop].valid_ind=1)
        AND dvxb_counter < 3)
        SET vxb_line_nbr = (vxb_line_nbr+ 1)
        SET dvxb_counter = (dvxb_counter+ 1)
        SET vxb_str_remain = concat("Source ",trim(cnvtstring(dvxb_loop))," of ",trim(cnvtstring(
           dvxb_seq->src_cnt)),": ",
         dvxb_seq->src_qual[dvxb_loop].src_env_name," (",trim(cnvtstring(dvxb_seq->src_qual[dvxb_loop
           ].src_id,20)),")")
        SET vxb_str_remain = concat(vxb_str_remain," - ",trim(cnvtstring(dvxb_seq->src_qual[dvxb_loop
           ].num_complete))," of ",trim(cnvtstring(greatest(dvxb_seq->src_qual[dvxb_loop].
            seq_limit_cnt,dvxb_seq->src_qual[dvxb_loop].num_complete))),
         " sequences backfilled")
        CALL text(vxb_line_nbr,12,vxb_str_remain)
       ENDIF
     ENDFOR
     SET vxb_total = size(xlat_process_info->qual,5)
     SET vxb_incr = ((11 - xlat_process_info->long_row_cnt) - dvxb_counter)
     SET vxb_low = 1
     IF (vxb_total < vxb_incr)
      SET vxb_high = vxb_total
     ELSE
      SET vxb_high = vxb_incr
     ENDIF
     IF (vxb_down=1)
      SET vxb_low = (vxb_low+ vxb_incr)
      IF (((vxb_high+ vxb_incr) > vxb_total))
       SET vxb_over = ((vxb_high+ vxb_incr) - vxb_total)
       SET vxb_high = vxb_total
      ELSE
       SET vxb_over = 0
       SET vxb_high = (vxb_high+ vxb_incr)
      ENDIF
     ELSEIF (vxb_up=1)
      IF (((vxb_low - vxb_incr) >= 1))
       SET vxb_low = (vxb_low - vxb_incr)
       SET vxb_high = ((vxb_high - vxb_incr)+ vxb_over)
       SET vxb_over = 0
      ENDIF
     ENDIF
     SET vxb_up = 0
     SET vxb_down = 0
     SET dvxb_command_str = "(R)efresh, (E)xit"
     IF (vxb_xlat_status != 1)
      SET vxb_line_nbr = (vxb_line_nbr+ 2)
      CALL text(vxb_line_nbr,3,"PROCESS CNT")
      CALL text(vxb_line_nbr,15,"STATUS")
      FOR (i = vxb_low TO vxb_high)
       SET vxb_line_nbr = (vxb_line_nbr+ 1)
       IF (vxb_line_nbr <= 23)
        CALL text(vxb_line_nbr,3,trim(cnvtstring(xlat_process_info->qual[i].process_cnt,20)))
        IF (size(xlat_process_info->qual[i].audit_rows[1].audit_text,1) > 115)
         SET vxb_str_first_95 = substring(1,115,xlat_process_info->qual[i].audit_rows[1].audit_text)
         SET vxb_col_pos = findstring(" ",vxb_str_first_95,1,1)
         SET vxb_str_format_95 = substring(1,(vxb_col_pos - 1),vxb_str_first_95)
         SET vxb_str_remain = substring(vxb_col_pos,size(xlat_process_info->qual[i].audit_rows[1].
           audit_text,1),xlat_process_info->qual[i].audit_rows[1].audit_text)
         CALL text(vxb_line_nbr,15,trim(vxb_str_format_95,3))
         SET vxb_line_nbr = (vxb_line_nbr+ 1)
         CALL text(vxb_line_nbr,15,trim(vxb_str_remain,3))
        ELSE
         CALL text(vxb_line_nbr,15,xlat_process_info->qual[i].audit_rows[1].audit_text)
        ENDIF
       ENDIF
      ENDFOR
      IF (((vxb_low+ vxb_incr) <= vxb_total))
       SET dvxb_command_str = concat(dvxb_command_str,", Page (D)own")
      ENDIF
      IF (vxb_low > vxb_incr)
       SET dvxb_command_str = concat(dvxb_command_str,", Page (U)p")
      ENDIF
     ENDIF
     SET accept = nopatcheck
     CALL text(23,3,concat("Command Options: __ ",dvxb_command_str))
     CALL accept(23,20,"X;CUS","R"
      WHERE curaccept IN ("D", "U", "R", "E"))
     SET accept = patcheck
     CASE (curscroll)
      OF 0:
       SET vxb_str = trim(curaccept)
       IF (vxb_str="R")
        SET stat = initrec(xlat_process_info)
        CALL dmda_get_xlat_backfill_info(xlat_process_info)
        SET message = window
       ELSEIF (vxb_str="E")
        SET vxb_loop = 0
       ELSEIF (vxb_str="U")
        IF (vxb_low > vxb_incr
         AND vxb_xlat_status != 1)
         SET vxb_up = 1
        ELSE
         CALL text(23,58,"Invalid Entry")
         CALL pause(2)
        ENDIF
       ELSEIF (vxb_str="D")
        IF (((vxb_low+ vxb_incr) <= vxb_total)
         AND vxb_xlat_status != 1)
         SET vxb_down = 1
        ELSE
         CALL text(23,58,"Invalid Entry")
         CALL pause(2)
        ENDIF
       ENDIF
      OF 1:
      OF 6:
       IF (((vxb_low+ vxb_incr) <= vxb_total)
        AND vxb_xlat_status != 1)
        SET vxb_down = 1
       ENDIF
      OF 2:
      OF 5:
       IF (vxb_low > vxb_incr
        AND vxb_xlat_status != 1)
        SET vxb_up = 1
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_open_evt_rpt(null)
   DECLARE doer_event_name = vc WITH protect, noconstant("")
   DECLARE doer_event_src = f8 WITH protect, noconstant(0.0)
   DECLARE doer_event_src_name = vc WITH protect, noconstant("")
   DECLARE doer_tmp_err_ind = i2 WITH protect, noconstant(0)
   DECLARE doer_tmp_err_msg = vc WITH protect, noconstant("")
   SET doer_request->open_event_id = 0
   SELECT INTO "NL:"
    drel.event_reason, drel.paired_environment_id
    FROM dm_rdds_event_log drel,
     dm_environment de
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=dmda_mr->env_id)
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     cur_environment_id, paired_environment_id, event_reason
     FROM dm_rdds_event_log
     WHERE (cur_environment_id=dmda_mr->env_id)
      AND rdds_event="End Reference Data Sync"
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
     AND drel.paired_environment_id=de.environment_id
    DETAIL
     doer_request->open_event_id = drel.dm_rdds_event_log_id, doer_event_name = trim(drel
      .event_reason,3), doer_event_src = drel.paired_environment_id,
     doer_event_src_name = trim(de.environment_name,3)
    WITH nocounter
   ;end select
   IF ((doer_request->open_event_id=0))
    CALL text(20,3,"In order to perform this action an open event is required.")
    CALL text(21,3,"Press Enter to return to menu.")
    CALL accept(21,45,"P;E"," ")
   ELSEIF (curqual > 1)
    CALL text(20,3,
     "There is more than one open event for this target.  The open event report could not be generated."
     )
    CALL text(21,3,"Press Enter to return to menu.")
    CALL accept(21,45,"P;E"," ")
   ELSE
    SET doer_request->target_env_id = dmda_mr->env_id
    SET message = window
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  RDDS Open Event Report ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(10,3,"The RDDS Open Event Report will be generated for the following open event.")
    CALL text(11,3,concat("Event Name: ",doer_event_name))
    CALL text(12,3,concat("Source Environment: ",doer_event_src_name," (",trim(cnvtstring(
        doer_event_src,20,0),3),")"))
    CALL text(13,3,"Continue? (Y/N)")
    SET accept = nopatcheck
    CALL accept(13,38,"P;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    SET accept = patcheck
    IF (trim(curaccept)="Y")
     SET doer_request->xml_file_name = dmda_get_file_name(dmda_mr->env_id,dmda_mr->env_name,
      "RDDS OPEN EVENT REPORT","open_event_report",".xml",
      "report")
     IF ((doer_request->xml_file_name != "-1"))
      CALL text(20,3,"Creating RDDS Open Event Report.  Please wait...")
      EXECUTE dm_rmc_event_rpt  WITH replace("REQUEST","DOER_REQUEST"), replace("REPLY","DOER_REPLY")
      IF ((dm_err->err_ind=1))
       SET doer_tmp_err_ind = dm_err->err_ind
       SET doer_tmp_err_msg = dm_err->emsg
       SET dm_err->err_ind = 0
      ENDIF
      CALL remove_lock("RDDS FILENAME LOCK",doer_request->xml_file_name,currdbhandle,drl_reply)
      IF (doer_tmp_err_ind=1)
       SET dm_err->err_ind = doer_tmp_err_ind
       SET dm_err->emsg = doer_tmp_err_msg
      ENDIF
      IF ((doer_reply->status="S"))
       CALL text(20,3,concat("The RDDS Open Event Report:",doer_request->xml_file_name,
         " was succesfully generated."))
       CALL text(21,3,"Press Enter to return to menu.")
       CALL accept(21,45,"P;E"," ")
      ELSE
       CALL clear(20,1)
       CALL text(20,3,"Errors occurred while generating the RDDS Open Event Report.")
       CALL text(21,3,doer_reply->error_msg)
       CALL text(23,3,"Press Enter to return to menu.")
       CALL accept(23,45,"P;E"," ")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_get_num_bbproc(null)
   DECLARE dgnb_start_over = i2 WITH protect, noconstant(0)
   DECLARE dgnb_num_proc = i4 WITH protect, noconstant(0)
   SET dmda_drbb_request->db_password = dmda_connect_info->db_password
   SET dmda_drbb_request->db_sid = cnvtupper(dmda_connect_info->db_sid)
   SET dmda_drbb_request->cur_env_name = dmda_mr->env_name
   WHILE (dgnb_start_over=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Open An RDDS Event  ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,3,"How many processes do you want to start to open this event: ")
     SET accept = nopatcheck
     CALL accept(9,65,"999",4)
     SET dgnb_num_proc = curaccept
     IF (cursys="AXP")
      CALL text(16,3,"    Which batch queue would you like this COM proc submitted to?")
      CALL accept(16,70,"P(30);c")
      SET dmda_drbb_request->dgnb_com_batch = curaccept
     ENDIF
     CALL text(24,3,"Continue? [(Y)es / (N)o / e(X)it]")
     CALL accept(24,38,"P;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     IF (curaccept="N")
      SET dgnb_start_over = 0
     ELSEIF (curaccept="X")
      SET dgnb_start_over = 1
     ELSEIF (curaccept="Y")
      IF (dgnb_num_proc < 1)
       CALL text(24,3,"You have chosen to start 0 processes.  Please enter a value greater than 0.")
       CALL accept(24,77,"P;HCU","N")
       SET dgnb_start_over = 0
      ELSE
       RETURN(dgnb_num_proc)
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dmda_mvr_mons(null)
   DECLARE dmm_loop = i2 WITH protect, noconstant(0)
   WHILE (dmm_loop=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Monitor Data Movers ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(9,3,"Choose from the following options: ")
     CALL text(11,3,"1 Change Log Progress Monitor")
     CALL text(12,3,"2 Mover Activity Monitor")
     CALL text(13,3,"3 Change Log Issues ")
     CALL text(15,3,"0 Exit")
     CALL accept(9,45,"9",0
      WHERE curaccept IN (1, 2, 3, 0))
     CASE (curaccept)
      OF 1:
       EXECUTE dm_rmc_dcl_mon
       SET message = window
      OF 2:
       SET dmam_rs->cur_id = dmda_mr->env_id
       SET dmam_rs->cur_name = dmda_mr->env_name
       EXECUTE dm_rmc_mvract_mon
       SET message = window
       SET accept = notime
      OF 3:
       EXECUTE dm_rmc_dcl_issues
      OF 0:
       SET dmm_loop = 1
     ENDCASE
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dmda_draw_event_box(ddeb_row_pos,ddeb_col_pos,ddeb_status_ind,ddeb_event_rs)
   DECLARE ddeb_oe_task_flg = i4 WITH protect, noconstant(0)
   DECLARE ddeb_event_log_id = f8 WITH protect, noconstant(0.0)
   DECLARE ddeb_task_err_ind = i2 WITH protect, noconstant(0)
   IF (daf_is_blank(ddeb_event_rs->event_status))
    SET ddeb_oe_task_flg = drtq_check_task_process("OPEN EVENT PROCESS")
    IF (ddeb_oe_task_flg IN (1, 2))
     SET ddeb_event_rs->open_event_flg = 0
     SELECT INTO "NL:"
      drel.event_reason, drel.paired_environment_id, drel.event_dt_tm
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event="Begin Reference Data Sync"
       AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
       AND (drel.cur_environment_id=dmda_mr->env_id)
       AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
      (SELECT
       d.cur_environment_id, d.paired_environment_id, d.event_reason
       FROM dm_rdds_event_log d
       WHERE (d.cur_environment_id=dmda_mr->env_id)
        AND d.rdds_event="End Reference Data Sync"
        AND d.rdds_event_key="ENDREFERENCEDATASYNC")))
      DETAIL
       ddeb_event_rs->open_event_flg = 1, ddeb_event_rs->event_name = drel.event_reason,
       ddeb_event_rs->event_src_id = drel.paired_environment_id,
       ddeb_event_rs->event_date = drel.event_dt_tm
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     SELECT INTO "nl:"
      FROM dm_refchg_process drp
      WHERE refchg_type="RDDS OPEN EVENT"
       AND refchg_status="RDDS OPEN EVENT"
       AND rdbhandle_value IN (
      (SELECT
       audsid
       FROM gv$session))
      DETAIL
       ddeb_event_rs->open_event_flg = 2, ddeb_event_rs->event_src_id = drp.env_source_id,
       ddeb_event_rs->event_name = "UNKNOWN",
       ddeb_event_rs->event_date = drp.last_action_dt_tm
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
    ELSEIF (ddeb_oe_task_flg IN (3, 4))
     SET ddeb_event_rs->open_event_flg = 2
     SET dm_err->eproc = "Gathering task queue data for open event process"
     SELECT INTO "nl:"
      FROM dm_rdds_event_detail d
      WHERE d.dm_rdds_event_log_id IN (
      (SELECT
       l.dm_rdds_event_log_id
       FROM dm_rdds_event_log l
       WHERE l.rdds_event_key="TASKQUEUESTARTED"
        AND (l.cur_environment_id=dmda_mr->env_id)
        AND l.paired_environment_id=0
        AND l.event_reason="OPEN EVENT PROCESS"
        AND l.event_dt_tm IN (
       (SELECT
        max(l2.event_dt_tm)
        FROM dm_rdds_event_log l2
        WHERE (l2.cur_environment_id=dmda_mr->env_id)
         AND l2.paired_environment_id=0
         AND l2.rdds_event_key="TASKQUEUESTARTED"
         AND l2.event_reason="OPEN EVENT PROCESS"))))
      DETAIL
       IF (d.event_detail1_txt="EVENT_NAME")
        ddeb_event_rs->event_name = d.event_detail2_txt
       ELSEIF (d.event_detail1_txt="EVENT_SOURCE_NAME")
        ddeb_event_rs->event_src_name = d.event_detail2_txt
       ELSEIF (d.event_detail1_txt="EVENT_SOURCE_ID")
        ddeb_event_rs->event_src_id = cnvtreal(d.event_detail2_txt)
       ENDIF
       ddeb_event_log_id = d.dm_rdds_event_log_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     SELECT INTO "nl:"
      FROM dm_rdds_event_log drel
      WHERE drel.dm_rdds_event_log_id=ddeb_event_log_id
      DETAIL
       ddeb_event_rs->event_date = drel.event_dt_tm
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     IF (ddeb_event_log_id=0)
      SET ddeb_event_rs->open_event_flg = 0
      SELECT INTO "nl:"
       FROM dm_refchg_process drp
       WHERE refchg_type="RDDS OPEN EVENT"
        AND refchg_status="RDDS OPEN EVENT"
        AND rdbhandle_value IN (
       (SELECT
        audsid
        FROM gv$session))
       DETAIL
        ddeb_event_rs->open_event_flg = 2, ddeb_event_rs->event_src_id = drp.env_source_id,
        ddeb_event_rs->event_name = "UNKNOWN",
        ddeb_event_rs->event_date = drp.last_action_dt_tm
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN
      ENDIF
      IF ((ddeb_event_rs->open_event_flg=0))
       SET dm_err->err_ind = 1
       CALL disp_msg("Error searching RDDS OPEN EVENT infomation on dm_refchg_process table",dm_err->
        logfile,1)
       RETURN
      ENDIF
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("Error searching for Open Event Process tasks",dm_err->logfile,1)
     RETURN
    ENDIF
    SELECT INTO "nl:"
     FROM dm_refchg_task_queue tq
     WHERE tq.process_name="OPEN EVENT PROCESS"
      AND tq.task_status="ERROR"
     DETAIL
      ddeb_task_err_ind = 1
     WITH maxqual(tq,1), nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF ((((ddeb_event_rs->open_event_flg=0)) OR ((ddeb_event_rs->open_event_flg=2)
     AND ddeb_status_ind=0)) )
     SET ddeb_event_rs->event_status = "No Open Event"
     SET ddeb_event_rs->open_event_flg = 0
    ELSEIF ((ddeb_event_rs->open_event_flg=1))
     SET ddeb_event_rs->event_status = "Complete"
    ELSEIF (ddeb_oe_task_flg=3
     AND ddeb_task_err_ind=0)
     SET ddeb_event_rs->event_status = "In Progress - No Sessions Running"
    ELSEIF (ddeb_task_err_ind=1)
     SET ddeb_event_rs->event_status = "In Progress - Errors Found"
    ELSE
     SET ddeb_event_rs->event_status = "In Progress"
    ENDIF
    SELECT INTO "NL:"
     FROM dm_environment de
     WHERE (de.environment_id=ddeb_event_rs->event_src_id)
     DETAIL
      ddeb_event_rs->event_src_name = de.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   CALL box(ddeb_row_pos,ddeb_col_pos,(ddeb_row_pos+ 8),(ddeb_col_pos+ 50))
   CALL text((ddeb_row_pos+ 2),(ddeb_col_pos+ 3),"Current Open Event:")
   IF ((((ddeb_event_rs->open_event_flg=0)) OR (ddeb_status_ind=1)) )
    CALL text((ddeb_row_pos+ 3),(ddeb_col_pos+ 5),ddeb_event_rs->event_status)
   ENDIF
   IF ((ddeb_event_rs->open_event_flg > 0))
    CALL text((ddeb_row_pos+ 4),(ddeb_col_pos+ 5),concat("Event Name: ",ddeb_event_rs->event_name))
    CALL text((ddeb_row_pos+ 5),(ddeb_col_pos+ 5),concat("Event Date: ",format(ddeb_event_rs->
       event_date,"dd-mmm-yy HH:MM:SS;;q")))
    IF (size(trim(cnvtstring(ddeb_event_rs->event_src_id)),1) > 11)
     CALL text((ddeb_row_pos+ 6),(ddeb_col_pos+ 5),concat("    Source: ",ddeb_event_rs->
       event_src_name," "))
     CALL text((ddeb_row_pos+ 7),(ddeb_col_pos+ 17),trim(cnvtstring(ddeb_event_rs->event_src_id)))
    ELSE
     CALL text((ddeb_row_pos+ 6),(ddeb_col_pos+ 5),concat("    Source: ",ddeb_event_rs->
       event_src_name," ",trim(cnvtstring(ddeb_event_rs->event_src_id))))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE mover_reset_time(null)
   DECLARE mrt_time = i4 WITH protect, noconstant(0)
   DECLARE mrt_continue = c1 WITH protect, noconstant(" ")
   DECLARE mrt_done_ind = i2 WITH protect, noconstant(0)
   DECLARE mrt_orig_time = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    di.info_number
    FROM dm_info di
    WHERE di.info_domain="RDDS DCL PROCESSING"
     AND di.info_name="EXCEPTION RESET TIME"
    DETAIL
     mrt_time = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
   ENDIF
   IF (curqual=0)
    SET mrt_time = 240
   ENDIF
   SET mrt_orig_time = mrt_time
   WHILE (mrt_done_ind=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,48,"***  Set DM_CHG_LOG Reset Time ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(8,3,concat(
       "The RDDS mover(s) periodically reset DM_CHG_LOG rows that are in HOLDNG or NOMV14 ",
       "end states back to REFCHG to be reprocessed."))
     CALL text(9,3,"Changing this setting controls how often the DM_CHG_LOG rows are reset")
     CALL text(10,3,"The reset time is controlled in minutes and can range from 5 to 300.")
     CALL text(12,3,"What would you like the reset time to be set at?")
     CALL text(13,3,concat("Current reset time is: ",trim(cnvtstring(mrt_time))))
     CALL accept(12,52,"999",trim(cnvtstring(mrt_time))
      WHERE cnvtint(curaccept) >= 5
       AND cnvtint(curaccept) <= 300)
     SET mrt_time = cnvtint(curaccept)
     CALL text(21,3,"Confirm configuration changes? [(Y)es / (N)o / e(X)it] ")
     CALL accept(21,58,"P;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     SET mrt_continue = curaccept
     IF (mrt_continue="Y")
      SET mrt_done_ind = 1
      UPDATE  FROM dm_info di
       SET di.info_number = cnvtreal(mrt_time)
       WHERE di.info_domain="RDDS DCL PROCESSING"
        AND di.info_name="EXCEPTION RESET TIME"
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc) != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_info di
        SET di.info_number = cnvtreal(mrt_time), di.info_domain = "RDDS DCL PROCESSING", di.info_name
          = "EXCEPTION RESET TIME"
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
       ENDIF
      ENDIF
      IF ((dm_err->err_ind=0))
       COMMIT
      ENDIF
      SET stat = alterlist(auto_ver_request->qual,1)
      SET auto_ver_request->qual[1].rdds_event = "Mover Reset Time Setting"
      SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
      SET auto_ver_request->qual[1].paired_environment_id = 0
      SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
      SET auto_ver_request->qual[1].detail_qual[1].event_value = cnvtreal(mrt_time)
      EXECUTE dm_rmc_auto_verify_setup
      IF ((auto_ver_reply->status="F"))
       ROLLBACK
       CALL disp_msg(auto_ver_reply->status_msg,dm_err->logfile,1)
       SET stat = initrec(auto_ver_request)
       SET stat = initrec(auto_ver_reply)
       GO TO exit_program
      ELSE
       COMMIT
       SET stat = initrec(auto_ver_request)
       SET stat = initrec(auto_ver_reply)
      ENDIF
     ELSEIF (mrt_continue="N")
      SET mrt_time = mrt_orig_time
     ELSEIF (mrt_continue="X")
      SET mrt_done_ind = 1
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE cancel_sched_ac(null)
   DECLARE csa_date = vc WITH protect, noconstant("")
   DECLARE csa_continue = c1 WITH protect, noconstant(" ")
   DECLARE csa_done_ind = i2 WITH protect, noconstant(0)
   WHILE (csa_done_ind=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,48,"***  Cancel Scheduled Auto Cutover ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     SELECT INTO "NL:"
      FROM dm_info d
      WHERE d.info_domain="RDDS CONFIGURATION"
       AND d.info_name=concat("SCHEDULED CUTOVER:",trim(cnvtstring(dmda_mr->env_id,20)))
      DETAIL
       csa_date = format(d.info_date,";;Q")
      WITH nocounter
     ;end select
     IF (check_error_gui(dm_err->eproc,"Cancel Schedule Auto Cutover",dmda_mr->env_name,dmda_mr->
      env_id) != 0)
      RETURN(null)
     ENDIF
     CALL text(8,3,concat(
       "Are you sure that you would like to cancel the scheduled auto-cutover that has been setup for ",
       csa_date,"?"))
     CALL text(9,3,"Cancelling the cutover means that the work will not be performed at that time.")
     CALL text(11,3,"Confirm cancellation? [(Y)es / (N)o / e(X)it] ")
     CALL accept(11,50,"P;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     SET csa_continue = curaccept
     IF (csa_continue="Y")
      CALL cancel_sched_dml(null)
      SET csa_done_ind = 1
     ELSEIF (csa_continue="N")
      SET csa_done_ind = 1
     ELSEIF (csa_continue="X")
      SET csa_done_ind = 1
      GO TO exit_program
     ENDIF
   ENDWHILE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE cancel_sched_dml(null)
   DECLARE csd_return = c1 WITH protect, noconstant(" ")
   SET csd_return = drtq_delete_task_process("SCHEDULED AUTO-CUTOVER")
   IF (csd_return="F")
    CALL check_error_gui(dm_err->eproc,"Cancel Scheduled Auto Cutover",dmda_mr->env_name,dmda_mr->
     env_id)
    ROLLBACK
    RETURN(null)
   ENDIF
   DELETE  FROM dm_info
    WHERE info_domain="RDDS CONFIGURATION"
     AND info_name=concat("SCHEDULED CUTOVER:",trim(cnvtstring(dmda_mr->env_id,20)))
    WITH nocounter
   ;end delete
   IF (check_error_gui(dm_err->eproc,"Cancel Scheduled Auto Cutover",dmda_mr->env_name,dmda_mr->
    env_id) != 0)
    RETURN(null)
   ENDIF
   DELETE  FROM dm_info
    WHERE info_domain="DM_STAT_GATHER"
     AND info_name="DM_RMC_RUN_AUTO_CUT"
    WITH nocounter
   ;end delete
   IF (check_error_gui(dm_err->eproc,"Cancel Scheduled Auto Cutover",dmda_mr->env_name,dmda_mr->
    env_id) != 0)
    ROLLBACK
    RETURN(null)
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Cancel Scheduled Auto Cutover"
   SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
   SET stat = initrec(auto_ver_request)
   SET stat = initrec(auto_ver_reply)
 END ;Subroutine
 SUBROUTINE dmda_get_default_context(dgdc_ctxt_to_pull)
   DECLARE gdc_str_first_100 = vc WITH protect, noconstant("")
   DECLARE gdc_col_pos = i4 WITH protect, noconstant(0)
   DECLARE gdc_str_format_100 = vc WITH protect, noconstant("")
   DECLARE gdc_str_remain = vc WITH protect, noconstant("")
   DECLARE gdc_temp_str = vc WITH protect, noconstant("")
   DECLARE gdc_while2_ind = i2 WITH protect, noconstant(0)
   DECLARE dgdc_default_ctxt = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CONTEXT"
     AND di.info_name="DEFAULT CONTEXT"
    DETAIL
     dgdc_default_ctxt = di.info_char
    WITH nocounter
   ;end select
   IF (check_error("Error finding current DEFAULT CONTEXT") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,7,132)
   CALL text(3,45,"*** Set Default Context ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(9,3,
    "Null contexts are not allowed. In case incoming rows have a context of NULL, what would you like the "
    )
   CALL text(10,3,
    "context to be changed to for this domain (hit enter to leave this value unchanged)?")
   CALL text(12,3,"Current Source Context(s) to Pull:")
   CALL text(13,3,"----------------------------------")
   IF (size(dgdc_ctxt_to_pull,1) > 100)
    SET gdc_str_first_100 = substring(1,100,dgdc_ctxt_to_pull)
    SET gdc_col_pos = findstring("::",gdc_str_first_100,1,1)
    SET gdc_str_format_100 = substring(1,(gdc_col_pos - 1),gdc_str_first_100)
    SET gdc_str_remain = substring(gdc_col_pos,size(dgdc_ctxt_to_pull,1),dgdc_ctxt_to_pull)
    CALL text(14,3,trim(gdc_str_format_100,3))
    CALL text(15,3,trim(gdc_str_remain,3))
   ELSE
    CALL text(14,3,dgdc_ctxt_to_pull)
   ENDIF
   CALL text(17,3,"Current Default Context:")
   CALL text(18,3,"-----------------------")
   CALL text(15,60,"** 'ALL' is not a valid Default Context")
   CALL text(17,60,"** ':' is not allowed in Default Context")
   CALL text(19,60,"** All blanks spaces is not a valid Default Context")
   SET gdc_while2_ind = 1
   WHILE (gdc_while2_ind=1)
     CALL accept(19,3,"P(24);CU",dgdc_default_ctxt)
     SET gdc_temp_str = curaccept
     IF (findstring(concat(":",gdc_temp_str,":"),concat(":",dgdc_ctxt_to_pull,":")) > 0)
      SET gdc_temp_str = ""
     ELSEIF (gdc_temp_str="NULL")
      SET gdc_temp_str = ""
     ELSEIF (gdc_temp_str="ALL")
      SET gdc_temp_str = ""
     ELSEIF (size(trim(gdc_temp_str),1)=0)
      SET gdc_temp_str = ""
     ELSEIF (findstring(":",gdc_temp_str) > 0)
      SET gdc_temp_str = ""
     ELSE
      SET dgdc_default_ctxt = gdc_temp_str
      SET gdc_while2_ind = 0
     ENDIF
   ENDWHILE
   UPDATE  FROM dm_info di
    SET di.info_char = dgdc_default_ctxt, di.updt_id = reqinfo->updt_id, di.updt_cnt = (di.updt_cnt+
     1),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_task = reqinfo->updt_task, di
     .updt_applctx = reqinfo->updt_applctx
    WHERE di.info_domain="RDDS CONTEXT"
     AND di.info_name="DEFAULT CONTEXT"
    WITH nocounter
   ;end update
   IF (check_error("Can not modify DEFAULT CONTEXT") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "RDDS CONTEXT", di.info_name = "DEFAULT CONTEXT", di.info_char =
      dgdc_default_ctxt,
      di.info_long_id = 0, di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_id = reqinfo->updt_id, di.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (check_error("Can not add DEFAULT CONTEXT") != 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
   COMMIT
   RETURN(dgdc_default_ctxt)
 END ;Subroutine
 SUBROUTINE dmda_check_mig_settings(dcms_ack_ind,dcms_oe_name,dcms_proc_name)
   DECLARE dcms_mig_status = i4 WITH protect, noconstant(0)
   DECLARE dcms_ret_val = i4 WITH protect, noconstant(0)
   DECLARE dcms_continue = vc WITH protect, noconstant("")
   DECLARE dcms_no_event_ind = i2 WITH protect, noconstant(0)
   DECLARE dcms_nvld_user = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Migration Acknowledgment"
   IF (((dcms_oe_name="UNKNOWN") OR (size(trim(dcms_oe_name))=0)) )
    SET dcms_no_event_ind = 1
   ENDIF
   SET dcms_mig_status = drrm_check_mig(dcms_ack_ind,dcms_oe_name)
   IF (check_error("Checking Migration status") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (dcms_mig_status=0)
    SET dcms_ret_val = 0
   ELSE
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,7,132)
    CALL text(3,53,"***  Migration Warning ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    IF (dcms_ack_ind=1
     AND dcms_no_event_ind=0)
     CALL text(8,3,concat("A database migration is in progress, if the ",dcms_proc_name,
       " is started the RDDS project will"," be required to complete "))
     CALL text(9,3,concat(
       "the merge and cutover process prior to the migration downtime event.  Please work",
       " with your integration architect to"))
     CALL text(10,3,concat(
       "determine if you should proceed.  By confirming 'Y', you are assuming responsibility to complete",
       " the RDDS merge and"))
     CALL text(11,3,concat(
       "cutover within the current migration timeframe and the RDDS project must close its event ",
       "prior to migration downtime."))
     CALL text(18,22,
      "WARNING: If 'Y' is answered, the next few screens will prompt you for CCLSECLOGIN information. "
      )
     CALL text(19,22,"The following accounts cannot be used: SYSTEM, CERNER, SYSTEMOE.")
     CALL text(20,22,"Please have this information ready!")
     CALL text(14,3,"Do you want to continue? [(Y)es / (N)o / e(X)it] ")
     CALL accept(14,52,"P;CU","N"
      WHERE curaccept IN ("Y", "N", "X"))
     SET dcms_continue = curaccept
     IF (dcms_continue="Y")
      IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
       IF ((xxcclseclogin->loggedin != 1))
        CALL clear(1,1)
        CALL parser("cclseclogin go")
        IF (check_error(dm_err->eproc)=1)
         SET dm_err->emsg = ""
         SET dm_err->err_ind = 0
        ENDIF
        IF ((xxcclseclogin->loggedin != 1))
         SET message = nowindow
         SET dm_err->eproc = "Acknowledging Migration"
         SET dm_err->emsg = "User not logged in cclseclogin"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        CALL clear(1,1)
        CALL box(1,1,7,132)
        CALL text(3,53,"***  Migration Warning ***")
        CALL text(5,20,"Environment Name:")
        CALL text(5,40,dmda_mr->env_name)
        CALL text(5,65,"Environment ID:")
        CALL text(5,85,cnvtstring(dmda_mr->env_id))
       ENDIF
       SET dcms_nvld_user = drcm_check_user(null)
       IF (dcms_nvld_user < 0)
        CALL check_error_gui(dm_err->eproc,"Checking Migration Status",dmda_mr->env_name,dmda_mr->
         env_id)
        GO TO exit_program
       ELSEIF (dcms_nvld_user=1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg =
        "RESTRICTED USER. Please exit your ccl session and sign in as a user other than SYSTEM, SYSTEMOE, or CERNER"
        CALL check_error_gui(dm_err->eproc,"Checking Migration status",dmda_mr->env_name,dmda_mr->
         env_id)
        GO TO exit_program
       ENDIF
      ENDIF
      CALL drrm_ack_mig(dcms_oe_name,dmda_mr->env_id)
      IF (check_error_gui("Adding Migration acknowledgement","Checking Migration status",dmda_mr->
       env_name,dmda_mr->env_id) != 0)
       GO TO exit_program
      ENDIF
      SET dcms_ret_val = 0
     ELSEIF (dcms_continue="N")
      SET dcms_ret_val = 1
     ELSEIF (dcms_continue="X")
      GO TO exit_program
     ENDIF
    ELSEIF (dcms_ack_ind=1
     AND dcms_no_event_ind=1)
     CALL text(8,3,concat("A database migration is in progress and there is not an open event.  "))
     CALL text(9,3,concat("The ",dcms_proc_name,
       " process will not be allowed to start in this scenario."))
     CALL text(10,3,"Press Enter to continue to previous menu.")
     CALL accept(10,45,"P;E"," ")
     SET dcms_ret_val = 1
    ELSE
     CALL text(8,3,concat("A database migration is in progress and the ",dcms_proc_name,
       " cannot run."))
     CALL text(9,3,"Press Enter to continue to previous menu.")
     CALL accept(9,45,"P;E"," ")
     SET dcms_ret_val = 1
    ENDIF
   ENDIF
   RETURN(dcms_ret_val)
 END ;Subroutine
#exit_program
 SET message = nowindow
 IF ((dm_err->err_ind=1))
  CALL disp_msg("Errors occurred during execution, check logfile for details",dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "...Ending dm_merge_domain_adm"
 CALL final_disp_msg("dm_merge_domain_adm")
END GO
