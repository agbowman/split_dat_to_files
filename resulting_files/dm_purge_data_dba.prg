CREATE PROGRAM dm_purge_data:dba
 DECLARE output_plan(i_statement_id=vc,i_file=vc,i_debug_str=vc) = null
 DECLARE sbr_fetch_starting_id(null) = f8
 DECLARE sbr_update_starting_id(sbr_newid=f8) = null
 DECLARE sbr_delete_starting_id(null) = null
 DECLARE sbr_getrowidnotexists(sbr_whereclause=vc,sbr_tablealias=vc) = vc
 SUBROUTINE output_plan(i_statement_id,i_file,i_debug_str)
   CALL echo(i_file)
   SELECT INTO value(i_file)
    x = substring(1,100,i_debug_str)
    FROM dual
    DETAIL
     x
    WITH maxcol = 130
   ;end select
   FOR (i = 2 TO ceil((size(i_debug_str)/ 100.0)))
     SELECT INTO value(i_file)
      x = substring((1+ ((i - 1) * 100)),100,i_debug_str)
      FROM dual
      DETAIL
       x
      WITH maxcol = 130, append
     ;end select
   ENDFOR
   SELECT INTO value(i_file)
    x = fillstring(100,"=")
    FROM dual
    DETAIL
     x
    WITH maxcol = 130, append
   ;end select
   SELECT INTO value(i_file)
    dm_ind = nullind(dm.index_name), p.statement_id, p.id,
    p.parent_id, p.position, p.operation,
    p.options, p.object_name, dm.table_name,
    dm.index_name, dm.column_position, dm.uniqueness,
    colname = substring(1,30,dm.column_name)
    FROM plan_table p,
     dm_user_ind_columns dm
    PLAN (p
     WHERE p.statement_id=patstring(i_statement_id))
     JOIN (dm
     WHERE outerjoin(p.object_name)=dm.index_name)
    ORDER BY p.statement_id, p.id, dm.index_name,
     dm.column_position
    HEAD REPORT
     indent = 0, line = fillstring(100,"=")
    HEAD p.statement_id
     "PLAN STATEMENT FOR ", p.statement_id, row + 1,
     line, row + 1, indent = 0
    HEAD p.id
     indent = (indent+ 1), col 0, p.id"#####",
     col + 1, col + indent, indent"###",
     ")", p.operation, col + 1,
     p.options, col + 1, p.object_name,
     col + 1
    DETAIL
     IF (dm_ind=0)
      IF (dm.column_position=1)
       row + 1, col + (indent+ 10), ">>>",
       col + 1, dm.uniqueness, col + 1
      ELSE
       ","
      ENDIF
      CALL print(trim(colname))
     ENDIF
    FOOT  p.id
     row + 1
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 400, append
   ;end select
 END ;Subroutine
 SUBROUTINE sbr_fetch_starting_id(null)
   DECLARE sbr_startingid = f8 WITH protect, noconstant(1.0)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   IF (batch_ndx=1)
    RETURN(1.0)
   ENDIF
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    DETAIL
     sbr_startingid = di.info_long_id
    WITH nocounter
   ;end select
   RETURN(sbr_startingid)
 END ;Subroutine
 SUBROUTINE sbr_update_starting_id(sbr_newid)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   UPDATE  FROM dm_info di
    SET di.info_long_id = sbr_newid, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM PURGE RESUME", di.info_name = sbr_infoname, di.info_long_id = sbr_newid,
      di.info_date = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx, di
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE sbr_delete_starting_id(null)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end delete
   COMMIT
 END ;Subroutine
 SUBROUTINE sbr_getrowidnotexists(sbr_whereclause,sbr_tablealias)
   IF ((jobs->data[job_ndx].purge_flag != c_audit))
    RETURN(sbr_whereclause)
   ENDIF
   DECLARE sbr_newwhereclause = vc WITH protect, noconstant("")
   SET sbr_newwhereclause = concat(sbr_whereclause,
    " and NOT EXISTS (select rowidtbl.purge_table_rowid ","from dm_purge_rowid_list_gttp rowidtbl ",
    "where rowidtbl.purge_table_rowid = ",sbr_tablealias,
    ".rowid)")
   RETURN(sbr_newwhereclause)
 END ;Subroutine
 DECLARE dctx_set_context(dsc_i_attr_name=vc,dsc_i_value=vc) = i2
 DECLARE dctx_restore_prev_contexts(null) = i2
 IF ((validate(dm2_prev_ctxt->attr_cnt,- (1))=- (1))
  AND (validate(dm2_prev_ctxt->attr_cnt,- (2))=- (2)))
  RECORD dm2_prev_ctxt(
    1 attr_cnt = i4
    1 qual[*]
      2 attr_name = vc
      2 attr_value = vc
  )
  SET dm2_prev_ctxt->attr_cnt = 0
 ENDIF
 SUBROUTINE dctx_set_context(dsc_i_attr_name,dsc_i_value)
   DECLARE dsc_attrib_idx = i4 WITH protect, noconstant(0)
   DECLARE dsc_prev_err_ind = i2 WITH protect, noconstant(0)
   SET dsc_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   EXECUTE dm2_set_context value(dsc_i_attr_name), value(dsc_i_value)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    SET dsc_attrib_idx = locateval(dsc_attrib_idx,1,dm2_prev_ctxt->attr_cnt,dsc_i_attr_name,
     dm2_prev_ctxt->qual[dsc_attrib_idx].attr_name)
    IF (dsc_attrib_idx=0)
     SET dm2_prev_ctxt->attr_cnt = (dm2_prev_ctxt->attr_cnt+ 1)
     SET stat = alterlist(dm2_prev_ctxt->qual,dm2_prev_ctxt->attr_cnt)
     SET dm2_prev_ctxt->qual[dm2_prev_ctxt->attr_cnt].attr_name = dsc_i_attr_name
     SET dm2_prev_ctxt->qual[dm2_prev_ctxt->attr_cnt].attr_value = dsc_i_value
    ELSE
     SET dm2_prev_ctxt->qual[dsc_attrib_idx].attr_value = dsc_i_value
    ENDIF
    IF (dsc_prev_err_ind=1)
     SET dm_err->err_ind = 1
    ENDIF
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dctx_restore_prev_contexts(null)
   DECLARE drpc_cnt = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dm2_prev_ctxt)
   ENDIF
   FOR (drpc_cnt = 1 TO dm2_prev_ctxt->attr_cnt)
    EXECUTE dm2_set_context value(dm2_prev_ctxt->qual[drpc_cnt].attr_name), value(dm2_prev_ctxt->
     qual[drpc_cnt].attr_value)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDFOR
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
 IF (validate(request->batch_selection,"-1")="-1")
  FREE RECORD request
  RECORD request(
    1 batch_selection = vc
  )
 ENDIF
 FREE RECORD parser_child
 RECORD parser_child(
   1 max_parser_cnt = i4
   1 next_row_to_purge = i4
 )
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="PURGE PARSER COUNT"
  DETAIL
   parser_child->max_parser_cnt = d.info_number
  WITH nocounter
 ;end select
 IF ((parser_child->max_parser_cnt <= 0))
  SET parser_child->max_parser_cnt = 5000
 ENDIF
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 RECORD jobs(
   1 data[*]
     2 job_id = f8
     2 max_rows = i4
     2 purge_flag = i2
     2 program_str = vc
     2 template_nbr = f8
     2 last_run_date = vc
     2 name = vc
     2 tokens[*]
       3 token_str = vc
       3 value = vc
 )
 IF (validate(ranges,"-1")="-1")
  FREE RECORD ranges
  RECORD ranges(
    1 sets[*]
      2 where_chunk = vc
  )
 ENDIF
 DECLARE row_limit = f8
 DECLARE batch_num = i4
 DECLARE max_rows = i4
 DECLARE no_rows = i2
 DECLARE v_job_cnt = i4
 DECLARE v_log_id = f8
 DECLARE v_where_string = vc
 DECLARE v_where_chunk = vc
 DECLARE dpd_run_id = f8
 DECLARE dpd_info_name = vc
 DECLARE dpd_info_char = vc
 DECLARE dpd_tok_cnt = i4
 DECLARE v_start_date = vc
 DECLARE v_purging_sum = i4
 DECLARE batch_ndx = i4
 DECLARE v_err_code = i4
 DECLARE v_errmsg = c255
 DECLARE v_resized_max_rows = i4
 DECLARE dpo_flag = i2
 DECLARE dpd_modact_allowed_ind = i2 WITH protect, noconstant(0)
 DECLARE dpd_original_module = vc WITH protect, noconstant("")
 DECLARE dpd_original_action = vc WITH protect, noconstant("")
 DECLARE v_logging_rowid_key = vc WITH protect, constant("ROWID_LOOKUP_TM")
 DECLARE v_logging_purge_prefix = vc WITH protect, constant("TBL_TM_")
 DECLARE v_logging_idx_prefix = vc WITH protect, constant("IDX_TM_")
 DECLARE parse_where_chunk(i_chunk=vc) = vc
 DECLARE parse_batch_selection(i_batch_string=vc) = null
 SET c_df = "YYYYMMDDHHMMSScc;;d"
 SET c_del_high_log = 1
 SET c_del_dtl_log = 2
 SET c_audit = 3
 SET c_ptf_delete = 1
 SET c_ptf_update = 2
 SET c_active = 1
 SET c_inactive = 2
 SET c_tmpl_changed = 3
 SET c_sf_success = 1
 SET c_sf_failed = 2
 IF (((currev=8
  AND currevminor > 6) OR (currev > 8)) )
  SET dpd_modact_allowed_ind = 1
 ENDIF
 IF (dpd_modact_allowed_ind)
  DECLARE set_module(module_name=vc,action_name=vc) = null WITH sql =
  "SYS.DBMS_APPLICATION_INFO.SET_MODULE", parameter
  SELECT INTO "nl:"
   vs.module, vs.action
   FROM v$session vs
   WHERE vs.audsid=cnvtreal(currdbhandle)
   HEAD REPORT
    dpd_original_module = vs.module, dpd_original_action = vs.action
   WITH nocounter, format
  ;end select
  CALL set_module("DMPURGE:DM_PURGE_DATA","MAIN")
 ENDIF
 SET v_job_cnt = 0
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="PURGE BATCH ROWS"
  DETAIL
   row_limit = d.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET row_limit = 10000.0
  INSERT  FROM dm_info
   SET info_domain = "DATA MANAGEMENT", info_name = "PURGE BATCH ROWS", info_number = 10000.0
  ;end insert
  COMMIT
 ENDIF
 CALL parse_batch_selection(request->batch_selection)
 FOR (range_ndx = 1 TO size(ranges->sets,5))
   SELECT DISTINCT INTO "nl:"
    pj.job_id, pj.max_rows, pj.purge_flag,
    pj.template_nbr, pt.program_str, last_run_date = format(pj.last_run_dt_tm,c_df)
    FROM dm_purge_job pj,
     dm_purge_template pt
    WHERE pj.active_flag=c_active
     AND pt.template_nbr=pj.template_nbr
     AND pt.active_ind=1
     AND (pt.schema_dt_tm=
    (SELECT
     max(pt1.schema_dt_tm)
     FROM dm_purge_template pt1
     WHERE pt1.template_nbr=pj.template_nbr))
     AND parser(ranges->sets[range_ndx].where_chunk)
     AND pt.program_str != "XNT*"
    DETAIL
     v_job_cnt = (v_job_cnt+ 1)
     IF (mod(v_job_cnt,10)=1)
      stat = alterlist(jobs->data,(v_job_cnt+ 9))
     ENDIF
     jobs->data[v_job_cnt].job_id = pj.job_id, jobs->data[v_job_cnt].template_nbr = pj.template_nbr,
     jobs->data[v_job_cnt].max_rows = pj.max_rows,
     jobs->data[v_job_cnt].purge_flag = pj.purge_flag, jobs->data[v_job_cnt].program_str = pt
     .program_str, jobs->data[v_job_cnt].last_run_date = last_run_date,
     jobs->data[v_job_cnt].name = pt.name
    WITH nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(jobs->data,v_job_cnt)
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echorecord(jobs)
 ENDIF
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echo("Creating context")
 ENDIF
 IF (dctx_set_context("MILLPURGE_APPL_NBR","14900") != 1)
  IF (validate(request->debug_mode,"Z") != "Z")
   CALL echo("Failed creating context")
  ENDIF
  GO TO end_program
 ENDIF
 IF (v_job_cnt > 0)
  SELECT INTO "nl:"
   pjt.token_str, pjt.value
   FROM dm_purge_job_token pjt,
    (dummyt d  WITH seq = value(size(jobs->data,5)))
   PLAN (d)
    JOIN (pjt
    WHERE (pjt.job_id=jobs->data[d.seq].job_id))
   ORDER BY pjt.job_id
   HEAD pjt.job_id
    tok_cnt = 0
   DETAIL
    tok_cnt = (tok_cnt+ 1)
    IF (mod(tok_cnt,10)=1)
     stat = alterlist(jobs->data[d.seq].tokens,(tok_cnt+ 9))
    ENDIF
    jobs->data[d.seq].tokens[tok_cnt].token_str = pjt.token_str, jobs->data[d.seq].tokens[tok_cnt].
    value = pjt.value
   FOOT REPORT
    stat = alterlist(jobs->data[d.seq].tokens,tok_cnt)
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM dm_info di
  WHERE di.info_domain="DM PURGE INFO"
   AND di.info_name="JOB OVERVIEW FOR RUN*"
   AND di.info_date <= cnvtdatetime((curdate - 30),curtime3)
   AND di.info_long_id=0
  WITH nocounter
 ;end delete
 COMMIT
 SET dpd_run_id = 0
 SELECT INTO "nl:"
  nextseq = seq(dm_clinical_seq,nextval)
  FROM dual
  DETAIL
   dpd_run_id = nextseq
  WITH nocounter
 ;end select
 FOR (job_ndx = 1 TO size(jobs->data,5))
   SET dpd_info_name = build("JOB OVERVIEW FOR RUN",dpd_run_id,jobs->data[job_ndx].job_id)
   SET v_log_id = 0
   SELECT INTO "nl:"
    nextseq = seq(dm_clinical_seq,nextval)
    FROM dual
    DETAIL
     v_log_id = nextseq
    WITH nocounter
   ;end select
   IF (validate(request->debug_mode,"Z") != "Z")
    CALL echo(build("log_id = ",v_log_id))
   ENDIF
   IF (dpd_modact_allowed_ind)
    CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("MAIN:",
      cnvtstring(v_log_id)))
   ENDIF
   IF (cnvtupper(substring(1,3,jobs->data[job_ndx].program_str))="DPO")
    SET dpo_flag = 1
   ELSE
    SET dpo_flag = 0
   ENDIF
   IF (dpo_flag=1)
    SET batch_num = 1
   ELSE
    SET batch_num = ceil((value(jobs->data[job_ndx].max_rows)/ row_limit))
   ENDIF
   SET v_start_date = format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS.CC;;q")
   SET v_purging_sum = 0
   SET batch_ndx = 1
   IF ((((row_limit > jobs->data[job_ndx].max_rows)) OR (dpo_flag=1)) )
    SET max_rows = jobs->data[job_ndx].max_rows
   ELSE
    SET max_rows = row_limit
   ENDIF
   SET v_resized_max_rows = 0
   WHILE (batch_ndx <= batch_num)
     SET dpd_info_char = ""
     SET dpd_info_char = concat(jobs->data[job_ndx].name," - Job ",trim(cnvtstring(job_ndx))," of ",
      trim(cnvtstring(size(jobs->data,5))),
      "; pass ",trim(cnvtstring(batch_ndx))," started ",format(cnvtdatetime(curdate,curtime3),";;q"),
      "; job_id = ",
      build(jobs->data[job_ndx].job_id),"; template_nbr = ",build(jobs->data[job_ndx].template_nbr),
      "; program_str = ",jobs->data[job_ndx].program_str)
     FOR (dpd_tok_cnt = 1 TO size(jobs->data[job_ndx].tokens,5))
       IF (trim(jobs->data[job_ndx].tokens[dpd_tok_cnt].token_str) > " ")
        SET dpd_info_char = concat(dpd_info_char,"; ",jobs->data[job_ndx].tokens[dpd_tok_cnt].
         token_str," - answer = ",trim(cnvtstring(jobs->data[job_ndx].tokens[dpd_tok_cnt].value)))
       ENDIF
     ENDFOR
     SET dpd_info_char = concat(dpd_info_char,"; max_rows = ",trim(cnvtstring(jobs->data[job_ndx].
        max_rows)),"; rows_per_pass_limit = ",trim(cnvtstring(row_limit)),
      "; max_parser_cnt = ",trim(cnvtstring(parser_child->max_parser_cnt)),"; purge_flag = ")
     IF ((jobs->data[job_ndx].purge_flag=1))
      SET dpd_info_char = concat(dpd_info_char," Purge with high level logging")
     ELSEIF ((jobs->data[job_ndx].purge_flag=2))
      SET dpd_info_char = concat(dpd_info_char," Purge with table level logging")
     ELSEIF ((jobs->data[job_ndx].purge_flag=3))
      SET dpd_info_char = concat(dpd_info_char," Audit only")
     ENDIF
     SET dpd_info_char = concat(dpd_info_char,"; batch selection = ")
     IF (trim(request->batch_selection) > " ")
      SET dpd_info_char = concat(dpd_info_char,request->batch_selection)
     ELSE
      SET dpd_info_char = concat(dpd_info_char," None")
     ENDIF
     SET dpd_info_char = concat(dpd_info_char," ::PROGRAM INFO:: ")
     UPDATE  FROM dm_info di
      SET di.info_char = dpd_info_char
      WHERE di.info_domain="DM PURGE INFO"
       AND di.info_name=dpd_info_name
       AND di.info_number=dpd_run_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_domain = "DM PURGE INFO", di.info_name = dpd_info_name, di.info_number =
        dpd_run_id,
        di.info_date = cnvtdatetime(curdate,curtime3), di.info_char = dpd_info_char, di.info_long_id
         = cnvtreal(currdbhandle)
       WITH nocounter
      ;end insert
     ENDIF
     COMMIT
     EXECUTE dm_purge_data_child
     IF (((no_rows=1) OR (dpo_flag=1)) )
      SET batch_ndx = batch_num
     ELSEIF (v_resized_max_rows=1)
      SET batch_ndx = batch_num
     ELSEIF (v_err_code != 0)
      SET batch_ndx = batch_num
     ELSEIF (batch_ndx=batch_num)
      IF ((v_purging_sum > (jobs->data[job_ndx].max_rows - row_limit)))
       IF ((v_purging_sum < jobs->data[job_ndx].max_rows))
        SET batch_num = (batch_num+ 1)
        SET max_rows = (jobs->data[job_ndx].max_rows - v_purging_sum)
        SET v_resized_max_rows = 1
       ENDIF
      ELSE
       SET batch_num = (batch_num+ 1)
       SET max_rows = row_limit
      ENDIF
     ELSEIF ((v_purging_sum > (jobs->data[job_ndx].max_rows - row_limit)))
      SET max_rows = (jobs->data[job_ndx].max_rows - v_purging_sum)
      SET v_resized_max_rows = 1
     ENDIF
     IF (max_rows <= 0)
      SET batch_ndx = batch_num
     ELSE
      SET batch_ndx = (batch_ndx+ 1)
     ENDIF
   ENDWHILE
   IF ((jobs->data[job_ndx].purge_flag=c_audit)
    AND dpo_flag=0)
    CALL parser("rdb asis(^ TRUNCATE TABLE DM_PURGE_ROWID_LIST_GTTP ^) go")
    SET v_err_code = error(v_errmsg,1)
    IF (v_err_code != 0)
     SET i18nhandle = 0
     SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
     SET v_errmsg = uar_i18nbuildmessage(i18nhandle,"TRUNCATE_ERROR",
      "Failed in truncating ROWID table: %1","s",v_errmsg)
     UPDATE  FROM dm_purge_job_log jl
      SET jl.err_msg = v_errmsg, jl.err_code = v_err_code, jl.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       jl.updt_task = reqinfo->updt_task, jl.updt_cnt = (jl.updt_cnt+ 1), jl.updt_id = reqinfo->
       updt_id,
       jl.updt_applctx = reqinfo->updt_applctx
      WHERE jl.log_id=v_log_id
     ;end update
     COMMIT
    ENDIF
   ENDIF
   CALL sbr_delete_starting_id(null)
 ENDFOR
 GO TO end_program
#end_program
 SUBROUTINE parse_batch_selection(i_batch_string)
   DECLARE s_found_semi = i2
   DECLARE s_last_semi = i2
   DECLARE s_chunk_cnt = i2
   DECLARE s_temp_string = vc
   IF (i_batch_string="")
    SET stat = alterlist(ranges->sets,1)
    SET ranges->sets[1].where_chunk = "1=1"
    RETURN
   ENDIF
   SET s_chunk_cnt = 1
   SET s_last_semi = 0
   SET s_found_semi = findstring(";",i_batch_string)
   WHILE (s_found_semi != 0)
     SET s_temp_string = parse_where_chunk(substring((s_last_semi+ 1),((s_found_semi - 1) -
       s_last_semi),i_batch_string))
     IF (s_temp_string != "fail")
      SET stat = alterlist(ranges->sets,s_chunk_cnt)
      SET ranges->sets[s_chunk_cnt].where_chunk = s_temp_string
      SET s_chunk_cnt = (s_chunk_cnt+ 1)
     ELSE
      SET stat = initrec(ranges)
      RETURN
     ENDIF
     SET s_last_semi = s_found_semi
     SET s_found_semi = findstring(";",i_batch_string,(s_last_semi+ 1))
   ENDWHILE
   SET s_temp_string = parse_where_chunk(substring((s_last_semi+ 1),(size(i_batch_string,1) -
     s_last_semi),i_batch_string))
   IF (s_temp_string != "fail")
    SET stat = alterlist(ranges->sets,s_chunk_cnt)
    SET ranges->sets[s_chunk_cnt].where_chunk = s_temp_string
    SET s_chunk_cnt = (s_chunk_cnt+ 1)
   ELSE
    SET stat = initrec(ranges)
    RETURN
   ENDIF
   IF (s_chunk_cnt=1)
    SET stat = alterlist(ranges->sets,s_chunk_cnt)
    SET ranges->sets[s_chunk_cnt].where_chunk = "1=1"
   ENDIF
 END ;Subroutine
 SUBROUTINE parse_where_chunk(i_chunk)
   DECLARE s_found_comma = i2
   DECLARE s_num_string1 = vc
   DECLARE s_num_string2 = vc
   DECLARE s_num1 = i4
   DECLARE s_num2 = i4
   SET s_found_comma = findstring(",",i_chunk)
   IF (s_found_comma=0)
    RETURN("fail")
   ELSE
    SET s_num_string1 = substring(1,(s_found_comma - 1),i_chunk)
    SET s_num1 = cnvtint(s_num_string1)
    IF (s_num1=0)
     RETURN("fail")
    ELSE
     SET s_num_string2 = substring((s_found_comma+ 1),size(i_chunk,1),i_chunk)
     SET s_num2 = cnvtint(s_num_string2)
     IF (s_num2=0)
      RETURN("fail")
     ELSE
      RETURN(concat("pj.template_nbr between ",s_num_string1," and ",s_num_string2))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dpd_clean_run_row(null)
   IF (validate(request->debug_mode,"Z") != "Z")
    CALL echo(build("Reseting run indicator for this run: ",dpd_run_id))
   ENDIF
   UPDATE  FROM dm_info di
    SET di.info_long_id = 0.0
    WHERE di.info_domain="DM PURGE INFO"
     AND di.info_number=dpd_run_id
     AND di.info_long_id > 0.0
    WITH nocounter
   ;end update
   COMMIT
 END ;Subroutine
 CALL dpd_clean_run_row(null)
 FREE RECORD jobs
 FREE RECORD b_request
 FREE RECORD b_reply
 FREE RECORD stmt
 FREE RECORD parser_child
 FREE RECORD dpo_reply
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echo("Reseting context to zero")
 ENDIF
 IF (dctx_set_context("MILLPURGE_APPL_NBR","0") != 1)
  IF (validate(request->debug_mode,"Z") != "Z")
   CALL echo("Failed reseting context")
  ENDIF
 ENDIF
 IF (dpd_modact_allowed_ind)
  CALL set_module(dpd_original_module,dpd_original_action)
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
END GO
