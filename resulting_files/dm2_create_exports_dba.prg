CREATE PROGRAM dm2_create_exports:dba
 DECLARE dm2_mod = vc WITH private, constant("006")
 DECLARE dce_logfile_prefix = vc WITH protect, constant("dm2_create_exports")
 DECLARE dce_file_prefix = vc WITH protect, noconstant(" ")
 DECLARE dce_node = vc WITH protect, noconstant(" ")
 DECLARE dce_user = vc WITH protect, noconstant(" ")
 DECLARE dce_pswd = vc WITH protect, noconstant(" ")
 DECLARE dce_table = vc WITH protect, noconstant(" ")
 DECLARE dce_output_dest = vc WITH protect, noconstant(" ")
 DECLARE dce_type = vc WITH protect, noconstant(" ")
 DECLARE dce_type_run = vc WITH protect, noconstant(" ")
 DECLARE dce_num_rows = vc WITH protect, noconstant(" ")
 DECLARE dce_adm_link = vc WITH protect, noconstant(" ")
 DECLARE dce_wrapper = vc WITH protect, noconstant(" ")
 DECLARE dce_str = vc WITH protect, noconstant(" ")
 DECLARE dce_stat = i4 WITH protect, noconstant(0)
 DECLARE dce_dyn_where = vc WITH protect, noconstant(" ")
 DECLARE dce_cnt = i4 WITH protect, noconstant(0)
 DECLARE dce_found = i2 WITH protect, noconstant(0)
 DECLARE dce_ldcmds_fname = vc WITH protect, noconstant(" ")
 DECLARE dce_full_path = vc WITH protect, noconstant(" ")
 DECLARE dce_msgs_file = vc WITH protect, noconstant(" ")
 DECLARE dce_tname = vc WITH protect, noconstant(" ")
 DECLARE dce_sname = vc WITH protect, noconstant(" ")
 DECLARE dce_server = vc WITH protect, noconstant(" ")
 DECLARE dce_object_exists = i2 WITH protect, noconstant(0)
 DECLARE dcs_lnksrv = vc
 DECLARE dcs_inhouse_oracle_capture = i2 WITH public, noconstant(0)
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
   IF (textlen(concat(sbr_fprefix,sbr_fext)) > 24)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Combination of file prefix and extension exceeded length limit of 24."
    SET dm_err->eproc = concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
     sbr_fext)
    SET dm_err->user_action =
    "Please enter a file prefix and extension that does not exceed a length of 24."
    SET guf_return_val = 0
   ENDIF
   IF (guf_return_val=1)
    WHILE (fini=0)
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
         cnvtdatetime(curdate,000000)) * 864000)))
      SET fname = cnvtlower(build(sbr_fprefix,unique_tempstr,sbr_fext))
      IF (findfile(fname)=0)
       SET fini = 1
      ENDIF
    ENDWHILE
    IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
      sbr_fext))=1)
     SET guf_return_val = 0
    ENDIF
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
    AND textlen(sbr_dlogfile) <= 30
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
    AND trim(sbr_logfile) != ""
    AND textlen(sbr_logfile) <= 30)
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
   FROM dm2_dba_tab_columns dutc,
    dtable dt
   WHERE dutc.table_name=trim(cnvtupper(dte_table_name))
    AND dutc.table_name=dt.table_name
    AND dutc.owner=value(currdbuser)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN("E")
  ELSE
   IF (curqual=0)
    RETURN("N")
   ELSE
    RETURN("F")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dm2_table_and_ccldef_exists(dtace_table_name,dtace_found_ind)
   SELECT INTO "nl:"
    FROM dm2_dba_tab_cols dutc,
     dtable dt
    WHERE dutc.table_name=trim(cnvtupper(dtace_table_name))
     AND dutc.table_name=dt.table_name
     AND dutc.owner=value(currdbuser)
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking if ",trim(cnvtupper(dtace_table_name)),
     " table and ccl def exists"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (curqual=0)
     SET dtace_found_ind = 0
    ELSE
     SET dtace_found_ind = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_disp_file(ddf_fname,ddf_desc)
   SET dm_err->eproc = concat("Displaying ",ddf_desc)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FREE DEFINE rtl2
   DEFINE rtl2 value(ddf_fname)
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
  IF (validate(currdbname," ")=" "
   AND currdb="ORACLE")
   SET dm_err->eproc = "Retrieving database name"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM v$database v
    DETAIL
     dgdn_name_out = v.name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
  ELSE
   SET dgdn_name_out = currdbname
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
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dm2_rdbms_version->version = p.version
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
   DECLARE sdi_vue2_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue3_exists_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dtable d
    WHERE d.table_name IN ("USER_VIEWS", "DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS")
    DETAIL
     CASE (d.table_name)
      OF "USER_VIEWS":
       sdi_def1_exists_ind = 1
      OF "DM2_DBA_TAB_COLUMNS":
       sdi_def2_exists_ind = 1
      OF "DM2_DBA_TAB_COLS":
       sdi_def3_exists_ind = 1
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(
    "Verifying that table definitions exist for USER_VIEWS, DM2_DBA_TAB_COLUMNS, and DM2_DBA_TAB_COLS."
    )=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
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
    WHERE uv.view_name IN ("DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS")
    DETAIL
     CASE (uv.view_name)
      OF "DM2_DBA_TAB_COLUMNS":
       sdi_vue2_exists_ind = 1
      OF "DM2_DBA_TAB_COLS":
       sdi_vue3_exists_ind = 1
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
    CALL parser(concat("rdb grant select any table to ",sdi_def_cur_user," go"))
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
    CALL parser(concat("rdb grant select any table to ",sdi_def_cur_user," go"))
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
 DECLARE dir_chk_schema_inst_backfill(null) = i2
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
 DECLARE dir_managed_ddl_setup(dmds_runid=f8) = i2
 DECLARE dir_perform_wait_interval(null) = i2
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
    1 table_monitoring = vc
    1 table_monitoring_maxretry = vc
    1 db_optimizer_category = vc
    1 dbstats_gather_method = vc
    1 cbf_maxrangegroups = vc
    1 resource_busy_maxretry = vc
    1 dbstats_chk_rpt = vc
    1 readme_space_calc = vc
    1 recompile_after_alter_tbl = vc
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
  )
  SET dir_env_maint_rs->src_env_id = 0
  SET dir_env_maint_rs->tgt_env_id = 0
  SET dir_env_maint_rs->tgt_hist_fnd = 0
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
  )
 ENDIF
 IF (validate(dm2_dft_extsize,- (1)) < 0)
  DECLARE dm2_dft_extsize = i4 WITH public, constant(163840)
  DECLARE dm2_dft_clin_tspace = vc WITH public, constant("D_A_SMALL")
  DECLARE dm2_dft_clin_itspace = vc WITH public, constant("I_A_SMALL")
  DECLARE dm2_dft_clin_ltspace = vc WITH public, constant("L_A_SMALL")
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
      WHERE t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_user_tables t
      WHERE t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")
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
    FROM dm2_user_tables t
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
   IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
       dm2_install_schema->file_prefix)),cnvtlower(dm2_sch_file->qual[1].file_suffix),".dat"))=0)
    SET dm_err->emsg = concat("Schema files not found for file prefix ",sbr_file_prefix," in ",
     sbr_vfp_dir)
    SET dm_err->eproc = "File Prefix Validation"
    SET dm_err->user_action = "Schema files not found.  Please enter a valid file prefix."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_toolset_usage(null)
   DECLARE dtu_use_dm2_toolset = i2
   DECLARE dtu_use_dm_toolset = i2
   DECLARE dtu_envid = i4
   DECLARE dtu_dm_info_exists = i2
   SET dtu_use_dm2_toolset = 1
   SET dtu_use_dm_toolset = 2
   SET dtu_envid = 0
   SET dtu_dm_info_exists = 0
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because database is DB2/SQLSRV")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if DM_INFO exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc,
     dtable dt
    WHERE utc.table_name="DM_INFO"
     AND utc.table_name=dt.table_name
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dtu_dm_info_exists = 1
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
   IF (currev < 8)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM toolset because the current rev is less then 8.0")
    ENDIF
    RETURN(dtu_use_dm_toolset)
   ENDIF
   IF (currdbuser="CDBA")
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because ADMIN database (always use dm2 toolset)")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if process running in an in-house domain."
   SET inhouse_misc->inhouse_domain = 0
   IF (validate(dm2_inhouse_flag,- (1)) > 0)
    SET inhouse_misc->inhouse_domain = 1
   ENDIF
   IF ((inhouse_misc->inhouse_domain=0)
    AND dtu_dm_info_exists=1)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     RETURN(0)
    ELSEIF (curqual=1)
     SET inhouse_misc->inhouse_domain = 1
    ENDIF
   ENDIF
   IF ((inhouse_misc->inhouse_domain=1))
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because INHOUSE domain (always use dm2 toolset)")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   IF (dtu_dm_info_exists=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(
      "Using DM toolset because DM_INFO does not exist and DM2 toolset requires it's existence")
    ENDIF
    RETURN(dtu_use_dm_toolset)
   ENDIF
   SET dm_err->eproc = "Getting environment id."
   SELECT INTO "nl:"
    FROM dm_info a,
     dm_environment b
    WHERE a.info_domain="DATA MANAGEMENT"
     AND a.info_name="DM_ENV_ID"
     AND a.info_number=b.environment_id
    DETAIL
     dtu_envid = b.environment_id
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unable to obtain ENVIRONMENT_ID from DM_INFO."
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking if packages are installed"
   SELECT INTO "nl:"
    FROM dm_alpha_features_env dafe,
     dm_ocd_log dol
    WHERE dafe.environment_id=dtu_envid
     AND dafe.alpha_feature_nbr IN (11277, 13384, 10292)
     AND dafe.environment_id=dol.environment_id
     AND dafe.alpha_feature_nbr=dol.ocd
     AND dol.project_type="INSTALL LOG"
     AND dol.project_name="POST-INST READMES"
     AND dol.status="COMPLETE"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual > 0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because required installation package exists.")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_alpha_features_env dafe
    WHERE dafe.environment_id=dtu_envid
     AND dafe.alpha_feature_nbr=10292
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_alpha_features_env dafe2
     WHERE dafe.environment_id=dafe2.environment_id
      AND dafe2.alpha_feature_nbr IN (11277, 13384))))
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual > 0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because required installation package exists.")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if CODE_VALUE exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc,
     dtable dt
    WHERE utc.table_name="CODE_VALUE"
     AND utc.table_name=dt.table_name
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = "Selecting from CODE_VALUE for codeset"
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=289570
      AND c.display="2004.02"
      AND c.active_ind=1
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     RETURN(0)
    ELSEIF (curqual > 0)
     IF ((dm_err->debug_flag > 0))
      CALL echo("Using DM2 toolset because required code value exists.")
     ENDIF
     RETURN(dtu_use_dm2_toolset)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("Using DM toolset because no DM2 toolset usage requirements were met.")
   ENDIF
   RETURN(dtu_use_dm_toolset)
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
        SET dcsa_error_msg = concat("Application Id ",trim(dcsa_fmt_appl_id))
        SET dcsa_error_msg = concat(dcsa_error_msg," is no longer active.")
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
   ELSE
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???1* | wc -w")
    ELSE
     SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"* | wc -w")
    ENDIF
    SET dgns_err_str = "0"
   ENDIF
   IF (dm2_push_dcl(dgns_dcl_find)=0)
    IF (findstring(dgns_err_str,dm_err->errtext) > 0)
     SET dm_err->eproc = "Find schema date."
     SET dm_err->emsg = "No schema date was found."
     SET dm_err->err_ind = 0
     RETURN(1)
    ENDIF
    RETURN(0)
   ELSE
    IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX")))
     IF (file_prefix="dm2a")
      SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???1* ")
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
 SUBROUTINE dir_chk_schema_inst_backfill(null)
   DECLARE dcs_dm_info_exists = c1 WITH protect, noconstant(" ")
   SET dm_err->eproc = "Determining if dm_info exist."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dcs_dm_info_exists = dm2_table_exists("DM_INFO")
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dcs_dm_info_exists="F"
    AND currdb="ORACLE")
    SET dm_err->eproc = "Determining if schema instance needs to be backfilled."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info
     WHERE info_domain="DATA MANAGEMENT"
      AND info_name="DM2_BACKFILL_SCHEMA_INSTANCE"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual > 0)
     EXECUTE dm2_backfill_schema_instance
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = "Checking for Backfill Complete row in DM_INFO"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM2 SCHEMA INSTANCE BACKFILL COMPLETE"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->eproc,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm2_install_schema->process_option != "CLIN COPY")
     AND currdbuser != "CDBA"
     AND curqual=0)
     SET dm_err->emsg = "Backfill Complete Row not in DM_INFO"
     SET dm_err->err_ind = 1
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
      dm2_dba_tables t
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
 IF (validate(dm2_server_link->wrapper," ")=" ")
  FREE RECORD dm2_server_link
  RECORD dm2_server_link(
    1 wrapper = vc
    1 server_name = vc
    1 drop_server_ind = i2
    1 server_rdbms = vc
    1 server_type = vc
    1 server_version = vc
    1 user = vc
    1 password = vc
    1 node = vc
    1 dbase = vc
    1 hostname = vc
    1 option_vntb = vc
  )
  SET dm2_server_link->wrapper = "NONE"
  SET dm2_server_link->option_vntb = "N"
 ENDIF
 IF (validate(dm2_nickname_info->nickname," ")=" ")
  FREE RECORD dm2_nickname_info
  RECORD dm2_nickname_info(
    1 nickname = vc
    1 drop_ind = i2
    1 create_ind = i2
    1 local_owner = vc
    1 server = vc
    1 remote_table = vc
    1 remote_owner = vc
    1 link_server = vc
    1 col_list1 = vc
    1 col_list2 = vc
  )
  SET dm2_nickname_info->nickname = "NONE"
 ENDIF
 DECLARE dm2_create_server_link(null) = i2
 DECLARE dm2_create_nickname(null) = i2
 DECLARE check_dm2tools_nicknames(sbr_cdn_drop_ind=i2) = i2
 DECLARE dm2_get_db_link(null) = vc
 DECLARE dm2_fill_nick_except(sbr_alias=vc) = vc
 SUBROUTINE dm2_fill_nick_except(sbr_alias)
   DECLARE dfne_in_clause = vc WITH public, noconstant("")
   SET dfne_in_clause = concat("substring(1,3,",sbr_alias,".table_name) != 'DM2' ")
   SET dfne_in_clause = concat(dfne_in_clause," and ",sbr_alias,".table_name not in ('DM_INFO',",
    "'DM_SEGMENTS',",
    "'DM_TABLE_LIST',","'DM_USER_CONSTRAINTS',","'DM_USER_CONS_COLUMNS',","'DM_USER_IND_COLUMNS',",
    "'DM_USER_TAB_COLS',",
    "'EXPLAIN_ARGUMENT',","'EXPLAIN_INSTANCE',","'EXPLAIN_OBJECT',","'EXPLAIN_OPERATOR',",
    "'EXPLAIN_PREDICATE',",
    "'EXPLAIN_STATEMENT',","'EXPLAIN_STREAM') ")
   RETURN(dfne_in_clause)
 END ;Subroutine
 SUBROUTINE dm2_create_server_link(null)
   DECLARE dcs_push_str = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET dm_err->eproc = concat("Determining if wrapper ",cnvtupper(dm2_server_link->wrapper),
     " exists.")
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (syscat.wrappers w)
     WHERE cnvtupper(w.wrapname)=cnvtupper(dm2_server_link->wrapper)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = concat("Creating wrapper ",cnvtupper(dm2_server_link->wrapper))
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dcs_push_str = concat("rdb create wrapper ",cnvtupper(dm2_server_link->wrapper)," go")
     IF (dm2_push_cmd(dcs_push_str,1)=0)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Determining if server ",cnvtupper(dm2_server_link->server_name),
     " exists.")
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (syscat.servers s)
     WHERE cnvtupper(s.servername)=cnvtupper(dm2_server_link->server_name)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=1
     AND (dm2_server_link->drop_server_ind=1))
     SET dm_err->eproc = concat("Dropping server ",cnvtupper(dm2_server_link->server_name))
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dcs_push_str = concat("rdb drop server ",cnvtupper(dm2_server_link->server_name)," go")
     IF (dm2_push_cmd(dcs_push_str,1)=0)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
    IF (((curqual=0) OR ((dm2_server_link->drop_server_ind=1))) )
     SET dm_err->eproc = concat("Creating server ",cnvtupper(dm2_server_link->server_name))
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (cnvtupper(dm2_server_link->server_rdbms)="ORACLE")
      SET dcs_push_str = concat('rdb asis ("create server ',cnvtupper(dm2_server_link->server_name),
       " type ",dm2_server_link->server_type," version ",
       dm2_server_link->server_version," wrapper ",cnvtupper(dm2_server_link->wrapper),
       " options (node ",build("'",dm2_server_link->node,"',"),
       " varchar_no_trailing_blanks '",build(trim(dm2_server_link->option_vntb),"')"),'") go')
     ELSE
      SET dcs_push_str = concat("rdb asis (^create server ",cnvtupper(dm2_server_link->server_name),
       " type ",dm2_server_link->server_type," version ",
       dm2_server_link->server_version," wrapper ",cnvtupper(dm2_server_link->wrapper),
       " authorization ",build('"',dm2_server_link->user,'"'),
       " password ",build('"',dm2_server_link->password,'"')," options (node ",build("'",
        dm2_server_link->node,"',")," dbname ",
       build("'",dm2_server_link->dbase,"',")," collating_sequence 'Y', fold_pw 'L')^) go")
     ENDIF
     IF (dm2_push_cmd(dcs_push_str,1)=0)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Determining if ",trim(currdbuser)," user mapping exists for server ",
     cnvtupper(dm2_server_link->server_name))
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (syscat.useroptions uo)
     WHERE cnvtupper(uo.servername)=cnvtupper(dm2_server_link->server_name)
      AND cnvtupper(uo.authid)=cnvtupper(currdbuser)
     WITH nocounter, maxqual(uo,1)
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = concat("Creating ",trim(currdbuser)," user mapping for server ",cnvtupper(
       dm2_server_link->server_name))
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dcs_push_str = concat('rdb asis ("create user mapping for ',trim(currdbuser)," server ",
      cnvtupper(dm2_server_link->server_name)," options (remote_authid ",
      build("'",dm2_server_link->user,"',")," remote_password ",build("'",dm2_server_link->password,
       "')"),'") go')
     IF (dm2_push_cmd(dcs_push_str,1)=0)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ELSE
    IF (dm2_set_autocommit(1)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Determining if linked server ",cnvtupper(dm2_server_link->server_name
      )," exists.")
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM sysservers s
     WHERE cnvtupper(s.srvname)=cnvtupper(dm2_server_link->server_name)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=1
     AND (dm2_server_link->drop_server_ind=1))
     SET dm_err->eproc = concat("Dropping linked server ",cnvtupper(dm2_server_link->server_name))
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dcs_push_str = concat('rdb asis("sp_dropserver ',build("'",cnvtupper(dm2_server_link->
        server_name),"',"),^'droplogins'") go^)
     IF (dm2_push_cmd(dcs_push_str,1)=0)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
    IF (((curqual=0) OR ((dm2_server_link->drop_server_ind=1))) )
     SET dm_err->eproc = concat("Creating linked server ",cnvtupper(dm2_server_link->server_name))
     CALL disp_msg(" ",dm_err->logfile,0)
     IF ((dm2_install_schema->special_ih_process=0))
      SET dcs_push_str = build(^rdb asis("sp_addlinkedserver @server = '^,cnvtupper(dm2_server_link->
        server_name),"', @srvproduct = '', @provider = 'SQLOLEDB', @datasrc = '",dm2_server_link->
       hostname,"',  @catalog = '",
       cnvtupper(dm2_server_link->dbase),^'") go^)
     ELSE
      SET dcs_push_str = build(^rdb asis("sp_addlinkedserver @server = '^,cnvtupper(dm2_server_link->
        server_name),"', @srvproduct = 'ORACLE', @provider = 'MSDAORA', @datasrc = '",dm2_server_link
       ->hostname,^'") go^)
     ENDIF
     IF (dm2_push_cmd(dcs_push_str,1)=0)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
     SET dm_err->eproc = concat("Creating linked server login for linked server ",cnvtupper(
       dm2_server_link->server_name))
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dcs_push_str = build(^rdb asis("sp_addlinkedsrvlogin @rmtsrvname = '^,cnvtupper(
       dm2_server_link->server_name),"', @useself = 'false', @rmtuser = '",dm2_server_link->user,
      "', @rmtpassword = '",
      dm2_server_link->password,^'") go^)
     IF (dm2_push_cmd(dcs_push_str,1)=0)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
     IF (dm2_set_autocommit(0)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_create_nickname(null)
   DECLARE dcn_push_str = vc WITH protect, noconstant(" ")
   DECLARE dcn_grp_str1 = vc WITH protect, noconstant(" ")
   DECLARE dcn_grp_str2 = vc WITH protect, noconstant(" ")
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_nickname_info->drop_ind=1))
    SET dm_err->eproc = concat("Dropping nickname ",dm2_nickname_info->nickname)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (currdb="ORACLE")
     SET dcn_push_str = concat("rdb drop public synonym  ",dm2_nickname_info->nickname," go")
    ELSEIF (currdb="DB2UDB")
     SET dcn_push_str = concat("rdb drop nickname ",build(dm2_nickname_info->local_owner,".",
       dm2_nickname_info->nickname)," go")
    ELSE
     SET dcn_push_str = concat('rdb asis("drop view  ',build(dm2_nickname_info->local_owner,".",
       dm2_nickname_info->nickname),'") go')
    ENDIF
    IF (dm2_push_cmd(dcn_push_str,1)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=0))
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   IF ((dm2_nickname_info->create_ind=1))
    SET dm_err->eproc = concat("Creating nickname ",dm2_nickname_info->nickname)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (currdb="ORACLE")
     SET dcn_push_str = concat("rdb create public synonym  ",dm2_nickname_info->nickname," for ",
      build(dm2_nickname_info->remote_owner,".",dm2_nickname_info->remote_table,"@",dm2_nickname_info
       ->server)," go")
    ELSEIF (currdb="DB2UDB")
     SET dcn_push_str = concat("rdb create nickname ",build(dm2_nickname_info->local_owner,".",
       dm2_nickname_info->nickname)," for ",build(dm2_nickname_info->server,".",dm2_nickname_info->
       remote_owner,".",dm2_nickname_info->remote_table)," go")
    ELSE
     IF (validate(dm2_inhouse_oracle_capture,0)=1)
      SET dcn_push_str = concat('rdb asis("CREATE VIEW  ',concat(dm2_nickname_info->local_owner,".",
        dm2_nickname_info->nickname," AS (SELECT * FROM OPENQUERY(",dcs_lnksrv,
        ",","' SELECT * FROM ",dm2_nickname_info->remote_table,^'))") go^))
     ELSE
      IF ((dm2_nickname_info->col_list1="NONE"))
       SET dcn_push_str = concat('rdb asis("create view  ',build(dm2_nickname_info->local_owner,".",
         dm2_nickname_info->nickname)," as select * from ",build(dm2_nickname_info->link_server,".",
         dm2_nickname_info->remote_table),'") go')
      ELSE
       SET dcn_grp_str1 = build(dm2_nickname_info->local_owner,".",dm2_nickname_info->nickname)
       SET dcn_grp_str2 = build(dm2_nickname_info->link_server,".",dm2_nickname_info->remote_table)
       SET dcn_push_str = concat('rdb asis("create view  ',dcn_grp_str1,dm2_nickname_info->col_list1,
        " ",dm2_nickname_info->col_list2,
        " from ",dcn_grp_str2,'") go')
      ENDIF
     ENDIF
    ENDIF
    IF (dm2_push_cmd(dcn_push_str,1)=0)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_dm2tools_nicknames(sbr_cdn_drop_ind)
   DECLARE cdn_admin_tables_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_tab_col_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_dm_info_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_seq_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_tables_cre_ind = i2 WITH protect, noconstant(1)
   DECLARE cdn_admin_tab_col_cre_ind = i2 WITH protect, noconstant(1)
   DECLARE cdn_admin_dm_info_cre_ind = i2 WITH protect, noconstant(1)
   DECLARE cdn_admin_seq_cre_ind = i2 WITH protect, noconstant(1)
   DECLARE cdn_dyn_where = vc WITH public
   DECLARE cdn_db_link = vc WITH protect, noconstant(" ")
   DECLARE cdn_admin_tables_def_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_tab_col_def_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_dm_info_def_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_seq_def_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Determining if DM2_ADMIN_TABLES, ","DM2_ADMIN_TAB_COLUMNS, ",
    "DM2_ADMIN_SEQUENCES, ","and DM2_ADMIN_DM_INFO nicknames exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("server_name=",dm2_server_link->server_name))
    CALL echo(build("server_link=",dm2_server_link->user))
    CALL echo(build("dbase =",dm2_server_link->dbase))
   ENDIF
   IF (currdb="ORACLE")
    SET cdn_dyn_where = 'ds.owner = "PUBLIC"'
   ELSE
    SET cdn_dyn_where = 'ds.owner = "V500"'
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_dba_synonyms ds
    WHERE cnvtupper(ds.synonym_name) IN ("DM2_ADMIN_SEQUENCES", "DM2_ADMIN_TABLES",
    "DM2_ADMIN_TAB_COLUMNS", "DM2_ADMIN_DM_INFO")
     AND parser(cdn_dyn_where)
    DETAIL
     IF (ds.synonym_name="DM2_ADMIN_DM_INFO")
      IF (currdb IN ("DB2UDB", "ORACLE"))
       IF (validate(ds.db_link,"@") != "@")
        cdn_pos = findstring(".",validate(ds.db_link," ")), cdn_db_link = substring(1,(cdn_pos - 1),
         validate(ds.db_link," "))
        IF (cnvtupper(cdn_db_link) != cnvtupper(dm2_server_link->server_name))
         CALL echo("found DM2_ADMIN_DM_INFO nickname but using wrong [linked] server"),
         CALL echo(build("old_db_link=",cdn_db_link)), cdn_admin_dm_info_drop_ind = 1,
         cdn_admin_dm_info_cre_ind = 1
        ELSE
         cdn_admin_dm_info_drop_ind = sbr_cdn_drop_ind, cdn_admin_dm_info_cre_ind = sbr_cdn_drop_ind
        ENDIF
       ENDIF
      ELSEIF (currdb="SQLSRV")
       IF (findstring(concat(" ",dm2_server_link->server_name),validate(ds.text,"@"))=0)
        CALL echo("found DM2_ADMIN_DM_INFO nickname but using wrong [linked] server"),
        CALL echo(build("old_db_link=",validate(ds.text," "))), cdn_admin_dm_info_drop_ind = 1,
        cdn_admin_dm_info_cre_ind = 1
       ELSE
        cdn_admin_dm_info_drop_ind = sbr_cdn_drop_ind, cdn_admin_dm_info_cre_ind = sbr_cdn_drop_ind
       ENDIF
      ELSE
       cdn_admin_dm_info_drop_ind = sbr_cdn_drop_ind, cdn_admin_dm_info_cre_ind = sbr_cdn_drop_ind
      ENDIF
     ENDIF
     IF (ds.synonym_name="DM2_ADMIN_TABLES")
      IF (currdb IN ("DB2UDB", "ORACLE"))
       IF (validate(ds.db_link,"@") != "@")
        cdn_pos = findstring(".",validate(ds.db_link," ")), cdn_db_link = substring(1,(cdn_pos - 1),
         validate(ds.db_link," "))
        IF (cnvtupper(cdn_db_link) != cnvtupper(dm2_server_link->server_name))
         CALL echo("found dm2_admin_tables nickname but using wrong [linked] server"),
         CALL echo(build("old_db_link=",cdn_db_link)), cdn_admin_tables_drop_ind = 1,
         cdn_admin_tables_cre_ind = 1
        ELSE
         cdn_admin_tables_drop_ind = sbr_cdn_drop_ind, cdn_admin_tables_cre_ind = sbr_cdn_drop_ind
        ENDIF
       ENDIF
      ELSEIF (currdb="SQLSRV")
       IF (findstring(concat(" ",dm2_server_link->server_name),validate(ds.text,"@"))=0)
        CALL echo("found dm2_admin_tables nickname but using wrong [linked] server"),
        CALL echo(build("old_db_link=",validate(ds.text," "))), cdn_admin_tables_drop_ind = 1,
        cdn_admin_tables_cre_ind = 1
       ELSE
        cdn_admin_tables_drop_ind = sbr_cdn_drop_ind, cdn_admin_tables_cre_ind = sbr_cdn_drop_ind
       ENDIF
      ELSE
       cdn_admin_tables_drop_ind = sbr_cdn_drop_ind, cdn_admin_tables_cre_ind = sbr_cdn_drop_ind
      ENDIF
     ENDIF
     IF (ds.synonym_name="DM2_ADMIN_TAB_COLUMNS")
      IF (currdb IN ("DB2UDB", "ORACLE"))
       IF (validate(ds.db_link,"@") != "@")
        cdn_pos = findstring(".",validate(ds.db_link," ")), cdn_db_link = substring(1,(cdn_pos - 1),
         validate(ds.db_link," "))
        IF (cnvtupper(cdn_db_link) != cnvtupper(dm2_server_link->server_name))
         CALL echo("found dm2_admin_tab_columns nickname but using wrong [linked] server"),
         CALL echo(build("old_db_link=",cdn_db_link)), cdn_admin_tab_col_drop_ind = 1,
         cdn_admin_tab_col_cre_ind = 1
        ELSE
         cdn_admin_tab_col_drop_ind = sbr_cdn_drop_ind, cdn_admin_tab_col_cre_ind = sbr_cdn_drop_ind
        ENDIF
       ENDIF
      ELSEIF (currdb="SQLSRV")
       IF (findstring(concat(" ",dm2_server_link->server_name),validate(ds.text,"@"))=0)
        CALL echo("found dm2_admin_tab_columns nickname but using wrong [linked] server"),
        CALL echo(build("old_db_link=",validate(ds.text," "))), cdn_admin_tab_col_drop_ind = 1,
        cdn_admin_tab_col_cre_ind = 1
       ELSE
        cdn_admin_tab_col_drop_ind = sbr_cdn_drop_ind, cdn_admin_tab_col_cre_ind = sbr_cdn_drop_ind
       ENDIF
      ELSE
       cdn_admin_tab_col_drop_ind = sbr_cdn_drop_ind, cdn_admin_tab_col_cre_ind = sbr_cdn_drop_ind
      ENDIF
     ENDIF
     IF (ds.synonym_name="DM2_ADMIN_SEQUENCES")
      IF (currdb IN ("DB2UDB", "ORACLE"))
       IF (validate(ds.db_link,"@") != "@")
        cdn_pos = findstring(".",validate(ds.db_link," ")), cdn_db_link = substring(1,(cdn_pos - 1),
         validate(ds.db_link," "))
        IF (cnvtupper(cdn_db_link) != cnvtupper(dm2_server_link->server_name))
         CALL echo("found dm2_admin_sequences nickname but using wrong [linked] server"),
         CALL echo(build("old_db_link=",cdn_db_link)), cdn_admin_seq_drop_ind = 1,
         cdn_admin_seq_cre_ind = 1
        ELSE
         cdn_admin_seq_drop_ind = sbr_cdn_drop_ind, cdn_admin_seq_cre_ind = sbr_cdn_drop_ind
        ENDIF
       ENDIF
      ELSEIF (currdb="SQLSRV")
       IF (findstring(concat(" ",dm2_server_link->server_name),validate(ds.text,"@"))=0)
        CALL echo("found dm2_admin_sequences nickname but using wrong [linked] server"),
        CALL echo(build("old_db_link=",validate(ds.text," "))), cdn_admin_seq_drop_ind = 1,
        cdn_admin_seq_cre_ind = 1
       ELSE
        cdn_admin_seq_drop_ind = sbr_cdn_drop_ind, cdn_admin_seq_cre_ind = sbr_cdn_drop_ind
       ENDIF
      ELSE
       cdn_admin_seq_drop_ind = sbr_cdn_drop_ind, cdn_admin_seq_cre_ind = sbr_cdn_drop_ind
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET cdn_admin_tables_cre_ind = 1
    SET cdn_admin_tab_col_cre_ind = 1
    SET cdn_admin_dm_info_cre_ind = 1
    SET cdn_admin_seq_cre_ind = 1
   ENDIF
   IF (((cdn_admin_tables_cre_ind=0) OR (((cdn_admin_tab_col_cre_ind=0) OR (((
   cdn_admin_dm_info_cre_ind=0) OR (cdn_admin_seq_cre_ind=0)) )) )) )
    SET dm_err->eproc = "Check CCL definitions for DM2_ADMIN* synonyms."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dtable d
     WHERE d.table_name IN ("DM2_ADMIN_TABLES", "DM2_ADMIN_TAB_COLUMNS", "DM2_ADMIN_DM_INFO",
     "DM2_ADMIN_SEQUENCES")
     DETAIL
      CASE (d.table_name)
       OF "DM2_ADMIN_TABLES":
        cdn_admin_tables_def_ind = 1
       OF "DM2_ADMIN_TAB_COLUMNS":
        cdn_admin_tab_col_def_ind = 1
       OF "DM2_ADMIN_DM_INFO":
        cdn_admin_dm_info_def_ind = 1
       OF "DM2_ADMIN_SEQUENCES":
        cdn_admin_seq_def_ind = 1
      ENDCASE
     WITH nocounter
    ;end select
    IF (check_error("Verifying DM2_ADMIN* ccl defs exist.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm2_nickname_info->nickname = "DM2_ADMIN_TABLES"
   SET dm2_nickname_info->drop_ind = cdn_admin_tables_drop_ind
   SET dm2_nickname_info->create_ind = cdn_admin_tables_cre_ind
   SET dm2_nickname_info->local_owner = "V500"
   SET dm2_nickname_info->remote_table = "DM2_USER_TABLES"
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   IF ((dm2_install_schema->special_ih_process=0))
    SET dm2_nickname_info->server = dm2_server_link->server_name
    SET dm2_nickname_info->remote_owner = dm2_server_link->user
    SET dm2_nickname_info->link_server = build(dm2_server_link->server_name,".",dm2_server_link->
     dbase,".",dm2_server_link->user)
   ELSE
    SET dm2_nickname_info->server = dm2_server_link->server_name
    SET dm2_nickname_info->remote_owner = dm2_server_link->user
    SET dm2_nickname_info->link_server = build(dm2_server_link->server_name,"..",dm2_server_link->
     user)
   ENDIF
   IF ((((dm2_nickname_info->drop_ind=1)) OR ((dm2_nickname_info->create_ind=1))) )
    SET dm_err->eproc = "(Re)creating DM2_ADMIN_TABLES nickname to access remote ADMIN tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=1))
      EXECUTE oragen3 "DM2_ADMIN_TABLES"
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (cdn_admin_tables_def_ind=0)
     EXECUTE oragen3 "DM2_ADMIN_TABLES"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_nickname_info->nickname = "DM2_ADMIN_TAB_COLUMNS"
   SET dm2_nickname_info->drop_ind = cdn_admin_tab_col_drop_ind
   IF ((dm2_install_schema->special_ih_process=1)
    AND currdb="DB2UDB")
    SET dm2_nickname_info->create_ind = 0
   ELSE
    SET dm2_nickname_info->create_ind = cdn_admin_tab_col_cre_ind
   ENDIF
   SET dm2_nickname_info->local_owner = "V500"
   SET dm2_nickname_info->remote_table = "DM2_USER_TAB_COLUMNS"
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   IF ((dm2_install_schema->special_ih_process=0))
    SET dm2_nickname_info->server = dm2_server_link->server_name
    SET dm2_nickname_info->remote_owner = dm2_server_link->user
    SET dm2_nickname_info->link_server = build(dm2_server_link->server_name,".",dm2_server_link->
     dbase,".",dm2_server_link->user)
   ELSE
    SET dm2_nickname_info->server = dm2_server_link->server_name
    SET dm2_nickname_info->remote_owner = dm2_server_link->user
    SET dm2_nickname_info->link_server = build(dm2_server_link->server_name,"..",dm2_server_link->
     user)
   ENDIF
   CALL echo(build("link_server=",dm2_nickname_info->link_server))
   IF ((((dm2_nickname_info->drop_ind=1)) OR ((dm2_nickname_info->create_ind=1))) )
    SET dm_err->eproc = "(Re)creating DM2_ADMIN_TAB_COLUMNS nickname to access remote ADMIN tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=1))
      EXECUTE oragen3 "DM2_ADMIN_TAB_COLUMNS"
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (cdn_admin_tab_col_def_ind=0)
     EXECUTE oragen3 "DM2_ADMIN_TAB_COLUMNS"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_nickname_info->nickname = "DM2_ADMIN_SEQUENCES"
   SET dm2_nickname_info->drop_ind = cdn_admin_seq_drop_ind
   SET dm2_nickname_info->create_ind = cdn_admin_seq_cre_ind
   SET dm2_nickname_info->local_owner = "V500"
   SET dm2_nickname_info->remote_table = "DM2_USER_SEQUENCES"
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   SET dm2_nickname_info->server = dm2_server_link->server_name
   SET dm2_nickname_info->remote_owner = dm2_server_link->user
   IF ((dm2_install_schema->special_ih_process=0))
    SET dm2_nickname_info->link_server = build(dm2_server_link->server_name,".",dm2_server_link->
     dbase,".",dm2_server_link->user)
   ELSE
    SET dm2_nickname_info->link_server = build(dm2_server_link->server_name,"..",dm2_server_link->
     user)
   ENDIF
   IF ((((dm2_nickname_info->drop_ind=1)) OR ((dm2_nickname_info->create_ind=1))) )
    SET dm_err->eproc = "(Re)creating DM2_ADMIN_SEQUENCES nickname to access remote ADMIN tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=1))
      EXECUTE oragen3 "DM2_ADMIN_SEQUENCES"
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (cdn_admin_seq_def_ind=0)
     EXECUTE oragen3 "DM2_ADMIN_SEQUENCES"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_nickname_info->nickname = "DM2_ADMIN_DM_INFO"
   SET dm2_nickname_info->drop_ind = cdn_admin_dm_info_drop_ind
   SET dm2_nickname_info->create_ind = cdn_admin_dm_info_cre_ind
   SET dm2_nickname_info->local_owner = "V500"
   SET dm2_nickname_info->remote_table = "DM_INFO"
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   IF ((dm2_install_schema->special_ih_process=0))
    SET dm2_nickname_info->server = dm2_server_link->server_name
    SET dm2_nickname_info->remote_owner = dm2_server_link->user
    SET dm2_nickname_info->link_server = build(dm2_server_link->server_name,".",dm2_server_link->
     dbase,".",dm2_server_link->user)
   ELSE
    SET dm2_nickname_info->server = dm2_server_link->server_name
    SET dm2_nickname_info->remote_owner = dm2_server_link->user
    SET dm2_nickname_info->link_server = build(dm2_server_link->server_name,"..",dm2_server_link->
     user)
   ENDIF
   IF ((((dm2_nickname_info->drop_ind=1)) OR ((dm2_nickname_info->create_ind=1))) )
    SET dm_err->eproc = "(Re)creating DM_INFO nickname to access remote ADMIN tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=1))
      IF ((dm2_install_schema->process_option != "CLIN COPY"))
       EXECUTE oragen3 "DM2_ADMIN_DM_INFO"
       IF ((dm_err->err_ind=1))
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (cdn_admin_dm_info_def_ind=0
     AND (dm2_install_schema->process_option != "CLIN COPY"))
     EXECUTE oragen3 "DM2_ADMIN_DM_INFO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_db_link(null)
   DECLARE dgdbl_link = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET dgdbl_link = "ADMIN1"
   ELSEIF (currdb="SQLSRV")
    SET dgdbl_link = "ADMIN"
   ELSE
    SET dm_err->eproc = "Getting admin db link from existing synonyms"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_dba_synonyms ds
     WHERE ds.table_name="DM_ENVIRONMENT"
     DETAIL
      dgdbl_link = cnvtlower(substring(1,(findstring(".",ds.db_link) - 1),ds.db_link))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     SET dgdbl_link = "DM2_ERROR"
    ELSEIF (curqual=0)
     SET dgdbl_link = "DM2_UNKNOWN"
    ELSE
     SET dm_err->eproc =
     "Making sure admin db/listener is up and that synonyms point to correct admin db"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm_environment de
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      SET dgdbl_link = "DM2_ERROR"
     ENDIF
    ENDIF
   ENDIF
   RETURN(dgdbl_link)
 END ;Subroutine
 DECLARE dm2_get_srvname(sbr_spc_view=i2) = i2
 SUBROUTINE dm2_get_srvname(sbr_spc_view)
   IF ( NOT (sbr_spc_view IN (0, 1)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid view indicator"
    SET dm_err->eproc = "Retrieving server name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (currdb="SQLSRV")
    IF (sbr_spc_view=0)
     SELECT INTO "nl:"
      FROM sysservers s
      WHERE s.srvproduct="SQL Server"
       AND s.srvname=s.datasource
       AND s.srvid=0
       AND s.isremote=0
      DETAIL
       dm2_install_schema->servername = s.srvname, dm2_install_schema->frmt_servername = cnvtupper(
        replace(trim(s.srvname,3),"\","_",1))
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM dm2syssrv s
      WHERE s.srvproduct="SQL Server"
       AND s.srvname=s.datasource
       AND s.srvid=0
       AND s.isremote=0
      DETAIL
       dm2_install_schema->servername = s.srvname, dm2_install_schema->frmt_servername = cnvtupper(
        replace(trim(s.srvname,3),"\","_",1))
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Retreiving server name in subroutine DM2_GET_SRVNAME")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No row qualified"
     SET dm_err->eproc = "Retreiving server name in subroutine DM2_GET_SRVNAME"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE initial_process(null) = i2
 DECLARE create_empty_files(null) = i2
 DECLARE build_schema_exceptions(null) = i2
 DECLARE get_export_list(null) = i2
 IF (currdb != "SQLSRV"
  AND dcs_inhouse_oracle_capture != 1)
  DECLARE create_src_tables_object(null) = i2
 ENDIF
 DECLARE check_for_object(cfo_name=vc,cfo_owner=vc,cfo_type=vc) = i2
 DECLARE create_object(cdo_name=vc,cdo_type=vc,cdo_table=vc) = i2
 DECLARE process_load_cmds(plc_process=vc) = i2
 RECORD tlist(
   1 tcount = i4
   1 qual[*]
     2 table_name = vc
     2 suffixed_table_name = vc
     2 tables_doc_ind = i4
     2 drop_ind = i2
 )
 SET tlist->tcount = 0
 IF (initial_process(null)=0)
  GO TO exit_program
 ENDIF
 IF (dcs_inhouse_oracle_capture != 1)
  IF (create_src_tables_object(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF (build_schema_exceptions(null)=0)
  GO TO exit_program
 ENDIF
 IF (get_export_list(null)=0)
  GO TO exit_program
 ENDIF
 IF (process_load_cmds("CREATE")=0)
  GO TO exit_program
 ENDIF
 IF (currdb="DB2UDB")
  SET dm_err->eproc = concat("Removing messages text file ",dce_msgs_file," if it already exists")
  CALL disp_msg(" ",dm_err->logfile,0)
  IF (findfile(dce_msgs_file)=1)
   IF (dm2_push_dcl(concat("rm ",dce_msgs_file))=0)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 SET dm_err->eproc = "Exporting tables"
 CALL disp_msg(" ",dm_err->logfile,0)
 FOR (dce_cnt = 1 TO tlist->tcount)
   IF (((dce_type="ADMIN") OR ((tlist->qual[dce_cnt].tables_doc_ind=1))) )
    IF (dce_type_run="EXPORT")
     IF (currdb="SQLSRV")
      SET dm2_nickname_info->nickname = cnvtupper(tlist->qual[dce_cnt].table_name)
      SET dm2_nickname_info->drop_ind = tlist->qual[dce_cnt].drop_ind
      SET dm2_nickname_info->create_ind = 1
      SET dm2_nickname_info->local_owner = "dbo"
      SET dm2_nickname_info->server = "NONE"
      SET dm2_nickname_info->remote_table = cnvtupper(tlist->qual[dce_cnt].table_name)
      SET dm2_nickname_info->remote_owner = "NONE"
      SET dm2_nickname_info->link_server = dce_node
      IF (dm2_create_nickname(null)=0)
       GO TO exit_program
      ENDIF
      SET dce_str = build('bcp "',cnvtupper(currdbname),".dbo.",cnvtupper(tlist->qual[dce_cnt].
        table_name),'" out "',
       dce_full_path,tlist->qual[dce_cnt].suffixed_table_name,'.exp" -e"',dce_msgs_file,
       '" -c -k -t"\t^" -S"',
       dm2_install_schema->servername,'" -U"',dce_user,'" -P"',dce_pswd,
       '"')
      IF (dm2_push_dcl(dce_str)=0)
       ROLLBACK
       GO TO exit_program
      ELSE
       IF (parse_errfile(dce_msgs_file)=0)
        GO TO exit_program
       ELSE
        IF (textlen(trim(dm_err->errtext)) > 0)
         SET dm_err->err_ind = 1
         SET dm_err->emsg = dm_err->errtext
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         GO TO exit_program
        ENDIF
       ENDIF
       COMMIT
      ENDIF
      SET dm2_nickname_info->drop_ind = 1
      SET dm2_nickname_info->create_ind = 0
      IF (dm2_create_nickname(null)=0)
       GO TO exit_program
      ENDIF
     ELSEIF (dce_node != "LOCAL")
      SET dm2_nickname_info->nickname = tlist->qual[dce_cnt].table_name
      SET dm2_nickname_info->drop_ind = tlist->qual[dce_cnt].drop_ind
      SET dm2_nickname_info->create_ind = 1
      SET dm2_nickname_info->server = "ORA_EXP"
      SET dm2_nickname_info->local_owner = "dbo"
      SET dm2_nickname_info->remote_table = tlist->qual[dce_cnt].table_name
      SET dm2_nickname_info->remote_owner = dce_user
      SET dm2_nickname_info->link_server = dce_node
      IF (dm2_create_nickname(null)=0)
       GO TO exit_program
      ENDIF
      IF (dce_num_rows="ALL")
       SET dce_str = concat('db2 "export to ',dce_full_path,tlist->qual[dce_cnt].suffixed_table_name,
        ".ixf of ixf messages ",dce_msgs_file,
        " select * from dbo.",tlist->qual[dce_cnt].table_name,'"')
      ELSE
       SET dce_str = concat('db2 "export to ',dce_full_path,tlist->qual[dce_cnt].suffixed_table_name,
        ".ixf of ixf messages ",dce_msgs_file,
        " select * from dbo.",tlist->qual[dce_cnt].table_name," fetch first ",dce_num_rows,
        ' rows only "')
      ENDIF
      IF (dm2_push_dcl(dce_str)=0)
       ROLLBACK
       GO TO exit_program
      ENDIF
      COMMIT
      SET dce_str = concat("chmod 777 ",dce_full_path,tlist->qual[dce_cnt].suffixed_table_name,".ixf"
       )
      IF (dm2_push_dcl(dce_str)=0)
       GO TO exit_program
      ENDIF
      SET dm2_nickname_info->drop_ind = 1
      SET dm2_nickname_info->create_ind = 0
      IF (dm2_create_nickname(null)=0)
       GO TO exit_program
      ENDIF
     ELSE
      IF (dce_num_rows="ALL")
       SET dce_str = concat('db2 "export to ',dce_full_path,tlist->qual[dce_cnt].suffixed_table_name,
        ".ixf of ixf messages ",dce_msgs_file,
        " select * from ",tlist->qual[dce_cnt].table_name,'"')
      ELSE
       SET dce_str = concat('db2 "export to ',dce_full_path,tlist->qual[dce_cnt].suffixed_table_name,
        ".ixf of ixf messages ",dce_msgs_file,
        " select * from ",tlist->qual[dce_cnt].table_name," fetch first ",dce_num_rows,' rows only "'
        )
      ENDIF
      IF (dm2_push_dcl(dce_str)=0)
       ROLLBACK
       GO TO exit_program
      ENDIF
      COMMIT
      SET dce_str = concat("chmod 777 ",dce_full_path,tlist->qual[dce_cnt].suffixed_table_name,".ixf"
       )
      IF (dm2_push_dcl(dce_str)=0)
       GO TO exit_program
      ENDIF
     ENDIF
    ENDIF
    IF (process_load_cmds("APPEND")=0)
     GO TO exit_program
    ENDIF
   ENDIF
 ENDFOR
 IF (create_empty_files(null)=0)
  GO TO exit_program
 ENDIF
 SET dm2_install_schema->oragen3_ignore_dm_columns_doc = 0
 GO TO exit_program
 SUBROUTINE initial_process(null)
   IF (check_logfile(dce_logfile_prefix,".log","DM2_CREATE_EXPORT LOGFILE")=0)
    RETURN(0)
   ENDIF
   IF (validate(dm2_inhouse_oracle_capture,0)=1)
    SET dcs_inhouse_oracle_capture = 1
   ENDIF
   IF (currdb="SQLSRV"
    AND dcs_inhouse_oracle_capture=1)
    SET dm_err->eproc = "Getting Oracle Linked Server from DM_INFO"
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_name="ORACLE LINKED SERVER-CAPTURE"
      AND d.info_domain="DM2TOOLS"
     DETAIL
      dcs_lnksrv = d.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ELSEIF (curqual=0)
     SET dm_err->emsg = "Inhouse Oracle Linked Server not found in DM_INFO"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Getting linked server name for inhouse Oracle capture on SQLSRV"
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm2_install_schema->oragen3_ignore_dm_columns_doc = 1
   SET dm_err->eproc = "Beginning Export Process...."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dce_file_prefix = build(trim( $1))
   IF (dce_file_prefix=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "File Prefix Name invalid"
    SET dm_err->eproc = "File Prefix Validation"
    SET dm_err->user_action = "Please specify a valid file prefix"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_node = build(cnvtupper(trim( $2)))
   IF (dce_node=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Node Name/Linked Server invalid"
    SET dm_err->eproc = "Node Name/Linked Server Validation"
    SET dm_err->user_action = "Please specify a valid node name or linked server"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_user = build(cnvtupper(trim( $3)))
   IF (dce_user=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "User invalid"
    SET dm_err->eproc = "User Validation"
    SET dm_err->user_action = "Please specify a valid user"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_pswd = build(trim( $4))
   IF (dce_pswd=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "User password invalid"
    SET dm_err->eproc = "User password Validation"
    SET dm_err->user_action = "Please specify a valid user password"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_table = build(cnvtupper(trim( $5)))
   IF (dce_table=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Table name invalid"
    SET dm_err->eproc = "Table name Validation"
    SET dm_err->user_action = "Please specify a valid table name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_output_dest = build(trim( $6))
   IF (dce_output_dest=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Output destination invalid"
    SET dm_err->eproc = "Output destination Validation"
    SET dm_err->user_action = "Please specify a valid output destination"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_type = build(cnvtupper(trim( $7)))
   IF ( NOT (dce_type IN ("ADMIN", "CLIN")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Table type invalid"
    SET dm_err->eproc = "Table type Validation"
    SET dm_err->user_action = "Please specify a valid table type.  Enter either ADMIN or CLIN."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_type_run = build(cnvtupper(trim( $8)))
   IF ( NOT (dce_type_run IN ("LOAD_CMDS", "EXPORT")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Type of run invalid"
    SET dm_err->eproc = "Run Type Validation"
    SET dm_err->user_action = "Please specify a valid run type.  Enter either LOAD_CMDS or EXPORT."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_num_rows = build(cnvtupper(trim( $9)))
   IF (dce_num_rows=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Number of rows to export invalid"
    SET dm_err->eproc = "Number of rows Validation"
    SET dm_err->user_action =
    "Please specify a valid number of rows to export, or ALL to export all rows"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF ( NOT (dce_num_rows="ALL")
    AND currdb="SQLSRV")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Number of rows to export invalid for SQL Server"
    SET dm_err->eproc = "Number of rows Validation"
    SET dm_err->user_action = 'Can only specify "ALL" for SQL Server'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_adm_link = build(cnvtupper(trim( $10)))
   IF (dce_adm_link=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Admin Server.Admin Schema Owner invalid"
    SET dm_err->eproc = "Admin Server.Admin Schema Owner Validation"
    SET dm_err->user_action = "Please specify a valid Admin Server.Admin Schema Owner"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_wrapper = build(cnvtupper(trim( $11)))
   IF (currdb="DB2UDB"
    AND  NOT (dce_wrapper IN ("NET8", "SQLNET")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DB2 wrapper invalid"
    SET dm_err->eproc = "DB2 Wrapper Validation"
    SET dm_err->user_action = "Please specify a valid DB2 wrapper.  Enter either NET8 or SQLNET."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dce_full_path = build(dce_output_dest,dce_file_prefix)
   SET dce_msgs_file = build(dce_output_dest,dce_file_prefix,"_exp.err")
   SET dce_ldcmds_fname = build(dce_output_dest,dce_file_prefix,"_load_cmds.dat")
   CALL echo(concat("                     File prefix ($1) = ",dce_file_prefix))
   CALL echo(concat("         Node Name/Linked Server ($2) = ",dce_node))
   CALL echo(concat("                       User Name ($3) = ",dce_user))
   CALL echo(concat("                   User Password ($4) = ",dce_pswd))
   CALL echo(concat("                      Table Name ($5) = ",dce_table))
   CALL echo(concat("              Output Destination ($6) = ",dce_output_dest))
   CALL echo(concat("     Type of Tables (ADMIN/CLIN) ($7) = ",dce_type))
   CALL echo(concat("  Type of Run (LOAD_CMDS/EXPORT) ($8) = ",dce_type_run))
   CALL echo(concat("        Number of Rows To export ($9) = ",dce_num_rows))
   CALL echo(concat("Admin Server/Admin Schema Owner ($10) = ",dce_adm_link))
   CALL echo(concat("                    DB2 Wrapper ($11) = ",dce_wrapper))
   CALL echo(concat("                          Path prefix = ",dce_full_path))
   CALL echo(concat("             Error/Messages file name = ",dce_msgs_file))
   CALL echo(concat("              Load commands file name = ",dce_ldcmds_fname))
   IF (currdb="DB2UDB")
    IF (cnvtupper(currdbuser) IN ("V500", "CDBA"))
     SET dm2_install_schema->dbase_name = cnvtupper(currdblink)
     SET dm2_install_schema->u_name = cnvtupper(currdbuser)
     EXECUTE dm2_connect_to_dbase "PC"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag=1))
      CALL echo(concat("Database: ",dm2_install_schema->dbase_name))
      CALL echo(concat("User    : ",dm2_install_schema->u_name))
      CALL echo(concat("Password: ",dm2_install_schema->p_word))
     ENDIF
     SET dce_str = concat("db2 connect to ",cnvtlower(currdblink)," user ",cnvtlower(currdbuser),
      " using ",
      dm2_install_schema->p_word)
     IF (dm2_push_dcl(dce_str)=0)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Invalid user.")
     SET dm_err->eproc = "User Validation"
     SET dm_err->user_action = concat("Please connect to database as user CDBA or V500. ")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF (currdb="SQLSRV")
    IF (dm2_get_srvname(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_src_tables_object(null)
  IF (currdb="DB2UDB")
   IF (dce_node != "LOCAL")
    SET dm2_server_link->wrapper = dce_wrapper
    SET dm2_server_link->server_name = "ORA_EXP"
    SET dm2_server_link->drop_server_ind = 1
    SET dm2_server_link->server_rdbms = "ORACLE"
    SET dm2_server_link->server_type = "ORACLE"
    SET dm2_server_link->server_version = "8.1"
    SET dm2_server_link->user = dce_user
    SET dm2_server_link->password = dce_pswd
    SET dm2_server_link->node = dce_node
    SET dm2_server_link->dbase = "NONE"
    SET dm2_server_link->hostname = "NONE"
    IF (dm2_create_server_link(null)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Creating DM2_SRC_TABLES nickname")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm2_nickname_info->server = "ORA_EXP"
    SET dm2_nickname_info->remote_owner = dce_user
    IF (create_object("DM2_SRC_TABLES","NICKNAME","DM2_USER_TABLES")=0)
     RETURN(0)
    ENDIF
    IF (dce_type="CLIN")
     SET dm_err->eproc = concat("Creating DM2_TABLES_DOC_EXP nickname")
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dm2_nickname_info->server = substring(1,(findstring(".",dce_adm_link) - 1),dce_adm_link)
     SET dm2_nickname_info->remote_owner = substring((findstring(".",dce_adm_link)+ 1),(textlen(trim(
        dce_adm_link)) - findstring(".",dce_adm_link)),dce_adm_link)
     IF (create_object("DM2_TABLES_DOC_EXP","NICKNAME","DM_TABLES_DOC")=0)
      RETURN(0)
     ENDIF
     SET dm2_nickname_info->server = "ORA_EXP"
     SET dm2_nickname_info->remote_owner = dce_user
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Creating DM2_SRC_TABLES view")
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (create_object("DM2_SRC_TABLES","VIEW","DM2_USER_TABLES")=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSE
   SET dm_err->eproc = concat("Creating DM2_TABLES_DOC_EXP view")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (create_object("DM2_TABLES_DOC_EXP","VIEW","DM_TABLES_DOC")=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Creating DM2_SRC_TABLES view")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (create_object("DM2_SRC_TABLES","VIEW","DM2_USER_TABLES")=0)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE create_object(cdo_name,cdo_type,cdo_table)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   IF (currdb="DB2UDB")
    SET dm_err->eproc = concat("Determine whether ",build(currdbuser,".",cnvtupper(cdo_name)),
     " nickname exists.")
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_dba_synonyms ds
     WHERE ds.synonym_name=cnvtupper(cdo_name)
      AND ds.owner=currdbuser
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=1)
     SET dm_err->eproc = concat("Dropping ",build(currdbuser,".",cdo_name)," nickname")
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dce_str = concat('rdb asis("drop nickname ',build(currdbuser,".",cnvtupper(cdo_name)),
      '") go')
     IF (dm2_push_cmd(dce_str,1)=0)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Determine whether ",build(currdbuser,".",cnvtupper(cdo_name)),
    " view exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_dba_views ds
    WHERE ds.view_name=cnvtupper(cdo_name)
     AND ds.owner=currdbuser
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=1)
    SET dm_err->eproc = concat("Dropping ",build(currdbuser,".",cdo_name)," view")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dce_str = concat('rdb asis("drop view ',build(currdbuser,".",cnvtupper(cdo_name)),'") go')
    IF (dm2_push_cmd(dce_str,1)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Creating ",build(currdbuser,".",cnvtupper(cdo_name))," ",cdo_type)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dce_node="LOCAL")
    SET dce_str = concat('rdb asis ("create ',cdo_type," ",build(currdbuser,".",cnvtupper(cdo_name)),
     " as select * from ",
     dce_user,".",cnvtupper(cdo_table),'") go')
    IF (dm2_push_cmd(dce_str,1)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
     EXECUTE oragen3 build(currdbuser,".",cnvtupper(cdo_name))
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm2_nickname_info->nickname = cnvtupper(cdo_name)
    SET dm2_nickname_info->drop_ind = 0
    SET dm2_nickname_info->create_ind = 1
    SET dm2_nickname_info->local_owner = currdbuser
    SET dm2_nickname_info->remote_table = cnvtupper(cdo_table)
    SET dm2_nickname_info->link_server = dce_node
    SET dm2_nickname_info->col_list1 = "NONE"
    SET dm2_nickname_info->col_list2 = "NONE"
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     EXECUTE oragen3 build(currdbuser,".",cnvtupper(cdo_name))
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE build_schema_exceptions(null)
   IF (dce_node="LOCAL")
    IF (dm2_fill_sch_except("LOCAL")=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (currdb="SQLSRV"
     AND dcs_inhouse_oracle_capture=1)
     SET modify openquery dcs_lnksrv
     IF (dm2_fill_sch_except("LOCAL")=0)
      RETURN(0)
     ENDIF
     SET modify = noopenquery
    ELSE
     IF (dm2_fill_sch_except("REMOTE")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_sch_except)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_export_list(null)
   DECLARE dce_tname = vc WITH protect, noconstant(" ")
   DECLARE dce_sname = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Selecting tables to export"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   IF (currdb="SQLSRV"
    AND dcs_inhouse_oracle_capture=1)
    SET modify openquery dcs_lnksrv
   ENDIF
   SELECT
    IF (currdb="SQLSRV"
     AND dcs_inhouse_oracle_capture=1)
     FROM dm_tables_doc dtd,
      dm2_user_tables st
     WHERE st.table_name=patstring(dce_table)
      AND outerjoin(st.table_name)=dtd.table_name
    ELSEIF (dce_type="ADMIN")
     FROM dm2_src_tables st
     WHERE st.table_name=patstring(dce_table)
    ELSEIF (dce_node="LOCAL")
     FROM dm_tables_doc dtd,
      dm2_src_tables st
     WHERE st.table_name=patstring(dce_table)
      AND outerjoin(st.table_name)=dtd.table_name
    ELSE
     FROM dm2_tables_doc_exp dtd,
      dm2_src_tables st
     WHERE st.table_name=patstring(dce_table)
      AND outerjoin(st.table_name)=dtd.table_name
    ENDIF
    INTO "nl:"
    ORDER BY st.table_name
    DETAIL
     dce_tname = cnvtlower(st.table_name), dce_sname = cnvtlower(validate(dtd.suffixed_table_name," "
       )), dce_found = 0
     FOR (dce_cnt = 1 TO dm2_sch_except->tcnt)
       IF (cnvtupper(dm2_sch_except->tbl[dce_cnt].tbl_name)=cnvtupper(st.table_name))
        dce_found = 1
       ENDIF
     ENDFOR
     IF (dce_found=0)
      tlist->tcount = (tlist->tcount+ 1), dce_stat = alterlist(tlist->qual,tlist->tcount), tlist->
      qual[tlist->tcount].table_name = dce_tname
      IF (((dce_type="ADMIN") OR (dce_sname=" ")) )
       tlist->qual[tlist->tcount].suffixed_table_name = dce_tname, tlist->qual[tlist->tcount].
       tables_doc_ind = 0
      ELSE
       tlist->qual[tlist->tcount].suffixed_table_name = dce_sname, tlist->qual[tlist->tcount].
       tables_doc_ind = 1
      ENDIF
      tlist->qual[tlist->tcount].drop_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (currdb="SQLSRV"
    AND dcs_inhouse_oracle_capture=1)
    SET modify = noopenquery
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (dce_node != "LOCAL")
    SET dm_err->eproc = "Determining nicknames/views that need to be dropped"
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (currdb="SQLSRV")
     SELECT INTO "nl:"
      FROM dm2_dba_views dv
      WHERE cnvtupper(dv.owner)="DBO"
      DETAIL
       dce_sname = cnvtlower(dv.view_name), dce_cnt = 0, dce_cnt = locateval(dce_cnt,1,tlist->tcount,
        dce_sname,tlist->qual[dce_cnt].table_name)
       IF (dce_cnt > 0)
        tlist->qual[dce_cnt].drop_ind = 1
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM dm2_dba_synonyms ds
      WHERE cnvtupper(ds.owner)="DBO"
      DETAIL
       dce_sname = cnvtlower(ds.synonym_name), dce_cnt = 0, dce_cnt = locateval(dce_cnt,1,tlist->
        tcount,dce_sname,tlist->qual[dce_cnt].table_name)
       IF (dce_cnt > 0)
        tlist->qual[dce_cnt].drop_ind = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE process_load_cmds(plc_process)
  IF (plc_process="CREATE")
   SET dm_err->eproc = "Establishing load command file"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dce_ldcmds_fname)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     " ", row + 1
    WITH nocounter, maxcol = 255, maxrow = 1,
     format = noheading
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
  ELSE
   SELECT INTO value(dce_ldcmds_fname)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     IF (currdb="SQLSRV")
      dce_str = concat('bcp "%DBASE%.%UNAME%.',cnvtupper(tlist->qual[dce_cnt].suffixed_table_name
        ),'" in "%FLOC%',dce_file_prefix,tlist->qual[dce_cnt].suffixed_table_name,
       '.exp" -e"%FLOC2%',dce_file_prefix,tlist->qual[dce_cnt].suffixed_table_name,
       '_exp.err" -c -k -t"\t^" -b100 -S"%SNAME%" -U"%UNAME%" -P"%PWD%"'), dce_str, row + 1
     ELSE
      IF ((tlist->qual[dce_cnt].tables_doc_ind=1))
       dce_str = concat("load from $cer_install/",dce_file_prefix,tlist->qual[dce_cnt].
        suffixed_table_name,".ixf"), dce_str, " of ixf modified by identitymissing ",
       "savecount 100 replace into ", tlist->qual[dce_cnt].suffixed_table_name, row + 1
      ELSEIF (dce_type="ADMIN")
       dce_str = concat("import from $cer_install/",dce_file_prefix,tlist->qual[dce_cnt].
        suffixed_table_name,".ixf"), dce_str, " of ixf commitcount 100 replace_create into ",
       tlist->qual[dce_cnt].suffixed_table_name, row + 1
      ENDIF
     ENDIF
    WITH nocounter, maxcol = 255, maxrow = 1,
     format = noheading, append
   ;end select
   IF (check_error("Adding load command to load_cmds file")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE create_empty_files(null)
  IF (currdb="DB2UDB")
   SET dce_str = concat("touch ",dce_full_path,"empty.ixf")
   IF (dm2_push_dcl(dce_str)=0)
    RETURN(0)
   ENDIF
   SET dce_str = concat("chmod 777 ",dce_full_path,"empty.ixf")
   IF (dm2_push_dcl(dce_str)=0)
    RETURN(0)
   ENDIF
   SET dce_str = concat("touch ",dce_output_dest,"dm2_empty.ixf")
   IF (dm2_push_dcl(dce_str)=0)
    RETURN(0)
   ENDIF
   SET dce_str = concat("chmod 777 ",dce_output_dest,"dm2_empty.ixf")
   IF (dm2_push_dcl(dce_str)=0)
    RETURN(0)
   ENDIF
   SET dce_str = concat("touch ",dce_output_dest,"empty.ixf")
   IF (dm2_push_dcl(dce_str)=0)
    RETURN(0)
   ENDIF
   SET dce_str = concat("chmod 777 ",dce_output_dest,"empty.ixf")
   IF (dm2_push_dcl(dce_str)=0)
    RETURN(0)
   ENDIF
   SET dce_str = concat("chmod 777 ",dce_ldcmds_fname)
   IF (dm2_push_dcl(dce_str)=0)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_program
 IF ((dm_err->err_ind=0))
  IF (currdb="DB2UDB")
   SET dce_str = "db2 connect reset"
   IF (dm2_push_dcl(dce_str)=0)
    RETURN(0)
   ENDIF
  ENDIF
 ENDIF
 SET dm_err->eproc = "Export Process Completed"
 CALL final_disp_msg(dce_logfile_prefix)
END GO
