CREATE PROGRAM dm_uncombine:dba
 SET trace = errorclear
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 xxx_combine_id[*]
      2 combine_id = f8
      2 parent_table = c50
      2 from_xxx_id = f8
      2 to_xxx_id = f8
      2 encntr_id = f8
    1 error[*]
      2 create_dt_tm = dq8
      2 parent_table = c50
      2 from_id = f8
      2 to_id = f8
      2 encntr_id = f8
      2 error_table = c32
      2 error_type = vc
      2 error_msg = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD rchildren(
   1 qual1[*]
     2 xxx_combine_det_id = f8
     2 entity_name = c32
     2 entity_id = f8
     2 combine_action_cd = f8
     2 attribute_name = c32
     2 prev_active_ind = i2
     2 prev_active_status_cd = f8
     2 prev_end_eff_dt_tm = dq8
     2 combine_desc_cd = f8
     2 to_record_ind = i2
     2 primary_key_attr = c30
     2 script_name = c50
     2 del_chg_id_ind = i2
     2 script_run_order = i4
     2 ignore_ind = i2
     2 ucb_audit_id = f8
 )
 RECORD rcombinedenc(
   1 qual[*]
     2 encntr_combine_id = f8
     2 from_encntr_id = f8
     2 to_encntr_id = f8
     2 from_encntr_id_ind = i2
     2 to_encntr_id_ind = i2
   1 err[*]
     2 msg = vc
 )
 DECLARE next_seq_val = f8
 DECLARE du_cmb_dt_tm_ind = i2 WITH protect
 DECLARE revdel = f8 WITH protect, noconstant(0.0)
 DECLARE revendeff = f8 WITH protect, noconstant(0.0)
 DECLARE ucb_group_id_pub = f8 WITH public, noconstant(0.0)
 DECLARE ucb_audit_id = f8 WITH protect, noconstant(0.0)
 DECLARE ucb_group_ndx = i4 WITH protect, noconstant(0)
 DECLARE noop = f8 WITH protect, noconstant(0.0)
 DECLARE ucb_cnt = i4 WITH protect, noconstant(0)
 DECLARE bypass_uid = f8 WITH protect, noconstant(0)
 SUBROUTINE chk_ccl_def_tbl_col(ctbl_name,ccol_name)
   SET tbl_ignore_ind = 0
   SET col_ignore_ind = 0
   SET tbl_ignore_ind = chk_ccl_def_tbl(ctbl_name)
   IF ((((tbl_ignore_ind=- (1))) OR (tbl_ignore_ind=1)) )
    RETURN(tbl_ignore_ind)
   ELSE
    SET col_ignore_ind = chk_ccl_def_col(ctbl_name,ccol_name)
    RETURN(col_ignore_ind)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE chk_ccl_def_tbl(dtbl_name)
   SET tbl_row_cnt = - (1)
   SELECT INTO "nl:"
    a.table_name
    FROM dtableattr a
    WHERE a.table_name=cnvtupper(trim(dtbl_name,3))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     table_name
     FROM user_tab_columns
     WHERE table_name=cnvtupper(trim(dtbl_name,3))
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(1)
    ENDIF
    SET tbl_row_cnt = chk_row_cnt(dtbl_name)
    IF (dm_debug_cmb)
     CALL echo(build("Table ",dtbl_name,"'s row_cnt =",tbl_row_cnt))
    ENDIF
    IF (((tbl_row_cnt=1) OR (tbl_row_cnt=0)) )
     RETURN(1)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE chk_ccl_def_col(ftbl_name,fcol_name)
   FREE RECORD ccdc_excl
   RECORD ccdc_excl(
     1 excl_cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   DECLARE ccdc_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM user_tab_cols u
    WHERE u.table_name=cnvtupper(trim(ftbl_name,3))
     AND ((u.hidden_column="YES") OR (((u.virtual_column="YES") OR (u.column_name="LAST_UTC_TS")) ))
    DETAIL
     ccdc_excl->excl_cnt += 1, stat = alterlist(ccdc_excl->qual,ccdc_excl->excl_cnt), ccdc_excl->
     qual[ccdc_excl->excl_cnt].column_name = u.column_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
     AND  NOT (expand(ccdc_idx,1,ccdc_excl->excl_cnt,l.attr_name,ccdc_excl->qual[ccdc_idx].
     column_name))
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE chk_row_cnt(rtbl_name)
   SET cr_cnt = - (1)
   DELETE  FROM dm_info d
    WHERE d.info_domain="CMB ROW CNT"
     AND d.info_name=cnvtupper(rtbl_name)
    WITH nocounter
   ;end delete
   CALL parser("rdb insert into dm_info (info_domain, info_name, info_number) ")
   CALL parser(concat(" (select 'CMB ROW CNT', '",trim(cnvtupper(rtbl_name)),"', t.cnt ",
     "from (select count(*) cnt from ",trim(cnvtupper(rtbl_name)),
     " ) t) go"))
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="CMB ROW CNT"
     AND d.info_name=cnvtupper(rtbl_name)
    DETAIL
     cr_cnt = d.info_number
    WITH nocounter
   ;end select
   DELETE  FROM dm_info d
    WHERE d.info_domain="CMB ROW CNT"
     AND d.info_name=cnvtupper(rtbl_name)
    WITH nocounter
   ;end delete
   RETURN(cr_cnt)
 END ;Subroutine
 SUBROUTINE ucb_chk_ccl_def_tbl(utbl_name)
   SELECT INTO "nl:"
    a.table_name
    FROM dtableattr a
    WHERE a.table_name=cnvtupper(trim(utbl_name,3))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     u.table_name
     FROM user_tab_columns u
     WHERE u.table_name=cnvtupper(trim(utbl_name,3))
     WITH nocounter
    ;end select
    IF (curqual > 0)
     RETURN(- (1))
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 IF ((validate(rev_cmb_request->reverse_ind,- (1))=- (1))
  AND (validate(rev_cmb_request->application_flag,- (999))=- (999)))
  FREE RECORD rev_cmb_request
  RECORD rev_cmb_request(
    1 reverse_ind = i2
    1 application_flag = i4
  )
 ENDIF
 IF ((validate(ddp_request->cnt,- (1))=- (1)))
  FREE RECORD ddp_request
  RECORD ddp_request(
    1 stmt[*]
      2 str = vc
    1 cnt = i2
  )
 ENDIF
 DECLARE cmb_audit_level(null) = i2
 DECLARE cmb_call_create_audit_procs(null) = null
 IF ((validate(cmb_audit->log_lvl,- (99))=- (99)))
  FREE RECORD cmb_audit
  RECORD cmb_audit(
    1 parent_table = vc
    1 log_lvl = i2
  )
  SET cmb_audit->log_lvl = - (1)
 ENDIF
 SUBROUTINE (ins_cmb_audit(i_request=vc(ref),i_request_ndx=i4,i_call_script=vc,i_child_entity_col=vc,
  i_child_entity_name=vc,i_child_entity_script_name=vc,i_cmb_grp_id=f8(ref),i_operation_type=vc,
  i_rev_cmb_ind=i2,i_pass_log_lvl=i2) =f8)
   DECLARE cmb_temp_pk_id = f8 WITH protect, noconstant(0.0)
   DECLARE cmb_temp_proc_str = vc WITH protect, noconstant("")
   DECLARE cmb_temp_app_flag = i2 WITH protect, noconstant(0)
   DECLARE cmb_temp_encntr_id = f8 WITH protect, noconstant(0.0)
   DECLARE cmb_temp_from_entity_id = f8 WITH protect, noconstant(0.0)
   DECLARE cmb_temp_to_entity_id = f8 WITH protect, noconstant(0.0)
   DECLARE cmb_temp_parent_entity_id = f8 WITH protect, noconstant(0.0)
   DECLARE dm_err_clr = i2 WITH protect, noconstant(0)
   DECLARE dm_err_ins_emsg = vc WITH protect, noconstant("")
   DECLARE cmb_temp_cmb_mode = vc WITH protect, noconstant("")
   DECLARE cmb_temp_trans_type = vc WITH protect, noconstant("")
   DECLARE cmb_temp_date = vc WITH protect, noconstant("")
   IF ((cmb_audit->log_lvl=- (1)))
    SET cmb_audit->parent_table = i_request->parent_table
    SET cmb_audit->log_lvl = cmb_audit_level(cmb_audit->parent_table)
   ENDIF
   IF ((cmb_audit->log_lvl >= i_pass_log_lvl))
    CASE (i_operation_type)
     OF "COMBINE":
      SET cmb_temp_app_flag = i_request->xxx_combine[i_request_ndx].application_flag
      SET cmb_temp_encntr_id = i_request->xxx_combine[i_request_ndx].encntr_id
      SET cmb_temp_from_entity_id = i_request->xxx_combine[i_request_ndx].from_xxx_id
      SET cmb_temp_to_entity_id = i_request->xxx_combine[i_request_ndx].to_xxx_id
      SET cmb_temp_parent_entity_id = i_request->xxx_combine[i_request_ndx].xxx_combine_id
     OF "UNCOMBINE":
      SET cmb_temp_app_flag = i_request->xxx_uncombine[i_request_ndx].application_flag
      SET cmb_temp_encntr_id = 0.0
      SET cmb_temp_from_entity_id = i_request->xxx_uncombine[i_request_ndx].from_xxx_id
      SET cmb_temp_to_entity_id = i_request->xxx_uncombine[i_request_ndx].to_xxx_id
      SET cmb_temp_parent_entity_id = i_request->xxx_uncombine[i_request_ndx].xxx_combine_id
     ELSE
      RETURN(0)
    ENDCASE
    SELECT INTO "nl:"
     y = seq(combine_seq,nextval)
     FROM dual
     DETAIL
      cmb_temp_pk_id = cnvtreal(y)
     WITH nocounter
    ;end select
    IF (i_cmb_grp_id=0)
     SELECT INTO "nl:"
      y = seq(combine_seq,nextval)
      FROM dual
      DETAIL
       i_cmb_grp_id = cnvtreal(y)
      WITH nocounter
     ;end select
    ENDIF
    SET cmb_temp_cmb_mode = replace(i_request->cmb_mode,"'","''")
    SET cmb_temp_trans_type = replace(i_request->transaction_type,"'","''")
    SET cmb_temp_cmb_mode = replace(cmb_temp_cmb_mode,"^","'||chr(94)||'")
    SET cmb_temp_trans_type = replace(cmb_temp_trans_type,"^","'||chr(94)||'")
    SET cmb_temp_cmb_mode = replace(cmb_temp_cmb_mode,char(0),"'||chr(0)||'")
    SET cmb_temp_trans_type = replace(cmb_temp_trans_type,char(0),"'||chr(0)||'")
    IF (curutc=1)
     SET cmb_temp_date = "SYS_EXTRACT_UTC(SYSTIMESTAMP)"
    ELSE
     SET cmb_temp_date = "sysdate"
    ENDIF
    SET cmb_temp_proc_str = build("rdb asis (^begin proc_ins_cmb_audit_auton(",cmb_temp_app_flag,",'",
     i_call_script,"','",
     i_child_entity_col,"','",i_child_entity_name,"','",i_child_entity_script_name,
     "',",cmb_temp_pk_id,",",i_cmb_grp_id,",'",
     cmb_temp_cmb_mode,"',",cmb_temp_encntr_id,",",cmb_temp_from_entity_id,
     ",",i_pass_log_lvl,",'",i_operation_type,"',",
     cmb_temp_parent_entity_id,",'",i_request->parent_table,"', ",cmb_temp_date,
     ",",cmb_temp_to_entity_id,",'",cmb_temp_trans_type,"',",
     i_rev_cmb_ind,",",reqinfo->updt_app,", ",cmb_temp_date,
     ", ",reqinfo->updt_id,",",reqinfo->updt_task,"); END; ^) go")
    IF (dm_debug_cmb=1)
     CALL echo(cmb_temp_proc_str)
    ENDIF
    CALL parser(cmb_temp_proc_str,1)
   ENDIF
   SET dm_err_clr = error(dm_err_ins_emsg,1)
   IF (dm_err_clr > 0)
    SET cmb_temp_pk_id = 0
    SET i_cmb_grp_id = 0
    CALL parser("reset go")
   ENDIF
   RETURN(cmb_temp_pk_id)
 END ;Subroutine
 SUBROUTINE (upd_cmb_audit(i_cmb_audit_id=f8,i_cmb_error_id=f8,i_pass_log_lvl=i2) =null)
   DECLARE cmb_temp_proc_str2 = vc WITH protect, noconstant("")
   DECLARE dm_err_clr2 = i2 WITH protect, noconstant(0)
   DECLARE dm_err_upd_emsg = vc WITH protect, noconstant("")
   DECLARE cmb_temp_date = vc WITH protect, noconstant("")
   IF ((cmb_audit->log_lvl >= i_pass_log_lvl)
    AND i_cmb_audit_id > 0)
    SET cmb_temp_proc_str2 = ""
    IF (curutc=1)
     SET cmb_temp_date = "SYS_EXTRACT_UTC(SYSTIMESTAMP)"
    ELSE
     SET cmb_temp_date = "sysdate"
    ENDIF
    SET cmb_temp_proc_str2 = build("rdb asis (^begin proc_upd_cmb_audit_auton(",i_cmb_audit_id,",",
     i_cmb_error_id,", ",
     cmb_temp_date,", ",reqinfo->updt_app,", ",cmb_temp_date,
     ", ",reqinfo->updt_id,",",reqinfo->updt_task,"); END; ^) go")
    IF (dm_debug_cmb=1)
     CALL echo(cmb_temp_proc_str2)
    ENDIF
    CALL parser(cmb_temp_proc_str2,1)
   ENDIF
   SET dm_err_clr2 = error(dm_err_upd_emsg,1)
 END ;Subroutine
 SUBROUTINE cmb_audit_level(i_parent_table)
   DECLARE temp_audit_lvl = i2 WITH protect, noconstant(0)
   DECLARE temp_info_name_str = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM user_objects u
    WHERE u.object_type="PROCEDURE"
     AND u.object_name IN ("PROC_INS_CMB_AUDIT_AUTON", "PROC_UPD_CMB_AUDIT_AUTON")
     AND u.status="VALID"
    WITH nocounter
   ;end select
   IF (curqual < 2)
    SET temp_audit_lvl = 0
   ELSE
    IF (i_parent_table="PRSNL")
     SET temp_info_name_str = "COMBINE_AUDIT_LOG_LEVEL::PERSON"
    ELSE
     SET temp_info_name_str = concat("COMBINE_AUDIT_LOG_LEVEL::",i_parent_table)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name=temp_info_name_str
     DETAIL
      temp_audit_lvl = di.info_number
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp_audit_lvl = 1
     INSERT  FROM dm_info di
      SET di.info_domain = "DATA MANAGEMENT", di.info_name = temp_info_name_str, di.info_number =
       temp_audit_lvl,
       di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->
       updt_applctx,
       di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
   IF (dm_debug_cmb=1)
    CALL echo(build("*** Combine Audit Level for parent: ",i_parent_table," is: ",temp_audit_lvl))
   ENDIF
   RETURN(temp_audit_lvl)
 END ;Subroutine
 SUBROUTINE (cmb_create_audit_procs(i_ins_ind=i2,i_upd_ind=i2) =vc)
   DECLARE dm_cmb_audit_emsg = vc WITH protect, noconstant("")
   IF (i_ins_ind=1)
    RDB read "cer_install:proc_ins_cmb_audit_auton.sql"
    END ;Rdb
    IF (error(dm_cmb_audit_emsg,1) != 0)
     RETURN(dm_cmb_audit_emsg)
    ENDIF
   ENDIF
   IF (i_upd_ind=1)
    RDB read "cer_install:proc_upd_cmb_audit_auton.sql"
    END ;Rdb
    IF (error(dm_cmb_audit_emsg,1) != 0)
     RETURN(dm_cmb_audit_emsg)
    ENDIF
   ENDIF
   IF (((i_ins_ind=1) OR (i_upd_ind=1)) )
    SELECT INTO "nl:"
     FROM user_objects u
     WHERE u.object_type="PROCEDURE"
      AND u.object_name IN ("PROC_INS_CMB_AUDIT_AUTON", "PROC_UPD_CMB_AUDIT_AUTON")
      AND u.status="VALID"
     WITH nocounter
    ;end select
    IF (curqual < 2)
     RETURN(
     "ERROR: PROC_INS_CMB_AUDIT_AUTON and PROC_UPD_CMB_AUDIT_AUTON Procedures not found on USER_OBJECTS"
     )
    ENDIF
    SELECT INTO "nl:"
     FROM user_errors e
     WHERE e.name IN ("PROC_INS_CMB_AUDIT_AUTON", "PROC_UPD_CMB_AUDIT_AUTON")
      AND e.type="PROCEDURE"
     DETAIL
      dm_cmb_audit_emsg = concat(dm_cmb_audit_emsg,"ERROR:",e.name,"-",e.text,
       "::")
     WITH nocounter
    ;end select
    IF (curqual > 0)
     RETURN(dm_cmb_audit_emsg)
    ENDIF
   ENDIF
   RETURN("SUCCESS")
 END ;Subroutine
 SUBROUTINE cmb_call_create_audit_procs(null)
   DECLARE dm_ins_ind = i2 WITH protect, noconstant(1)
   DECLARE dm_upd_ind = i2 WITH protect, noconstant(1)
   DECLARE dm_sub_return_val = vc WITH protect, noconstant("")
   DECLARE dm_err_queue_clr = i2 WITH protect, noconstant(0)
   DECLARE dm_err_emsg = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM user_objects u
    WHERE u.object_type="PROCEDURE"
     AND u.object_name IN ("PROC_INS_CMB_AUDIT_AUTON", "PROC_UPD_CMB_AUDIT_AUTON")
     AND u.status="VALID"
    DETAIL
     IF (u.object_name="PROC_INS_CMB_AUDIT_AUTON")
      dm_ins_ind = 0
     ELSEIF (u.object_name="PROC_UPD_CMB_AUDIT_AUTON")
      dm_upd_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (((dm_ins_ind=1) OR (dm_upd_ind=1)) )
    SET dm_sub_return_val = cmb_create_audit_procs(dm_ins_ind,dm_upd_ind)
   ENDIF
   SET dm_err_queue_clr = error(dm_err_emsg,1)
 END ;Subroutine
 SET du_cmb_dt_tm_ind = 0
 SET next_seq_val = 0.0
 SET init_updt_cnt = 0
 SET ucb_dummy = 0
 SET nbr_to_ucb = 0
 SET error_table = fillstring(50," ")
 SET ermsg = fillstring(132," ")
 SET ercode = 0
 SET ucb_parser_buffer[20] = fillstring(132," ")
 SET max_script_run_order = 1
 SET parent_combine_id = 0.0
 SET task_nbr = 100102
 DECLARE b_reply_size = i4
 SET ucb_failed = false
 DECLARE ucb_debug = i4
 SET ucb_debug = 0
 DECLARE inx = i4
 SET inx = 0
 SET cmb_type = 0.0
 SET meaning = fillstring(12," ")
 SET combinedaway = 0.0
 SET meaning = "COMBINED"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=48
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   combinedaway = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'COMBINED' for code_set 48"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET del = 0.0
 SET meaning = "DEL"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   del = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'DEL' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET upt = 0.0
 SET meaning = "UPT"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   upt = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'UPT' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET add = 0.0
 SET meaning = "ADD"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   add = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'ADD' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET eff = 0.0
 SET meaning = "EFF"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   eff = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'EFF' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET physdel = 0.0
 SET meaning = "PHYSDEL"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   physdel = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'PHYSDEL' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET recalc = 0.0
 SET meaning = "RECALC"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   recalc = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'RECALC' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET meaning = "REVDEL"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   revdel = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'REVDEL' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET meaning = "REVENDEFF"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   revendeff = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'REVENDEFF' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET meaning = "NOOP"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   noop = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'NOOP' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 SET meaning = "BYPASS_UID"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   bypass_uid = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ucb_failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'BYPASS_UID' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 IF (trim(request->parent_table)="PERSON")
  SET cmb_table_id = "PERSON_COMBINE_ID"
  SET cmb_det_table = "PERSON_COMBINE_DET"
  SET cmb_det_table_id = "PERSON_COMBINE_DET_ID"
  SET cmb_table = "PERSON_COMBINE"
  SET cmb_from = "FROM_PERSON_ID"
  SET cmb_to = "TO_PERSON_ID"
  SET cmb_id = "PERSON_ID"
 ELSEIF (trim(request->parent_table)="ENCOUNTER")
  SET cmb_table_id = "ENCNTR_COMBINE_ID"
  SET cmb_det_table = "ENCNTR_COMBINE_DET"
  SET cmb_det_table_id = "ENCNTR_COMBINE_DET_ID"
  SET cmb_table = "ENCNTR_COMBINE"
  SET cmb_from = "FROM_ENCNTR_ID"
  SET cmb_to = "TO_ENCNTR_ID"
  SET cmb_id = "ENCNTR_ID"
 ENDIF
 CALL parser(concat("range of ucbcol is ",cmb_table," go"))
 SET du_cmb_dt_tm_ind = evaluate(validate(ucbcol.cmb_dt_tm,- (999999.0)),- (999999.0),0,1)
 FREE RANGE ucbcol
 SET nbr_to_ucb = size(request->xxx_uncombine,5)
 SET swap_to_from = 0.0
 FOR (inx = 1 TO nbr_to_ucb)
   SET swap_to_from = request->xxx_uncombine[inx].from_xxx_id
   SET request->xxx_uncombine[inx].from_xxx_id = request->xxx_uncombine[inx].to_xxx_id
   SET request->xxx_uncombine[inx].to_xxx_id = swap_to_from
 ENDFOR
 SET ercode = error(ermsg,1)
 IF (ercode != 0)
  SET ucb_failed = ccl_error
  GO TO check_error
 ENDIF
 FOR (ucb_cnt = 1 TO nbr_to_ucb)
   SET det_cnt = 0
   SET ucb_count1 = 0
   SET cmb_det_updt_cnt = 0
   SET activity_updt_cnt = 0
   SET activity_no_updt_cnt = 0
   SET ucb_audit_id = 0.0
   SET ucb_group_id_pub = 0.0
   SET parent_combine_id = request->xxx_uncombine[ucb_cnt].xxx_combine_id
   IF (call_script="DM_CALL_UNCOMBINE"
    AND (request->parent_table="PERSON"))
    SET stat = locateval(ucb_group_ndx,1,size(rucbprsnl->ucb,5),parent_combine_id,rucbprsnl->ucb[
     ucb_cnt].prsnl_combine_id)
    SET ucb_group_id_pub = rucbprsnl->ucb[ucb_group_ndx].ucb_group_id
   ENDIF
   SET ucb_audit_id = ins_cmb_audit(request,ucb_cnt,call_script," "," ",
    " ",ucb_group_id_pub,"UNCOMBINE",0,1)
   SET req_error = 0
   IF ((request->parent_table="PERSON"))
    IF ((request->cmb_mode != "RE-UCB"))
     SELECT INTO "nl:"
      p.person_id
      FROM person p
      WHERE (p.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
       AND p.active_ind=0
      DETAIL
       req_error = 1, request->error_message = "Can't uncombine - 'master' person is inactive."
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      p.person_id
      FROM person p
      WHERE (p.person_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
       AND p.active_ind=1
      DETAIL
       req_error = 1, request->error_message = "Can't uncombine - 'combined away' person is active."
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF ((request->parent_table="ENCOUNTER"))
    SELECT INTO "nl:"
     ec.encntr_combine_id, ecd.entity_name
     FROM encntr_combine ec,
      encntr_combine_det ecd
     PLAN (ec
      WHERE (ec.encntr_combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id))
      JOIN (ecd
      WHERE ec.encntr_combine_id=ecd.encntr_combine_id
       AND ec.from_encntr_id=ecd.entity_id
       AND ecd.updt_task=0)
     DETAIL
      ucb_failed = data_error, request->error_message =
      "This encounter uncombine cannot be completed due to inconsistent combine history.",
      error_table = ecd.entity_name
     WITH nocounter
    ;end select
    IF (curqual > 0)
     GO TO check_error
    ENDIF
    IF ((request->cmb_mode != "RE-UCB"))
     SELECT INTO "nl:"
      e.encntr_id
      FROM encounter e
      WHERE (e.encntr_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
       AND e.active_ind=0
      DETAIL
       req_error = 1, request->error_message = "Can't uncombine - 'master' encounter is inactive."
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      e.encntr_id
      FROM encounter e
      WHERE (e.encntr_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
       AND e.active_ind=1
      DETAIL
       req_error = 1, request->error_message =
       "Can't uncombine - 'combined away' encounter is active."
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (req_error=1)
    SET ucb_failed = data_error
    SET error_table = "REQUEST"
    GO TO check_error
   ENDIF
   CALL ucb_xxx_combine(ucb_dummy)
   CALL parser('select into "nl:" x.entity_name')
   CALL parser(concat("from ",trim(cmb_det_table)," x"))
   CALL parser(build("where x.",trim(cmb_table_id)," = ",request->xxx_uncombine[ucb_cnt].
     xxx_combine_id))
   CALL parser("and x.entity_name = 'ENCOUNTER' ")
   CALL parser("and x.active_ind = 1")
   CALL parser(build("and x.combine_action_cd != ",noop))
   CALL parser("detail")
   CALL parser("ucb_count1 = ucb_count1 + 1")
   CALL parser("stat = alterlist(rChildren->qual1, ucb_count1)")
   CALL parser(concat("rChildren->qual1[ucb_count1]->xxx_combine_det_id = x.",trim(cmb_det_table_id))
    )
   CALL parser("rChildren->qual1[ucb_count1]->entity_name = x.entity_name")
   CALL parser("rChildren->qual1[ucb_count1]->entity_id = x.entity_id")
   CALL parser("rChildren->qual1[ucb_count1]->combine_action_cd = x.combine_action_cd")
   CALL parser("rChildren->qual1[ucb_count1]->attribute_name = x.attribute_name")
   CALL parser("rChildren->qual1[ucb_count1]->prev_active_ind = x.prev_active_ind")
   CALL parser("rChildren->qual1[ucb_count1]->prev_active_status_cd = x.prev_active_status_cd")
   CALL parser("rChildren->qual1[ucb_count1]->prev_end_eff_dt_tm = x.prev_end_eff_dt_tm")
   CALL parser("rChildren->qual1[ucb_count1]->combine_desc_cd = x.combine_desc_cd")
   CALL parser("rChildren->qual1[ucb_count1]->to_record_ind = x.to_record_ind")
   CALL parser("rChildren->qual1[ucb_count1]->script_run_order = 1")
   CALL parser("rChildren->qual1[ucb_count1]->del_chg_id_ind = 2")
   CALL parser("with nocounter go")
   CALL parser('select into "nl:" x.entity_name')
   CALL parser(concat("from ",trim(cmb_det_table)," x"))
   CALL parser(build("where x.",trim(cmb_table_id)," = ",request->xxx_uncombine[ucb_cnt].
     xxx_combine_id))
   CALL parser("and x.entity_name != 'ENCOUNTER' ")
   CALL parser("and x.active_ind = 1")
   CALL parser(build("and x.combine_action_cd != ",noop))
   CALL parser("order by x.entity_name")
   CALL parser("detail")
   CALL parser("ucb_count1 = ucb_count1 + 1")
   CALL parser("stat = alterlist(rChildren->qual1, ucb_count1)")
   CALL parser(concat("rChildren->qual1[ucb_count1]->xxx_combine_det_id = x.",trim(cmb_det_table_id))
    )
   CALL parser("rChildren->qual1[ucb_count1]->entity_name = x.entity_name")
   CALL parser("rChildren->qual1[ucb_count1]->entity_id = x.entity_id")
   CALL parser("rChildren->qual1[ucb_count1]->combine_action_cd = x.combine_action_cd")
   CALL parser("rChildren->qual1[ucb_count1]->attribute_name = x.attribute_name")
   CALL parser("rChildren->qual1[ucb_count1]->prev_active_ind = x.prev_active_ind")
   CALL parser("rChildren->qual1[ucb_count1]->prev_active_status_cd = x.prev_active_status_cd")
   CALL parser("rChildren->qual1[ucb_count1]->prev_end_eff_dt_tm = x.prev_end_eff_dt_tm")
   CALL parser("rChildren->qual1[ucb_count1]->combine_desc_cd = x.combine_desc_cd")
   CALL parser("rChildren->qual1[ucb_count1]->to_record_ind = x.to_record_ind")
   CALL parser("rChildren->qual1[ucb_count1]->script_run_order = 1")
   CALL parser("rChildren->qual1[ucb_count1]->del_chg_id_ind = 2")
   CALL parser("with nocounter go")
   IF (ucb_count1 > 0)
    IF ((request->parent_table="PERSON"))
     SET dm_qual_cnt = 0
     SELECT INTO "nl:"
      d.seq
      FROM (dummyt d  WITH seq = value(ucb_count1)),
       encntr_combine ec
      PLAN (d
       WHERE (rchildren->qual1[d.seq].entity_name="ENCOUNTER"))
       JOIN (ec
       WHERE ec.active_ind=1
        AND (((ec.from_encntr_id=rchildren->qual1[d.seq].entity_id)) OR ((ec.to_encntr_id=rchildren->
       qual1[d.seq].entity_id))) )
      DETAIL
       dm_found = 0, dm_z = 1
       WHILE (dm_z <= dm_qual_cnt
        AND dm_found != 1)
         IF ((rcombinedenc->qual[dm_z].encntr_combine_id=ec.encntr_combine_id))
          dm_found = 1
         ELSE
          dm_z += 1
         ENDIF
       ENDWHILE
       IF (dm_found=0)
        dm_qual_cnt += 1, stat = alterlist(rcombinedenc->qual,dm_qual_cnt), rcombinedenc->qual[
        dm_qual_cnt].encntr_combine_id = ec.encntr_combine_id,
        rcombinedenc->qual[dm_qual_cnt].from_encntr_id = ec.from_encntr_id, rcombinedenc->qual[
        dm_qual_cnt].to_encntr_id = ec.to_encntr_id
        IF ((ec.from_encntr_id=rchildren->qual1[d.seq].entity_id))
         rcombinedenc->qual[dm_qual_cnt].from_encntr_id_ind = 1
        ELSEIF ((ec.to_encntr_id=rchildren->qual1[d.seq].entity_id))
         rcombinedenc->qual[dm_qual_cnt].to_encntr_id_ind = 1
        ENDIF
       ELSEIF (dm_found=1)
        IF ((ec.from_encntr_id=rchildren->qual1[d.seq].entity_id))
         rcombinedenc->qual[dm_z].from_encntr_id_ind = 1
        ELSEIF ((ec.to_encntr_id=rchildren->qual1[d.seq].entity_id))
         rcombinedenc->qual[dm_z].to_encntr_id_ind = 1
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SET msg_cnt = 0
     IF (dm_qual_cnt > 0)
      SELECT INTO "nl:"
       d.seq
       FROM (dummyt d  WITH seq = value(dm_qual_cnt))
       WHERE (((rcombinedenc->qual[d.seq].from_encntr_id_ind=0)) OR ((rcombinedenc->qual[d.seq].
       to_encntr_id_ind=0)))
       DETAIL
        msg_cnt += 1, stat = alterlist(rcombinedenc->err,msg_cnt), rcombinedenc->err[msg_cnt].msg =
        concat(trim(cnvtstring(rcombinedenc->qual[d.seq].from_encntr_id))," and ",trim(cnvtstring(
           rcombinedenc->qual[d.seq].to_encntr_id)),", ")
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET dm_err_string = fillstring(500," ")
       SET buf_cnt = 0
       SET ucb_failed = data_error
       SET buf_cnt += 1
       SET ucb_parser_buffer[buf_cnt] = 'set dm_err_string= concat("Must uncombine encntrs ",'
       FOR (dm_x = 1 TO msg_cnt)
         SET temp_str = build("rCombinedEnc->err[",dm_x,"]->msg,")
         SET buf_cnt += 1
         SET ucb_parser_buffer[buf_cnt] = temp_str
       ENDFOR
       SET buf_cnt += 1
       SET ucb_parser_buffer[buf_cnt] = '" before person uncombine.") go'
       FOR (dm_x = 1 TO buf_cnt)
         CALL parser(ucb_parser_buffer[dm_x])
       ENDFOR
       SET request->error_message = trim(substring(1,131,dm_err_string))
       SET error_table = "ENCNTR_COMBINE"
       GO TO check_error
      ENDIF
     ENDIF
    ENDIF
    SET ucb_count1 = size(rchildren->qual1,5)
    DECLARE du_child_cnt = i4
    SET du_child_cnt = 0
    FREE SET du_db
    FREE RECORD du_db
    RECORD du_db(
      1 tbl_cnt = i4
      1 tbl[*]
        2 table_name = vc
        2 pk_name = vc
        2 pk_col = vc
    )
    SELECT INTO "nl:"
     uc.table_name, uc.constraint_name, ucc.column_name
     FROM user_cons_columns ucc,
      user_constraints uc
     WHERE uc.owner=ucc.owner
      AND uc.constraint_name=ucc.constraint_name
      AND uc.table_name=ucc.table_name
      AND uc.owner=currdbuser
      AND uc.constraint_type="P"
      AND ucc.position=1
     HEAD REPORT
      inx = 0
     DETAIL
      inx += 1
      IF (mod(inx,100)=1)
       stat = alterlist(du_db->tbl,(inx+ 100))
      ENDIF
      du_db->tbl[inx].table_name = uc.table_name, du_db->tbl[inx].pk_name = uc.constraint_name, du_db
      ->tbl[inx].pk_col = ucc.column_name
     FOOT REPORT
      du_db->tbl_cnt = inx, stat = alterlist(du_db->tbl,inx)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     d.seq, d2.seq
     FROM (dummyt d  WITH seq = value(ucb_count1)),
      (dummyt d2  WITH seq = value(du_db->tbl_cnt))
     PLAN (d
      WHERE size(trim(rchildren->qual1[d.seq].primary_key_attr))=0)
      JOIN (d2
      WHERE (du_db->tbl[d2.seq].table_name=rchildren->qual1[d.seq].entity_name))
     DETAIL
      IF (size(trim(rchildren->qual1[d.seq].primary_key_attr))=0)
       du_child_cnt += 1
      ENDIF
      rchildren->qual1[d.seq].primary_key_attr = du_db->tbl[d2.seq].pk_col
     WITH nocounter
    ;end select
    IF (dm_debug_cmb)
     CALL echorecord(rchildren)
    ENDIF
    IF (curqual=0)
     SET ucb_failed = select_error
     SET request->error_message =
     "Could not select primary key names for child tables to be uncombined."
     GO TO check_error
    ENDIF
    SELECT INTO "nl:"
     rchildren->qual1[d.seq].entity_name
     FROM (dummyt d  WITH seq = value(ucb_count1)),
      dm_cmb_exception dce
     PLAN (d)
      JOIN (dce
      WHERE (dce.child_entity=rchildren->qual1[d.seq].entity_name)
       AND (dce.parent_entity=request->parent_table)
       AND dce.operation_type="UNCOMBINE")
     DETAIL
      rchildren->qual1[d.seq].script_name = dce.script_name, rchildren->qual1[d.seq].script_run_order
       = dce.script_run_order
      IF (dce.script_run_order > max_script_run_order)
       max_script_run_order = dce.script_run_order
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     rchildren->qual1[d.seq].entity_name
     FROM (dummyt d  WITH seq = value(ucb_count1)),
      dm_cmb_exception dce
     PLAN (d)
      JOIN (dce
      WHERE (dce.child_entity=rchildren->qual1[d.seq].entity_name)
       AND (dce.parent_entity=request->parent_table)
       AND dce.operation_type="COMBINE")
     DETAIL
      rchildren->qual1[d.seq].del_chg_id_ind = dce.del_chg_id_ind
     WITH nocounter
    ;end select
    SET ercode = error(ermsg,1)
    IF (ercode != 0)
     SET ucb_failed = ccl_error
     GO TO check_error
    ENDIF
    SET prev_tbl_name = fillstring(30," ")
    FOR (ucb_i = 1 TO ucb_count1)
      IF ((rchildren->qual1[ucb_i].script_name != "NONE"))
       IF ((rchildren->qual1[ucb_i].entity_name != trim(prev_tbl_name)))
        SET prev_tbl_name = rchildren->qual1[ucb_i].entity_name
        SET rchildren->qual1[ucb_i].ignore_ind = ucb_chk_ccl_def_tbl(rchildren->qual1[ucb_i].
         entity_name)
        IF (dm_debug_cmb)
         CALL echo(build("child_table ",rchildren->qual1[ucb_i].entity_name,"'s ignore_ind=",
           rchildren->qual1[ucb_i].ignore_ind))
         IF ((rchildren->qual1[ucb_i].ignore_ind=1))
          CALL echo(build("table=",rchildren->qual1[ucb_i].entity_name," is ignored."))
         ENDIF
        ENDIF
        IF ((rchildren->qual1[ucb_i].ignore_ind=- (1)))
         SET ucb_failed = data_error
         SET error_table = rchildren->qual1[ucb_i].entity_name
         SET request->error_message = concat("No CCL definition for table ",rchildren->qual1[ucb_i].
          entity_name,"found.")
         GO TO check_error
        ENDIF
       ELSE
        SET rchildren->qual1[ucb_i].ignore_ind = rchildren->qual1[(ucb_i - 1)].ignore_ind
       ENDIF
      ENDIF
    ENDFOR
    IF ((request->cmb_mode != "RE-UCB"))
     CALL ucb_parent(ucb_dummy)
    ENDIF
    FREE RECORD b_reply
    RECORD b_reply(
      1 em[*]
        2 encntr_id = f8
        2 from_person_id = f8
        2 to_person_id = f8
        2 entity_id = f8
    )
    FOR (script_run_cnt = 1 TO max_script_run_order)
      FOR (det_cnt = 1 TO ucb_count1)
        IF ((rchildren->qual1[det_cnt].script_run_order=script_run_cnt))
         IF ((rchildren->qual1[det_cnt].ignore_ind=0))
          SET error_table = rchildren->qual1[det_cnt].entity_name
          SET rchildren->qual1[det_cnt].ucb_audit_id = ins_cmb_audit(request,ucb_cnt,call_script,
           rchildren->qual1[det_cnt].attribute_name,rchildren->qual1[det_cnt].entity_name,
           trim(rchildren->qual1[det_cnt].script_name,3),ucb_group_id_pub,"UNCOMBINE",0,2)
          IF (trim(rchildren->qual1[det_cnt].script_name)="")
           IF (trim(rchildren->qual1[det_cnt].primary_key_attr)="")
            SET ucb_failed = no_primary_key
            SET request->error_message = concat("Table ",rchildren->qual1[det_cnt].entity_name,
             " has no primary key.")
            GO TO check_error
           ENDIF
           IF (dm_debug_cmb=1)
            CALL trace(7)
            CALL trace(8)
            CALL trace(10)
           ENDIF
           IF ((rchildren->qual1[det_cnt].combine_action_cd=add))
            CALL ucb_add(ucb_dummy)
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
            IF ((rchildren->qual1[det_cnt].to_record_ind=1))
             CALL ucb_del3(ucb_dummy)
            ELSEIF ((rchildren->qual1[det_cnt].del_chg_id_ind=1))
             CALL ucb_del(ucb_dummy)
            ELSEIF ((rchildren->qual1[det_cnt].del_chg_id_ind=0))
             CALL ucb_del2(ucb_dummy)
            ELSE
             SET ucb_failed = data_error
             SET request->error_message = concat("Table ",rchildren->qual1[det_cnt].entity_name,
              " has value of del_chg_id_ind on dm_cmb_exception table not equal 1 or 0.")
             GO TO check_error
            ENDIF
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
            CALL ucb_upt(ucb_dummy)
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=eff))
            IF ((rchildren->qual1[det_cnt].to_record_ind=1))
             CALL ucb_eff2(ucb_dummy)
            ELSE
             CALL ucb_eff(ucb_dummy)
            ENDIF
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=revdel))
            CALL ucb_revdel(ucb_dummy)
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=revendeff))
            CALL ucb_reveff2(ucb_dummy)
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=bypass_uid))
            CALL ucb_upt_bypassuid(ucb_dummy)
           ELSE
            IF ((rchildren->qual1[det_cnt].combine_action_cd != recalc)
             AND (rchildren->qual1[det_cnt].combine_action_cd != physdel)
             AND (rchildren->qual1[det_cnt].combine_action_cd != noop))
             SET ucb_failed = data_error
             SET request->error_message = concat("Found invalid combine_action_cd for table ",
              rchildren->qual1[det_cnt].entity_name)
             SET error_table = rchildren->qual1[det_cnt].entity_name
             GO TO check_error
            ENDIF
           ENDIF
           IF (dm_debug_cmb=1)
            CALL trace(7)
            CALL trace(8)
            CALL trace(10)
           ENDIF
          ELSE
           IF ((rchildren->qual1[det_cnt].script_name != "NONE"))
            SET trace = norecpersist
            SET modify = nopredeclare
            IF ((rchildren->qual1[det_cnt].script_name="DM_PUCB_ORDERS"))
             CALL echo(build("execute ",rchildren->qual1[det_cnt].script_name,
               ' with replace("REPLY", "B_REPLY") go'))
             CALL parser(concat("execute ",rchildren->qual1[det_cnt].script_name,
               ' with replace("REPLY", "B_REPLY") go'))
            ELSE
             CALL echo(build("execute ",rchildren->qual1[det_cnt].script_name," go"))
             CALL parser(concat("execute ",rchildren->qual1[det_cnt].script_name," go"))
            ENDIF
            IF (ucb_failed != false)
             IF (((ucb_failed=update_error) OR (ucb_failed=reactivate_error)) )
              SET ucb_failed = false
             ELSE
              SET ermsg = request->error_message
              GO TO check_error
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          SET ercode = error(ermsg,1)
          IF (ercode != 0)
           SET ucb_failed = ccl_error
           GO TO check_error
          ENDIF
          CALL upd_cmb_audit(rchildren->qual1[det_cnt].ucb_audit_id,0.0,2)
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
    CALL ucb_xxx_combine_det(ucb_dummy)
   ENDIF
   SET ercode = error(ermsg,1)
   IF (ercode != 0)
    SET ucb_failed = ccl_error
    GO TO check_error
   ENDIF
   IF ((request->parent_table="PERSON")
    AND ucb_count1 > 0)
    SET nbr_of_encntrs = 0
    SET stat = alterlist(request->xxx_combine,0)
    SET stat = alterlist(request->xxx_combine_det,0)
    FOR (dm_h = 1 TO ucb_count1)
      IF ((rchildren->qual1[dm_h].entity_name="ENCOUNTER"))
       SELECT INTO "nl:"
        e.encntr_id
        FROM encounter e
        WHERE (e.encntr_id=rchildren->qual1[dm_h].entity_id)
         AND e.active_ind=1
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM encntr_combine ec
         WHERE ec.from_encntr_id=e.encntr_id
          AND ec.active_ind=1)))
        DETAIL
         nbr_of_encntrs += 1, stat = alterlist(request->xxx_combine,nbr_of_encntrs), request->
         xxx_combine[nbr_of_encntrs].encntr_id = rchildren->qual1[dm_h].entity_id,
         request->xxx_combine[nbr_of_encntrs].from_xxx_id = request->xxx_uncombine[ucb_cnt].
         from_xxx_id, request->xxx_combine[nbr_of_encntrs].from_mrn = "", request->xxx_combine[
         nbr_of_encntrs].from_alias_pool_cd = 0,
         request->xxx_combine[nbr_of_encntrs].from_alias_type_cd = 0, request->xxx_combine[
         nbr_of_encntrs].to_xxx_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, request->xxx_combine[
         nbr_of_encntrs].to_mrn = "",
         request->xxx_combine[nbr_of_encntrs].to_alias_pool_cd = 0, request->xxx_combine[
         nbr_of_encntrs].to_alias_type_cd = 0
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
    SET b_reply_size = size(b_reply->em,5)
    FOR (du_b_lp = 1 TO b_reply_size)
      SET nbr_of_encntrs += 1
      SET stat = alterlist(request->xxx_combine,nbr_of_encntrs)
      SET request->xxx_combine[nbr_of_encntrs].encntr_id = b_reply->em[du_b_lp].encntr_id
      SET request->xxx_combine[nbr_of_encntrs].from_xxx_id = b_reply->em[du_b_lp].from_person_id
      SET request->xxx_combine[nbr_of_encntrs].from_mrn = ""
      SET request->xxx_combine[nbr_of_encntrs].from_alias_pool_cd = 0
      SET request->xxx_combine[nbr_of_encntrs].from_alias_type_cd = 0
      SET request->xxx_combine[nbr_of_encntrs].to_xxx_id = b_reply->em[du_b_lp].to_person_id
      SET request->xxx_combine[nbr_of_encntrs].to_mrn = ""
      SET request->xxx_combine[nbr_of_encntrs].to_alias_pool_cd = 0
      SET request->xxx_combine[nbr_of_encntrs].to_alias_type_cd = 0
    ENDFOR
    SET ercode = error(ermsg,1)
    IF (ercode != 0)
     SET ucb_failed = ccl_error
     GO TO check_error
    ENDIF
    IF (nbr_of_encntrs > 0)
     SET call_script = "DM_UNCOMBINE"
     SET reply_cnt = 0
     SET stat = alterlist(reply->xxx_combine_id,0)
     CALL echo("Call dm_combine to move encounters...")
     CALL echorecord(request)
     EXECUTE dm_combine
     IF ((reqinfo->commit_ind=false))
      GO TO du_end_script
     ENDIF
    ENDIF
   ENDIF
   SET call_script = "DM_CALL_UNCOMBINE"
   CALL upd_cmb_audit(ucb_audit_id,0.0,1)
 ENDFOR
 SUBROUTINE ucb_xxx_combine(dummy)
   IF ((request->cmb_mode != "RE-UCB"))
    DECLARE xxx_cmb_lock = vc WITH protect
    DECLARE cmb_table_alias = vc WITH protect, constant("c")
    SET xxx_cmb_lock = concat("select into 'nl:' from ",trim(cmb_table)," ",cmb_table_alias)
    SET xxx_cmb_lock = concat(xxx_cmb_lock," where ",cmb_table_alias,".",trim(cmb_table_id),
     " = ",build(request->xxx_uncombine[ucb_cnt].xxx_combine_id)," and ",cmb_table_alias,
     ".active_ind = 1 with forupdate(c) go")
    CALL parser(xxx_cmb_lock)
    SET ercode = error(ermsg,1)
    IF (ercode != 0)
     SET ucb_failed = lock_error
     SET request->error_message = concat("Could not obtain lock on ",cmb_table," with ",cmb_table_id,
      " = ",
      build(request->xxx_uncombine[ucb_cnt].xxx_combine_id),".")
     SET error_table = cmb_table
     GO TO check_error
    ELSEIF (curqual=0)
     SET ucb_failed = data_error
     SET request->error_message = concat("No row found on ",cmb_table," with ",cmb_table_id," = ",
      build(request->xxx_uncombine[ucb_cnt].xxx_combine_id),".")
     SET error_table = cmb_table
     GO TO check_error
    ENDIF
   ENDIF
   DECLARE xxx_cmb_buff = vc WITH protect
   SET xxx_cmb_buff = concat("update into ",trim(cmb_table)," set active_ind = FALSE, ",
    "active_status_cd = ",build(reqdata->inactive_status_cd),
    ",","transaction_type = '",build(request->transaction_type),"',","application_flag = ",
    build(request->xxx_uncombine[1].application_flag),",","updt_id = ",build(reqinfo->updt_id),",",
    "updt_dt_tm = cnvtdatetime(curdate,curtime3), ","updt_applctx = ",build(reqinfo->updt_applctx),
    ", ","updt_cnt = updt_cnt + 1, ",
    "updt_task = TASK_NBR"," ")
   IF (du_cmb_dt_tm_ind=1)
    SET xxx_cmb_buff = concat(xxx_cmb_buff," ,ucb_dt_tm = cnvtdatetime(curdate,curtime3), ",
     " ucb_updt_id = reqinfo->updt_id, ")
    SET xxx_cmb_buff = concat(xxx_cmb_buff," cmb_dt_tm = nullval(cmb_dt_tm, updt_dt_tm), ",
     " cmb_updt_id = nullval(cmb_updt_id, updt_id) ")
   ENDIF
   IF ((request->cmb_mode != "RE-UCB"))
    SET xxx_cmb_buff = concat(xxx_cmb_buff," where ",trim(cmb_table_id)," = ",build(request->
      xxx_uncombine[ucb_cnt].xxx_combine_id),
     " and active_ind = 1 go")
   ELSE
    SET xxx_cmb_buff = concat(xxx_cmb_buff," where ",trim(cmb_table_id)," = ",build(request->
      xxx_uncombine[ucb_cnt].xxx_combine_id),
     " go")
   ENDIF
   IF (ucb_debug=1)
    SET idx = 1
    WHILE (idx > 0)
     CALL echo(substring(idx,80,xxx_cmb_buff))
     IF (idx > size(trim(xxx_cmb_buff)))
      SET idx = 0
     ELSE
      SET idx += 80
     ENDIF
    ENDWHILE
   ENDIF
   CALL parser(xxx_cmb_buff)
   IF (curqual=0
    AND (request->cmb_mode != "RE-UCB"))
    SET ucb_failed = delete_error
    SET request->error_message = concat("Could not inactivate record on ",cmb_table," table.")
    SET error_table = cmb_table
    GO TO check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE ucb_xxx_combine_det(dummy)
   SET xxx_cmb_det_buff = fillstring(1000," ")
   SET xxx_cmb_det_buff = concat("update into ",trim(cmb_det_table)," set active_ind = FALSE, ",
    "active_status_cd = reqdata->inactive_status_cd, ","updt_id = reqinfo->updt_id, ",
    "updt_dt_tm = cnvtdatetime(curdate,curtime3), ","updt_applctx = reqinfo->updt_applctx, ",
    "updt_cnt = updt_cnt + 1, ","updt_task = TASK_NBR ","where ",
    trim(cmb_table_id)," = ","request->xxx_uncombine[ucb_cnt]->xxx_combine_id ",
    "and active_ind = 1 go")
   CALL parser(xxx_cmb_det_buff)
   IF (curqual=0
    AND (request->cmb_mode != "RE-UCB"))
    SET ucb_failed = delete_error
    SET request->error_message = concat("No ",cmb_det_table," records were inactivated.")
    SET error_table = cmb_det_table
    GO TO check_error
   ENDIF
   SET cmb_det_updt_cnt = curqual
 END ;Subroutine
 SUBROUTINE ucb_parent(dummy)
   IF ((request->parent_table="PERSON"))
    EXECUTE dm_pucb_person
    SET ercode = error(ermsg,1)
    IF (ercode != 0)
     SET ucb_failed = ccl_error
     SET request->error_message = "Unable to uncombine person on the PERSON table."
     GO TO check_error
    ENDIF
   ELSE
    SET parent_buff = fillstring(1000," ")
    SET parent_buff = concat("update into ",trim(request->parent_table)," set active_ind = TRUE, ",
     "active_status_cd = reqdata->active_status_cd, ","updt_id = reqinfo->updt_id, ",
     "updt_dt_tm = cnvtdatetime(curdate,curtime3), ","updt_applctx = reqinfo->updt_applctx, ",
     "updt_cnt = updt_cnt + 1, ","updt_task = reqinfo->updt_task ","where ",
     trim(cmb_id)," = request->xxx_uncombine[ucb_cnt]->to_xxx_id go")
    CALL parser(parent_buff)
    IF (curqual=0)
     SET ucb_failed = reactivate_error
     SET request->error_message = concat("Could not re-activate record on ",request->parent_table,
      " table.")
     SET error_table = request->parent_table
     GO TO check_error
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE ucb_add(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 12
   SET stat = alterlist(ddp_request->stmt,12)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set active_ind = FALSE, "
   SET ddp_request->stmt[3].str = "active_status_cd = reqdata->inactive_status_cd, "
   SET ddp_request->stmt[4].str = "updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[5].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[6].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[7].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[8].str = "updt_task = TASK_NBR "
   SET ddp_request->stmt[9].str = " where "
   SET ddp_request->stmt[10].str = trim(rchildren->qual1[det_cnt].primary_key_attr)
   SET ddp_request->stmt[11].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[12].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_del(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 14
   SET stat = alterlist(ddp_request->stmt,14)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[7].str = trim(rchildren->qual1[det_cnt].attribute_name)
   SET ddp_request->stmt[8].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID, "
   SET ddp_request->stmt[9].str = "active_ind = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_IND, "
   SET ddp_request->stmt[10].str =
   "active_status_cd = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_STATUS_CD "
   SET ddp_request->stmt[11].str = " where "
   SET ddp_request->stmt[12].str = trim(rchildren->qual1[det_cnt].primary_key_attr)
   SET ddp_request->stmt[13].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[14].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_del2(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 12
   SET stat = alterlist(ddp_request->stmt,12)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[7].str = "active_ind = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_IND, "
   SET ddp_request->stmt[8].str =
   "active_status_cd = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_STATUS_CD "
   SET ddp_request->stmt[9].str = " where "
   SET ddp_request->stmt[10].str = trim(rchildren->qual1[det_cnt].primary_key_attr)
   SET ddp_request->stmt[11].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[12].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_del3(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 12
   SET stat = alterlist(ddp_request->stmt,12)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[7].str = "active_ind = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_IND, "
   SET ddp_request->stmt[8].str =
   "active_status_cd = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_STATUS_CD "
   SET ddp_request->stmt[9].str = " where "
   SET ddp_request->stmt[10].str = trim(rchildren->qual1[det_cnt].primary_key_attr)
   SET ddp_request->stmt[11].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[12].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_upt(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 14
   SET stat = alterlist(ddp_request->stmt,14)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[7].str = trim(rchildren->qual1[det_cnt].attribute_name)
   SET ddp_request->stmt[8].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID "
   SET ddp_request->stmt[9].str = " where "
   SET ddp_request->stmt[10].str = trim(rchildren->qual1[det_cnt].attribute_name)
   SET ddp_request->stmt[11].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID and "
   SET ddp_request->stmt[12].str = trim(rchildren->qual1[det_cnt].primary_key_attr)
   SET ddp_request->stmt[13].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[14].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_eff(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 16
   SET stat = alterlist(ddp_request->stmt,16)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[7].str = trim(rchildren->qual1[det_cnt].attribute_name)
   SET ddp_request->stmt[8].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID, "
   SET ddp_request->stmt[9].str = "end_effective_dt_tm "
   SET ddp_request->stmt[10].str = " = cnvtdatetime(rChildren->QUAL1[det_cnt]->PREV_END_EFF_DT_TM) "
   SET ddp_request->stmt[11].str = " where "
   SET ddp_request->stmt[12].str = trim(rchildren->qual1[det_cnt].attribute_name)
   SET ddp_request->stmt[13].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID and "
   SET ddp_request->stmt[14].str = trim(rchildren->qual1[det_cnt].primary_key_attr)
   SET ddp_request->stmt[15].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[16].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_eff2(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 13
   SET stat = alterlist(ddp_request->stmt,13)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[7].str = "end_effective_dt_tm "
   SET ddp_request->stmt[8].str = " = cnvtdatetime(rChildren->QUAL1[det_cnt]->PREV_END_EFF_DT_TM) "
   SET ddp_request->stmt[9].str = concat(" where ",trim(rchildren->qual1[det_cnt].attribute_name))
   SET ddp_request->stmt[10].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID "
   SET ddp_request->stmt[11].str = concat(" and ",trim(rchildren->qual1[det_cnt].primary_key_attr))
   SET ddp_request->stmt[12].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[13].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE (ucb_revdel(dummy=i2) =null)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 12
   SET stat = alterlist(ddp_request->stmt,12)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[7].str = "active_ind = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_IND, "
   SET ddp_request->stmt[8].str =
   "active_status_cd = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_STATUS_CD "
   SET ddp_request->stmt[9].str = " where "
   SET ddp_request->stmt[10].str = trim(rchildren->qual1[det_cnt].primary_key_attr)
   SET ddp_request->stmt[11].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[12].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE (ucb_reveff2(dummy=i2) =null)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 13
   SET stat = alterlist(ddp_request->stmt,13)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[7].str = "end_effective_dt_tm "
   SET ddp_request->stmt[8].str = " = cnvtdatetime(rChildren->QUAL1[det_cnt]->PREV_END_EFF_DT_TM) "
   SET ddp_request->stmt[9].str = concat(" where ",trim(rchildren->qual1[det_cnt].attribute_name))
   SET ddp_request->stmt[10].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID "
   SET ddp_request->stmt[11].str = concat(" and ",trim(rchildren->qual1[det_cnt].primary_key_attr))
   SET ddp_request->stmt[12].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[13].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_upt_bypassuid(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = 14
   SET stat = alterlist(ddp_request->stmt,14)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name))
   SET ddp_request->stmt[2].str = " set updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[3].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[4].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[5].str = "updt_task = TASK_NBR, "
   SET ddp_request->stmt[6].str = trim(rchildren->qual1[det_cnt].attribute_name)
   SET ddp_request->stmt[7].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID "
   SET ddp_request->stmt[8].str = " where "
   SET ddp_request->stmt[9].str = trim(rchildren->qual1[det_cnt].attribute_name)
   SET ddp_request->stmt[10].str = " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID and "
   SET ddp_request->stmt[11].str = trim(rchildren->qual1[det_cnt].primary_key_attr)
   SET ddp_request->stmt[12].str = " = rChildren->QUAL1[det_cnt]->ENTITY_ID "
   SET ddp_request->stmt[13].str = " with nocounter go "
   EXECUTE dm_daf_parser
 END ;Subroutine
#check_error
 IF (ucb_failed != false)
  ROLLBACK
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  SET error_cnt += 1
  SET stat = alterlist(reply->error,error_cnt)
  SELECT INTO "nl:"
   y = seq(combine_error_seq,nextval)
   FROM dual
   DETAIL
    next_seq_val = cnvtreal(y)
   WITH nocounter
  ;end select
  CALL upd_cmb_audit(ucb_audit_id,next_seq_val,1)
  SET etype = fillstring(50," ")
  IF (ucb_failed=3)
   SET etype = "GEN_NBR_ERROR"
  ELSEIF (ucb_failed=4)
   SET etype = "INSERT_ERROR"
  ELSEIF (ucb_failed=5)
   SET etype = "UPDATE_ERROR"
  ELSEIF (ucb_failed=6)
   SET etype = "REPLACE_ERROR"
  ELSEIF (ucb_failed=7)
   SET etype = "DELETE_ERROR"
  ELSEIF (ucb_failed=8)
   SET etype = "UNDELETE_ERROR"
  ELSEIF (ucb_failed=9)
   SET etype = "REMOVE_ERROR"
  ELSEIF (ucb_failed=10)
   SET etype = "ATTRIBUTE_ERROR"
  ELSEIF (ucb_failed=11)
   SET etype = "LOCK_ERROR"
  ELSEIF (ucb_failed=12)
   SET etype = "NONE_FOUND"
  ELSEIF (ucb_failed=13)
   SET etype = "SELECT_ERROR"
  ELSEIF (ucb_failed=14)
   SET etype = "DATA_ERROR"
  ELSEIF (ucb_failed=15)
   SET etype = "GENERAL_ERROR"
  ELSEIF (ucb_failed=16)
   SET etype = "REACTIVATE_ERROR"
  ELSEIF (ucb_failed=17)
   SET etype = "EFF_ERROR"
  ELSEIF (ucb_failed=18)
   SET etype = "CCL_ERROR"
  ELSEIF (ucb_failed=19)
   SET etype = "RECALC_ERROR"
  ELSEIF (ucb_failed=20)
   SET etype = "NO_PRIMARY_KEY"
  ENDIF
  UPDATE  FROM dm_combine_error dce
   SET dce.calling_script = call_script, dce.operation_type = "UNCOMBINE", dce.parent_entity =
    request->parent_table,
    dce.combine_id = parent_combine_id, dce.from_id = request->xxx_uncombine[ucb_cnt].from_xxx_id,
    dce.to_id = request->xxx_uncombine[ucb_cnt].to_xxx_id,
    dce.encntr_id = request->xxx_uncombine[ucb_cnt].encntr_id, dce.error_table = error_table, dce
    .error_type = etype,
    dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false, dce.error_msg = substring(1,
     132,request->error_message),
    dce.combine_mode = request->cmb_mode, dce.updt_id = reqinfo->updt_id, dce.updt_task = reqinfo->
    updt_task,
    dce.updt_applctx = reqinfo->updt_applctx, dce.updt_cnt = (dce.updt_cnt+ 1), dce.updt_dt_tm =
    cnvtdatetime(sysdate),
    dce.transaction_type = request->transaction_type, dce.application_flag = request->xxx_uncombine[1
    ].application_flag
   WHERE dce.combine_error_id=next_seq_val
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_combine_error dce
    SET dce.combine_error_id = next_seq_val, dce.calling_script = call_script, dce.operation_type =
     "UNCOMBINE",
     dce.parent_entity = request->parent_table, dce.combine_id = parent_combine_id, dce.from_id =
     request->xxx_uncombine[ucb_cnt].from_xxx_id,
     dce.to_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, dce.encntr_id = request->xxx_uncombine[
     ucb_cnt].encntr_id, dce.error_table = error_table,
     dce.error_type = etype, dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false,
     dce.error_msg = substring(1,132,request->error_message), dce.combine_mode = request->cmb_mode,
     dce.updt_id = reqinfo->updt_id,
     dce.updt_task = reqinfo->updt_task, dce.updt_applctx = reqinfo->updt_applctx, dce.updt_cnt =
     init_updt_cnt,
     dce.updt_dt_tm = cnvtdatetime(sysdate), dce.transaction_type = request->transaction_type, dce
     .application_flag = request->xxx_uncombine[1].application_flag
    WITH nocounter
   ;end insert
  ENDIF
  SET reply->error[error_cnt].create_dt_tm = cnvtdatetime(sysdate)
  SET reply->error[error_cnt].from_id = request->xxx_uncombine[ucb_cnt].from_xxx_id
  SET reply->error[error_cnt].to_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
  SET reply->error[error_cnt].encntr_id = request->xxx_uncombine[ucb_cnt].encntr_id
  SET reply->error[error_cnt].error_table = error_table
  SET reply->error[error_cnt].error_type = etype
  SET reply->error[error_cnt].error_msg = request->error_message
  IF (ucb_failed=ccl_error)
   UPDATE  FROM dm_combine_error
    SET error_msg = substring(1,132,ermsg)
    WHERE combine_error_id=next_seq_val
    WITH nocounter
   ;end update
   SET reply->error[error_cnt].error_msg = ermsg
  ENDIF
  COMMIT
 ELSE
  SET reqinfo->commit_ind = true
  SET reply->status_data.status = "S"
 ENDIF
#du_end_script
END GO
