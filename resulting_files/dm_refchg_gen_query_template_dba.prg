CREATE PROGRAM dm_refchg_gen_query_template:dba
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
 IF ( NOT (validate(drgqt_request,0)))
  FREE RECORD drgqt_request
  RECORD drgqt_request(
    1 tbl_name = vc
    1 tbl_suffix = vc
    1 template_type = vc
    1 col_cnt = i4
    1 cols[*]
      2 column_name = vc
      2 column_datatype = vc
      2 parent_entity_col = vc
      2 trans_ind = i2
      2 exist_ind = i2
      2 precision_ind = i2
      2 base62_re_name = vc
  )
 ENDIF
 IF ( NOT (validate(drgqt_reply,0)))
  FREE RECORD drgqt_reply
  RECORD drgqt_reply(
    1 err_ind = i2
    1 err_msg = vc
    1 pkw_template = vc
  )
 ENDIF
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
 IF (check_logfile("DM_REFCHG_GEN_Q",".log","DM_REFCHG_GEN_Q LogFile")=0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((drgqt_request->col_cnt=0))
  GO TO exit_program
 ENDIF
 FREE RECORD dr_decode
 RECORD dr_decode(
   1 qual[*]
     2 str = vc
     2 dmt3_str = vc
     2 ptam_str = vc
 ) WITH protect
 DECLARE dr_loop = i4 WITH protect
 DECLARE drgq_old_temp_type = vc WITH protect
 DECLARE drgq_type_ind = i2 WITH protect
 IF ((validate(drg_non_eng_ind,- (1))=- (1)))
  DECLARE drg_non_eng_ind = i2
  SET drg_non_eng_ind = 0
 ENDIF
 FOR (dr_loop = 1 TO drgqt_request->col_cnt)
  SET stat = alterlist(dr_decode->qual,dr_loop)
  IF ((drgqt_request->cols[dr_loop].column_datatype IN ("CHAR", "VARCHAR", "VARCHAR2", "ROWID")))
   SET dr_decode->qual[dr_loop].str = concat("decode(i_",trim(substring(1,28,drgqt_request->cols[
      dr_loop].column_name)),",null,' is null ',chr(0),'=char(0)','='|| dm_refchg_breakup_str(i_",
    trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),"))")
   SET dr_decode->qual[dr_loop].dmt3_str = concat("decode(i_",trim(substring(1,28,drgqt_request->
      cols[dr_loop].column_name)),
    ",null,''''||'<DM2NULLVAL>'||'''',chr(0),' char(0) ',dm_refchg_breakup_str(i_",trim(substring(1,
      28,drgqt_request->cols[dr_loop].column_name)),"))")
   SET dr_decode->qual[dr_loop].ptam_str = concat("decode(i_",trim(substring(1,28,drgqt_request->
      cols[dr_loop].column_name)),",null,'NULL',''''|| replace(i_",trim(substring(1,28,drgqt_request
      ->cols[dr_loop].column_name)),",'''','''''')||'''')")
  ELSEIF ((drgqt_request->cols[dr_loop].column_datatype="DATE"))
   IF (drg_non_eng_ind=0)
    SET dr_decode->qual[dr_loop].str = concat("decode(to_char(i_",trim(substring(1,28,drgqt_request->
       cols[dr_loop].column_name)),"),null,' is null ',' = cnvtdatetimeutc('||'^'|| to_char(i_",trim(
      substring(1,28,drgqt_request->cols[dr_loop].column_name)),
     ",'DD-MON-YYYY HH24:MI:SS') ||'^'||')')")
    SET dr_decode->qual[dr_loop].ptam_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,'NULL','to_date('||''''||to_char(i_",trim(
      substring(1,28,drgqt_request->cols[dr_loop].column_name)),
     ",'DD-MON-YYYY HH24:MI:SS')||''''||',''DD-MON-YYYY HH24:MI:SS'')')")
   ELSE
    SET dr_decode->qual[dr_loop].str = concat("decode(to_char(i_",trim(substring(1,28,drgqt_request->
       cols[dr_loop].column_name)),"),null,' is null ',' = cnvtdatetimeutc('||'^'|| to_char(i_",trim(
      substring(1,28,drgqt_request->cols[dr_loop].column_name)),
     ",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')")
    SET dr_decode->qual[dr_loop].ptam_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,'NULL','to_date('||''''||to_char(i_",trim(
      substring(1,28,drgqt_request->cols[dr_loop].column_name)),
     ",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american')",
     "||''''||',''DD-MON-YYYY HH24:MI:SS'',''nls_date_language=american'')')")
   ENDIF
  ELSEIF ((drgqt_request->cols[dr_loop].precision_ind=1))
   IF (drg_non_eng_ind=0)
    SET dr_decode->qual[dr_loop].str = concat("decode(to_char(i_",trim(substring(1,28,drgqt_request->
       cols[dr_loop].column_name)),"),null,' is null ',' ='|| decode(trunc(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),") - i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),",0,to_char(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),")||'.0', decode(ceil(abs(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),
     ")),1, ","TRIM(to_char(i_",trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),
     ",'FM0.9999999999','nls_numeric_characters=''.,'''",")), to_char(i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),"))))")
    SET dr_decode->qual[dr_loop].dmt3_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,' null ', decode(trunc(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),") - i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),",0,to_char(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),")||'.0', decode(ceil(abs(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),
     ")),1, ","TRIM(to_char(i_",trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),
     ",'FM0.9999999999','nls_numeric_characters=''.,'''",")),to_char(i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),"))))")
    SET dr_decode->qual[dr_loop].ptam_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,'NULL',to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"))")
   ELSE
    SET dr_decode->qual[dr_loop].str = concat("decode(to_char(i_",trim(substring(1,28,drgqt_request->
       cols[dr_loop].column_name)),"),null,' is null ',' ='|| decode(trunc(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),") - i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),",0,to_char(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),")||'.0', decode(trunc(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),
     "),0, ","to_char(i_",trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),
     ",'FM0.9999999999','nls_numeric_characters=''.,'''), to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),
     ",'TM9','nls_numeric_characters=''.,'''))))")
    SET dr_decode->qual[dr_loop].dmt3_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,' null ', decode(trunc(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),") - i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),",0,to_char(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),")||'.0', decode(trunc(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),
     "),0, ","to_char(i_",trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),
     ",'FM0.9999999999','nls_numeric_characters=''.,'''),to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),
     ",'TM9','nls_numeric_characters=''.,'''))))")
    SET dr_decode->qual[dr_loop].ptam_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,'NULL',to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),",'TM9','nls_numeric_characters=''.,'''))")
   ENDIF
  ELSE
   IF (drg_non_eng_ind=0)
    SET dr_decode->qual[dr_loop].str = concat("decode(to_char(i_",trim(substring(1,28,drgqt_request->
       cols[dr_loop].column_name)),"),null,' is null ',' ='|| decode(trunc(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),") - i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),",0,to_char(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),")||'.0', to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),
     ")))")
    SET dr_decode->qual[dr_loop].dmt3_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,' null ', decode(trunc(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),") - i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),",0,to_char(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),")||'.0', to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),
     ")))")
    SET dr_decode->qual[dr_loop].ptam_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,'NULL',to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"))")
   ELSE
    SET dr_decode->qual[dr_loop].str = concat("decode(to_char(i_",trim(substring(1,28,drgqt_request->
       cols[dr_loop].column_name)),"),null,' is null ',' ='|| decode(trunc(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),") - i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),",0,to_char(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),")||'.0', to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),
     ",'TM9','nls_numeric_characters=''.,''')))")
    SET dr_decode->qual[dr_loop].dmt3_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,' null ', decode(trunc(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),") - i_",
     trim(substring(1,28,drgqt_request->cols[dr_loop].column_name)),",0,to_char(i_",trim(substring(1,
       28,drgqt_request->cols[dr_loop].column_name)),")||'.0', to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),
     ",'TM9','nls_numeric_characters=''.,''')))")
    SET dr_decode->qual[dr_loop].ptam_str = concat("decode(to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),"),null,'NULL',to_char(i_",trim(substring(1,28,
       drgqt_request->cols[dr_loop].column_name)),",'TM9','nls_numeric_characters=''.,'''))")
   ENDIF
  ENDIF
 ENDFOR
 SET drgq_type_ind = 1
 SET drgq_old_temp_type = drgqt_request->template_type
 FOR (dr_loop = 1 TO drgqt_request->col_cnt)
   IF ((((drgqt_request->cols[dr_loop].trans_ind=1)) OR (daf_is_not_blank(drgqt_request->cols[dr_loop
    ].base62_re_name)))
    AND (drgqt_request->template_type="DELETE"))
    SET drgq_type_ind = 0
   ENDIF
 ENDFOR
 IF (drgq_type_ind=1
  AND (drgqt_request->template_type="DELETE"))
  SET drgqt_request->template_type = "INS/UPD"
 ENDIF
 IF ((drgqt_request->template_type="INS/UPD"))
  FOR (dr_loop = 1 TO drgqt_request->col_cnt)
    IF (dr_loop=1)
     SET drgqt_reply->pkw_template = concat("'WHERE t",drgqt_request->tbl_suffix,".",drgqt_request->
      cols[dr_loop].column_name,"'|| ",
      dr_decode->qual[dr_loop].str)
    ELSE
     SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template,"|| ' AND t",drgqt_request->
      tbl_suffix,".",drgqt_request->cols[dr_loop].column_name,
      "'|| ",dr_decode->qual[dr_loop].str)
    ENDIF
  ENDFOR
 ELSEIF ((drgqt_request->template_type="DELETE"))
  FOR (dr_loop = 1 TO drgqt_request->col_cnt)
    IF ((drgqt_request->cols[dr_loop].exist_ind=1))
     IF (dr_loop=1)
      SET drgqt_reply->pkw_template = concat("'CONCAT('||''''||'WHERE t",drgqt_request->tbl_suffix,
       ".",drgqt_request->cols[dr_loop].column_name)
     ELSE
      SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template,"||','||''''||' AND t",
       drgqt_request->tbl_suffix,".",drgqt_request->cols[dr_loop].column_name)
     ENDIF
     IF ((drgqt_request->cols[dr_loop].trans_ind=1))
      SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template,
       "='||''''||',dm_trans3('||''''||'",drgqt_request->tbl_name,"'||''''||','||''''||'",
       drgqt_request->cols[dr_loop].column_name,
       "'||''''||','||",dr_decode->qual[dr_loop].dmt3_str,"||', <SOURCE_IND>,'||")
     ELSEIF (daf_is_not_blank(drgqt_request->cols[dr_loop].base62_re_name))
      SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template,
       "='||''''||',dm_trans4('||''''||'",drgqt_request->cols[dr_loop].base62_re_name,
       "'||''''||','||",dr_decode->qual[dr_loop].dmt3_str,
       "||', <SOURCE_IND>)'")
     ELSE
      SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template," '|| ",dr_decode->qual[
       dr_loop].str," ||''''")
     ENDIF
     IF ((drgqt_request->cols[dr_loop].trans_ind=1))
      IF (daf_is_not_blank(drgqt_request->cols[dr_loop].parent_entity_col))
       SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template," decode(i_",trim(substring(1,
          28,drgqt_request->cols[dr_loop].parent_entity_col)),",null,'^^', dm_refchg_breakup_str(i_",
        trim(substring(1,28,drgqt_request->cols[dr_loop].parent_entity_col)),
        "))||')'")
      ELSE
       SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template,"''''||' '||''''||')'")
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
  SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template,"||')'")
 ELSEIF ((drgqt_request->template_type="PTAM"))
  SET drgqt_reply->pkw_template = concat("'PTAM_MATCH_QUERY_",drgqt_request->tbl_suffix,"(")
  FOR (dr_loop = 1 TO drgqt_request->col_cnt)
    SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template,"'||",dr_decode->qual[dr_loop].
     ptam_str,"||',")
  ENDFOR
  SET drgqt_reply->pkw_template = concat(drgqt_reply->pkw_template,
   "<SOURCE_ID>,<TARGET_ID>,<DB_LINK>,<LOCAL_IND>,<XLAT_TYPE>)'")
 ELSE
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "DRGQT_REQUEST->TEMPLATE_TYPE is not set correctly."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  SET drgqt_reply->err_ind = 1
  SET drgqt_reply->err_msg = dm_err->emsg
  GO TO exit_program
 ENDIF
 SET drgqt_request->template_type = drgq_old_temp_type
#exit_program
 FREE RECORD dr_decode
END GO
