CREATE PROGRAM dm_uncombine2:dba
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
 DECLARE get_gdpr_table(null) = null
 IF (validate(rcmbgdpr->qual[1].cmb_entity,"-1")="-1")
  FREE SET rcmbgdpr
  RECORD rcmbgdpr(
    1 gdpr_table_count = i4
    1 qual[100]
      2 cmb_entity = c30
      2 cmb_entity_drr = c30
  )
 ENDIF
 SUBROUTINE get_gdpr_table(null)
  DECLARE gdpr_cnt = i4 WITH protect, noconstant(0)
  SELECT DISTINCT INTO "nl:"
   tr.table_name, tr.drr_table_name
   FROM dm_table_relationships tr
   WHERE tr.drr_flag=1
    AND  EXISTS (
   (SELECT
    "x"
    FROM user_tables ut
    WHERE ut.table_name=tr.drr_table_name))
   ORDER BY tr.table_name, tr.drr_table_name
   DETAIL
    gdpr_cnt += 1
    IF (mod(gdpr_cnt,100)=1
     AND gdpr_cnt != 1)
     stat = alter(rcmbgdpr->qual,(gdpr_cnt+ 99))
    ENDIF
    rcmbgdpr->qual[gdpr_cnt].cmb_entity = tr.table_name, rcmbgdpr->qual[gdpr_cnt].cmb_entity_drr = tr
    .drr_table_name
   FOOT REPORT
    stat = alter(rcmbgdpr->qual,gdpr_cnt), rcmbgdpr->gdpr_table_count = gdpr_cnt
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (find_drr_table(live_table_name=c30) =c30)
   DECLARE flt_idx = i4 WITH protect, noconstant(0)
   DECLARE flt_drr_found = i4 WITH protect, noconstant(0)
   DECLARE flt_drr_table = c30 WITH protect, noconstant("<TABLE NOT FOUND>")
   DECLARE flt_drr_count = i4 WITH protect, noconstant(size(rcmbgdpr->qual,5))
   SET flt_drr_found = locateval(flt_idx,1,flt_drr_count,live_table_name,rcmbgdpr->qual[flt_idx].
    cmb_entity)
   IF (flt_drr_found > 0)
    SET flt_drr_table = rcmbgdpr->qual[flt_drr_found].cmb_entity_drr
   ENDIF
   RETURN(flt_drr_table)
 END ;Subroutine
 SUBROUTINE (find_live_table(drr_table_name=c30) =c30)
   DECLARE flt_idx = i4 WITH protect, noconstant(0)
   DECLARE flt_live_found = i4 WITH protect, noconstant(0)
   DECLARE flt_live_table = c30 WITH protect, noconstant("<TABLE NOT FOUND>")
   DECLARE flt_live_count = i4 WITH protect, noconstant(size(rcmbgdpr->qual,5))
   SET flt_live_found = locateval(flt_idx,1,flt_live_count,drr_table_name,rcmbgdpr->qual[flt_idx].
    cmb_entity_drr)
   IF (flt_live_found > 0)
    SET flt_live_table = rcmbgdpr->qual[flt_live_found].cmb_entity
   ENDIF
   RETURN(flt_live_table)
 END ;Subroutine
 SET trace = errorclear
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 xxx_combine_id[*]
      2 combine_id = f8
      2 parent_table = c50
      2 from_xxx_is = f8
      2 to_xxx_id = f8
    1 error[*]
      2 create_dt_tm = dq8
      2 parent_table = c50
      2 from_id = f8
      2 to_id = f8
      2 error_table = c32
      2 error_type = vc
      2 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD rchildren(
   1 qual1[*]
     2 xxx_combine_det_id = f8
     2 entity_name = c32
     2 entity_id = f8
     2 pk_size = i4
     2 entity_pk[*]
       3 col_name = c30
       3 data_type = c30
       3 data_char = c100
       3 data_number = f8
       3 data_date = dq8
     2 combine_action_cd = f8
     2 attribute_name = c32
     2 prev_active_ind = i2
     2 prev_active_status_cd = f8
     2 prev_end_eff_dt_tm = dq8
     2 combine_desc_cd = f8
     2 to_record_ind = i2
     2 script_name = c50
     2 del_chg_id_ind = i2
     2 script_run_order = i4
     2 ignore_ind = i2
     2 ucb2_audit_id = f8
 )
 DECLARE next_seq_val = f8
 DECLARE du2_cmb_dt_tm_ind = i2 WITH protect
 DECLARE revdel = f8 WITH protect, noconstant(0.0)
 DECLARE revendeff = f8 WITH protect, noconstant(0.0)
 DECLARE ucb2_group_id = f8 WITH protect, noconstant(0.0)
 DECLARE ucb2_audit_id = f8 WITH protect, noconstant(0.0)
 DECLARE ucb2_group_ndx = i4 WITH protect, noconstant(0)
 DECLARE noop = f8 WITH protect, noconstant(0.0)
 DECLARE ucb2_drr_table = c32 WITH protect, noconstant(" ")
 DECLARE ucb2_drr_count1 = i4 WITH protect, noconstant(0)
 DECLARE ucb2_gdpr_idx = i4 WITH protect, noconstant(0)
 DECLARE bypass_uid = f8 WITH protect, noconstant(0.0)
 SET du2_cmb_dt_tm_ind = 0
 SET parent_table = request->parent_table
 SET failed = false
 SET ucb_failed = false
 SET ercode = 0
 SET init_updt_cnt = 0
 SET max_script_run_order = 1
 SET nbr_to_ucb = 0
 SET next_seq_val = 0.0
 SET pk_count = 0
 SET ucb_dummy = 0
 SET ermsg = fillstring(132," ")
 SET error_table = fillstring(50," ")
 SET p_buff[20] = fillstring(132," ")
 SET pk_type = fillstring(30," ")
 SET cmb_type = 0.0
 SET parent_combine_id = 0.0
 SET del = 0.0
 SET upt = 0.0
 SET add = 0.0
 SET eff = 0.0
 SET physdel = 0.0
 SET recalc = 0.0
 SET combinedaway = 0.0
 SET noop = 0.0
 SET bypass_uid = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning="COMBINED"
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
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   CASE (c.cdf_meaning)
    OF "DEL":
     del = c.code_value
    OF "UPT":
     upt = c.code_value
    OF "ADD":
     add = c.code_value
    OF "EFF":
     eff = c.code_value
    OF "PHYSDEL":
     physdel = c.code_value
    OF "RECALC":
     recalc = c.code_value
    OF "REVDEL":
     revdel = c.code_value
    OF "REVENDEFF":
     revendeff = c.code_value
    OF "NOOP":
     noop = c.code_value
    OF "BYPASS_UID":
     bypass_uid = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (((del=0) OR (((upt=0) OR (((add=0) OR (((eff=0) OR (((physdel=0) OR (((recalc=0) OR (((revdel=0)
  OR (((revendeff=0) OR (noop=0)) )) )) )) )) )) )) )) )
  SET ucb_failed = data_error
  SET request->error_message =
  "One or more combine_action_cds (code_set = 327) are either not active or not effective."
  SET error_table = "CODE_VALUE"
  GO TO check_error
 ENDIF
 CASE (parent_table)
  OF "PRSNL":
   SET cmb_id = "PERSON_ID"
  OF "LOCATION":
   SET cmb_id = "LOCATION_CD"
  OF "HEALTH_PLAN":
   SET cmb_id = "HEALTH_PLAN_ID"
  OF "ORGANIZATION":
   SET cmb_id = "ORGANIZATION_ID"
 ENDCASE
 IF ((cmb_drr_reply->gdpr_ind=1))
  CALL get_gdpr_table(null)
 ENDIF
 SET nbr_to_ucb = size(request->xxx_uncombine,5)
 SET swap_to_from = 0.0
 FOR (inx = 1 TO nbr_to_ucb)
   SET swap_to_from = request->xxx_uncombine[inx].from_xxx_id
   SET request->xxx_uncombine[inx].from_xxx_id = request->xxx_uncombine[inx].to_xxx_id
   SET request->xxx_uncombine[inx].to_xxx_id = swap_to_from
 ENDFOR
 RANGE OF cmbcol IS combine
 SET du2_cmb_dt_tm_ind = evaluate(validate(cmbcol.cmb_dt_tm,- (999999.0)),- (999999.0),0,1)
 FREE RANGE cmbcol
 SET ercode = error(ermsg,1)
 IF (ercode != 0)
  SET ucb_failed = ccl_error
  GO TO check_error
 ENDIF
 FOR (ucb_cnt = 1 TO nbr_to_ucb)
   SET det_cnt = 0
   SET ucb_count1 = 0
   SET pkcount = 0
   SET cmb_det_updt_cnt = 0
   SET activity_updt_cnt = 0
   SET activity_no_updt_cnt = 0
   SET ucb2_group_id = 0.0
   SET ucb2_audit_id = 0.0
   SET parent_combine_id = request->xxx_uncombine[ucb_cnt].xxx_combine_id
   IF (call_script="DM_CALL_UNCOMBINE"
    AND (request->parent_table="PRSNL"))
    SET stat = locateval(ucb2_group_ndx,1,size(rucbprsnl->ucb,5),parent_combine_id,rucbprsnl->ucb[
     ucb_cnt].prsnl_combine_id)
    SET ucb2_group_id = rucbprsnl->ucb[ucb2_group_ndx].ucb_group_id
   ENDIF
   SET ucb2_audit_id = ins_cmb_audit(request,ucb_cnt,call_script," "," ",
    " ",ucb2_group_id,"UNCOMBINE",0,1)
   SET req_error = 0
   IF ((request->cmb_mode != "RE-UCB"))
    SET p_buff[1] = concat("select into 'nl:'"," p.",cmb_id)
    SET p_buff[2] = concat("from ",trim(parent_table)," p")
    SET p_buff[3] = concat("where p.",cmb_id," = request->xxx_uncombine[ucb_cnt]->from_xxx_id")
    SET p_buff[4] = "and p.active_ind = 0"
    SET p_buff[5] = "detail"
    SET p_buff[6] = "req_error = 1"
    SET p_buff[7] = concat("request->error_message = 'Cannot uncombine - master ",trim(parent_table),
     " is inactive.'")
    SET p_buff[8] = "with nocounter go"
    FOR (buf_cnt = 1 TO 8)
      IF (dm_debug_cmb=1)
       CALL echo(p_buff[buf_cnt])
      ENDIF
      CALL parser(p_buff[buf_cnt])
      SET p_buff[buf_cnt] = fillstring(132," ")
    ENDFOR
    SET p_buff[1] = concat("select into 'nl:'"," p.",cmb_id)
    SET p_buff[2] = concat("from ",trim(parent_table)," p")
    SET p_buff[3] = concat("where p.",cmb_id," = request->xxx_uncombine[ucb_cnt]->to_xxx_id")
    SET p_buff[4] = "and p.active_ind = 1"
    SET p_buff[5] = "detail"
    SET p_buff[6] = "req_error = 1"
    SET p_buff[7] = concat("request->error_message = 'Cannot uncombine - combined away ",trim(
      parent_table)," is active.'")
    SET p_buff[8] = "with nocounter go"
    FOR (buf_cnt = 1 TO 8)
      IF (dm_debug_cmb=1)
       CALL echo(p_buff[buf_cnt])
      ENDIF
      CALL parser(p_buff[buf_cnt])
      SET p_buff[buf_cnt] = fillstring(132," ")
    ENDFOR
   ENDIF
   IF (req_error=1)
    SET ucb_failed = data_error
    SET error_table = "REQUEST"
    GO TO check_error
   ENDIF
   CALL ucb_combine(ucb_dummy)
   SELECT INTO "nl:"
    x.seq
    FROM combine_detail x
    WHERE (x.combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
     AND x.active_ind=1
    DETAIL
     ucb_count1 += 1, stat = alterlist(rchildren->qual1,ucb_count1), rchildren->qual1[ucb_count1].
     xxx_combine_det_id = x.combine_detail_id,
     rchildren->qual1[ucb_count1].entity_name = x.entity_name, rchildren->qual1[ucb_count1].entity_id
      = x.entity_id, rchildren->qual1[ucb_count1].combine_action_cd = x.combine_action_cd,
     rchildren->qual1[ucb_count1].attribute_name = x.attribute_name, rchildren->qual1[ucb_count1].
     prev_active_ind = x.prev_active_ind, rchildren->qual1[ucb_count1].prev_active_status_cd = x
     .prev_active_status_cd,
     rchildren->qual1[ucb_count1].prev_end_eff_dt_tm = x.prev_end_eff_dt_tm, rchildren->qual1[
     ucb_count1].to_record_ind = x.to_record_ind, rchildren->qual1[ucb_count1].script_run_order = 1,
     rchildren->qual1[ucb_count1].del_chg_id_ind = 0
     IF (x.combine_action_cd=noop)
      rchildren->qual1[ucb_count1].ignore_ind = 1
     ELSE
      rchildren->qual1[ucb_count1].ignore_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   CALL echorecord(rchildren)
   SET ucb2_drr_count1 = ucb_count1
   FOR (entity_cnt = 1 TO ucb_count1)
     SET pkcount = 0
     SELECT INTO "nl:"
      x.entity_id
      FROM entity_detail x
      WHERE (x.entity_id=rchildren->qual1[entity_cnt].entity_id)
      DETAIL
       pkcount += 1, stat = alterlist(rchildren->qual1[entity_cnt].entity_pk,pkcount), rchildren->
       qual1[entity_cnt].entity_pk[pkcount].col_name = x.column_name,
       rchildren->qual1[entity_cnt].entity_pk[pkcount].data_type = x.data_type, rchildren->qual1[
       entity_cnt].entity_pk[pkcount].data_number = x.data_number, rchildren->qual1[entity_cnt].
       entity_pk[pkcount].data_char = x.data_char,
       rchildren->qual1[entity_cnt].entity_pk[pkcount].data_date = x.data_date
      WITH nocounter
     ;end select
     SET rchildren->qual1[entity_cnt].pk_size = pkcount
     IF ((cmb_drr_reply->gdpr_ind=1))
      SET ucb2_drr_table = find_drr_table(rchildren->qual1[entity_cnt].entity_name)
      IF (operator(trim(rchildren->qual1[entity_cnt].entity_name,3),"regexplike","DRR$")=1)
       SET stat = movereclist(rchildren->qual1,rchildren->qual1,entity_cnt,ucb2_drr_count1,1,
        1)
       SET ucb2_drr_count1 += 1
       SET rchildren->qual1[ucb2_drr_count1].entity_name = find_live_table(rchildren->qual1[
        entity_cnt].entity_name)
       SET stat = moverec(rchildren->qual1[entity_cnt].entity_pk,rchildren->qual1[ucb2_drr_count1].
        entity_pk)
      ELSEIF (operator(trim(ucb2_drr_table,3),"regexplike","DRR$")=1)
       SET stat = movereclist(rchildren->qual1,rchildren->qual1,entity_cnt,ucb2_drr_count1,1,
        1)
       SET ucb2_drr_count1 += 1
       SET rchildren->qual1[ucb2_drr_count1].entity_name = ucb2_drr_table
       SET stat = moverec(rchildren->qual1[entity_cnt].entity_pk,rchildren->qual1[ucb2_drr_count1].
        entity_pk)
      ENDIF
     ENDIF
   ENDFOR
   SET ucb_count1 = ucb2_drr_count1
   IF (ucb_count1 > 0)
    SELECT INTO "nl:"
     rchildren->qual1[d.seq].entity_name
     FROM (dummyt d  WITH seq = value(ucb_count1)),
      dm_cmb_exception dce
     PLAN (d)
      JOIN (dce
      WHERE (dce.child_entity=rchildren->qual1[d.seq].entity_name)
       AND dce.parent_entity=parent_table
       AND dce.operation_type="UNCOMBINE")
     DETAIL
      rchildren->qual1[d.seq].script_name = dce.script_name, rchildren->qual1[d.seq].script_run_order
       = dce.script_run_order
      IF (dce.script_run_order > max_script_run_order)
       max_script_run_order = dce.script_run_order
      ENDIF
     WITH nocounter
    ;end select
    FOR (entity_cnt = 1 TO ucb_count1)
      IF (operator(trim(rchildren->qual1[entity_cnt].entity_name,3),"not regexplike","DRR$")=1
       AND (rchildren->qual1[entity_cnt].script_name > " "))
       SET ucb2_drr_table = find_drr_table(rchildren->qual1[entity_cnt].entity_name)
       IF (operator(trim(ucb2_drr_table,3),"regexplike","DRR$")=1)
        SET ucb2_gdpr_exist = 0
        SET ucb2_gdpr_exist = locateval(ucb2_gdpr_idx,1,ucb_count1,ucb2_drr_table,rchildren->qual1[
         ucb2_gdpr_idx].entity_name,
         rchildren->qual1[entity_cnt].xxx_combine_det_id,rchildren->qual1[ucb2_gdpr_idx].
         xxx_combine_det_id)
        IF (ucb2_gdpr_exist > 0
         AND size(trim(rchildren->qual1[ucb2_gdpr_exist].script_name,3),1)=0)
         SET rchildren->qual1[ucb2_gdpr_exist].script_name = rchildren->qual1[entity_cnt].script_name
         SET rchildren->qual1[ucb2_gdpr_exist].script_run_order = rchildren->qual1[entity_cnt].
         script_run_order
         IF ((rchildren->qual1[entity_cnt].script_name != "NONE"))
          SET rchildren->qual1[ucb2_gdpr_exist].ignore_ind = 1
         ELSE
          SET rchildren->qual1[ucb2_gdpr_exist].ignore_ind = rchildren->qual1[entity_cnt].ignore_ind
         ENDIF
         SET rchildren->qual1[ucb2_gdpr_exist].script_run_order = rchildren->qual1[entity_cnt].
         script_run_order
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    FOR (ecnt = 1 TO ucb_count1)
     CALL echo(build2("Loop Counter: ",ecnt))
     IF ((rchildren->qual1[ecnt].script_name != "NONE")
      AND (rchildren->qual1[ecnt].ignore_ind=0))
      SET rchildren->qual1[ecnt].ignore_ind = ucb_chk_ccl_def_tbl(rchildren->qual1[ecnt].entity_name)
      IF (dm_debug_cmb=1)
       CALL echo(build(rchildren->qual1[ecnt].entity_name,":",rchildren->qual1[ecnt].ignore_ind))
      ENDIF
      IF ((rchildren->qual1[ecnt].ignore_ind=- (1)))
       SET error_table = rchildren->qual1[ecnt].entity_name
       SET request->error_message = build("Table (",error_table,") does not have a CCL definition")
       SET ucb_failed = data_error
       GO TO check_error
      ENDIF
     ENDIF
    ENDFOR
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
    IF ((request->cmb_mode != "RE-UCB"))
     CALL ucb_parent(ucb_dummy)
    ENDIF
    FOR (script_run_cnt = 1 TO max_script_run_order)
      FOR (det_cnt = 1 TO ucb_count1)
        IF ((rchildren->qual1[det_cnt].ignore_ind=0))
         IF ((rchildren->qual1[det_cnt].script_run_order=script_run_cnt))
          SET error_table = rchildren->qual1[det_cnt].entity_name
          SET rchildren->qual1[det_cnt].ucb2_audit_id = ins_cmb_audit(request,ucb_cnt,call_script,
           rchildren->qual1[det_cnt].attribute_name,rchildren->qual1[det_cnt].entity_name,
           trim(rchildren->qual1[det_cnt].script_name,3),ucb2_group_id,"UNCOMBINE",0,2)
          IF (trim(rchildren->qual1[det_cnt].script_name)="")
           IF ((rchildren->qual1[det_cnt].pk_size=0))
            SET ucb_failed = no_primary_key
            SET request->error_message = concat("Table ",trim(rchildren->qual1[det_cnt].entity_name),
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
             CALL ucb_del2(ucb_dummy)
            ELSEIF ((rchildren->qual1[det_cnt].del_chg_id_ind=1))
             CALL ucb_del(ucb_dummy)
            ELSEIF ((rchildren->qual1[det_cnt].del_chg_id_ind=0))
             CALL ucb_del2(ucb_dummy)
            ENDIF
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
            CALL ucb_upt(ucb_dummy)
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=eff))
            CALL ucb_eff(ucb_dummy)
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=revdel))
            CALL ucb_revdel(ucb_dummy)
           ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=revendeff))
            CALL ucb_reveff(ucb_dummy)
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
            CALL echo(concat("execute ",rchildren->qual1[det_cnt].script_name," go"))
            CALL parser(concat("execute ",rchildren->qual1[det_cnt].script_name," go"))
            IF (ucb_failed != false
             AND ucb_failed != update_error
             AND ucb_failed != reactivate_error)
             GO TO check_error
            ELSEIF (((ucb_failed != update_error) OR (ucb_failed != reactivate_error)) )
             SET ucb_failed = false
            ENDIF
           ENDIF
          ENDIF
          SET ercode = error(ermsg,1)
          IF (ercode != 0)
           SET ucb_failed = ccl_error
           GO TO check_error
          ENDIF
          CALL upd_cmb_audit(rchildren->qual1[det_cnt].ucb2_audit_id,0.0,2)
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
    CALL ucb_combine_det(ucb_dummy)
   ENDIF
   SET ercode = error(ermsg,1)
   IF (ercode != 0)
    SET ucb_failed = ccl_error
    GO TO check_error
   ENDIF
   CALL upd_cmb_audit(ucb2_audit_id,0.0,1)
 ENDFOR
 SUBROUTINE ucb_combine(dummy)
   IF ((request->cmb_mode != "RE-UCB"))
    CALL parser("select into 'nl:' from COMBINE c ",0)
    CALL parser(concat(" where c.COMBINE_ID = ",build(request->xxx_uncombine[ucb_cnt].xxx_combine_id)
      ),0)
    CALL parser(" and c.active_ind = 1 with forupdate(c) go",1)
    SET ercode = error(ermsg,1)
    IF (ercode != 0)
     SET ucb_failed = lock_error
     SET request->error_message = concat("Could not obtain lock on COMBINE with COMBINE_ID = ",build(
       request->xxx_uncombine[ucb_cnt].xxx_combine_id),".")
     SET error_table = "COMBINE"
     GO TO check_error
    ELSEIF (curqual=0)
     SET ucb_failed = data_error
     SET request->error_message = concat("No row found on COMBINE with COMBINE_ID = ",build(request->
       xxx_uncombine[ucb_cnt].xxx_combine_id),".")
     SET error_table = "COMBINE"
     GO TO check_error
    ENDIF
   ENDIF
   CALL parser(" update into combine set ",0)
   CALL parser(" active_ind = FALSE, ",0)
   CALL parser(" active_status_cd = reqdata->inactive_status_cd, ",0)
   CALL parser(" transaction_type = request->transaction_type, ",0)
   CALL parser(" application_flag = request->xxx_uncombine[1]->application_flag, ",0)
   CALL parser(" updt_id = reqinfo->updt_id, ",0)
   CALL parser(" updt_dt_tm = cnvtdatetime(curdate,curtime3), ",0)
   CALL parser(" updt_applctx = reqinfo->updt_applctx, ",0)
   CALL parser(" updt_cnt = updt_cnt + 1, ",0)
   IF (du2_cmb_dt_tm_ind=1)
    CALL parser(" ucb_dt_tm = cnvtdatetime(curdate,curtime3), ",0)
    CALL parser(" ucb_updt_id = reqinfo->updt_id,  ",0)
    CALL parser(" cmb_dt_tm = nullval(cmb_dt_tm, updt_dt_tm), ",0)
    CALL parser(" cmb_updt_id = nullval(cmb_updt_id, updt_id), ",0)
   ENDIF
   CALL parser(" updt_task = reqinfo->updt_task ",0)
   CALL parser(" where  combine_id = request->xxx_uncombine[ucb_cnt]->xxx_combine_id ",0)
   IF ((request->cmb_mode != "RE-UCB"))
    CALL parser(" and  active_ind = 1 ",0)
   ENDIF
   CALL parser(" with   nocounter go",1)
   IF (curqual=0)
    SET ucb_failed = delete_error
    SET request->error_message = concat("Could not inactivate record on COMBINE table.")
    SET error_table = "COMBINE"
    GO TO check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE ucb_combine_det(dummy)
   UPDATE  FROM combine_detail
    SET active_ind = false, active_status_cd = reqdata->inactive_status_cd, updt_id = reqinfo->
     updt_id,
     updt_dt_tm = cnvtdatetime(sysdate), updt_applctx = reqinfo->updt_applctx, updt_cnt = (updt_cnt+
     1),
     updt_task = reqinfo->updt_task
    WHERE (combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
     AND active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = delete_error
    SET request->error_message = concat("No COMBINE_DETAIL records were inactivated.")
    SET error_table = "COMBINE_DETAIL"
    GO TO check_error
   ENDIF
   SET cmb_det_updt_cnt = curqual
 END ;Subroutine
 SUBROUTINE ucb_parent(dummy)
   SET p_buff[1] = concat("update into ",trim(parent_table)," set")
   SET p_buff[2] = "active_ind = TRUE, "
   SET p_buff[3] = "active_status_cd = reqdata->active_status_cd, "
   SET p_buff[4] = "updt_id = reqinfo->updt_id, "
   SET p_buff[5] = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET p_buff[6] = "updt_applctx = reqinfo->updt_applctx, "
   SET p_buff[7] = "updt_cnt = updt_cnt + 1, "
   SET p_buff[8] = "updt_task = reqinfo->updt_task "
   SET p_buff[9] = concat("where ",trim(cmb_id)," = request->xxx_uncombine[ucb_cnt]->to_xxx_id")
   SET p_buff[10] = "with nocounter go"
   FOR (buf_cnt = 1 TO 10)
     IF (dm_debug_cmb=1)
      CALL echo(p_buff[buf_cnt])
     ENDIF
     CALL parser(p_buff[buf_cnt])
     SET p_buff[buf_cnt] = fillstring(132," ")
   ENDFOR
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET request->error_message = concat("Could not re-activate record on ",trim(parent_table),
     " table.")
    SET error_table = parent_table
    GO TO check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE ucb_add(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = (10+ rchildren->qual1[det_cnt].pk_size)
   SET stat = alterlist(ddp_request->stmt,ddp_request->cnt)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set")
   SET ddp_request->stmt[2].str = "active_ind = FALSE, "
   SET ddp_request->stmt[3].str = "active_status_cd = reqdata->inactive_status_cd, "
   SET ddp_request->stmt[4].str = "updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[5].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[6].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[7].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[8].str = "updt_task = reqinfo->updt_task "
   SET ddp_request->stmt[9].str = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].
     col_name))
   SET pk_type = rchildren->qual1[det_cnt].entity_pk[1].data_type
   CASE (pk_type)
    OF "INTEGER":
    OF "DOUBLE":
    OF "BIGINT":
    OF "FLOAT":
    OF "NUMBER":
     SET ddp_request->stmt[10].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number"
    OF "VARCHAR":
    OF "VARCHAR2":
    OF "CHAR":
     SET ddp_request->stmt[10].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_char"
    OF "TIME":
    OF "DATE":
     SET ddp_request->stmt[10].str =
     " = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[1]->data_date)"
   ENDCASE
   SET pk_count = rchildren->qual1[det_cnt].pk_size
   FOR (ucb_cnt1 = 2 TO pk_count)
    SET pk_type = rchildren->qual1[det_cnt].entity_pk[ucb_cnt1].data_type
    CASE (pk_type)
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "FLOAT":
     OF "NUMBER":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_number")
     OF "VARCHAR":
     OF "VARCHAR2":
     OF "CHAR":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_char")
     OF "TIME":
     OF "DATE":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[",build(
        ucb_cnt1),"]->data_date)")
    ENDCASE
   ENDFOR
   SET ddp_request->stmt[(pk_count+ 10)].str = "with nocounter go"
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_del(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = (10+ rchildren->qual1[det_cnt].pk_size)
   SET stat = alterlist(ddp_request->stmt,ddp_request->cnt)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set")
   SET ddp_request->stmt[2].str = concat(trim(rchildren->qual1[det_cnt].attribute_name),
    " = request->xxx_uncombine[ucb_cnt]->to_xxx_id, ")
   SET ddp_request->stmt[3].str = "active_ind = rChildren->qual1[det_cnt]->prev_active_ind, "
   SET ddp_request->stmt[4].str =
   "active_status_cd = rChildren->qual1[det_cnt]->prev_active_status_cd, "
   SET ddp_request->stmt[5].str = "updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[6].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[7].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[8].str = "updt_cnt = updt_cnt + 1, updt_task = reqinfo->updt_task "
   SET ddp_request->stmt[9].str = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].
     col_name))
   SET pk_type = rchildren->qual1[det_cnt].entity_pk[1].data_type
   CASE (pk_type)
    OF "INTEGER":
    OF "DOUBLE":
    OF "BIGINT":
    OF "FLOAT":
    OF "NUMBER":
     SET ddp_request->stmt[10].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number"
    OF "VARCHAR":
    OF "VARCHAR2":
    OF "CHAR":
     SET ddp_request->stmt[10].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_char"
    OF "TIME":
    OF "DATE":
     SET ddp_request->stmt[10].str =
     " = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[1]->data_date)"
   ENDCASE
   SET pk_count = rchildren->qual1[det_cnt].pk_size
   FOR (ucb_cnt1 = 2 TO pk_count)
    SET pk_type = rchildren->qual1[det_cnt].entity_pk[ucb_cnt1].data_type
    CASE (pk_type)
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "FLOAT":
     OF "NUMBER":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_number")
     OF "VARCHAR":
     OF "VARCHAR2":
     OF "CHAR":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_char")
     OF "TIME":
     OF "DATE":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[",build(
        ucb_cnt1),"]->data_date)")
    ENDCASE
   ENDFOR
   SET ddp_request->stmt[(pk_count+ 10)].str = "with nocounter go"
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_del2(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = (10+ rchildren->qual1[det_cnt].pk_size)
   SET stat = alterlist(ddp_request->stmt,ddp_request->cnt)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set")
   SET ddp_request->stmt[2].str = "active_ind = rChildren->qual1[det_cnt]->prev_active_ind, "
   SET ddp_request->stmt[3].str =
   "active_status_cd = rChildren->qual1[det_cnt]->prev_active_status_cd, "
   SET ddp_request->stmt[4].str = "updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[5].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[6].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[7].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[8].str = "updt_task = reqinfo->updt_task "
   SET ddp_request->stmt[9].str = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].
     col_name))
   SET pk_type = rchildren->qual1[det_cnt].entity_pk[1].data_type
   CASE (pk_type)
    OF "INTEGER":
    OF "DOUBLE":
    OF "BIGINT":
    OF "FLOAT":
    OF "NUMBER":
     SET ddp_request->stmt[10].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number"
    OF "VARCHAR":
    OF "VARCHAR2":
    OF "CHAR":
     SET ddp_request->stmt[10].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_char"
    OF "TIME":
    OF "DATE":
     SET ddp_request->stmt[10].str =
     " = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[1]->data_date)"
   ENDCASE
   SET pk_count = rchildren->qual1[det_cnt].pk_size
   FOR (ucb_cnt1 = 2 TO pk_count)
    SET pk_type = rchildren->qual1[det_cnt].entity_pk[ucb_cnt1].data_type
    CASE (pk_type)
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "FLOAT":
     OF "NUMBER":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_number")
     OF "VARCHAR":
     OF "VARCHAR2":
     OF "CHAR":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_char")
     OF "TIME":
     OF "DATE":
      SET ddp_request->stmt[(ucb_cnt1+ 9)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[",build(
        ucb_cnt1),"]->data_date)")
    ENDCASE
   ENDFOR
   SET ddp_request->stmt[(pk_count+ 10)].str = "with nocounter go"
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_upt(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = (9+ rchildren->qual1[det_cnt].pk_size)
   SET stat = alterlist(ddp_request->stmt,ddp_request->cnt)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set")
   SET ddp_request->stmt[2].str = concat(trim(rchildren->qual1[det_cnt].attribute_name),
    " = request->xxx_uncombine[ucb_cnt]->to_xxx_id, ")
   SET ddp_request->stmt[3].str = "updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[4].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[5].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[6].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[7].str = "updt_task = reqinfo->updt_task "
   SET ddp_request->stmt[8].str = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].
     col_name))
   SET pk_type = rchildren->qual1[det_cnt].entity_pk[1].data_type
   CASE (pk_type)
    OF "INTEGER":
    OF "DOUBLE":
    OF "BIGINT":
    OF "FLOAT":
    OF "NUMBER":
     SET ddp_request->stmt[9].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number"
    OF "VARCHAR":
    OF "VARCHAR2":
    OF "CHAR":
     SET ddp_request->stmt[9].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_char"
    OF "TIME":
    OF "DATE":
     SET ddp_request->stmt[9].str =
     " = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[1]->data_date)"
   ENDCASE
   SET pk_count = rchildren->qual1[det_cnt].pk_size
   FOR (ucb_cnt1 = 2 TO pk_count)
    SET pk_type = rchildren->qual1[det_cnt].entity_pk[ucb_cnt1].data_type
    CASE (pk_type)
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "FLOAT":
     OF "NUMBER":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_number")
     OF "VARCHAR":
     OF "VARCHAR2":
     OF "CHAR":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_char")
     OF "TIME":
     OF "DATE":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[",build(
        ucb_cnt1),"]->data_date)")
    ENDCASE
   ENDFOR
   SET ddp_request->stmt[(pk_count+ 9)].str = "with nocounter go"
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_eff(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = (9+ rchildren->qual1[det_cnt].pk_size)
   SET stat = alterlist(ddp_request->stmt,ddp_request->cnt)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set")
   SET ddp_request->stmt[2].str =
   "end_effective_dt_tm = cnvtdatetime(rChildren->qual1[det_cnt]->prev_end_eff_dt_tm), "
   SET ddp_request->stmt[3].str = "updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[4].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[5].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[6].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[7].str = "updt_task = reqinfo->updt_task "
   SET ddp_request->stmt[8].str = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].
     col_name))
   SET pk_type = rchildren->qual1[det_cnt].entity_pk[1].data_type
   CASE (pk_type)
    OF "INTEGER":
    OF "DOUBLE":
    OF "BIGINT":
    OF "FLOAT":
    OF "NUMBER":
     SET ddp_request->stmt[9].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number"
    OF "VARCHAR":
    OF "VARCHAR2":
    OF "CHAR":
     SET ddp_request->stmt[9].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_char"
    OF "TIME":
    OF "DATE":
     SET ddp_request->stmt[9].str =
     " = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[1]->data_date)"
   ENDCASE
   SET pk_count = rchildren->qual1[det_cnt].pk_size
   FOR (ucb_cnt1 = 2 TO pk_count)
    SET pk_type = rchildren->qual1[det_cnt].entity_pk[ucb_cnt1].data_type
    CASE (pk_type)
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "FLOAT":
     OF "NUMBER":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_number")
     OF "VARCHAR":
     OF "VARCHAR2":
     OF "CHAR":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_char")
     OF "TIME":
     OF "DATE":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[",build(
        ucb_cnt1),"]->data_date)")
    ENDCASE
   ENDFOR
   SET ddp_request->stmt[(pk_count+ 9)].str = "with nocounter go"
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE (ucb_revdel(dummy=i2) =null)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = (9+ rchildren->qual1[det_cnt].pk_size)
   SET stat = alterlist(ddp_request->stmt,ddp_request->cnt)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set ")
   SET ddp_request->stmt[2].str = "active_ind = rChildren->qual1[det_cnt]->prev_active_ind, "
   SET ddp_request->stmt[3].str =
   "active_status_cd = rChildren->qual1[det_cnt]->prev_active_status_cd, "
   SET ddp_request->stmt[4].str = "updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[5].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[6].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[7].str = "updt_cnt = updt_cnt + 1, updt_task = reqinfo->updt_task "
   SET ddp_request->stmt[8].str = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].
     col_name))
   SET pk_type = rchildren->qual1[det_cnt].entity_pk[1].data_type
   CASE (pk_type)
    OF "INTEGER":
    OF "DOUBLE":
    OF "BIGINT":
    OF "FLOAT":
    OF "NUMBER":
     SET ddp_request->stmt[9].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number"
    OF "VARCHAR":
    OF "VARCHAR2":
    OF "CHAR":
     SET ddp_request->stmt[9].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_char"
    OF "TIME":
    OF "DATE":
     SET ddp_request->stmt[9].str =
     " = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[1]->data_date)"
   ENDCASE
   SET pk_count = rchildren->qual1[det_cnt].pk_size
   FOR (ucb_cnt1 = 2 TO pk_count)
    SET pk_type = rchildren->qual1[det_cnt].entity_pk[ucb_cnt1].data_type
    CASE (pk_type)
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "FLOAT":
     OF "NUMBER":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_number")
     OF "VARCHAR":
     OF "VARCHAR2":
     OF "CHAR":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_char")
     OF "TIME":
     OF "DATE":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[",build(
        ucb_cnt1),"]->data_date)")
    ENDCASE
   ENDFOR
   SET ddp_request->stmt[(pk_count+ 9)].str = "with nocounter go"
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE (ucb_reveff(dummy=i2) =null)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = (9+ rchildren->qual1[det_cnt].pk_size)
   SET stat = alterlist(ddp_request->stmt,ddp_request->cnt)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set")
   SET ddp_request->stmt[2].str =
   "end_effective_dt_tm = cnvtdatetime(rChildren->qual1[det_cnt]->prev_end_eff_dt_tm), "
   SET ddp_request->stmt[3].str = "updt_id = reqinfo->updt_id, "
   SET ddp_request->stmt[4].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[5].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[6].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[7].str = "updt_task = reqinfo->updt_task "
   SET ddp_request->stmt[8].str = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].
     col_name))
   SET pk_type = rchildren->qual1[det_cnt].entity_pk[1].data_type
   CASE (pk_type)
    OF "INTEGER":
    OF "DOUBLE":
    OF "BIGINT":
    OF "FLOAT":
    OF "NUMBER":
     SET ddp_request->stmt[9].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number"
    OF "VARCHAR":
    OF "VARCHAR2":
    OF "CHAR":
     SET ddp_request->stmt[9].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_char"
    OF "TIME":
    OF "DATE":
     SET ddp_request->stmt[9].str =
     " = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[1]->data_date)"
   ENDCASE
   SET pk_count = rchildren->qual1[det_cnt].pk_size
   FOR (ucb_cnt1 = 2 TO pk_count)
    SET pk_type = rchildren->qual1[det_cnt].entity_pk[ucb_cnt1].data_type
    CASE (pk_type)
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "FLOAT":
     OF "NUMBER":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_number")
     OF "VARCHAR":
     OF "VARCHAR2":
     OF "CHAR":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_char")
     OF "TIME":
     OF "DATE":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[",build(
        ucb_cnt1),"]->data_date)")
    ENDCASE
   ENDFOR
   SET ddp_request->stmt[(pk_count+ 9)].str = "with nocounter go"
   EXECUTE dm_daf_parser
 END ;Subroutine
 SUBROUTINE ucb_upt_bypassuid(dummy)
   SET stat = initrec(ddp_request)
   SET ddp_request->cnt = (8+ rchildren->qual1[det_cnt].pk_size)
   SET stat = alterlist(ddp_request->stmt,ddp_request->cnt)
   SET ddp_request->stmt[1].str = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set")
   SET ddp_request->stmt[2].str = concat(trim(rchildren->qual1[det_cnt].attribute_name),
    " = request->xxx_uncombine[ucb_cnt]->to_xxx_id, ")
   SET ddp_request->stmt[3].str = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET ddp_request->stmt[4].str = "updt_applctx = reqinfo->updt_applctx, "
   SET ddp_request->stmt[5].str = "updt_cnt = updt_cnt + 1, "
   SET ddp_request->stmt[6].str = "updt_task = reqinfo->updt_task "
   SET ddp_request->stmt[7].str = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].
     col_name))
   SET pk_type = rchildren->qual1[det_cnt].entity_pk[1].data_type
   CASE (pk_type)
    OF "INTEGER":
    OF "DOUBLE":
    OF "BIGINT":
    OF "FLOAT":
    OF "NUMBER":
     SET ddp_request->stmt[8].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number"
    OF "VARCHAR":
    OF "VARCHAR2":
    OF "CHAR":
     SET ddp_request->stmt[8].str = " = rChildren->qual1[det_cnt]->entity_pk[1]->data_char"
    OF "TIME":
    OF "DATE":
     SET ddp_request->stmt[8].str =
     " = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[1]->data_date)"
   ENDCASE
   SET pk_count = rchildren->qual1[det_cnt].pk_size
   FOR (ucb_cnt1 = 2 TO pk_count)
    SET pk_type = rchildren->qual1[det_cnt].entity_pk[ucb_cnt1].data_type
    CASE (pk_type)
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "FLOAT":
     OF "NUMBER":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_number")
     OF "VARCHAR":
     OF "VARCHAR2":
     OF "CHAR":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = rChildren->qual1[det_cnt]->entity_pk[",build(ucb_cnt1),
       "]->data_char")
     OF "TIME":
     OF "DATE":
      SET ddp_request->stmt[(ucb_cnt1+ 8)].str = concat("  and ",trim(rchildren->qual1[det_cnt].
        entity_pk[ucb_cnt1].col_name)," = cnvtdatetime(rChildren->qual1[det_cnt]->entity_pk[",build(
        ucb_cnt1),"]->data_date)")
    ENDCASE
   ENDFOR
   SET ddp_request->stmt[(pk_count+ 8)].str = "with nocounter go"
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
  CALL upd_cmb_audit(ucb2_audit_id,next_seq_val,1)
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
   SET dce.calling_script = "DM_UNCOMBINE2", dce.operation_type = "UNCOMBINE", dce.parent_entity =
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
    SET dce.combine_error_id = next_seq_val, dce.calling_script = "DM_UNCOMBINE2", dce.operation_type
      = "UNCOMBINE",
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
  SET reply->error[error_cnt].parent_table = request->parent_table
  SET reply->error[error_cnt].create_dt_tm = cnvtdatetime(sysdate)
  SET reply->error[error_cnt].from_id = request->xxx_uncombine[ucb_cnt].from_xxx_id
  SET reply->error[error_cnt].to_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
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
END GO
