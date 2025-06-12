CREATE PROGRAM dm2_set_clukey_to_float:dba
 DECLARE dan_insert_app_nodes(null) = i2
 DECLARE dan_get_app_nodes(null) = i2
 DECLARE dan_get_missing_cron_node(null) = vc
 DECLARE dan_bypass_node_check(dbnc_bypass_check=i4(ref)) = i2
 IF ((validate(dan_nodes_list->cnt,- (1))=- (1))
  AND (validate(dan_nodes_list->cnt,- (2))=- (2)))
  RECORD dan_nodes_list(
    1 cnt = i2
    1 domain_name = vc
    1 qual[*]
      2 node_name = vc
  )
 ENDIF
 SUBROUTINE dan_insert_app_nodes(null)
   DECLARE dan_file = vc WITH protect, noconstant("")
   DECLARE dan_cmd = vc WITH protect, noconstant("")
   DECLARE dan_found_start = i2 WITH protect, noconstant(0)
   DECLARE dan_found_node_name = i2 WITH protect, noconstant(0)
   DECLARE dan_errfile = vc WITH protect, noconstant("")
   DECLARE dan_found_curnode = i2 WITH protect, noconstant(0)
   DECLARE dan_idx = i4 WITH protect, noconstant(0)
   DECLARE dan_pos = i4 WITH protect, noconstant(0)
   DECLARE dan_str = vc WITH protect, noconstant("")
   DECLARE dan_domain = vc WITH protect, noconstant("")
   FREE RECORD dian_list
   RECORD dian_list(
     1 cnt = i4
     1 qual[*]
       2 node_name = vc
   )
   IF (get_unique_file("get_nodes",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dan_file = dm_err->unique_fname
   ENDIF
   SET dan_domain = cnvtupper(trim(logical("environment")))
   SET dm_err->eproc = concat("Create file to obtain listing of nodes from DNS:",dan_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dan_file)
    DETAIL
     CALL print(concat("$cer_exe/testdns ",dan_domain)), row + 1
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(concat("chmod 777 $CCLUSERDIR/",dan_file))=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain node listing from DNS."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dan_cmd = concat(". $CCLUSERDIR/",dan_file)
   IF (dm2_push_dcl(dan_cmd)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (((findstring("bad command",dm_err->errtext,1,1) > 0) OR (findstring("Domain lookup failed",
    dm_err->errtext,1,1) > 0)) )
    SET dm_err->emsg = concat("Error getting ",dan_domain," nodes from DNS:",dan_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dan_errfile = dm_err->errfile
   SET dm_err->eproc = concat("Parse node listing from:",dan_errfile)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dgnd_data_file dan_errfile
   FREE DEFINE rtl
   DEFINE rtl "dgnd_data_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     IF ((dm_err->debug_flag > 0))
      CALL echo(t.line)
     ENDIF
     IF (dan_found_node_name=1)
      IF (findstring(".",t.line,dan_pos,0) > 0)
       dan_str = trim(cnvtupper(substring(1,(findstring(".",t.line,dan_pos,0) - dan_pos),t.line)))
      ELSE
       dan_str = substring(dan_pos,(findstring(" ",t.line,dan_pos,0) - dan_pos),t.line)
      ENDIF
      dian_list->cnt = (dian_list->cnt+ 1), stat = alterlist(dian_list->qual,dian_list->cnt),
      dian_list->qual[dian_list->cnt].node_name = cnvtupper(trim(dan_str,3))
      IF (trim(cnvtupper(dan_str))=trim(cnvtupper(curnode)))
       dan_found_curnode = 1
      ENDIF
     ENDIF
     IF (dan_found_start=1
      AND dan_found_node_name=0)
      dan_pos = findstring("Node Name",t.line,1,0)
      IF (dan_pos > 0)
       dan_found_node_name = 1
      ENDIF
     ENDIF
     IF (findstring("DNS SRV lookup for Cerner domain",t.line,1,1) > 0)
      dan_found_start = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dian_list)
   ENDIF
   IF (dan_found_curnode=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Current node,",cnvtupper(trim(curnode)),
     " not found via testdns command.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Delete existing node list and node count information in dm_info"
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info
    WHERE info_domain=concat("DM2_APP_NODES_",dan_domain)
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   FOR (dan_idx = 1 TO dian_list->cnt)
     SET dm_err->eproc = "Add node list information into dm_info"
     INSERT  FROM dm_info
      SET info_domain = concat("DM2_APP_NODES_",dan_domain), info_name = cnvtupper(dian_list->qual[
        dan_idx].node_name), updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dan_get_app_nodes(null)
   DECLARE dgan_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgan_idx = i4 WITH protect, noconstant(0)
   DECLARE dgan_pos = i4 WITH protect, noconstant(0)
   DECLARE dgan_override_ind = i4 WITH protect, noconstant(0)
   IF ((dan_nodes_list->cnt > 0))
    SET dan_nodes_list->cnt = 0
    SET dan_nodes_list->domain_name = ""
    SET stat = alterlist(dan_nodes_list->qual,0)
   ENDIF
   SET dan_nodes_list->domain_name = cnvtupper(trim(logical("environment")))
   SET dm_err->eproc = concat("Querying node override information into dm_info")
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgan_idx = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=concat("DM2_APP_NODES_OVERRIDE_",dan_nodes_list->domain_name)
    DETAIL
     dgan_pos = locateval(dgan_idx,1,dan_nodes_list->cnt,cnvtupper(d.info_name),cnvtupper(
       dan_nodes_list->qual[dgan_idx].node_name))
     IF (dgan_pos=0)
      dan_nodes_list->cnt = (dan_nodes_list->cnt+ 1), stat = alterlist(dan_nodes_list->qual,
       dan_nodes_list->cnt), dan_nodes_list->qual[dan_nodes_list->cnt].node_name = cnvtupper(d
       .info_name),
      dgan_override_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dan_nodes_list)
   ENDIF
   IF (dgan_override_ind=0)
    SET dgan_idx = 0
    SET dm_err->eproc = concat("Loading nodes in to global record dan_nodes_list")
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=concat("DM2_APP_NODES_",dan_nodes_list->domain_name)
     DETAIL
      dgan_pos = locateval(dgan_idx,1,dan_nodes_list->cnt,cnvtupper(d.info_name),cnvtupper(
        dan_nodes_list->qual[dgan_idx].node_name))
      IF (dgan_pos=0)
       dan_nodes_list->cnt = (dan_nodes_list->cnt+ 1), stat = alterlist(dan_nodes_list->qual,
        dan_nodes_list->cnt), dan_nodes_list->qual[dan_nodes_list->cnt].node_name = cnvtupper(d
        .info_name)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dan_nodes_list)
   ENDIF
   IF ((dan_nodes_list->cnt=0))
    SET dm_err->emsg = "No dm_info rows found to load into global record."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dan_nodes_list->cnt=1)
    AND (dan_nodes_list->qual[dan_nodes_list->cnt].node_name != cnvtupper(curnode)))
    SET dm_err->emsg = "Override node name does not match the curnode."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dan_get_missing_cron_node(null)
   DECLARE dmcn_nodes = vc WITH protect, noconstant("")
   DECLARE dmcn_cnt = i4 WITH protect, noconstant(0)
   DECLARE dmcn_dt_tm = f8 WITH protect, noconstant(0.0)
   DECLARE dmcn_idx = i4 WITH protect, noconstant(0)
   IF ((dan_nodes_list->cnt=0))
    IF (dan_get_app_nodes(null)=0)
     SET dmcn_nodes = "ERROR"
     RETURN(dmcn_nodes)
    ENDIF
   ENDIF
   FOR (dmcn_idx = 1 TO dan_nodes_list->cnt)
     SET dm_err->eproc = concat("Check dm_info for cronjob entry for node- ",cnvtupper(dan_nodes_list
       ->qual[dmcn_idx].node_name))
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain=concat("DM2_SYNC_APP_TABLEDEF_",dan_nodes_list->domain_name)
       AND di.info_name=cnvtupper(dan_nodes_list->qual[dmcn_idx].node_name)
      DETAIL
       dmcn_dt_tm = cnvtdatetime(di.info_date)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dmcn_nodes = "ERROR"
      RETURN(dmcn_nodes)
     ENDIF
     IF (((curqual=0) OR (datetimediff(cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      cnvtdatetimeutc(cnvtdatetime(dmcn_dt_tm)),4) > 60)) )
      IF (dmcn_cnt=0)
       SET dmcn_nodes = cnvtupper(dan_nodes_list->qual[dmcn_idx].node_name)
       SET dmcn_cnt = (dmcn_cnt+ 1)
      ELSE
       SET dmcn_nodes = concat(dmcn_nodes,",",cnvtupper(dan_nodes_list->qual[dmcn_idx].node_name))
      ENDIF
     ENDIF
     SET dmcn_dt_tm = 0.0
   ENDFOR
   RETURN(dmcn_nodes)
 END ;Subroutine
 SUBROUTINE dan_bypass_node_check(dbnc_bypass_check)
   DECLARE dbnc_domain = vc WITH protect, noconstant("")
   SET dbnc_domain = cnvtupper(trim(logical("environment")))
   SET dbnc_bypass_check = 0
   IF (dbnc_domain="ADMIN")
    SET dm_err->eproc = concat("Query dm_info for bypass value for domain ",dbnc_domain)
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat("DM2_BYPASS_NODE_CHECK_",dbnc_domain)
      AND di.info_number=1
     DETAIL
      dbnc_bypass_check = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
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
 FREE RECORD dsctf_tab_list
 RECORD dsctf_tab_list(
   1 cnt = i4
   1 tbl[*]
     2 table_name = vc
 )
 DECLARE dsctf_logfile = vc WITH protect, constant("dm2_set_clukey")
 DECLARE dsctf_cnt_ret = i4 WITH protect, noconstant(0)
 DECLARE dsctf_idx = i4 WITH protect, noconstant(0)
 DECLARE dsctf_idx2 = i4 WITH protect, noconstant(0)
 DECLARE dsctf_owner = vc WITH protect, constant("V500")
 DECLARE dsctf_column = vc WITH protect, constant("CLU_SUBKEY1_FLAG")
 DECLARE dsctf_info_domain = vc WITH protect, constant("DM2_SINGLE_TABLE_ORAGEN")
 DECLARE dsctf_chk_cnt = i4 WITH protect, noconstant(0)
 DECLARE dsctf_allclear_ind = i4 WITH protect, noconstant(0)
 DECLARE dsctf_bypass_node_check = i4 WITH protect, noconstant(0)
 DECLARE dsctf_err_detected = i2 WITH protect, noconstant(0)
 DECLARE dsctf_err_msg = vc WITH protect, noconstant("")
 DECLARE dsctf_type = vc WITH protect, noconstant("")
 IF (check_logfile(dsctf_logfile,".log","DM2_SET_CLU_TO_FLOAT Logfile")=0)
  GO TO exit_program
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dm2_set_clukey_to_float"
 SET dm_err->eproc = "Starting dm2_set_clukey_to_float"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dsctf_tab_list->cnt = 0
 SET dm_err->eproc = "Load tables containing CLU_SUBKEY1_FLAG column"
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 SELECT INTO "nl:"
  FROM dba_tab_columns d
  WHERE d.owner=dsctf_owner
   AND d.column_name=dsctf_column
  DETAIL
   dsctf_tab_list->cnt = (dsctf_tab_list->cnt+ 1), stat = alterlist(dsctf_tab_list->tbl,
    dsctf_tab_list->cnt), dsctf_tab_list->tbl[dsctf_tab_list->cnt].table_name = trim(d.table_name)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((dsctf_tab_list->cnt=0))
  SET dm_err->eproc = "No tables present which contain CLU_SUBKEY1_FLAG column"
  CALL disp_msg(" ",dm_err->logfile,0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success: ",dm_err->eproc)
  GO TO exit_program
 ENDIF
 IF (dm2_set_inhouse_domain(null)=0)
  GO TO exit_program
 ENDIF
 IF ((inhouse_misc->inhouse_domain=1))
  IF (dan_insert_app_nodes(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 SET dm_err->eproc = "Remove existing nbr_to_float rows for CLU_SUBKEY1_FLAG"
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 DELETE  FROM dm_info di
  WHERE di.info_domain="DM2_NBR_TO_FLOAT"
   AND di.info_name IN (
  (SELECT
   concat(trim(d.table_name),"-",trim(d.column_name))
   FROM dba_tab_columns d
   WHERE d.owner=dsctf_owner
    AND d.column_name=dsctf_column))
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc) != 0)
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 SET dm_err->eproc = "Check if app node sync bypass is enabled"
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 IF (dan_bypass_node_check(dsctf_bypass_node_check)=0)
  GO TO exit_program
 ENDIF
 IF (dsctf_bypass_node_check=1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Domain has excluded application node registration. Cannot continue."
  SET dm_err->user_action =
  "Support ticket is required to determine how to continue. Do not autosuccess."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Check for multi-app node"
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 IF ((dan_nodes_list->cnt=0))
  IF (dan_get_app_nodes(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dan_nodes_list->cnt > 1))
  SET dm_err->eproc = "Denote tables for single table oragen"
  IF ((dm_err->debug_flag > 0))
   CALL disp_msg("",dm_err->logfile,0)
  ENDIF
  FOR (dsctf_idx = 1 TO dan_nodes_list->cnt)
   FOR (dsctf_idx2 = 1 TO dsctf_tab_list->cnt)
     SET dm_err->eproc = concat("Checking if single table oragen row exists for ",dsctf_tab_list->
      tbl[dsctf_idx2].table_name," on ",dan_nodes_list->qual[dsctf_idx].node_name)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SET dsctf_cnt_ret = 0
     SELECT INTO "nl:"
      qryclu_cnt_ret = count(*)
      FROM dm_info di
      WHERE di.info_domain=dsctf_info_domain
       AND di.info_name=concat(dsctf_owner,".",dsctf_tab_list->tbl[dsctf_idx2].table_name,".",
       dan_nodes_list->qual[dsctf_idx].node_name)
      DETAIL
       dsctf_cnt_ret = qryclu_cnt_ret
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (dsctf_cnt_ret=0)
      SET dm_err->eproc = concat("Inserting single table oragen row for ",dsctf_tab_list->tbl[
       dsctf_idx2].table_name," on ",dan_nodes_list->qual[dsctf_idx].node_name)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      INSERT  FROM dm_info di
       SET di.info_domain = dsctf_info_domain, di.info_name = concat(dsctf_owner,".",dsctf_tab_list->
         tbl[dsctf_idx2].table_name,".",dan_nodes_list->qual[dsctf_idx].node_name), di.info_char =
        null,
        di.info_number = 0
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc) != 0)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
     ELSE
      SET dm_err->eproc = concat("Resetting single-table oragen row ",dsctf_tab_list->tbl[dsctf_idx2]
       .table_name)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      UPDATE  FROM dm_info di
       SET di.info_char = null, di.info_number = 0
       WHERE di.info_domain=dsctf_info_domain
        AND di.info_name=concat(dsctf_owner,".",dsctf_tab_list->tbl[dsctf_idx2].table_name,".",
        dan_nodes_list->qual[dsctf_idx].node_name)
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc) != 0)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
     ENDIF
   ENDFOR
   COMMIT
  ENDFOR
  SET dsctf_err_detected = 0
  WHILE (dsctf_chk_cnt < 30
   AND dsctf_allclear_ind=0)
    SET dsctf_chk_cnt = (dsctf_chk_cnt+ 1)
    SET dm_err->eproc = concat("Check if all oragens have processed. Attempt(",trim(cnvtstring(
       dsctf_chk_cnt)),")")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     qry_rowcnt = count(*)
     FROM dm_info di
     WHERE di.info_domain=dsctf_info_domain
     DETAIL
      IF (qry_rowcnt > 0)
       dsctf_allclear_ind = 0
      ELSE
       dsctf_allclear_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (dsctf_allclear_ind=0)
     SET dm_err->eproc = concat("Checking for failures reported from oragen")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain=dsctf_info_domain
       AND di.info_number=1
      DETAIL
       dsctf_err_msg = di.info_char, dm_err->user_action = concat(
        "Check dm2syncapp_tbldef*log files for ",trim(di.info_name)," oragen failure details"),
       dsctf_err_detected = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (dsctf_err_detected=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = dsctf_err_msg
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = concat(
      "Pausing 30 seconds to allow time for oragen cronjob to complete on all nodes.")
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL pause(30)
    ENDIF
  ENDWHILE
  IF (dsctf_allclear_ind=0)
   SET dm_err->emsg =
   "dm2_exec_sync_app_tabledef_wrapper.ksh appears to not be processing the oragen requests."
   SET dm_err->user_action =
   "Ensure dm2_exec_sync_app_tabledef_wrapper.ksh is scheduled in root crontab on all app nodes"
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ELSE
   SET dm_err->eproc = concat("All oragen operations processed successfully.")
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
 ELSE
  SET dm_err->eproc = concat("Oragen each table containing CLU_SUBKEY1_FLAG column")
  IF ((dm_err->debug_flag > 0))
   CALL disp_msg("",dm_err->logfile,0)
  ENDIF
  FOR (dsctf_idx = 1 TO dsctf_tab_list->cnt)
   EXECUTE oragen3 dsctf_tab_list->tbl[dsctf_idx].table_name
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  ENDFOR
 ENDIF
 FOR (dsctf_idx = 1 TO dsctf_tab_list->cnt)
   SET dm_err->eproc = concat("Verify ccl definition updated to F8 for CLU_SUBKEY1_FLAG column")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dsctf_type = ""
   SELECT INTO "nl:"
    FROM dtable t,
     dtableattr ta,
     dtableattrl tl
    PLAN (t
     WHERE t.table_name=cnvtupper(dsctf_tab_list->tbl[dsctf_idx].table_name))
     JOIN (ta
     WHERE t.table_name=ta.table_name)
     JOIN (tl
     WHERE tl.structtype != "K"
      AND btest(tl.stat,11)=0
      AND btest(tl.stat,9)=0
      AND btest(tl.stat,10)=0
      AND tl.attr_name="CLU_SUBKEY1_FLAG")
    DETAIL
     dsctf_type = concat(tl.type,trim(cnvtstring(tl.len)))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (cnvtupper(dsctf_type) != "F8")
    SET dm_err->emsg = concat("CCL definition for ",dsctf_tab_list->tbl[dsctf_idx].table_name,
     " was not updated to F8. Type returned: ",dsctf_type)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Success: dm2_set_clukey_to_float completed with success"
#exit_program
 IF ((dm_err->err_ind=1))
  SET readme_data->message = concat(dm_err->eproc,":",dm_err->emsg)
  SET readme_data->status = "F"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ELSE
  SET dm_err->eproc = "dm2_set_clukey_to_float completed successfully"
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SET dm_err->eproc = "Ending script dm2_set_clukey_to_float"
 CALL final_disp_msg("dm2_set_clukey_to_float")
END GO
