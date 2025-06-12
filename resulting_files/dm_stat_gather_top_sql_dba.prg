CREATE PROGRAM dm_stat_gather_top_sql:dba
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
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
 IF ((validate(ml_max_piece_cnt,- (1))=- (1))
  AND (validate(ml_max_piece_cnt,- (2))=- (2)))
  DECLARE ml_max_piece_cnt = i4 WITH protect, constant(484)
 ENDIF
 IF ((validate(mn_dat_output,- (1))=- (1))
  AND (validate(mn_dat_output,- (2))=- (2)))
  DECLARE mn_dat_output = i2 WITH protect, constant(1)
  DECLARE mn_csv_output = i2 WITH protect, constant(2)
  DECLARE mn_rec_output = i2 WITH protect, constant(3)
  DECLARE mn_rec_csv_output = i2 WITH protect, constant(4)
 ENDIF
 IF (validate(m_files_delta,"X")="X"
  AND validate(m_files_delta,"Y")="Y")
  FREE RECORD m_files_delta
  RECORD m_files_delta(
    1 n_corrupt = i2
    1 d_date1 = dq8
    1 s_oracle_version1 = vc
    1 d_date2 = dq8
    1 s_oracle_version2 = vc
    1 f_total_shareable_mem = f8
    1 f_delta_total_executions = f8
    1 f_delta_total_buffer_gets = f8
    1 f_delta_total_disk_reads = f8
    1 f_delta_total_rows_processed = f8
    1 f_delta_total_cpu_time = f8
    1 l_sql_cnt = i4
    1 sqls[*]
      2 d_first_load_time = dq8
      2 f_hash_value = f8
      2 l_piece_cnt = i4
      2 sql_pieces[*]
        3 s_sql_piece = vc
      2 f_user_id = f8
      2 f_delta_executions = f8
      2 f_delta_buffer_gets = f8
      2 f_delta_disk_reads = f8
      2 f_delta_rows_processed = f8
      2 f_delta_cpu_time = f8
      2 f_exe_per_min = f8
      2 f_max_sharable_mem = f8
      2 n_print_ind = i2
      2 s_optimizer_mode = vc
      2 s_object_name = vc
      2 s_outline_category = vc
  ) WITH protect
 ENDIF
 IF (validate(m_files_delta_ndx,"X")="X"
  AND validate(m_files_delta_ndx,"Y")="Y")
  FREE RECORD m_files_delta_ndx
  RECORD m_files_delta_ndx(
    1 l_sql_cnt = i4
    1 sqls[*]
      2 n_orig_ndx = i4
      2 f_user_id = f8
      2 f_score = f8
      2 f_shareable_mem = f8
  ) WITH protect
 ENDIF
 DECLARE sbr_gather_database_sql(ps_output_file_name=vc,pn_gather_mode=i2) = i2
 DECLARE sbr_add_sql_statement(pf_user_id=f8,pf_executions=f8,pf_buffer_gets=f8,pf_disk_reads=f8,
  pf_rows_processed=f8,
  pd_first_load_time=q8,pf_hash_value=f8,ps_optimizer_mode=vc,mf_sharable_mem=f8,mf_cpu_time=f8,
  ms_outline_category=vc) = i2
 DECLARE sbr_add_sql_text(ps_line=vc) = i2
 DECLARE sbr_populate_object_name(null) = i2
 DECLARE sbr_check_exclude_list(ps_sql=vc) = i2
 SUBROUTINE sbr_gather_database_sql(ps_output_file_name,pn_gather_mode)
   DECLARE mf_cmd_type_insert = f8 WITH protect, constant(2.0)
   DECLARE mf_cmd_type_select = f8 WITH protect, constant(3.0)
   DECLARE mf_cmd_type_update = f8 WITH protect, constant(6.0)
   DECLARE mf_cmd_type_delete = f8 WITH protect, constant(7.0)
   DECLARE mf_total_executions = f8 WITH protect, noconstant(0.0)
   DECLARE mf_total_buffer_gets = f8 WITH protect, noconstant(0.0)
   DECLARE mf_total_disk_reads = f8 WITH protect, noconstant(0.0)
   DECLARE mf_total_scores = f8 WITH protect, noconstant(0.0)
   DECLARE mf_total_rows_processed = f8 WITH protect, noconstant(0.0)
   DECLARE mf_total_sharable_mem = f8 WITH protect, noconstant(0.0)
   DECLARE mf_total_cpu_time = f8 WITH protect, noconstant(0.0)
   DECLARE ms_first_load_time_string = vc WITH protect, noconstant(" ")
   DECLARE ms_sql_text = vc WITH protect, noconstant(" ")
   DECLARE ms_oracle_version = vc WITH protect, noconstant(" ")
   DECLARE mn_exclude_obj_ind = i2 WITH protect, noconstant(0)
   DECLARE mn_skip_exclusion_ind = i2 WITH protect, noconstant(- (1))
   IF (validate(mn_rec_snapshot_ind,- (1))=1)
    IF (size(m_exclude_list->scripts,5)=0)
     SET dm_err->eproc = "No exclusion entries found. Skipping exclusion process..."
     CALL disp_msg(" ",dm_err->logfile,0)
     SET mn_skip_exclusion_ind = 1
    ELSE
     SET mn_skip_exclusion_ind = 0
    ENDIF
   ELSE
    DECLARE mn_rec_snapshot_ind = i2 WITH protect, noconstant(0)
   ENDIF
   IF (((pn_gather_mode < 1) OR (pn_gather_mode > 4)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Invalid gather mode."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF (currdb != "ORACLE")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Gather process does not run on ",currdb,".")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Gathering Oracle Information"
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dm2_get_rdbms_version(null)
   SET ms_oracle_version = format(trim(dm2_rdbms_version->version),"####################;R")
   SET dm_err->eproc = "Finished gathering Oracle information"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((validate(mf_v500_user_id,- (1.0))=- (1.0))
    AND (validate(mf_v500_user_id,- (2.0))=- (2.0)))
    DECLARE mf_v500_user_id = f8 WITH protect, noconstant(0.0)
    IF (validate(dsg_calling_script,"X")="X"
     AND validate(dsg_calling_script,"Y")="Y")
     DECLARE dsg_calling_script = vc WITH public, noconstant("NONE")
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="V500 USER ID"
      AND di.info_number=1
     WITH counter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((curqual > 0) OR (dsg_calling_script="DM_CBO_IMPLEMENTER")) )
     SELECT INTO "nl:"
      du.user_id
      FROM dba_users du
      WHERE du.username="V500"
      DETAIL
       mf_v500_user_id = du.user_id
      WITH counter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (pn_gather_mode IN (mn_csv_output, mn_rec_output, mn_rec_csv_output))
    SET dm_err->eproc = "Reading GV$SQL and GV$SQLTEXT tables..."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (mn_rec_snapshot_ind=1)
     IF (mn_allusers_ind=1)
      SET mf_v500_user_id = 0
     ENDIF
    ENDIF
    SELECT
     IF (mf_v500_user_id > 0)
      PLAN (vs
       WHERE vs.command_type IN (mf_cmd_type_insert, mf_cmd_type_select, mf_cmd_type_update,
       mf_cmd_type_delete)
        AND trim(vs.optimizer_mode) != "NONE"
        AND vs.child_number=0
        AND vs.parsing_user_id=mf_v500_user_id)
       JOIN (vt
       WHERE vt.hash_value=vs.hash_value
        AND vt.address=vs.address
        AND vt.piece < ml_max_piece_cnt)
     ELSE
     ENDIF
     INTO value(ps_output_file_name)
     FROM gv$sql vs,
      gv$sqltext vt
     PLAN (vs
      WHERE vs.command_type IN (mf_cmd_type_insert, mf_cmd_type_select, mf_cmd_type_update,
      mf_cmd_type_delete)
       AND trim(vs.optimizer_mode) != "NONE"
       AND vs.child_number=0)
      JOIN (vt
      WHERE vt.hash_value=vs.hash_value
       AND vt.address=vs.address
       AND vt.piece < ml_max_piece_cnt)
     ORDER BY vs.hash_value, vs.first_load_time, vt.piece
     HEAD REPORT
      pd_current_dt_tm = cnvtdatetime(sysdate)
      IF (validate(vs.cpu_time,- (1)) < 0)
       mf_total_cpu_time = - (1)
      ENDIF
      IF (pn_gather_mode IN (mn_rec_output, mn_rec_csv_output))
       m_files_delta->d_date2 = pd_current_dt_tm, m_files_delta->s_oracle_version2 =
       ms_oracle_version
      ENDIF
      IF (pn_gather_mode IN (mn_csv_output, mn_rec_csv_output))
       ps_current_dt_tm = format(pd_current_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"), s_header_text = concat(
        "DATE,ORACLE_VERSION,TYPE,EXECUTIONS,BUFFER_GETS,DISK_READS,ROWS_PROCESSED,",
        "SCORE,CPU_TIME,SHARABLE_MEM,OUTLINE_CATEGORY,FIRST_LOAD_TIME,HASH_VALUE,OPTIMIZER_MODE,SQL_TEXT"
        ), row 0,
       col 0, s_header_text, row + 1
      ENDIF
     HEAD vs.hash_value
      row + 0
     HEAD vs.first_load_time
      row + 0
     DETAIL
      IF (vt.piece=0)
       ms_sql_text = trim(replace(replace(replace(replace(vt.sql_text,char(0)," ",0),'"'," ",0),char(
           10)," ",0),char(13)," ",0),2)
      ELSE
       ms_sql_text = concat(ms_sql_text,replace(replace(replace(replace(vt.sql_text,char(0)," ",0),
           '"'," ",0),char(10)," ",0),char(13)," ",0))
      ENDIF
     FOOT  vs.first_load_time
      IF (pn_gather_mode IN (mn_rec_output, mn_rec_csv_output))
       IF (mn_skip_exclusion_ind=0)
        mn_exclude_obj_ind = sbr_check_exclude_list(ms_sql_text)
       ENDIF
       IF (mn_exclude_obj_ind != 1)
        stat = sbr_add_sql_statement(vs.parsing_user_id,vs.executions,vs.buffer_gets,vs.disk_reads,vs
         .rows_processed,
         cnvtdatetime(concat(format(cnvtdate2(substring(1,10,vs.first_load_time),"YYYY-MM-DD"),
            "DD-MMM-YYYY;;d")," ",substring(12,8,vs.first_load_time))),vs.hash_value,vs
         .optimizer_mode,vs.sharable_mem,validate(vs.cpu_time,- (1)),
         vs.outline_category), stat = sbr_add_sql_text(ms_sql_text)
       ENDIF
      ENDIF
      IF (pn_gather_mode IN (mn_csv_output, mn_rec_csv_output))
       mf_total_executions = (mf_total_executions+ vs.executions), mf_total_buffer_gets = (
       mf_total_buffer_gets+ vs.buffer_gets), mf_total_disk_reads = (mf_total_disk_reads+ vs
       .disk_reads),
       mf_total_scores = ((mf_total_scores+ vs.buffer_gets)+ (200 * (vs.disk_reads+ vs.executions))),
       mf_total_rows_processed = (mf_total_rows_processed+ vs.rows_processed), mf_total_sharable_mem
        = (mf_total_sharable_mem+ vs.sharable_mem),
       mf_total_cpu_time = (mf_total_cpu_time+ validate(vs.cpu_time,0)), ms_first_load_time_string =
       format(cnvtdatetimeutc(cnvtdatetime(concat(format(cnvtdate2(substring(1,10,vs.first_load_time),
             "YYYY-MM-DD"),"DD-MMM-YYYY;;d")," ",substring(12,8,vs.first_load_time)))),
        "dd-mmm-yyyy hh:mm:ss;;d"), ms_outline_category_string = trim(vs.outline_category,3)
       IF (ms_outline_category_string IN ("", " ", null))
        ms_outline_category_string = "<NONE>"
       ENDIF
       row + 1,
       CALL print(build(ps_current_dt_tm,",",trim(ms_oracle_version,3),",","DETAIL,",
        trim(cnvtstring(vs.executions)),",",trim(cnvtstring(vs.buffer_gets)),",",trim(cnvtstring(vs
          .disk_reads)),
        ",",trim(cnvtstring(vs.rows_processed)),",",trim(cnvtstring((vs.buffer_gets+ (200 * (vs
          .disk_reads+ vs.executions))))),",",
        evaluate(mf_total_cpu_time,- (1.0),"N/A",trim(cnvtstring(validate(vs.cpu_time,0)))),",",trim(
         cnvtstring(vs.sharable_mem)),",",ms_outline_category_string,
        ",",ms_first_load_time_string,",",trim(cnvtstring(vs.hash_value)),",",
        trim(vs.optimizer_mode),',"',trim(ms_sql_text,3),'"'))
      ENDIF
     FOOT  vs.hash_value
      row + 0
     FOOT REPORT
      IF (pn_gather_mode IN (mn_rec_output, mn_rec_csv_output))
       row + 1, stat = sbr_populate_object_name(null), stat = alterlist(m_files_delta->sqls,
        m_files_delta->l_sql_cnt)
      ENDIF
      IF (pn_gather_mode IN (mn_csv_output, mn_rec_csv_output))
       row + 1, col 0,
       CALL print(build(ps_current_dt_tm,",",trim(ms_oracle_version,3),",","TOTAL,",
        trim(cnvtstring(mf_total_executions)),",",trim(cnvtstring(mf_total_buffer_gets)),",",trim(
         cnvtstring(mf_total_disk_reads)),
        ",",trim(cnvtstring(mf_total_rows_processed)),",",trim(cnvtstring(mf_total_scores)),",",
        evaluate(mf_total_cpu_time,- (1.0),"N/A",trim(cnvtstring(mf_total_cpu_time))),",",trim(
         cnvtstring(mf_total_sharable_mem)),",","N/A,N/A,N/A,N/A,N/A"))
      ENDIF
     WITH counter, nullreport, format = variable,
      maxrow = 1, maxcol = 32000
    ;end select
   ELSE
    FREE RECORD m_totals
    RECORD m_totals(
      1 f_score_total = f8
      1 f_execute_total = f8
      1 f_gets_total = f8
      1 f_disk_total = f8
    ) WITH protect
    SELECT
     IF (mf_v500_user_id > 0)
      WHERE s.parsing_user_id=mf_v500_user_id
     ELSE
     ENDIF
     INTO "nl:"
     pf_score_sum = sum(((s.buffer_gets+ (s.executions * 200))+ (s.disk_reads * 200))),
     pf_execute_sum = sum(s.executions), pf_gets_sum = sum(s.buffer_gets),
     pf_disk_sum = sum(s.disk_reads)
     FROM gv$sqlarea s
     FOOT REPORT
      m_totals->f_score_total = pf_score_sum, m_totals->f_execute_total = pf_execute_sum, m_totals->
      f_gets_total = pf_gets_sum,
      m_totals->f_disk_total = pf_disk_sum
     WITH counter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Finished gathering totals information"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->eproc = "Generating gather report in DAT format"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT
     IF (mf_v500_user_id > 0)
      PLAN (vs
       WHERE vs.parsing_user_id=mf_v500_user_id
        AND vs.command_type IN (mf_cmd_type_insert, mf_cmd_type_select, mf_cmd_type_update,
       mf_cmd_type_delete)
        AND trim(vs.optimizer_mode) != "NONE")
       JOIN (vt
       WHERE vt.hash_value=vs.hash_value
        AND vt.address=vs.address)
     ELSE
     ENDIF
     INTO value(ms_output_file_name)
     FROM gv$sqltext vt,
      gv$sqlarea vs
     PLAN (vs
      WHERE vs.command_type IN (mf_cmd_type_insert, mf_cmd_type_select, mf_cmd_type_update,
      mf_cmd_type_delete)
       AND trim(vs.optimizer_mode) != "NONE")
      JOIN (vt
      WHERE vt.hash_value=vs.hash_value
       AND vt.address=vs.address)
     ORDER BY vs.hash_value, vs.first_load_time, vt.piece
     HEAD REPORT
      ps_current_dt_tm = format(cnvtdatetime(sysdate),"dd-mmm-yyyy hh:mm:ss;;d"),
      pc_execute_total_string = format(m_totals->f_execute_total,"#############"),
      pc_gets_total_string = format(m_totals->f_gets_total,"#############"),
      pc_disk_total_string = format(m_totals->f_disk_total,"#############"), pc_score_total_string =
      format(m_totals->f_score_total,"#############"), col 0,
      "DATE:", col 16, ps_current_dt_tm,
      row + 1, col 0, "ORACLE VERSION:",
      col 16, ms_oracle_version, row + 1,
      col 0, "EXECUTE TOTAL:", col 23,
      pc_execute_total_string, row + 1, col 0,
      "BUFFER TOTAL:", col 23, pc_gets_total_string,
      row + 1, col 0, "DISK TOTAL:",
      col 23, pc_disk_total_string, row + 1,
      col 0, "SCORE TOTAL:", col 23,
      pc_score_total_string, row + 1, col 9,
      "EXECUTE", col 19, "BUFFER GETS",
      col 33, "DISK READS", col 51,
      "FIRST LOAD TIME", col 69, "HASH VALUE",
      col 92, "OPTIMIZER MODE", col 108,
      "ROWS PROCESSED", col 124, "SHARABLE MEM",
      col 143, "CPU TIME"
     HEAD vs.hash_value
      row + 0
     HEAD vs.first_load_time
      row + 1, pd_flt_date = cnvtdate2(substring(1,10,vs.first_load_time),"YYYY-MM-DD"), pd_flt_dt_tm
       = cnvtdatetimeutc(cnvtdatetime(concat(format(pd_flt_date,"DD-MMM-YYYY;;d")," ",substring(12,8,
          vs.first_load_time)))),
      pc_exec_string = format(vs.executions,"###########"), pc_buff_string = format(vs.buffer_gets,
       "###########"), pc_disk_string = format(vs.disk_reads,"###########"),
      pc_flt_string = format(pd_flt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"), pc_hash_string = format(vs
       .hash_value,"###########"), pc_opt_mode = format(vs.optimizer_mode,
       "#########################;R"),
      pc_rows_processed_string = format(vs.rows_processed,"###############"), pc_mem_string = format(
       vs.sharable_mem,"#############"), pc_cpu_string = fillstring(13," ")
      IF (validate(vs.cpu_time,0)=0
       AND validate(vs.cpu_time,1)=1)
       pc_cpu_string = "          N/A"
      ELSE
       pc_cpu_string = format(validate(vs.cpu_time,0),"#############")
      ENDIF
      col 0, "SQL:", col + 1,
      pc_exec_string, col + 3, pc_buff_string,
      col + 2, pc_disk_string, col + 3,
      pc_flt_string, col + 2, pc_hash_string,
      col + 2, pc_opt_mode, col + 1,
      pc_rows_processed_string, col + 1, pc_mem_string,
      col + 2, pc_cpu_string
     DETAIL
      IF (trim(vt.sql_text,1) != "")
       row + 1, col 0,
       CALL print(replace(vt.sql_text,char(0)," ",0))
      ENDIF
     FOOT  vs.first_load_time
      row + 1
     FOOT  vs.hash_value
      row + 0
     FOOT REPORT
      row + 0
     WITH counter, maxrow = 1, format = variable,
      maxcol = 160
    ;end select
   ENDIF
   FREE RECORD m_totals
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Finished reading GV$SQL and GV$SQLTEXT tables."
   CALL disp_msg(" ",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 DECLARE ml_init_hashset_size = i4 WITH protect, constant(5009)
 DECLARE mc_starline = c80 WITH protect, constant(fillstring(80,"*"))
 DECLARE ms_obj_start = vc WITH protect, constant("CCL<")
 DECLARE ms_obj_end = vc WITH protect, constant(":")
 DECLARE ms_obj_ind_str = vc WITH protect, constant("/*+")
 DECLARE ms_server_query = vc WITH protect, constant("<SERVER QUERY>")
 DECLARE ms_interactive_query = vc WITH protect, constant("<INTERACTIVE QUERY>")
 DECLARE ms_cclstartup = vc WITH protect, constant("CCLSTARTUP")
 FREE RECORD m_hash_record
 RECORD m_hash_record(
   1 hash_cells[ml_init_hashset_size]
     2 l_list_cnt = i4
     2 lists[*]
       3 f_hash_value = f8
       3 d_first_load_time = dq8
       3 l_sql_index = i4
 ) WITH protect
 FREE RECORD m_exclude_list
 RECORD m_exclude_list(
   1 scripts[*]
     2 s_script_name = vc
 ) WITH protect
 DECLARE sbr_add_to_hashset(pf_hash_value=f8,pd_first_load_time=f8,pl_sql_index=i4) = i2
 DECLARE sbr_get_from_hashset(pf_hash_value=f8,pd_first_load_time=f8) = i4
 SUBROUTINE sbr_check_exclude_list(ps_sql)
   DECLARE pn_begin_pos = i2 WITH private, noconstant(0)
   DECLARE pn_end_pos = i2 WITH private, noconstant(0)
   DECLARE pn_got_exclude_obj_ind = i2 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_exclusion_size = i4 WITH protect, noconstant(0)
   SET pn_begin_pos = findstring(ms_obj_ind_str,ps_sql,1,0)
   IF (pn_begin_pos > 0)
    SET pn_begin_pos = findstring(ms_obj_start,ps_sql,1,0)
    IF (pn_begin_pos > 0)
     SET pn_end_pos = findstring(ms_obj_end,ps_sql,(pn_begin_pos+ textlen(ms_obj_start)),0)
     IF (pn_end_pos > 0)
      IF (trim(ps_sql) > " "
       AND trim(ps_sql) != "CCL")
       SET ps_sql = substring((pn_begin_pos+ textlen(ms_obj_start)),((pn_end_pos - pn_begin_pos) -
        textlen(ms_obj_start)),ps_sql)
       SET ml_exclusion_size = size(m_exclude_list->scripts,5)
       FOR (ml_idx = 1 TO ml_exclusion_size)
         IF ((trim(ps_sql,3)=m_exclude_list->scripts[ml_idx].s_script_name))
          SET pn_got_exclude_obj_ind = 1
         ENDIF
       ENDFOR
       IF (check_error(dm_err->eproc)=1)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(pn_got_exclude_obj_ind)
 END ;Subroutine
 SUBROUTINE sbr_add_sql_statement(pf_user_id,pf_executions,pf_buffer_gets,pf_disk_reads,
  pf_rows_processed,pd_first_load_time,pf_hash_value,ps_optimizer_mode,pf_sharable_mem,pf_cpu_time,
  ps_outline_category)
   DECLARE pl_cur_sql_cnt = i4 WITH private, constant((m_files_delta->l_sql_cnt+ 1))
   IF (pl_cur_sql_cnt > size(m_files_delta->sqls,5))
    SET stat = alterlist(m_files_delta->sqls,(m_files_delta->l_sql_cnt+ 200))
   ENDIF
   SET m_files_delta->l_sql_cnt = pl_cur_sql_cnt
   SET m_files_delta->sqls[pl_cur_sql_cnt].f_user_id = pf_user_id
   SET m_files_delta->sqls[pl_cur_sql_cnt].d_first_load_time = pd_first_load_time
   SET m_files_delta->sqls[pl_cur_sql_cnt].f_hash_value = pf_hash_value
   SET m_files_delta->sqls[pl_cur_sql_cnt].f_delta_executions = pf_executions
   SET m_files_delta->sqls[pl_cur_sql_cnt].f_delta_buffer_gets = pf_buffer_gets
   SET m_files_delta->sqls[pl_cur_sql_cnt].f_delta_disk_reads = pf_disk_reads
   SET m_files_delta->sqls[pl_cur_sql_cnt].f_delta_rows_processed = pf_rows_processed
   SET m_files_delta->sqls[pl_cur_sql_cnt].s_optimizer_mode = ps_optimizer_mode
   SET m_files_delta->sqls[pl_cur_sql_cnt].f_max_sharable_mem = pf_sharable_mem
   SET m_files_delta->sqls[pl_cur_sql_cnt].f_delta_cpu_time = pf_cpu_time
   SET m_files_delta->sqls[pl_cur_sql_cnt].s_outline_category = ps_outline_category
   IF (((pf_executions < 0) OR (((pf_buffer_gets < 0) OR (pf_disk_reads < 0)) )) )
    SET m_files_delta->sqls[pl_cur_sql_cnt].n_print_ind = 0
   ELSE
    SET m_files_delta->sqls[pl_cur_sql_cnt].n_print_ind = 1
    SET m_files_delta->f_total_shareable_mem = (m_files_delta->f_total_shareable_mem+ pf_sharable_mem
    )
    SET m_files_delta->f_delta_total_executions = (m_files_delta->f_delta_total_executions+
    pf_executions)
    SET m_files_delta->f_delta_total_buffer_gets = (m_files_delta->f_delta_total_buffer_gets+
    pf_buffer_gets)
    SET m_files_delta->f_delta_total_disk_reads = (m_files_delta->f_delta_total_disk_reads+
    pf_disk_reads)
    SET m_files_delta->f_delta_total_rows_processed = (m_files_delta->f_delta_total_rows_processed+
    pf_rows_processed)
    SET m_files_delta->f_delta_total_cpu_time = (m_files_delta->f_delta_total_cpu_time+ pf_cpu_time)
   ENDIF
   IF (validate(mn_rec_snapshot_ind,- (1))=1)
    IF (pl_cur_sql_cnt > size(m_files_delta_ndx->sqls,5))
     SET stat = alterlist(m_files_delta_ndx->sqls,(m_files_delta_ndx->l_sql_cnt+ 200))
    ENDIF
    SET m_files_delta_ndx->l_sql_cnt = pl_cur_sql_cnt
    SET m_files_delta_ndx->sqls[pl_cur_sql_cnt].n_orig_ndx = pl_cur_sql_cnt
    SET m_files_delta_ndx->sqls[pl_cur_sql_cnt].f_user_id = pf_user_id
    SET m_files_delta_ndx->sqls[pl_cur_sql_cnt].f_score = (pf_buffer_gets+ (200 * (pf_disk_reads+
    pf_executions)))
    SET m_files_delta_ndx->sqls[pl_cur_sql_cnt].f_shareable_mem = pf_sharable_mem
   ELSE
    IF (sbr_add_to_hashset(pf_hash_value,pd_first_load_time,pl_cur_sql_cnt)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_add_sql_text(ps_line)
   DECLARE pl_cur_sql_cnt = i4 WITH private, constant(m_files_delta->l_sql_cnt)
   DECLARE pl_cur_piece_cnt = i4 WITH private, constant((m_files_delta->sqls[pl_cur_sql_cnt].
    l_piece_cnt+ 1))
   SET stat = alterlist(m_files_delta->sqls[pl_cur_sql_cnt].sql_pieces,pl_cur_piece_cnt)
   SET m_files_delta->sqls[pl_cur_sql_cnt].l_piece_cnt = pl_cur_piece_cnt
   SET m_files_delta->sqls[pl_cur_sql_cnt].sql_pieces[pl_cur_piece_cnt].s_sql_piece = ps_line
   RETURN(stat)
 END ;Subroutine
 SUBROUTINE sbr_populate_object_name(null)
   DECLARE ps_sql = vc WITH private, noconstant(" ")
   DECLARE pn_begin_pos = i2 WITH private, noconstant(0)
   DECLARE pn_end_pos = i2 WITH private, noconstant(0)
   DECLARE pn_got_object_ind = i2 WITH private, noconstant(0)
   FOR (l_cur_sql = 1 TO m_files_delta->l_sql_cnt)
     FOR (l_cur_piece = 1 TO m_files_delta->sqls[l_cur_sql].l_piece_cnt)
       IF (pn_got_object_ind=0)
        SET ps_sql = substring(1,31000,concat(trim(ps_sql),trim(m_files_delta->sqls[l_cur_sql].
           sql_pieces[l_cur_piece].s_sql_piece)))
        SET pn_begin_pos = findstring(ms_obj_ind_str,ps_sql,1,0)
        IF (pn_begin_pos > 0)
         SET pn_begin_pos = findstring(ms_obj_start,ps_sql,1,0)
         IF (pn_begin_pos > 0)
          SET pn_end_pos = findstring(ms_obj_end,ps_sql,(pn_begin_pos+ textlen(ms_obj_start)),0)
          IF (pn_end_pos > 0)
           SET m_files_delta->sqls[l_cur_sql].s_object_name = substring((pn_begin_pos+ textlen(
             ms_obj_start)),((pn_end_pos - pn_begin_pos) - textlen(ms_obj_start)),ps_sql)
           IF (trim(m_files_delta->sqls[l_cur_sql].s_object_name) <= " ")
            SET m_files_delta->sqls[l_cur_sql].s_object_name = ms_server_query
           ELSEIF (trim(m_files_delta->sqls[l_cur_sql].s_object_name)="CCL")
            SET m_files_delta->sqls[l_cur_sql].s_object_name = ms_interactive_query
           ENDIF
           SET pn_got_object_ind = 1
          ENDIF
         ELSEIF ((l_cur_piece=m_files_delta->sqls[l_cur_sql].l_piece_cnt))
          SET m_files_delta->sqls[l_cur_sql].s_object_name = ms_server_query
         ENDIF
        ELSE
         SET m_files_delta->sqls[l_cur_sql].s_object_name = ms_interactive_query
         SET pn_got_object_ind = 1
        ENDIF
       ENDIF
     ENDFOR
     SET ps_sql = " "
     SET pn_begin_pos = 0
     SET pn_end_pos = 0
     SET pn_got_object_ind = 0
   ENDFOR
   RETURN(1)
 END ;Subroutine
 DECLARE ms_logfile_prefix = vc WITH protect, constant("dm_top_sql")
 DECLARE ms_score = vc WITH protect, constant("SCORE")
 DECLARE ms_shareable_mem = vc WITH protect, constant("SHAREABLE MEM")
 DECLARE ml_num_entries = i4 WITH protect, noconstant(10)
 DECLARE mn_rec_snapshot_ind = i2 WITH protect, noconstant(1)
 DECLARE mn_allusers_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_v500_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp_metrics = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_sqltext = vc WITH protect, noconstant(" ")
 DECLARE ml_dsr_cnt = i4 WITH protect, noconstant(0)
 DECLARE md_capture_dt_tm = q8 WITH protect, noconstant(cnvtdatetime(sysdate))
 FREE RECORD m_sql_entries
 RECORD m_sql_entries(
   1 sqls[*]
     2 f_seq_id = f8
     2 f_sql_id = f8
     2 n_orig_ndx = i4
     2 s_sql_text = vc
     2 n_exists_ind = i2
 ) WITH protect
 FREE RECORD m_users
 RECORD m_users(
   1 names[*]
     2 s_user_name = vc
     2 f_user_id = f8
 ) WITH protect
 FREE RECORD m_tmp_sql_entries
 RECORD m_tmp_sql_entries(
   1 sqls[*]
     2 f_sql_id = f8
     2 n_orig_ndx = i4
     2 s_sql_text = vc
     2 n_dup_ind = i2
 ) WITH protect
 FREE RECORD m_tmp_dsr
 RECORD m_tmp_dsr(
   1 qual[*]
     2 stat_snap_dt_tm = dq8
     2 snapshot_type = c100
     2 qual[*]
       3 stat_name = vc
       3 stat_number_val = f8
       3 stat_clob_val = vc
 )
 DECLARE sbr_filter_sql_data(ms_sort_criteria=vc,pn_allusers_ind=i2) = null
 DECLARE sbr_populate_sql_ids(null) = null
 DECLARE sbr_store_sql_text(null) = null
 DECLARE sbr_populate_master_data(null) = null
 IF (check_logfile(ms_logfile_prefix,".log","DM_TOP_SQL")=0)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error creating log file"
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning DM_STAT_GATHER_TOP_SQL"
 CALL disp_msg(" ",dm_err->logfile,0)
 RANGE OF dsss IS dm_stat_snaps_sql
 IF (validate(dsss.sql_text)=0)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error: Table definition for DM_STAT_SNAPS_SQL not found"
  GO TO exit_program
 ENDIF
 FREE RANGE dsss
 SET dm_err->eproc = "Capturing application settings from DM_INFO..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  di.info_domain, di.info_name, di.info_char
  FROM dm_info di
  WHERE ((di.info_domain="DM_STAT_GATHER_TOP_SQL"
   AND di.info_name IN ("REPORT_CRITERIA", "CAPTURE_INTERACTIVE_QUERIES")) OR (di.info_char=
  "EXCLUDE_LIST"))
  HEAD REPORT
   ml_idx = 0
  DETAIL
   IF (di.info_name="REPORT_CRITERIA")
    IF (di.info_number >= ml_num_entries)
     ml_num_entries = di.info_number
    ENDIF
   ELSEIF (di.info_name="CAPTURE_INTERACTIVE_QUERIES")
    mn_allusers_ind = di.info_number
   ELSEIF (di.info_char="EXCLUDE_LIST")
    ml_idx = (ml_idx+ 1)
    IF (ml_idx > size(m_exclude_list->scripts,5))
     stat = alterlist(m_exclude_list->scripts,(ml_idx+ 9))
    ENDIF
    m_exclude_list->scripts[ml_idx].s_script_name = di.info_name
   ENDIF
  FOOT REPORT
   stat = alterlist(m_exclude_list->scripts,ml_idx)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error: gathering DM_INFO data"
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc = "No DM_INFO rows exist. Continuing with defaults..."
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SET dm_err->eproc = "Capturing user data..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dba_users du
  HEAD REPORT
   ml_idx = 0
  DETAIL
   IF (mn_allusers_ind=1)
    ml_idx = (ml_idx+ 1)
    IF (ml_idx > size(m_users->names,5))
     stat = alterlist(m_users->names,(ml_idx+ 9))
    ENDIF
    m_users->names[ml_idx].s_user_name = du.username, m_users->names[ml_idx].f_user_id = du.user_id
   ENDIF
   IF (du.username="V500")
    mf_v500_id = du.user_id
   ENDIF
  FOOT REPORT
   stat = alterlist(m_users->names,ml_idx)
  WITH counter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error: gathering users data"
  GO TO exit_program
 ENDIF
 SET ml_idx = sbr_gather_database_sql("nl:",mn_rec_output)
 IF (ml_idx != 1)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error: Could not access data returned"
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Capturing total system metrics..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET ml_dsr_cnt = 1
 SET stat = alterlist(dsr->qual,ml_dsr_cnt)
 SET dsr->qual[ml_dsr_cnt].snapshot_type = "DB_TOTAL_HOURLY"
 SET dsr->qual[ml_dsr_cnt].stat_snap_dt_tm = cnvtdatetime(md_capture_dt_tm)
 IF (mn_allusers_ind=1)
  SET ms_tmp_metrics = "ALL"
 ELSEIF (mn_allusers_ind=0)
  SET ms_tmp_metrics = "V500"
 ENDIF
 SET stat = alterlist(dsr->qual[ml_dsr_cnt].qual,1)
 SET dsr->qual[ml_dsr_cnt].qual[1].stat_name = "DB_SYSTEM_METRICS"
 SET dsr->qual[ml_dsr_cnt].qual[1].stat_clob_val = build(ms_tmp_metrics,",",m_files_delta->
  f_total_shareable_mem,",",m_files_delta->f_delta_total_buffer_gets,
  ",",m_files_delta->f_delta_total_disk_reads,",",m_files_delta->f_delta_total_executions,",",
  m_files_delta->f_delta_total_rows_processed,",",m_files_delta->f_delta_total_cpu_time)
 EXECUTE dm_stat_snaps_load
 SET ml_dsr_cnt = 0
 SET dm_err->eproc = "Sorting for V500 Score Top N entries..."
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL sbr_filter_sql_data(ms_score,0)
 SET dm_err->eproc = "Populating SQL ids..."
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL sbr_populate_sql_ids(null)
 SET dm_err->eproc = "Filtering duplicate data..."
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL sbr_populate_master_data(null)
 EXECUTE dm_stat_snaps_load
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error: loading STAT_SNAPS* data"
  GO TO exit_program
 ENDIF
 SET ml_dsr_cnt = 0
 SET dm_err->eproc = "Beginning storage of SQLText entries..."
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL sbr_store_sql_text(null)
 COMMIT
 SET dm_err->eproc = "Successfully completed V500 Score data storage"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Beginning V500 Shareable Mem data storage..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET stat = initrec(m_sql_entries)
 CALL sbr_filter_sql_data(ms_shareable_mem,0)
 SET dm_err->eproc = "Populating SQL ids..."
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL sbr_populate_sql_ids(null)
 SET dm_err->eproc = "Filtering duplicate data..."
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL sbr_populate_master_data(null)
 EXECUTE dm_stat_snaps_load
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error: loading STAT_SNAPS* data"
  GO TO exit_program
 ENDIF
 SET ml_dsr_cnt = 0
 SET dm_err->eproc = "Beginning storage of SQLText entries..."
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL sbr_store_sql_text(null)
 COMMIT
 SET dm_err->eproc = "Successfully completed V500 Shareable Mem data storage"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (mn_allusers_ind=1)
  SET stat = initrec(m_sql_entries)
  SET dm_err->eproc = "Sorting for Other Users Score Top N entries..."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL sbr_filter_sql_data(ms_score,1)
  SET dm_err->eproc = "Populating SQL ids..."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL sbr_populate_sql_ids(null)
  SET dm_err->eproc = "Filtering duplicate data..."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL sbr_populate_master_data(null)
  EXECUTE dm_stat_snaps_load
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->err_ind = 1
   SET dm_err->eproc = "Error: loading STAT_SNAPS* data"
   GO TO exit_program
  ENDIF
  SET ml_dsr_cnt = 0
  SET dm_err->eproc = "Beginning storage of SQLText entries..."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL sbr_store_sql_text(null)
  COMMIT
  SET dm_err->eproc = "Successfully completed Other Users Score data storage"
  CALL disp_msg(" ",dm_err->logfile,0)
  SET dm_err->eproc = "Beginning Other Users Shareable Mem data storage..."
  CALL disp_msg(" ",dm_err->logfile,0)
  SET stat = initrec(m_sql_entries)
  CALL sbr_filter_sql_data(ms_shareable_mem,1)
  SET dm_err->eproc = "Populating SQL ids..."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL sbr_populate_sql_ids(null)
  SET dm_err->eproc = "Filtering duplicate data..."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL sbr_populate_master_data(null)
  EXECUTE dm_stat_snaps_load
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->err_ind = 1
   SET dm_err->eproc = "Error: loading STAT_SNAPS* data"
   GO TO exit_program
  ENDIF
  SET ml_dsr_cnt = 0
  SET dm_err->eproc = "Beginning storage of SQLText entries..."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL sbr_store_sql_text(null)
  COMMIT
  SET dm_err->eproc = "Successfully loaded Other Users Shareable Mem data storage"
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SUBROUTINE sbr_filter_sql_data(ms_sort_criteria,pn_allusers_ind)
   DECLARE ms_user_clause = vc WITH protect, noconstant("")
   IF (pn_allusers_ind=1)
    SET ms_user_clause = "M_FILES_DELTA_NDX->SQLS[D1.SEQ].F_USER_ID != MF_V500_ID"
   ELSE
    SET ms_user_clause = "M_FILES_DELTA_NDX->SQLS[D1.SEQ].F_USER_ID = MF_V500_ID"
   ENDIF
   SELECT
    IF (ms_sort_criteria=ms_shareable_mem)
     ORDER BY pl_share_mem DESC
    ELSE
    ENDIF
    INTO "nl:"
    pl_orig_ndx = m_files_delta_ndx->sqls[d1.seq].n_orig_ndx, pl_user_id = m_files_delta_ndx->sqls[d1
    .seq].f_user_id, pl_score = m_files_delta_ndx->sqls[d1.seq].f_score,
    pl_share_mem = m_files_delta_ndx->sqls[d1.seq].f_shareable_mem
    FROM (dummyt d1  WITH seq = value(size(m_files_delta_ndx->sqls,5)))
    PLAN (d1
     WHERE d1.seq > 0
      AND parser(ms_user_clause))
    ORDER BY pl_score DESC
    HEAD REPORT
     ml_idx = 0, ml_idx2 = 0, ml_cnt = 0,
     ml_dsr_cnt = (ml_dsr_cnt+ 1), stat = alterlist(m_tmp_dsr->qual,ml_dsr_cnt), m_tmp_dsr->qual[
     ml_dsr_cnt].stat_snap_dt_tm = cnvtdatetime(md_capture_dt_tm)
     IF (ms_sort_criteria=ms_score)
      IF (pn_allusers_ind=0)
       m_tmp_dsr->qual[ml_dsr_cnt].snapshot_type = "V500_HOURLY_TOP_SQL"
      ELSEIF (pn_allusers_ind=1)
       m_tmp_dsr->qual[ml_dsr_cnt].snapshot_type = "OTHER_HOURLY_TOP_SQL"
      ENDIF
     ELSEIF (ms_sort_criteria=ms_shareable_mem)
      IF (pn_allusers_ind=0)
       m_tmp_dsr->qual[ml_dsr_cnt].snapshot_type = "V500_HOURLY_SHARE_MEM_SQL"
      ELSEIF (pn_allusers_ind=1)
       m_tmp_dsr->qual[ml_dsr_cnt].snapshot_type = "OTHER_HOURLY_SHARE_MEM_SQL"
      ENDIF
     ENDIF
    DETAIL
     IF (ml_idx < ml_num_entries)
      ml_idx = (ml_idx+ 1)
      IF (ml_idx > size(m_tmp_dsr->qual[ml_dsr_cnt].qual,5))
       stat = alterlist(m_tmp_dsr->qual[ml_dsr_cnt].qual,(ml_idx+ 9)), stat = alterlist(
        m_tmp_sql_entries->sqls,(ml_idx+ 9))
      ENDIF
      IF (pn_allusers_ind=1)
       ml_idx2 = locateval(ml_cnt,1,size(m_users->names,5),pl_user_id,m_users->names[ml_cnt].
        f_user_id)
       IF (ml_idx2 > 0)
        ps_user_name = m_users->names[ml_idx2].s_user_name
       ENDIF
      ELSE
       ps_user_name = "V500"
      ENDIF
      m_tmp_sql_entries->sqls[ml_idx].n_orig_ndx = pl_orig_ndx, m_tmp_sql_entries->sqls[ml_idx].
      s_sql_text = m_files_delta->sqls[pl_orig_ndx].sql_pieces[1].s_sql_piece
      IF (ms_sort_criteria=ms_score)
       m_tmp_dsr->qual[ml_dsr_cnt].qual[ml_idx].stat_number_val = pl_score
      ELSEIF (ms_sort_criteria=ms_shareable_mem)
       m_tmp_dsr->qual[ml_dsr_cnt].qual[ml_idx].stat_number_val = pl_share_mem
      ENDIF
      str_first_load = format(m_files_delta->sqls[pl_orig_ndx].d_first_load_time,"YYYYMMDDHHMMSS;;D"),
      ms_tmp_metrics = build(ps_user_name,",",pl_score,",",pl_share_mem,
       ",",str_first_load,",",m_files_delta->sqls[pl_orig_ndx].f_delta_buffer_gets,",",
       m_files_delta->sqls[pl_orig_ndx].f_delta_disk_reads,",",m_files_delta->sqls[pl_orig_ndx].
       f_delta_executions,",",m_files_delta->sqls[pl_orig_ndx].f_delta_rows_processed,
       ",",m_files_delta->sqls[pl_orig_ndx].f_delta_cpu_time,",",m_files_delta->sqls[pl_orig_ndx].
       s_optimizer_mode), m_tmp_dsr->qual[ml_dsr_cnt].qual[ml_idx].stat_clob_val = ms_tmp_metrics
     ELSE
      CALL cancel(1)
     ENDIF
    FOOT REPORT
     stat = alterlist(m_tmp_dsr->qual[ml_dsr_cnt].qual,ml_idx), stat = alterlist(m_tmp_sql_entries->
      sqls,ml_idx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Error: Filtering TOP N entries"
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_populate_sql_ids(null)
   DECLARE ms_input_str = vc WITH protect, noconstant("")
   DECLARE mn_sql_size = i4 WITH protect, noconstant(0)
   SET mn_sql_size = size(m_tmp_sql_entries->sqls,5)
   FOR (ml_idx = 1 TO mn_sql_size)
     SET ms_tmp_sqltext = substring(1,4000,trim(asis(replace(replace(m_tmp_sql_entries->sqls[ml_idx].
          s_sql_text,"'",'"',0),":","-",0)),3))
     SET ms_input_str = concat("dbms_utility.get_hash_value('",ms_tmp_sqltext,"',0,1073741824)")
     SELECT INTO "nl:"
      sql_id = sqlpassthru(ms_input_str,0)
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
      DETAIL
       m_tmp_sql_entries->sqls[ml_idx].f_sql_id = sql_id, m_tmp_dsr->qual[ml_dsr_cnt].qual[ml_idx].
       stat_name = cnvtstring(sql_id)
      WITH maxqual(di,1), nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     SET ml_cnt = 0
     SET ml_idx2 = locateval(ml_cnt,1,(ml_idx - 1),m_tmp_sql_entries->sqls[ml_idx].f_sql_id,
      m_tmp_sql_entries->sqls[ml_cnt].f_sql_id)
     IF (ml_idx2 > 0)
      SET m_tmp_sql_entries->sqls[ml_idx].n_dup_ind = 1
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE sbr_populate_master_data(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(m_tmp_sql_entries->sqls,5)))
    WHERE d1.seq > 0
     AND (m_tmp_sql_entries->sqls[d1.seq].n_dup_ind=0)
    HEAD REPORT
     ml_idx = 0, stat = alterlist(dsr->qual,ml_dsr_cnt)
    DETAIL
     ml_idx = (ml_idx+ 1)
     IF (ml_idx > size(m_sql_entries->sqls,5))
      stat = alterlist(dsr->qual[ml_dsr_cnt].qual,(ml_idx+ 9)), stat = alterlist(m_sql_entries->sqls,
       (ml_idx+ 9))
     ENDIF
     m_sql_entries->sqls[ml_idx].f_sql_id = m_tmp_sql_entries->sqls[d1.seq].f_sql_id, m_sql_entries->
     sqls[ml_idx].n_orig_ndx = m_tmp_sql_entries->sqls[d1.seq].n_orig_ndx, m_sql_entries->sqls[ml_idx
     ].s_sql_text = m_tmp_sql_entries->sqls[d1.seq].s_sql_text,
     dsr->qual[ml_dsr_cnt].stat_snap_dt_tm = m_tmp_dsr->qual[ml_dsr_cnt].stat_snap_dt_tm, dsr->qual[
     ml_dsr_cnt].snapshot_type = m_tmp_dsr->qual[ml_dsr_cnt].snapshot_type, dsr->qual[ml_dsr_cnt].
     qual[ml_idx].stat_name = m_tmp_dsr->qual[ml_dsr_cnt].qual[d1.seq].stat_name,
     dsr->qual[ml_dsr_cnt].qual[ml_idx].stat_number_val = m_tmp_dsr->qual[ml_dsr_cnt].qual[d1.seq].
     stat_number_val, dsr->qual[ml_dsr_cnt].qual[ml_idx].stat_clob_val = m_tmp_dsr->qual[ml_dsr_cnt].
     qual[d1.seq].stat_clob_val
    FOOT REPORT
     stat = alterlist(dsr->qual[ml_dsr_cnt].qual,ml_idx), stat = alterlist(m_sql_entries->sqls,ml_idx
      )
    WITH nocounter
   ;end select
   SET stat = initrec(m_tmp_sql_entries)
   SET stat = initrec(m_tmp_dsr)
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Error: Filtering duplicate data..."
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_store_sql_text(null)
   SELECT INTO "nl:"
    FROM dm_stat_snaps_sql dsss
    PLAN (dsss
     WHERE expand(ml_idx,1,size(m_sql_entries->sqls,5),dsss.sql_ident,m_sql_entries->sqls[ml_idx].
      f_sql_id))
    HEAD REPORT
     ml_idx = 0
    DETAIL
     ml_idx = locateval(ml_cnt,1,size(m_sql_entries->sqls,5),dsss.sql_ident,m_sql_entries->sqls[
      ml_cnt].f_sql_id)
     IF (ml_idx > 0)
      m_sql_entries->sqls[ml_idx].n_exists_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Error: Gathering existing SQL entries"
    GO TO exit_program
   ENDIF
   UPDATE  FROM dm_stat_snaps_sql dsss
    SET dsss.updt_cnt = (dsss.updt_cnt+ 1), dsss.updt_dt_tm = cnvtdatetime(md_capture_dt_tm)
    PLAN (dsss
     WHERE expand(ml_idx,1,value(size(m_sql_entries->sqls,5)),dsss.sql_ident,m_sql_entries->sqls[
      ml_idx].f_sql_id))
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Error: Updating existing SQL entries"
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Successfully updated existing SQL_Text entries..."
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD m_dm2_seq_stat
   RECORD m_dm2_seq_stat(
     1 n_status = i4
     1 s_error_msg = vc
   ) WITH protect
   EXECUTE dm2_dar_get_bulk_seq "m_sql_entries->sqls", size(m_sql_entries->sqls,5), "f_seq_id",
   1, "DM_CLINICAL_SEQ"
   IF ((m_dm2_seq_stat->n_status != 1))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = m_dm2_seq_stat->s_error_msg
    GO TO exit_program
   ENDIF
   INSERT  FROM dm_stat_snaps_sql dsss,
     (dummyt d1  WITH seq = value(size(m_sql_entries->sqls,5)))
    SET dsss.dm_stat_snaps_sql_id = m_sql_entries->sqls[d1.seq].f_seq_id, dsss.sql_ident =
     m_sql_entries->sqls[d1.seq].f_sql_id, dsss.create_dt_tm = cnvtdatetime(md_capture_dt_tm),
     dsss.updt_dt_tm = cnvtdatetime(md_capture_dt_tm), dsss.sql_text = m_sql_entries->sqls[d1.seq].
     s_sql_text, dsss.updt_cnt = 1
    PLAN (d1
     WHERE d1.seq > 0
      AND (m_sql_entries->sqls[d1.seq].n_exists_ind=0))
     JOIN (dsss)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Error: Inserting new SQL entries"
    GO TO exit_program
   ENDIF
   FREE RECORD m_dm2_seq_stat
   SET dm_err->eproc = "Successfully inserted new SQL_Text entries..."
   CALL disp_msg(" ",dm_err->logfile,0)
 END ;Subroutine
#exit_program
 FREE RECORD m_sql_entries
 FREE RECORD m_users
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Ending DM_STAT_GATHER_TOP_SQL.  Process completed successfully."
  CALL final_disp_msg(dm_err->logfile)
 ELSE
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  CALL esmerror(dm_err->eproc,esmreturn)
 ENDIF
END GO
