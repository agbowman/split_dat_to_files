CREATE PROGRAM dm2_rdds_req_chk:dba
 IF ((validate(rreqmts->refresh_ind,- (99))=- (99))
  AND (validate(rreqmts->req_level,- (99))=- (99)))
  RECORD rreqmts(
    1 refresh_ind = i2
    1 new_inst_met_ind = i2
    1 req_level = i2
    1 tbl[*]
      2 table_name = vc
      2 old_ovr_inst_met = i4
      2 new_ovr_inst_met = i4
      2 ovr_inst[*]
        3 override_inst = i4
        3 req[*]
          4 req_name = vc
          4 req_type = vc
          4 req_version_nbr = i4
          4 req_met_ind = i2
      2 schema_instance = i4
    1 req_met[*]
      2 req_name = vc
      2 req_type = vc
      2 req_version_nbr = i4
  )
 ENDIF
 DECLARE dm2_rdds_metadata_view_val(sbr_drmvc_dblink=vc,sbr_drmvc_env_id=f8) = i2
 SUBROUTINE dm2_rdds_metadata_view_val(sbr_drmvc_dblink,sbr_drmvc_env_id)
   DECLARE drmvc_link_name = vc
   IF (sbr_drmvc_dblink="NONE")
    SET drmvc_link_name = " "
   ELSE
    SET drmvc_link_name = sbr_drmvc_dblink
   ENDIF
   SET dm_err->eproc = "Validating RDDS metadata views"
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dm2_push_cmd('select into "nl:" drtd.* from ',0)
   CALL dm2_push_cmd(concat("dm_rdds_tbl_doc",drmvc_link_name," drtd "),0)
   CALL dm2_push_cmd(concat(" where drtd.local_env_id NOT = ",build(sbr_drmvc_env_id)),0)
   SET drcmv_errcheck = dm2_push_cmd(" with nocounter,maxqual(drtd,1) go",1)
   IF (drcmv_errcheck=0)
    RETURN(0)
   ELSEIF (curqual != 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(
     "Invalid environment_id found in dm_rdds_tbl_doc view.  DM_ENV_ID may have been ",
     "changed outside the context of a Cerner-defined process.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd('select into "nl:" drtd.* from ',0)
   CALL dm2_push_cmd(concat("dm_rdds_col_doc",drmvc_link_name," drtd "),0)
   CALL dm2_push_cmd(concat(" where drtd.local_env_id NOT = ",build(sbr_drmvc_env_id)),0)
   SET drcmv_errcheck = dm2_push_cmd(" with nocounter go",1)
   IF (drcmv_errcheck=0)
    RETURN(0)
   ELSEIF (curqual != 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(
     "Invalid environment_id found in dm_rdds_col_doc view.  DM_ENV_ID may have been ",
     "changed outside the context of a Cerner-defined process.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
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
 DECLARE dsr_sd_in_use_check(dsiuc_db_link=vc,dsiuc_sd_in_use_ind=i2(ref)) = i2
 DECLARE dsr_usage_prep(dup_db_link=vc) = i2
 DECLARE dsr_sd_get_trigger_version(dsgtv_owner=vc,dsgtv_trigger_name=vc,dsgtv_table_name=vc,
  dsgtv_when_clause=vc,dsgtv_trig_version=i4(ref)) = i2
 DECLARE dsr_check_object_state(dcos_owner=vc,dcos_object_type=vc,dcos_object_name=vc,dcos_state=vc,
  dcos_obj_drop_ind=i2(ref)) = i2
 DECLARE dsr_chk_sd_in_process(dcsip_db_group=vc,dcsip_owner=vc,dcsip_sd_in_process=i2(ref)) = i2
 IF ((validate(dsr_obj_state->cnt,- (1))=- (1))
  AND (validate(dsr_obj_state->cnt,- (2))=- (2)))
  FREE RECORD dsr_obj_state
  RECORD dsr_obj_state(
    1 obj_owner = vc
    1 obj_type = vc
    1 state = vc
    1 cnt = i4
    1 qual[*]
      2 obj_name = vc
  )
 ENDIF
 IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,0)=0
  AND validate(dsr_sd_misc->ccl_tbldef_sync_ind,1)=1)
  FREE RECORD dsr_sd_misc
  RECORD dsr_sd_misc(
    1 ccl_tbldef_sync_ind = i2
  )
  SET dsr_sd_misc->ccl_tbldef_sync_ind = 0
 ENDIF
 SUBROUTINE dsr_sd_in_use_check(dsiuc_db_link,dsiuc_sd_in_use_ind)
   DECLARE dsiuc_qry_stats = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dsiuc_sd_tbl_v_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_qry_sd_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_tbl_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_pkg_qry_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_pkg_valid_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_pkg_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_cnt = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_in_view_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_use_link_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_db_link_new = vc WITH protect, noconstant("")
   DECLARE dsiuc_mill_cds_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_param_table = vc WITH noconstant("")
   SET dsiuc_sd_in_use_ind = 0
   IF (trim(dsiuc_db_link,3) > ""
    AND dsiuc_db_link != "DM2NOTSET")
    IF (substring(1,1,dsiuc_db_link)="@")
     SET dsiuc_db_link_new = substring(2,(size(trim(dsiuc_db_link,3)) - 1),dsiuc_db_link)
    ELSE
     SET dsiuc_db_link_new = dsiuc_db_link
    ENDIF
    SET dsiuc_use_link_ind = 1
   ENDIF
   IF (currdbuser != "V500")
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if CERADM schema exists."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("dba_users@",dsiuc_db_link_new)) d)
     WHERE d.username="CERADM"
    ELSE
     FROM dba_users d
     WHERE d.username="CERADM"
    ENDIF
    INTO "nl:"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("SD framework is not in use.")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if SD_PARAM exists."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) t)
     WHERE t.owner="CERADM"
      AND t.table_name="SD_PARAM"
    ELSE
     FROM dba_tables t
     WHERE t.owner="CERADM"
      AND t.table_name="SD_PARAM"
    ENDIF
    INTO "nl:"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("SD_PARAM do not exists.")
    ENDIF
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if Millennium-CDS in use."
   CALL disp_msg("",dm_err->logfile,0)
   IF (dsiuc_use_link_ind=1)
    SET dsiuc_sd_param_table = concat("CERADM.SD_PARAM@",dsiuc_db_link_new)
   ELSE
    SET dsiuc_sd_param_table = "CERADM.SD_PARAM"
   ENDIF
   SELECT INTO "nl:"
    x = sqlpassthru(concat(asis("(select count(*) from "),dsiuc_sd_param_table," SDP ",asis(
       "where SDP.PTYPE  = 'CDS_GLOBAL_CONFIG'"),asis(
       "  and SDP.PNAME  = 'MILLENNIUM_CDS_IN_USE') as rowsCnt")),0)
    FROM dual
    DETAIL
     dsiuc_mill_cds_ind = x
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dsiuc_mill_cds_ind=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("Millennium-CDS is not in use.")
    ENDIF
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 5))
    CALL echo("Millennium-CDS is in use.")
   ENDIF
   SET dm_err->eproc = "Check to see if dm_info exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     dsiuc_tmp_qry_cnt = count(*)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) d)
     WHERE d.owner=currdbuser
      AND d.table_name="DM_INFO"
    ELSE
     dsiuc_tmp_qry_cnt = count(*)
     FROM dba_tables d
     WHERE d.owner=currdbuser
      AND d.table_name="DM_INFO"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_dm_info_fnd_ind = dsiuc_tmp_qry_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_dm_info_fnd_ind=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DM_INFO does not exist"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if sd not in use due to dm_info override."
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("DM_INFO@",dsiuc_db_link_new)) di)
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="SD_NOT_IN_USE_OVERRIDE"
    ELSE
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="SD_NOT_IN_USE_OVERRIDE"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_dm_info_cnt = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dsiuc_dm_info_cnt > 0)
    CALL echo("SD not in use due to DM_INFO override")
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if Schema Deployment SD_TABLE_VERSION_V view exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     FROM (parser(concat("dba_objects@",dsiuc_db_link_new)) d)
     WHERE d.owner="CERADM"
      AND d.object_name="SD_TABLE_VERSION_V"
      AND d.object_type="VIEW"
    ELSE
     FROM dba_objects d
     WHERE d.owner="CERADM"
      AND d.object_name="SD_TABLE_VERSION_V"
      AND d.object_type="VIEW"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_qry_stats = d.status
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_qry_stats="VALID")
    SET dm_err->eproc = "Check to see if dm_info is union of SD view or not."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT
     IF (dsiuc_use_link_ind)
      FROM (parser(concat("dba_views@",dsiuc_db_link_new)) v)
      WHERE v.owner="CERADM"
       AND v.view_name="SD_TABLE_VERSION_V"
     ELSE
      FROM dba_views v
      WHERE v.owner="CERADM"
       AND v.view_name="SD_TABLE_VERSION_V"
     ENDIF
     INTO "nl:"
     DETAIL
      IF (cnvtlower(v.text)="*union all*"
       AND cnvtlower(v.text)="*v500*dm_info*")
       dsiuc_dm_info_in_view_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dsiuc_dm_info_in_view_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No union of V500.DM_INFO in SD view"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dsiuc_sd_tbl_v_ind = 1
   ELSEIF (dsiuc_qry_stats="INVALID")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid Schema deployment Objects exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if Schema Deployment tables exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     dsiuc_tbl_tmp_cnt = count(*)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) t)
     WHERE t.owner="CERADM"
      AND t.table_name IN ("SD_TABLES", "SD_TABLE_COLS", "SD_TABLE_INDS", "SD_TABLE_IND_COLS",
     "SD_TABLE_CONS",
     "SD_TABLE_CON_COLS", "SD_TABLE_GROUP", "SD_DDL_OPS", "SD_OBJECT_VERSION", "SD_OBJECT_STATE",
     "SD_PROCESS_EVENT")
    ELSE
     dsiuc_tbl_tmp_cnt = count(*)
     FROM dba_tables t
     WHERE t.owner="CERADM"
      AND t.table_name IN ("SD_TABLES", "SD_TABLE_COLS", "SD_TABLE_INDS", "SD_TABLE_IND_COLS",
     "SD_TABLE_CONS",
     "SD_TABLE_CON_COLS", "SD_TABLE_GROUP", "SD_DDL_OPS", "SD_OBJECT_VERSION", "SD_OBJECT_STATE",
     "SD_PROCESS_EVENT")
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_qry_sd_tbl_cnt = dsiuc_tbl_tmp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_qry_sd_tbl_cnt=11)
    SET dsiuc_sd_tbl_ind = 1
   ELSEIF (dsiuc_qry_sd_tbl_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Incomplete SD table(s) exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Check to see if Schema Deployment SD_OBJECT_VERSION_PKG package exists or not"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     FROM (parser(concat("dba_objects@",dsiuc_db_link_new)) o)
     WHERE o.owner="CERADM"
      AND o.object_name="SD_OBJECT_VERSION_PKG"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    ELSE
     FROM dba_objects o
     WHERE o.owner="CERADM"
      AND o.object_name="SD_OBJECT_VERSION_PKG"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_pkg_qry_cnt = (dsiuc_pkg_qry_cnt+ 1)
     IF (o.status="VALID")
      dsiuc_pkg_valid_cnt = (dsiuc_pkg_valid_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_pkg_valid_cnt=2)
    SET dsiuc_sd_pkg_ind = 1
   ELSEIF (dsiuc_pkg_qry_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid Schema deployment SD_OBJECT_VERSION_PKG package exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_sd_tbl_v_ind=1
    AND dsiuc_sd_tbl_ind=1
    AND dsiuc_sd_pkg_ind=1)
    CALL echo("SD framework is in use")
    SET dsiuc_sd_in_use_ind = 1
   ELSEIF (dsiuc_sd_tbl_v_ind=0
    AND dsiuc_sd_tbl_ind=0
    AND dsiuc_sd_pkg_ind=0)
    CALL echo("SD framework is not in use")
    SET dsiuc_sd_in_use_ind = 0
   ELSE
    SET dm_err->eproc = "Check if SD objects exists or not"
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Incomplete Schema Deployment framework."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_usage_prep(dup_db_link)
   FREE RECORD dsr_ceradm_rs
   RECORD dsr_ceradm_rs(
     1 tbl_cnt = i4
     1 tbl[*]
       2 tbl_name = vc
       2 ccl_def_ind = i2
       2 col_cnt = i4
       2 col[*]
         3 col_name = vc
   )
   DECLARE dup_use_link_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_db_link_new = vc WITH protect, noconstant("")
   DECLARE dup_tblx = i4 WITH protect, noconstant(0)
   DECLARE dup_colx = i4 WITH protect, noconstant(0)
   DECLARE dup_col_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_coldef_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_data_type = vc WITH protect, noconstant("")
   IF (trim(dup_db_link,3) > ""
    AND dup_db_link != "DM2NOTSET")
    IF (substring(1,1,dup_db_link)="@")
     SET dup_db_link_new = substring(2,(size(trim(dup_db_link,3)) - 1),dup_db_link)
    ELSE
     SET dup_db_link_new = dup_db_link
    ENDIF
    SET dup_use_link_ind = 1
   ENDIF
   IF (currdbuser != "V500")
    RETURN(1)
   ENDIF
   IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,0)=1)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Loading CERADM Record Structure"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dup_use_link_ind=1)
     FROM (parser(concat("dba_tab_columns@",dup_db_link_new)) dtc)
     WHERE dtc.owner="CERADM"
      AND dtc.table_name="SD*"
     ORDER BY dtc.table_name, dtc.column_name
    ELSE
     FROM dba_tab_columns dtc
     WHERE dtc.owner="CERADM"
      AND dtc.table_name="SD*"
     ORDER BY dtc.table_name, dtc.column_name
    ENDIF
    INTO "nl:"
    HEAD REPORT
     dup_tblx = 0
    HEAD dtc.table_name
     dup_colx = 0, dup_tblx = (dup_tblx+ 1)
     IF (mod(dup_tblx,10)=1)
      stat = alterlist(dsr_ceradm_rs->tbl,(dup_tblx+ 9))
     ENDIF
     dsr_ceradm_rs->tbl[dup_tblx].tbl_name = dtc.table_name, dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind
      = 0
    DETAIL
     dup_colx = (dup_colx+ 1)
     IF (mod(dup_colx,10)=1)
      stat = alterlist(dsr_ceradm_rs->tbl[dup_tblx].col,(dup_colx+ 9))
     ENDIF
     dsr_ceradm_rs->tbl[dup_tblx].col[dup_colx].col_name = dtc.column_name
    FOOT  dtc.table_name
     stat = alterlist(dsr_ceradm_rs->tbl[dup_tblx].col,dup_colx), dsr_ceradm_rs->tbl[dup_tblx].
     col_cnt = dup_colx
    FOOT REPORT
     stat = alterlist(dsr_ceradm_rs->tbl,dup_tblx), dsr_ceradm_rs->tbl_cnt = dup_tblx
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Comparing CCL Definitions to CERADM Record Structure"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dup_tblx = 1 TO dsr_ceradm_rs->tbl_cnt)
     IF (checkdic(cnvtupper(dsr_ceradm_rs->tbl[dup_tblx].tbl_name),"T",0)=2)
      FOR (dup_colx = 1 TO dsr_ceradm_rs->tbl[dup_tblx].col_cnt)
        SET dup_coldef_fnd_ind = 0
        IF (dm2_table_column_exists("",cnvtupper(dsr_ceradm_rs->tbl[dup_tblx].tbl_name),cnvtupper(
          dsr_ceradm_rs->tbl[dup_tblx].col[dup_colx].col_name),0,1,
         1,dup_col_fnd_ind,dup_coldef_fnd_ind,dup_data_type)=0)
         RETURN(0)
        ENDIF
        IF (dup_coldef_fnd_ind=0)
         SET dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind = 1
         SET dup_colx = dsr_ceradm_rs->tbl[dup_tblx].col_cnt
        ENDIF
      ENDFOR
     ELSE
      SET dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind = 1
     ENDIF
   ENDFOR
   SET dup_tblx = 0
   SET dup_tblx = locateval(dup_tblx,1,dsr_ceradm_rs->tbl_cnt,1,dsr_ceradm_rs->tbl[dup_tblx].
    ccl_def_ind)
   IF (dup_tblx > 0)
    SET dm_err->eproc = "Create CCL definitions for SD tables"
    CALL disp_msg("",dm_err->logfile,0)
    FOR (dup_tblx = 1 TO dsr_ceradm_rs->tbl_cnt)
     IF ((dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind=1))
      IF (dup_use_link_ind=1)
       EXECUTE oragen3 cnvtupper(concat("CERADM.",dsr_ceradm_rs->tbl[dup_tblx].tbl_name,"@",
         dup_db_link_new))
      ELSE
       EXECUTE oragen3 cnvtupper(concat("CERADM.",dsr_ceradm_rs->tbl[dup_tblx].tbl_name))
      ENDIF
     ENDIF
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDFOR
   ENDIF
   IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,- (1))=0)
    SET dsr_sd_misc->ccl_tbldef_sync_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_check_object_state(dcos_owner,dcos_object_type,dcos_object_name,dcos_state,
  dcos_obj_drop_ind)
   DECLARE dcos_obj_idx = i4 WITH protect, noconstant(0)
   SET dcos_obj_drop_ind = 0
   IF ((((dsr_obj_state->cnt=0)) OR ((((dsr_obj_state->obj_type != dcos_object_type)) OR ((
   dsr_obj_state->state != dcos_state))) )) )
    SET stat = alterlist(dsr_obj_state->qual,0)
    SET dsr_obj_state->cnt = 0
    SET dsr_obj_state->obj_owner = dcos_owner
    SET dsr_obj_state->obj_type = dcos_object_type
    SET dsr_obj_state->state = dcos_state
    SET dm_err->eproc = "Check to see if object is in dropped state or not."
    SELECT INTO "nl:"
     FROM (ceradm.sd_object_state sos)
     WHERE sos.object_owner=dcos_owner
      AND sos.object_type=dcos_object_type
      AND sos.state=dcos_state
     DETAIL
      dsr_obj_state->cnt = (dsr_obj_state->cnt+ 1), stat = alterlist(dsr_obj_state->qual,
       dsr_obj_state->cnt), dsr_obj_state->qual[dsr_obj_state->cnt].obj_name = sos.object_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dsr_obj_state->cnt > 0))
    SET dcos_obj_idx = locateval(dcos_obj_idx,1,dsr_obj_state->cnt,dcos_object_name,dsr_obj_state->
     qual[dcos_obj_idx].obj_name)
   ENDIF
   IF (dcos_obj_idx > 0)
    SET dcos_obj_drop_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_sd_get_trigger_version(dsgtv_owner,dsgtv_trigger_name,dsgtv_table_name,
  dsgtv_when_clause,dsgtv_trig_version)
   DECLARE dsgtv_qry_cnt = i4 WITH protect, noconstant(0)
   DECLARE regexp_replace() = c300
   SET dm_err->eproc = "Retrieving from dba_triggers to pull the trigger version."
   SELECT
    IF (dsgtv_when_clause != "DM2NOTSET")
     tmp_version = regexp_replace(dt.description,"(.*/\*version_)(\d+)(\*/.*)","\2",1,0,
      "in")
     FROM dba_triggers dt
     WHERE dt.trigger_name=patstring(dsgtv_trigger_name)
      AND dt.table_name=dsgtv_table_name
      AND cnvtupper(dt.when_clause)=patstring(cnvtupper(dsgtv_when_clause))
      AND dt.owner=dsgtv_owner
    ELSE
     tmp_version = regexp_replace(dt.description,"(.*/\*version_)(\d+)(\*/.*)","\2",1,0,
      "in")
     FROM dba_triggers dt
     WHERE dt.trigger_name=dsgtv_trigger_name
      AND dt.table_name=dsgtv_table_name
      AND dt.owner=dsgtv_owner
    ENDIF
    INTO "nl:"
    DETAIL
     dsgtv_qry_cnt = (dsgtv_qry_cnt+ 1), dsgtv_trig_version = cnvtint(tmp_version)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if multiple rows are qualified from dba_triggers"
   IF (dsgtv_qry_cnt > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "failed due to the multiple rows are qualified from dba_triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsgtv_trig_version <= 0)
    SET dsgtv_trig_version = - (1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_chk_sd_in_process(dcsip_db_group,dcsip_owner,dcsip_sd_in_process)
   DECLARE dcsip_get_session_status(session_ident=vc) = i2 WITH sql =
   "CERADM.SD_DDL_MANAGE_PKG.session_is_alive", parameter
   DECLARE dcsip_pvalue_ind = i2 WITH protect, noconstant(0)
   DECLARE dcsip_ret_value = i2 WITH protect, noconstant(0)
   DECLARE dcsip_sessidx = i4 WITH protect, noconstant(0)
   FREE RECORD dcsip_session
   RECORD dcsip_session(
     1 cnt = i4
     1 session[*]
       2 sess_id = vc
   )
   SET dcsip_sd_in_process = 0
   SET stat = alterlist(dcsip_session->session,0)
   SET dcsip_session->cnt = 0
   SET dm_err->eproc = "Checking if schema deployment is actively running"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    spe.session_ident
    FROM (ceradm.sd_process_event spe)
    WHERE spe.db_group=dcsip_db_group
     AND spe.owner=dcsip_owner
     AND spe.process_name="INSTALLER"
     AND spe.event_name="SCHEMA UPDATE"
     AND spe.status="RUNNING"
    DETAIL
     dcsip_session->cnt = (dcsip_session->cnt+ 1), stat = alterlist(dcsip_session->session,
      dcsip_session->cnt), dcsip_session->session[dcsip_session->cnt].sess_id = spe.session_ident
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcsip_session->cnt > 0))
    SET dm_err->eproc =
    "Evaluating if there's an override with schema deployment to evaluate only active event sessions."
    SELECT INTO "nl:"
     FROM (ceradm.sd_param sp)
     WHERE sp.pname="PROCESS_EVENT_CHK_ACTIVE_SESSIONS_ONLY"
      AND sp.ptype="CONFIG"
     DETAIL
      IF (sp.pvalue="YES")
       dcsip_pvalue_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dcsip_pvalue_ind=0)
     SET dcsip_sd_in_process = 1
    ELSE
     SET dm_err->eproc = "Evaluating if session is alive or dead"
     FOR (dcsip_sessidx = 1 TO dcsip_session->cnt)
      SELECT INTO "nl:"
       ret_value_tmp = dcsip_get_session_status(dcsip_session->session[dcsip_sessidx].sess_id)
       FROM dual
       DETAIL
        IF (ret_value_tmp=1)
         dcsip_sd_in_process = 1, dcsip_sessidx = dcsip_session->cnt
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) > 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (check_logfile("drrc",".log","DM2_RDDS_REQ_CHK")=0)
  CALL echo(concat("While creating log file: ",dm_err->emsg))
  GO TO drrc_exit
 ENDIF
 DECLARE drrc_env_id = f8 WITH protect, constant(cnvtreal( $1))
 DECLARE drrc_dblink = vc WITH protect, noconstant(" ")
 DECLARE drrc_req_met_cnt = i4 WITH protect, noconstant(0)
 DECLARE drrc_req_met_sum = i4 WITH protect, noconstant(0)
 DECLARE drrc_temp_size = i4 WITH protect, noconstant(0)
 DECLARE drrc_errcheck = i2 WITH protect, noconstant(0)
 DECLARE drrc_table_cnt = i4 WITH protect, noconstant(0)
 DECLARE drrc_idx = i4 WITH protect, noconstant(0)
 DECLARE drrc_pad_cnt = i4 WITH protect, noconstant(0)
 DECLARE drrc_batch_size = i4 WITH protect, constant(100)
 DECLARE drrc_estart = i4 WITH protect, noconstant(1)
 DECLARE drrc_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE drrc_sd_in_use_ind = i2 WITH protect, noconstant(0)
 DECLARE drrc_disp_info(s_msg=vc) = i2
 SET dm_err->eproc = "Begin dm2_rdds_req_chk"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (cnvtupper( $2) != "NONE")
  SET drrc_dblink = cnvtupper( $2)
 ENDIF
 IF (dsr_sd_in_use_check(drrc_dblink,drrc_sd_in_use_ind)=0)
  GO TO drrc_exit
 ENDIF
 IF (drrc_sd_in_use_ind=1)
  IF (dsr_usage_prep(drrc_dblink)=0)
   GO TO drrc_exit
  ENDIF
 ENDIF
 SET dm_err->eproc = "Loading RDDS override requirements"
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL dm2_push_cmd("select into 'nl:' from ",0)
 CALL dm2_push_cmd("dm_rdds_override_req dror ",0)
 CALL dm2_push_cmd("where dror.active_ind = 1 ",0)
 CALL dm2_push_cmd("order by dror.table_name, dror.override_instance desc ",0)
 CALL dm2_push_cmd("head report ",0)
 CALL dm2_push_cmd("  drrc_table_cnt = 0 ",0)
 CALL dm2_push_cmd("head dror.table_name ",0)
 CALL dm2_push_cmd("  drrc_table_cnt = drrc_table_cnt + 1 ",0)
 CALL dm2_push_cmd("  if (mod(drrc_table_cnt, 100) = 1) ",0)
 CALL dm2_push_cmd("     stat = alterlist(rReqmts->tbl, drrc_table_cnt + 99) ",0)
 CALL dm2_push_cmd(" endif ",0)
 CALL dm2_push_cmd("rReqmts->tbl[drrc_table_cnt].table_name = dror.table_name ",0)
 CALL dm2_push_cmd("drrc_oi_cnt = 0 ",0)
 CALL dm2_push_cmd("head dror.override_instance ",0)
 CALL dm2_push_cmd("drrc_oi_cnt = drrc_oi_cnt + 1 ",0)
 CALL dm2_push_cmd("     stat = alterlist(rReqmts->tbl[drrc_table_cnt]->ovr_inst,drrc_oi_cnt) ",0)
 CALL dm2_push_cmd(
  "rReqmts->tbl[drrc_table_cnt]->ovr_inst[drrc_oi_cnt].override_inst = dror.override_instance ",0)
 CALL dm2_push_cmd("  drrc_req_cnt = 0 ",0)
 CALL dm2_push_cmd("detail ",0)
 CALL dm2_push_cmd("  drrc_req_cnt =drrc_req_cnt + 1 ",0)
 CALL dm2_push_cmd("  if (mod(drrc_req_cnt, 10) = 1) ",0)
 CALL dm2_push_cmd(
  " stat = alterlist(rReqmts->tbl[drrc_table_cnt]->ovr_inst[drrc_oi_cnt]->req,drrc_req_cnt+9) ",0)
 CALL dm2_push_cmd("  endif ",0)
 CALL dm2_push_cmd(
  " rReqmts->tbl[drrc_table_cnt]->ovr_inst[drrc_oi_cnt]->req[drrc_req_cnt].req_name = dror.req_name ",
  0)
 CALL dm2_push_cmd(
  " rReqmts->tbl[drrc_table_cnt]->ovr_inst[drrc_oi_cnt]->req[drrc_req_cnt].req_type = dror.req_type ",
  0)
 CALL dm2_push_cmd(
  "rReqmts->tbl[drrc_table_cnt]->ovr_inst[drrc_oi_cnt]->req[drrc_req_cnt].req_version_nbr = dror.req_version_nbr ",
  0)
 CALL dm2_push_cmd(
  "  rReqmts->tbl[drrc_table_cnt]->ovr_inst[drrc_oi_cnt]->req[drrc_req_cnt].req_met_ind = 0 ",0)
 CALL dm2_push_cmd("foot dror.override_instance ",0)
 CALL dm2_push_cmd(
  "  stat = alterlist(rReqmts->tbl[drrc_table_cnt]->ovr_inst[drrc_oi_cnt]->req,drrc_req_cnt)  ",0)
 CALL dm2_push_cmd("foot report ",0)
 CALL dm2_push_cmd("  stat = alterlist(rReqmts->tbl, drrc_table_cnt) ",0)
 SET drrc_errcheck = dm2_push_cmd("with nocounter go",1)
 IF (drrc_errcheck=0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO drrc_exit
 ENDIF
 SET dm_err->eproc = "Determing what RDDS override requirements have been met"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_rdds_tbl_doc_env drtde
  WHERE drtde.environment_id=drrc_env_id
  HEAD REPORT
   drrc_idx = 0
  DETAIL
   drrc_index = locateval(drrc_idx,1,drrc_table_cnt,drtde.table_name,rreqmts->tbl[drrc_idx].
    table_name)
   IF (drrc_index=0)
    stat = drrc_disp_info(concat(trim(drtde.table_name)," used to meet override_instance ",trim(
       cnvtstring(drtde.override_instance)),
      " but now there are no active requirements for the table."))
   ELSE
    rreqmts->tbl[drrc_index].old_ovr_inst_met = drtde.override_instance
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO drrc_exit
 ENDIF
 SET drrc_idx = 0
 SET drrc_loop_cnt = ceil((cnvtreal(drrc_table_cnt)/ drrc_batch_size))
 SET drrc_pad_cnt = (drrc_loop_cnt * drrc_batch_size)
 SET stat = alterlist(rreqmts->tbl,drrc_pad_cnt)
 FOR (i = (drrc_table_cnt+ 1) TO drrc_pad_cnt)
   SET rreqmts->tbl[i].table_name = rreqmts->tbl[drrc_table_cnt].table_name
 ENDFOR
 SET dm_err->eproc = "getting the schema instance"
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL dm2_push_cmd("select into 'nl:' from ",0)
 IF (drrc_sd_in_use_ind=1)
  CALL dm2_push_cmd(concat("ceradm.sd_table_version_v",drrc_dblink," stv, "),0)
  CALL dm2_push_cmd("(dummyt d with seq = value(drrc_loop_cnt)) ",0)
  CALL dm2_push_cmd("plan d ",0)
  CALL dm2_push_cmd(
   "  where initarray(drrc_estart, evaluate(d.seq,1,1,drrc_estart+drrc_batch_size)) ",0)
  CALL dm2_push_cmd("join stv ",0)
  CALL dm2_push_cmd("  where expand(drrc_idx, drrc_estart, drrc_estart + (drrc_batch_size -1),  ",0)
  CALL dm2_push_cmd("                stv.table_name, rReqmts->tbl[drrc_idx].table_name) ",0)
  CALL dm2_push_cmd("    and stv.owner = currdbuser ",0)
  CALL dm2_push_cmd("head report ",0)
  CALL dm2_push_cmd("  loc = 0 ",0)
  CALL dm2_push_cmd("detail ",0)
  CALL dm2_push_cmd(
   "  drrc_index = locateval(loc,1,drrc_table_cnt, stv.table_name,rReqmts->tbl[loc].table_name) ",0)
  CALL dm2_push_cmd("  rReqmts->tbl[drrc_index].schema_instance = stv.version_nbr ",0)
 ELSE
  CALL dm2_push_cmd(concat("dm_info",drrc_dblink," di, "),0)
  CALL dm2_push_cmd("(dummyt d with seq = value(drrc_loop_cnt)) ",0)
  CALL dm2_push_cmd("plan d ",0)
  CALL dm2_push_cmd(
   "  where initarray(drrc_estart, evaluate(d.seq,1,1,drrc_estart+drrc_batch_size)) ",0)
  CALL dm2_push_cmd("join di ",0)
  CALL dm2_push_cmd("  where di.INFO_DOMAIN = 'DM2_SCHEMA_INSTANCE' ",0)
  CALL dm2_push_cmd("    and expand(drrc_idx, drrc_estart, drrc_estart + (drrc_batch_size -1),  ",0)
  CALL dm2_push_cmd("                di.info_name, rReqmts->tbl[drrc_idx].table_name) ",0)
  CALL dm2_push_cmd("head report ",0)
  CALL dm2_push_cmd("  loc = 0 ",0)
  CALL dm2_push_cmd("detail ",0)
  CALL dm2_push_cmd(
   "  drrc_index = locateval(loc,1,drrc_table_cnt, di.info_name,rReqmts->tbl[loc].table_name) ",0)
  CALL dm2_push_cmd("  rReqmts->tbl[drrc_index].schema_instance = di.info_number ",0)
 ENDIF
 SET drrc_errcheck = dm2_push_cmd("with nocounter go",1)
 IF (drrc_errcheck=0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO drrc_exit
 ENDIF
 SET stat = alterlist(rreqmts->tbl,drrc_table_cnt)
 SET dm_err->eproc = "Loading 'CODE' requirements that have been met in this environment"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_rdds_req_install_env drrie
  WHERE drrie.active_ind=1
   AND drrie.environment_id=drrc_env_id
   AND drrie.req_type="CODE"
  HEAD REPORT
   drrc_req_met_cnt = 0
  DETAIL
   drrc_req_met_cnt = (drrc_req_met_cnt+ 1)
   IF (mod(drrc_req_met_cnt,100)=1)
    stat = alterlist(rreqmts->req_met,(drrc_req_met_cnt+ 99))
   ENDIF
   rreqmts->req_met[drrc_req_met_cnt].req_name = drrie.req_name, rreqmts->req_met[drrc_req_met_cnt].
   req_type = drrie.req_type, rreqmts->req_met[drrc_req_met_cnt].req_version_nbr = drrie
   .req_version_nbr
  FOOT REPORT
   stat = alterlist(rreqmts->req_met,drrc_req_met_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO drrc_exit
 ENDIF
 FOR (drrc_i = 1 TO drrc_table_cnt)
   SET dm_err->eproc = concat("Evaluating requirements for table: ",rreqmts->tbl[drrc_i].table_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   FOR (drrc_j = 1 TO size(rreqmts->tbl[drrc_i].ovr_inst,5))
     SET drrc_req_met_sum = 0
     SET drrc_temp_size = size(rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req,5)
     FOR (drrc_k = 1 TO drrc_temp_size)
       CASE (rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req[drrc_k].req_type)
        OF "SCHEMA":
         IF ((rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req[drrc_k].req_version_nbr <= rreqmts->tbl[
         drrc_i].schema_instance))
          SET rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req[drrc_k].req_met_ind = 1
          SET drrc_req_met_sum = (drrc_req_met_sum+ 1)
         ELSE
          SET drrc_k = drrc_temp_size
         ENDIF
        ELSE
         SELECT INTO "nl:"
          FROM (dummyt d  WITH seq = value(drrc_req_met_cnt))
          WHERE (rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req[drrc_k].req_name=rreqmts->req_met[d.seq].
          req_name)
           AND (rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req[drrc_k].req_type=rreqmts->req_met[d.seq].
          req_type)
           AND (rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req[drrc_k].req_version_nbr <= rreqmts->
          req_met[d.seq].req_version_nbr)
          HEAD REPORT
           drrc_req_met_sum = (drrc_req_met_sum+ 1)
          DETAIL
           rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req[drrc_k].req_met_ind = 1
          WITH nocounter
         ;end select
         IF ((rreqmts->tbl[drrc_i].ovr_inst[drrc_j].req[drrc_k].req_met_ind=0))
          SET drrc_k = drrc_temp_size
         ENDIF
       ENDCASE
     ENDFOR
     IF (drrc_req_met_sum=drrc_temp_size)
      SET rreqmts->tbl[drrc_i].new_ovr_inst_met = rreqmts->tbl[drrc_i].ovr_inst[drrc_j].override_inst
      IF ((rreqmts->tbl[drrc_i].new_ovr_inst_met != rreqmts->tbl[drrc_i].old_ovr_inst_met))
       SET rreqmts->refresh_ind = 1
       SET rreqmts->new_inst_met_ind = 1
       SET dm_err->eproc = "New override instance was met. Requirements will be refreshed."
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      SET drrc_j = size(rreqmts->tbl[drrc_i].ovr_inst,5)
     ENDIF
   ENDFOR
 ENDFOR
 SUBROUTINE drrc_disp_info(s_msg)
   CALL echo(dm_err->asterisk_line)
   CALL echo(s_msg)
   CALL echo(dm_err->asterisk_line)
   RETURN(0)
 END ;Subroutine
#drrc_exit
 SET dm_err->eproc = "End dm2_rdds_req_chk"
 CALL final_disp_msg("drrc")
END GO
