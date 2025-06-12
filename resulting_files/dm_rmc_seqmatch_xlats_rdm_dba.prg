CREATE PROGRAM dm_rmc_seqmatch_xlats_rdm:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
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
 IF ((validate(sx_request->cnt,- (99))=- (99)))
  FREE RECORD sx_request
  RECORD sx_request(
    1 cnt = i4
    1 stmt[*]
      2 str = vc
  ) WITH protect
 ENDIF
 IF ((validate(sx_reply->row_count,- (99))=- (99)))
  FREE RECORD sx_reply
  RECORD sx_reply(
    1 row_count = i4
  ) WITH protect
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
 IF (validate(dm_batch_list_req->dblg_owner,"XYZ")="XYZ"
  AND validate(dm_batch_list_req->dblg_owner,"ABC")="ABC")
  FREE RECORD dm_batch_list_req
  RECORD dm_batch_list_req(
    1 dblg_owner = vc
    1 dblg_table = vc
    1 dblg_table_id = vc
    1 dblg_column = vc
    1 dblg_where = vc
    1 dblg_mode = vc
    1 dblg_num_cnt = i4
  )
 ENDIF
 IF (validate(dm_batch_list_rep->status_msg,"XYZ")="XYZ"
  AND validate(dm_batch_list_rep->status_msg,"ABC")="ABC")
  FREE RECORD dm_batch_list_rep
  RECORD dm_batch_list_rep(
    1 status = c1
    1 status_msg = vc
    1 list[*]
      2 batch_num = i4
      2 max_value = vc
  )
 ENDIF
 DECLARE seqmatch_xlats(i_sequence_name=vc,i_source_env_id=f8,i_table_name=vc) = vc
 DECLARE app_task_backfill(i_atb_source_env_id=f8) = vc
 DECLARE seqmatch_event_chk(i_source_id=f8,i_target_id=f8,i_sequence_name=vc) = vc
 DECLARE add_src_done_2(i_src_id=f8,i_tgt_id=f8,i_tgt_mock_id=f8,i_sequence=vc) = vc
 DECLARE cs93_xlat_backfill(cxb_source_id=f8) = vc
 DECLARE cs93_fix_done2(cfd_source_id=f8,cfd_target_id=f8,cfd_mock_id=f8,cfd_db_link=vc,
  cfd_seqmatch_value=f8) = vc
 DECLARE cs93_create_seqmatch(ccs_rec=vc(ref)) = vc
 SUBROUTINE seqmatch_xlats(i_sequence_name,i_source_env_id,i_table_name)
   SET dm_err->eproc = concat("Start Xlat Backfill",format(cnvtdatetime(curdate,curtime3),cclfmt->
     mediumdatetime))
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE sx_table_suffix = vc
   DECLARE sx_live_table_name = vc
   DECLARE sx_sequence_name = vc
   DECLARE sx_target_id = f8
   DECLARE sx_t_id1 = f8
   DECLARE sx_db_link = vc
   DECLARE sx_seq_match_domain = vc
   DECLARE sx_src_seq_match_domain = vc WITH protect, noconstant("")
   DECLARE sx_seq_match_num = f8
   DECLARE sx_val_loop = i4
   DECLARE sx_dmt_source = vc
   DECLARE sx_filter_name = vc
   DECLARE sx_filter = vc
   DECLARE sx_col_loop = i4
   DECLARE sx_next_seq = f8
   DECLARE sx_continue_ind = i2
   DECLARE sx_insert_limit = i4
   DECLARE sx_asd2_ret = vc WITH protect, noconstant("")
   DECLARE sx_sec_ret = vc WITH protect, noconstant("")
   DECLARE sx_tbl_allrow_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE sx_tbl_fltr_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE sx_range_start = vc WITH protect, noconstant("")
   DECLARE sx_range_end = vc WITH protect, noconstant("")
   DECLARE sx_range_idx = i4 WITH protect, noconstant(0)
   DECLARE sx_seq_match_num_src = f8 WITH protect, noconstant(0.0)
   DECLARE sx_s_col_name = vc
   DECLARE sx_t_col_name = vc
   DECLARE sx_s_table_name = vc
   DECLARE sx_dmt_s = vc
   DECLARE sx_atb_return = vc
   FREE RECORD sx_tbl_list
   RECORD sx_tbl_list(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 suffix = vc
       2 val_cnt = i4
       2 values[*]
         3 source_val = f8
   )
   FREE RECORD sx_filter_columns
   RECORD sx_filter_columns(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   IF (trim(i_sequence_name) <= "")
    IF (trim(i_table_name) > "")
     IF (cnvtupper(i_table_name)="*$R")
      SET sx_table_suffix = substring((size(i_table_name) - 5),4,i_table_name)
      SELECT INTO "nl:"
       FROM dm_tables_doc dtd
       WHERE dtd.table_suffix=sx_table_suffix
        AND dtd.full_table_name=dtd.table_name
       DETAIL
        sx_live_table_name = dtd.table_name
       WITH nocounter
      ;end select
      IF (check_error("Obtaining live table name") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       CALL echo("*****************************************************************")
       CALL echo("")
       CALL echo("Error: seqmatch_xlats():Live table name could not be obtained from ")
       CALL echo("table_name passed in.")
       CALL echo("")
       CALL echo("*****************************************************************")
       RETURN("F")
      ENDIF
     ELSE
      SET sx_live_table_name = cnvtupper(i_table_name)
     ENDIF
     IF (cnvtupper(sx_live_table_name)="APPLICATION_TASK")
      SET sx_atb_return = app_task_backfill(i_source_env_id)
      RETURN(sx_atb_return)
     ENDIF
     SELECT INTO "nl:"
      dcd.sequence_name
      FROM dm_columns_doc dcd,
       dm_tables_doc dtd
      WHERE dtd.table_name=sx_live_table_name
       AND ((dtd.reference_ind=1) OR (dtd.table_name IN (
      (SELECT
       rt.table_name
       FROM dm_rdds_refmrg_tables rt))))
       AND dtd.table_name IN (
      (SELECT
       ut.table_name
       FROM user_tables ut))
       AND dtd.table_name=dtd.full_table_name
       AND dtd.table_name=dcd.table_name
       AND dcd.table_name=dcd.root_entity_name
       AND dcd.column_name=dcd.root_entity_attr
       AND  NOT (dtd.table_name IN (
      (SELECT
       cv.display
       FROM code_value cv
       WHERE cv.code_set=4001912
        AND cv.cdf_meaning="NORDDSTRG"
        AND cv.active_ind=1)))
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_info di
       WHERE di.info_domain="RDDS IGNORE COL LIST:*"
        AND sqlpassthru(" dcd.column_name like di.info_name and dcd.table_name like di.info_char"))))
      DETAIL
       sx_sequence_name = dcd.sequence_name
      WITH nocounter
     ;end select
     IF (check_error("Obtaining sequence name") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     IF (curqual=0)
      RETURN("S")
     ENDIF
    ELSE
     CALL echo("*****************************************************************")
     CALL echo("")
     CALL echo("Error: seqmatch_xlats():sequence_name and table_name passed in")
     CALL echo("were not filled out.")
     CALL echo("")
     CALL echo("*****************************************************************")
     RETURN("F")
    ENDIF
   ELSE
    SET sx_sequence_name = i_sequence_name
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     sx_t_id1 = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    CALL echo("*****************************************************************")
    CALL echo("")
    CALL echo("Error: seqmatch_xlats():no dm_info row found to obtain target_id")
    CALL echo("")
    CALL echo("*****************************************************************")
    RETURN("F")
   ENDIF
   SET sx_db_link = build("@MERGE",cnvtstring(i_source_env_id,20,0),cnvtstring(sx_t_id1,20,0))
   SET sx_target_id = drmmi_get_mock_id(sx_t_id1)
   IF (sx_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET sx_seq_match_domain = build("MERGE",cnvtstring(i_source_env_id,20,0),cnvtstring(sx_target_id,
     20,0),"SEQMATCH")
   SET sx_src_seq_match_domain = build("MERGE",cnvtstring(sx_target_id,20,0),cnvtstring(
     i_source_env_id,20,0),"SEQMATCH")
   SET sx_dmt_source = build("DM_MERGE_TRANSLATE",sx_db_link)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=sx_seq_match_domain
     AND di.info_name=sx_sequence_name
    DETAIL
     sx_seq_match_num = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (sx_seq_match_num <= 0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end select
    IF (check_error("Checking DONE2 sequence row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_domain = concat(trim(sx_seq_match_domain),"DONE2"), di.info_name = sx_sequence_name,
       di.info_number = 0,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting 0 sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ELSE
      IF (sx_sequence_name="REFERENCE_SEQ")
       SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,0.0)
       IF (sx_sec_ret="F")
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
      ENDIF
      COMMIT
      SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
      IF (sx_sec_ret="F")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
      IF (sx_asd2_ret="F")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      RETURN("S")
     ENDIF
    ELSE
     RETURN("S")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",sx_db_link)) di)
    WHERE di.info_domain=concat(sx_src_seq_match_domain,"DONE2")
     AND di.info_name=sx_sequence_name
    DETAIL
     sx_seq_match_num_src = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    IF (sx_sequence_name="REFERENCE_SEQ")
     SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,
      sx_seq_match_num_src)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end select
    IF (check_error("Checking DONE2 sequence row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     UPDATE  FROM dm_info di
      SET di.info_domain = concat(trim(sx_seq_match_domain),"DONE2"), di.updt_task = 4310001, di
       .updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE di.info_domain=sx_seq_match_domain
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence done2 row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     INSERT  FROM dm_info di
      SET di.info_domain = sx_seq_match_domain, di.info_name = sx_sequence_name, di.info_number = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_task = 4310001
      WITH nocounter
     ;end insert
     IF (check_error("Updating old sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ELSE
     UPDATE  FROM dm_info di
      SET di.info_number = sx_seq_match_num, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
       .updt_task = 4310001
      WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence done2 row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_task = 4310001
      WHERE di.info_domain=sx_seq_match_domain
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating old sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    dcd.table_name, dcd.column_name
    FROM dm_columns_doc dcd,
     dm_tables_doc dtd
    WHERE ((dtd.reference_ind=1) OR (dtd.table_name IN (
    (SELECT
     rt.table_name
     FROM dm_rdds_refmrg_tables rt))))
     AND dtd.table_name=dtd.full_table_name
     AND dtd.table_name=dcd.table_name
     AND ((dcd.table_name=dcd.root_entity_name
     AND dcd.column_name=dcd.root_entity_attr) OR (((dcd.table_name="DCP_FORMS_REF"
     AND dcd.column_name="DCP_FORMS_REF_ID") OR (dcd.table_name="DCP_SECTION_REF"
     AND dcd.column_name="DCP_SECTION_REF_ID")) ))
     AND list(dcd.table_name,dcd.column_name) IN (
    (SELECT
     utc.table_name, utc.column_name
     FROM user_tab_columns utc))
     AND dcd.sequence_name=sx_sequence_name
     AND  NOT (dtd.table_name IN (
    (SELECT
     cv.display
     FROM code_value cv
     WHERE cv.code_set=4001912
      AND cv.cdf_meaning="NORDDSTRG"
      AND cv.active_ind=1)))
     AND  NOT (dtd.table_name IN (
    (SELECT
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="RDDS BACKFILL EXCLUSION")))
     AND list(dcd.table_name,dcd.column_name) IN (
    (SELECT
     utc2.table_name, utc2.column_name
     FROM (parser(build("user_tab_columns",sx_db_link)) utc2)))
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_info di
     WHERE di.info_domain="RDDS IGNORE COL LIST:*"
      AND sqlpassthru(" dcd.column_name like di.info_name and dcd.table_name like di.info_char"))))
    HEAD REPORT
     sx_tbl_list->cnt = 0
    DETAIL
     sx_tbl_list->cnt = (sx_tbl_list->cnt+ 1)
     IF (mod(sx_tbl_list->cnt,10)=1)
      stat = alterlist(sx_tbl_list->qual,(sx_tbl_list->cnt+ 9))
     ENDIF
     sx_tbl_list->qual[sx_tbl_list->cnt].table_name = dcd.table_name, sx_tbl_list->qual[sx_tbl_list->
     cnt].column_name = dcd.column_name, sx_tbl_list->qual[sx_tbl_list->cnt].suffix = dtd
     .table_suffix
    FOOT REPORT
     stat = alterlist(sx_tbl_list->qual,sx_tbl_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error("Obtaining tables associated with the current sequence") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF ((sx_tbl_list->cnt > 0))
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONFIGURATION"
      AND di.info_name="RXLAT_BELOW_SEQ_FILL"
     DETAIL
      sx_insert_limit = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Logging creation in dm_chg_log_audit") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET sx_insert_limit = 100000
    ENDIF
    FOR (sx_val_loop = 1 TO sx_tbl_list->cnt)
      SELECT INTO "NL:"
       y = seq(dm_merge_audit_seq,nextval)
       FROM dual
       DETAIL
        sx_next_seq = y
       WITH nocounter
      ;end select
      IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET dm_err->eproc = concat("Start Table: ",sx_tbl_list->qual[sx_val_loop].table_name," ",format
       (cnvtdatetime(curdate,curtime3),cclfmt->mediumdatetime))
      CALL disp_msg("",dm_err->logfile,0)
      UPDATE  FROM dm_chg_log_audit dcla
       SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = sx_tbl_list->qual[
        sx_val_loop].table_name,
        dcla.text = concat("Backfill translations below seqmatch for sequence: ",sx_sequence_name,
         ", working on table ",cnvtstring(sx_val_loop)," of ",
         cnvtstring(sx_tbl_list->cnt),": ",sx_tbl_list->qual[sx_val_loop].table_name), dcla
        .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
        dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->
        updt_task,
        dcla.audit_dt_tm = sysdate
       WHERE dcla.dm_chg_log_audit_id=sx_next_seq
       WITH nocounter
      ;end update
      IF (check_error("Updating creation in dm_chg_log_audit") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ELSE
       COMMIT
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_chg_log_audit dcla
        SET dcla.dm_chg_log_audit_id = sx_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
         dcla.table_name = sx_tbl_list->qual[sx_val_loop].table_name, dcla.text = concat(
          "Backfill translations below seqmatch for sequence: ",sx_sequence_name,
          ", working on table ",cnvtstring(sx_val_loop)," of ",
          cnvtstring(sx_tbl_list->cnt),": ",sx_tbl_list->qual[sx_val_loop].table_name), dcla
         .updt_applctx = cnvtreal(currdbhandle),
         dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
         dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
        WITH nocounter
       ;end insert
      ENDIF
      IF (check_error("Logging creation in dm_chg_log_audit") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ELSE
       COMMIT
      ENDIF
      SET sx_filter_name = concat("REFCHG_FILTER_",sx_tbl_list->qual[sx_val_loop].suffix,"*")
      CALL echo(sx_filter_name)
      SELECT INTO "nl:"
       FROM user_objects uo
       WHERE uo.object_name=patstring(sx_filter_name)
        AND  NOT ( EXISTS (
       (SELECT
        di.info_name
        FROM dm_info di
        WHERE di.info_domain="RDDS BACKFILL FILTER EXCLUSION"
         AND (di.info_name=sx_tbl_list->qual[sx_val_loop].table_name))))
       DETAIL
        sx_filter_name = uo.object_name, sx_filter = uo.object_name
       WITH nocounter
      ;end select
      IF (check_error("Obtaining Filter") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       SET sx_filter = "1"
      ELSE
       SET sx_filter_name = concat("declare ",sx_filter_name,"()=i2 go")
       CALL parser(sx_filter_name)
       SELECT INTO "nl:"
        dr.column_name
        FROM dm_refchg_filter_parm dr
        WHERE (dr.table_name=sx_tbl_list->qual[sx_val_loop].table_name)
         AND dr.active_ind=1
        ORDER BY dr.parm_nbr
        HEAD REPORT
         sx_filter_columns->cnt = 0
        DETAIL
         sx_filter_columns->cnt = (sx_filter_columns->cnt+ 1), stat = alterlist(sx_filter_columns->
          qual,sx_filter_columns->cnt), sx_filter_columns->qual[sx_filter_columns->cnt].column_name
          = dr.column_name
        WITH nocounter
       ;end select
       IF (check_error("Obtaining columns for the filter") != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       IF (curqual > 0)
        SET sx_filter = concat(sx_filter,"('ADD'")
        FOR (sx_col_loop = 1 TO sx_filter_columns->cnt)
          SET sx_filter = concat(sx_filter,",t.",sx_filter_columns->qual[sx_col_loop].column_name,
           ",t.",sx_filter_columns->qual[sx_col_loop].column_name)
        ENDFOR
        SET sx_filter = concat(sx_filter,")")
       ELSE
        SET sx_filter = "1"
       ENDIF
      ENDIF
      SET sx_s_col_name = build("s.",sx_tbl_list->qual[sx_val_loop].column_name)
      SET sx_t_col_name = build("t.",sx_tbl_list->qual[sx_val_loop].column_name)
      SET sx_s_table_name = build(sx_tbl_list->qual[sx_val_loop].table_name,sx_db_link)
      SET sx_dmt_s = build("dm_merge_translate",sx_db_link)
      SET sx_continue_ind = 0
      SET sx_request->cnt = 1
      SET stat = alterlist(sx_request->stmt,sx_request->cnt)
      SET sx_reply->row_count = 0
      SET sx_tbl_fltr_cnt = 0
      SELECT INTO "nl:"
       cnt = count(*)
       FROM (parser(sx_tbl_list->qual[sx_val_loop].table_name) t)
       WHERE parser(concat("t.",sx_tbl_list->qual[sx_val_loop].column_name,
         " between 1 and sx_seq_match_num"))
        AND parser(concat(sx_filter," = 1"))
       DETAIL
        sx_tbl_fltr_cnt = cnt
       WITH nocounter
      ;end select
      IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
        table_name)) != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SELECT INTO "nl:"
       cnt = count(ti.parent_entity_id)
       FROM dm_refchg_invalid_xlat ti
       WHERE (ti.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
        AND ti.parent_entity_id BETWEEN 1 AND sx_seq_match_num
       DETAIL
        sx_tbl_fltr_cnt = (sx_tbl_fltr_cnt+ cnt)
       WITH nocounter
      ;end select
      IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
        table_name)) != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (sx_tbl_fltr_cnt > sx_insert_limit)
       SET dm_batch_list_req->dblg_num_cnt = ceil((sx_tbl_fltr_cnt/ cnvtreal(sx_insert_limit)))
       SET dm_batch_list_req->dblg_where = concat(" where ",sx_tbl_list->qual[sx_val_loop].
        column_name," between 1 and ",cnvtstring(sx_seq_match_num)," and ",
        replace(sx_filter,"t.","")," = 1")
      ELSEIF (sx_tbl_fltr_cnt < sx_insert_limit
       AND sx_filter != "1")
       SET sx_tbl_allrow_cnt = 0
       SELECT INTO "nl:"
        cnt = count(*)
        FROM (parser(sx_tbl_list->qual[sx_val_loop].table_name) t)
        WHERE parser(concat("t.",sx_tbl_list->qual[sx_val_loop].column_name,
          " between 1 and sx_seq_match_num"))
        DETAIL
         sx_tbl_allrow_cnt = cnt
        WITH nocounter
       ;end select
       IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
         table_name)) != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       SELECT INTO "nl:"
        cnt = count(ti.parent_entity_id)
        FROM dm_refchg_invalid_xlat ti
        WHERE (ti.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
         AND ti.parent_entity_id BETWEEN 1 AND sx_seq_match_num
        DETAIL
         sx_tbl_allrow_cnt = (sx_tbl_allrow_cnt+ cnt)
        WITH nocounter
       ;end select
       IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
         table_name)) != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       IF (sx_tbl_allrow_cnt > sx_insert_limit)
        SET dm_batch_list_req->dblg_num_cnt = ceil((sx_tbl_allrow_cnt/ cnvtreal(sx_insert_limit)))
        SET dm_batch_list_req->dblg_where = concat(" where ",sx_tbl_list->qual[sx_val_loop].
         column_name," between 1 and ",cnvtstring(sx_seq_match_num))
       ELSE
        SET stat = alterlist(dm_batch_list_rep->list,1)
        SET dm_batch_list_rep->list[1].max_value = cnvtstring(sx_seq_match_num,20,0)
        SET dm_batch_list_req->dblg_num_cnt = 1
        SET sx_continue_ind = 1
       ENDIF
      ELSE
       CALL echo("sx_tbl_allrow_cnt < sx_insert_limit")
       SET stat = alterlist(dm_batch_list_rep->list,1)
       SET dm_batch_list_rep->list[1].max_value = cnvtstring(sx_seq_match_num,20,0)
       SET dm_batch_list_req->dblg_num_cnt = 1
       SET sx_continue_ind = 1
      ENDIF
      IF (sx_continue_ind=0)
       SET dm_batch_list_req->dblg_owner = "V500"
       SET dm_batch_list_req->dblg_table = sx_tbl_list->qual[sx_val_loop].table_name
       SET dm_batch_list_req->dblg_column = sx_tbl_list->qual[sx_val_loop].column_name
       SET dm_batch_list_req->dblg_mode = "BATCH"
       EXECUTE dm_get_batch_list
       IF ((dm_batch_list_rep->status="F"))
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
      ENDIF
      FOR (sx_range_idx = 1 TO size(dm_batch_list_rep->list,5))
        IF (sx_range_idx=1)
         SET sx_range_start = "1"
        ELSE
         SET sx_range_start = cnvtstring(dm_batch_list_rep->list[(sx_range_idx - 1)].max_value,20,0)
        ENDIF
        IF (sx_range_idx=size(dm_batch_list_rep->list,5))
         SET sx_range_end = cnvtstring(sx_seq_match_num,20,0)
        ELSE
         SET sx_range_end = cnvtstring(dm_batch_list_rep->list[sx_range_idx].max_value,20,0)
        ENDIF
        SELECT INTO "NL:"
         y = seq(dm_merge_audit_seq,nextval)
         FROM dual
         DETAIL
          sx_next_seq = y
         WITH nocounter
        ;end select
        IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ENDIF
        CALL echo(sx_tbl_list->qual[sx_val_loop].table_name)
        UPDATE  FROM dm_chg_log_audit dcla
         SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = sx_tbl_list->qual[
          sx_val_loop].table_name,
          dcla.text = concat("Backfill translations for sequence: ",sx_sequence_name,", table: ",
           sx_tbl_list->qual[sx_val_loop].table_name," batch: ",
           cnvtstring(sx_range_idx)," of ",cnvtstring(dm_batch_list_req->dblg_num_cnt)), dcla
          .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
          dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->
          updt_task,
          dcla.audit_dt_tm = sysdate
         WHERE dcla.dm_chg_log_audit_id=sx_next_seq
         WITH nocounter
        ;end update
        IF (check_error("Logging creation in dm_chg_log_audit") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ELSE
         COMMIT
        ENDIF
        IF (curqual=0)
         INSERT  FROM dm_chg_log_audit dcla
          SET dcla.dm_chg_log_audit_id = sx_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
           dcla.table_name = sx_tbl_list->qual[sx_val_loop].table_name, dcla.text = concat(
            "Backfill translations for sequence: ",sx_sequence_name,", table: ",sx_tbl_list->qual[
            sx_val_loop].table_name," batch: ",
            cnvtstring(sx_range_idx)," of ",cnvtstring(dm_batch_list_req->dblg_num_cnt)), dcla
           .updt_applctx = cnvtreal(currdbhandle),
           dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
           dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
          WITH nocounter
         ;end insert
        ENDIF
        IF (check_error("Logging creation in dm_chg_log_audit") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ELSE
         COMMIT
        ENDIF
        SET sx_continue_ind = 0
        WHILE (sx_continue_ind=0)
          SET sx_request->stmt[1].str = concat(
           " rdb asis(^insert /*+ CCL<DM_RMC_SEQMATCH_XLATS:S> */ ","into dm_merge_translate dmt ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ( dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  dmt.status_flg, dmt.updt_dt_tm ) ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " (select from_value, table_name, env_source_id, env_target_id, to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  status_flg, updt_dt_tm from ( ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" select ",
            sx_t_col_name," from_value , "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" table_name , ",
            i_source_env_id," env_source_id, ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" env_target_id, ",
            sx_t_col_name," to_value ,3 status_flg,sysdate updt_dt_tm "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("   from ",sx_tbl_list
            ->qual[sx_val_loop].table_name," t "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("    where ",
            sx_t_col_name," between ",sx_range_start," and ",
            sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("    and ",sx_filter,
            " = 1"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," union ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_id from_value,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_name table_name,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(i_source_env_id,
            " env_source_id,"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(sx_target_id,
            " env_target_id,"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_id to_value,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," 3 status_flg,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," sysdate updt_dt_tm")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  from dm_refchg_invalid_xlat ti ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " where ti.parent_entity_name = '",sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " and ti.parent_entity_id between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select from_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , from_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,"  from dm_merge_translate")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " where table_name  = '",sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and from_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , to_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,"  from dm_merge_translate")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and to_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select from_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , from_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("  from ",sx_dmt_s))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and from_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , to_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("  from ",sx_dmt_s))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and to_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" ) where rownum <= ",
            cnvtstring(sx_insert_limit),")^) go "))
          EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","SX_REQUEST"), replace("REPLY",
           "SX_REPLY")
          IF ((sx_reply->row_count < sx_insert_limit))
           SET sx_continue_ind = 1
          ENDIF
          IF (check_error("Inserting translations into dm_merge_translate") != 0)
           SET dm_err->err_ind = 1
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ROLLBACK
           RETURN("F")
          ELSE
           COMMIT
          ENDIF
        ENDWHILE
      ENDFOR
    ENDFOR
   ENDIF
   IF (sx_sequence_name="REFERENCE_SEQ")
    SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,sx_seq_match_num
     )
    IF (sx_sec_ret="F")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
     AND di.info_name=sx_sequence_name
    WITH nocounter
   ;end select
   IF (check_error("Checking DONE2 sequence row") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    UPDATE  FROM dm_info
     SET info_domain = concat(trim(sx_seq_match_domain),"DONE2"), updt_task = 4310001
     WHERE info_domain=sx_seq_match_domain
      AND info_name=sx_sequence_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     INSERT  FROM dm_info di
      SET di.info_domain = sx_seq_match_domain, di.info_name = sx_sequence_name, di.info_number = 0,
       di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting 0 sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
     IF (sx_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain=sx_seq_match_domain
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
     IF (sx_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE app_task_backfill(i_atb_source_env_id)
   DECLARE atb_target_id = f8
   DECLARE atb_cur_env_id = f8
   DECLARE atb_db_link = vc
   DECLARE atb_app_task_src = vc
   DECLARE atb_dmt_src = vc
   DECLARE atb_table_name = vc WITH constant("APPLICATION_TASK")
   DECLARE atb_insert_limit = i4 WITH constant(100000)
   DECLARE i_domain = vc
   DECLARE atb_next_seq = f8 WITH noconstant(0.0)
   DECLARE atb_app_task_col_cnt = i4 WITH noconstant(0)
   DECLARE atb_parser_cnt = i4 WITH noconstant(0)
   DECLARE atb_continue_ind = i2 WITH noconstant(1)
   DECLARE atb_sec_ret = vc WITH protect, noconstant("")
   DECLARE atb_asd2_ret = vc WITH protect, noconstant("")
   DECLARE atb_src_domain = vc WITH protect, noconstant("")
   DECLARE atb_seqmatch_domain = vc WITH protect, noconstant("")
   DECLARE atb_src_number = f8 WITH protect, noconstant(0.0)
   FREE RECORD atb_rs_parser
   RECORD atb_rs_parser(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD atb_rs_parser_reply
   RECORD atb_rs_parser_reply(
     1 row_count = i4
   )
   FREE RECORD atb_app_task_rs
   RECORD atb_app_task_rs(
     1 qual[*]
       2 notnull_ind = i4
       2 column_name = vc
   )
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     atb_cur_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET atb_db_link = build("@MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(atb_cur_env_id,20,
     0))
   SET atb_app_task_src = concat("APPLICATION_TASK",atb_db_link)
   SET atb_dmt_src = concat("DM_MERGE_TRANSLATE",atb_db_link)
   SET atb_target_id = drmmi_get_mock_id(atb_cur_env_id)
   IF (atb_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET i_domain = build("MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(atb_target_id,20,0),
    "SEQMATCHDONE2")
   SET atb_src_domain = build("MERGE",cnvtstring(atb_target_id,20,0),cnvtstring(i_atb_source_env_id,
     20,0),"SEQMATCHDONE2")
   SET atb_seqmatch_domain = build("MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(
     atb_target_id,20,0),"SEQMATCH")
   SELECT INTO "NL:"
    y = seq(dm_merge_audit_seq,nextval)
    FROM dual
    DETAIL
     atb_next_seq = y
    WITH nocounter
   ;end select
   IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = atb_table_name,
     dcla.text = "Backfill translations in custom ranges for table APPLICATION_TASK", dcla
     .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
     dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->updt_task,
     dcla.audit_dt_tm = sysdate
    WHERE dcla.dm_chg_log_audit_id=atb_next_seq
    WITH nocounter
   ;end update
   IF (check_error("Inserting DM_CHG_LOG_AUDIT row for APPLICATION_TASK") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = atb_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
      dcla.table_name = atb_table_name, dcla.text =
      "Backfill translations in custom ranges for table APPLICATION_TASK", dcla.updt_applctx =
      cnvtreal(currdbhandle),
      dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
      dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
     WITH nocounter
    ;end insert
    IF (check_error("Inserting DM_CHG_LOG_AUDIT row for APPLICATION_TASK") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=i_domain
     AND di.info_name=atb_table_name
    WITH nocounter
   ;end select
   IF (check_error("Checking if DONE2 row exists for APPLICATION_TASK") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ELSEIF (curqual=0)
    SELECT INTO "NL:"
     FROM user_tab_columns ut,
      (parser(concat("user_tab_columns",atb_db_link)) utc)
     PLAN (ut
      WHERE ut.table_name=atb_table_name)
      JOIN (utc
      WHERE utc.table_name=atb_table_name
       AND utc.column_name=ut.column_name)
     DETAIL
      atb_app_task_col_cnt = (atb_app_task_col_cnt+ 1), stat = alterlist(atb_app_task_rs->qual,
       atb_app_task_col_cnt), atb_app_task_rs->qual[atb_app_task_col_cnt].column_name = trim(ut
       .column_name,3),
      atb_app_task_rs->qual[atb_app_task_col_cnt].notnull_ind = 0
     WITH nocounter
    ;end select
    IF (check_error("Gathering apptask columns that exist in source and target") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_user_notnull_cols unc,
      (dummyt dt  WITH seq = value(atb_app_task_col_cnt))
     PLAN (unc
      WHERE unc.table_name=atb_table_name)
      JOIN (dt
      WHERE (atb_app_task_rs->qual[dt.seq].column_name=unc.column_name))
     DETAIL
      atb_app_task_rs->qual[dt.seq].notnull_ind = 1
     WITH nocounter
    ;end select
    IF (check_error("Gathering not nullible columns on apptask") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM (parser(concat("dm_info",atb_db_link)) di)
     WHERE di.info_domain=atb_src_domain
      AND di.info_name=atb_table_name
     DETAIL
      atb_src_number = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Obtaining sequence match value") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual > 0)
     INSERT  FROM dm_info di
      SET di.info_domain = i_domain, di.info_name = atb_table_name, di.updt_task = 4310001,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.info_number = atb_src_number
      WITH nocounter
     ;end insert
     IF (check_error("Updating sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = 0, di.updt_task = 4310001, di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE di.info_domain=atb_seqmatch_domain
       AND di.info_name=atb_table_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_number = 0, di.updt_task = 4310001, di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        di.info_domain = atb_seqmatch_domain, di.info_name = atb_table_name
       WITH nocounter
      ;end insert
      IF (check_error("Updating sequence row in dm_info") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_atb_source_env_id,atb_cur_env_id,atb_table_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
    SET stat = alterlist(atb_rs_parser->stmt,8)
    SET atb_rs_parser->stmt[1].str = " rdb insert into dm_merge_translate dmt"
    SET atb_rs_parser->stmt[2].str =
    " (dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, "
    SET atb_rs_parser->stmt[3].str = "  dmt.status_flg, dmt.updt_dt_tm) "
    SET atb_rs_parser->stmt[4].str = build(' (select at.task_number, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_rs_parser->stmt[5].str = build(atb_target_id,", at.task_number, 3, sysdate")
    SET atb_rs_parser->stmt[6].str = concat("from application_task at, ",atb_app_task_src," ats")
    SET atb_rs_parser->stmt[7].str = "where ((at.task_number between 113000 and 113999) "
    SET atb_rs_parser->stmt[8].str = "or (at.task_number between 117000 and 118999)) and "
    SET atb_parser_cnt = 8
    FOR (i = 1 TO size(atb_app_task_rs->qual,5))
      SET atb_parser_cnt = (atb_parser_cnt+ 1)
      SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
      IF ((atb_app_task_rs->qual[i].notnull_ind=0))
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("((at.",atb_app_task_rs->qual[i].
        column_name," = ats.",atb_app_task_rs->qual[i].column_name,")")
       SET atb_parser_cnt = (atb_parser_cnt+ 1)
       SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(" or (at.",atb_app_task_rs->qual[i].
        column_name," is NULL and ats.",atb_app_task_rs->qual[i].column_name," is NULL))")
      ELSE
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("at.",atb_app_task_rs->qual[i].
        column_name," = ats.",atb_app_task_rs->qual[i].column_name)
      ENDIF
      IF (i < size(atb_app_task_rs->qual,5))
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(atb_rs_parser->stmt[atb_parser_cnt].str,
        " and ")
      ENDIF
    ENDFOR
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select from_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,
     ", from_value, 3, sysdate")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     'from dm_merge_translate where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     " and ((from_value >= 113000 and from_value <= 113999) ","or (from_value >= 117000 and ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " from_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select to_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,", to_value, 3, sysdate"
     )
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     'from dm_merge_translate where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str =
    " and ((to_value >= 113000 and to_value <= 113999) or (to_value >= 117000 and "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " to_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select from_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,
     ", from_value, 3, sysdate")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("from dm_merge_translate",atb_db_link,
     ' where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     " and ((from_value >= 113000 and from_value <= 113999) ","or (from_value >= 117000 and ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " from_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select to_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,", to_value, 3, sysdate"
     )
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("from dm_merge_translate",atb_db_link,
     ' where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str =
    " and ((to_value >= 113000 and to_value <= 113999) or (to_value >= 117000 and "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " to_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = ") go"
    WHILE (atb_continue_ind=1)
      EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","ATB_RS_PARSER"), replace("REPLY",
       "ATB_RS_PARSER_REPLY")
      IF ((atb_rs_parser_reply->row_count < atb_insert_limit))
       SET atb_continue_ind = 0
      ELSE
       SET atb_continue_ind = 1
      ENDIF
      IF (check_error("Error during APPLICATION_TASK translation backfill") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
    ENDWHILE
    INSERT  FROM dm_info di
     SET di.info_domain = i_domain, di.info_name = "APPLICATION_TASK", di.info_number = 0,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("app__task_backfill - Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
     SET atb_sec_ret = seqmatch_event_chk(i_atb_source_env_id,atb_cur_env_id,"APPLICATION_TASK")
     IF (atb_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET atb_asd2_ret = add_src_done_2(i_atb_source_env_id,atb_cur_env_id,atb_target_id,
      "APPLICATION_TASK")
     IF (atb_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ELSEIF (curqual > 0)
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE seqmatch_event_chk(i_source_id,i_target_id,i_sequence_name)
   DECLARE sec_link_name = vc WITH protect, noconstant("")
   DECLARE sec_done_ind = i2 WITH protect, noconstant(0)
   DECLARE sec_drel_row = f8 WITH protect, noconstant(0.0)
   DECLARE sec_drel_value = i4 WITH protect, noconstant(0)
   IF (validate(sec_lck_reply->status,"X")="X")
    FREE RECORD sec_lck_reply
    RECORD sec_lck_reply(
      1 status = c1
      1 status_msg = vc
    )
   ENDIF
   IF ((validate(sx_seq->cnt,- (9999)) != - (9999)))
    SET sec_drel_value = sx_seq->cnt
   ENDIF
   SET sec_lck_reply->status = "Z"
   SET sec_link_name = build(cnvtstring(i_source_id,20),cnvtstring(i_target_id,20))
   WHILE (sec_done_ind=0)
     SELECT INTO "nl:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
       AND drel.cur_environment_id=i_target_id
       AND drel.paired_environment_id=i_source_id
       AND  EXISTS (
      (SELECT
       "x"
       FROM dm_rdds_event_detail dred
       WHERE dred.dm_rdds_event_log_id=drel.dm_rdds_event_log_id
        AND dred.event_detail1_txt=i_sequence_name))
      DETAIL
       sec_drel_row = drel.dm_rdds_event_log_id
      WITH nocounter
     ;end select
     IF (check_error("Determining if Translation Backfill event row exists") != 0)
      RETURN("F")
     ENDIF
     IF (sec_drel_row=0)
      SELECT INTO "nl:"
       FROM dm_rdds_event_log drel
       WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
        AND drel.cur_environment_id=i_target_id
        AND drel.paired_environment_id=i_source_id
       DETAIL
        sec_drel_row = drel.dm_rdds_event_log_id
       WITH nocounter, maxqual(drel,1)
      ;end select
      IF (check_error("Determining if Translation Backfill event row exists") != 0)
       RETURN("F")
      ENDIF
     ENDIF
     IF (sec_drel_row > 0)
      UPDATE  FROM dm_rdds_event_detail dred
       SET dred.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE dred.dm_rdds_event_log_id=sec_drel_row
        AND dred.event_detail1_txt=i_sequence_name
       WITH nocounter
      ;end update
      IF (check_error("Attempting to update event detail row") != 0)
       RETURN("F")
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_rdds_event_detail dred
        SET dred.dm_rdds_event_detail_id = seq(dm_seq,nextval), dred.dm_rdds_event_log_id =
         sec_drel_row, dred.event_detail1_txt = i_sequence_name,
         dred.event_detail_value = 0.0, dred.updt_applctx = reqinfo->updt_applctx, dred.updt_cnt = 0,
         dred.updt_dt_tm = cnvtdatetime(curdate,curtime3), dred.updt_id = reqinfo->updt_id, dred
         .updt_task = 4310001
        WITH nocounter
       ;end insert
       IF (check_error("Attempting to insert new event detail row") != 0)
        RETURN("F")
       ENDIF
      ENDIF
      COMMIT
      SET sec_done_ind = 1
     ELSE
      CALL get_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",0,sec_lck_reply)
      IF ((sec_lck_reply->status="F"))
       SET dm_err->emsg = "Error while obtaining lock"
       RETURN("F")
      ELSEIF ((sec_lck_reply->status="S"))
       COMMIT
       SET stat = alterlist(auto_ver_request->qual,1)
       IF (sec_drel_value > 0)
        SET auto_ver_request->qual[1].event_reason = cnvtstring(sec_drel_value)
       ELSE
        SET auto_ver_request->qual[1].event_reason = ""
       ENDIF
       SET auto_ver_request->qual[1].rdds_event = "Translation Backfill Finished"
       SET auto_ver_request->qual[1].cur_environment_id = i_target_id
       SET auto_ver_request->qual[1].paired_environment_id = i_source_id
       SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
       SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = i_sequence_name
       SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
       EXECUTE dm_rmc_auto_verify_setup
       IF ((auto_ver_reply->status="F"))
        SET dm_err->emsg = "Error while writing event row for Translation Backfill"
        CALL remove_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",
         currdbhandle,sec_lck_reply)
        IF ((sec_lck_reply->status="F"))
         SET dm_err->emsg = "Error while releasing lock"
        ENDIF
        RETURN("F")
       ENDIF
       CALL remove_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",currdbhandle,
        sec_lck_reply)
       IF ((sec_lck_reply->status="F"))
        SET dm_err->emsg = "Error while releasing lock"
        RETURN("F")
       ENDIF
       COMMIT
       SET sec_done_ind = 1
      ELSEIF ((sec_lck_reply->status="Z"))
       CALL pause(10)
      ENDIF
     ENDIF
   ENDWHILE
   RETURN("S")
 END ;Subroutine
 SUBROUTINE add_src_done_2(i_src_id,i_tgt_id,i_tgt_mock_id,i_sequence)
   DECLARE asd_merge_link = vc WITH protect, noconstant("")
   DECLARE asd_domain = vc WITH protect, noconstant("")
   DECLARE asd_sec_ret = vc WITH protect, noconstant("")
   DECLARE asd_targ_nbr = f8 WITH protect, noconstant(0.0)
   DECLARE asd_src_domain = vc WITH protect, noconstant("")
   SET asd_merge_link = build("@MERGE",cnvtstring(i_src_id,20,0),cnvtstring(i_tgt_id,20,0))
   SET asd_domain = build("MERGE",cnvtstring(i_tgt_mock_id,20,0),cnvtstring(i_src_id,20,0),"SEQMATCH"
    )
   SET asd_src_domain = build("MERGE",cnvtstring(i_src_id,20,0),cnvtstring(i_tgt_mock_id,20,0),
    "SEQMATCH")
   IF (i_tgt_id != i_tgt_mock_id)
    RETURN("S")
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",asd_merge_link)) di)
    WHERE di.info_domain=concat(trim(asd_domain),"DONE2")
     AND info_name=i_sequence
    WITH nocounter
   ;end select
   IF (check_error("Obtaining done2 row from target") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    RETURN("S")
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN (asd_src_domain, concat(asd_src_domain,"DONE2"))
     AND di.info_name=i_sequence
    DETAIL
     IF (di.info_number > asd_targ_nbr)
      asd_targ_nbr = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value from target") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   INSERT  FROM (parser(concat("dm_info",asd_merge_link)) di)
    SET di.info_domain = concat(trim(asd_domain),"DONE2"), di.info_number = asd_targ_nbr, di
     .updt_task = 4310001,
     di.info_name = i_sequence
    WITH nocounter
   ;end insert
   IF (check_error("Updating sequence row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",asd_merge_link)) di)
    WHERE di.info_domain=asd_domain
     AND di.info_name=i_sequence
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM (parser(concat("dm_info",asd_merge_link)) di)
     SET di.info_number = 0, di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=asd_domain
      AND di.info_name=i_sequence
     WITH nocounter
    ;end update
    IF (check_error("Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSE
    INSERT  FROM (parser(concat("dm_info",asd_merge_link)) di)
     SET di.info_number = 0, di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx,
      di.info_domain = asd_domain, di.info_name = i_sequence
     WITH nocounter
    ;end insert
    IF (check_error("Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   COMMIT
   SET asd_sec_ret = seqmatch_event_chk(i_tgt_id,i_src_id,i_sequence)
   IF (asd_sec_ret="F")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE cs93_xlat_backfill(cxb_source_id)
   DECLARE cxb_target_id = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_cur_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_db_link = vc WITH protect, noconstant(" ")
   DECLARE cxb_cv_src = vc WITH protect, noconstant(" ")
   DECLARE cxb_dmt_src = vc WITH protect, noconstant(" ")
   DECLARE cxb_table_name = vc WITH protect, constant("CODE_VALUE")
   DECLARE cxb_domain = vc WITH protect, noconstant(" ")
   DECLARE cxb_info_name = vc WITH protect, constant("CODESET93")
   DECLARE cxb_next_seq = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_sec_ret = vc WITH protect, noconstant("")
   DECLARE cxb_src_domain = vc WITH protect, noconstant("")
   DECLARE cxb_seqmatch_domain = vc WITH protect, noconstant("")
   DECLARE cxb_src_number = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_seqmatch_val = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_done2_src_val = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_row_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_batch = i4 WITH protect, noconstant(0)
   DECLARE cxb_loop = i4 WITH protect, noconstant(0)
   DECLARE cxb_batch_limit = f8 WITH protect, noconstant(0.0)
   FREE RECORD cxb_rs_parser
   RECORD cxb_rs_parser(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD cxb_rs_parser_reply
   RECORD cxb_rs_parser_reply(
     1 row_count = i4
   )
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     cxb_cur_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET cxb_db_link = build("@MERGE",cnvtstring(cxb_source_id,20),cnvtstring(cxb_cur_env_id,20))
   SET cxb_cv_src = concat("CODE_VALUE",cxb_db_link)
   SET cxb_dmt_src = concat("DM_MERGE_TRANSLATE",cxb_db_link)
   SET cxb_target_id = drmmi_get_mock_id(cxb_cur_env_id)
   IF (cxb_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET cxb_domain = build("MERGE",cnvtstring(cxb_source_id),cnvtstring(cxb_target_id),"SEQMATCHDONE2"
    )
   SET cxb_src_domain = build("MERGE",cnvtstring(cxb_target_id),cnvtstring(cxb_source_id),
    "SEQMATCHDONE2")
   SET cxb_seqmatch_domain = build("MERGE",cnvtstring(cxb_source_id),cnvtstring(cxb_target_id),
    "SEQMATCH")
   SELECT INTO "NL:"
    FROM (parser(concat("dm_info",cxb_db_link)) di)
    WHERE di.info_name="REFERENCE_SEQ"
     AND di.info_domain=cxb_src_domain
    DETAIL
     cxb_done2_src_val = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying for remote REFERENCE_SEQ DONE2 row")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    y = seq(dm_merge_audit_seq,nextval)
    FROM dual
    DETAIL
     cxb_next_seq = y
    WITH nocounter
   ;end select
   IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = cxb_table_name,
     dcla.text = "Backfill translations in CODE_SET 93 for table CODE_VALUE", dcla.updt_applctx =
     cnvtreal(currdbhandle), dcla.updt_cnt = 0,
     dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->updt_task,
     dcla.audit_dt_tm = sysdate
    WHERE dcla.dm_chg_log_audit_id=cxb_next_seq
    WITH nocounter
   ;end update
   IF (check_error("Updating DM_CHG_LOG_AUDIT row for CODE_VALUE") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = cxb_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
      dcla.table_name = cxb_table_name, dcla.text =
      "Backfill translations in CODE_SET 93 for table CODE_VALUE", dcla.updt_applctx = cnvtreal(
       currdbhandle),
      dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
      dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
     WITH nocounter
    ;end insert
    IF (check_error("Inserting DM_CHG_LOG_AUDIT row for CODE_VALUE") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=cxb_domain
     AND di.info_name=cxb_info_name
    WITH nocounter
   ;end select
   IF (check_error("Checking if DONE2 row exists for CODE_SET 93") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ELSEIF (curqual=0)
    SELECT INTO "nl:"
     FROM (parser(concat("dm_info",cxb_db_link)) di)
     WHERE di.info_domain=cxb_src_domain
      AND di.info_name=cxb_info_name
     DETAIL
      cxb_src_number = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for remote CODESET93 DONE2 row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual > 0)
     SET cxb_sec_ret = cs93_fix_done2(cxb_source_id,cxb_cur_env_id,cxb_target_id,cxb_db_link,
      cxb_src_number)
     IF (cxb_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     RETURN("S")
    ENDIF
    SELECT INTO "NL:"
     FROM dm_info di
     WHERE di.info_domain=cxb_seqmatch_domain
      AND di.info_name=cxb_info_name
     DETAIL
      cxb_seqmatch_val = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for local CODESET93 SEQMATCH") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (cxb_done2_src_val > cxb_seqmatch_val)
     SET cxb_seqmatch_val = cxb_done2_src_val
     UPDATE  FROM dm_info d
      SET info_number = cxb_seqmatch_val
      WHERE info_domain=cxb_seqmatch_domain
       AND info_name=cxb_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating local CODESET93 SEQMATCH to be correct") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     cnt = count(*)
     FROM code_value c
     WHERE c.code_set=93
      AND c.code_value <= cxb_seqmatch_val
     DETAIL
      cxb_row_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error("Gathering count of CODESET93 to use for NTILE")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     cnt = count(*)
     FROM dm_refchg_invalid_xlat t1
     WHERE t1.parent_entity_name="CODE_VALUE"
      AND t1.parent_entity_id <= cxb_seqmatch_val
     DETAIL
      cxb_row_cnt = (cxb_row_cnt+ cnt)
     WITH nocounter
    ;end select
    IF (check_error("Gathering count of CODESET93 to use for NTILE")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONFIGURATION"
      AND di.info_name="RXLAT_BELOW_SEQ_FILL"
     DETAIL
      cxb_batch_limit = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for backfill batch size") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET cxb_batch_limit = 50000.0
    ENDIF
    SET cxb_batch = ceil((cxb_row_cnt/ cxb_batch_limit))
    SET cxb_row_cnt = 1.0
    IF (cxb_batch > 1)
     DELETE  FROM dm_info d
      WHERE info_domain="CODESET93"
       AND info_name=patstring("CODESET93*")
      WITH nocounter
     ;end delete
     IF (check_error("Removing CODSET93 Ntile rows from DM_INFO")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     CALL parser("rdb asis(^ insert into dm_info (info_domain, info_name, info_number) ^)",0)
     CALL parser("asis(^(select 'CODSET93','CODESET93'||to_char(bin,'FM00000'), max(code_value)^)",0)
     CALL parser(concat("asis(^ from (select code_value, ntile(",trim(cnvtstring(cxb_batch)),
       ") over (order by code_value) bin ^)"),0)
     CALL parser(concat(
       "asis(^ from (select code_value from code_value where code_set = 93 and code_value < ",trim(
        cnvtstring(cxb_seqmatch_val,20,1)),"^)"),0)
     CALL parser(
      "asis(^ union select t1.parent_entity_id code_value from dm_refchg_invalid_xlat t1 ^)",0)
     CALL parser(concat(
       "asis(^ where t1.parent_entity_name = 'CODE_VALUE' and t1.parent_entity_id < ",trim(cnvtstring
        (cxb_seqmatch_val,20,1)),"^)"),0)
     CALL parser("asis (^ order by code_value) group by bin) ^) go",1)
     IF (check_error("Performing NTILE statement for CODESET93")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET cxb_batch = 0
     SELECT INTO "NL:"
      FROM dm_info d
      WHERE d.info_domain="CODESET93"
       AND info_name=patstring("CODESET93*")
      ORDER BY d.info_number
      DETAIL
       cxb_batch = (cxb_batch+ 1), stat = alterlist(dm_batch_list_rep->list,cxb_batch),
       dm_batch_list_rep->list[cxb_batch].batch_num = cxb_batch,
       dm_batch_list_rep->list[cxb_batch].max_value = cnvtstring(d.info_number,20,1)
      WITH nocounter
     ;end select
     IF (check_error("Querying CODESET93 NTILE data in DM_INFO")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSE
     SET cxb_batch = 1
     SET stat = alterlist(dm_batch_list_rep->list,1)
     SET dm_batch_list_rep->list[1].batch_num = 1
     SET dm_batch_list_rep->list[1].max_value = cnvtstring(cxb_seqmatch_val,20,1)
    ENDIF
    SET stat = alterlist(cxb_rs_parser->stmt,40)
    FOR (cxb_loop = 1 TO cxb_batch)
      SET cxb_rs_parser->stmt[1].str = " rdb insert into dm_merge_translate dmt"
      SET cxb_rs_parser->stmt[2].str =
      " (dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, "
      SET cxb_rs_parser->stmt[3].str = "  dmt.status_flg, dmt.updt_dt_tm) "
      SET cxb_rs_parser->stmt[4].str = build(' (select cv.code_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[5].str = build(cxb_target_id,", cv.code_value, 3, sysdate")
      SET cxb_rs_parser->stmt[6].str = concat("from code_value cv")
      SET cxb_rs_parser->stmt[7].str = concat("where cv.code_set = 93 and cv.code_value between ",
       trim(cnvtstring(cxb_row_cnt,20,2))," and ",dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[8].str =
      " union select ti.parent_entity_id from_value, ti.parent_entity_name table_name, "
      SET cxb_rs_parser->stmt[9].str = concat(trim(cnvtstring(cxb_source_id,20,2))," env_source_id, ",
       trim(cnvtstring(cxb_target_id,20,2))," env_target_id, ")
      SET cxb_rs_parser->stmt[10].str =
      "ti.parent_entity_id to_value, 3 status_flg, sysdate updt_dt_tm "
      SET cxb_rs_parser->stmt[11].str = concat(
       'from dm_refchg_invalid_xlat ti where ti.parent_entity_name = "',cxb_table_name,
       '" and ti.parent_entity_id between ',trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[16].str = "  minus "
      SET cxb_rs_parser->stmt[17].str = build('  select from_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[18].str = build("    ",cxb_target_id,", from_value, 3, sysdate")
      SET cxb_rs_parser->stmt[19].str = concat('from dm_merge_translate where table_name = "',
       cxb_table_name,'"')
      SET cxb_rs_parser->stmt[20].str = build(" and env_source_id = ",cxb_source_id)
      SET cxb_rs_parser->stmt[21].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_target_id,
         20,2))," and from_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[22].str = "  minus "
      SET cxb_rs_parser->stmt[23].str = build('  select to_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[24].str = build("    ",cxb_target_id,", to_value, 3, sysdate")
      SET cxb_rs_parser->stmt[25].str = concat('from dm_merge_translate where table_name = "',
       cxb_table_name,'"')
      SET cxb_rs_parser->stmt[26].str = build(" and env_source_id = ",cxb_source_id)
      SET cxb_rs_parser->stmt[27].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_target_id,
         20,2))," and to_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[28].str = "  minus "
      SET cxb_rs_parser->stmt[29].str = build('  select from_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[30].str = build("    ",cxb_target_id,", from_value, 3, sysdate")
      SET cxb_rs_parser->stmt[31].str = build("from dm_merge_translate",cxb_db_link,
       ' where table_name = "',cxb_table_name,'"')
      SET cxb_rs_parser->stmt[32].str = build(" and env_source_id = ",cxb_target_id)
      SET cxb_rs_parser->stmt[33].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_source_id,
         20,2))," and from_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[34].str = "  minus "
      SET cxb_rs_parser->stmt[35].str = build('  select to_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[36].str = build("    ",cxb_target_id,", to_value, 3, sysdate")
      SET cxb_rs_parser->stmt[37].str = concat("from dm_merge_translate",cxb_db_link,
       ' where table_name = "',cxb_table_name,'"')
      SET cxb_rs_parser->stmt[38].str = build(" and env_source_id = ",cxb_target_id)
      SET cxb_rs_parser->stmt[39].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_source_id,
         20,2))," and to_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[40].str = ") go"
      EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","CXB_RS_PARSER"), replace("REPLY",
       "CXB_RS_PARSER_REPLY")
      IF (check_error("Error during CODESET 93 translation backfill") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET cxb_row_cnt = cnvtreal(dm_batch_list_rep->list[cxb_loop].max_value)
    ENDFOR
    SET cxb_sec_ret = cs93_fix_done2(cxb_source_id,cxb_cur_env_id,cxb_target_id,cxb_db_link,
     cxb_seqmatch_val)
    IF (cxb_sec_ret="F")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    COMMIT
    RETURN("S")
   ELSEIF (curqual > 0)
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE cs93_fix_done2(cfd_source_id,cfd_target_id,cfd_mock_id,cfd_db_link,cfd_seqmatch_value)
   DECLARE cfd_target_seqmatch = vc WITH protect, noconstant("")
   DECLARE cfd_target_done2 = vc WITH protect, noconstant("")
   DECLARE cfd_source_seqmatch = vc WITH protect, noconstant("")
   DECLARE cfd_source_done2 = vc WITH protect, noconstant("")
   DECLARE cfd_info_name = vc WITH protect, constant("CODESET93")
   DECLARE cfd_value = f8 WITH protect, noconstant(0.0)
   SET cfd_target_seqmatch = concat("MERGE",trim(cnvtstring(cfd_source_id,20)),trim(cnvtstring(
      cfd_mock_id,20)),"SEQMATCH")
   SET cfd_target_done2 = concat(cfd_target_seqmatch,"DONE2")
   SET cfd_source_seqmatch = concat("MERGE",trim(cnvtstring(cfd_mock_id,20)),trim(cnvtstring(
      cfd_source_id,20)),"SEQMATCH")
   SET cfd_source_done2 = concat(cfd_source_seqmatch,"DONE2")
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain=cfd_target_seqmatch
     AND di.info_name=cfd_info_name
    DETAIL
     cfd_value = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying sequence row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = cfd_target_seqmatch, di.info_name = cfd_info_name, di.info_number = 0.0,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("Inserting sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSEIF (cfd_value > 0.0)
    UPDATE  FROM dm_info di
     SET info_number = 0.0, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=cfd_target_seqmatch
      AND di.info_name=cfd_info_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SET cfd_value = 0.0
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain=cfd_target_done2
     AND di.info_name=cfd_info_name
    DETAIL
     cfd_value = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying DONE2 row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = cfd_target_done2, di.info_name = cfd_info_name, di.info_number =
      cfd_seqmatch_value,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("Inserting done2 row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSEIF (cfd_value != cfd_seqmatch_value)
    UPDATE  FROM dm_info di
     SET info_number = cfd_seqmatch_value, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=cfd_target_done2
      AND di.info_name=cfd_info_name
     WITH nocounter
    ;end update
    IF (check_error("Updating done2 row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   IF (cfd_target_id=cfd_mock_id)
    SET cfd_value = 0.0
    SELECT INTO "NL:"
     FROM (parser(concat("dm_Info",cfd_db_link)) di)
     WHERE di.info_domain=cfd_source_seqmatch
      AND di.info_name=cfd_info_name
     DETAIL
      cfd_value = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying sequence row in remote dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET di.info_domain = cfd_source_seqmatch, di.info_name = cfd_info_name, di.info_number = 0.0,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting sequence row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSEIF (cfd_value > 0.0)
     UPDATE  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET info_number = 0.0, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
       di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
       updt_applctx
      WHERE di.info_domain=cfd_source_seqmatch
       AND di.info_name=cfd_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
    SET cfd_value = 0.0
    SELECT INTO "NL:"
     FROM (parser(concat("dm_Info",cfd_db_link)) di)
     WHERE di.info_domain=cfd_source_done2
      AND di.info_name=cfd_info_name
     DETAIL
      cfd_value = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying done2 row in remote dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET di.info_domain = cfd_source_done2, di.info_name = cfd_info_name, di.info_number =
       cfd_seqmatch_value,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting done2 row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSEIF (cfd_value != cfd_seqmatch_value)
     UPDATE  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET info_number = cfd_seqmatch_value, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
       di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
       updt_applctx
      WHERE di.info_domain=cfd_source_done2
       AND di.info_name=cfd_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating done2 row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE cs93_create_seqmatch(ccs_rec)
   DECLARE ccs_loop = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_ENV_ID"
    DETAIL
     ccs_rec->env_id = d.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying for local environment id")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET ccs_rec->mock_id = drmmi_get_mock_id(ccs_rec->env_id)
   IF (check_error("Obtaining MOCK_ID")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    FROM dm_env_reltn d
    WHERE (d.child_env_id=ccs_rec->env_id)
     AND d.relationship_type="REFERENCE MERGE"
     AND d.post_link_name > " "
    DETAIL
     ccs_rec->env_cnt = (ccs_rec->env_cnt+ 1), stat = alterlist(ccs_rec->env_qual,ccs_rec->env_cnt),
     ccs_rec->env_qual[ccs_rec->env_cnt].parent_env_id = d.parent_env_id,
     ccs_rec->env_qual[ccs_rec->env_cnt].db_link = d.post_link_name, ccs_rec->env_qual[ccs_rec->
     env_cnt].done2_name = concat("MERGE",trim(cnvtstring(d.parent_env_id,20)),trim(cnvtstring(
        ccs_rec->mock_id,20)),"SEQMATCHDONE2")
    WITH nocounter
   ;end select
   IF (check_error("Looking for all parent relationships")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF ((ccs_rec->env_cnt > 0))
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = ccs_rec->env_cnt),
      dm_info di
     PLAN (d)
      JOIN (di
      WHERE di.info_name="REFERENCE_SEQ"
       AND (di.info_domain=ccs_rec->env_qual[d.seq].done2_name))
     DETAIL
      ccs_rec->env_qual[d.seq].done2_value = di.info_number, ccs_rec->env_qual[d.seq].done2_exist_ind
       = 1, ccs_rec->ref_seq_cnt = (ccs_rec->ref_seq_cnt+ 1)
     WITH nocounter
    ;end select
    IF (check_error("Looking for REFERENCE_SEQ DONE2 rows")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   FOR (ccs_loop = 1 TO ccs_rec->env_cnt)
     IF ((ccs_rec->env_qual[ccs_loop].done2_exist_ind=1))
      SELECT INTO "NL:"
       FROM dm_info di
       WHERE di.info_domain=concat("MERGE",trim(cnvtstring(ccs_rec->env_qual[ccs_loop].parent_env_id,
          20)),trim(cnvtstring(ccs_rec->mock_id,20)),"SEQMATCH")
        AND di.info_name="CODESET93"
       WITH nocounter
      ;end select
      IF (check_error("Querying for CODESET93 SEQMATCH row")=1)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_info di
        SET di.info_domain = concat("MERGE",trim(cnvtstring(ccs_rec->env_qual[ccs_loop].parent_env_id,
            20)),trim(cnvtstring(ccs_rec->mock_id,20)),"SEQMATCH"), di.info_name = "CODESET93", di
         .info_number = ccs_rec->env_qual[ccs_loop].done2_value,
         di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
         di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (check_error("Inserting CODESET93 SEQMATCH row")=1)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   COMMIT
   RETURN("S")
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
 DECLARE add_tracking_row(i_source_id=f8,i_refchg_type=vc,i_refchg_status=vc) = null
 DECLARE delete_tracking_row(null) = null
 DECLARE move_long(i_from_table=vc,i_to_table=vc,i_column_name=vc,i_pk_str=vc,i_source_env_id=f8,
  i_status_flag=i4) = null
 DECLARE get_reg_tab_name(i_r_tab_name=vc,i_suffix=vc) = vc
 DECLARE dcc_find_val(i_delim_str=vc,i_delim_val=vc,i_val_rec=vc(ref)) = i2
 DECLARE move_circ_long(i_from_table=vc,i_from_rtable=vc,i_from_pk=vc,i_from_prev_pk=vc,i_from_fk=vc,
  i_from_pe_col=vc,i_circ_table=vc,i_circ_column_name=vc,i_circ_fk_col=vc,i_circ_long_col=vc,
  i_source_env_id=f8,i_status_flag=i4) = null
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE add_tracking_row(i_source_id,i_refchg_type,i_refchg_status)
   DECLARE var_process = vc
   DECLARE var_sid = f8
   DECLARE var_serial_num = f8
   SELECT INTO "nl:"
    process, sid, serial#
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    DETAIL
     var_process = vs.process, var_sid = vs.sid, var_serial_num = vs.serial#
    WITH maxqual(vs,1)
   ;end select
   UPDATE  FROM dm_refchg_process
    SET refchg_type = i_refchg_type, refchg_status = i_refchg_status, last_action_dt_tm = sysdate,
     updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE rdbhandle_value=cnvtreal(currdbhandle)
   ;end update
   COMMIT
   IF (curqual=0)
    INSERT  FROM dm_refchg_process
     SET dm_refchg_process_id = seq(dm_clinical_seq,nextval), env_source_id = i_source_id,
      rdbhandle_value = cnvtreal(currdbhandle),
      process_name = var_process, log_file = dm_err->logfile, last_action_dt_tm = sysdate,
      refchg_type = i_refchg_type, refchg_status = i_refchg_status, updt_cnt = 0,
      updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->
      updt_task,
      updt_dt_tm = cnvtdatetime(curdate,curtime3), session_sid = var_sid, serial_number =
      var_serial_num
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_tracking_row(null)
  DELETE  FROM dm_refchg_process
   WHERE rdbhandle_value=cnvtreal(currdbhandle)
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE move_long(i_from_table,i_to_table,i_column_name,i_pk_str,i_source_env_id,i_status_flag)
   RECORD long_col(
     1 data[*]
       2 pk_str = vc
       2 long_str = vc
   )
   SET s_rdds_where_iu_str =
   " rdds_delete_ind = 0 and rdds_source_env_id = i_source_env_id and rdds_status_flag = i_status_flag"
   DECLARE long_str = vc
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_column_name),")"),0)
   CALL parser(concat("        , pk_str=",i_pk_str),0)
   CALL parser(concat("   from ",trim(i_from_table)," l "),0)
   CALL parser(concat(" where ",s_rdds_where_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (long_str = ' ') ",0)
   CALL parser("       long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser("       long_str = notrim(concat(long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser("   long_col->data[long_cnt].pk_str = pk_str",0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(long_str,5)",0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   FOR (lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_to_table)," set ",trim(i_column_name)),0)
     CALL parser("= long_col->data[lc_ndx].long_str where ",0)
     CALL parser(long_col->data[lc_ndx].pk_str,0)
     CALL parser(" go",1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_reg_tab_name(i_r_tab_name,i_suffix)
   DECLARE s_suffix = vc
   DECLARE s_tab_name = vc
   IF (i_suffix > " ")
    SET s_suffix = i_suffix
   ELSE
    SET s_suffix = substring((size(i_r_tab_name) - 5),4,i_r_tab_name)
   ENDIF
   SELECT INTO "nl:"
    dtd.table_name
    FROM dm_rdds_tbl_doc dtd
    WHERE dtd.table_suffix=s_suffix
     AND dtd.table_name=dtd.full_table_name
    DETAIL
     s_tab_name = dtd.table_name
    WITH nocounter
   ;end select
   RETURN(s_tab_name)
 END ;Subroutine
 SUBROUTINE dcc_find_val(i_delim_str,i_delim_val,i_val_rec)
   DECLARE dfv_temp_delim_str = vc WITH constant(concat(i_delim_val,i_delim_str,i_delim_val)),
   protect
   DECLARE dfv_temp_str = vc WITH noconstant(""), protect
   DECLARE dfv_return = i2 WITH noconstant(0), protect
   IF (size(trim(i_delim_str),1) > 0)
    FOR (i = 1 TO i_val_rec->len)
      IF (size(trim(i_val_rec->values[i].str),1) > 0)
       SET dfv_temp_str = concat(i_delim_val,i_val_rec->values[i].str,i_delim_val)
       IF (findstring(dfv_temp_str,dfv_temp_delim_str) > 0)
        SET dfv_return = 1
        RETURN(dfv_return)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(dfv_return)
 END ;Subroutine
 SUBROUTINE move_circ_long(i_from_table,i_from_rtable,i_from_pk,i_from_prev_pk,i_from_fk,
  i_from_pe_col,i_circ_table,i_circ_column_name,i_circ_fk_col,i_circ_long_col,i_source_env_id,
  i_status_flag)
   DECLARE mcl_rdds_iu_str = vc WITH protect, noconstant("")
   DECLARE move_circ_lc_ndx = i4 WITH protect, noconstant(0)
   DECLARE move_circ_long_str = vc WITH protect, noconstant("")
   DECLARE evaluate_pe_name() = c255
   RECORD long_col(
     1 data[*]
       2 long_pk = f8
       2 long_col_fk = f8
       2 long_str = vc
   )
   SET mcl_rdds_iu_str =
   " r.rdds_delete_ind = 0 and r.rdds_source_env_id = i_source_env_id and r.rdds_status_flag = i_status_flag"
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_circ_long_col),")"),0)
   CALL parser(concat("   from ",trim(i_circ_table)," l, ",trim(i_from_table)," t, "),0)
   CALL parser(concat("         ",trim(i_from_rtable)," r "),0)
   CALL parser(concat(" where l.",trim(i_circ_column_name)," = t.",i_from_fk),0)
   CALL parser(concat("    and t.",i_from_pk," = r.",i_from_prev_pk),0)
   CALL parser(concat("    and r.",i_from_pk," != r.",i_from_prev_pk),0)
   IF (i_from_pe_col > "")
    CALL parser(concat("    and evaluate_pe_name('",i_from_table,"', '",i_from_fk,"','",
      i_from_pe_col,"', r.",i_from_pe_col,") = '",i_circ_table,
      "'"),0)
   ENDIF
   CALL parser(concat("    and l.",i_circ_column_name," > 0"),0)
   CALL parser(concat("    and ",mcl_rdds_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   move_circ_long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (move_circ_long_str = ' ') ",0)
   CALL parser("       move_circ_long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser(
    "       move_circ_long_str = notrim(concat(move_circ_long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser(concat("   long_col->data[long_cnt].long_pk = t.",i_from_pk),0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(move_circ_long_str,5)",0)
   CALL parser(concat("   long_col->data[long_cnt].long_col_fk = r.",i_from_fk),0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   FOR (move_circ_lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_circ_table)," t set ",trim(i_circ_long_col)),0)
     CALL parser("= long_col->data[move_circ_lc_ndx].long_str where ",0)
     CALL parser(concat("t.",i_circ_column_name," = ",trim(cnvtstring(long_col->data[move_circ_lc_ndx
         ].long_col_fk,20,2))),0)
     CALL parser(" go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(null)
     ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE dci_get_rdds_identifier(null) = vc
 DECLARE dci_set_rdds_identifier(dsri_ident=vc) = null
 SUBROUTINE dci_get_rdds_identifier(null)
   DECLARE sys_context() = c4000
   DECLARE dgri_ora_version = i2 WITH protect, noconstant(0)
   DECLARE dgri_ident = vc WITH protect, noconstant("")
   DECLARE dgri_temp_err = i2 WITH protect, noconstant(0)
   DECLARE dgri_temp_emsg = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get CLIENT_IDENTIFIER."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgri_temp_err = dm_err->err_ind
   SET dgri_temp_emsg = dm_err->emsg
   SET dm_err->err_ind = 0
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dgri_ora_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dgri_ident = "NULL"
    SET dm_err->emsg = concat("Error while obtaining Oracle version.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (dgri_ora_version >= 9)
    SELECT INTO "nl:"
     y = sys_context("USERENV","CLIENT_IDENTIFIER")
     FROM dual
     DETAIL
      dgri_ident = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dgri_ident = "NULL"
     SET dm_err->emsg = concat("Error while obtaining CLIENT_IDENTIFIER.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSEIF (((dgri_ident="") OR (dgri_ident=" ")) )
     SET dgri_ident = "NULL"
    ENDIF
   ELSE
    SET dgri_ident = "NULL"
   ENDIF
   SET dm_err->err_ind = dgri_temp_err
   SET dm_err->emsg = dgri_temp_emsg
   RETURN(dgri_ident)
 END ;Subroutine
 SUBROUTINE dci_set_rdds_identifier(dsri_ident)
   DECLARE sys_context() = c4000
   DECLARE dsri_ora_version = i2 WITH protect, noconstant(0)
   DECLARE dsri_temp_err = i2 WITH protect, noconstant(0)
   DECLARE dsri_temp_emsg = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Set CLIENT_IDENTIFIER."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dsri_temp_err = dm_err->err_ind
   SET dsri_temp_emsg = dm_err->emsg
   SET dm_err->err_ind = 0
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dsri_ora_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = concat("Error while obtaining Oracle version.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (dsri_ora_version >= 9)
    IF (dsri_ident="NULL")
     RDB asis ( "begin dbms_session.clear_identifier; end;" )
     END ;Rdb
    ELSE
     CALL parser(concat(^rdb asis("begin dbms_session.set_identifier('^,dsri_ident,^'); end;") go^),1
      )
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = concat("Error while setting CLIENT_IDENTIFIER.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
   ENDIF
   SET dm_err->err_ind = dsri_temp_err
   SET dm_err->emsg = dsri_temp_emsg
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
 DECLARE sx_insert_dcla_row(i_cur_seq_pos=i4,i_tot_seq_cnt=i4,i_cur_src_pos=i4,i_tot_src_cnt=i4,
  i_seq_name=vc) = vc
 DECLARE sx_return = vc
 DECLARE sx_loop = i4
 DECLARE sx_loop2 = i4
 DECLARE sx_fail_ind = i2
 DECLARE sx_continue_ind = i2
 DECLARE sx_seq_in = vc WITH protect, noconstant("")
 DECLARE sx_targ_mock_id = f8 WITH protect, noconstant(0.0)
 DECLARE sx_src_link_name = vc WITH protect, noconstant("")
 DECLARE sx_all_done = i2 WITH protect, noconstant(0)
 DECLARE sx_domain_loop = i4 WITH protect, noconstant(0)
 DECLARE sx_sequnce_loop = i4 WITH protect, noconstant(0)
 DECLARE sx_ins_dcla_row_ret = vc WITH protect, noconstant("")
 DECLARE sx_client_ident = vc WITH protect, noconstant("")
 DECLARE sx_app_task_ind = i2 WITH protect, noconstant(0)
 IF (validate(lck_reply->status,"X")="X")
  FREE RECORD lck_reply
  RECORD lck_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 FREE RECORD sx_domains
 RECORD sx_domains(
   1 cnt = i4
   1 target_id = f8
   1 mock_id = f8
   1 target_name = vc
   1 list[*]
     2 source_id = f8
     2 db_link = vc
     2 valid_ind = i2
 )
 FREE RECORD sx_seq
 RECORD sx_seq(
   1 cnt = i4
   1 list[*]
     2 seq_name = vc
 )
 SET dm_err->emsg = "Readme Failed: Starting dm_create_rmc_triggers_rdm"
 SET readme_data->status = "F"
 SET readme_data->message = dm_err->emsg
 IF (check_logfile("dm_rmc_seq_xlats",".log","dm_rmc_seq_xlats LOG FILE...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->emsg
  GO TO exit_main
 ENDIF
 SET sx_client_ident = dci_get_rdds_identifier(null)
 CALL dci_set_rdds_identifier("RDDS XLAT BACKFILL")
 IF (reflect(parameter(1,0)) != "*C*")
  SET sx_seq_in = "*"
 ELSE
  SET sx_seq_in =  $1
 ENDIF
 IF (((sx_seq_in=char(42)) OR (sx_seq_in="APPLICATION_TASK")) )
  SET sx_app_task_ind = 1
 ENDIF
 IF (sx_seq_in=char(42))
  SET message = noinformation
  SET trace = nocallecho
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   sx_domains->target_id = di.info_number, sx_domains->target_name = di.info_char
  WITH nocounter
 ;end select
 IF (check_error("Obtaining target_id") != 0)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->emsg
  GO TO exit_main
 ENDIF
 IF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Fatal Error: current environment id not found"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->emsg
  GO TO exit_main
 ENDIF
 CALL add_tracking_row(0.0,"TRANSLATION BACKFILL","XLAT BCKFLL RUNNING")
 SET sx_domains->mock_id = drmmi_get_mock_id(sx_domains->target_id)
 IF ((sx_domains->mock_id < 0))
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->emsg
  GO TO exit_main
 ELSEIF ((sx_domains->mock_id != sx_domains->target_id)
  AND validate(rdds_run_xlat_backfill_anyway,- (99)) < 0)
  CALL disp_msg("Translation Backfill Process does not need to be run in the MOCK domain.",dm_err->
   logfile,0)
  SET readme_data->status = "S"
  SET readme_data->message = "Seqmatch Translations do not need to be created in MOCK domain"
  GO TO exit_main
 ELSE
  SET sx_targ_mock_id = sx_domains->mock_id
 ENDIF
 SELECT INTO "nl:"
  FROM dm_env_reltn der
  WHERE (der.child_env_id=sx_domains->target_id)
   AND der.relationship_type="REFERENCE MERGE"
   AND trim(der.post_link_name) > ""
   AND der.post_link_name IS NOT null
  HEAD REPORT
   sx_domains->cnt = 0
  DETAIL
   sx_domains->cnt = (sx_domains->cnt+ 1), stat = alterlist(sx_domains->list,sx_domains->cnt),
   sx_domains->list[sx_domains->cnt].source_id = der.parent_env_id,
   sx_domains->list[sx_domains->cnt].db_link = der.post_link_name, sx_domains->list[sx_domains->cnt].
   valid_ind = 0
  WITH nocounter
 ;end select
 IF (check_error("Obtaining valid source ids") != 0)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->emsg
  GO TO exit_main
 ENDIF
 SET sx_continue_ind = 0
 FOR (sx_loop = 1 TO sx_domains->cnt)
   SELECT INTO "nl:"
    FROM (parser(build("v$database",sx_domains->list[sx_loop].db_link)) d)
    WHERE  NOT (d.name IN (
    (SELECT
     vd.name
     FROM (parser("v$database") vd))))
    WITH maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 0
   ENDIF
   IF (curqual != 0)
    SET sx_continue_ind = 1
    SET sx_domains->list[sx_loop].valid_ind = 1
   ENDIF
 ENDFOR
 SET sx_fail_ind = 0
 IF (sx_continue_ind=1)
  SELECT DISTINCT INTO "nl:"
   dcd.sequence_name
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
    AND dcd.sequence_name=patstring(sx_seq_in)
    AND trim(dcd.sequence_name) > " "
    AND dcd.sequence_name IS NOT null
   HEAD REPORT
    sx_seq->cnt = 0
   DETAIL
    sx_seq->cnt = (sx_seq->cnt+ 1)
    IF (mod(sx_seq->cnt,100)=1)
     stat = alterlist(sx_seq->list,(sx_seq->cnt+ 99))
    ENDIF
    sx_seq->list[sx_seq->cnt].seq_name = dcd.sequence_name
   FOOT REPORT
    stat = alterlist(sx_seq->list,sx_seq->cnt)
   WITH nocounter
  ;end select
  IF (check_error("Obtaining sequences from current domain") != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET readme_data->status = "F"
   SET readme_data->message = dm_err->emsg
   GO TO exit_main
  ENDIF
  IF (sx_app_task_ind=1)
   SET sx_seq->cnt = (sx_seq->cnt+ 1)
   SET stat = alterlist(sx_seq->list,sx_seq->cnt)
   SET sx_seq->list[sx_seq->cnt].seq_name = "APPLICATION_TASK"
  ENDIF
  WHILE (sx_all_done=0)
    FOR (sx_loop = 1 TO sx_domains->cnt)
      IF ((sx_domains->list[sx_loop].valid_ind=1))
       SET sx_src_link_name = build(cnvtstring(sx_domains->list[sx_loop].source_id,20),cnvtstring(
         sx_targ_mock_id,20))
       FOR (sx_loop2 = 1 TO sx_seq->cnt)
        CALL get_lock(concat("XLAT BACKFILL",sx_src_link_name),sx_seq->list[sx_loop2].seq_name,3,
         lck_reply)
        IF ((lck_reply->status="F"))
         SET dm_err->err_ind = 1
         SET dm_err->emsg = "Fatal Error: error while obtaining lock"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET readme_data->status = "F"
         SET readme_data->message = dm_err->emsg
         GO TO exit_main
        ELSEIF ((lck_reply->status="S"))
         COMMIT
         SET sx_ins_dcla_row_ret = sx_insert_dcla_row(sx_loop2,sx_seq->cnt,sx_loop,sx_domains->cnt,
          sx_seq->list[sx_loop2].seq_name)
         IF (sx_ins_dcla_row_ret="F")
          SET dm_err->err_ind = 0
          CALL remove_lock(concat("XLAT BACKFILL",sx_src_link_name),sx_seq->list[sx_loop2].seq_name,
           currdbhandle,lck_reply)
          COMMIT
          IF ((lck_reply->status="F"))
           SET dm_err->err_ind = 1
           SET dm_err->emsg = "Fatal Error: error while releasing lock"
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET readme_data->status = "F"
           SET readme_data->message = dm_err->emsg
           GO TO exit_main
          ENDIF
          SET dm_err->err_ind = 1
          SET dm_err->emsg = "Fatal Error: error while writing dm_chg_log_audit row"
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET readme_data->status = "F"
          SET readme_data->message = dm_err->emsg
          GO TO exit_main
         ENDIF
         SELECT INTO "nl:"
          FROM dm_info dm
          WHERE (dm.info_name=sx_seq->list[sx_loop2].seq_name)
           AND dm.info_domain=concat("MERGE",sx_src_link_name,"SEQMATCHDONE2")
          WITH nocounter
         ;end select
         IF (check_error("Checking if DONE2 row exists for sequence") != 0)
          SET dm_err->err_ind = 0
          CALL remove_lock(concat("XLAT BACKFILL",sx_src_link_name),sx_seq->list[sx_loop2].seq_name,
           currdbhandle,lck_reply)
          IF ((lck_reply->status="F"))
           SET dm_err->err_ind = 1
           SET dm_err->emsg = "Fatal Error: error while releasing lock"
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET readme_data->status = "F"
           SET readme_data->message = dm_err->emsg
           GO TO exit_main
          ENDIF
          COMMIT
          SET dm_err->err_ind = 1
          SET dm_err->emsg = "Fatal Error: error while checking for done2 row"
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET readme_data->status = "F"
          SET readme_data->message = dm_err->emsg
          GO TO exit_main
         ENDIF
         IF (curqual=0)
          IF ((sx_seq->list[sx_loop2].seq_name="APPLICATION_TASK"))
           CALL echo(build("Creating translations for source:",cnvtstring(sx_domains->list[sx_loop].
              source_id,20,0)," and table: APPLICATION_TASK"))
           SET sx_return = seqmatch_xlats("",sx_domains->list[sx_loop].source_id,"APPLICATION_TASK")
          ELSE
           CALL echo(build("Creating translations for source:",cnvtstring(sx_domains->list[sx_loop].
              source_id,20,0)," and sequence: ",sx_seq->list[sx_loop2].seq_name))
           SET sx_return = seqmatch_xlats(sx_seq->list[sx_loop2].seq_name,sx_domains->list[sx_loop].
            source_id,"")
          ENDIF
         ENDIF
         IF (sx_return="F")
          SET sx_fail_ind = 1
          SET readme_data->status = "F"
          SET readme_data->message = "Could not create translations below seqmatch"
          GO TO exit_main
         ENDIF
         CALL remove_lock(concat("XLAT BACKFILL",sx_src_link_name),sx_seq->list[sx_loop2].seq_name,
          currdbhandle,lck_reply)
         IF ((lck_reply->status="F"))
          SET dm_err->err_ind = 1
          SET dm_err->emsg = "Fatal Error: error while releasing lock"
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET readme_data->status = "F"
          SET readme_data->message = dm_err->emsg
          GO TO exit_main
         ENDIF
         COMMIT
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
    SET sx_all_done = 1
    FOR (sx_domain_loop = 1 TO sx_domains->cnt)
      IF ((sx_domains->list[sx_domain_loop].valid_ind=1))
       FOR (sx_sequence_loop = 1 TO sx_seq->cnt)
         SET sx_src_link_name = build(cnvtstring(sx_domains->list[sx_domain_loop].source_id,20,0),
          cnvtstring(sx_targ_mock_id,20,0))
         SELECT INTO "nl:"
          FROM dm_info dm
          WHERE (dm.info_name=sx_seq->list[sx_sequence_loop].seq_name)
           AND dm.info_domain=concat("MERGE",sx_src_link_name,"SEQMATCHDONE2")
          WITH nocounter
         ;end select
         IF (check_error("Checking if DONE2 row exists for sequence") != 0)
          SET dm_err->err_ind = 1
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET readme_data->status = "F"
          SET readme_data->message = dm_err->emsg
          GO TO exit_main
         ENDIF
         IF (curqual=0)
          SET lck_reply->status = ""
          SET lck_reply->status_msg = ""
          CALL check_lock(concat("XLAT BACKFILL",sx_src_link_name),sx_seq->list[sx_sequence_loop].
           seq_name,lck_reply)
          IF ((lck_reply->status="F"))
           SET dm_err->err_ind = 1
           SET dm_err->emsg = "Fatal Error: error while checking lock"
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET readme_data->status = "F"
           SET readme_data->message = dm_err->emsg
           GO TO exit_main
          ELSEIF ((lck_reply->status="S"))
           CALL remove_lock(concat("XLAT BACKFILL",sx_src_link_name),sx_seq->list[sx_sequence_loop].
            seq_name,currdbhandle,lck_reply)
           IF ((lck_reply->status="F"))
            SET dm_err->err_ind = 1
            SET dm_err->emsg = "Fatal Error: error while releasing lock"
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            SET readme_data->status = "F"
            SET readme_data->message = dm_err->emsg
            GO TO exit_main
           ENDIF
           SET sx_all_done = 0
          ELSEIF ((lck_reply->status=""))
           SET sx_all_done = 0
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
  ENDWHILE
 ENDIF
 IF (sx_fail_ind=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Created seqmatch translations with success"
 ENDIF
 SUBROUTINE sx_insert_dcla_row(i_cur_seq_pos,i_tot_seq_cnt,i_cur_src_pos,i_tot_src_cnt,i_seq_name)
   DECLARE sx_next_seq = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    y = seq(dm_merge_audit_seq,nextval)
    FROM dual
    DETAIL
     sx_next_seq = y
    WITH nocounter
   ;end select
   IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.log_id = 0, dcla.action = "XLATSMRY", dcla.table_name = i_seq_name,
     dcla.text = concat("Working on sequence ",trim(cnvtstring(i_cur_seq_pos))," of ",trim(cnvtstring
       (i_tot_seq_cnt))," for source ",
      trim(cnvtstring(i_cur_src_pos))," of ",trim(cnvtstring(i_tot_src_cnt))), dcla.updt_applctx =
     cnvtreal(currdbhandle), dcla.updt_cnt = 0,
     dcla.updt_dt_tm = sysdate, dcla.audit_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE dcla.dm_chg_log_audit_id=sx_next_seq
    WITH nocounter
   ;end update
   IF (check_error("Logging creation in dm_chg_log_audit") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = sx_next_seq, dcla.log_id = 0, dcla.action = "XLATSMRY",
      dcla.table_name = i_seq_name, dcla.text = concat("Working on sequence ",trim(cnvtstring(
         i_cur_seq_pos))," of ",trim(cnvtstring(i_tot_seq_cnt))," for source ",
       trim(cnvtstring(i_cur_src_pos))," of ",trim(cnvtstring(i_tot_src_cnt))), dcla.updt_applctx =
      cnvtreal(currdbhandle),
      dcla.updt_cnt = 0, dcla.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcla.audit_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error("Logging creation in dm_chg_log_audit") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ELSE
    COMMIT
   ENDIF
   RETURN("S")
 END ;Subroutine
#exit_main
 IF ((dm_err->err_ind=1))
  SET dm_err->err_ind = 0
  CALL dci_set_rdds_identifier(sx_client_ident)
  SET dm_err->err_ind = 1
 ELSE
  CALL dci_set_rdds_identifier(sx_client_ident)
 ENDIF
 IF (sx_seq_in=char(42))
  SET message = information
  SET trace = callecho
 ENDIF
 CALL delete_tracking_row(null)
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
