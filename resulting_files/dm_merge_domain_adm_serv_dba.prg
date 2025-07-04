CREATE PROGRAM dm_merge_domain_adm_serv:dba
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
 DECLARE fill_rs(type=vc,info=vc) = i4 WITH public
 DECLARE dm2_rdds_get_tbl_col_info(sbr_gtci_tname=vc) = i2 WITH public
 DECLARE dm2_rdds_init_drcs_rec(null) = null
 DECLARE dm2_rdds_col_add(sbr_tbl_idx=i4,sbr_col_idx=i4) = i2
 DECLARE dm2_rdds_col_extend(sbr_tbl_idx=i4,sbr_col_idx=i4) = i2
 DECLARE dm2_rdds_col_compare(srb_tbl_idx=i4) = i2
 DECLARE fill_ccl_data_info(cdi_tbl_cnt=i4) = i2
 DECLARE dm2_rdds_get_tgt_id(s_gmti_tgt_rs=vc(ref)) = i2
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
      2 mergeable_ind = i2
      2 reference_ind = i2
      2 version_ind = i2
      2 version_type = vc
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
        3 data_type = vc
        3 data_length = vc
        3 binary_long_ind = i2
        3 pk_ind = i2
        3 code_set = i4
        3 nullable = c1
        3 check_null = i2
        3 check_space = i2
        3 translated = i2
        3 idcd_ind = i2
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
      2 parent_flag = i4
      2 child_flag = i4
      2 parent_qual[*]
        3 child_name = vc
        3 parent_id_col = vc
        3 parent_tab_col = vc
        3 in_src_ind = i2
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
    1 refchg_buffer = i4
    1 loop_back_ind = i2
    1 one_pass_ind = i2
    1 qual[*]
      2 pattern_cki = vc
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
  )
  FREE RECORD pk_where_parm
  RECORD pk_where_parm(
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 col_name = vc
  )
  FREE RECORD filter_parm
  RECORD filter_parm(
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 col_name = vc
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
 SUBROUTINE fill_rs(type,info)
   DECLARE column_loop = i4
   DECLARE src_tab_name = vc
   DECLARE alg_code = f8
   DECLARE fr_di_appl_id = vc
   DECLARE fr_cur_appl_id = vc
   DECLARE drm_ioru_only = f8
   DECLARE drm_ioru_meaning = vc
   DECLARE fr_loop = i4
   SET fr_di_appl_id = "NOT SET"
   SET fr_cur_appl_id = "NOT SET"
   IF (type="TABLE")
    IF (dm2_rdds_get_tbl_col_info(info)=0)
     SET dm_err->err_ind = 0
     SET dm_err->eproc = "Determining if schema snapshot concurrency row should be removed"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     SET fr_cur_appl_id = currdbhandle
     SELECT INTO "nl:"
      di.info_char
      FROM dm_info di
      WHERE di.info_domain="DM2 INSTALL PROCESS"
       AND di.info_name="CONCURRENCY CHECKPOINT"
      DETAIL
       fr_di_appl_id = di.info_char
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     SET dm_err->eproc = concat("dm_info appl_id=",fr_di_appl_id)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     SET dm_err->eproc = concat("current process appl_id=",fr_cur_appl_id)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     IF (fr_di_appl_id=fr_cur_appl_id
      AND fr_cur_appl_id != "NOT SET")
      SET dm_err->eproc =
      "Removing schema snapshot concurrency row since it was inserted by this process"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
      SET dm_err->err_ind = 0
      CALL check_concurrent_snapshot("D")
     ENDIF
     SET dm_err->err_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->eproc = "Retrieving schema information"
     SET dm_err->emsg = "Error occurred. Please refer to previous messages in logfile."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SELECT INTO "nl:"
     di.info_char
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name=concat("MERGE SCRIPT:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
     DETAIL
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].custom_script = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    SET drm_ioru_only = 0
    SET drm_ioru_only = uar_get_code_by("DISPLAY",4000220,nullterm(dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].table_name))
    IF (drm_ioru_only > 0)
     SET drm_ioru_meaning = uar_get_code_meaning(drm_ioru_only)
     IF (drm_ioru_meaning="NONE")
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].insert_only_ind = 0
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].update_only_ind = 0
     ELSEIF (drm_ioru_meaning="INSERT_ONLY")
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].insert_only_ind = 1
     ELSEIF (drm_ioru_meaning="UPDATE_ONLY")
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].update_only_ind = 1
     ENDIF
    ELSE
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].insert_only_ind = 0
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].update_only_ind = 0
    ENDIF
    SELECT INTO "NL:"
     FROM dm_info di
     WHERE di.info_domain="RDDS SKIP SEQMATCH"
      AND di.info_name=info
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF (curqual=1)
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind = 1
    ELSE
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind = 0
    ENDIF
    SET alg_code = 0
    SET alg_code = uar_get_code_by("DISPLAY",255351,nullterm(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt]
      .table_name))
    IF (alg_code > 0)
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type = uar_get_code_meaning(alg_code)
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type="NONE"))
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind = 0
     ELSE
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind = 1
     ENDIF
    ELSEIF ((alg_code=- (2)))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Error returned from Versiong Alg UAR."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF ((alg_code=- (1)))
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind = 0
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt)),
      dm_info i
     PLAN (d
      WHERE (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].idcd_ind=0))
      JOIN (i
      WHERE i.info_domain=concat("RDDS TRANS COLUMN:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
       table_name)
       AND (i.info_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name))
     DETAIL
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].idcd_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    SET tbl_loop = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,info,dguc_reply->dtd_hold[tbl_loop].
     tbl_name)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,5)),
      (dummyt d2  WITH seq = dguc_reply->dtd_hold[tbl_loop].pk_cnt)
     PLAN (d)
      JOIN (d2
      WHERE (dguc_reply->dtd_hold[tbl_loop].pk_hold[d2.seq].pk_name=dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[d.seq].column_name))
     DETAIL
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].pk_ind = 1
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
     PLAN (d)
     DETAIL
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name="ACTIVE_IND"))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind = 1
      ENDIF
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name IN (
      "BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM", "BEG_EFFECTIVE_UTC_DT_TM",
      "BEG_EFF_DT_TM",
      "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM")))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name = dm2_ref_data_doc->tbl_qual[
       temp_tbl_cnt].col_qual[d.seq].column_name
      ENDIF
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name IN (
      "END_EFFECTIVE_DT_TM", "PRSNL_END_EFFECTIVE_DT_TM", "END_EFFECTIVE_UTC_DT_TM", "END_EFF_DT_TM",
      "CNTRCT_EFF_DT_TM")))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name = dm2_ref_data_doc->tbl_qual[
       temp_tbl_cnt].col_qual[d.seq].column_name
      ENDIF
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].db_data_type="*LOB"))
       IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].db_data_type_tgt="*LOB"))
        dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].lob_process_type = "LOB_LOB"
       ELSE
        dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].lob_process_type = "LOB_LONG"
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name != "")
     AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name != ""))
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind = 1
    ENDIF
    FOR (fr_loop = 1 TO dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].exception_flg=9))
       SELECT INTO "NL:"
        FROM dm_refchg_version_r d
        WHERE (child_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
         AND (child_vers_col=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].column_name)
        DETAIL
         dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].version_nbr_child_ind = 1,
         dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].parent_table = d.parent_table,
         dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].parent_pk_col = d.parent_id_col,
         dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].parent_vers_col = d
         .parent_vers_col, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].child_fk_col =
         d.child_id_col
        WITH nocounter
       ;end select
       IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].version_nbr_child_ind=0)
        AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind=0))
        SET dm_err->err_ind = 1
        SET drdm_error_out_ind = 1
        SET dm_err->eproc = "Retrieving schema information"
        SET dm_err->emsg = "A parent version_nbr column was found on a table that isn't versioned"
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
    SET drdm_return_var = temp_tbl_cnt
   ELSE
    SET dm_err->eproc = "Filling code set info into RS"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM code_value_set cvs
     WHERE cvs.code_set=cnvtint(info)
     DETAIL
      perm_cs_cnt = (perm_cs_cnt+ 1), temp_cs_cnt = perm_cs_cnt, stat = alterlist(dm2_ref_data_doc->
       cs_qual,temp_cs_cnt),
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].code_set = cvs.code_set, dm2_ref_data_doc->cs_qual[
      temp_cs_cnt].cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind, dm2_ref_data_doc->cs_qual[
      temp_cs_cnt].display_dup_ind = cvs.display_dup_ind,
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].display_key_dup_ind = cvs.display_key_dup_ind,
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].active_ind_dup_ind = cvs.active_ind_dup_ind,
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].definition_dup_ind = cvs.definition_dup_ind
     FOOT REPORT
      dm2_ref_data_doc->cs_cnt = temp_cs_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF (curqual=0)
     CALL disp_msg("No code_set qualified from dm_code_set",dm_err->logfile,0)
     RETURN(0)
    ENDIF
    SELECT INTO "NL:"
     FROM dm_code_set dcs
     WHERE code_set=cnvtint(info)
     DETAIL
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].merge_ui_query = dcs.merge_ui_query
      IF (dcs.merge_ui_query=null)
       dm2_ref_data_doc->cs_qual[temp_cs_cnt].merge_ui_query_ni = 1
      ELSE
       dm2_ref_data_doc->cs_qual[temp_cs_cnt].merge_ui_query_ni = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm2_ref_data_doc->cs_qual[temp_cs_cnt].merge_ui_query_ni = 1
    ENDIF
    SET drdm_return_var = temp_cs_cnt
   ENDIF
   RETURN(drdm_return_var)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tbl_col_info(sbr_gtci_tname)
   DECLARE fr_tab_name = vc
   SET dm_err->eproc = concat("Loading table level info into memory for table ",sbr_gtci_tname)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((validate(oragen3_ignore_dm_columns_doc,- (1))=- (1)))
    DECLARE oragen3_ignore_dm_columns_doc = i2
   ENDIF
   DECLARE src_tab_name = vc
   DECLARE rgtci_cnt = i4 WITH noconstant(0)
   DECLARE col_qual_cnt = i4 WITH noconstant(0)
   DECLARE rms_len_idx = i4 WITH noconstant(0)
   SET src_tab_name = dm2_get_rdds_tname("USER_TAB_COLUMNS")
   SET fr_tab_name = dm2_get_rdds_tname("dm_rdds_tbl_doc")
   SELECT INTO "NL:"
    FROM dm_rdds_tbl_doc drt,
     (parser(fr_tab_name) drs)
    PLAN (drs
     WHERE drs.table_name=sbr_gtci_tname)
     JOIN (drt
     WHERE drt.table_name=drs.table_name)
    DETAIL
     temp_tbl_cnt = (perm_tbl_cnt+ 1), perm_tbl_cnt = (perm_tbl_cnt+ 1), stat = alterlist(
      dm2_ref_data_doc->tbl_qual,value((size(dm2_ref_data_doc->tbl_qual,5)+ 1))),
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name = drs.table_name
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name IN ("ACCESSION", "ADDRESS", "PHONE",
     "PERSON", "PERSON_NAME",
     "PERSON_ALIAS", "DCP_ENTITY_RELTN", "LONG_TEXT", "LONG_BLOB", "ACCOUNT",
     "AT_ACCT_RELTN")))
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind = 1, dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].reference_ind = 1
     ELSEIF (drs.override_instance <= drt.override_instance)
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind = drs.mergeable_ind, dm2_ref_data_doc->
      tbl_qual[temp_tbl_cnt].reference_ind = drs.reference_ind
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind = drt.mergeable_ind, dm2_ref_data_doc->
      tbl_qual[temp_tbl_cnt].reference_ind = drt.reference_ind
     ENDIF
     IF (drs.override_instance <= drt.override_instance)
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_delete_ind = drs.merge_delete_ind
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_delete_ind = drt.merge_delete_ind
     ENDIF
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix = drs.table_suffix, dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].merge_ui_query = drs.merge_ui_query
     IF (drs.merge_ui_query=null)
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_ui_query_ni = 1
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_ui_query_ni = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(dm2_ref_data_doc->tbl_qual,temp_tbl_cnt), dm2_ref_data_doc->tbl_cnt =
     temp_tbl_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     CALL disp_msg(concat("No table qualified for table",sbr_gtci_tname," in table level meta-data"),
      dm_err->logfile,1)
    ENDIF
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Loading column level info into memory for table ",sbr_gtci_tname)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET fr_tab_name = dm2_get_rdds_tname("DM_RDDS_COL_DOC")
   SELECT INTO "NL:"
    udd = nullind(utc.data_default)
    FROM dm_rdds_col_doc drt,
     (parser(src_tab_name) utc),
     (parser(fr_tab_name) drs)
    PLAN (drs
     WHERE drs.table_name=sbr_gtci_tname)
     JOIN (drt
     WHERE drt.table_name=sbr_gtci_tname
      AND drt.column_name=drs.column_name)
     JOIN (utc
     WHERE utc.table_name=sbr_gtci_tname
      AND utc.column_name=drt.column_name)
    DETAIL
     col_qual_cnt = (col_qual_cnt+ 1)
     IF (mod(col_qual_cnt,10)=1)
      stat = alterlist(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,(col_qual_cnt+ 9))
     ENDIF
     IF (drs.override_instance <= drt.override_instance)
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].column_name = drs.column_name,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].unique_ident_ind = drs
      .unique_ident_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      exception_flg = drs.exception_flg,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].constant_value = drs
      .constant_value, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      parent_entity_col = cnvtupper(drs.parent_entity_col), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      col_qual[col_qual_cnt].sequence_name = drs.sequence_name,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].root_entity_name = cnvtupper(
       drs.root_entity_name), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      root_entity_attr = cnvtupper(drs.root_entity_attr), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      col_qual[col_qual_cnt].code_set = drs.code_set,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].merge_delete_ind = drs
      .merge_delete_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      defining_attribute_ind = drs.defining_attribute_ind
      IF (drs.column_name IN ("*_ID", "*_CD", "CODE_VALUE"))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 1
      ELSE
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 0
      ENDIF
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].column_name = drt.column_name,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].unique_ident_ind = drt
      .unique_ident_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      exception_flg = drt.exception_flg,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].constant_value = drt
      .constant_value, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      parent_entity_col = cnvtupper(drt.parent_entity_col), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      col_qual[col_qual_cnt].sequence_name = drt.sequence_name,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].root_entity_name = cnvtupper(
       drt.root_entity_name), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      root_entity_attr = cnvtupper(drt.root_entity_attr), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      col_qual[col_qual_cnt].code_set = drt.code_set,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].merge_delete_ind = drt
      .merge_delete_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      defining_attribute_ind = drt.defining_attribute_ind
      IF (drt.column_name IN ("*_ID", "*_CD", "CODE_VALUE"))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 1
      ELSE
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 0
      ENDIF
     ENDIF
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].db_data_type = utc.data_type,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].db_data_length = utc.data_length,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].nullable = utc.nullable,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].check_null = 0, dm2_ref_data_doc
     ->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].translated = 0, dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].col_qual[col_qual_cnt].data_default = utc.data_default,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni = udd
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni=0))
      IF (((cnvtupper(utc.data_default)="NULL") OR (((utc.data_default=" ") OR (((utc.data_default=""
      ) OR (((utc.data_default="''") OR (utc.data_default='""')) )) )) )) )
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni = 1
      ENDIF
     ENDIF
     IF (utc.data_type IN ("BLOB", "LONG RAW", "CLOB", "LONG"))
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].binary_long_ind = 1
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].binary_long_ind = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,col_qual_cnt),
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt = col_qual_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     CALL disp_msg(concat("No columns qualified from column level meta-data query for table ",
       sbr_gtci_tname),dm_err->logfile,1)
    ENDIF
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF ((dm2_rdds_rec->mode="OS"))
    IF (fill_ccl_data_info(temp_tbl_cnt)=0)
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   IF (dm2_rdds_col_compare(temp_tbl_cnt)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_rdds_curdb_schema->same_count != dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
    SET dm_err->eproc = "Schema differences exist between target and source domains"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->eproc = "Checking for inhouse domain"
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_set_inhouse_domain(null)=0)
     RETURN(0)
    ENDIF
    IF ((inhouse_misc->inhouse_domain=1))
     SET dm_err->emsg = concat(
      "Running in an inhouse domain, can not perform needed schema changes on ",sbr_gtci_tname)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    SET dm2_install_schema->appl_id = currdbhandle
    IF (check_concurrent_snapshot("I")=0)
     RETURN(0)
    ENDIF
    IF (dm2_rdds_col_compare(temp_tbl_cnt)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdds_curdb_schema->same_count=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
     SET dm_err->eproc =
     "No schema differences exist between target and source domains inside the concurrency window"
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL check_concurrent_snapshot("D")
     RETURN(1)
    ENDIF
    SET dm2_rdds_curdb_schema->ddl_exist_flag = dm2_table_exists("DM2_DDL_OPS_LOG")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Getting ready to make the schema changes"
    FOR (rcc_lp = 1 TO dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].in_tgt_flag != 1))
       SET dm_err->eproc = concat("Schema diff found for ",sbr_gtci_tname,".",dm2_ref_data_doc->
        tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].column_name)
       CALL disp_msg("",dm_err->logfile,0)
       IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].db_data_type IN ("LONG",
       "LONG RAW", "CLOB", "BLOB")))
        SET dm_err->emsg = "The missing column has LONG, LONG RAW, CLOB, or BLOB data type"
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF ((dm2_rdds_curdb_schema->ddl_exist_flag="F")
        AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].in_tgt_flag=0))
        SET dm_err->eproc = "Checking if another process is getting ready to make the same change"
        CALL disp_msg("",dm_err->logfile,0)
        SET dm2_rdds_curdb_schema->appl_id = "NOT SET"
        SELECT INTO "nl:"
         d.*
         FROM dm2_ddl_ops_log d
         WHERE (d.table_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
          AND (d.obj_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].column_name)
          AND d.op_type="ADD COLUMN"
         DETAIL
          dm2_rdds_curdb_schema->appl_id = d.appl_id
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF ((dm2_rdds_curdb_schema->appl_id != "NOT SET"))
         IF (dm2_get_appl_status(dm2_rdds_curdb_schema->appl_id) != "I")
          IF ((dm_err->err_ind=0))
           SET dm_err->eproc = concat("Another process is getting ready to add column ",
            dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].column_name," to ",
            dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
           SET dm_err->user_action = "Please restart this process"
           SET dm_err->err_ind = 1
           CALL disp_msg("",dm_err->logfile,0)
          ENDIF
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->eproc = "No other process is getting ready to make the same change"
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].in_tgt_flag=0))
        IF (dm2_rdds_col_add(temp_tbl_cnt,rcc_lp)=0)
         RETURN(0)
        ENDIF
        IF (drm_log_sch_chg("RDDS SCHEMA MAINTENANCE:ADD COLUMN",build(dm2_ref_data_doc->tbl_qual[
          temp_tbl_cnt].table_name,".",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].
          column_name),concat("TYPE= ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].
          db_data_type,"; DEFAULT=",substring(1,200,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
           col_qual[rcc_lp].data_default)))=0)
         RETURN(0)
        ENDIF
       ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].in_tgt_flag=2))
        IF (dm2_rdds_col_extend(temp_tbl_cnt,rcc_lp)=0)
         RETURN(0)
        ENDIF
        IF (drm_log_sch_chg(build("RDDS SCHEMA MAINTENANCE:EXTEND DATA LENGTH (",dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].db_data_length,")"),build(dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].table_name,".",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[
          rcc_lp].column_name),concat("TYPE= ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[
          rcc_lp].db_data_type))=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    SET oragen3_ignore_dm_columns_doc = 1
    EXECUTE oragen3 dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (dm2_rdds_col_compare(temp_tbl_cnt)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdds_curdb_schema->same_count != dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
     SET dm_err->emsg = "Column differences still exist after one pass of changes was made"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (check_concurrent_snapshot("D")=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (fill_ccl_data_info(temp_tbl_cnt)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_rdds_curdb_schema->ccl_same_cnt != dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
    SET oragen3_ignore_dm_columns_doc = 1
    EXECUTE oragen3 dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (fill_ccl_data_info(temp_tbl_cnt)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdds_curdb_schema->ccl_same_cnt != dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Cannot find all columns for table ",dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].table_name," in CCL dictionary after performing oragen3")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_col_extend(sbr_tbl_idx,sbr_col_idx)
   SET dm_err->eproc = concat("Extend length for ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
    ".",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," to ",
    cnvtstring(dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_length))
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_push_cmd(concat("rdb alter table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
     " modify (",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," ",
     dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_type,"(",cnvtstring(
      dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_length),")) go"),1)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_col_add(sbr_tbl_idx,sbr_col_idx)
   SET dm_err->eproc = concat("Add column ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[
    sbr_col_idx].column_name," for table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE drm_bb_trg_cnt = i4
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_type IN ("CHAR",
   "VARCHAR", "VARCHAR2", "CHARACTER", "RAW")))
    IF (dm2_push_cmd(concat("rdb alter table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
      " add (",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," ",
      dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_type,"(",cnvtstring(
       dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_length),")) go"),1)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (dm2_push_cmd(concat("rdb alter table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
      " add (",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," ",
      dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_type,") go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name IN ("BED", "BILL_ITEM")))
    SET drm_bb_trg_cnt = 0
    SELECT DISTINCT INTO "nl:"
     u.table_name
     FROM user_triggers u
     WHERE (u.table_name=dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name)
      AND u.trigger_name="REFCHG*"
     DETAIL
      drm_bb_trg_cnt = (drm_bb_trg_cnt+ 1)
     WITH nocounter
    ;end select
    IF (drm_bb_trg_cnt > 0)
     SET dguc_request->what_tables = dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name
     EXECUTE dm2_add_chg_log_triggers dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name, "REFCHG"
     IF (check_error("Failed to generate RDDS trigger for table BED and BILL_ITEM") != 0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].data_default_ni=0))
    IF (dm2_push_cmd(concat("rdb alter table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
      " modify (",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," ",
      " default ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].data_default,") go"),
     1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_init_drcs_rec(null)
   SET dm2_rdds_curdb_schema->table_name = ""
   SET dm2_rdds_curdb_schema->col_cnt = 0
   SET stat = alterlist(dm2_rdds_curdb_schema->col,0)
   SET dm2_rdds_curdb_schema->same_count = 0
 END ;Subroutine
 SUBROUTINE dm2_rdds_col_compare(sbr_tbl_idx)
   DECLARE rcc_tbl_cnt = i4 WITH noconstant(0)
   SET dm_err->eproc = concat("Compare the schema for table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx]
    .table_name)
   CALL dm2_rdds_init_drcs_rec(null)
   SELECT INTO "nl:"
    FROM dm2_user_tab_columns utc
    WHERE (utc.table_name=dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name)
    DETAIL
     rcc_tbl_cnt = (rcc_tbl_cnt+ 1)
     IF (mod(rcc_tbl_cnt,50)=1)
      stat = alterlist(dm2_rdds_curdb_schema->col,(rcc_tbl_cnt+ 49))
     ENDIF
     dm2_rdds_curdb_schema->col[rcc_tbl_cnt].column_name = utc.column_name, dm2_rdds_curdb_schema->
     col[rcc_tbl_cnt].data_type = utc.data_type, dm2_rdds_curdb_schema->col[rcc_tbl_cnt].data_length
      = utc.data_length
    FOOT REPORT
     stat = alterlist(dm2_rdds_curdb_schema->col,rcc_tbl_cnt), dm2_rdds_curdb_schema->col_cnt =
     rcc_tbl_cnt, dm2_rdds_curdb_schema->table_name = utc.table_name
    WITH nocounter
   ;end select
   IF (check_error("Populating the target schema")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dm2_rdds_curdb_schema->col_cnt)),
     (dummyt dt  WITH seq = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_cnt))
    PLAN (dt)
     JOIN (d
     WHERE (dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].column_name=
     dm2_rdds_curdb_schema->col[d.seq].column_name))
    DETAIL
     dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].in_tgt_flag = 1
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].db_data_type IN ("CHAR", "VARCHAR",
     "VARCHAR2", "RAW", "CHARACTER"))
      AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].db_data_length >
     dm2_rdds_curdb_schema->col[d.seq].data_length))
      dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].in_tgt_flag = 2
     ELSE
      dm2_rdds_curdb_schema->same_count = (dm2_rdds_curdb_schema->same_count+ 1)
     ENDIF
     dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].db_data_type_tgt =
     dm2_rdds_curdb_schema->col[d.seq].data_type
    WITH nocounter
   ;end select
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = build("dm2_rdds_curdb_schema->same_count=",dm2_rdds_curdb_schema->same_count,
     "; source col_cnt=",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_cnt,"; currdb col_cnt=",
     dm2_rdds_curdb_schema->col_cnt)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = concat("Table name:",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
     "; column changes needed:")
    FOR (df_lp = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[df_lp].in_tgt_flag=0))
       SET dm_err->eproc = concat(dm_err->eproc,"Add column:",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx]
        .col_qual[df_lp].column_name,";")
      ELSEIF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[df_lp].in_tgt_flag=2))
       SET dm_err->eproc = concat(dm_err->eproc,"Extend column:",dm2_ref_data_doc->tbl_qual[
        sbr_tbl_idx].col_qual[df_lp].column_name,";")
      ENDIF
    ENDFOR
    SET dm_err->eproc = concat(dm_err->eproc,"***End column changes")
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (check_error("Comparing the schema differences between target and source")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drm_log_sch_chg(sbr_lsc_domain,sbr_lsc_info_name,sbr_lsc_info_char)
   SET dm_err->eproc = "Log schema change to dm_info"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=sbr_lsc_domain
     AND d.info_name=sbr_lsc_info_name
     AND d.info_char=sbr_lsc_info_char
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info d
     SET d.info_domain = sbr_lsc_domain, d.info_name = sbr_lsc_info_name, d.info_char =
      sbr_lsc_info_char,
      d.updt_cnt = 0, d.updt_dt_tm = sysdate
     WITH noconter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE fill_ccl_data_info(cdi_tbl_cnt)
   SET dm_err->eproc = "Gather column info from CCL dictionary"
   SET dm2_rdds_curdb_schema->ccl_same_cnt = 0
   SELECT INTO "NL:"
    build(l.type,l.len), l.*, utc.data_type
    FROM dtableattr a,
     dtableattrl l,
     user_tab_columns utc
    PLAN (a
     WHERE (a.table_name=dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].table_name))
     JOIN (l
     WHERE l.structtype="F"
      AND btest(l.stat,11)=0)
     JOIN (utc
     WHERE utc.table_name=a.table_name
      AND utc.column_name=l.attr_name)
    DETAIL
     sbr_cdi_idx = 0, sbr_cdi_idx = locateval(sbr_cdi_idx,1,dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].
      col_cnt,l.attr_name,dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].column_name)
     IF (sbr_cdi_idx > 0)
      dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_length = cnvtstring(l.len)
      IF (l.type="F")
       dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = "F8"
      ELSEIF (l.type="I")
       dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = "I4"
      ELSEIF (l.type="C")
       IF (utc.data_type="CHAR")
        dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = build(l.type,l.len)
       ELSE
        dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = "VC"
       ENDIF
      ELSEIF (l.type="Q")
       dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = "DQ8"
      ENDIF
      dm2_rdds_curdb_schema->ccl_same_cnt = (dm2_rdds_curdb_schema->ccl_same_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
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
    SELECT INTO "NL:"
     d.info_number
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="RDDS_MOCK_ENV_ID"
     DETAIL
      s_gmti_tgt_rs->mock_target_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drgmti_return_val = 0
     RETURN(drgmti_return_val)
    ENDIF
    IF (curqual=0)
     SET s_gmti_tgt_rs->mock_target_id = s_gmti_tgt_rs->env_target_id
    ENDIF
   ENDIF
   RETURN(drgmti_return_val)
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
 DECLARE dmda_con = i2 WITH protect, noconstant(0)
 DECLARE reltn_type = vc WITH protect, constant("REFERENCE MERGE")
 DECLARE logfile_name = vc WITH protect
 DECLARE re_dtrig = c1 WITH protect
 DECLARE return_val = c1 WITH protect
 DECLARE srm_env_id = f8 WITH noconstant(0.0)
 DECLARE srm_env_name = vc
 DECLARE no_log_ind = c1
 DECLARE cutover_flag = i2
 DECLARE meta_data_trigger_refresh_global_ind = i2
 DECLARE manage_merge_domain(null) = null
 DECLARE merge_domain_view(null) = null
 DECLARE merge_domain_add(null) = null
 DECLARE merge_domain_delete(null) = null
 DECLARE add_triggers(null) = null
 DECLARE autoadd_triggers(null) = null
 DECLARE drop_triggers(null) = null
 DECLARE emulate_change(null) = null
 DECLARE confirm_display(domain_name=vc,trg_flag=i2) = c1
 DECLARE trigger_status_report(null) = null
 DECLARE trigger_rpt(trigger_type=vc,msg_type=vc) = null
 DECLARE chg_log_src(null) = null
 DECLARE chg_log_tgt(null) = null
 DECLARE chg_log_rpt(null) = null
 DECLARE dmda_manage_change_log_triggers(null) = null
 DECLARE confirm_sequence_match(environment_name=vc,trig_flag=i2) = c1
 DECLARE source_environment_change(null) = null
 DECLARE get_src_env_id(sub_title=vc,sub_confirm_ind=i2) = null
 DECLARE manage_rdds_context(null) = i2
 DECLARE auto_planned_cutover(null) = null
 DECLARE modify_environment_config(null) = null
 DECLARE cutover_configure_movers(null) = null
 DECLARE target_reactivation(null) = null
 DECLARE mover_batch_size(null) = null
 DECLARE set_log_level(null) = null
 DECLARE mover_buffer_time(null) = null
 DECLARE cutover_configuration(null) = null
 DECLARE check_cut_dups(null) = null
 DECLARE view_cut_dups(src_env_id=f8) = null
 DECLARE start_cutover(null) = null
 DECLARE view_cutover_movers(null) = null
 DECLARE view_cutover_warnings(null) = null
 DECLARE get_cutover_status_reports(i_detail=i2,i_source_env_id=f8,v_tabs=vc(ref)) = null
 DECLARE view_free_space(null) = null
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
 DECLARE ptam_confirm(pc_target_env_id=f8) = null
 DECLARE ptam_setup(ps_target_env_id=f8) = null
 DECLARE auto_planned_cut_modify(apcm_target_env_id=f8) = null
 DECLARE chg_log_vers(null) = null
 DECLARE modify_unmapped_setting(null) = null
 DECLARE dmda_disp_backfill_msgs(dbm_sc_explode=i2,dbm_ptam_check=i2,dbm_dcl_check=i2,dbm_srm_check=
  i2,dbm_mov_check=i2,
  dbm_pkw_check=i2,dbm_mov_check=i2) = i2
 DECLARE dmda_pkw_prompt(pp_mov_check=i2) = i2
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
 FREE RECORD valid_env
 RECORD valid_env(
   1 env_cnt = i4
   1 list[*]
     2 env_id = f8
     2 env_name = vc
 )
 FREE RECORD r_table
 RECORD r_table(
   1 qual[*]
     2 tab_name = vc
   1 qual_cnt = i2
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
 SET message = window
 SET meta_data_trigger_refresh_global_ind = 0
 SET meta_data_trigger_refresh_global_ind = 0
 CALL check_logfile("dm_merge_domain_adm",".log","DM_MERGE_DOMAIN_ADM LOGFILE")
 SET dm_err->eproc = "Beginning dm_merge_domain_adm"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET logfile_name = dm_err->logfile
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION"
   AND di.info_name="CUTOVER ACTIVE_IND"
  DETAIL
   cutover_flag = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ROLLBACK
 ENDIF
 IF (curqual=0)
  SET cutover_flag = 0
 ENDIF
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
 WHILE (dmda_con=0)
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,44,"***  MERGE DOMAIN ADMINISTRATION  ***")
   CALL text(4,75,"ENVIRONMENT ID:")
   CALL text(4,20,"ENVIRONMENT NAME:")
   CALL text(4,95,cnvtstring(dmda_mr->env_id))
   CALL text(4,40,dmda_mr->env_name)
   CALL text(7,3,"Please choose from the following options:")
   CALL text(9,3,"1 Manage environment relationship")
   CALL text(10,3,"2 Manage change log triggers")
   CALL text(11,3,"3 Change log summary reports")
   CALL text(12,3,"4 Manage data movers")
   CALL text(13,3,"5 Find highest sequence values matching between domains")
   IF (cutover_flag=1)
    CALL text(14,3,"6 Manage Cutover")
   ENDIF
   CALL text(15,3,"7 Manage RDDS Events")
   CALL text(16,3,"8 RDDS Status and Monitoring Tools")
   CALL text(18,3,"0 Exit")
   CALL accept(7,50,"99",0
    WHERE curaccept IN (1, 2, 3, 4, 5,
    6, 7, 8, 0))
   CASE (curaccept)
    OF 1:
     CALL manage_merge_domain(null)
    OF 2:
     CALL dmda_manage_change_log_triggers(null)
    OF 3:
     CALL chg_log_rpt(null)
    OF 4:
     CALL mover_management(null)
    OF 5:
     CALL dmda_find_seq_match(null)
    OF 6:
     IF (cutover_flag=0)
      CALL text(20,3,"This option is not availabe at this time.")
      CALL pause(3)
     ELSE
      CALL cutover_configuration(null)
     ENDIF
    OF 7:
     CALL dmda_manage_rdds_event(null)
    OF 8:
     CALL dmda_setup_and_monitor(null)
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
     CALL text(3,44,"***  CHANGE LOG TRIGGER MANAGEMENT  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,"Please choose from the following options:")
     CALL text(9,3,"1 Add/refresh change log triggers")
     CALL text(10,3,"2 View change log trigger history")
     CALL text(11,3,"3 Allow/disallow unmapped users to make changes")
     CALL text(17,3,"0 Exit")
     CALL accept(7,50,"99",0
      WHERE curaccept IN (1, 2, 3, 0))
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
    FROM dm2_user_triggers dt
    WHERE dt.trigger_name="REFCHG*"
    WITH nocounter
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
     CALL text(18,3,"0 Exit")
     IF (dmda_trigger_flag=1
      AND dmda_trg_exist=1)
      CALL text(17,3,"NOTE: Domain relationship was changed!")
      CALL text(18,3,"Change log triggers will be recreated when you return to main menu (Press 0)")
     ENDIF
     CALL accept(10,45,"9",0
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
       IF (dmda_trg_exist=1)
        CALL autoadd_triggers(null)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE merge_domain_view(null)
   DECLARE child_env_size = i4 WITH protect, noconstant(0)
   DECLARE env_total_cnt = i4 WITH protect
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
     SELECT INTO "NL:"
      FROM dm_env_reltn er
      WHERE (er.parent_env_id=dmda_mr->env_id)
       AND (er.child_env_id=derg_reply->child_env_list[env_cnt].env_id)
       AND er.relationship_type="PENDING TARGET AS MASTER"
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET ptam_rec->qual[env_cnt].ptam_check = "Yes"
     ELSE
      SET ptam_rec->qual[env_cnt].ptam_check = "No"
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
       IF ((derg_reply->child_env_list[d.seq].post_link_name != ""))
        col 60, "Yes"
       ELSE
        col 60, "No"
       ENDIF
      ELSEIF (currdb="DB2UDB")
       IF ((derg_reply->child_env_list[d.seq].pre_link_name != ""))
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
     CALL text(12,3,"Is the information correct? (Y, N)")
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
      CALL no_log_confirm(null)
      IF (no_log_ind="Y")
       CALL ins_no_log_row(null)
       CALL ptam_confirm(dmda_add->child_env_id)
      ENDIF
      SET dmda_trigger_flag = 1
     ENDIF
    ENDIF
   ENDIF
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
 SUBROUTINE get_valid_env(null)
   DECLARE gve_cnt = i4 WITH noconstant(0)
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
    ORDER BY environment_id
    DETAIL
     gve_cnt = (gve_cnt+ 1)
     IF (mod(gve_cnt,10)=1)
      stat = alterlist(valid_env->list,(gve_cnt+ 9))
     ENDIF
     valid_env->list[gve_cnt].env_id = de.environment_id, valid_env->list[gve_cnt].env_name = de
     .environment_name
    FOOT REPORT
     stat = alterlist(valid_env->list,gve_cnt), valid_env->env_cnt = gve_cnt
    WITH nocounter
   ;end select
   IF (check_error("Getting valid table list") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE no_log_confirm(null)
   SELECT INTO "nl:"
    FROM dm_env_reltn d
    WHERE (d.child_env_id=dmda_mr->env_id)
     AND (d.parent_env_id=dmda_add->child_env_id)
     AND d.relationship_type=reltn_type
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET no_log_ind = "Y"
    RETURN
   ENDIF
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
   IF (cutover_flag=1)
    CALL auto_planned_cutover(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE merge_domain_delete(null)
   DECLARE del_env_id = i4 WITH protect, noconstant(0)
   DECLARE display_msg = vc WITH protect
   DECLARE sbr_drop_del = vc WITH protect
   DECLARE del_env_name = vc WITH protect
   DECLARE del_con = i2 WITH protect, noconstant(0)
   DECLARE del_validate = i2 WITH protect, noconstant(0)
   DECLARE del_rel_type = vc WITH protect, noconstant(0)
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
     SELECT INTO "NL:"
      der.relationship_type
      FROM dm_env_reltn der
      WHERE (parent_env_id=dmda_mr->env_id)
       AND der.child_env_id=del_env_id
       AND der.relationship_type IN ("AUTO CUTOVER", "PLANNED CUTOVER")
      DETAIL
       del_rel_type = der.relationship_type
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
     ENDIF
     IF (curqual > 0)
      IF (del_rel_type="AUTO CUTOVER")
       SET derd_request->child_env_id = del_env_id
       SET derd_request->env_list[1].child_env_id = del_env_id
       SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
       SET derd_request->env_list[1].relationship_type = "AUTO CUTOVER"
       EXECUTE dm_del_env_reltn
      ELSE
       SET derd_request->child_env_id = del_env_id
       SET derd_request->env_list[1].child_env_id = del_env_id
       SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
       SET derd_request->env_list[1].relationship_type = "PLANNED CUTOVER"
       EXECUTE dm_del_env_reltn
      ENDIF
     ENDIF
     SELECT INTO "NL:"
      FROM dm_env_reltn r
      WHERE (r.parent_env_id=dmda_mr->env_id)
       AND r.child_env_id=del_env_id
       AND r.relationship_type="PENDING TARGET AS MASTER"
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (curqual > 0)
      SET derd_request->child_env_id = ps_target_env_id
      SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
      SET derd_request->env_list[1].child_env_id = del_env_id
      SET derd_request->env_list[1].relationship_type = "PENDING TARGET AS MASTER"
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
 SUBROUTINE autoadd_triggers(null)
   IF (dmda_trigger_flag > 0)
    SET accept = time(10)
    CALL clear(16,1)
    CALL text(18,3,"The program is going to recreate the trigger for this domain!")
    CALL text(19,3,"Press C to continue(automatic recreation in 10 seconds if no response):")
    CALL accept(19,80,"A;CU","C"
     WHERE curaccept IN ("C", "c"))
    SET accept = notime
    SET message = nowindow
    EXECUTE dm2_add_refchg_log_triggers
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_triggers(null)
   SET re_atrig = confirm_display("SOURCE",0)
   IF (re_atrig="Y")
    SET message = nowindow
    EXECUTE dm2_add_refchg_log_triggers
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   SET message = window
   SET width = 132
 END ;Subroutine
 SUBROUTINE chg_log_rpt(null)
  DECLARE clr_con = i2 WITH protect, noconstant(0)
  WHILE (clr_con=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,40,"***  Change Log Summary Reports ***")
    CALL text(7,3,"Choose from the following options: ")
    CALL text(8,3,"1 View remaining chg log summary (source)")
    CALL text(9,3,"2 View reference data mover failure report")
    CALL text(10,3,"3 View remaining chg log rows that require the version id backfill")
    CALL text(17,3,"0 Exit")
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
 SUBROUTINE emulate_change(null)
  SET return_val = confirm_display("SOURCE",0)
  IF (return_val="Y")
   SET message = nowindow
   EXECUTE dm2_ref_chg_all
   SET message = window
   SET width = 132
   CALL clear(20,1)
   CALL text(21,3,
    "All mergeable reference data has been recorded.  Review the following log file in CCLUSERDIR")
   CALL text(22,3,concat("for any errors that may have occurred: ",logfile_name))
   CALL text(24,3,"Press enter to continue: ")
   CALL accept(24,45,"P;E"," ")
  ENDIF
 END ;Subroutine
 SUBROUTINE confirm_display(domain_name,trg_flag)
   CALL clear(20,1)
   CALL text(20,38,"!!!WARNING: ONLY execute this program in")
   CALL text(20,80,domain_name)
   CALL text(20,87," domain!!!")
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
   DELETE  FROM dm_info
    WHERE info_domain="DM_STAT_GATHER"
     AND info_name="DM2_CYCLE_DATA_MOVERS"
    WITH nocounter
   ;end delete
   IF (check_error("Can not delete DM2_CYCLE_DATA_MOVERS") != 0)
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
   SET mm_ret_val = confirm_display("TARGET",0)
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
      CALL text(17,3,"0 Exit")
      CALL accept(9,45,"9",0
       WHERE curaccept IN (1, 2, 3, 4, 0))
      CASE (curaccept)
       OF 1:
        CALL stop_ref_mover(null)
       OF 2:
        CALL start_ref_mover(null)
       OF 3:
        CALL view_ref_mover(null)
       OF 4:
        IF (cutover_flag=0)
         CALL text(20,3,"This option is not availabe at this time.")
         CALL pause(3)
        ELSE
         CALL cutover_configure_movers(null)
        ENDIF
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
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "Starting Data Movers"
      SET dm_err->emsg = "User not logged in cclseclogin"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
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
   SET srm_m_exist = 0
   SET srm_info_number = 60
   CALL get_src_env_id("Start Ref Movers",1)
   IF (srm_env_id=0)
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
     srm_open_event_dt_tm = drel.event_dt_tm
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
      srm_open_event_dt_tm = drel.event_dt_tm
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
     IF (srm_open_event=1)
      RETURN
     ENDIF
     SET meta_data_trigger_refresh_global_ind = 0
     SET srm_rdds_context_ind = 0
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="ACTIVE_IND"
       AND di.info_number=1
      DETAIL
       srm_rdds_context_ind = 1
      WITH nocounter
     ;end select
     IF (srm_rdds_context_ind=1)
      SET srm_rdds_context_call = manage_rdds_context(null)
      IF (srm_rdds_context_call=0)
       CALL disp_msg("Failed during MANAGE_RDDS_CONTEXT subroutine",dm_err->logfile,1)
       GO TO exit_program
      ELSEIF (srm_rdds_context_call=2)
       ROLLBACK
       RETURN
      ENDIF
     ELSE
      UPDATE  FROM dm_info di
       SET di.info_char = "NULL", di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (di.updt_cnt
        + 1),
        di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task
         = reqinfo->updt_task
       WHERE di.info_domain="RDDS CONTEXT"
        AND di.info_name="CONTEXTS TO PULL"
       WITH nocounter
      ;end update
      IF (curqual=0)
       INSERT  FROM dm_info di
        SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXTS TO PULL", di.info_char = "NULL",
         di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
      ENDIF
      UPDATE  FROM dm_info di
       SET di.info_char = "NULL", di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (di.updt_cnt
        + 1),
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
     CALL accept(16,40,"P;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      SET meta_data_trigger_refresh_global_ind = 0
      SET srm_rdds_context_ind = 0
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain="RDDS CONTEXT"
        AND di.info_name="ACTIVE_IND"
        AND di.info_number=1
       DETAIL
        srm_rdds_context_ind = 1
       WITH nocounter
      ;end select
      IF (srm_rdds_context_ind=1)
       SET srm_rdds_context_call = manage_rdds_context(null)
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
       SET dm_err->emsg =
       "There is currently a merge in process for this environment. You cannot open a new RDDS event right now."
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       CALL clear(1,1)
       CALL text(15,3,
        "There is currently a merge in process for this environment. You cannot open a new RDDS event right now."
        )
       CALL text(16,20,"Press ENTER to return to the previous menu.")
       CALL accept(16,64,"P;E"," ")
       SET help = off
       SET validate = off
       RETURN
      ELSE
       SELECT INTO "NL:"
        FROM dm_refchg_process d
        WHERE d.refchg_type="CUTOVER PROCESS*"
         AND  EXISTS (
        (SELECT
         "X"
         FROM gv$session g
         WHERE g.audsid=d.rdbhandle_value))
        WITH nocounter
       ;end select
       IF (check_error("Check if any CUTOVER PROCESS is running for this environment") != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (curqual > 0)
        SET dm_err->emsg =
        "There is currently a CUTOVER in process for this environment. You cannot open a new RDDS event right now."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        CALL clear(1,1)
        CALL text(15,3,
         "There is currently a CUTOVER in process for this environment. You cannot open a new RDDS event right now."
         )
        CALL text(16,20,"Press ENTER to return to the previous menu.")
        CALL accept(16,64,"P;E"," ")
        SET help = off
        SET validate = off
        RETURN
       ELSE
        SELECT INTO "NL:"
         FROM user_tables u
         WHERE u.table_name="*$R"
         HEAD REPORT
          cnt = 0
         DETAIL
          cnt = (cnt+ 1)
          IF (mod(cnt,10)=1)
           stat = alterlist(r_table->qual,(cnt+ 9))
          ENDIF
          r_table->qual[cnt].tab_name = u.table_name
         FOOT REPORT
          stat = alterlist(r_table->qual,cnt), r_table->qual_cnt = cnt
         WITH nocounter
        ;end select
        IF (check_error("Retrieving $R table names.") != 0)
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        FOR (i = 1 TO r_table->qual_cnt)
          SELECT INTO "NL:"
           FROM (parser(r_table->qual[i].tab_name) d)
           WHERE d.rdds_status_flag < 9000
           WITH nocounter
          ;end select
          IF (check_error("Looking for non-cutover rows in $R tables") != 0)
           SET dm_err->err_ind = 1
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ENDIF
          IF (curqual > 0)
           SET dm_err->emsg =
           "There are rows left to cutover. Cannot start a new event. Exiting menu."
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           CALL clear(1,1)
           CALL text(15,3,"There are rows left to cutover. Cannot start a new event. Exiting menu.")
           CALL text(16,20,"Press ENTER to return to the previous menu.")
           CALL accept(16,64,"P;E"," ")
           SET help = off
           SET validate = off
           RETURN
          ENDIF
        ENDFOR
        SET stat = alterlist(r_table->qual,0)
        SET r_table->qual_cnt = 0
        SET srm_dmda_mover_cutover_off_ind = 1
       ENDIF
      ENDIF
      IF (srm_dmda_mover_cutover_off_ind=1)
       CALL clear(1,1)
       SET message = window
       SET width = 132
       CALL box(1,1,7,132)
       CALL text(3,40,"***  Manage Data Movers ***")
       CALL text(5,20,"Environment Name:")
       CALL text(5,40,dmda_mr->env_name)
       CALL text(5,65,"Environment ID:")
       CALL text(5,85,cnvtstring(dmda_mr->env_id))
       CALL text(14,3,concat("Can the following RDDS open event be closed for source: ",trim(
          cnvtstring(srm_open_event_source))," ?"))
       CALL text(15,3,concat("Event: ",srm_open_event_reason))
       CALL accept(15,40,"P;CU","N"
        WHERE curaccept IN ("Y", "N"))
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
        IF (srm_open_event=1)
         RETURN
        ENDIF
        SET meta_data_trigger_refresh_global_ind = 0
        SET srm_rdds_context_ind = 0
        SELECT INTO "nl:"
         FROM dm_info di
         WHERE di.info_domain="RDDS CONTEXT"
          AND di.info_name="ACTIVE_IND"
          AND di.info_number=1
         DETAIL
          srm_rdds_context_ind = 1
         WITH nocounter
        ;end select
        IF (srm_rdds_context_ind=1)
         SET srm_rdds_context_call = manage_rdds_context(null)
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
           di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di
           .updt_task = reqinfo->updt_task
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
           di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di
           .updt_task = reqinfo->updt_task
          WHERE di.info_domain="RDDS CONTEXT"
           AND di.info_name="CONTEXT TO SET"
          WITH nocounter
         ;end update
         IF (curqual=0)
          INSERT  FROM dm_info di
           SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXT TO SET", di.info_char =
            "NULL",
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
     SET dm_err->emsg = concat("Event ",srm_open_event_reason," for source environment: ",trim(
       cnvtstring(srm_open_event_source)),
      " is currently open. You cannot open a new RDDS event while another event is open.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL clear(1,1)
     CALL text(15,3,concat("Event: ",srm_open_event_reason))
     CALL text(16,3,concat("For source environment: ",trim(cnvtstring(srm_open_event_source)),
       " is currently open."))
     CALL text(17,3,"You cannot open a new RDDS event while another event is open.")
     CALL text(18,20,"Press ENTER to return to the previous menu.")
     CALL accept(18,64,"P;E"," ")
     SET help = off
     SET validate = off
     RETURN
    ELSE
     SELECT INTO "NL:"
      FROM dm_refchg_process d
      WHERE d.refchg_type="CUTOVER PROCESS*"
       AND  EXISTS (
      (SELECT
       "X"
       FROM gv$session g
       WHERE g.audsid=d.rdbhandle_value))
      WITH nocounter
     ;end select
     IF (check_error("Check if any CUTOVER PROCESS is running for this environment") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     IF (curqual > 0)
      SET dm_err->emsg = concat("Event ",srm_open_event_reason," for source environment: ",trim(
        cnvtstring(srm_open_event_source)),
       " is currently open. You cannot open a new RDDS event while another event is open.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL clear(1,1)
      CALL text(15,3,concat("Event: ",srm_open_event_reason))
      CALL text(16,3,concat("For source environment: ",trim(cnvtstring(srm_open_event_source)),
        " is currently open."))
      CALL text(17,3,"You cannot open a new RDDS event while another event is open.")
      CALL text(18,20,"Press ENTER to return to the previous menu.")
      CALL accept(18,64,"P;E"," ")
      SET help = off
      SET validate = off
      RETURN
     ELSE
      SELECT INTO "NL:"
       FROM user_tables u
       WHERE u.table_name="*$R"
       HEAD REPORT
        cnt = 0
       DETAIL
        cnt = (cnt+ 1)
        IF (mod(cnt,10)=1)
         stat = alterlist(r_table->qual,(cnt+ 9))
        ENDIF
        r_table->qual[cnt].tab_name = u.table_name
       FOOT REPORT
        stat = alterlist(r_table->qual,cnt), r_table->qual_cnt = cnt
       WITH nocounter
      ;end select
      FOR (i = 1 TO r_table->qual_cnt)
       SELECT INTO "NL:"
        FROM (parser(r_table->qual[i].tab_name) d)
        WHERE d.rdds_status_flag < 9000
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET dm_err->emsg = concat("Event ",srm_open_event_reason," for source environment: ",trim(
          cnvtstring(srm_open_event_source)),
         " is currently open. You cannot open a new RDDS event while another event is open.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        CALL clear(1,1)
        CALL text(15,3,concat("Event: ",srm_open_event_reason))
        CALL text(16,3,concat("For source environment: ",trim(cnvtstring(srm_open_event_source)),
          " is currently open."))
        CALL text(17,3,"You cannot open a new RDDS event while another event is open.")
        CALL text(18,20,"Press ENTER to return to the previous menu.")
        CALL accept(18,64,"P;E"," ")
        SET help = off
        SET validate = off
        RETURN
       ENDIF
      ENDFOR
      SET stat = alterlist(r_table->qual,0)
      SET r_table->qual_cnt = 0
     ENDIF
    ENDIF
    CALL clear(1,1)
    SET message = window
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  Manage Data Movers ***")
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,dmda_mr->env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(dmda_mr->env_id))
    CALL text(14,3,concat("Can the following RDDS open event be closed for source: ",trim(cnvtstring(
        srm_open_event_source))," ?"))
    CALL text(15,3,concat("Event: ",srm_open_event_reason))
    CALL accept(15,40,"P;CU","N"
     WHERE curaccept IN ("Y", "N"))
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
     IF (srm_open_event=1)
      RETURN
     ENDIF
     SET meta_data_trigger_refresh_global_ind = 0
     SET srm_rdds_context_ind = 0
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="ACTIVE_IND"
       AND di.info_number=1
      DETAIL
       srm_rdds_context_ind = 1
      WITH nocounter
     ;end select
     IF (srm_rdds_context_ind=1)
      SET srm_rdds_context_call = manage_rdds_context(null)
      IF (srm_rdds_context_call=0)
       CALL disp_msg("Failed during MANAGE_RDDS_CONTEXT subroutine",dm_err->logfile,1)
       GO TO exit_program
      ELSEIF (srm_rdds_context_call=2)
       ROLLBACK
       RETURN
      ENDIF
     ELSE
      UPDATE  FROM dm_info di
       SET di.info_char = "NULL", di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (di.updt_cnt
        + 1),
        di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task
         = reqinfo->updt_task
       WHERE di.info_domain="RDDS CONTEXT"
        AND di.info_name="CONTEXTS TO PULL"
       WITH nocounter
      ;end update
      IF (curqual=0)
       INSERT  FROM dm_info di
        SET di.info_domain = "RDDS CONTEXT", di.info_name = "CONTEXTS TO PULL", di.info_char = "NULL",
         di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
      ENDIF
      UPDATE  FROM dm_info di
       SET di.info_char = "NULL", di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (di.updt_cnt
        + 1),
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
     SET dm_err->emsg = concat("Event ",srm_open_event_reason," for source environment: ",trim(
       cnvtstring(srm_open_event_source)),
      " is currently open. You cannot open a new RDDS event while another event is open.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     CALL clear(1,1)
     CALL text(15,3,concat("Event: ",srm_open_event_reason))
     CALL text(16,3,concat("For source environment: ",trim(cnvtstring(srm_open_event_source)),
       " is currently open."))
     CALL text(17,3,"You cannot open a new RDDS event while another event is open.")
     CALL text(18,20,"Press ENTER to return to the previous menu.")
     CALL accept(18,64,"P;E"," ")
     SET help = off
     SET validate = off
     RETURN
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
   DECLARE srm_count = i4
   DECLARE rdds_movers = i4
   DECLARE pre_env_id = f8 WITH noconstant(0.0)
   FREE RECORD srm_source
   RECORD srm_source(
     1 srm_cnt = i4
     1 list[*]
       2 env_id = f8
       2 info_domain = vc
       2 env_name = vc
       2 cnt = i4
       2 distr_cnt = i4
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
      col 20, "Environment Name:", col 40,
      dmda_mr->env_name, col 65, "Environment ID:",
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
       WHERE drp.refchg_type="MOVER PROCESS"
        AND  NOT (drp.refchg_status IN ("WRITING HANG FILE", "ORPHANED MOVER", "HANGING MOVER"))
        AND (drp.env_source_id=srm_source->list[d.seq].env_id)
        AND drp.rdbhandle_value IN (
       (SELECT
        audsid
        FROM gv$session)))
      DETAIL
       IF (cnvtupper(drp.log_file)="DM2_RUN_DATA_MVR*.LOG")
        srm_source->list[d.seq].cnt = (srm_source->list[d.seq].cnt+ 1)
       ELSE
        srm_source->list[d.seq].distr_cnt = (srm_source->list[d.seq].distr_cnt+ 1)
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO mine
      FROM (dummyt d  WITH seq = srm_source->srm_cnt)
      HEAD REPORT
       col 35, "*** View RDDS Movers ***", row + 2,
       col 0, "Environment Id", col 18,
       "Environment Name", col 45, "Menu Movers Running",
       col 80, "Interactive/Distributed Mover Running", row + 2,
       pre_env_id = 0.0
      DETAIL
       IF ((srm_source->list[d.seq].env_id != pre_env_id))
        row + 1, col 0, srm_source->list[d.seq].env_id,
        col 18, srm_source->list[d.seq].env_name, col 45,
        srm_source->list[d.seq].cnt, col 80, srm_source->list[d.seq].distr_cnt
       ENDIF
      FOOT REPORT
       pre_env_id = srm_source->list[d.seq].env_id
      WITH nocounter
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
 SUBROUTINE dmda_find_seq_match(null)
   DECLARE dfsm_ret_val = c1
   SET dfsm_ret_val = confirm_sequence_match("TARGET",0)
   IF (dfsm_ret_val="Y")
    CALL get_src_env_id("Begin Sequence Match",1)
    IF (srm_env_id=0)
     RETURN
    ENDIF
    SET message = nowindow
    SET dm_err->eproc = "Executing dm2_rdds_val_reltn"
    EXECUTE dm2_rdds_val_reltn srm_env_id
    IF ((dm_err->err_ind > 0))
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = build("Ready to find sequence match for source domain -",srm_env_id)
    IF (srm_env_id != 0)
     EXECUTE dm2_noupdt_seq_match "*", srm_env_id
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE confirm_sequence_match(environment_name,trig_flag)
   CALL clear(20,1)
   CALL text(20,03,"Running this program will calculate nonexisting Sequence Match rows")
   CALL text(21,03,"for the specified source target relationship.")
   CALL text(24,3,"Would you like to continue?(Y/N)")
   CALL accept(24,40,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE source_environment_change(null)
   CALL clear(20,1)
   CALL text(20,3,
    "This function is currently unavailable...press enter to make a different selection.")
   CALL accept(20,90,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
 END ;Subroutine
 SUBROUTINE manage_rdds_context(null)
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
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="RDDS CONTEXT"
       AND di.info_name="CONTEXTS TO PULL"
      DETAIL
       s_context_to_pull = di.info_char
      WITH nocounter
     ;end select
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,40,"*** Manage RDDS Context ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     IF (s_user_option_pull > "")
      SET s_user_option_main = "E"
     ELSE
      CALL text(9,3,"Current Source Context(s) to Pull:")
      CALL text(10,3,"----------------------------------")
      IF (size(s_context_to_pull,1) > 100)
       SET s_str_first_100 = substring(1,100,s_context_to_pull)
       SET s_col_pos = findstring("::",s_str_first_100,1,1)
       SET s_str_format_100 = substring(1,(s_col_pos - 1),s_str_first_100)
       SET s_str_remain = substring(s_col_pos,size(s_context_to_pull,1),s_context_to_pull)
       CALL text(11,3,trim(s_str_format_100,3))
       CALL text(12,3,trim(s_str_remain,3))
      ELSE
       CALL text(11,3,s_context_to_pull)
      ENDIF
      CALL text(14,3,"E=Edit, C=Continue")
      CALL accept(15,3,"P;CU","C"
       WHERE curaccept IN ("E", "C"))
      SET s_user_option_main = curaccept
     ENDIF
     CASE (s_user_option_main)
      OF "E":
       IF (s_context_to_pull="NULL"
        AND s_first_null=0)
        SET s_user_option_pull = "E"
        SET s_first_null = 1
       ELSE
        CALL clear(8,1)
        CALL text(9,3,"Current Source Context(s) to Pull:")
        CALL text(10,3,"----------------------------------")
        IF (size(s_context_to_pull,1) > 100)
         SET s_str_first_100 = substring(1,100,s_context_to_pull)
         SET s_col_pos = findstring("::",s_str_first_100,1,1)
         SET s_str_format_100 = substring(1,(s_col_pos - 1),s_str_first_100)
         SET s_str_remain = substring(s_col_pos,size(s_context_to_pull,1),s_context_to_pull)
         CALL text(11,3,trim(s_str_format_100,3))
         CALL text(12,3,trim(s_str_remain,3))
        ELSE
         CALL text(11,3,s_context_to_pull)
        ENDIF
        CALL text(14,3,"R=Reset, A=Add, D=Delete, C=Continue")
        CALL accept(15,3,"P;CU","C"
         WHERE curaccept IN ("R", "A", "D", "C"))
        SET s_user_option_pull = curaccept
        CASE (s_user_option_pull)
         OF "R":
          SET s_context_to_pull = "NULL"
         OF "A":
          CALL clear(8,1)
          CALL text(9,3,"Choose a Source Context to Pull")
          CALL text(10,3,"     from the Help Menu:")
          CALL accept(12,3,"P(24);CUF")
          IF (s_context_to_pull > "")
           SET s_context_to_pull = concat(trim(curaccept,3),"::",s_context_to_pull)
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
          IF (s_context_to_pull <= "")
           SET s_context_to_pull = "NULL"
          ENDIF
          SET s_while_ind = 1
        ENDCASE
       ENDIF
      OF "C":
       IF (s_context_to_pull <= "")
        SET s_context_to_pull = "NULL"
       ENDIF
       SET s_while_ind = 1
     ENDCASE
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
        di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
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
   ENDWHILE
   SET help = off
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   SET s_string_match = "*::*"
   IF (((s_context_to_pull=patstring(s_string_match)) OR (s_context_to_pull="ALL")) )
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,45,"*** Group or Maintain Context ***")
    CALL text(9,3,
     "Would you prefer that the Merge and Cut logic maintain the contexts to pull CONTEXT_NAMES when merging,"
     )
    CALL text(10,3,"or would you rather have them grouped into a single context?")
    CALL text(12,20,"G-Group, M-Maintain")
    CALL accept(12,40,"A;CU","M"
     WHERE curaccept IN ("G", "M"))
    IF (curaccept="G")
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
     COMMIT
     IF (((findstring("NULL",s_context_to_pull) > 0) OR (s_context_to_pull="ALL")) )
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain="RDDS CONTEXT"
        AND di.info_name="DEFAULT CONTEXT"
       DETAIL
        s_default_context = di.info_char
       WITH nocounter
      ;end select
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
      IF (size(s_context_to_pull,1) > 100)
       SET s_str_first_100 = substring(1,100,s_context_to_pull)
       SET s_col_pos = findstring("::",s_str_first_100,1,1)
       SET s_str_format_100 = substring(1,(s_col_pos - 1),s_str_first_100)
       SET s_str_remain = substring(s_col_pos,size(s_context_to_pull,1),s_context_to_pull)
       CALL text(14,3,trim(s_str_format_100,3))
       CALL text(15,3,trim(s_str_remain,3))
      ELSE
       CALL text(14,3,s_context_to_pull)
      ENDIF
      CALL text(17,3,"Current Default Context:")
      CALL text(18,3,"-----------------------")
      CALL text(15,60,"** 'ALL' is not a valid Default Context")
      CALL text(17,60,"** ':' is not allowed in Default Context")
      CALL text(19,60,"** All blanks spaces is not a valid Default Context")
      SET s_while2_ind = 1
      WHILE (s_while2_ind=1)
        CALL accept(19,3,"P(24);CU",s_default_context)
        SET s_temp_str = curaccept
        IF (findstring(concat(":",s_temp_str,":"),concat(":",s_context_to_pull,":")) > 0)
         SET s_temp_str = ""
        ELSEIF (s_temp_str="NULL")
         SET s_temp_str = ""
        ELSEIF (s_temp_str="ALL")
         SET s_temp_str = ""
        ELSEIF (size(trim(s_temp_str),1)=0)
         SET s_temp_str = ""
        ELSEIF (findstring(":",s_temp_str) > 0)
         SET s_temp_str = ""
        ELSE
         SET s_default_context = s_temp_str
         SET s_while2_ind = 0
        ENDIF
      ENDWHILE
      UPDATE  FROM dm_info di
       SET di.info_char = s_default_context, di.updt_id = reqinfo->updt_id, di.updt_cnt = (di
        .updt_cnt+ 1),
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
         s_default_context,
         di.info_long_id = 0, di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0,
         di.updt_dt_tm = cnvtdatetime(curdate,curtime), di.updt_id = reqinfo->updt_id, di.updt_task
          = reqinfo->updt_task
        WITH nocounter
       ;end insert
       IF (check_error("Can not add DEFAULT CONTEXT") != 0)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
      ENDIF
     ENDIF
     COMMIT
    ENDIF
   ELSE
    SET cts_check = manage_context_to_set(s_context_to_pull)
    IF (cts_check=2)
     IF ((dm_err->err_ind > 0))
      RETURN(0)
     ELSE
      RETURN(2)
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
   DECLARE cutover_answer = vc
   DECLARE default_message = vc
   SELECT INTO "NL:"
    der.relationship_type
    FROM dm_env_reltn der
    WHERE (der.parent_env_id=dmda_mr->env_id)
     AND (der.child_env_id=dmda_add->child_env_id)
     AND der.relationship_type IN ("AUTO CUTOVER", "PLANNED CUTOVER")
    DETAIL
     default_message = der.relationship_type
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET default_message = "Current configuration : Not yet configured for this relationship"
   ELSEIF (default_message="AUTO CUTOVER")
    SET default_message = "Current configuration : Auto Cutover for this relationship"
   ELSE
    SET default_message = "Current configuration : Planned Cutover for this relationship"
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Merge and Cutover Auto/Planned Confirmation ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(8,3,"Should this relationship be configured for auto-cutover? (Y/N)")
   CALL text(9,3,"By answering 'Y' you will set up this relationship for auto cutover,")
   CALL text(10,3,"by answering 'N' you will set up this relationship for planned cutover.")
   CALL text(11,3,default_message)
   CALL accept(15,90,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   SET cutover_answer = curaccept
   IF (cutover_answer="Y")
    SET stat = alterlist(dera_request->env_list,1)
    SET dera_request->child_env_id = dmda_add->child_env_id
    SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
    SET dera_request->env_list[1].child_env_id = dmda_add->child_env_id
    SET dera_request->env_list[1].relationship_type = "AUTO CUTOVER"
    EXECUTE dm_add_env_reltn
   ELSE
    SET stat = alterlist(dera_request->env_list,1)
    SET dera_request->child_env_id = dmda_add->child_env_id
    SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
    SET dera_request->env_list[1].child_env_id = dmda_add->child_env_id
    SET dera_request->env_list[1].relationship_type = "PLANNED CUTOVER"
    EXECUTE dm_add_env_reltn
   ENDIF
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
   DECLARE default_message = vc
   DECLARE modify_answer = vc
   SELECT INTO "NL:"
    der.relationship_type
    FROM dm_env_reltn der
    WHERE (der.parent_env_id=dmda_mr->env_id)
     AND der.child_env_id=apcm_target_env_id
     AND der.relationship_type IN ("AUTO CUTOVER", "PLANNED CUTOVER")
    DETAIL
     default_message = der.relationship_type
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET default_message = "Current configuration : Not yet configured for this relationship"
   ELSEIF (default_message="AUTO CUTOVER")
    SET default_message = "Current configuration : Auto Cutover for this relationship"
   ELSE
    SET default_message = "Current configuration : Planned Cutover for this relationship"
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Merge and Cutover Auto/Planned Confirmation ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(8,3,concat("Should this relationship be configured for auto-cutover? (Y/N)"))
   CALL text(9,3,"By answering 'Y' you will set up this relationship for auto cutover,")
   CALL text(10,3,"by answering 'N' you will set up this relationship for planned cutover.")
   CALL text(11,3,default_message)
   CALL text(12,3,
    "Please note that any changes will not be committed to the database until you exit the dm_merge_domain_adm menu"
    )
   CALL accept(15,90,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   SET modify_answer = curaccept
   IF (modify_answer="Y")
    UPDATE  FROM dm_env_reltn der
     SET der.relationship_type = "AUTO CUTOVER"
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
     SET dera_request->env_list[1].relationship_type = "AUTO CUTOVER"
     EXECUTE dm_add_env_reltn
    ENDIF
   ELSE
    UPDATE  FROM dm_env_reltn der
     SET der.relationship_type = "PLANNED CUTOVER"
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
     SET dera_request->env_list[1].relationship_type = "PLANNED CUTOVER"
     EXECUTE dm_add_env_reltn
    ENDIF
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
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
      CALL text(14,3,"4 Mover Buffer Time")
      CALL text(17,3,"0 Exit")
      CALL text(20,3,"Please note that any changes made will not be committed to the database until")
      CALL text(21,3,"you exit the dm_merge_domain_adm menu program")
      CALL accept(9,45,"9",0
       WHERE curaccept IN (1, 2, 3, 4, 0))
      CASE (curaccept)
       OF 1:
        CALL target_reactivation(null)
       OF 2:
        CALL mover_batch_size(null)
       OF 3:
        CALL set_log_level(null)
       OF 4:
        CALL mover_buffer_time(null)
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
    "Current setting: Reacitivate inactive rows in the target if the source row is active"
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
    SET batch_size = 20
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
   CALL text(10,3,"The batch size range can be from 1 to 200'.")
   CALL text(12,3,concat("What would you like the batch size to be set at? Current batch size is: ",
     cnvtstring(batch_size)))
   CALL accept(12,90,"P(5);CU","0")
   SET batch_size = cnvtreal(curaccept)
   IF (((batch_size < 1) OR (batch_size > 200)) )
    CALL clear(20,1)
    CALL text(20,3,
     "Invalid batch size entered. The acceptable range for the mover batch size is 1-200. Please try again."
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
    "table. If the option is set to reduce logging, then only INSERT,UPDATE,FAILREASON and BATCH END actions"
    )
   CALL text(10,3,"will be written to the table.")
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
 SUBROUTINE mover_buffer_time(null)
   DECLARE buffer_time = i4
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
    "When an RDDS mover instance attempts to merge a row and cannot, the row's LOG_TYPE attribute is reset"
    )
   CALL text(9,3,
    "to 'REFCHG', and the UPDT_DT_TM is set to a point in time in the future at which the row will be reconsidered"
    )
   CALL text(10,3,"for merge by the mover(s). The range of minutes that can be set is 1 - 1440.")
   CALL text(12,3,"How large of a time buffer would you like to use? (in minutes)")
   CALL accept(12,90,"P(5);CU","0")
   SET buffer_time = cnvtreal(curaccept)
   IF (((buffer_time < 1) OR (buffer_time > 1440)) )
    CALL clear(20,1)
    CALL text(20,3,
     "Invalid buffer time chosen. The acceptable range of minutes to pick from is 1-1440. Please try again."
     )
    CALL pause(3)
    CALL mover_buffer_time(null)
   ENDIF
   UPDATE  FROM dm_info di
    SET di.info_number = buffer_time
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="REFCHG ROW BUFFER"
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = buffer_time, di.info_domain = "DATA MANAGEMENT", di.info_name =
      "REFCHG ROW BUFFER"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE cutover_configuration(null)
   DECLARE cutover_con = i2 WITH protect, noconstant(0)
   DECLARE mm_ret_val = c1
   SET mm_ret_val = confirm_display("TARGET",0)
   IF (mm_ret_val="Y")
    WHILE (cutover_con=0)
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,7,132)
      CALL text(3,40,"***  Cutover Process Management ***")
      CALL text(5,20,"Environment Name:")
      CALL text(5,40,dmda_mr->env_name)
      CALL text(5,65,"Environment ID:")
      CALL text(5,85,cnvtstring(dmda_mr->env_id))
      CALL text(9,3,"Choose from the following options: ")
      CALL text(11,3,"1 Check for Cutover Duplicates")
      CALL text(12,3,"2 View Cutover Duplicates")
      CALL text(13,3,"3 Start Cutover Process")
      CALL text(14,3,"4 View Cutover Processes")
      CALL text(15,3,"5 View Cutover Status")
      CALL text(16,3,"6 View Cutover Warnings")
      CALL text(17,3,"7 View Cutover Free Space Report")
      CALL text(19,3,"0 Exit")
      CALL accept(9,45,"9",0
       WHERE curaccept IN (1, 2, 3, 4, 5,
       6, 7, 0))
      CASE (curaccept)
       OF 1:
        CALL check_cut_dups(null)
       OF 2:
        CALL get_src_env_id("View Cutover Dups",1)
        CALL view_cut_dups(srm_env_id)
       OF 3:
        CALL start_cutover(null)
       OF 4:
        CALL view_cutover_movers(null)
       OF 5:
        CALL view_cutover_status(null)
       OF 6:
        CALL view_cutover_warnings(null)
       OF 7:
        CALL view_free_space(null)
       OF 0:
        SET cutover_con = 1
      ENDCASE
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE check_cut_dups(null)
   SET message = nowindow
   FREE RECORD b_request
   RECORD b_request(
     1 source_env_id = f8
   )
   CALL get_src_env_id("Check Cutover Dups",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   SET b_request->source_env_id = srm_env_id
   EXECUTE dm_rmc_ui_dup_checker  WITH replace(request,b_request)
   IF (check_error("Executing dm_rmc_ui_dup_checker") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   EXECUTE dm_rmc_nsi_dup_check  WITH replace(request,b_request)
   IF (check_error("Executing dm_rmc_nsi_dup_check") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL view_cut_dups(srm_env_id)
 END ;Subroutine
 SUBROUTINE view_cut_dups(src_env_id)
   SELECT INTO mine
    drw2.table_name, drw2.source_env_id, drw2.warning_type,
    drw2.message
    FROM dm_refchg_warning drw2
    WHERE drw2.warning_type IN ("DUP AFTER CUTOVER", "NSI DUPLICATE")
     AND drw2.source_env_id=src_env_id
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_refchg_warning drw3
     WHERE drw3.source_env_id=drw2.source_env_id
      AND drw3.table_name=drw2.table_name
      AND drw3.message=drw2.message
      AND drw3.warning_type="DUP BEFORE CUTOVER")))
    ORDER BY drw2.warning_type, drw2.table_name
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE start_cutover(null)
   CALL clear(1,1)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL parser("cclseclogin go")
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
   CALL stop_ref_mover(null)
   CALL get_src_env_id("Start Cutover Movers",1)
   IF (srm_env_id=0)
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
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  Manage Data Movers ***")
     CALL text(5,20,"Environment Name:")
     CALL text(5,40,dmda_mr->env_name)
     CALL text(5,65,"Environment ID:")
     CALL text(5,85,cnvtstring(dmda_mr->env_id))
     CALL text(14,3,"Should the RDDS cutover process continue to run under the following event?")
     CALL text(15,3,concat("Event: ",sc_open_event_reason))
     CALL accept(16,40,"P;CU","N"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      CALL clear(1,1)
      SET message = window
      CALL text(9,3,"2.  How many cutover processes do you want to start? ")
      CALL accept(9,70,"999",0)
      SET sc_num_mover = curaccept
      SET b_request->num_cutover_processes = sc_num_mover
      SET b_request->source_env_id = srm_env_id
      CALL text(11,3,concat("Please make sure you have ",trim(cnvtstring(sc_num_mover)),
        " instances of the 'CPM Asynch Script' "))
      CALL text(12,3,"server running to support RDDS data movers for all source domains. This is in")
      CALL text(13,3,
       "addition to the number of instances you currently run to support other processes.")
      CALL text(15,3,"Would you like to continue?(Y/N)")
      CALL accept(15,40,"P;CU","N"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="Y")
       SET stat = alterlist(auto_ver_request->qual,1)
       SET auto_ver_request->qual[1].rdds_event = "Cutover Started"
       SET auto_ver_request->qual[1].cur_environment_id = dmda_mr->env_id
       SET auto_ver_request->qual[1].paired_environment_id = srm_env_id
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
       EXECUTE dm_rmc_cutover_main  WITH replace("REQUEST","B_REQUEST"), replace("REPLY","B_REPLY")
      ELSE
       SET help = off
       SET validate = off
       RETURN
      ENDIF
     ELSE
      SET help = off
      SET validate = off
      RETURN
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
   CALL get_src_env_id("View Cutover Processes",1)
   IF (srm_env_id=0)
    RETURN
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
   FREE RECORD vcw_tabs
   RECORD vcw_tabs(
     1 qual[*]
       2 tab_name = vc
       2 completed_count = i4
       2 remaining_count = i4
       2 9000_count = i4
       2 9001_count = i4
       2 9002_count = i4
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
     1 warning_tab = i2
     1 proc_cnt = i2
     1 no_oragen = i2
   )
   CALL get_src_env_id("View Cutover Mover Status",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   CALL get_cutover_status_reports(0,srm_env_id,vcw_tabs)
   WHILE (v_loop=1)
     CALL clear(1,1)
     SET width = 132
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
     CALL text(10,3,"Status: ")
     IF ((vcw_tabs->remaining_rows=0))
      CALL text(10,12,"Completed")
     ELSE
      IF ((vcw_tabs->proc_cnt > 0))
       CALL text(10,12,"In Progress")
      ELSE
       CALL text(10,12,"Stalled")
      ENDIF
     ENDIF
     CALL text(11,3,"Completed Activity:")
     CALL text(11,33,concat(trim(cnvtstring(vcw_tabs->complete_tab))," tables"))
     CALL text(11,58,concat(trim(cnvtstring(vcw_tabs->complete_rows))," rows"))
     CALL text(12,3,"Remaining Activity")
     CALL text(12,33,concat(trim(cnvtstring(vcw_tabs->remaining_tab))," tables"))
     CALL text(12,58,concat(trim(cnvtstring(vcw_tabs->remaining_rows))," rows"))
     CALL text(13,3,"Tables with warnings:")
     CALL text(13,33,concat(trim(cnvtstring(vcw_tabs->warning_tab))," tables"))
     CALL text(15,3,"Choose from the following options for detail reports: ")
     CALL text(16,3,"1 Processing List")
     CALL text(17,3,"2 Pending Processing List")
     CALL text(18,3,"3 Processed List")
     CALL text(19,3,"0 Exit")
     CALL accept(15,61,"9",0
      WHERE curaccept IN (1, 2, 3, 0))
     FREE RECORD vcw_tabs
     RECORD vcw_tabs(
       1 qual[*]
         2 tab_name = vc
         2 completed_count = i4
         2 remaining_count = i4
         2 9000_count = i4
         2 9001_count = i4
         2 9002_count = i4
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
       1 warning_tab = i2
       1 proc_cnt = i2
       1 no_oragen = i2
     )
     CASE (curaccept)
      OF 1:
       CALL get_cutover_status_reports(curaccept,srm_env_id,vcw_tabs)
      OF 2:
       CALL get_cutover_status_reports(curaccept,srm_env_id,vcw_tabs)
      OF 3:
       CALL get_cutover_status_reports(curaccept,srm_env_id,vcw_tabs)
      OF 0:
       SET v_loop = 0
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE view_cutover_warnings(null)
   CALL get_src_env_id("View Cutover Warnings",1)
   IF (srm_env_id=0)
    RETURN
   ENDIF
   DECLARE v_message = vc
   DECLARE v_warning = vc
   DECLARE v_temp = i4
   SELECT
    d.table_name, d.message
    FROM dm_refchg_warning d
    WHERE d.warning_type="TABLE PROCESSING ERROR"
     AND d.source_env_id=srm_env_id
    ORDER BY d.table_name
    HEAD REPORT
     col 0, "Table Name", col 31,
     "Warning Message", col 88, "Comment",
     row + 1, filldash = fillstring(128,"-"), col 0,
     filldash, row + 1
    DETAIL
     v_message = substring(1,30,d.table_name), col 0, v_message,
     v_warning = d.message, v_message = substring(1,55,v_warning), v_temp = size(v_warning,1),
     v_warning = substring(56,(v_temp - 55),v_warning), col 31, v_message,
     v_temp = findstring("ORA-",d.message,1,0)
     IF (v_temp > 0)
      v_message = substring((v_temp+ 4),5,d.message)
     ENDIF
     IF (v_message IN ("01502", "01631", "01632", "01653", "01654",
     "01680", "01691", "08100", "08104"))
      v_message = "Contact DBA"
     ELSEIF (v_message="00001")
      v_message = "Duplicate data moving into live"
     ELSEIF (v_message="20100")
      v_message = "Attempted to update/delete default row"
     ELSE
      v_message = "Investigation Required"
     ENDIF
     col 88, v_message, row + 1,
     v_temp = size(v_warning,1)
     WHILE (v_temp > 0)
       v_message = substring(1,55,v_warning), col 31, v_message,
       v_warning = substring(56,(v_temp - 55),v_warning), v_temp = size(v_warning,1), row + 1
     ENDWHILE
    WITH nocounter, formfeed = none, maxrow = 1
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
       2 9000_count = i4
       2 9001_count = i4
       2 9002_count = i4
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
     1 warning_tab = i2
     1 proc_cnt = i2
     1 no_oragen = i2
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
     "Free space (MB)", row + 1
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
 SUBROUTINE get_cutover_status_reports(i_detail,i_source_env_id,v_tabs)
   DECLARE v_dba = i2 WITH noconstant(0)
   DECLARE v_temp = vc
   DECLARE v_info_domain = vc
   DECLARE v_idx = i4 WITH protect, noconstant(0)
   DECLARE v_pad_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_batch_size = i4 WITH protect, constant(100)
   DECLARE v_estart = i4 WITH protect, noconstant(1)
   DECLARE v_loop_cnt = i4 WITH protect, noconstant(0)
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
     AND (d.rdbhandle_value=
    (SELECT
     audsid
     FROM gv$session))
    DETAIL
     v_tabs->proc_cnt = s_cnt
    WITH nocounter
   ;end select
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
       GROUP BY d.rdds_status_flag
       DETAIL
        IF (d.rdds_status_flag=9999)
         v_tabs->qual[i].completed_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (d.rdds_status_flag=9000)
         v_tabs->qual[i].9000_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (d.rdds_status_flag=9001)
         v_tabs->qual[i].9001_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (d.rdds_status_flag=9002)
         v_tabs->qual[i].9002_count = q_count, v_tabs->complete_rows = (v_tabs->complete_rows+
         q_count)
        ELSEIF (d.rdds_status_flag > 9002)
         v_tabs->qual[i].9000up_count = (v_tabs->qual[i].9000up_count+ q_count), v_tabs->
         complete_rows = (v_tabs->complete_rows+ q_count)
        ELSE
         v_tabs->qual[i].remaining_count = (v_tabs->qual[i].remaining_count+ q_count), v_tabs->
         remaining_rows = (v_tabs->remaining_rows+ q_count)
        ENDIF
       WITH nocounter
      ;end select
      IF ((v_tabs->qual[i].completed_count > 0))
       SET v_tabs->complete_tab = (v_tabs->complete_tab+ 1)
      ENDIF
      IF ((v_tabs->qual[i].remaining_count > 0))
       SET v_tabs->remaining_tab = (v_tabs->remaining_tab+ 1)
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
     HEAD REPORT
      loc = 0, col 0, "Status: "
      IF ((v_tabs->remaining_rows=0))
       col + 2, "Completed"
      ELSE
       IF ((v_tabs->proc_cnt > 0))
        col + 2, "In Progress"
       ELSE
        col + 2, "Stalled"
       ENDIF
      ENDIF
      row + 1, col 0, "Completed Activity:",
      col 30, v_tabs->complete_tab, col + 2,
      "tables", col 55, v_tabs->complete_rows,
      col + 2, "rows", row + 1,
      col 0, "Remaining Activity", col 30,
      v_tabs->remaining_tab, col + 2, "tables",
      col 55, v_tabs->remaining_rows, col + 2,
      "rows", row + 1, col 0,
      "Tables with warnings:", col 30, v_tabs->warning_tab,
      col + 2, "tables", row + 3,
      col 0, "Table Name", col 32,
      "Rows to Process", col 49, "Stmt Running",
      col 65, "Time current stmt started", row + 1
     DETAIL
      v_index = locateval(loc,1,v_tabs->qual_cnt,drs.table_name,v_tabs->qual[loc].tab_name)
      IF ((v_tabs->qual[v_index].process_flag=1))
       col 0, drs.table_name, col 32,
       v_tabs->qual[v_index].remaining_count, v_temp = concat(trim(cnvtstring(drs.cur_stmt_nbr)),
        " of ",trim(cnvtstring(drs.stmt_cnt))), col 49,
       v_temp, v_temp = format(drs.cur_stmt_dt_tm,";;q"), col 65,
       v_temp, row + 1
      ENDIF
     WITH nocounter, formfeed = none, maxrow = 1
    ;end select
    SET stat = alterlist(v_tabs->qual,v_tabs->qual_cnt)
   ELSEIF (i_detail=2)
    SELECT INTO mine
     FROM (dummyt d  WITH seq = v_tabs->qual_cnt)
     HEAD REPORT
      col 0, "Status: "
      IF ((v_tabs->remaining_rows=0))
       col + 2, "Completed"
      ELSE
       IF ((v_tabs->proc_cnt > 0))
        col + 2, "In Progress"
       ELSE
        col + 2, "Stalled"
       ENDIF
      ENDIF
      row + 1, col 0, "Completed Activity:",
      col 30, v_tabs->complete_tab, col + 2,
      "tables", col 55, v_tabs->complete_rows,
      col + 2, "rows", row + 1,
      col 0, "Remaining Activity", col 30,
      v_tabs->remaining_tab, col + 2, "tables",
      col 55, v_tabs->remaining_rows, col + 2,
      "rows", row + 1, col 0,
      "Tables with warnings:", col 30, v_tabs->warning_tab,
      col + 2, "tables", row + 3,
      col 0, "Table Name", col 32,
      "Rows to Process", row + 1
     DETAIL
      IF ((v_tabs->qual[d.seq].remaining_count > 0))
       col 0, v_tabs->qual[d.seq].tab_name, col 32,
       v_tabs->qual[d.seq].remaining_count, row + 1
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
     HEAD REPORT
      loc = 0, col 0, "Status: "
      IF ((v_tabs->remaining_rows=0))
       col + 2, "Completed"
      ELSE
       IF ((v_tabs->proc_cnt > 0))
        col + 2, "In Progress"
       ELSE
        col + 2, "Stalled"
       ENDIF
      ENDIF
      row + 1, col 0, "Completed Activity:",
      col 30, v_tabs->complete_tab, col + 2,
      "tables", col 55, v_tabs->complete_rows,
      col + 2, "rows", row + 1,
      col 0, "Remaining Activity", col 30,
      v_tabs->remaining_tab, col + 2, "tables",
      col 55, v_tabs->remaining_rows, col + 2,
      "rows", row + 1, col 0,
      "Tables with warnings:", col 30, v_tabs->warning_tab,
      col + 2, "tables", row + 3,
      col 0, "Table Name", col 32,
      "Inserted", col 42, "Updated",
      col 52, "Deleted", col 62,
      "Set Aside Manually", col 85, "Duplicates ",
      col 100, "Combined Away Values", col 130,
      "Others", col 145, "Time Started",
      col 170, "Time Completed", col 195,
      "Seconds to Run", row + 1
     DETAIL
      v_index = locateval(loc,1,v_tabs->qual_cnt,drs.table_name,v_tabs->qual[loc].tab_name)
      IF ((v_tabs->qual[v_index].process_flag=2))
       col 0, v_tabs->qual[v_index].tab_name, v_temp = trim(cnvtstring(drs.ins_row_cnt)),
       col 32, v_temp, v_temp = trim(cnvtstring(drs.upd_row_cnt)),
       col 42, v_temp, v_temp = trim(cnvtstring(drs.del_row_cnt)),
       col 51, v_temp, v_temp = format(v_tabs->qual[v_index].start_date,";;q"),
       col 62, v_tabs->qual[v_index].9000_count, col 85,
       v_tabs->qual[v_index].9001_count, col 100, v_tabs->qual[v_index].9002_count,
       col 130, v_tabs->qual[v_index].9000up_count, col 145,
       v_temp, v_temp = format(v_tabs->qual[v_index].end_date,";;q"), col 170,
       v_temp, v_temp = cnvtstring(datetimediff(v_tabs->qual[v_index].end_date,v_tabs->qual[v_index].
         start_date,5)), col 195,
       v_temp, row + 1
      ENDIF
     WITH nocounter, formfeed = none, maxrow = 1,
      maxcol = 250
    ;end select
    SET stat = alterlist(v_tabs->qual,v_tabs->qual_cnt)
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
     CALL text(18,3,"E=Edit, C=Continue")
     CALL accept(19,3,"P;CU","C"
      WHERE curaccept IN ("E", "C"))
     SET s_user_option_set = curaccept
     CASE (s_user_option_set)
      OF "E":
       CALL text(18,3,"Edit Context to Set:")
       CALL accept(19,3,"P(24);CUH","")
       SET s_context_set = trim(curaccept,3)
       CALL clear(15,3,30)
       CALL text(15,3,s_context_set)
      OF "C":
       SET s_while2_ind = 1
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
     IF (s_context_set <= " ")
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
   DECLARE srm_ptam_check = i2
   DECLARE srm_sc_explode = i2
   DECLARE srm_dcl_check = i2
   DECLARE srm_msg = i2
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
    CALL text(09,03,"This environment has been configured as a mock_target.")
    CALL text(10,03,"Any existing translations or sequence match rows will be used")
    CALL text(11,03,"in processing change log rows from the build_source.")
    CALL text(12,03,
     "New translations created will utilize the environment id of the replicated environment.")
    CALL text(14,03,"Do you want to continue (Y/N)?")
    CALL accept(14,70,"P;CU","N"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     CALL clear(1,1)
     SET dm_err->eproc = "USER CONFIRMATION:USER CHOSE TO QUIT PROGRAM"
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
   ENDIF
   SET dm_err->eproc = "Executing dm2_rdds_val_reltn"
   EXECUTE dm2_rdds_val_reltn srm_env_id
   IF ((dm_err->err_ind > 0))
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Checking backfill events"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "NL:"
    FROM dm_rdds_event_log drel
    WHERE (drel.cur_environment_id=dmda_mr->env_id)
     AND drel.rdds_event_key="ENDSINGLECOMMITBACKFILL"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET srm_sc_explode = curqual
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
    WHERE drel.rdds_event_key="ENDDMREFCHGPKWVERSIDBACKFILL"
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
   SET srm_msg = dmda_disp_backfill_msgs(srm_sc_explode,srm_ptam_check,srm_dcl_check,0,1)
   IF (srm_msg=0)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ELSEIF (srm_msg=1)
    RETURN
   ENDIF
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL box(1,1,7,132)
   CALL text(3,40,"***  Manage Data Movers ***")
   CALL text(5,20,"Environment Name:")
   CALL text(5,40,dmda_mr->env_name)
   CALL text(5,65,"Environment ID:")
   CALL text(5,85,cnvtstring(dmda_mr->env_id))
   CALL text(9,3,"2.  How many movers do you want to start: ")
   CALL accept(9,70,"999",0)
   SET srm_num_mover = curaccept
   SET srm_info_domain = build("MERGE",cnvtstring(srm_env_id),cnvtstring(dmda_mr->env_id))
   SET srm_tot_domain = build("MERGE*",cnvtstring(dmda_mr->env_id))
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
     SET info_number = srm_num_mover, info_domain = srm_info_domain, info_name = "RDDS MOVERS TO RUN",
      updt_dt_tm = sysdate, updt_cnt = 0
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN
   ENDIF
   SET dm_err->eproc = "Insert/Update RDDS MOVERS RUNNING in table DM_INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info
    WHERE info_domain=srm_info_domain
     AND info_name="RDDS MOVERS RUNNING"
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN
    ENDIF
    SET dm_err->eproc = "Update RDDS MOVERS RUNNING in table DM_INFO"
    INSERT  FROM dm_info
     SET info_number = 0, info_domain = srm_info_domain, info_name = "RDDS MOVERS RUNNING",
      updt_dt_tm = sysdate, updt_cnt = 0
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN
   ENDIF
   SELECT INTO "nl:"
    tot = sum(info_number)
    FROM dm_info di
    WHERE di.info_domain=patstring(srm_tot_domain)
     AND di.info_name="RDDS MOVERS TO RUN"
    DETAIL
     srm_nbr = tot
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN
   ENDIF
   CALL text(11,3,concat("Please make sure you have ",trim(cnvtstring(srm_nbr)),
     " instances of the 'CPM Asynch Script' "))
   CALL text(12,3,"server running to support RDDS data movers for all source domains. This is in")
   CALL text(13,3,"addition to the number of instances you currently run to support other processes."
    )
   CALL text(15,3,"Would you like to continue?(Y/N)")
   CALL accept(15,40,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    IF (cutover_flag=1)
     UPDATE  FROM dm_info di
      SET info_domain = "RDDS CONFIGURATION", info_name = "FORCE DROP $R", info_number = 0
      WHERE info_domain="RDDS CONFIGURATION"
       AND info_name="FORCE DROP $R"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_info
       SET info_domain = "RDDS CONFIGURATION", info_name = "FORCE DROP $R", info_number = 0
       WITH nocounter
      ;end insert
     ENDIF
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
     CALL text(11,3,"4. Cutover configuration is NOT complete, no mover will start")
     CALL text(12,20,"Press ENTER to continue")
     CALL accept(12,60,"P;E"," ")
     ROLLBACK
     RETURN
    ENDIF
    SET srm_msg = dmda_disp_backfill_msgs(srm_sc_explode,srm_ptam_check,srm_dcl_check,1,1)
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
     EXECUTE dm_rmc_correct_dcl  WITH replace("REQUEST","DCL_REQUEST"), replace("REPLY","DCL_REPLY")
     IF ((dcl_reply->status_data.status="F"))
      SET message = nowindow
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     SELECT INTO "NL:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event_key="ENDDMREFCHGPKWVERSIDBACKFILL"
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
      SET dm_err->eproc = "Checking event row for PK VersID Backfill (ENDDMREFCHGPKWVERSIDBACKFILL)"
      SET dm_err->emsg = "PK VersID Backfill has not been completed; cannot start movers"
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO exit_program
     ENDIF
    ENDIF
    SET message = nowindow
    COMMIT
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
    IF (dsrm_refresh_trig_ind=1)
     SET dm_err->eproc =
     "Refreshing meta-data and $R triggers. This process will take a few minutes."
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL pause(5)
     SET srm_request->post_link_name = concat("@MERGE",trim(cnvtstring(srm_env_id)),trim(cnvtstring(
        dmda_mr->env_id)))
     SET srm_request->source_env_id = srm_env_id
     SET srm_request->target_env_id = dmda_mr->env_id
     EXECUTE dm2_refresh_local_meta_data  WITH replace("REQUEST","SRM_REQUEST")
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     EXECUTE dm_create_rmc_triggers "*"
     IF ((dm_err->err_ind=1))
      RETURN
     ENDIF
    ENDIF
    EXECUTE dm2_cycle_data_movers
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ELSE
    RETURN
    ROLLBACK
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_manage_rdds_event(null)
   DECLARE dsmme_user_input = i2
   DECLARE dsmme_done_flag = i2
   SET dsmme_done_flag = 0
   WHILE (dsmme_done_flag=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,"***  MANAGE RDDS EVENTS  ***")
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(dmda_mr->env_id))
     CALL text(4,40,dmda_mr->env_name)
     CALL text(7,3,"Please choose from the following options:")
     CALL text(9,3,"1 Open a new RDDS event")
     CALL text(10,3,"2 Close an open RDDS event")
     CALL text(11,3,"3 Drop old $R tables")
     CALL text(12,3,"(0 to exit)")
     CALL accept(7,50,"9",0
      WHERE curaccept IN (1, 2, 3, 0))
     SET dsmme_user_input = curaccept
     CASE (dsmme_user_input)
      OF 1:
       CALL dmda_open_rdds_event(0.0)
      OF 2:
       CALL dmda_close_rdds_event(null)
      OF 3:
       CALL dmda_drop_old_r(null)
      OF 0:
       SET dsmme_done_flag = 1
       SET help = off
       SET validate = off
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dmda_open_rdds_event(ore_src_env_id)
   DECLARE dmoe_done_flag = i2
   DECLARE dmoe_new_event_name = vc
   DECLARE dmoe_open_event = vc
   DECLARE dmoe_open_source = f8
   DECLARE dmoe_tgt_env_name = vc
   DECLARE dmoe_exit_ind = i2
   DECLARE oe_ptam_check = i2
   DECLARE oe_sc_explode = i2
   DECLARE oe_dcl_check = i2
   DECLARE oe_msg = i2
   IF (ore_src_env_id=0)
    CALL get_src_env_id("Open An RDDS Event",1)
   ENDIF
   IF (srm_env_id=0)
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ENDIF
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
    IF (curqual=0)
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
   EXECUTE dm_rmc_bookmark_begin srm_env_id, dmda_mr->env_id, dmoe_new_event_name,
   1, 0
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Checking backfill events"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "NL:"
    FROM dm_rdds_event_log drel
    WHERE (drel.cur_environment_id=dmda_mr->env_id)
     AND drel.rdds_event_key="ENDSINGLECOMMITBACKFILL"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET oe_sc_explode = curqual
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
   SET oe_ptam_check = curqual
   SET oe_dcl_check = 0
   SET oe_msg = dmda_disp_backfill_msgs(oe_sc_explode,oe_ptam_check,oe_dcl_check,1,0)
   IF (oe_msg=0)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ELSEIF (oe_msg=1)
    SET help = off
    SET validate = off
    SET dmoe_exit_ind = 1
    RETURN(dmoe_exit_ind)
   ELSEIF (oe_msg=2)
    SET dm_err->eproc = "Correcting dm_chg_log for the Pending Target as Master environment"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dcl_request->target_id = srm_env_id
    SET dcl_request->log_id = 0
    EXECUTE dm_rmc_correct_dcl  WITH replace("REQUEST","DCL_REQUEST"), replace("REPLY","DCL_REPLY")
    IF ((dcl_reply->status_data.status="F"))
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="ENDDMREFCHGPKWVERSIDBACKFILL"
      AND (drel.cur_environment_id=dmda_mr->env_id)
      AND drel.paired_environment_id=srm_env_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual=0)
     SET message = nowindow
     SET dm_err->eproc = "Checking event row for PK VersID Backfill (ENDDMREFCHGPKWVERSIDBACKFILL)"
     SET dm_err->emsg = "PK VersID Backfill has not been completed; cannot start movers"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
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
    CALL clear(1,1)
    CALL text(16,3,concat("Are you sure you want to close the ",dmce_old_event_name," event? (Y/N)"))
    CALL accept(17,65,"P;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     SET help = off
     SET validate = off
     RETURN
    ENDIF
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
    IF (check_error("Check if a MOVER PROCESS is running in the current environment.") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET help = off
     SET validate = off
     RETURN
    ENDIF
    IF (curqual > 0)
     SET dm_err->emsg =
     "There is a merge in process for this environment. You cannot close an RDDS event until the merge is completed."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL clear(1,1)
     CALL text(15,3,
      "There is a merge in process for this environment. You cannot close an RDDS event until the merge is completed."
      )
     CALL text(16,20,"Press ENTER to return to the previous menu.")
     CALL accept(16,64,"P;E"," ")
     SET help = off
     SET validate = off
     RETURN
    ELSE
     SELECT INTO "NL:"
      FROM dm_refchg_process d
      WHERE d.refchg_type="CUTOVER PROCESS*"
       AND  EXISTS (
      (SELECT
       "X"
       FROM gv$session g
       WHERE g.audsid=d.rdbhandle_value))
      WITH nocounter
     ;end select
     IF (check_error("Check if any CUTOVER PROCESS is running for this environment") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET help = off
      SET validate = off
      RETURN
     ENDIF
     IF (curqual > 0)
      SET dm_err->emsg =
      "There is a merge in process for this environment. You cannot close an RDDS event until the merge is completed."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL clear(1,1)
      CALL text(15,3,
       "There is a cutover in process for this environment. You cannot close an RDDS event until the merge is completed."
       )
      CALL text(16,20,"Press ENTER to return to the previous menu.")
      CALL accept(16,64,"P;E"," ")
      SET help = off
      SET validate = off
      RETURN
     ELSE
      SELECT INTO "NL:"
       FROM user_tables u
       WHERE u.table_name="*$R"
       HEAD REPORT
        cnt = 0
       DETAIL
        cnt = (cnt+ 1)
        IF (mod(cnt,10)=1)
         stat = alterlist(r_table->qual,(cnt+ 9))
        ENDIF
        r_table->qual[cnt].tab_name = u.table_name
       FOOT REPORT
        stat = alterlist(r_table->qual,cnt), r_table->qual_cnt = cnt
       WITH nocounter
      ;end select
      FOR (i = 1 TO r_table->qual_cnt)
       SELECT INTO "NL:"
        FROM (parser(r_table->qual[i].tab_name) d)
        WHERE d.rdds_status_flag < 9000
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET dm_err->emsg =
        "There are rows left to cutover. You cannot close an RDDS event until all rows have been cutover."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        CALL clear(1,1)
        CALL text(15,3,
         "There are rows left to cutover. You cannot close an RDDS event until all rows have been cutover."
         )
        CALL text(16,20,"Press ENTER to return to the previous menu.")
        CALL accept(16,64,"P;E"," ")
        SET help = off
        SET validate = off
        RETURN
       ENDIF
      ENDFOR
      SET stat = alterlist(r_table->qual,0)
      SET r_table->qual_cnt = 0
     ENDIF
    ENDIF
    EXECUTE dm_rmc_bookmark_end srm_env_id, dmda_mr->env_id, dmce_old_event_name
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
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
    CALL text(13,3,"0 Exit")
    CALL accept(7,50,"99",0
     WHERE curaccept IN (1, 2, 3, 0))
    CASE (curaccept)
     OF 1:
      EXECUTE dm_auto_verify_rpt
      IF ((dm_err->err_ind=1))
       GO TO exit_program
      ENDIF
     OF 2:
      CALL dmda_monitor_tools(null)
     OF 3:
      CALL dmda_ref_data_audit(null)
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
   SELECT INTO "nl:"
    FROM dm_env_reltn der,
     dm_environment de1,
     dm_environment de2
    WHERE der.relationship_type="REFERENCE MERGE"
     AND de1.environment_id=der.parent_env_id
     AND de2.environment_id=der.child_env_id
    ORDER BY de1.environment_name
    HEAD REPORT
     dmt_env->cnt = 0
    DETAIL
     dmt_env->cnt = (dmt_env->cnt+ 1)
     IF (mod(dmt_env->cnt,10)=1)
      stat = alterlist(dmt_env->qual,(dmt_env->cnt+ 9))
     ENDIF
     dmt_env->qual[dmt_env->cnt].source_id = de1.environment_id, dmt_env->qual[dmt_env->cnt].
     source_name = de1.environment_name, dmt_env->qual[dmt_env->cnt].target_id = de2.environment_id,
     dmt_env->qual[dmt_env->cnt].target_name = de2.environment_name
    FOOT REPORT
     stat = alterlist(dmt_env->qual,dmt_env->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dmt_total = dmt_env->cnt
   SET dmt_low = 1
   IF (dmt_total < dmt_incr)
    SET dmt_high = dmt_total
   ELSE
    SET dmt_high = dmt_incr
   ENDIF
   SET dmt_up = 0
   SET dmt_down = 0
   WHILE (dmt_choice=0)
     IF (dmt_down=1)
      SET dmt_low = (dmt_low+ dmt_incr)
      IF (((dmt_high+ dmt_incr) > dmt_total))
       SET dmt_over = ((dmt_high+ dmt_incr) - dmt_total)
       SET dmt_high = dmt_total
      ELSE
       SET dmt_over = 0
       SET dmt_high = (dmt_high+ dmt_incr)
      ENDIF
     ELSEIF (dmt_up=1)
      IF (((dmt_low - dmt_incr) >= 1))
       SET dmt_low = (dmt_low - dmt_incr)
       SET dmt_high = ((dmt_high - dmt_incr)+ dmt_over)
       SET dmt_over = 0
      ENDIF
     ENDIF
     SET dmt_up = 0
     SET dmt_down = 0
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,5,132)
     CALL text(2,43,"***  RDDS STATUS AND MONITORING TOOLS  ***")
     CALL text(4,2,"Line #")
     CALL text(4,30,"SOURCE")
     CALL text(4,90,"TARGET")
     SET row_num = 6
     FOR (idx = dmt_low TO dmt_high)
       CALL text(row_num,2,concat(trim(cnvtstring(idx)),")"))
       CALL text(row_num,20,trim(cnvtstring(dmt_env->qual[idx].source_id)))
       CALL text(row_num,40,dmt_env->qual[idx].source_name)
       CALL text(row_num,80,trim(cnvtstring(dmt_env->qual[idx].target_id)))
       CALL text(row_num,100,dmt_env->qual[idx].target_name)
       SET row_num = (row_num+ 1)
     ENDFOR
     IF (((dmt_low+ dmt_incr) <= dmt_total))
      CALL text(22,3,"D) Page Down")
     ENDIF
     IF (dmt_low > dmt_incr)
      CALL text(21,3,"U) Page Up")
     ENDIF
     CALL text(24,3,"0) Exit")
     CALL text(23,3,concat("Choose a line # (",trim(cnvtstring(dmt_low)),"-",trim(cnvtstring(dmt_high
         )),") for setup"))
     CALL accept(23,40,"PPP;CU","0")
     SET dmt_str = trim(curaccept)
     SET dmt_num = - (1)
     IF (isnumeric(dmt_str)=1)
      SET dmt_num = cnvtint(dmt_str)
      IF (dmt_num != 0
       AND ((dmt_num < dmt_low) OR (dmt_num > dmt_high)) )
       CALL text(23,58,"Invalid Entry")
       CALL pause(2)
       SET dmt_num = - (1)
      ENDIF
     ELSEIF (dmt_str="U")
      IF (dmt_low > dmt_incr)
       SET dmt_up = 1
      ELSE
       CALL text(23,58,"Invalid Entry")
       CALL pause(2)
      ENDIF
     ELSEIF (dmt_str="D")
      IF (((dmt_low+ dmt_incr) <= dmt_total))
       SET dmt_down = 1
      ELSE
       CALL text(23,58,"Invalid Entry")
       CALL pause(2)
      ENDIF
     ELSE
      CALL text(23,58,"Invalid Entry")
      CALL pause(2)
     ENDIF
     IF ((dmt_num > - (1)))
      IF (dmt_num=0)
       SET dmt_choice = 1
      ELSE
       SET dm_err->eproc = "Filling out default values"
       SELECT INTO "nl:"
        FROM dm2_admin_dm_info dadi
        WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].source_id)),
         "|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
         AND dadi.info_name="Report Frequency"
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (curqual=0)
        INSERT  FROM dm2_admin_dm_info dadi
         SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].source_id)),
           "|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi.info_name =
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
        WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].source_id)),
         "|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
         AND dadi.info_name="Suppression Duration"
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (curqual=0)
        INSERT  FROM dm2_admin_dm_info dadi
         SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].source_id)),
           "|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi.info_name =
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
         CALL text(2,45,"***  MONITORING PREFERENCES SETUP  ***")
         CALL text(4,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",trim(
            cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
         CALL text(4,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",trim(
            cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
         CALL text(7,3,"Please choose from the following options:")
         CALL text(9,3,"1 View current settings")
         CALL text(10,3,"2 Manage E-Mail addresses")
         CALL text(11,3,"3 Manage warning message suppression")
         CALL text(12,3,"4 Manage status report frequency")
         CALL text(13,3,"5 Manage E-Mail subject prefix")
         CALL text(14,3,"6 Replicate monitoring preferences from another environment pair")
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
            WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].source_id
               )),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
           SET dmt_s_temp_id = concat(trim(dmt_env->qual[dmt_num].source_name)," (",trim(cnvtstring(
              dmt_env->qual[dmt_num].source_id)),")")
           SET dmt_t_temp_id = concat(trim(dmt_env->qual[dmt_num].target_name)," (",trim(cnvtstring(
              dmt_env->qual[dmt_num].target_id)),")")
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
             rpt_loop = 0, col 50, "CURRENT SETTINGS",
             row + 1, col 20, "SOURCE:",
             col 30, dmt_s_temp_id, col 60,
             "TARGET:", col 70, dmt_t_temp_id,
             row + 2, col 2, "Warning Suppression Time in hours: ",
             col 37, dmt_temp_supp, row + 1,
             col 2, "Status Report Frequency: ", col 28,
             dmt_temp_freq, row + 1, col 2,
             "E-Mail Prefix: "
             IF (trim(dmt_view->prefix) > "")
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
              WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                 source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
               CALL text(2,50,"***  E-MAIL SETTING  ***")
               CALL text(3,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",trim(
                  cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
               CALL text(3,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",trim(
                  cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
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
                   CALL text(2,50,"***  ADD E-MAIL  ***")
                   CALL text(3,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",
                     trim(cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
                   CALL text(3,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",
                     trim(cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
                   CALL text(11,40,"Please input an e-mail address and press enter")
                   CALL accept(10,10,"P(110);C"," ")
                   SET dmt_temp_email = trim(curaccept)
                   CALL text(14,10,"Continue ?( (Y)es/(N)o/e(X)it )")
                   CALL accept(14,43,"P;CU","Y"
                    WHERE curaccept IN ("Y", "N", "X"))
                   IF (curaccept="Y")
                    SET dmt_idx2 = 0
                    SET dmt_idx2 = locateval(idx3,1,dmt_email->cnt,dmt_temp_email,dmt_email->qual[
                     idx3].email)
                    IF (dmt_idx2 > 0)
                     CALL text(20,10,"This e-mail already exists for the current environment")
                     CALL pause(5)
                     SET dmt_echoice = 1
                     SET dmt_add_email_choice = 1
                    ELSEIF (trim(dmt_temp_email) > "")
                     INSERT  FROM dm2_admin_dm_info dadi
                      SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num]
                          .source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi
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
                  WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                     source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
                   CALL text(2,50,"***  EDIT E-MAIL  ***")
                   CALL text(3,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",
                     trim(cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
                   CALL text(3,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",
                     trim(cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
                   CALL text(11,50,"Please edit the e-mail address and press enter")
                   CALL accept(10,10,"P(110);C",dmt_email->qual[dmt_enum].email
                    WHERE trim(curaccept) > "")
                   SET dmt_temp_email = trim(curaccept)
                   CALL text(14,10,"Continue? ( (Y)es/(N)o/e(X)it )")
                   CALL accept(14,43,"P;CU","Y"
                    WHERE curaccept IN ("Y", "N", "X"))
                   IF (curaccept="Y")
                    SET dmt_idx2 = 0
                    SET dmt_idx2 = locateval(idx3,1,dmt_email->cnt,dmt_temp_email,dmt_email->qual[
                     idx3].email)
                    IF (dmt_idx2 > 0)
                     CALL text(20,10,
                      "This e-mail already exists for the current environment, nothing was modified")
                     CALL pause(5)
                     SET dmt_echoice = 1
                     SET dmt_email_edit_choice = 1
                    ELSE
                     UPDATE  FROM dm2_admin_dm_info dadi
                      SET dadi.info_name = dmt_temp_email
                      WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num]
                         .source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
             CALL text(2,45,"***  SUPRESSION TIME SETTING  ***")
             CALL text(4,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",trim(
                cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
             CALL text(4,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",trim(
                cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
             SELECT INTO "nl:"
              FROM dm2_admin_dm_info dadi
              WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                 source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
               WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                  source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
                SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                    source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi
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
             CALL text(2,45,"***  REPORT FREQUENCY SETTING  ***")
             CALL text(4,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",trim(
                cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
             CALL text(4,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",trim(
                cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
             SELECT INTO "nl:"
              FROM dm2_admin_dm_info dadi
              WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                 source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
                 WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                    source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
                  SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                      source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi
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
                 WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                    source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
                  SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                      source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi
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
                 WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                    source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
                  SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                      source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi
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
             CALL text(2,45,"***  E-MAIL PREFIX SETTING  ***")
             CALL text(4,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",trim(
                cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
             CALL text(4,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",trim(
                cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
             SELECT INTO "nl:"
              FROM dm2_admin_dm_info dadi
              WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                 source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
              IF (trim(dmt_prefix) > "")
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
               WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                  source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
                SET dadi.info_domain = concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                    source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi
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
            WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].source_id
               )),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
            WITH nocounter
           ;end select
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            GO TO exit_program
           ENDIF
           IF (curqual > 0)
            CALL text(20,3,"Monitoring preferences for this environment pair have already been set.")
            CALL text(21,3,
             "If you continue forward these setting will be deleted. Continue ? ( (Y)es/(N)o )")
            CALL accept(21,86,"P;CU","Y"
             WHERE curaccept IN ("Y", "N"))
            IF (curaccept="Y")
             SET dmt_delete_cur = 1
             DELETE  FROM dm2_admin_dm_info dadi
              WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                 source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
            SET dmt_set_cnt = 0
            FOR (dmt_cp_idx = 1 TO dmt_env->cnt)
              SELECT INTO "nl:"
               FROM dm2_admin_dm_info dadi
               WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_cp_idx].
                  source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_cp_idx].target_id)))
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
              CALL box(1,1,7,132)
              CALL text(2,50,"***  COPY SETTING  ***")
              CALL text(4,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",trim(
                 cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
              CALL text(4,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",trim(
                 cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
              CALL text(6,2,"Line #")
              CALL text(6,30,"SOURCE")
              CALL text(6,90,"TARGET")
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
                CALL text(row_num,20,cnvtstring(dmt_env->qual[dmt_sidx].source_id))
                CALL text(row_num,40,dmt_env->qual[dmt_sidx].source_name)
                CALL text(row_num,80,cnvtstring(dmt_env->qual[dmt_sidx].target_id))
                CALL text(row_num,100,dmt_env->qual[dmt_sidx].target_name)
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
                  concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].source_id)),"|",trim(
                    cnvtstring(dmt_env->qual[dmt_num].target_id))), dadi2.info_name, dadi2.info_char,
                  dadi2.info_number
                  FROM dm2_admin_dm_info dadi2
                  WHERE dadi2.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_sidx].
                     source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_sidx].target_id))))
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
           SET drrm_events->source_env_id = dmt_env->qual[dmt_num].source_id
           SET drrm_events->target_env_id = dmt_env->qual[dmt_num].target_id
           SET drrm_events->link_name = concat(trim(cnvtstring(dmt_env->qual[dmt_num].source_id)),"|",
            trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
           SET drrm_events->file_name = "testst.txt"
           SET drrm_events->unrprtd_cnt = 1
           SET dm_err->err_ind = 0
           IF (drrm_get_mail_list(drrm_events,drrm_email_address)=0)
            SET dm_err->err_ind = 1
           ENDIF
           IF ((dm_err->err_ind=0))
            SELECT INTO "nl:"
             FROM dm2_admin_dm_info dadi
             WHERE dadi.info_domain=concat("RDDSPREF",trim(cnvtstring(dmt_env->qual[dmt_num].
                source_id)),"|",trim(cnvtstring(dmt_env->qual[dmt_num].target_id)))
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
            CALL text(2,50,"***  TEST E-MAIL  ***")
            CALL text(4,25,concat("SOURCE: ",trim(dmt_env->qual[dmt_num].source_name)," (",trim(
               cnvtstring(dmt_env->qual[dmt_num].source_id)),")"))
            CALL text(4,80,concat("TARGET: ",trim(dmt_env->qual[dmt_num].target_name)," (",trim(
               cnvtstring(dmt_env->qual[dmt_num].target_id)),")"))
            CALL text(13,40,"Ready to send test e-mail.")
            CALL text(14,40,"Continue ? ( (Y)es/(N)o )")
            CALL accept(14,67,"X;CU","N"
             WHERE curaccept IN ("Y", "N"))
            IF (curaccept="Y")
             IF ((dm_err->err_ind=0))
              IF (drrm_get_env_names(drrm_events)=0)
               SET dm_err->err_ind = 1
              ENDIF
             ENDIF
             IF ((dm_err->err_ind=0))
              IF (drrm_create_subject("Test",drrm_events)=0)
               SET dm_err->err_ind = 1
              ENDIF
             ENDIF
             IF ((dm_err->err_ind=0))
              IF (drrm_generate_email_text(1,drrm_events)=0)
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
   DECLARE drdar_rep_name = vc
   DECLARE drdar_tab_name = vc
   DECLARE drdar_size_ind = vc
   DECLARE drdar_source_id = f8
   DECLARE drdar_cgl_ind = vc
   DECLARE drdar_sample_size = i4
   DECLARE drdar_xml_name = vc
   DECLARE drdar_sum_name = vc
   DECLARE drdar_xsl_name = vc
   DECLARE drdam_ext_pos = i4
   DECLARE drdar_tab_ind = i2
   DECLARE drdar_tempqual = i4 WITH protect, noconstant(0)
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
      CALL text(9,3,"Enter table name or pattern to be audited:")
      SET accept = nopatcheck
      SET drdar_tab_ind = 0
      WHILE (drdar_tab_ind=0)
        CALL accept(9,50,"P(35);CU","*"
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
       CALL text(10,3,concat("Limit the sample size for the above table to ",trim(cnvtstring(
           drdar_sample_size))," rows ? ( (Y)es/(N)o ):"))
       CALL accept(10,76,"P;CU","Y"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        SET drdar_size_ind = "YES"
       ELSE
        SET drdar_size_ind = "NO"
       ENDIF
      ELSE
       CALL text(10,3,"The sample size will be limited to a default of 25 rows per table")
       SET drdar_size_ind = "YES"
      ENDIF
      CALL text(11,3,"Limit change log retreival from source to REFCHG rows only? ( (Y)es/(N)o ):")
      CALL accept(11,80,"P;CU","Y"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="Y")
       SET drdar_cgl_ind = "YES"
      ELSE
       SET drdar_cgl_ind = "NO"
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
      CALL text(15,3,
       "The following 3 files will be created by the Audit Report and found in CCLUSERDIR upon completion:"
       )
      CALL text(17,50,drdar_xml_name)
      CALL text(18,50,drdar_sum_name)
      CALL text(19,50,drdar_xsl_name)
      CALL text(22,3,"Continue?( (Y)es/(N)o/e(X)it )")
      CALL accept(22,36,"A;CU","Y"
       WHERE curaccept IN ("Y", "N", "X"))
      IF (curaccept="X")
       SET drdar_back = 1
      ELSEIF (curaccept="Y")
       SET message = nowindow
       EXECUTE dm_rdds_audit drdar_rep_name, drdar_tab_name, srm_env_id,
       drdar_cgl_ind, drdar_size_ind
       GO TO exit_program
      ENDIF
     ELSE
      SET drdar_back = 1
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE ptam_confirm(pc_target_env_id)
   SET dm_err->eproc = "Checking for existing PTAM relationship"
   SELECT INTO "NL:"
    FROM dm_env_reltn der
    WHERE der.relationship_type="PENDING TARGET AS MASTER"
     AND (der.child_env_id=dmda_mr->env_id)
     AND der.parent_env_id=pc_target_env_id
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,44,"***  Pending Target as Master Configuration  ***")
    CALL text(4,75,"ENVIRONMENT ID:")
    CALL text(4,20,"ENVIRONMENT NAME:")
    CALL text(4,95,cnvtstring(dmda_mr->env_id))
    CALL text(4,40,dmda_mr->env_name)
    CALL text(7,3,"Would you like this target domain to be set up as master (Y/N)?")
    CALL text(9,3,concat("If reference data built in the target (",dmda_add->child_env_name,
      ") domain should not be"))
    CALL text(10,3,concat("overwritten by changes in the source (",dmda_mr->env_name,
      "), then answer 'Yes'"))
    CALL accept(7,72,"A;CU","N"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     SET stat = initrec(dera_request)
     SET stat = alterlist(dera_request->env_list,1)
     SET dera_request->child_env_id = pc_target_env_id
     SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
     SET dera_request->env_list[1].child_env_id = pc_target_env_id
     SET dera_request->env_list[1].relationship_type = "PENDING TARGET AS MASTER"
     EXECUTE dm_add_env_reltn
     IF ((dera_reply->err_num > 0))
      CALL text(12,3,dera_reply->err_msg)
      CALL text(13,3,"Insertion failed! Action aborted..")
      CALL pause(2)
      SET dm_err->eproc = "Inserting 'PENDING TARGET AS MASTER' to DM_ENV_RELTN"
      CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
    ELSE
     RETURN
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE ptam_setup(ps_target_env_id)
   DECLARE ps_oe_check = i4
   DECLARE ps_ptam_ind = i4
   DECLARE ptam_env_name = vc
   SET dm_err->eproc = "Checking for full circle relationship"
   SELECT INTO "NL:"
    FROM dm_env_reltn r
    WHERE (r.parent_env_id=dmda_mr->env_id)
     AND r.child_env_id=ps_target_env_id
     AND r.relationship_type="RDDS MOVER CHANGES NOT LOGGED"
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
   SET dm_err->eproc = "Checking if existing relationship is already PTAM"
   SELECT INTO "NL:"
    FROM dm_env_reltn r
    WHERE (r.parent_env_id=dmda_mr->env_id)
     AND r.child_env_id=ps_target_env_id
     AND r.relationship_type="PENDING TARGET AS MASTER"
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET ps_ptam_ind = curqual
   SET dm_err->eproc = "Getting target environment name"
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE de.environment_id=ps_target_env_id
    DETAIL
     ptam_env_name = de.environment_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,44,"***  Pending Target as Master Configuration  ***")
   CALL text(4,75,"ENVIRONMENT ID:")
   CALL text(4,20,"ENVIRONMENT NAME:")
   CALL text(4,95,cnvtstring(dmda_mr->env_id))
   CALL text(4,40,dmda_mr->env_name)
   CALL text(7,3,"Would you like this target domain to be set up as master (Y/N)?")
   CALL text(9,3,concat("If reference data built in the target (",ptam_env_name,
     ") domain should not be"))
   CALL text(10,3,concat("overwritten by changes in the source (",dmda_mr->env_name,
     "), then answer 'Yes'"))
   CALL accept(7,72,"A;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="N")
    IF (ps_ptam_ind > 0)
     SET stat = initrec(derd_request)
     SET stat = alterlist(derd_request->env_list,1)
     SET derd_request->child_env_id = ps_target_env_id
     SET derd_request->env_list[1].parent_env_id = dmda_mr->env_id
     SET derd_request->env_list[1].child_env_id = ps_target_env_id
     SET derd_request->env_list[1].relationship_type = "PENDING TARGET AS MASTER"
     EXECUTE dm_del_env_reltn
     IF ((derd_reply->err_num > 0))
      CALL text(12,3,derd_reply->err_msg)
      CALL text(13,3,"Deletion failed! Action abort...")
      CALL disp_msg(derd_reply->err_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = "Regenerating triggers after removing PTAM"
     CALL autoadd_triggers(null)
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ELSE
     RETURN
    ENDIF
   ELSEIF (curaccept="Y")
    IF (ps_ptam_ind > 0)
     RETURN
    ELSE
     SET stat = initrec(dera_request)
     SET stat = alterlist(dera_request->env_list,1)
     SET dera_request->child_env_id = ps_target_env_id
     SET dera_request->env_list[1].parent_env_id = dmda_mr->env_id
     SET dera_request->env_list[1].child_env_id = ps_target_env_id
     SET dera_request->env_list[1].relationship_type = "PENDING TARGET AS MASTER"
     EXECUTE dm_add_env_reltn
     IF ((dera_reply->err_num > 0))
      CALL text(12,3,dera_reply->err_msg)
      CALL text(13,3,"Insertion failed! Action aborted..")
      CALL pause(2)
      SET dm_err->eproc = "Inserting 'PENDING TARGET AS MASTER' to DM_ENV_RELTN"
      CALL disp_msg(dera_reply->err_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = "Regenerating triggers after adding PTAM"
     CALL autoadd_triggers(null)
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
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
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS INFO"
     AND di.info_name="LAST DM_REFCHG_PKW_VERS UPDATE"
     AND (di.info_date <
    (SELECT
     max(r.event_dt_tm)
     FROM dm_rdds_event_log r
     WHERE r.rdds_event_key="LOCALMETADATAREFRESH"
      AND (r.cur_environment_id=dmda_mr->env_id)))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual != 0)
    SET message = nowindow
    CALL clear(1,1)
    EXECUTE dm_rmc_vers_tab  WITH replace("REQUEST","CLV_REQUEST"), replace("REPLY","CLV_REPLY")
    IF ((clv_reply->status_data.status="F"))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS INFO"
      AND di.info_name="LAST DM_REFCHG_PKW_VERS UPDATE"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET message = nowindow
     CALL clear(1,1)
     EXECUTE dm_rmc_vers_tab  WITH replace("REQUEST","CLV_REQUEST"), replace("REPLY","CLV_REPLY")
     IF ((clv_reply->status_data.status="F"))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   SET message = window
   CALL clear(1,1)
   SET dm_err->eproc = "Checking remaining rows that need a new version id"
   SELECT
    count(*)
    FROM dm_chg_log dcl
    WHERE  NOT (dcl.dm_refchg_pkw_vers_id IN (
    (SELECT
     d.dm_refchg_pkw_vers_id
     FROM dm_refchg_pkw_vers d
     WHERE d.table_name=dcl.table_name
      AND d.active_ind=1)))
     AND dcl.log_type IN ("REFCHG", "NORDDS", "PKWREF", "PKWNOR")
     AND dcl.delete_ind=0
     AND dcl.target_env_id=target_env_id
     AND  EXISTS (
    (SELECT
     "x"
     FROM dm_refchg_pkw_vers pkw
     WHERE pkw.table_name=dcl.table_name
      AND pkw.active_ind=1))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE dmda_disp_backfill_msgs(dbm_sc_explode,dbm_ptam_check,dbm_dcl_check,dbm_pkw_check,
  dbm_mov_check)
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
   IF (((dbm_sc_explode=0) OR (dbm_dcl_check=0
    AND dbm_ptam_check > 0
    AND dbm_pkw_check=1)) )
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
      IF (dbm_sc_explode=0
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
    IF (dbm_sc_explode=0)
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
#exit_program
 SET message = nowindow
 IF ((dm_err->err_ind=1))
  CALL disp_msg("Errors occurred during execution, check logfile for details",dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "...Ending dm_merge_domain_adm"
 CALL final_disp_msg("dm_merge_domain_adm")
END GO
