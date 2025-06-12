CREATE PROGRAM dm2_rdds_nologs_child:dba
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
 FREE RECORD dyn_ui_search
 RECORD dyn_ui_search(
   1 qual[*]
     2 pk_value = f8
     2 other = vc
 )
 IF (validate(drdm_sequence->qual[1].seq_val,- (1)) < 0)
  FREE RECORD drdm_sequence
  RECORD drdm_sequence(
    1 qual[*]
      2 seq_name = vc
      2 seq_val = f8
  )
 ENDIF
 IF (validate(dm2_rdds_rec->mode,"NONE")="NONE")
  FREE RECORD dm2_rdds_rec
  RECORD dm2_rdds_rec(
    1 mode = vc
    1 main_process = vc
  )
 ENDIF
 IF (validate(ui_query_rec->table_name,"NONE")="NONE")
  FREE RECORD ui_query_rec
  RECORD ui_query_rec(
    1 table_name = vc
    1 dom = vc
    1 usage = vc
    1 qual[*]
      2 qtype = vc
      2 where_clause = vc
      2 cqual[*]
        3 query_idx = i2
      2 other_pk_col[*]
        3 col_name = vc
  )
  FREE RECORD ui_query_eval_rec
  RECORD ui_query_eval_rec(
    1 qual[*]
      2 root_entity_attr = f8
      2 additional_attr = vc
  )
 ENDIF
 IF (validate(select_merge_translate_rec->type,"NONE")="NONE")
  FREE RECORD select_merge_translate_rec
  RECORD select_merge_translate_rec(
    1 type = vc
  )
 ENDIF
 DECLARE find_p_e_col(sbr_p_e_name=vc,sbr_p_e_col=i4) = vc
 DECLARE dm_translate(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc) = vc
 DECLARE dm_trans2(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc,sbr_src_ind=i2) = vc
 DECLARE dm_trans3(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=f8,sbr_src_ind=i2,sbr_pe_tbl_name=vc)
  = vc
 DECLARE insert_update_row(iur_temp_tbl_cnt=i4,iur_perm_col_cnt=i4) = i2
 DECLARE query_target(qt_temp_tbl_cnt=i4,qt_perm_col_cnt=i4) = f8 WITH public
 DECLARE merge_audit(action=vc,text=vc,audit_type=i4) = null
 DECLARE parse_statements(parser_cnt=i4) = null
 DECLARE insert_merge_translate(sbr_from=f8,sbr_to=f8,sbr_table=vc) = i2
 DECLARE select_merge_translate(sbr_f_value=vc,sbr_t_name=vc) = vc
 DECLARE del_chg_log(sbr_table_name=vc,sbr_log_type=vc,sbr_target_id=f8) = null
 DECLARE report_missing(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = vc
 DECLARE rdds_del_except(sbr_table_name=vc,sbr_value=f8) = null
 DECLARE version_exception(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = null
 DECLARE orphan_child_tab(sbr_table_name=vc,sbr_log_type=vc) = i2
 DECLARE dm2_rdds_get_tbl_alias(sbr_tbl_suffix=vc) = vc
 DECLARE dm2_get_rdds_tname(sbr_tname=vc) = vc
 DECLARE exec_ui_query(exec_tbl_cnt=i4,exec_perm_col_cnt=i4) = f8 WITH public
 DECLARE evaluate_exec_ui_query(sbr_current_qual=i4,eval_tbl_cnt=i4,eval_perm_col_cnt=i4) = f8 WITH
 public
 DECLARE insert_noxlat(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8,sbr_orphan_ind=i2) = i2
 DECLARE add_rs_values(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = i4
 DECLARE trigger_proc_call(tpc_table_name=vc,tpc_pk_where=vc,tpc_context=vc,tpc_col_name=vc,tpc_value
  =f8) = i2
 DECLARE filter_proc_call(fpc_table_name=vc,fpc_pk_where=vc) = i2
 DECLARE replace_carrot_symbol(rcs_string=vc) = vc
 SUBROUTINE query_target(qt_temp_tbl_cnt,qt_perm_col_cnt)
   DECLARE sbr_active_value = i2
   DECLARE sbr_effective_date = f8
   DECLARE sbr_end_effective_date = f8
   DECLARE sbr_returned_value = f8
   DECLARE sbr_cur_date = f8
   DECLARE sbr_rec_size = i4
   DECLARE sbr_null_beg_ind = i2
   DECLARE sbr_null_end_ind = i2
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET drdm_return_var = 0
   IF ((dm2_ref_data_doc->tbl_qual[qt_temp_tbl_cnt].merge_delete_ind=1))
    RETURN(- (3))
   ELSE
    SET dm_err->eproc = "Query Target"
    CALL echo("")
    CALL echo("")
    CALL echo("*******************QUERY TARGET***************************")
    CALL echo("")
    CALL echo("")
    SET sbr_rec_size = 1
    SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
    SET ui_query_rec->table_name = sbr_table_name
    SET ui_query_rec->usage = ""
    SET ui_query_rec->dom = "TO"
    SET ui_query_rec->qual[sbr_rec_size].qtype = "UIONLY"
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1))
     SET sbr_rec_size = (sbr_rec_size+ 1)
     SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
     SET sbr_active_value = cnvtreal(get_value(sbr_table_name,"ACTIVE_IND","FROM"))
     IF (sbr_active_value=1)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "ACTIVE"
     ELSE
      SET ui_query_rec->qual[sbr_rec_size].qtype = "INACTIVE"
     ENDIF
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
     SET sbr_null_beg_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      beg_col_name)
     SET sbr_null_end_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      end_col_name)
     IF (((sbr_null_beg_ind=1) OR (sbr_null_end_ind=1)) )
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind = 0
     ELSE
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      CALL parser(concat("set sbr_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name," go "),1)
      CALL parser(concat("set sbr_end_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name," go "),1)
      IF (sbr_effective_date <= sbr_cur_date
       AND sbr_end_effective_date >= sbr_cur_date)
       SET ui_query_rec->qual[sbr_rec_size].qtype = "EFFECTIVE"
      ELSE
       SET ui_query_rec->qual[sbr_rec_size].qtype = "END_EFFECTIVE"
      ENDIF
     ENDIF
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "COMBO"
      SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].cqual,2)
      SET ui_query_rec->qual[sbr_rec_size].cqual[1].query_idx = 2
      SET ui_query_rec->qual[sbr_rec_size].cqual[2].query_idx = 3
     ENDIF
    ENDIF
    SET sbr_returned_value = exec_ui_query(qt_temp_tbl_cnt,qt_perm_col_cnt)
    SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].other_pk_col,0)
    RETURN(sbr_returned_value)
   ENDIF
 END ;Subroutine
 SUBROUTINE exec_ui_query(exec_tbl_cnt,exec_perm_col_cnt)
   DECLARE sbr_while_loop = i2
   DECLARE sbr_done_select = i2
   DECLARE sbr_loop = i2
   DECLARE sbr_other_loop = i2
   DECLARE query_cnt = i4
   DECLARE sbr_eff_date = f8
   DECLARE sbr_end_eff_date = f8
   DECLARE sbr_cur_date = f8
   DECLARE query_return = f8
   DECLARE rs_tab_prefix = vc
   DECLARE sbr_domain = vc
   DECLARE add_ndx = i4
   DECLARE ndx_loop = i4
   DECLARE add_col_name = vc
   DECLARE add_d_type = vc
   DECLARE euq_ord_col = vc
   SET rs_tab_prefix = concat("RS_",dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].suffix)
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET euq_ord_col = ""
   FOR (sbr_loop = 1 TO size(ui_query_eval_rec->qual,5))
     SET ui_query_eval_rec->qual[sbr_loop].additional_attr = ""
   ENDFOR
   SET sbr_loop = 1
   SET sbr_done_select = 0
   IF ((ui_query_rec->dom="FROM"))
    SET sbr_domain = "FROM"
   ELSE
    SET sbr_domain = "TO"
   ENDIF
   WHILE (sbr_loop <= size(ui_query_rec->qual,5)
    AND sbr_done_select=0)
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET query_cnt = 0
     IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].merge_ui_query_ni=1))
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[1].frag = concat("select into 'NL:' dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
      ELSE
       SET drdm_parser->statement[1].frag = "select into 'NL:' "
      ENDIF
      SET drdm_parser->statement[2].frag = concat(" from ",value(ui_query_rec->table_name)," dc ",
       " where ")
      SET drdm_parser_cnt = 3
      FOR (drdm_loop_cnt = 1 TO exec_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].unique_ident_ind=1))
         SET no_unique_ident = 1
         IF (drdm_parser_cnt > 3)
          SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ENDIF
         SET drdm_col_name = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].
         column_name
         SET drdm_from_con = concat(rs_tab_prefix,"->",sbr_domain,"_values.",drdm_col_name)
         IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_null=1))
          IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type IN ("DQ8",
          "F8", "I4", "I2")))
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = NULL")
          ELSE
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
            " = null or ",drdm_col_name," = ' ')")
          ENDIF
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSEIF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_space=1))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
           " = ' ' or ",drdm_col_name," = null)")
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSE
          CASE (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type)
           OF "DQ8":
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
             " =  cnvtdatetime(",drdm_from_con,")")
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ELSE
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
             drdm_from_con)
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          ENDCASE
         ENDIF
        ENDIF
      ENDFOR
      IF (no_unique_ident=0)
       SET insert_update_reason = "There were no unique_ident_ind's for log_id "
       SET no_insert_update = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = concat(dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].
        custom_script,": There were no unique_ident_ind's")
       RETURN(- (2))
      ENDIF
      SET sbr_current_date = cnvtdatetime(curdate,curtime3)
      CASE (ui_query_rec->qual[sbr_loop].qtype)
       OF "UIONLY":
       OF patstring("ORDER*",0):
        SET ui_query_rec->qual[sbr_loop].where_clause = ""
       OF "ACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 1"
       OF "INACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 0"
       OF "EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,"<=  cnvtdatetime(sbr_cur_date) AND dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,">= cnvtdatetime(sbr_cur_date)")
       OF "END_EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,">=  cnvtdatetime(sbr_cur_date) OR dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,"<= cnvtdatetime(sbr_cur_date)")
       OF "COMBO":
        FOR (sbr_other_loop = 1 TO size(ui_query_rec->qual[sbr_loop].cqual,5))
          SET ui_query_rec->qual[sbr_loop].where_clause = concat(ui_query_rec->qual[sbr_loop].
           where_clause,ui_query_rec->qual[ui_query_rec->qual[sbr_loop].cqual[sbr_other_loop].
           query_idx].where_clause)
        ENDFOR
      ENDCASE
      IF ((ui_query_rec->qual[sbr_loop].where_clause != ""))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(ui_query_rec->qual[sbr_loop].
        where_clause)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF ((ui_query_rec->qual[sbr_loop].qtype="ORDER:*"))
       SET euq_ord_col = substring((findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)+ 1),(size(
         ui_query_rec->qual[sbr_loop].qtype) - findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)
        ),ui_query_rec->qual[sbr_loop].qtype)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ORDER BY dc.",euq_ord_col)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" head report",
       " stat = alterlist(ui_query_eval_rec->qual, 10)"," query_cnt = 0")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" detail query_cnt = query_cnt + 1 ")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "if (mod(query_cnt,10) = 1 and query_cnt != 1)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt + 9)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" endif")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
        "ui_query_eval_rec->qual[query_cnt]->root_entity_attr = dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF (size(ui_query_rec->qual[sbr_loop].other_pk_col,5) > 0)
       IF ((ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name != ""))
        SET add_col_name = ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name
        SET add_ndx = locateval(ndx_loop,1,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_cnt,
         add_col_name,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[ndx_loop].column_name)
        IF (add_ndx > 0)
         SET add_d_type = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[add_ndx].data_type
         IF ( NOT (add_d_type IN ("VC", "C*")))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = cnvtstring(dc.",add_col_name,")")
         ELSE
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = dc.",add_col_name)
         ENDIF
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" foot report",
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt)"," with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET query_return = - (1)
       SET sbr_done_select = 1
      ELSEIF ((query_return != - (1)))
       SET query_return = evaluate_exec_ui_query(query_cnt,exec_tbl_cnt,exec_perm_col_cnt)
      ENDIF
      IF ((((query_return=- (3))) OR (query_return >= 0)) )
       SET sbr_done_select = 1
      ELSE
       SET sbr_loop = (sbr_loop+ 1)
      ENDIF
     ENDIF
   ENDWHILE
   IF ((query_return=- (2))
    AND (ui_query_rec->usage != "VERSION"))
    SET insert_update_reason = "Multiple values returned with unique indicator query for log_id "
    SET no_insert_update = 1
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "NOMV06"
    SET drdm_mini_loop_status = "NOMV06"
    ROLLBACK
    CALL orphan_child_tab(sbr_table_name,"NOMV06")
    COMMIT
   ENDIF
   RETURN(query_return)
 END ;Subroutine
 SUBROUTINE evaluate_exec_ui_query(sbr_current_qual,eval_tbl_cnt,eval_perm_col_cnt)
   DECLARE sbr_eval_loop = i4
   DECLARE sbr_trans_val = vc
   DECLARE sbr_table_name = vc
   DECLARE sbr_root_entity_attr_val = f8
   DECLARE sbr_not_translated_count = i4
   DECLARE sbr_value_pos = i4
   DECLARE sbr_temp_pk_value = f8
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET sbr_eval_loop = 1
   SET sbr_not_translated_count = 0
   IF (sbr_current_qual=0)
    RETURN(- (3))
   ELSEIF (sbr_current_qual=1)
    IF ((((ui_query_rec->usage="VERSION")
     AND sbr_temp_pk_value != 0) OR ((ui_query_rec->usage != "VERSION"))) )
     SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
     SET select_merge_translate_rec->type = "TO"
     SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_trans_val="No Trans")
      SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
      RETURN(sbr_root_entity_attr_val)
     ELSE
      IF ((ui_query_rec->usage="VERSION"))
       SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
       RETURN(sbr_root_entity_attr_val)
      ELSE
       RETURN(- (3))
      ENDIF
     ENDIF
    ELSE
     SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
     RETURN(sbr_root_entity_attr_val)
    ENDIF
   ELSE
    IF ((ui_query_rec->usage="VERSION"))
     RETURN(- (2))
    ELSE
     FOR (sbr_eval_loop = 1 TO sbr_current_qual)
       SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
       SET select_merge_translate_rec->type = "TO"
       SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
       IF (sbr_trans_val="No Trans")
        SET sbr_not_translated_count = (sbr_not_translated_count+ 1)
        SET sbr_val_pos = sbr_eval_loop
       ENDIF
     ENDFOR
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_not_translated_count=0)
      RETURN(- (3))
     ELSEIF (sbr_not_translated_count=1)
      SET current_qual = ui_query_eval_rec->qual[sbr_val_pos].root_entity_attr
      RETURN(current_qual)
     ELSE
      RETURN(- (2))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_update_row(iur_temp_tbl_cnt,iur_perm_col_cnt)
   DECLARE first_where = i2
   DECLARE active_in = i2
   DECLARE drdm_col_name = vc
   DECLARE drdm_table_name = vc
   DECLARE p_tab_ind = i2
   DECLARE sbr_data_type = vc
   DECLARE no_update_ind = i2
   DECLARE non_key_ind = i2
   DECLARE pk_cnt = i4
   DECLARE iur_tgt_pk_where = vc
   DECLARE iur_del_loop = i4
   DECLARE iur_del_ind = i2
   DECLARE iur_child_loop = i4
   DECLARE iur_child_pk_cnt = i4
   DECLARE src_pk_where = vc
   DECLARE iur_tbl_alias = vc
   SET iur_del_ind = 0
   SET drdm_table_name = concat("RS_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)
   SET dm_err->eproc = concat("Inserting or Updating Row ",cnvtstring(drdm_chg->log[drdm_log_loop].
     log_id))
   CALL echo("")
   CALL echo("")
   CALL echo("*******************INSERTING OR UPDATING ROW******************")
   CALL echo("")
   CALL echo("")
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1)
    AND (drdm_chg->log[drdm_log_loop].md_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," in (select ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          SET iur_child_pk_cnt = (iur_child_pk_cnt+ 1)
          IF (iur_child_pk_cnt=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" c.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name)
          ENDIF
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].table_name," c where ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1)
         )
          IF (iur_del_ind=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
            "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
            column_name,
            "))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
            suffix,"->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop]
            .column_name,
            ")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = 1
         ENDIF
       ENDFOR
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
           tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = ") with nocounter go"
       IF (iur_del_ind=1
        AND iur_child_pk_cnt=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
     SET iur_child_pk_cnt = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   SET iur_del_ind = 0
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," = ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          IF (iur_del_ind >= 1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,"))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,notrim(rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = (iur_del_ind+ 1)
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = " with nocounter go"
       IF (iur_del_ind=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   IF (nodelete_ind=1)
    RETURN(1)
   ENDIF
   SET p_tab_ind = 0
   SET first_where = 0
   SET no_update_ind = 0
   SET short_string = ""
   SET drdm_parser->statement[1].frag = concat("select into 'NL:' from ",value(dm2_ref_data_doc->
     tbl_qual[iur_temp_tbl_cnt].table_name)," dc where ")
   SET drdm_parser_cnt = 2
   IF ((((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0)) OR ((dm2_ref_data_doc->
   tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))) )
    SET pk_cnt = 0
    FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
       SET pk_cnt = (pk_cnt+ 1)
       SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
       data_type
       SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
        column_name)
       SET drdm_from_con = concat(drdm_table_name,"->To_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where," and ")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
        AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
        IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
          " = null or dc.",drdm_col_name," = ' ')")
        ENDIF
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF (sbr_data_type="DQ8")
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
         " = cnvtdatetime(",drdm_from_con,")")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
         " = null or dc.",drdm_col_name," = ' ')")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSE
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
         drdm_from_con)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ELSE
       SET non_key_ind = 1
      ENDIF
    ENDFOR
    IF (pk_cnt=0)
     SET nodelete_ind = 1
     SET dm_err->emsg = "The table has no primary_key information, check to see if it is mergeable."
    ELSE
     SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
     CALL parse_statements(drdm_parser_cnt)
    ENDIF
   ENDIF
   IF (curqual > 0
    AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].insert_only_ind=1))
     CALL merge_audit("FAILREASON",
      "This table is marked as insert only, so this row will not be updated.",3)
     RETURN(0)
    ELSE
     IF (new_seq_ind=1
      AND drdm_override_ind=0)
      SET no_update_ind = 1
      CALL merge_audit("FAILREASON",
       "A new sequence was created for the table, but the sequence value already exists in the target table",
       3)
      SET nodelete_ind = 1
      SET drdm_mini_loop_status = "NOMV99"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON4859"))
       IF (non_key_ind=1)
        SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].table_name,"  dc set ")
        SET drdm_parser_cnt = 2
        FOR (update_loop = 1 TO iur_perm_col_cnt)
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].db_data_type !=
          "*LOB"))
           IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].pk_ind=0))
            IF (drdm_parser_cnt > 2)
             SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
             SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
            ENDIF
            SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].
            column_name
            SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
            IF (drdm_col_name="ACTIVE_IND")
             IF (drdm_active_ind_merge=0)
              CALL parser(concat("set active_in = ",drdm_table_name,"->from_values.active_ind go"),1)
              IF (((active_in=0) OR ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[
              update_loop].exception_flg=8))) )
               IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
                AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y")
               )
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
               ELSE
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = active_in"
               ENDIF
              ELSE
               IF (((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt - pk_cnt)=1))
                SET no_update_ind = 1
               ELSE
                IF (drdm_parser_cnt=2)
                 SET drdm_parser_cnt = (drdm_parser_cnt - 1)
                ELSE
                 SET drdm_parser_cnt = (drdm_parser_cnt - 2)
                ENDIF
               ENDIF
              ENDIF
             ELSE
              IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
               AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
               SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
              ELSE
               SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.ACTIVE_IND = ",
                drdm_from_con)
              ENDIF
             ENDIF
            ELSEIF (drdm_col_name="UPDT_TASK")
             SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
            ELSEIF (drdm_col_name="UPDT_DT_TM")
             SET drdm_parser->statement[drdm_parser_cnt].frag =
             " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
            ELSEIF (drdm_col_name="UPDT_CNT")
             SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = dc.UPDT_CNT + 1"
            ELSE
             IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
              AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = null")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].data_type=
             "DQ8"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = cnvtdatetime(",drdm_from_con,")")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_space=
             1))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '"
               )
             ELSE
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
               drdm_from_con)
             ENDIF
            ENDIF
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ENDIF
          ENDIF
        ENDFOR
        IF (no_update_ind=0)
         SET drdm_parser->statement[drdm_parser_cnt].frag = " where "
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = iur_tgt_pk_where
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
        SET current_merges = (current_merges+ 1)
        SET child_merge_audit->num[current_merges].action = "UPDATE"
        SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt
        ].table_name
       ENDIF
       SET ins_ind = 0
      ELSE
       SET p_tab_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ins_ind = 1
    SET drdm_parser->statement[1].frag = concat("insert into ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," dc set ")
    SET drdm_parser_cnt = 2
    FOR (insert_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type != "*LOB")
      )
       SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].
       column_name
       SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF (drdm_col_name="UPDT_TASK")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
       ELSEIF (drdm_col_name="UPDT_DT_TM")
        SET drdm_parser->statement[drdm_parser_cnt].frag =
        " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
       ELSEIF (drdm_col_name="UPDT_CNT")
        SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = 0"
       ELSE
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_null=1)
         AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].nullable="Y"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null ")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].data_type="DQ8"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
          " = cnvtdatetime(",drdm_from_con,")")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_space=1))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
          drdm_from_con)
        ENDIF
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
    ENDFOR
    SET current_merges = (current_merges+ 1)
    SET child_merge_audit->num[current_merges].action = "INSERT"
    SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
    table_name
   ENDIF
   SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
   IF (p_tab_ind=0
    AND no_update_ind=0)
    IF (ins_ind=0
     AND non_key_ind=0)
     CALL echo("No update will be done on this table because there are no non-key columns")
    ELSE
     CALL parse_statements(drdm_parser_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))
      SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
       iur_temp_tbl_cnt].table_name," dc set ")
      SET drdm_parser_cnt = 2
      FOR (insert_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type="*LOB"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name," = (select ")
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ",dm2_rdds_get_tbl_alias(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix),".",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name)
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_get_rdds_tname(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name)," ",dm2_rdds_get_tbl_alias(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)," where ")
      SET iur_tbl_alias = concat(" ",dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].suffix))
      SET src_pk_where = " "
      SET pk_cnt = 0
      SET iur_perm_col_cnt = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt
      FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
         SET pk_cnt = (pk_cnt+ 1)
         SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
         data_type
         SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop
          ].column_name)
         SET drdm_from_con = concat(drdm_table_name,"->from_values.",drdm_col_name)
         IF (pk_cnt > 1)
          SET iur_tgt_pk_where = concat(src_pk_where," and ")
         ENDIF
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
          IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
           SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = null")
          ELSE
           SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
            " = null or ",iur_tbl_alias,".",drdm_col_name," = ' ')")
          ENDIF
         ELSEIF (sbr_data_type="DQ8")
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = cnvtdatetime(",
           drdm_from_con,")")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
          SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
           iur_tbl_alias,".",drdm_col_name," = ' ')")
         ELSE
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = ",
           drdm_from_con)
         ENDIF
        ENDIF
      ENDFOR
      IF (pk_cnt=0)
       SET nodelete_ind = 1
       SET dm_err->emsg =
       "The table has no primary_key information, check to see if it is mergeable."
       RETURN(1)
      ENDIF
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(src_pk_where,")")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" where ",iur_tgt_pk_where,
       " with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
     ENDIF
    ENDIF
   ENDIF
   FREE SET first_where
   FREE SET p_tab_ind
   FREE SET active_in
   FREE SET drdm_table_name
   IF (nodelete_ind=1)
    IF ((dm_err->ecode=288))
     SET drdm_mini_loop_status = "NOMV02"
     CALL merge_audit("FAILREASON","The row recieved a constraint violation when merged into target",
      1)
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV02")
     COMMIT
    ELSEIF ((dm_err->ecode=284))
     IF (findstring("ORA-20500:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV01"
      CALL merge_audit("FAILREASON","The row is related to a person that has been combined away",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV01")
      COMMIT
     ENDIF
     IF (findstring("ORA-20100:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV08"
      CALL merge_audit("FAILREASON","The row is trying to update the default row in target",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
      COMMIT
     ENDIF
    ENDIF
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    SET dm2_ref_data_reply->error_ind = 1
    RETURN(1)
   ELSE
    SET drdm_chg->log[drdm_log_loop].reprocess_ind = 0
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE parse_statements(drdm_parser_cnt)
   FOR (parse_loop = 1 TO drdm_parser_cnt)
     IF (parse_loop=drdm_parser_cnt)
      SET drdm_go_ind = 1
     ELSE
      SET drdm_go_ind = 0
     ENDIF
     IF ((drdm_parser->statement[parse_loop].frag=""))
      CALL echo("")
      CALL echo("")
      CALL echo("A DYNAMIC STATEMENT WAS IMPROPERLY LOADED")
      CALL echo("")
      CALL echo("")
     ENDIF
     CALL parser(drdm_parser->statement[parse_loop].frag,drdm_go_ind)
     SET drdm_parser->statement[parse_loop].frag = ""
     IF (check_error(dm_err->eproc)=1)
      IF (findstring("ORA-20100:",dm_err->emsg) > 0)
       SET drdm_mini_loop_status = "NOMV08"
       CALL merge_audit("FAILREASON",
        "The row is trying to update/insert/delete the default row in target",1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET nodelete_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE dm_translate(sbr_tbl_name,sbr_col_name,sbr_from_val)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   SET to_val = "NOXLAT"
   SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
    index_var].table_name)
   SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[index_var].column_name)
   SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
    col_qual[dt_temp_col_cnt].root_entity_name)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE dm_trans2(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
     index_var].table_name)
    SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
     dt_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].exception_flg=1))
     RETURN(sbr_from_val)
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name IN (
     "", " ")))
      SET to_val = "BADLOG"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name =
       "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
       col_qual[dt_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val != "No Trans"
       AND findstring(".0",to_val)=0)
       SET to_val = concat(to_val,".0")
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = sbr_from_val
   ENDIF
   SET dt_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[index_var]
    .table_name)
   IF ((dm2_ref_data_doc->tbl_qual[dt_root_tbl_cnt].mergeable_ind=0))
    SET to_val = "NOMV04"
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE select_merge_translate(sbr_f_value,sbr_t_name)
   DECLARE sbr_return_val = vc
   DECLARE drdm_dmt_scr = vc
   DECLARE except_tab = vc
   DECLARE smt_loop = i4
   DECLARE smt_tbl_pos = i4
   DECLARE smt_seq_name = vc
   DECLARE smt_seq_num = f8
   DECLARE smt_cur_table = i4
   DECLARE smt_seq_loop = i4
   DECLARE smt_seq_val = i4
   DECLARE smt_xlat_env_tgt_id = f8
   SET smt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET sbr_return_val = "No Trans"
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET smt_tbl_pos = locateval(smt_loop,1,dm2_ref_data_doc->tbl_cnt,sbr_t_name,dm2_ref_data_doc->
    tbl_qual[smt_loop].table_name)
   IF (smt_tbl_pos=0)
    SET smt_cur_table = temp_tbl_cnt
    SET smt_tbl_pos = fill_rs("TABLE",sbr_t_name)
    SET temp_tbl_cnt = smt_cur_table
   ENDIF
   IF (smt_tbl_pos=0)
    RETURN(sbr_return_val)
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].skip_seqmatch_ind != 1))
    IF (sbr_t_name="REF_TEXT_RELTN")
     SET smt_seq_name = "REFERENCE_SEQ"
    ELSE
     FOR (smt_loop = 1 TO dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].pk_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].root_entity_name=sbr_t_name))
        SET smt_seq_name = dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].sequence_name
       ENDIF
     ENDFOR
    ENDIF
    IF (smt_seq_name="")
     CALL disp_msg("No Valid sequence was found",dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = "No Valid sequence was found"
     SET dm_err->err_ind = 0
     CALL merge_audit("FAILREASON","No Valid sequence was found",3)
     RETURN(sbr_return_val)
    ENDIF
    SET smt_seq_val = locateval(smt_seq_loop,1,size(drdm_sequence->qual,5),smt_seq_name,drdm_sequence
     ->qual[smt_seq_loop].seq_name)
    IF (smt_seq_val=0)
     SELECT
      IF ((dm2_rdds_rec->mode="OS"))
       WHERE d.info_domain="MERGE00SEQMATCH"
        AND d.info_name=smt_seq_name
      ELSE
       WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
         cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
        AND d.info_name=smt_seq_name
      ENDIF
      INTO "NL:"
      FROM dm_info d
      DETAIL
       smt_seq_num = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
     IF (((curqual=0) OR ((smt_seq_num=- (1)))) )
      SET smt_cur_table = temp_tbl_cnt
      EXECUTE dm2_find_sequence_match smt_seq_name, dm2_ref_data_doc->env_source_id
      SET temp_tbl_cnt = smt_cur_table
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
       SET dm_err->err_ind = 1
       SET drdm_error_ind = 1
       RETURN(sbr_return_val)
      ENDIF
      SELECT
       IF ((dm2_rdds_rec->mode="OS"))
        WHERE d.info_domain="MERGE00SEQMATCH"
         AND d.info_name=smt_seq_name
       ELSE
        WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
          cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
         AND d.info_name=smt_seq_name
       ENDIF
       INTO "NL:"
       FROM dm_info d
       DETAIL
        smt_seq_num = d.info_number
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
      ENDIF
      IF (curqual=0)
       SET drdm_error_out_ind = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = "A sequence match could not be found in DM_INFO"
       CALL disp_msg("A sequence match could not be found in DM_INFO",dm_err->logfile,1)
       RETURN("No Trans")
      ENDIF
     ENDIF
     SET stat = alterlist(drdm_sequence->qual,(size(drdm_sequence->qual,5)+ 1))
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_name = smt_seq_name
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_val = smt_seq_num
    ELSE
     SET smt_seq_num = drdm_sequence->qual[smt_seq_val].seq_val
    ENDIF
   ELSE
    SET smt_seq_num = 0
   ENDIF
   IF (cnvtreal(sbr_f_value) <= smt_seq_num)
    RETURN(sbr_f_value)
   ELSE
    SELECT
     IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSE
     ENDIF
     INTO "NL:"
     FROM dm_merge_translate dm
     DETAIL
      IF ((select_merge_translate_rec->type="TO"))
       sbr_return_val = cnvtstring(dm.from_value)
      ELSE
       sbr_return_val = cnvtstring(dm.to_value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
    ENDIF
    IF (sbr_return_val="No Trans"
     AND (global_mover_rec->loop_back_ind=1))
     SET source_table_name = dm2_get_rdds_tname("DM_MERGE_TRANSLATE")
     SELECT
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSE
      ENDIF
      INTO "NL:"
      FROM (parser(source_table_name) dm)
      DETAIL
       IF ((select_merge_translate_rec->type != "TO"))
        sbr_return_val = cnvtstring(dm.from_value)
       ELSE
        sbr_return_val = cnvtstring(dm.to_value)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (sbr_return_val != "No Trans")
    CALL rdds_del_except(sbr_t_name,cnvtreal(sbr_f_value))
   ENDIF
   RETURN(sbr_return_val)
 END ;Subroutine
 SUBROUTINE del_chg_log(sbr_table_name,sbr_log_type,sbr_target_id)
   FREE RECORD dcl_rec_parse
   RECORD dcl_rec_parse(
     1 qual[*]
       2 parse_stmts = vc
   )
   SET stat = alterlist(dcl_rec_parse->qual,3)
   DECLARE sbr_tname_flex = vc
   DECLARE sbr_flex_pos = i4
   DECLARE sbr_look_ahead = vc WITH noconstant(build(global_mover_rec->refchg_buffer,"MIN"))
   SET drdm_any_translated = 1
   SET dm_err->eproc = "Updating DM_CHG_LOG Table drdm_chg->log[drdm_log_loop].log_id"
   SET update_cnt = 0
   SET sbr_tname_flex = dm2_get_rdds_tname("DM_CHG_LOG")
   SET dcl_rec_parse->qual[1].parse_stmts = concat("select into 'nl:' from ",sbr_tname_flex)
   SET dcl_rec_parse->qual[2].parse_stmts = " d where log_id = drdm_chg->log[drdm_log_loop].log_id"
   SET dcl_rec_parse->qual[3].parse_stmts = " detail update_cnt = d.updt_cnt with nocounter go"
   EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
   ENDIF
   SET stat = alterlist(dcl_rec_parse->qual,0)
   SET stat = alterlist(dcl_rec_parse->qual,8)
   IF ((((update_cnt=drdm_chg->log[drdm_log_loop].updt_cnt)) OR (sbr_log_type="REFCHG")) )
    IF ((drdm_chg->log[drdm_log_loop].par_location > 0))
     SET sbr_flex_pos = drdm_chg->log[drdm_log_loop].par_location
    ELSE
     SET sbr_flex_pos = drdm_log_loop
    ENDIF
    SET dcl_rec_parse->qual[1].parse_stmts = concat(" update into ",sbr_tname_flex,
     " d1, (dummyt d with seq = size(drdm_pair_info->qual)) ")
    SET dcl_rec_parse->qual[2].parse_stmts = " set d1.log_type = sbr_log_type, "
    SET dcl_rec_parse->qual[3].parse_stmts = " d1.rdbhandle = NULL, "
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[4].parse_stmts = concat(
      " d1.updt_dt_tm = cnvtlookahead(sbr_look_ahead, cnvtdatetime(curdate,curtime3)),")
    ELSE
     SET dcl_rec_parse->qual[4].parse_stmts = "d1.updt_dt_tm = cnvtdatetime(curdate,curtime3),"
    ENDIF
    SET dcl_rec_parse->qual[5].parse_stmts = concat(" d1.updt_cnt = d1.updt_cnt + 1 plan d where",
     " drdm_pair_info->qual[d.seq].log_id > 0 ")
    SET dcl_rec_parse->qual[6].parse_stmts = concat(" join d1 where d1.log_id = ",
     " drdm_pair_info->qual[d.seq].log_id")
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[7].parse_stmts = " and d1.log_type = 'PROCES'"
    ELSE
     SET dcl_rec_parse->qual[7].parse_stmts = concat(" and d1.updt_cnt = ",
      " drdm_pair_info->qual[d.seq].updt_cnt")
    ENDIF
    SET dcl_rec_parse->qual[8].parse_stmts = " with nocounter go"
    EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    SET nodelete_msg = concat("Could not process log_id ",trim(cnvtstring(drdm_chg->log[drdm_log_loop
       ].log_id)),
     " because it has been updated since the mover picked it up. It will be merged next pass.")
    CALL echo("")
    CALL echo("")
    CALL echo(nodelete_msg)
    CALL echo("")
    CALL echo("")
    CALL merge_audit("FAILREASON",nodelete_msg,1)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE insert_merge_translate(sbr_from,sbr_to,sbr_table)
   DECLARE imt_seq_name = vc
   DECLARE imt_seq_num = f8
   DECLARE imt_seq_loop = i4
   DECLARE imt_seq_cnt = i4
   DECLARE imt_rs_cnt = i4
   DECLARE imt_return = i2
   DECLARE imt_except_tab = vc
   DECLARE imt_pk_pos = i4
   DECLARE imt_xlat_env_tgt_id = f8
   SET imt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET imt_return = 0
   SET dm_err->eproc = "Inserting Translation"
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind=0))
    FOR (imt_seq_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,5))
      IF ((sbr_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].root_entity_name
      )
       AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].pk_ind=1))
       SET imt_pk_pos = imt_seq_loop
       SET imt_seq_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].
       sequence_name
      ENDIF
    ENDFOR
    SET imt_seq_cnt = locateval(imt_seq_loop,1,size(drdm_sequence->qual,5),imt_seq_name,drdm_sequence
     ->qual[imt_seq_loop].seq_name)
    SET imt_seq_num = drdm_sequence->qual[imt_seq_cnt].seq_val
    IF (sbr_to < imt_seq_num)
     SET imt_return = 1
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM dm_merge_translate dmt
    WHERE dmt.to_value=sbr_to
     AND concat(dmt.table_name,"")=sbr_table
     AND (dmt.env_source_id=dm2_ref_data_doc->env_source_id)
     AND dmt.env_target_id=imt_xlat_env_tgt_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET dm_err->err_ind = 0
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET imt_return = 1
   ENDIF
   IF (imt_return=0)
    INSERT  FROM dm_merge_translate dm
     SET dm.from_value = sbr_from, dm.to_value = sbr_to, dm.table_name = sbr_table,
      dm.env_source_id = dm2_ref_data_doc->env_source_id, dm.status_flg = drdm_chg->log[drdm_log_loop
      ].status_flg, dm.log_id = drdm_chg->log[drdm_log_loop].log_id,
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.env_target_id = imt_xlat_env_tgt_id
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     IF (nvp_commit_ind=1
      AND (global_mover_rec->one_pass_ind=0))
      COMMIT
     ENDIF
    ENDIF
    CALL rdds_del_except(sbr_table,sbr_from)
   ELSE
    ROLLBACK
    SET imt_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
    IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND (d.column_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name)
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
    IF (curqual=0)
     IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.from_value = sbr_from,
        d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ELSE
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.column_name = dm2_ref_data_doc->
        tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
        d.from_value = sbr_from, d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     COMMIT
    ENDIF
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET fail_merges = (fail_merges+ 1)
    SET fail_merge_audit->num[fail_merges].action = "FAILREASON"
    SET fail_merge_audit->num[fail_merges].text = "Preventing a 2 into 1 translation"
    CALL merge_audit(fail_merge_audit->num[fail_merges].action,fail_merge_audit->num[fail_merges].
     text,1)
    IF (drdm_error_out_ind=1)
     ROLLBACK
    ENDIF
   ENDIF
   RETURN(imt_return)
 END ;Subroutine
 SUBROUTINE find_p_e_col(sbr_p_e_name,sbr_p_e_col)
   DECLARE p_e_name = vc
   DECLARE r_e_name = vc
   DECLARE p_e_col = vc
   DECLARE tbl_loop = i4
   DECLARE kickout = i4
   DECLARE p_e_tbl_pos = i4
   DECLARE p_e_col_pos = i4
   DECLARE p_e_where_str = vc
   DECLARE pk_pos = i4
   DECLARE temp_name = vc
   DECLARE mult_cnt = i4
   DECLARE pk_num = i4
   DECLARE good_pk = i4
   DECLARE pk_name = vc
   DECLARE id_ind = i2
   DECLARE info_alias = vc
   DECLARE i_domain = vc
   DECLARE i_name = vc
   DECLARE p_e_dummy_cnt = i4
   DECLARE temp_r_e_name = vc
   SET p_e_name = "INVALIDTABLE"
   SET r_e_name = sbr_p_e_name
   SET info_alias = ""
   SET id_ind = 0
   SET pk_num = 0
   SET pk_name = ""
   SET good_pk = 0
   WHILE (p_e_name != r_e_name)
     SET p_e_name = r_e_name
     SET r_e_name = "INVALIDTABLE"
     SET pk_pos = 0
     SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[tbl_loop]
      .tbl_name)
     IF (pk_pos=0)
      SELECT INTO "NL:"
       FROM dtable d
       WHERE d.table_name=p_e_name
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
       SET i_name = concat(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_p_e_col].
        parent_entity_col,":",p_e_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain="RDDS_PE_ABBREVIATIONS"
         AND d.info_name=p_e_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=i_domain
         AND d.info_name=i_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       IF (info_alias="")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
        CALL echo("Parent_entity_col could not be found")
       ELSE
        SET p_e_name = info_alias
        SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[
         tbl_loop].tbl_name)
        IF (pk_pos=0)
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
         CALL echo("Parent_entity_col could not be found")
        ENDIF
       ENDIF
      ELSE
       CALL echo(concat("The following table is activity: ",p_e_name))
       SET p_e_name = "INVALIDTABLE"
       SET r_e_name = p_e_name
      ENDIF
     ENDIF
     IF (pk_pos != 0)
      IF ((dguc_reply->dtd_hold[tbl_loop].pk_cnt > 1))
       FOR (mult_cnt = 1 TO dguc_reply->dtd_hold[tbl_loop].pk_cnt)
         IF ((((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID")) OR ((((dguc_reply->
         dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*CD")) OR ((dguc_reply->dtd_hold[tbl_loop].
         pk_hold[mult_cnt].pk_name="CODE_VALUE"))) )) )
          IF ((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID"))
           SET id_ind = 1
          ENDIF
          SET pk_num = (pk_num+ 1)
          SET good_pk = mult_cnt
         ENDIF
       ENDFOR
       IF (pk_num > 1)
        IF (id_ind=1)
         CALL echo("This Parent_Entity Table has more than a single Primary Key")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
        ENDIF
       ELSE
        SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
       ENDIF
      ELSE
       SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[1].pk_name
      ENDIF
      IF (p_e_name != "INVALIDTABLE")
       SET p_e_col = pk_name
       SET p_e_tbl_pos = 0
       SET p_e_tbl_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_cnt,p_e_name,dm2_ref_data_doc->
        tbl_qual[tbl_loop].table_name)
       IF (p_e_tbl_pos=0)
        SET p_e_dummy_cnt = temp_tbl_cnt
        SET p_e_tbl_pos = fill_rs("TABLE",p_e_name)
        SET temp_tbl_cnt = p_e_dummy_cnt
        IF (p_e_tbl_pos=0)
         CALL echo("Information not found for table level meta-data")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET temp_r_e_name = r_e_name
         FOR (p_e_dummy_cnt = 1 TO dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt)
           IF ((dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].column_name=p_e_col))
            SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].
            root_entity_name
           ENDIF
         ENDFOR
         IF (temp_r_e_name=r_e_name)
          CALL echo("Information not found for table level meta-data")
          SET p_e_name = "INVALIDTABLE"
          SET r_e_name = p_e_name
         ENDIF
        ENDIF
       ENDIF
       IF (p_e_tbl_pos != 0)
        SET p_e_col_pos = 0
        SET p_e_col_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt,
         p_e_col,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[tbl_loop].column_name)
        IF (p_e_col_pos=0)
         CALL echo("Information not found in dm_columns_doc for column")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_col_pos].
         root_entity_name
        ENDIF
       ENDIF
       SET kickout = (kickout+ 1)
       IF (kickout=5)
        CALL echo("Searched through 5 Parent_entity_columns")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF (p_e_name="INVALIDTABLE")
    ROLLBACK
    SET drdm_mini_loop_status = "NOMV99"
    CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV99")
    COMMIT
   ENDIF
   RETURN(p_e_name)
 END ;Subroutine
 SUBROUTINE merge_audit(action,text,audit_type)
   DECLARE aud_seq = i4
   DECLARE ma_log_id = f8
   DECLARE ma_next_seq = f8
   DECLARE ma_del_ind = i2
   DECLARE ma_table_name = vc
   IF (drdm_log_level=1
    AND  NOT (action IN ("INSERT", "UPDATE", "FAILREASON", "BATCH END")))
    RETURN(null)
   ELSE
    SET ma_del_ind = 0
    SET ma_log_id = drdm_chg->log[drdm_log_loop].log_id
    IF (temp_tbl_cnt=0)
     SET ma_table_name = "NONE"
    ELSE
     SET ma_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     ROLLBACK
    ENDIF
    SELECT INTO "NL:"
     y = seq(dm_merge_audit_seq,nextval)
     FROM dual
     DETAIL
      ma_next_seq = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET drdm_error_out_ind = 1
    ELSE
     UPDATE  FROM dm_chg_log_audit dm
      SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
       dm.text = text, dm.table_name = ma_table_name, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE dm.dm_chg_log_audit_id=ma_next_seq
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET drdm_error_out_ind = 1
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_chg_log_audit dm
       SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
        dm.text = text, dm.table_name = ma_table_name, dm.dm_chg_log_audit_id = ma_next_seq,
        dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET drdm_error_out_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     IF (drdm_error_out_ind=0)
      COMMIT
     ENDIF
    ENDIF
    RETURN(1)
   ENDIF
   FREE SET aud_seq
   FREE SET ma_log_id
 END ;Subroutine
 SUBROUTINE report_missing(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   DECLARE missing_cnt = i4
   DECLARE source_tab_name = vc
   DECLARE insert_log_type = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET source_tab_name = dm2_get_rdds_tname(sbr_table_name)
   SET except_log_type = "NOXLAT"
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
     IF (sbr_table_name="DCP_FORMS_REF")
      CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
     ELSEIF (sbr_table_name="DCP_SECTION_REF")
      CALL parser(" where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",
       0)
     ELSE
      CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
     ENDIF
     CALL parser(" with nocounter go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF (curqual=0)
       SET except_log_type = "ORPHAN"
       INSERT  FROM (parser(except_tab) d)
        SET d.log_type = "ORPHAN", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
         d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET nodelete_ind = 1
        SET no_insert_update = 1
        SET drdm_error_out_ind = 1
        SET dm_err->err_ind = 0
       ENDIF
      ENDIF
     ENDIF
     SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
     IF (missing_cnt > 0)
      IF (except_log_type="ORPHAN")
       SET missing_xlats->qual[missing_cnt].orphan_ind = 1
       SET missing_xlats->qual[missing_cnt].processed_ind = 1
      ELSE
       SET missing_xlats->qual[missing_cnt].orphan_ind = 0
       SET missing_xlats->qual[missing_cnt].processed_ind = 0
      ENDIF
     ENDIF
     RETURN(except_log_type)
    ELSE
     IF (except_log_type IN ("ORPHAN", "OLDVER", "NOMV*"))
      RETURN(except_log_type)
     ELSE
      CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
      IF (sbr_table_name="DCP_FORMS_REF")
       CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
      ELSEIF (sbr_table_name="DCP_SECTION_REF")
       CALL parser(
        " where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",0)
      ELSE
       CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
      ENDIF
      CALL parser(" with nocounter go",1)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET nodelete_ind = 1
       SET no_insert_update = 1
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
      ELSE
       IF (curqual=0)
        UPDATE  FROM (parser(except_tab) d)
         SET d.log_type = "ORPHAN"
         WHERE d.table_name=sbr_table_name
          AND d.from_value=sbr_value
          AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET nodelete_ind = 1
         SET no_insert_update = 1
         SET drdm_error_out_ind = 1
         SET dm_err->err_ind = 0
        ENDIF
        RETURN("ORPHAN")
       ELSE
        SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
        IF (missing_cnt > 0)
         SET missing_xlats->qual[missing_cnt].processed_ind = 0
         SET missing_xlats->qual[missing_cnt].orphan_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(except_log_type)
 END ;Subroutine
 SUBROUTINE version_exception(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   IF ((global_mover_rec->one_pass_ind=0))
    ROLLBACK
   ENDIF
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     INSERT  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
       d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ELSEIF (except_log_type != "OLDVER")
     UPDATE  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER"
      WHERE d.table_name=sbr_table_name
       AND d.column_name=sbr_column_name
       AND d.from_value=sbr_value
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE rdds_del_except(sbr_table_name,sbr_value)
   DECLARE except_tab = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   DELETE  FROM (parser(except_tab) d)
    WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
     AND d.table_name=sbr_table_name
     AND d.from_value=sbr_value
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_get_rdds_tname(sbr_tname)
   DECLARE return_tname = vc
   IF ((dm2_rdds_rec->mode="OS"))
    SET return_tname = concat(trim(substring(1,28,sbr_tname)),"$F")
   ELSEIF ((dm2_rdds_rec->main_process="EXTRACTOR")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = sbr_tname
   ELSEIF ((dm2_rdds_rec->main_process="MOVER")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = concat(dm2_ref_data_doc->pre_link_name,sbr_tname,dm2_ref_data_doc->
     post_link_name)
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "The main_process and/or mode were invalid"
   ENDIF
   RETURN(return_tname)
 END ;Subroutine
 SUBROUTINE orphan_child_tab(sbr_table_name,sbr_log_type)
   DECLARE oct_tab_cnt = i4
   DECLARE oct_tab_loop = i4
   DECLARE oct_col_cnt = i4
   DECLARE oct_pk_value = f8
   DECLARE oct_excptn_tab = vc
   DECLARE oct_col_name = vc
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name != sbr_table_name))
    SET oct_tab_cnt = locateval(oct_tab_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
     dm2_ref_data_doc->tbl_qual[oct_tab_loop].table_name)
    IF (oct_tab_cnt=0)
     SET dm_err->err_msg = "The table name could not be found in the meta-data record structure"
     SET nodelete_ind = 1
    ENDIF
   ELSE
    SET oct_tab_cnt = temp_tbl_cnt
   ENDIF
   SET oct_col_cnt = 0
   FOR (oct_tab_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual,5))
     IF ((dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].root_entity_name=
     sbr_table_name))
      SET oct_col_cnt = oct_tab_loop
     ENDIF
   ENDFOR
   IF (oct_col_cnt=0)
    RETURN(0)
   ENDIF
   CALL parser(concat("set oct_pk_value = RS_",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].suffix,
     "->from_values.",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name,
     " go "),1)
   SET oct_excptn_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     DETAIL
      oct_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.column_name=dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name)
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end select
    SET oct_col_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF (curqual=0)
    INSERT  FROM (parser(oct_excptn_tab) d)
     SET d.table_name = sbr_table_name, d.column_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].
      col_qual[oct_col_cnt].column_name, d.target_env_id = dm2_ref_data_doc->env_target_id,
      d.from_value = oct_pk_value, d.log_type = sbr_log_type
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    UPDATE  FROM (parser(oct_excptn_tab) d)
     SET d.log_type = sbr_log_type
     WHERE d.table_name=sbr_table_name
      AND d.column_name=oct_col_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tbl_alias(sbr_tbl_suffix)
   DECLARE sbr_rgta_rtn = vc
   SET sbr_rgta_rtn = build("t",sbr_tbl_suffix)
   RETURN(sbr_rgta_rtn)
 END ;Subroutine
 SUBROUTINE insert_noxlat(sbr_table_name,sbr_column_name,sbr_value,sbr_orphan_ind)
   DECLARE inx_except_tab = vc
   DECLARE inx_log_type = vc
   DECLARE inx_col_name = vc
   SET inx_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     DETAIL
      inx_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     WITH nocounter
    ;end select
    SET inx_col_name = sbr_column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    RETURN(1)
   ENDIF
   IF (curqual=0)
    IF (sbr_orphan_ind=1)
     SET inx_log_type = "ORPHAN"
    ELSE
     SET inx_log_type = "NOXLAT"
    ENDIF
    INSERT  FROM (parser(inx_except_tab) d)
     SET d.log_type = inx_log_type, d.table_name = sbr_table_name, d.column_name = sbr_column_name,
      d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE arv_loop = i4
   DECLARE arv_cnt = i4
   DECLARE arv_found = i2
   SET arv_cnt = size(missing_xlats->qual,5)
   SET arv_found = 0
   FOR (arv_loop = 1 TO arv_cnt)
     IF ((missing_xlats->qual[arv_loop].table_name=sbr_table_name)
      AND (missing_xlats->qual[arv_loop].column_name=sbr_column_name)
      AND (missing_xlats->qual[arv_loop].missing_value=sbr_value))
      SET arv_found = 1
     ENDIF
   ENDFOR
   IF (arv_found=0)
    SET arv_cnt = (arv_cnt+ 1)
    SET stat = alterlist(missing_xlats->qual,arv_cnt)
    SET missing_xlats->qual[arv_cnt].table_name = sbr_table_name
    SET missing_xlats->qual[arv_cnt].column_name = sbr_column_name
    SET missing_xlats->qual[arv_cnt].missing_value = sbr_value
    RETURN(arv_cnt)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_trans3(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind,sbr_pe_tbl_name)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt3_temp_tbl_cnt = i4
   DECLARE dt3_temp_col_cnt = i4
   DECLARE dt3_from_con = vc
   DECLARE dt3_domain = vc
   DECLARE dt3_name = vc
   DECLARE dt3_find = i4
   DECLARE dt3_pk_column = vc
   DECLARE dt3_pk_tab_name = vc
   DECLARE dt3_root_tbl_cnt = i4
   IF (sbr_from_val=0)
    RETURN("0")
   ENDIF
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt3_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->
     tbl_qual[index_var].table_name)
    SET dt3_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->
     tbl_qual[dt3_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].exception_flg=1))
     RETURN(cnvtstring(sbr_from_val))
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
      IN ("", " ")))
      IF (sbr_pe_tbl_name != ""
       AND sbr_pe_tbl_name != " ")
       SET dt3_pk_tab_name = find_p_e_col(sbr_pe_tbl_name,dt3_temp_col_cnt)
      ELSE
       SET dt3_pk_tab_name = "INVALIDTABLE"
       SET dt3_domain = concat("RDDS_PE_ABBREV:",sbr_tbl_name)
       SET dt3_name = concat(sbr_col_name,":",dt3_pk_tab_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=dt3_domain
         AND d.info_name=dt3_name
        DETAIL
         dt3_pk_tab_name = d.info_char
        WITH nocounter
       ;end select
      ENDIF
      IF (dt3_pk_tab_name != "")
       IF (dt3_pk_tab_name != "INVALIDTABLE")
        IF (dt3_pk_tab_name="PERSON")
         SET dt3_pk_tab_name = "PRSNL"
        ENDIF
        SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dt3_pk_tab_name)
       ENDIF
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dt3_pk_tab_name,dm2_ref_data_doc->
        tbl_qual[index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET dt3_find = locateval(dt3_find,1,size(dm2_ref_data_doc->tbl_qual,5),dt3_pk_tab_name,
         dm2_ref_data_doc->tbl_qual[dt3_find].table_name)
        FOR (dt3_i = 1 TO size(dm2_ref_data_doc->tbl_qual[dt3_find].col_qual,5))
          IF ((dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].pk_ind=1)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name=dm2_ref_data_doc->
          tbl_qual[dt3_find].col_qual[dt3_i].root_entity_attr)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].root_entity_name=
          dm2_ref_data_doc->tbl_qual[dt3_find].table_name))
           SET dt3_pk_column = dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name
          ENDIF
        ENDFOR
        SET to_val = report_missing(dt3_pk_tab_name,dt3_pk_column,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
        = "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dm2_ref_data_doc->tbl_qual[
       dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
        dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[
        index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_attr,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = cnvtstring(sbr_from_val)
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE trigger_proc_call(tpc_table_name,tpc_pk_where,tpc_context,tpc_col_name,tpc_value)
   DECLARE tpc_pk_where_vc = vc
   DECLARE tpc_pktbl_cnt = i4
   DECLARE tpc_tbl_loop = i4
   DECLARE tpc_error_ind = i2
   DECLARE tpc_col_loop = i4
   DECLARE tpc_col_pos = i4
   DECLARE tpc_suffix = vc
   DECLARE tpc_pk_proc_name = vc
   DECLARE tpc_proc_name = vc
   DECLARE tpc_f8_var = f8
   DECLARE tpc_i4_var = i4
   DECLARE tpc_vc_var = vc
   DECLARE tpc_row_cnt = i4
   DECLARE tpc_row_loop = i4
   DECLARE tpc_src_tab_name = vc
   DECLARE tpc_main_proc = vc
   DECLARE tpc_uo_tname = vc
   DECLARE tpc_pkw_tab_name = vc
   SET tpc_pk_where_vc = tpc_pk_where
   SET tpc_proc_name = ""
   SET tpc_pktbl_cnt = 0
   SET tpc_pktbl_cnt = locateval(tpc_tbl_loop,1,size(pk_where_parm->qual,5),tpc_table_name,
    pk_where_parm->qual[tpc_tbl_loop].table_name)
   IF (tpc_pktbl_cnt=0)
    SET tpc_pktbl_cnt = (size(pk_where_parm->qual,5)+ 1)
    SET stat = alterlist(pk_where_parm->qual,tpc_pktbl_cnt)
    SET pk_where_parm->qual[tpc_pktbl_cnt].table_name = tpc_table_name
    SET tpc_tbl_loop = 0
    SET tpc_pkw_tab_name = dm2_get_rdds_tname("DM_REFCHG_PKW_PARM")
    SELECT INTO "NL:"
     FROM (parser(tpc_pkw_tab_name) d)
     WHERE d.table_name=tpc_table_name
     ORDER BY parm_nbr
     DETAIL
      tpc_tbl_loop = (tpc_tbl_loop+ 1), stat = alterlist(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,
       tpc_tbl_loop), pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name = d
      .column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(tpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpc_table_name,
    dm2_ref_data_doc->tbl_qual[tpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",tpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       " = ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   SET tpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   IF (tpc_pk_where_vc="")
    SET tpc_pk_where_vc = concat("WHERE t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,".",
     tpc_col_name," = tpc_value")
   ENDIF
   IF (((size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5) != 1) OR ((pk_where_parm->qual[
   tpc_pktbl_cnt].col_qual[1].col_name != tpc_col_name))) )
    SET tpc_src_tab_name = dm2_get_rdds_tname(tpc_table_name)
    SET tpc_row_cnt = 0
    CALL parser("select into 'NL:' ",0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     IF (tpc_tbl_loop > 1)
      CALL parser(" , ",0)
     ENDIF
     CALL parser(concat("var",cnvtstring(tpc_tbl_loop)," = nullind(",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,")"),0)
    ENDFOR
    CALL parser(concat("from ",tpc_src_tab_name," ",tpc_suffix," ",
      tpc_pk_where_vc,
      " detail  tpc_row_cnt = tpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, tpc_row_cnt) "),0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name," = ",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name),0)
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(tpc_tbl_loop)),0)
    ENDFOR
    CALL parser("with nocounter go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
    IF (tpc_row_cnt=0)
     RETURN(0)
    ENDIF
   ELSE
    SET tpc_row_cnt = 1
    SET stat = alterlist(cust_cs_rows->qual,1)
    CALL parser(concat("set cust_cs_rows->qual[1].",tpc_col_name," = tpc_value go"),0)
   ENDIF
   SET tpc_pk_proc_name = concat("REFCHG_PK_WHERE_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SET tpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SELECT INTO "NL:"
    FROM (parser(tpc_uo_tname) u)
    WHERE u.object_name=patstring(tpc_pk_proc_name)
    DETAIL
     tpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   IF (tpc_proc_name="")
    SET dm_err->emsg = concat("A trigger procedure is not built: ",tpc_pk_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET tpc_main_proc = dm2_get_rdds_tname("PROC_REFCHG_INS_LOG")
    SET tpc_proc_name = dm2_get_rdds_tname(tpc_proc_name)
    FOR (tpc_row_loop = 1 TO tpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("RDB ASIS(^ BEGIN ",tpc_main_proc,"('",
       tpc_table_name,"',^)")
      SET drdm_parser->statement[2].frag = concat(" ASIS (^",tpc_proc_name,"('INS/UPD'^)")
      SET drdm_parser_cnt = 3
      FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
        CALL parser(concat("set tpc_col_nullind = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
          qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (tpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , NULL ^)")
         SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
          col_qual,5))].frag = concat("ASIS (^ , NULL ^)")
        ELSE
         SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_f8_var,15),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_f8_var,15),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ ,to_date('",format(
            tpc_f8_var,"DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ ,to_date('",format(tpc_f8_var,
            "DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set tpc_i4_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_i4_var),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_i4_var),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type="C*"))
          CALL parser(concat("declare tpc_c_var = C",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
            col_qual[tpc_col_pos].data_length," go"),1)
          CALL parser(concat("set tpc_c_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->qual[
            tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
         ELSE
          CALL parser(concat("set tpc_vc_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET tpc_vc_var = replace_carrot_symbol(tpc_vc_var)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "ASIS (^), dbms_utility.get_hash_value(^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^",tpc_proc_name,
       "('INS/UPD'^)")
      SET drdm_parser_cnt = ((drdm_parser_cnt+ 1)+ size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5
       ))
      SET drdm_parser->statement[drdm_parser_cnt].frag = "ASIS (^),0,1073741824.0), ^)"
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'REFCHG',0,",cnvtstring(
        reqinfo->updt_id,15),",",cnvtstring(reqinfo->updt_task),",",
       cnvtstring(reqinfo->updt_applctx),", ^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'",tpc_context,"',",
       cnvtstring(dm2_ref_data_doc->env_target_id,15),"); END; ^) GO")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET tpc_error_ind = 1
       SET tpc_row_loop = tpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(tpc_error_ind)
 END ;Subroutine
 SUBROUTINE filter_proc_call(fpc_table_name,fpc_pk_where)
   DECLARE fpc_loop = i4
   DECLARE fpc_filter_pos = i4
   DECLARE fpc_col_cnt = i4
   DECLARE fpc_tbl_loop = i4
   DECLARE fpc_col_loop = i4
   DECLARE fpc_col_pos = i4
   DECLARE fpc_error_ind = i2
   DECLARE fpc_suffix = vc
   DECLARE fpc_row_cnt = i4
   DECLARE fpc_row_loop = i4
   DECLARE fpc_col_nullind = i2
   DECLARE fpc_proc_name = vc
   DECLARE fpc_filter_proc_name = vc
   DECLARE fpc_src_tab_name = vc
   DECLARE fpc_f8_var = f8
   DECLARE fpc_i4_var = i4
   DECLARE fpc_vc_var = vc
   DECLARE fpc_return_var = i2
   DECLARE fpc_uo_tname = vc
   DECLARE fpc_filter_tab_name = vc
   SET fpc_filter_pos = locateval(fpc_loop,1,size(filter_parm->qual,5),fpc_table_name,filter_parm->
    qual[fpc_loop].table_name)
   IF (fpc_filter_pos=0)
    SET fpc_filter_pos = (size(filter_parm->qual,5)+ 1)
    SET fpc_col_cnt = 0
    SET fpc_filter_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_PARM")
    SELECT INTO "NL:"
     FROM (parser(fpc_filter_tab_name) d)
     WHERE d.table_name=fpc_table_name
      AND d.active_ind=1
     ORDER BY d.parm_nbr
     HEAD REPORT
      stat = alterlist(filter_parm->qual,fpc_filter_pos), filter_parm->qual[fpc_filter_pos].
      table_name = fpc_table_name
     DETAIL
      fpc_col_cnt = (fpc_col_cnt+ 1), stat = alterlist(filter_parm->qual[fpc_filter_pos].col_qual,
       fpc_col_cnt), filter_parm->qual[fpc_filter_pos].col_qual[fpc_col_cnt].col_name = d.column_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(1)
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(fpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,fpc_table_name,
    dm2_ref_data_doc->tbl_qual[fpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",fpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
     SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," = ",
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   SET fpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   SET fpc_row_cnt = 0
   SET fpc_src_tab_name = dm2_get_rdds_tname(fpc_table_name)
   CALL parser("select into 'NL:' ",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    IF (fpc_tbl_loop > 1)
     CALL parser(" , ",0)
    ENDIF
    CALL parser(concat("var",cnvtstring(fpc_tbl_loop)," = nullind(",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,")"),0)
   ENDFOR
   CALL parser(concat("from ",fpc_src_tab_name," ",fpc_suffix," ",
     fpc_pk_where,
     " detail  fpc_row_cnt = fpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, fpc_row_cnt) "),0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name," = ",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name),0)
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(fpc_tbl_loop)),0)
   ENDFOR
   CALL parser("with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 0
   ENDIF
   IF (fpc_row_cnt=0)
    RETURN(1)
   ENDIF
   SET fpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SET fpc_proc_name = ""
   SET fpc_filter_proc_name = concat("REFCHG_FILTER_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SELECT INTO "NL:"
    FROM (parser(fpc_uo_tname) u)
    WHERE u.object_name=patstring(fpc_filter_proc_name)
    DETAIL
     fpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   IF (fpc_proc_name="")
    SET dm_err->emsg = concat("A filter procedure is not built: ",fpc_filter_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET fpc_proc_name = dm2_get_rdds_tname(fpc_proc_name)
    CALL parser(concat(" declare ",fpc_proc_name,"() = i2 go"),0)
    FOR (fpc_row_loop = 1 TO fpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("select into 'NL:' ret_val = ",fpc_proc_name,
       "('UPD'")
      SET drdm_parser_cnt = 2
      FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
        CALL parser(concat("set fpc_col_nullind = cust_cs_rows->qual[fpc_row_loop].",filter_parm->
          qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (fpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = ", NULL, NULL "
        ELSE
         SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_f8_var,15),
           " , ",cnvtstring(fpc_f8_var,15))
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ,to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS'),","to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),
           "','DD-MON-YYYY HH24:MI:SS')")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set fpc_i4_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_i4_var)," , ",
           cnvtstring(fpc_i4_var))
         ELSE
          CALL parser(concat("set fpc_vc_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET fpc_vc_var = replace(fpc_vc_var,"'","''",0)
          SET fpc_vc_var = concat("'",fpc_vc_var,"'")
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",fpc_vc_var," , ",fpc_vc_var)
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag =
      ") from dual detail fpc_return_var = ret_val with nocounter go"
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET fpc_error_ind = 1
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
      IF (fpc_return_var=0)
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(fpc_return_var)
 END ;Subroutine
 SUBROUTINE replace_carrot_symbol(rcs_string)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   SET rcs_temp_val = replace(rcs_string,"'",'"',0)
   SET rcs_start_idx = 1
   SET rcs_pos = findstring("^",rcs_temp_val,1,0)
   IF (rcs_pos=0)
    SET rcs_return = concat("'",rcs_temp_val,"'")
   ELSE
    WHILE (rcs_pos > 0)
      IF (rcs_start_idx=1)
       IF (rcs_pos=1)
        SET rcs_return = "chr(94)"
       ELSE
        SET rcs_return = concat("'",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),"'||chr(94)")
       ENDIF
      ELSE
       SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
         rcs_temp_val),"'||chr(94)")
      ENDIF
      SET rcs_start_idx = (rcs_pos+ 1)
      SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
    ENDWHILE
    IF (rcs_start_idx <= size(rcs_temp_val))
     SET rcs_pos = findstring("^",rcs_temp_val,1,1)
     SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos),
       rcs_temp_val),"'")
    ENDIF
   ENDIF
   RETURN(rcs_return)
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
 FREE RECORD dr_nologs
 RECORD dr_nologs(
   1 qual[*]
     2 table_name = vc
     2 column_name = vc
     2 from_value = f8
     2 pk_where_value = f8
     2 log_id = f8
     2 log_type = vc
 )
 FREE RECORD t_suff
 RECORD t_suff(
   1 qual[*]
     2 table_name = vc
     2 suffix = vc
 )
 DECLARE nolog_cnt = i4
 DECLARE drfn_loop = i4
 DECLARE drfn_table_name = vc
 DECLARE drfn_pk_where = vc
 DECLARE drfn_except_tab = vc
 DECLARE drfn_updt_tab = vc
 DECLARE drfn_row_ind = i2
 DECLARE drfn_table_suffix = vc
 DECLARE drfn_suff_cnt = i4
 DECLARE drfn_suff_loop = i4
 DECLARE drfn_error_ind = i2
 DECLARE drfn_context = vc
 DECLARE drfn_tbl_loop = i4
 DECLARE drfn_chop = vc
 SET drfn_except_tab = concat(value(dm2_ref_data_doc->pre_link_name),"DM_CHG_LOG_EXCEPTION",value(
   dm2_ref_data_doc->post_link_name))
 SELECT INTO "NL:"
  FROM (parser(drfn_except_tab) d)
  WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
   AND d.log_type IN ("INSRC", "UPDTSK")
   AND d.column_name != ""
   AND d.from_value > 0
  HEAD REPORT
   nolog_cnt = 0, stat = alterlist(dr_nologs->qual,1000)
  DETAIL
   nolog_cnt = (nolog_cnt+ 1), dr_nologs->qual[nolog_cnt].table_name = d.table_name, dr_nologs->qual[
   nolog_cnt].column_name = d.column_name,
   dr_nologs->qual[nolog_cnt].from_value = d.from_value, dr_nologs->qual[nolog_cnt].log_type = d
   .log_type
  FOOT REPORT
   stat = alterlist(dr_nologs->qual,nolog_cnt)
  WITH nocounter, maxqual(d,1000)
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET drfn_quit = 1
  GO TO nolog_child
 ENDIF
 IF (curqual=0)
  SET drfn_quit = 1
 ELSE
  SET dm_err->eproc = "Performing Fake update against source table"
  CALL disp_msg(" ",dm_err->logfile,0)
  FOR (drfn_loop = 1 TO nolog_cnt)
    SET drfn_error_ind = 0
    SET temp_tbl_cnt = locateval(drfn_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,dr_nologs->qual[drfn_loop]
     .table_name,dm2_ref_data_doc->tbl_qual[drfn_tbl_loop].table_name)
    IF (temp_tbl_cnt=0)
     SET temp_tbl_cnt = fill_rs("TABLE",dr_nologs->qual[drfn_loop].table_name)
    ENDIF
    SET drfn_table_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
    SET drfn_pk_where = concat("WHERE ",drfn_table_suffix,".",dr_nologs->qual[drfn_loop].column_name,
     " = ",
     cnvtstring(dr_nologs->qual[drfn_loop].from_value,15))
    SET drfn_filter_ind = filter_proc_call(dr_nologs->qual[drfn_loop].table_name,drfn_pk_where)
    IF (drdm_error_out_ind=1)
     SET drfn_error_ind = 1
     SET drfn_loop = nolog_cnt
    ELSE
     IF (drfn_filter_ind=0)
      UPDATE  FROM (parser(drfn_except_tab) d)
       SET d.log_type = "NOMV11"
       WHERE (d.table_name=dr_nologs->qual[drfn_loop].table_name)
        AND (d.column_name=dr_nologs->qual[drfn_loop].column_name)
        AND (d.from_value=dr_nologs->qual[drfn_loop].from_value)
        AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET drfn_error_ind = 1
      ELSE
       COMMIT
      ENDIF
     ELSE
      IF (((drdm_context_string="") OR (drdm_context_string="ALL")) )
       SET drfn_context = "NULL"
      ELSE
       SET drfn_tbl_loop = findstring("::",drdm_context_string,1,0)
       IF (drfn_tbl_loop=0)
        SET drfn_context = drdm_context_string
       ELSE
        SET drfn_chop = drdm_context_string
        WHILE (drfn_chop=patstring("NULL::*"))
          SET drfn_chop = substring((drfn_tbl_loop+ 2),size(drfn_chop),drfn_chop)
        ENDWHILE
        SET drfn_tbl_loop = findstring("::",drfn_chop,1,0)
        IF (drfn_tbl_loop != 0)
         SET drfn_context = substring(1,(drfn_tbl_loop - 1),drfn_chop)
        ELSE
         SET drfn_context = drfn_chop
        ENDIF
       ENDIF
      ENDIF
      SET drfn_error_ind = trigger_proc_call(dr_nologs->qual[drfn_loop].table_name,"",drfn_context,
       dr_nologs->qual[drfn_loop].column_name,dr_nologs->qual[drfn_loop].from_value)
      IF (drdm_error_out_ind=1)
       SET drfn_loop = nolog_cnt
      ELSE
       IF (drfn_error_ind=0)
        SET drdm_any_translated = 1
        UPDATE  FROM (parser(drfn_except_tab) d)
         SET d.log_type = "INLOG"
         WHERE (d.table_name=dr_nologs->qual[drfn_loop].table_name)
          AND (d.column_name=dr_nologs->qual[drfn_loop].column_name)
          AND (d.from_value=dr_nologs->qual[drfn_loop].from_value)
          AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET drfn_error_ind = 1
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF ((dm_err->err_ind=1))
  SET drfn_quit = 1
 ENDIF
#nolog_child
END GO
