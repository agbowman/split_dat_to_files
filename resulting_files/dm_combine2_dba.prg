CREATE PROGRAM dm_combine2:dba
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
 DECLARE metadatacount = i4 WITH protect, noconstant(0)
 DECLARE metadatapelist = vc WITH protect, noconstant(" ")
 DECLARE cmblistindex = i4 WITH protect, noconstant(0)
 DECLARE cmblistposition = i4 WITH protect, noconstant(0)
 IF (validate(rcmbmetadatalist->qual[1].cmb_entity,"-1")="-1")
  FREE SET rcmbmetadatalist
  RECORD rcmbmetadatalist(
    1 qual[*]
      2 cmb_entity = c30
      2 cmb_entity_attribute = c30
      2 cmb_entity_pk = c30
      2 cmb_entity_encntr_attr = c30
      2 upt_ind = i2
      2 active_ind = i2
      2 ignore_ind = i2
      2 cmb_audit_id = f8
      2 cmb_action_cd = f8
      2 where_clause = vc
    1 custom[*]
      2 table_name = c30
      2 script_name = c30
      2 script_run_order = i4
      2 ignore_ind = i2
      2 cmb_audit_id = f8
  )
 ENDIF
 SUBROUTINE (get_cmb_metadata(parent_rs=vc(ref)) =null)
   DECLARE metadatawhere = vc WITH protect, noconstant("1 = 1")
   DECLARE metadata_cmb2_flag = i2 WITH protect, noconstant(0)
   IF (validate(parent_rs->qual[1].cmb_entity_attribute,"-1")="-1")
    SET metadata_cmb2_flag = 1
   ENDIF
   IF (metadata_cmb2_flag=0)
    SELECT INTO "nl:"
     FROM dm_cmb_metadata cm
     WHERE (cm.parent_table=request->parent_table)
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_cmb_exception e
      WHERE e.parent_entity=cm.parent_table
       AND e.child_entity=cm.child_table
       AND e.operation_type="COMBINE")))
     DETAIL
      IF (cm.child_pe_name_column > " "
       AND cm.child_pe_name1_txt > " ")
       metadatawhere = build2(" x.",cm.child_pe_name_column," in('",trim(cm.child_pe_name1_txt,3),"'"
        )
       IF (cm.child_pe_name2_txt > " ")
        metadatawhere = build2(metadatawhere,", '",trim(cm.child_pe_name2_txt,3),"'")
       ENDIF
       IF (cm.child_pe_name3_txt > " ")
        metadatawhere = build2(metadatawhere,", '",trim(cm.child_pe_name3_txt,3),"'")
       ENDIF
       metadatawhere = build2(metadatawhere,")")
      ELSE
       metadatawhere = "1 = 1"
      ENDIF
      IF (((cm.active_only_flag=1) OR (cm.combine_action_type_cd=del)) )
       metadatawhere = build2(metadatawhere," and x.active_ind = 1")
      ENDIF
      cmblistposition = 0,
      CALL echo(build(" metadata_cmb2_flag = ",metadata_cmb2_flag)), cmblistposition = locateval(
       cmblistindex,1,size(parent_rs->qual,5),cm.child_table,parent_rs->qual[cmblistindex].cmb_entity,
       cm.child_column,parent_rs->qual[cmblistindex].cmb_entity_attribute)
      IF (cmblistposition > 0
       AND (parent_rs->qual[cmblistposition].ignore_ind=0))
       parent_rs->qual[cmblistposition].ignore_ind = 1, metadatacount += 1, stat = alterlist(
        rcmbmetadatalist->qual,metadatacount),
       rcmbmetadatalist->qual[metadatacount].cmb_entity = cm.child_table, rcmbmetadatalist->qual[
       metadatacount].cmb_entity_pk = cm.child_pk, rcmbmetadatalist->qual[metadatacount].
       cmb_entity_attribute = cm.child_column,
       rcmbmetadatalist->qual[metadatacount].ignore_ind = 0
       IF (cm.combine_action_type_cd=0.0)
        rcmbmetadatalist->qual[metadatacount].cmb_action_cd = upt
       ELSE
        rcmbmetadatalist->qual[metadatacount].cmb_action_cd = cm.combine_action_type_cd
       ENDIF
       rcmbmetadatalist->qual[metadatacount].where_clause = metadatawhere
      ELSEIF (cmblistposition=0)
       metadatacount += 1, stat = alterlist(rcmbmetadatalist->qual,metadatacount), rcmbmetadatalist->
       qual[metadatacount].cmb_entity = cm.child_table,
       rcmbmetadatalist->qual[metadatacount].cmb_entity_pk = cm.child_pk, rcmbmetadatalist->qual[
       metadatacount].cmb_entity_attribute = cm.child_column, rcmbmetadatalist->qual[metadatacount].
       active_ind = cm.active_only_flag,
       rcmbmetadatalist->qual[metadatacount].ignore_ind = - (1)
       IF (cm.combine_action_type_cd=0.0)
        rcmbmetadatalist->qual[metadatacount].cmb_action_cd = upt
       ELSE
        rcmbmetadatalist->qual[metadatacount].cmb_action_cd = cm.combine_action_type_cd
       ENDIF
       rcmbmetadatalist->qual[metadatacount].where_clause = metadatawhere
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM dm_cmb_metadata cm
     WHERE (cm.parent_table=request->parent_table)
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_cmb_exception e
      WHERE e.parent_entity=cm.parent_table
       AND e.child_entity=cm.child_table
       AND e.operation_type="COMBINE")))
     DETAIL
      IF (cm.child_pe_name_column > " "
       AND cm.child_pe_name1_txt > " ")
       metadatawhere = build2(" x.",cm.child_pe_name_column," in('",trim(cm.child_pe_name1_txt,3),"'"
        )
       IF (cm.child_pe_name2_txt > " ")
        metadatawhere = build2(metadatawhere,", '",trim(cm.child_pe_name2_txt,3),"'")
       ENDIF
       IF (cm.child_pe_name3_txt > " ")
        metadatawhere = build2(metadatawhere,", '",trim(cm.child_pe_name3_txt,3),"'")
       ENDIF
       metadatawhere = build2(metadatawhere,")")
      ELSE
       metadatawhere = "1 = 1"
      ENDIF
      IF (((cm.active_only_flag=1) OR (cm.combine_action_type_cd=del)) )
       metadatawhere = build2(metadatawhere," and x.active_ind = 1")
      ENDIF
      cmblistposition = 0,
      CALL echo(build(" metadata_cmb2_flag = ",metadata_cmb2_flag)), cmblistposition = locateval(
       cmblistindex,1,size(parent_rs->qual,5),cm.child_table,parent_rs->qual[cmblistindex].cmb_entity,
       cm.child_column,parent_rs->qual[cmblistindex].cmb_entity_fk)
      IF (cmblistposition > 0)
       parent_rs->qual[cmblistposition].execute_flag = 2, metadatacount += 1, stat = alterlist(
        rcmbmetadatalist->qual,metadatacount),
       rcmbmetadatalist->qual[metadatacount].cmb_entity = cm.child_table, rcmbmetadatalist->qual[
       metadatacount].cmb_entity_pk = cm.child_pk, rcmbmetadatalist->qual[metadatacount].
       cmb_entity_attribute = cm.child_column,
       rcmbmetadatalist->qual[metadatacount].ignore_ind = 0
       IF (cm.combine_action_type_cd=0.0)
        rcmbmetadatalist->qual[metadatacount].cmb_action_cd = upt
       ELSE
        rcmbmetadatalist->qual[metadatacount].cmb_action_cd = cm.combine_action_type_cd
       ENDIF
       rcmbmetadatalist->qual[metadatacount].where_clause = metadatawhere,
       CALL echo(build2("table: ",cm.child_table," cmbListPosition>0 addded to dm_cmb_metadata."))
      ELSEIF (cmblistposition=0)
       metadatacount += 1, stat = alterlist(rcmbmetadatalist->qual,metadatacount), rcmbmetadatalist->
       qual[metadatacount].cmb_entity = cm.child_table,
       rcmbmetadatalist->qual[metadatacount].cmb_entity_pk = cm.child_pk, rcmbmetadatalist->qual[
       metadatacount].cmb_entity_attribute = cm.child_column, rcmbmetadatalist->qual[metadatacount].
       active_ind = cm.active_only_flag,
       rcmbmetadatalist->qual[metadatacount].ignore_ind = - (1)
       IF (cm.combine_action_type_cd=0.0)
        rcmbmetadatalist->qual[metadatacount].cmb_action_cd = upt
       ELSE
        rcmbmetadatalist->qual[metadatacount].cmb_action_cd = cm.combine_action_type_cd
       ENDIF
       rcmbmetadatalist->qual[metadatacount].where_clause = metadatawhere
      ENDIF
     WITH nocounter
    ;end select
    SET ecode = error(emsg,0)
    IF (ecode != 0)
     SET failed = ccl_error
    ENDIF
   ENDIF
 END ;Subroutine
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 xxx_combine_id[*]
      2 combine_id = f8
      2 parent_table = c30
      2 from_xxx_id = f8
      2 to_xxx_id = f8
    1 error[*]
      2 create_dt_tm = dq8
      2 parent_table = c30
      2 from_id = f8
      2 to_id = f8
      2 error_table = c30
      2 error_type = vc
      2 error_msg = vc
      2 combine_error_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET rcmbchildren
 RECORD rcmbchildren(
   1 qual1[100]
     2 child_table = c30
     2 fk_constraint = c30
     2 child_column = c30
     2 ignore_ind = i2
   1 qual2[100]
     2 child_table = c30
     2 script_name = c30
     2 script_run_order = i4
     2 ignore_ind = i2
     2 cmb2_audit_id = f8
   1 qual3[100]
     2 child_table = c30
     2 fk_constraint = c30
     2 index_name = c30
     2 child_column = c30
   1 qual4[100]
     2 child_table = c30
     2 fk_constraint = c30
     2 child_column = c30
 )
 FREE SET rcmblist
 RECORD rcmblist(
   1 qual[100]
     2 cmb_entity = c30
     2 cmb_entity_fk = c30
     2 cmb_entity_pk[*]
       3 col_name = c30
       3 data_type = c9
     2 execute_flag = i2
     2 cmb2_audit_id = f8
 )
 FREE SET rcmblist2
 RECORD rcmblist2(
   1 qual[100]
     2 cmb_entity = c30
     2 cmb_entity_fk = c30
     2 cmb_entity_pk[*]
       3 col_name = c30
       3 data_type = c9
     2 cmb_entity_ak[*]
       3 col_name = c30
     2 cmb2_audit_id = f8
 )
 DECLARE next_seq_val = f8
 DECLARE dc2_refresh_dcc2_ind = i2
 DECLARE dc2_cmb_dt_tm_ind = i2 WITH protect
 DECLARE revdel = f8 WITH protect, noconstant(0.0)
 DECLARE revendeff = f8 WITH protect, noconstant(0.0)
 DECLARE cmb2_audit_id = f8 WITH protect, noconstant(0.0)
 DECLARE cmb2_group_id = f8 WITH public, noconstant(0.0)
 DECLARE noop = f8 WITH protect, noconstant(0.0)
 DECLARE cmb2_gdpr_pos = i4 WITH protect, noconstant(0)
 DECLARE cmb2_gdpr_idx = i4 WITH protect, noconstant(0)
 DECLARE bypass_uid = f8 WITH protect, noconstant(0)
 DECLARE startidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE listidx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE resultind = i2 WITH protect, noconstant(1)
 SET reply->status_data.status = "F"
 DECLARE active_active_ind = i2 WITH protect, noconstant(1)
 DECLARE childcount1 = i4 WITH protect, noconstant(0)
 DECLARE childcount2 = i4 WITH protect, noconstant(0)
 DECLARE childcount3 = i4 WITH protect, noconstant(0)
 DECLARE childcount4 = i4 WITH protect, noconstant(0)
 DECLARE childcount5 = i4 WITH protect, noconstant(0)
 DECLARE childcount6 = i4 WITH protect, noconstant(0)
 DECLARE custom_det_ind = i4 WITH protect, noconstant(0)
 DECLARE ecode = i4 WITH protect, noconstant(0)
 DECLARE error_ind = i4 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE icombine = i4 WITH protect, noconstant(1)
 DECLARE icombinedet = i4 WITH protect, noconstant(0)
 DECLARE totalcmbdet = i4 WITH protect, noconstant(0)
 DECLARE init_updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE main_dummy = i4 WITH protect, noconstant(0)
 DECLARE maincount1 = i4 WITH protect, noconstant(0)
 DECLARE maincount2 = i4 WITH protect, noconstant(0)
 DECLARE maincount3 = i4 WITH protect, noconstant(0)
 DECLARE maincount4 = i4 WITH protect, noconstant(0)
 DECLARE maintcount5 = i4 WITH protect, noconstant(0)
 DECLARE max_script_run_order = i4 WITH protect, noconstant(0)
 DECLARE next_seq_val = f8 WITH protect, noconstant(0.0)
 DECLARE pkcount = i4 WITH protect, noconstant(0)
 DECLARE z = i4 WITH protect, noconstant(1)
 DECLARE del = f8 WITH protect, noconstant(0.0)
 DECLARE upt = f8 WITH protect, noconstant(0.0)
 DECLARE add = f8 WITH protect, noconstant(0.0)
 DECLARE eff = f8 WITH protect, noconstant(0.0)
 DECLARE physdel = f8 WITH protect, noconstant(0.0)
 DECLARE recalc = f8 WITH protect, noconstant(0.0)
 DECLARE combinedaway = f8 WITH protect, noconstant(0.0)
 DECLARE emsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE error_table = vc WITH protect, noconstant(fillstring(32," "))
 DECLARE init_blank = vc WITH protect, noconstant(fillstring(32," "))
 DECLARE parent_cons_name = vc WITH protect, noconstant(fillstring(30," "))
 SET p_buf[33] = fillstring(132," ")
 SET dc2_refresh_dcc2_ind = 0
 SET dc2_cmb_dt_tm_ind = 0
 RANGE OF cmbcol IS combine
 SET dc2_cmb_dt_tm_ind = evaluate(validate(cmbcol.cmb_dt_tm,- (999999.0)),- (999999.0),0,1)
 FREE RANGE cmbcol
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'COMBINED' for code_set 48"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
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
  SET failed = data_error
  SET request->error_message =
  "One or more combine_action_cds (code_set = 327) are either not active or not effective."
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF ((validate(request->reverse_cmb_ind,- (123))=- (123)))
  SET rev_cmb_request->reverse_ind = 0
 ELSE
  SET rev_cmb_request->reverse_ind = request->reverse_cmb_ind
 ENDIF
 IF (trim(request->parent_table)="PRSNL")
  SET cmb_id = "PERSON_ID"
 ELSEIF (trim(request->parent_table)="LOCATION")
  SET cmb_id = "LOCATION_CD"
 ELSEIF (trim(request->parent_table)="HEALTH_PLAN")
  SET cmb_id = "HEALTH_PLAN_ID"
 ELSEIF (trim(request->parent_table)="ORGANIZATION")
  SET cmb_id = "ORGANIZATION_ID"
 ENDIF
 SET dm_env = " "
 SELECT INTO "nl:"
  di.info_char
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="COMBINE ENVIRONMENT"
  DETAIL
   dm_env = di.info_char
  WITH nocounter
 ;end select
 IF (validate(call_script," ")="DM_CALL_COMBINE"
  AND (request->parent_table != "PRSNL"))
  DECLARE cmb_last_updt2 = f8
  SET cmb_last_updt2 = 0.0
  DECLARE schema_last_updt2 = f8
  SET schema_last_updt2 = 0.0
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="CMB_LAST_UPDT2"
   DETAIL
    cmb_last_updt2 = d.info_date
   WITH forupdatewait(d)
  ;end select
  SET ecode = error(emsg,1)
  IF (ecode != 0)
   SET failed = ccl_error
   GO TO cmb_check_error
  ENDIF
  SELECT INTO "nl:"
   d.parent_table
   FROM dm_cmb_children2 d
   WITH maxqual(d,100)
  ;end select
  IF (curqual < 100)
   SET dc2_refresh_dcc2_ind = 1
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="USERLASTUPDT"
   DETAIL
    schema_last_updt2 = d.info_date
   WITH nocounter
  ;end select
  SET ecode = error(emsg,1)
  IF (ecode != 0)
   SET failed = ccl_error
   GO TO cmb_check_error
  ENDIF
  IF (schema_last_updt2=0)
   SET failed = data_error
   SET request->error_message = "USERLASTUPDT not found in DM_INFO table."
   SET error_table = "DM_INFO"
   GO TO cmb_check_error
  ELSEIF (((schema_last_updt2 > cmb_last_updt2) OR (dc2_refresh_dcc2_ind=1)) )
   CALL cmb_call_create_audit_procs(null)
   FREE RECORD cmb_ins_reply
   RECORD cmb_ins_reply(
     1 error_ind = i2
     1 error_msg = vc
   )
   EXECUTE dm_cmb_ins_user_children2
   IF ((cmb_ins_reply->error_ind > 0))
    SET failed = data_error
    SET request->error_message = cmb_ins_reply->error_msg
    SET error_table = "DM_CMB_CHILDREN2"
    GO TO cmb_check_error
   ENDIF
  ELSE
   ROLLBACK
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="CMB_LAST_UPDT2"
   DETAIL
    cmb_last_updt2 = d.info_date
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_children2 d
  WHERE (d.parent_table=request->parent_table)
  ORDER BY d.child_table
  DETAIL
   childcount1 += 1
   IF (mod(childcount1,100)=1
    AND childcount1 != 1)
    stat = alter(rcmbchildren->qual1,(childcount1+ 99))
   ENDIF
   rcmbchildren->qual1[childcount1].child_table = d.child_table, rcmbchildren->qual1[childcount1].
   fk_constraint = d.child_cons_name, rcmbchildren->qual1[childcount1].child_column = d.child_column,
   rcmbchildren->qual1[childcount1].ignore_ind = 0
  WITH nocounter
 ;end select
 IF ((cmb_drr_reply->gdpr_ind=1))
  CALL get_gdpr_table(null)
 ENDIF
 DECLARE forloop1 = i4 WITH protect, noconstant(0)
 DECLARE gdprcount1 = i4 WITH protect, noconstant(childcount1)
 DECLARE gdprtable = c30 WITH protect, noconstant(" ")
 FOR (forloop1 = 1 TO childcount1)
   SET cmb2_gdpr_pos = 0
   SET cmb2_gdpr_pos = locateval(cmb2_gdpr_idx,1,rcmbgdpr->gdpr_table_count,rcmbchildren->qual1[
    forloop1].child_table,rcmbgdpr->qual[cmb2_gdpr_idx].cmb_entity)
   IF (cmb2_gdpr_pos > 0)
    SET gdprtable = rcmbgdpr->qual[cmb2_gdpr_pos].cmb_entity_drr
    SET gdprcount1 += 1
    IF (mod(gdprcount1,100)=1
     AND gdprcount1 != 1)
     SET stat = alter(rcmbchildren->qual1,(gdprcount1+ 99))
    ENDIF
    SET rcmbchildren->qual1[gdprcount1].child_table = gdprtable
    SET rcmbchildren->qual1[gdprcount1].fk_constraint = rcmbchildren->qual1[forloop1].fk_constraint
    SET rcmbchildren->qual1[gdprcount1].child_column = rcmbchildren->qual1[forloop1].child_column
    SET rcmbchildren->qual1[gdprcount1].ignore_ind = rcmbchildren->qual1[forloop1].ignore_ind
   ENDIF
 ENDFOR
 SET childcount1 = gdprcount1
 SET stat = alter(rcmbchildren->qual1,childcount1)
 FOR (tcnt = 1 TO value(size(rcmbchildren->qual1,5)))
   SET rcmbchildren->qual1[tcnt].ignore_ind = chk_ccl_def_tbl_col(rcmbchildren->qual1[tcnt].
    child_table,rcmbchildren->qual1[tcnt].child_column)
   IF (dm_debug_cmb=1)
    CALL echo(build(rcmbchildren->qual1[tcnt].child_table,"=",rcmbchildren->qual1[tcnt].ignore_ind))
   ENDIF
   IF ((rcmbchildren->qual1[tcnt].ignore_ind=- (1)))
    SET error_table = rcmbchildren->qual1[tcnt].child_table
    SET request->error_message = concat("No CCL definition for table ",rcmbchildren->qual1[tcnt].
     child_table," found.")
    IF (dm_debug_cmb=1)
     CALL echo(request->error_message)
    ENDIF
    SET failed = data_error
    GO TO cmb_check_error
   ENDIF
 ENDFOR
 IF (dm_debug_cmb=1)
  CALL echo(build("childcount1=",childcount1))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  d.script_name
  FROM dm_cmb_exception d,
   user_tables u
  PLAN (d
   WHERE (d.parent_entity=request->parent_table)
    AND d.operation_type="COMBINE")
   JOIN (u
   WHERE d.child_entity=u.table_name)
  DETAIL
   childcount2 += 1
   IF (mod(childcount2,100)=1
    AND childcount2 != 1)
    stat = alter(rcmbchildren->qual2,(childcount2+ 99))
   ENDIF
   rcmbchildren->qual2[childcount2].child_table = d.child_entity, rcmbchildren->qual2[childcount2].
   script_name = d.script_name, rcmbchildren->qual2[childcount2].script_run_order = d
   .script_run_order
   IF ((rcmbchildren->qual2[childcount2].script_run_order > max_script_run_order))
    max_script_run_order = rcmbchildren->qual2[childcount2].script_run_order
   ENDIF
   rcmbchildren->qual2[childcount2].ignore_ind = 0
  FOOT REPORT
   stat = alter(rcmbchildren->qual2,childcount2)
  WITH nocounter
 ;end select
 DECLARE gdprcount2 = i4 WITH protect, noconstant(childcount2)
 FOR (forloop1 = 1 TO childcount2)
  SET gdprtable = find_drr_table(rcmbchildren->qual2[forloop1].child_table)
  IF (findstring("<TABLE NOT FOUND>",gdprtable)=0)
   SET cmb2_gdpr_idx = 0
   SET cmb2_gdpr_exist = 0
   SET cmb2_gdpr_exist = locateval(cmb2_gdpr_idx,1,childcount2,gdprtable,rcmbchildren->qual2[
    cmb2_gdpr_idx].child_table)
   IF (cmb2_gdpr_exist=0)
    SET gdprcount2 += 1
    SET stat = alter(rcmbchildren->qual2,gdprcount2)
    SET rcmbchildren->qual2[gdprcount2].child_table = gdprtable
    SET rcmbchildren->qual2[gdprcount2].script_name = rcmbchildren->qual2[forloop1].script_name
    SET rcmbchildren->qual2[gdprcount2].script_run_order = rcmbchildren->qual2[forloop1].
    script_run_order
    IF ((rcmbchildren->qual2[gdprcount2].script_run_order > max_script_run_order))
     SET max_script_run_order = rcmbchildren->qual2[gdprcount2].script_run_order
    ENDIF
    IF ((rcmbchildren->qual2[forloop1].script_name != "NONE"))
     SET rcmbchildren->qual2[gdprcount2].ignore_ind = 1
    ELSE
     SET rcmbchildren->qual2[gdprcount2].ignore_ind = 0
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 SET childcount2 = gdprcount2
 SET stat = alter(rcmbchildren->qual2,childcount2)
 FOR (tcnt = 1 TO value(size(rcmbchildren->qual2,5)))
   IF ((rcmbchildren->qual2[tcnt].script_name != "NONE")
    AND (rcmbchildren->qual2[tcnt].ignore_ind != 1))
    SET rcmbchildren->qual2[tcnt].ignore_ind = chk_ccl_def_tbl(rcmbchildren->qual2[tcnt].child_table)
    IF ((rcmbchildren->qual2[tcnt].ignore_ind=- (1)))
     SET error_table = rcmbchildren->qual2[tcnt].child_table
     SET request->error_message = build("Table (",error_table,") does not have a CCL definition")
     SET failed = data_error
     GO TO cmb_check_error
    ENDIF
   ENDIF
 ENDFOR
 IF (dm_debug_cmb=1)
  CALL echo(build("childcount2=",childcount2))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rcmbchildren->qual1,5))),
   (dummyt d  WITH seq = 1),
   dm_cmb_children_pk dc,
   (dummyt d2  WITH seq = value(size(rcmbchildren->qual2,5)))
  PLAN (d1
   WHERE (rcmbchildren->qual1[d1.seq].ignore_ind=0))
   JOIN (dc
   WHERE (dc.child_table=rcmbchildren->qual1[d1.seq].child_table)
    AND (dc.pk_column_name=rcmbchildren->qual1[d1.seq].child_column))
   JOIN (d)
   JOIN (d2
   WHERE (rcmbchildren->qual2[d2.seq].child_table=rcmbchildren->qual1[d1.seq].child_table))
  DETAIL
   childcount3 += 1
   IF (mod(childcount3,100)=1
    AND childcount3 != 1)
    stat = alter(rcmbchildren->qual3,(childcount3+ 99))
   ENDIF
   rcmbchildren->qual3[childcount3].child_table = rcmbchildren->qual1[d1.seq].child_table,
   rcmbchildren->qual3[childcount3].fk_constraint = rcmbchildren->qual1[d1.seq].fk_constraint,
   rcmbchildren->qual3[childcount3].child_column = rcmbchildren->qual1[d1.seq].child_column,
   rcmbchildren->qual3[childcount3].index_name = dc.pk_index_name
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 IF (dm_debug_cmb=1)
  CALL echo(build("childcount3=",childcount3))
 ENDIF
 SET forloop1 = 0
 DECLARE gdprcount3 = i4 WITH protect, noconstant(childcount3)
 SET gdprtable = " "
 FOR (forloop1 = 1 TO childcount3)
   SET cmb2_gdpr_pos = 0
   SET cmb2_gdpr_pos = locateval(cmb2_gdpr_idx,1,rcmbgdpr->gdpr_table_count,rcmbchildren->qual3[
    forloop1].child_table,rcmbgdpr->qual[cmb2_gdpr_idx].cmb_entity)
   IF (cmb2_gdpr_pos > 0)
    SET gdprtable = rcmbgdpr->qual[cmb2_gdpr_pos].cmb_entity_drr
    SET gdprcount3 += 1
    IF (mod(gdprcount3,100)=1
     AND gdprcount3 != 1)
     SET stat = alter(rcmbchildren->qual3,(gdprcount3+ 99))
    ENDIF
    SET rcmbchildren->qual3[gdprcount3].child_table = gdprtable
    SET rcmbchildren->qual3[gdprcount3].fk_constraint = rcmbchildren->qual3[forloop1].fk_constraint
    SET rcmbchildren->qual3[gdprcount3].child_column = rcmbchildren->qual3[forloop1].child_column
    SET rcmbchildren->qual3[gdprcount3].index_name = rcmbchildren->qual3[forloop1].index_name
   ENDIF
 ENDFOR
 SET childcount3 = gdprcount3
 SET stat = alter(rcmbchildren->qual3,childcount3)
 SET dm_child_table = fillstring(30," ")
 SET dm_child_fk = fillstring(30," ")
 SET dm_child_column = fillstring(30," ")
 FOR (dm_cnt3 = 1 TO childcount1)
   SET dm_child_table = rcmbchildren->qual1[dm_cnt3].child_table
   SET dm_child_fk = rcmbchildren->qual1[dm_cnt3].fk_constraint
   SET dm_child_column = rcmbchildren->qual1[dm_cnt3].child_column
   SET dm_flag = 0
   IF ((rcmbchildren->qual1[dm_cnt3].ignore_ind=1))
    SET dm_flag = 1
   ENDIF
   IF (dm_flag=0)
    FOR (dm_cnt4 = 1 TO childcount2)
      IF ((rcmbchildren->qual2[dm_cnt4].child_table=dm_child_table))
       SET dm_flag = 1
      ENDIF
    ENDFOR
   ENDIF
   IF (dm_flag=0)
    FOR (dm_cnt4 = 1 TO childcount3)
      IF ((rcmbchildren->qual3[dm_cnt4].child_table=dm_child_table)
       AND (rcmbchildren->qual3[dm_cnt4].fk_constraint=dm_child_fk))
       SET dm_flag = 1
      ENDIF
    ENDFOR
   ENDIF
   IF (dm_flag=0)
    SET childcount4 += 1
    IF (mod(childcount4,100)=1
     AND childcount4 != 1)
     SET stat = alter(rcmbchildren->qual4,(childcount4+ 99))
    ENDIF
    SET rcmbchildren->qual4[childcount4].child_table = dm_child_table
    SET rcmbchildren->qual4[childcount4].fk_constraint = dm_child_fk
    SET rcmbchildren->qual4[childcount4].child_column = dm_child_column
   ENDIF
 ENDFOR
 SET stat = alter(rcmbchildren->qual4,childcount4)
 IF (dm_debug_cmb=1)
  CALL echo(build("childcount4=",childcount4))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rcmbchildren->qual4,5)))
  PLAN (d)
  DETAIL
   childcount5 += 1
   IF (mod(childcount5,100)=1
    AND childcount5 != 1)
    stat = alter(rcmblist->qual,(childcount5+ 99))
   ENDIF
   rcmblist->qual[childcount5].cmb_entity = rcmbchildren->qual4[d.seq].child_table, rcmblist->qual[
   childcount5].cmb_entity_fk = rcmbchildren->qual4[d.seq].child_column
  FOOT REPORT
   stat = alter(rcmblist->qual,childcount5)
  WITH nocounter
 ;end select
 SET pkcount = 0
 SELECT INTO "nl:"
  FROM dm_cmb_children_pk dccp
  WHERE expand(idx,1,value(size(rcmblist->qual,5)),dccp.child_table,rcmblist->qual[idx].cmb_entity)
   AND dccp.pk_ind=1
  ORDER BY dccp.child_table, dccp.pk_column_pos
  HEAD dccp.child_table
   pkcount = 0
  DETAIL
   pkcount += 1, startidx = 0, listidx = locateval(idx,(startidx+ 1),value(size(rcmblist->qual,5)),
    dccp.child_table,rcmblist->qual[idx].cmb_entity)
   WHILE (listidx != 0)
     stat = alterlist(rcmblist->qual[listidx].cmb_entity_pk,pkcount), rcmblist->qual[listidx].
     cmb_entity_pk[pkcount].col_name = dccp.pk_column_name, rcmblist->qual[listidx].cmb_entity_pk[
     pkcount].data_type = dccp.pk_column_type,
     startidx = listidx, listidx = locateval(listidx,(startidx+ 1),value(size(rcmblist->qual,5)),dccp
      .child_table,rcmblist->qual[listidx].cmb_entity)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 IF (error(errmsg,0) != 0)
  SET failed = select_error
  SET request->error_message = build2(
   "Error occured when populating primary keys for combine entities",errmsg)
  SET error_table = "DM_CMB_CHILDREN_PK"
  GO TO cmb_check_error
 ENDIF
 SET forloop1 = 0
 DECLARE gdprcount5 = i4 WITH protect, noconstant(childcount5)
 SET gdprtable = " "
 FOR (forloop1 = 1 TO childcount5)
   SET cmb2_gdpr_pos = 0
   SET cmb2_gdpr_pos = locateval(cmb2_gdpr_idx,1,rcmbgdpr->gdpr_table_count,rcmblist->qual[forloop1].
    cmb_entity,rcmbgdpr->qual[cmb2_gdpr_idx].cmb_entity)
   IF (cmb2_gdpr_pos > 0)
    SET gdprtable = rcmbgdpr->qual[cmb2_gdpr_pos].cmb_entity_drr
    SET gdprcount5 = 0
    SET gdprcount5 = locateval(cmb2_gdpr_idx,1,childcount5,gdprtable,rcmblist->qual[cmb2_gdpr_idx].
     cmb_entity,
     rcmblist->qual[forloop1].cmb_entity_fk,rcmblist->qual[cmb2_gdpr_idx].cmb_entity_fk)
    IF (gdprcount5 > 0)
     SET pk_forloop1 = 0
     SET gdpr_pkcount = size(rcmblist->qual[forloop1].cmb_entity_pk,5)
     SET stat = alterlist(rcmblist->qual[gdprcount5].cmb_entity_pk,gdpr_pkcount)
     FOR (pk_forloop1 = 1 TO gdpr_pkcount)
      SET rcmblist->qual[gdprcount5].cmb_entity_pk[pk_forloop1].col_name = rcmblist->qual[forloop1].
      cmb_entity_pk[pk_forloop1].col_name
      SET rcmblist->qual[gdprcount5].cmb_entity_pk[pk_forloop1].data_type = rcmblist->qual[forloop1].
      cmb_entity_pk[pk_forloop1].data_type
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 IF (dm_debug_cmb=1)
  CALL echo(build("childcount5=",childcount5))
 ENDIF
 SET resultind = createcmblistforuniqueindexes(rcmblist2,rcmbchildren)
 IF (resultind != 0)
  GO TO cmb_check_error
 ENDIF
 SET forloop1 = 0
 DECLARE gdprcount6 = i4 WITH protect, noconstant(childcount6)
 DECLARE gdprcount6_pos = i4 WITH protect, noconstant(0)
 SET gdprtable = " "
 FOR (forloop1 = 1 TO childcount6)
   SET cmb2_gdpr_pos = 0
   SET cmb2_gdpr_pos = locateval(cmb2_gdpr_idx,1,rcmbgdpr->gdpr_table_count,rcmblist2->qual[forloop1]
    .cmb_entity,rcmbgdpr->qual[cmb2_gdpr_idx].cmb_entity)
   IF (cmb2_gdpr_pos > 0)
    SET gdprtable = rcmbgdpr->qual[cmb2_gdpr_pos].cmb_entity_drr
    SET gdprcount6 += 1
    SET stat = alter(rcmblist2->qual,gdprcount6)
    SET rcmblist2->qual[gdprcount6].cmb_entity = gdprtable
    SET rcmblist2->qual[gdprcount6].cmb_entity_fk = rcmblist2->qual[forloop1].cmb_entity_fk
    SET pk_forloop1 = 0
    SET gdpr_pkcount = size(rcmblist2->qual[forloop1].cmb_entity_pk,5)
    SET stat = alterlist(rcmblist2->qual[gdprcount6].cmb_entity_pk,gdpr_pkcount)
    FOR (pk_forloop1 = 1 TO gdpr_pkcount)
     SET rcmblist2->qual[gdprcount6].cmb_entity_pk[pk_forloop1].col_name = rcmblist2->qual[forloop1].
     cmb_entity_pk[pk_forloop1].col_name
     SET rcmblist2->qual[gdprcount6].cmb_entity_pk[pk_forloop1].data_type = rcmblist2->qual[forloop1]
     .cmb_entity_pk[pk_forloop1].data_type
    ENDFOR
    SET ak_forloop1 = 0
    SET gdpr_akcount = size(rcmblist2->qual[forloop1].cmb_entity_ak,5)
    SET stat = alterlist(rcmblist2->qual[gdprcount6].cmb_entity_ak,gdpr_akcount)
    FOR (ak_forloop1 = 1 TO gdpr_akcount)
      SET rcmblist2->qual[gdprcount6].cmb_entity_ak[ak_forloop1].col_name = rcmblist2->qual[forloop1]
      .cmb_entity_ak[ak_forloop1].col_name
    ENDFOR
   ENDIF
 ENDFOR
 SET childcount6 = gdprcount6
 SET stat = alter(rcmblist2->qual,childcount6)
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET error_table = "size() function"
  SET failed = ccl_error
  GO TO cmb_check_error
 ENDIF
 SET nbr_to_combine = size(request->xxx_combine,5)
 IF (dm_debug_cmb=1)
  CALL echo(build("nbr_to_combine = ",nbr_to_combine))
 ENDIF
 CALL get_cmb_metadata(rcmblist)
 IF (dm_debug_cmb)
  CALL echo("Call get_cmb_metadata ")
  CALL echorecord(rcmbmetadatalist)
 ENDIF
 IF (failed != false)
  GO TO cmb_check_error
 ENDIF
 FOR (tcnt = 1 TO size(rcmbmetadatalist->qual,5))
   IF ((rcmbmetadatalist->qual[tcnt].ignore_ind=- (1)))
    IF (dm_debug_cmb)
     CALL echo(build("Check ccl definition for table ",rcmbmetadatalist->qual[tcnt].cmb_entity,
       " and column ",rcmbmetadatalist->qual[tcnt].cmb_entity_attribute))
    ENDIF
    SET rcmbmetadatalist->qual[tcnt].ignore_ind = chk_ccl_def_tbl_col(rcmbmetadatalist->qual[tcnt].
     cmb_entity,rcmbmetadatalist->qual[tcnt].cmb_entity_attribute)
   ENDIF
   IF (dm_debug_cmb)
    CALL echo(build("Table =",rcmbmetadatalist->qual[tcnt].cmb_entity," has ignore_ind = ",
      rcmbmetadatalist->qual[tcnt].ignore_ind))
    IF ((rcmbmetadatalist->qual[tcnt].ignore_ind=1))
     CALL echo(build("Table =",rcmbmetadatalist->qual[tcnt].cmb_entity," will be ignored."))
    ENDIF
   ENDIF
   IF ((rcmbmetadatalist->qual[tcnt].ignore_ind=- (1)))
    IF (dm_debug_cmb)
     CALL echo(build("No ccl definition found for table= ",rcmbmetadatalist->qual[tcnt].cmb_entity))
    ENDIF
    SET error_table = rcmbmetadatalist->qual[tcnt].cmb_entity
    SET request->error_message = build("Table (",error_table,") does not have a CCL definition.")
    CALL echo(request->error_message)
    SET failed = data_error
    GO TO cmb_check_error
   ENDIF
 ENDFOR
#begin_for
 FOR (icombine = z TO nbr_to_combine)
   SET count_of_inserts = 0
   SET count_of_updates = 0
   SET cmb_action = 0
   SET cmb_from_id = request->xxx_combine[icombine].from_xxx_id
   SET cmb_to_id = request->xxx_combine[icombine].to_xxx_id
   SET error_ind = 1
   SET dm_chk1 = 0
   SET dm_chk2 = 0
   SET cmb2_audit_id = 0.0
   SET cmb2_group_id = 0.0
   IF ((request->parent_table != "PRSNL")
    AND (request->parent_table != "HEALTH_PLAN")
    AND (request->cmb_mode != "RE-CMB"))
    IF (dm_debug_cmb=1)
     CALL echo(build("from/to:",cmb_from_id,"/",cmb_to_id))
     CALL echorecord(request)
    ENDIF
    CALL check_id(main_dummy)
    CALL upd_parent(main_dummy)
   ENDIF
   IF ((request->cmb_mode != "RE-CMB"))
    CALL add_cmb(main_dummy)
   ELSE
    CALL upt_cmb(main_dummy)
   ENDIF
   IF (call_script="DM_CALL_COMBINE"
    AND (request->parent_table="PRSNL"))
    SET cmb2_group_id = rcmbprsnl->qual[icombine].cmb_group_id
   ENDIF
   SET cmb2_audit_id = ins_cmb_audit(request,icombine,call_script," "," ",
    " ",cmb2_group_id,"COMBINE",rev_cmb_request->reverse_ind,1)
   FOR (maincount1 = 1 TO childcount5)
     SET rcmblist->qual[maincount1].cmb2_audit_id = ins_cmb_audit(request,icombine,call_script,trim(
       rcmblist->qual[maincount1].cmb_entity_fk),rcmblist->qual[maincount1].cmb_entity,
      " ",cmb2_group_id,"COMBINE",rev_cmb_request->reverse_ind,2)
     SET cmb_action = upt
     SET error_table = rcmblist->qual[maincount1].cmb_entity
     IF (dm_debug_cmb)
      CALL echo(build("begin det generic curmem1 =",curmem))
      CALL trace(7)
     ENDIF
     IF ((rcmblist->qual[maincount1].execute_flag=0))
      EXECUTE dm_cmb_add_det_generic2
      IF (failed != false)
       GO TO cmb_check_error
      ENDIF
      IF (dm_debug_cmb)
       CALL echo(build("end det generic curmem1 =",curmem))
       CALL trace(7)
      ENDIF
     ENDIF
     IF ((rcmblist->qual[maincount1].execute_flag=1))
      CALL echo(concat("Updating ",trim(error_table),"....."))
      SET p_buf[1] = concat("update from ",trim(rcmblist->qual[maincount1].cmb_entity)," x")
      SET p_buf[2] = concat("set x.",trim(rcmblist->qual[maincount1].cmb_entity_fk)," = CMB_TO_ID, ")
      SET p_buf[3] = "x.updt_cnt = x.updt_cnt + 1, "
      SET p_buf[4] = "x.updt_dt_tm = cnvtdatetime(curdate, curtime3), "
      SET p_buf[5] = "x.updt_id = reqinfo->updt_id, "
      SET p_buf[6] = "x.updt_task = reqinfo->updt_task, "
      SET p_buf[7] = "x.updt_applctx = reqinfo->updt_applctx"
      SET p_buf[8] = concat("where x.",trim(rcmblist->qual[maincount1].cmb_entity_fk),
       " = CMB_FROM_ID")
      SET p_buf[9] = "with nocounter go"
      FOR (buf_cnt = 1 TO 9)
       CALL parser(p_buf[buf_cnt])
       SET p_buf[buf_cnt] = fillstring(132," ")
      ENDFOR
      SET count_of_updates += curqual
      IF (dm_debug_cmb=1)
       CALL echo(build(trim(rcmblist->qual[maincount1].cmb_entity),": count_of_updates=",
         count_of_updates))
      ENDIF
      SET ecode = error(emsg,1)
      IF (ecode != 0)
       SET failed = ccl_error
       GO TO cmb_check_error
      ENDIF
      SET rcmblist->qual[maincount1].execute_flag = 0
     ENDIF
     CALL upd_cmb_audit(rcmblist->qual[maincount1].cmb2_audit_id,0.0,2)
   ENDFOR
   IF (count_of_inserts != count_of_updates)
    SET error_table = " "
    SET request->error_message = concat(
     "Number of combine details inserted != number of records updated for generic combine.",
     " Try combine again.")
    SET failed = general_error
    GO TO cmb_check_error
   ENDIF
   FOR (maincount2 = 1 TO childcount6)
     SET rcmblist2->qual[maincount2].cmb2_audit_id = ins_cmb_audit(request,icombine,call_script,trim(
       rcmblist2->qual[maincount2].cmb_entity_fk),rcmblist2->qual[maincount2].cmb_entity,
      " ",cmb2_group_id,"COMBINE",rev_cmb_request->reverse_ind,2)
     SET icombinedet = 0
     SET dm_child_table = rcmblist2->qual[maincount2].cmb_entity
     SET error_table = dm_child_table
     CALL process_akpk(main_dummy)
     IF (dm_debug_cmb)
      SET mem1 = curmem
      CALL echo(build("begin det cust curmem1 =",mem1))
     ENDIF
     EXECUTE dm_cmb_add_det_custom2
     IF (failed != false)
      GO TO cmb_check_error
     ENDIF
     IF (dm_debug_cmb)
      CALL echo(build("mem used for det cust1 = ",(curmem - mem1)))
     ENDIF
     SET totalcmbdet += icombinedet
     SET stat = alterlist(request->xxx_combine_det,0)
     SET icombinedet = 0
     CALL upd_cmb_audit(rcmblist2->qual[maincount2].cmb2_audit_id,0.0,2)
   ENDFOR
   FOR (script_run_cnt = 1 TO max_script_run_order)
     FOR (maincount3 = 1 TO childcount2)
       IF ((rcmbchildren->qual2[maincount3].script_name != "NONE")
        AND (rcmbchildren->qual2[maincount3].script_run_order=script_run_cnt)
        AND (rcmbchildren->qual2[maincount3].ignore_ind=0))
        SET rcmbchildren->qual2[maincount3].cmb2_audit_id = ins_cmb_audit(request,icombine,
         call_script," ",rcmbchildren->qual2[maincount3].child_table,
         rcmbchildren->qual2[maincount3].script_name,cmb2_group_id,"COMBINE",rev_cmb_request->
         reverse_ind,2)
        SET icombinedet = 0
        CALL echo(".")
        CALL echo(concat("Executing ",trim(rcmbchildren->qual2[maincount3].script_name),"....."))
        CALL echo(".")
        CALL echo(".")
        SET modify = nopredeclare
        SET trace = norecpersist
        CALL parser(concat("execute ",rcmbchildren->qual2[maincount3].script_name," go"))
        IF (failed != false)
         SET error_table = rcmbchildren->qual2[maincount3].child_table
         GO TO cmb_check_error
        ENDIF
        SET ecode = error(emsg,1)
        IF (ecode != 0)
         SET error_table = rcmbchildren->qual2[maincount3].child_table
         SET failed = ccl_error
         GO TO cmb_check_error
        ENDIF
        IF (icombinedet=0
         AND (request->cmb_mode != "RE-CMB"))
         SET icombinedet += 1
         SET stat = alterlist(request->xxx_combine_det,icombinedet)
         SET request->xxx_combine_det[icombinedet].combine_action_cd = noop
         SET request->xxx_combine_det[icombinedet].entity_name = rcmbchildren->qual2[maincount3].
         child_table
         SET request->xxx_combine_det[icombinedet].attribute_name = rcmbchildren->qual2[maincount3].
         script_name
        ENDIF
        IF (dm_debug_cmb)
         SET mem1 = curmem
         CALL echo(build("begin det cust curmem2 =",mem1))
        ENDIF
        EXECUTE dm_cmb_add_det_custom2
        IF (failed != false)
         GO TO cmb_check_error
        ENDIF
        IF (dm_debug_cmb)
         CALL echo(build("mem used for det cust2 = ",(curmem - mem1)))
        ENDIF
        SET totalcmbdet += icombinedet
        SET stat = alterlist(request->xxx_combine_det,0)
        SET icombinedet = 0
        CALL upd_cmb_audit(rcmbchildren->qual2[maincount3].cmb2_audit_id,0.0,2)
       ENDIF
     ENDFOR
   ENDFOR
   SET custom_det_ind = 1
   SET icombinedet = totalcmbdet
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET error_table = " "
    SET failed = ccl_error
    GO TO cmb_check_error
   ENDIF
   IF ((request->cmb_mode != "TESTING"))
    COMMIT
   ENDIF
   IF ((request->parent_table != "PRSNL"))
    SET reply_cnt += 1
    SET stat = alterlist(reply->xxx_combine_id,reply_cnt)
    SET reply->xxx_combine_id[reply_cnt].combine_id = request->xxx_combine[icombine].xxx_combine_id
    SET reply->xxx_combine_id[reply_cnt].parent_table = request->parent_table
    SET reply->xxx_combine_id[reply_cnt].from_xxx_id = request->xxx_combine[icombine].from_xxx_id
    SET reply->xxx_combine_id[reply_cnt].to_xxx_id = request->xxx_combine[icombine].to_xxx_id
   ELSE
    SET rcmbprsnl->qual[icombine].prsnl_combine_id = request->xxx_combine[icombine].xxx_combine_id
   ENDIF
   SET cmbmetadatacount = size(rcmbmetadatalist->qual,5)
   FOR (maincount5 = 1 TO cmbmetadatacount)
     SET error_table = rcmbmetadatalist->qual[maincount5].cmb_entity
     CALL echo(concat("Generate metadata sql for ",trim(error_table),"....."))
     SET count_of_inserts = 0
     SET count_of_updates = 0
     IF ((rcmbmetadatalist->qual[maincount5].ignore_ind=0))
      SET rcmbmetadatalist->qual[maincount5].cmb_audit_id = ins_cmb_audit(request,icombine,
       call_script,rcmbmetadatalist->qual[maincount5].cmb_entity_attribute,rcmbmetadatalist->qual[
       maincount5].cmb_entity,
       " ",cmb2_group_id,"COMBINE",rev_cmb_request->reverse_ind,2)
      EXECUTE dm_cmb_add_det_metadata2
      IF (failed != false)
       GO TO cmb_check_error
      ENDIF
      SET ecode = error(emsg,0)
      IF (ecode != 0)
       SET failed = ccl_error
       GO TO cmb_check_error
      ENDIF
     ENDIF
     IF ((rcmbmetadatalist->qual[maincount5].ignore_ind=0))
      SET error_table = rcmbmetadatalist->qual[maincount5].cmb_entity
      FOR (buf_cnt = 1 TO 26)
        SET p_buf[buf_cnt] = fillstring(132," ")
      ENDFOR
      CALL echo(concat("Updating ",trim(error_table),"....."))
      CALL echo(concat("Combine_TO_ID = ",cnvtstring(cmb_to_id,20,0)))
      SET p_buf[1] = concat("update from ",trim(rcmbmetadatalist->qual[maincount5].cmb_entity)," x")
      IF ((rcmbmetadatalist->qual[maincount5].cmb_action_cd=del))
       SET p_buf[2] = "set x.active_ind = 0,"
      ELSE
       SET p_buf[2] = concat("set x.",trim(rcmbmetadatalist->qual[maincount5].cmb_entity_attribute),
        " = CMB_TO_ID, ")
      ENDIF
      SET p_buf[3] = "x.updt_cnt = x.updt_cnt + 1, "
      SET p_buf[4] = "x.updt_dt_tm = cnvtdatetime(curdate, curtime3), "
      IF ((rcmbmetadatalist->qual[maincount5].cmb_action_cd=bypass_uid))
       SET p_buf[5] = "x.updt_id = x.updt_id, "
      ELSE
       SET p_buf[5] = "x.updt_id = reqinfo->updt_id, "
      ENDIF
      SET p_buf[6] = "x.updt_task = 100102, "
      SET p_buf[7] = "x.updt_applctx = reqinfo->updt_applctx"
      SET p_buf[8] = concat("where x.",trim(rcmbmetadatalist->qual[maincount5].cmb_entity_attribute),
       " = CMB_FROM_ID")
      SET p_buf[9] = concat("and ",trim(rcmbmetadatalist->qual[maincount5].where_clause))
      SET p_buf[10] = "go"
      FOR (x = 1 TO 10)
       IF (dm_debug_cmb=1)
        CALL echo(p_buf[x])
       ENDIF
       CALL parser(p_buf[x])
      ENDFOR
      SET count_of_updates = curqual
      SET ecode = error(emsg,0)
      IF (ecode != 0)
       SET error_table = rcmbmetadatalist->qual[maincount5].cmb_entity
       SET failed = ccl_error
       GO TO cmb_check_error
      ENDIF
     ENDIF
     CALL upd_cmb_audit(rcmbmetadatalist->qual[maincount5].cmb_audit_id,0.0,2)
     IF (count_of_inserts != count_of_updates)
      SET error_table = rcmbmetadatalist->qual[maincount5].cmb_entity
      SET request->error_message = build2("Number of combine details inserted",count_of_inserts,
       " != number of records updated",count_of_updates," for generic table ",
       trim(error_table,3),"."," Try combine again.")
      SET failed = general_error
      GO TO cmb_check_error
     ENDIF
   ENDFOR
   CALL upd_cmb_audit(cmb2_audit_id,0.0,1)
 ENDFOR
 SUBROUTINE (PUBLIC::createcmblistforuniqueindexes(combineentitieslist=vc(ref),combinechildtables=vc(
   ref)) =i2 WITH protect)
   DECLARE idx1 = i4 WITH protect, noconstant(0)
   DECLARE start = i4 WITH protect, noconstant(0)
   DECLARE listitemidx1 = i4 WITH protect, noconstant(0)
   DECLARE listitemidx2 = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_cmb_children_pk dccp
    WHERE expand(idx1,1,size(combinechildtables->qual3,5),dccp.child_table,combinechildtables->qual3[
     idx1].child_table)
     AND dccp.pk_ind=1
    ORDER BY dccp.child_table, dccp.pk_column_pos
    HEAD dccp.child_table
     start = 0, listitemidx1 = locateval(idx1,(start+ 1),value(size(combinechildtables->qual3,5)),
      dccp.child_table,combinechildtables->qual3[idx1].child_table)
     WHILE (listitemidx1 != 0)
       listitemidx2 = locateval(idx1,1,value(size(combineentitieslist->qual,5)),combinechildtables->
        qual3[listitemidx1].child_table,combineentitieslist->qual[idx1].cmb_entity,
        combinechildtables->qual3[listitemidx1].child_column,combineentitieslist->qual[idx1].
        cmb_entity_fk)
       IF (listitemidx2=0)
        childcount6 += 1
        IF (mod(childcount6,100)=1
         AND childcount6 != 1)
         stat = alter(combineentitieslist->qual,(childcount6+ 99))
        ENDIF
        combineentitieslist->qual[childcount6].cmb_entity = combinechildtables->qual3[listitemidx1].
        child_table, combineentitieslist->qual[childcount6].cmb_entity_fk = combinechildtables->
        qual3[listitemidx1].child_column
       ENDIF
       start = listitemidx1, listitemidx1 = locateval(idx1,(start+ 1),value(size(combinechildtables->
          qual3,5)),dccp.child_table,combinechildtables->qual3[idx1].child_table)
     ENDWHILE
     pkcount = 0
    DETAIL
     pkcount += 1, start = 0, listitemidx1 = locateval(idx1,(start+ 1),value(size(combineentitieslist
        ->qual,5)),dccp.child_table,combineentitieslist->qual[idx1].cmb_entity)
     WHILE (listitemidx1 != 0)
       stat = alterlist(combineentitieslist->qual[listitemidx1].cmb_entity_pk,pkcount),
       combineentitieslist->qual[listitemidx1].cmb_entity_pk[pkcount].col_name = dccp.pk_column_name,
       combineentitieslist->qual[listitemidx1].cmb_entity_pk[pkcount].data_type = dccp.pk_column_type,
       start = listitemidx1, listitemidx1 = locateval(idx1,(start+ 1),value(size(combineentitieslist
          ->qual,5)),dccp.child_table,combineentitieslist->qual[idx1].cmb_entity)
     ENDWHILE
    FOOT REPORT
     stat = alter(combineentitieslist->qual,childcount6)
    WITH nocounter, expand = 1
   ;end select
   IF (error(errmsg,0) != 0)
    SET failed = select_error
    SET request->error_message = build2(
     "Error occured when populating primary keys for combineEntitiesList",errmsg)
    SET error_table = "DM_CMB_CHILDREN_PK"
    RETURN(1)
   ENDIF
   SET pkcount = 0
   SELECT INTO "nl:"
    FROM dm_cmb_children_pk dccp
    WHERE expand(idx1,1,size(combinechildtables->qual3,5),dccp.child_table,combinechildtables->qual3[
     idx1].child_table,
     dccp.pk_index_name,combinechildtables->qual3[idx1].index_name)
     AND dccp.pk_ind=0
    ORDER BY dccp.child_table, dccp.pk_column_pos
    HEAD dccp.child_table
     pkcount = 0
    DETAIL
     pkcount += 1, start = 0, listitemidx1 = locateval(idx1,(start+ 1),value(size(combineentitieslist
        ->qual,5)),dccp.child_table,combineentitieslist->qual[idx1].cmb_entity)
     WHILE (listitemidx1 != 0)
       stat = alterlist(combineentitieslist->qual[listitemidx1].cmb_entity_ak,pkcount),
       combineentitieslist->qual[listitemidx1].cmb_entity_ak[pkcount].col_name = dccp.pk_column_name,
       start = listitemidx1,
       listitemidx1 = locateval(idx1,(start+ 1),value(size(combineentitieslist->qual,5)),dccp
        .child_table,combineentitieslist->qual[idx1].cmb_entity)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
   IF (error(errmsg,0) != 0)
    SET failed = select_error
    SET request->error_message = build2(
     "Error occured when populating combineEntitiesList for child tables with unique indexes",errmsg)
    SET error_table = "DM_CMB_CHILDREN_PK"
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE check_id(dummy)
   IF (((cmb_from_id=0) OR (((cmb_to_id=0) OR (cmb_from_id=cmb_to_id)) )) )
    SET failed = data_error
    SET request->error_message =
    "One or both of the 'from' and 'to' id were 0, or both ids were equal"
    SET error_table = "REQUEST"
    GO TO cmb_check_error
   ENDIF
   SET p_buf[1] = concat("select into 'nl:' x.",trim(cmb_id))
   SET p_buf[2] = concat("from   ",trim(request->parent_table)," x")
   SET p_buf[3] = concat("where  x.",trim(cmb_id)," in (cmb_from_id, cmb_to_id)")
   SET p_buf[4] = "  and  x.active_ind = 1"
   SET p_buf[5] = "  and  x.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
   SET p_buf[6] = "  and  x.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)"
   SET p_buf[7] = "detail dm_chk1 = dm_chk1 + 1"
   SET p_buf[8] = "with   forupdatewait(x) go"
   FOR (buf_cnt = 1 TO 8)
    CALL parser(p_buf[buf_cnt])
    SET p_buf[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET failed = ccl_error
    GO TO cmb_check_error
   ENDIF
   IF (dm_chk1 < 2)
    SET failed = data_error
    SET error_table = "REQUEST"
    SET request->error_message = concat("One or both of the 2 ",trim(request->parent_table),
     "s to be combined is either not active or not effective.")
    GO TO cmb_check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE upd_parent(dummy)
   SET p_buf[1] = concat("update into ",trim(request->parent_table)," x set")
   SET p_buf[2] = "x.active_ind = FALSE,"
   SET p_buf[3] = "x.active_status_cd = COMBINEDAWAY,"
   SET p_buf[4] = "x.active_status_dt_tm = cnvtdatetime(curdate, curtime3),"
   SET p_buf[5] = "x.active_status_prsnl_id = reqinfo->updt_id,"
   SET p_buf[6] = "x.updt_dt_tm = cnvtdatetime(curdate, curtime3),"
   SET p_buf[7] = "x.updt_id = reqinfo->updt_id,"
   SET p_buf[8] = "x.updt_task = reqinfo->updt_task,"
   SET p_buf[9] = "x.updt_cnt = x.updt_cnt + 1,"
   SET p_buf[10] = "x.updt_applctx = reqdata->contributor_system_cd"
   SET p_buf[11] = concat("where  x.",trim(cmb_id)," = CMB_FROM_ID")
   SET p_buf[12] = "with nocounter go"
   FOR (buf_cnt = 1 TO 12)
     IF (dm_debug_cmb=1)
      CALL echo(p_buf[buf_cnt])
     ENDIF
     CALL parser(p_buf[buf_cnt])
     SET p_buf[buf_cnt] = fillstring(132," ")
   ENDFOR
   IF (curqual=0)
    SET error_table = request->parent_table
    SET failed = insert_error
    SET request->error_message = concat("Could not update ",trim(request->parent_table),
     " table.  Please try combine again.")
    SET error_ind = 0
    GO TO cmb_check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE add_cmb(dummy)
   SET new_combine_id = 0.0
   SELECT INTO "nl:"
    y = seq(combine_seq,nextval)
    FROM dual
    DETAIL
     new_combine_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET request->xxx_combine[icombine].xxx_combine_id = new_combine_id
   IF (curqual=0)
    SET failed = gen_nbr_error
    SET request->error_message = "Couldn't get next sequence value from COMBINE_SEQ"
    GO TO cmb_check_error
    SET error_ind = 0
   ENDIF
   DECLARE comment_field_absent_ind = i2
   SET comment_field_absent_ind = chk_ccl_def_col("COMBINE","COMMENT_TXT")
   CALL parser("insert into COMBINE ",0)
   CALL parser(
    " (combine_id, parent_entity, from_id, to_id, active_ind, active_status_cd, active_status_dt_tm, ",
    0)
   CALL parser(
    " active_status_prsnl_id, updt_dt_tm, updt_id, updt_task, updt_cnt, updt_applctx, contributor_system_cd, ",
    0)
   CALL parser(" transaction_type, ",0)
   IF (validate(request->xxx_combine[icombine].comment_txt,"") != ""
    AND comment_field_absent_ind=0)
    CALL parser(" comment_txt, ",0)
   ENDIF
   IF (dc2_cmb_dt_tm_ind=1)
    CALL parser(" cmb_dt_tm, cmb_updt_id, ",0)
   ENDIF
   CALL parser(" application_flag) ",0)
   CALL parser(
    " (select NEW_COMBINE_ID, request->parent_table, CMB_FROM_ID, CMB_TO_ID, ACTIVE_ACTIVE_IND, ",0)
   CALL parser(" reqdata->active_status_cd, cnvtdatetime(curdate, curtime3), reqinfo->updt_id, ",0)
   CALL parser(
    " cnvtdatetime(curdate, curtime3), reqinfo->updt_id, reqinfo->updt_task, INIT_UPDT_CNT, ",0)
   CALL parser(" reqinfo->updt_applctx, reqdata->contributor_system_cd, request->transaction_type, ",
    0)
   IF (validate(request->xxx_combine[icombine].comment_txt,"") != ""
    AND comment_field_absent_ind=0)
    CALL parser(" request->xxx_combine[iCombine]->comment_txt, ",0)
   ENDIF
   IF (dc2_cmb_dt_tm_ind=1)
    CALL parser(" cnvtdatetime(curdate, curtime3), reqinfo->updt_id, ",0)
   ENDIF
   CALL parser(" request->xxx_combine[iCombine]->application_flag from dual) with nocounter go ",1)
   IF (curqual=0)
    SET error_table = cmb_table
    SET failed = insert_error
    SET request->error_message = concat(
     "Couldn't insert into COMBINE table.  Check if tablespace is full.")
    SET error_ind = 0
    GO TO cmb_check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_cmb(dummy)
  UPDATE  FROM combine c
   SET c.updt_task = 77777, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id
   WHERE (c.combine_id=request->xxx_combine[icombine].xxx_combine_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = update_error
   SET request->error_message = concat("Couldn't update combine table where combine_id = ",build(
     request->xxx_combine[icombine].xxx_combine_id))
   GO TO cmb_check_error
  ENDIF
 END ;Subroutine
 SUBROUTINE add_cmb_det_generic(dummy)
   SET dm_entity_cnt = 0
   SET dm_child_table = rcmblist->qual[maincount1].cmb_entity
   SET pknum = size(rcmblist->qual[maincount1].cmb_entity_pk,5)
   SET rcmblist->qual[maincount1].execute_flag = 0
   SET dm_data_type = fillstring(9," ")
   FREE SET rpkdet
   SET p_buf[1] = "record rPkDet"
   SET p_buf[2] = "(    1 qual[*]"
   SET p_buf[3] = "       2 entity_id = f8"
   FOR (cnt1 = 1 TO pknum)
    SET dm_data_type = rcmblist->qual[maincount1].cmb_entity_pk[cnt1].data_type
    CASE (dm_data_type)
     OF "VARCHAR":
     OF "CHAR":
     OF "VARCHAR2":
      SET p_buf[(cnt1+ 3)] = concat("       2 pk",build(cnt1),"= c100")
     OF "TIME":
     OF "TIMESTAMP":
     OF "DATE":
      SET p_buf[(cnt1+ 3)] = concat("       2 pk",build(cnt1),"= dq8")
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "NUMBER":
     OF "FLOAT":
      SET p_buf[(cnt1+ 3)] = concat("       2 pk",build(cnt1),"= f8")
    ENDCASE
   ENDFOR
   SET p_buf[(cnt1+ 4)] = ") go"
   FOR (buf_cnt = 1 TO (cnt1+ 4))
    CALL parser(p_buf[buf_cnt])
    SET p_buf[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET p_buf[1] = "select into 'nl:' x.seq, y = seq(COMBINE_SEQ, nextval)"
   SET p_buf[2] = concat("from   ",trim(dm_child_table)," x")
   SET p_buf[3] = concat("where  x.",trim(rcmblist->qual[maincount1].cmb_entity_fk)," = CMB_FROM_ID")
   SET p_buf[4] = "detail"
   SET p_buf[5] = "       dm_entity_cnt = dm_entity_cnt + 1"
   SET p_buf[6] = "       stat = alterlist(rPkDet->qual, dm_entity_cnt)"
   SET p_buf[7] = "       rPkDet->qual[dm_entity_cnt]->entity_id = y"
   FOR (cnt1 = 1 TO pknum)
     SET p_buf[(cnt1+ 7)] = concat("       rPkDet->qual[dm_entity_cnt]->pk",build(cnt1)," = x.",trim(
       rcmblist->qual[maincount1].cmb_entity_pk[cnt1].col_name))
   ENDFOR
   SET p_buf[(cnt1+ 8)] = "with   nocounter go"
   FOR (buf_cnt = 1 TO (cnt1+ 8))
     IF (dm_debug_cmb=1)
      CALL echo(p_buf[buf_cnt])
     ENDIF
     CALL parser(p_buf[buf_cnt])
     SET p_buf[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET error_table = " "
    SET failed = ccl_error
    GO TO cmb_check_error
   ENDIF
   IF (dm_entity_cnt > 0)
    SET rcmblist->qual[maincount1].execute_flag = 1
   ENDIF
   FOR (cnt1 = 1 TO dm_entity_cnt)
     INSERT  FROM combine_detail
      (combine_detail_id, combine_id, entity_name,
      entity_id, combine_action_cd, attribute_name,
      active_ind, active_status_cd, active_status_dt_tm,
      active_status_prsnl_id, updt_cnt, updt_dt_tm,
      updt_id, updt_task, updt_applctx)(SELECT
       rpkdet->qual[cnt1].entity_id, request->xxx_combine[icombine].xxx_combine_id, dm_child_table,
       rpkdet->qual[cnt1].entity_id, cmb_action, rcmblist->qual[maincount1].cmb_entity_fk,
       active_active_ind, reqdata->active_status_cd, cnvtdatetime(sysdate),
       reqinfo->updt_id, init_updt_cnt, cnvtdatetime(sysdate),
       reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx
       FROM dual)
      WITH nocounter
     ;end insert
     SET ecode = error(emsg,1)
     IF (ecode != 0)
      SET error_table = " "
      SET failed = ccl_error
      GO TO cmb_check_error
     ENDIF
     SET count_of_inserts += curqual
     IF (dm_debug_cmb=1)
      CALL echo(build(trim(dm_child_table),": count_of_inserts=",count_of_inserts))
     ENDIF
     FOR (cnt2 = 1 TO pknum)
       SET p_buf[1] = "insert into ENTITY_DETAIL set"
       SET p_buf[2] = "entity_id = rPkDet->qual[cnt1]->entity_id,"
       SET p_buf[3] = "column_name = rCmbList->qual[maincount1]->cmb_entity_pk[cnt2]->col_name,"
       SET p_buf[4] = "data_type   = rCmbList->qual[maincount1]->cmb_entity_pk[cnt2]->data_type,"
       CASE (rcmblist->qual[maincount1].cmb_entity_pk[cnt2].data_type)
        OF "VARCHAR":
        OF "CHAR":
        OF "VARCHAR2":
         SET p_buf[5] = concat("data_char = rPkDet->qual[cnt1]->pk",build(cnt2))
        OF "TIME":
        OF "TIMESTAMP":
        OF "DATE":
         SET p_buf[5] = concat("data_date = cnvtdatetime(rPkDet->qual[cnt1]->pk",build(cnt2),")")
        OF "INTEGER":
        OF "DOUBLE":
        OF "BIGINT":
        OF "NUMBER":
        OF "FLOAT":
         SET p_buf[5] = concat("data_number = rPkDet->qual[cnt1]->pk",build(cnt2))
       ENDCASE
       SET p_buf[6] = "with nocounter go"
       FOR (buf_cnt = 1 TO 6)
        CALL parser(p_buf[buf_cnt])
        SET p_buf[buf_cnt] = fillstring(132," ")
       ENDFOR
       SET ecode = error(emsg,1)
       IF (ecode != 0)
        SET error_table = " "
        SET failed = ccl_error
        GO TO cmb_check_error
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE process_akpk(dummy)
   SET dm_active = 0
   SET from_cnt = 0
   SET to_cnt = 0
   SET pknum = size(rcmblist2->qual[maincount2].cmb_entity_pk,5)
   SET p_buf_cnt = 0
   SET akpk_idx = 0
   SET akpk_chg_pos = 0
   SET akpk_del = 0
   FREE SET rreclist
   SET p_buf_cnt += 1
   SET p_buf[p_buf_cnt] = "record rRecList"
   SET p_buf_cnt += 1
   SET p_buf[p_buf_cnt] = "(    1 from_rec[10]"
   FOR (cnt1 = 1 TO pknum)
    SET dm_data_type = build(rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].data_type)
    CASE (dm_data_type)
     OF "VARCHAR":
     OF "CHAR":
     OF "VARCHAR2":
      SET p_buf_cnt += 1
      SET p_buf[p_buf_cnt] = concat("       2 pk",build(cnt1),"= vc")
     OF "TIME":
     OF "TIMESTAMP":
     OF "DATE":
      SET p_buf_cnt += 1
      SET p_buf[p_buf_cnt] = concat("       2 pk",build(cnt1),"= dq8")
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "NUMBER":
     OF "FLOAT":
      SET p_buf_cnt += 1
      SET p_buf[p_buf_cnt] = concat("       2 pk",build(cnt1),"= f8")
    ENDCASE
   ENDFOR
   SELECT INTO "nl:"
    a.seq
    FROM user_tab_columns a
    WHERE a.table_name=dm_child_table
     AND a.column_name IN ("ACTIVE_IND", "ACTIVE_STATUS_CD")
    DETAIL
     dm_active += 1
    WITH nocounter
   ;end select
   IF (dm_active=2)
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "       2 active_ind       = I4"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "       2 active_status_cd = F8"
   ENDIF
   SET p_buf_cnt += 1
   SET p_buf[p_buf_cnt] = "       2 delete_ind = I2"
   SET p_buf_cnt += 1
   SET p_buf[p_buf_cnt] = ") go"
   FOR (buf_cnt = 1 TO p_buf_cnt)
     IF (dm_debug_cmb=1)
      CALL echo(p_buf[buf_cnt])
     ENDIF
     CALL parser(p_buf[buf_cnt])
     SET p_buf[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET p_buf_cnt = 0
   CALL echo(build("akpk mem=",curmem,"/",dm_child_table))
   IF ((rcmbchildren->qual3[maincount2].index_name="XPK*"))
    SET p_buf_cnt = 0
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "select into 'nl:' "
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = concat("from ",trim(dm_child_table)," FRM")
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = concat("where FRM.",trim(rcmblist2->qual[maincount2].cmb_entity_fk),
     " = CMB_FROM_ID")
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "and not exists (select  'x'"
    SET akpk_chg_pos = p_buf_cnt
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = concat("from   ",trim(dm_child_table)," TU")
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = concat(" where TU.",trim(rcmblist2->qual[maincount2].cmb_entity_fk),
     " = CMB_TO_ID")
    FOR (cnt2 = 1 TO pknum)
      IF ((rcmblist2->qual[maincount2].cmb_entity_pk[cnt2].col_name != rcmblist2->qual[maincount2].
      cmb_entity_fk))
       SET p_buf_cnt += 1
       SET p_buf[p_buf_cnt] = concat("           and FRM.",trim(rcmblist2->qual[maincount2].
         cmb_entity_pk[cnt2].col_name)," = ","TU.",trim(rcmblist2->qual[maincount2].cmb_entity_pk[
         cnt2].col_name))
      ENDIF
    ENDFOR
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = ") detail"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "    from_cnt = from_cnt + 1"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "    if (mod(from_cnt,10) = 1 and from_cnt != 1)"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "       stat = alter(rRecList->from_rec, from_cnt+ 9)"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "    endif"
    FOR (cnt1 = 1 TO pknum)
     SET p_buf_cnt += 1
     SET p_buf[p_buf_cnt] = concat("    rRecList->from_rec[from_cnt]->pk",build(cnt1)," = FRM.",trim(
       rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].col_name))
    ENDFOR
    IF (dm_active=2)
     SET p_buf_cnt += 1
     SET p_buf[p_buf_cnt] = "    rRecList->from_rec[from_cnt]->active_ind = FRM.active_ind"
     SET p_buf_cnt += 1
     SET p_buf[p_buf_cnt] =
     "    rRecList->from_rec[from_cnt]->active_status_cd = FRM.active_status_cd"
    ENDIF
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "rRecList->from_rec[from_cnt]->delete_ind = akpk_del"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "with nocounter, forupdatewait(FRM) go"
    FOR (buf_cnt = 1 TO p_buf_cnt)
     IF (dm_debug_cmb=1)
      CALL echo(p_buf[buf_cnt])
     ENDIF
     CALL parser(p_buf[buf_cnt],1)
    ENDFOR
    SET ecode = error(emsg,1)
    IF (ecode != 0)
     SET failed = ccl_error
     GO TO cmb_check_error
    ENDIF
    SET akpk_del = 1
    SET p_buf[akpk_chg_pos] = "and exists (select  'x'"
    FOR (buf_cnt = 1 TO p_buf_cnt)
      IF (dm_debug_cmb=1)
       CALL echo(p_buf[buf_cnt])
      ENDIF
      CALL parser(p_buf[buf_cnt],1)
      SET p_buf[buf_cnt] = fillstring(132," ")
    ENDFOR
    SET ecode = error(emsg,1)
    IF (ecode != 0)
     SET failed = ccl_error
     GO TO cmb_check_error
    ENDIF
    SET p_buf_cnt = 0
    IF (from_cnt > 0)
     SET p_buf[1] = "select into 'nl:' "
     SET p_buf[2] = concat("from ",trim(dm_child_table)," TU")
     SET p_buf[3] = concat("where TU.",trim(rcmblist2->qual[maincount2].cmb_entity_fk),"= CMB_TO_ID")
     SET p_buf[4] = "with forupdatewait(TU) go"
     FOR (buf_cnt = 1 TO 4)
       IF (dm_debug_cmb=1)
        CALL echo(p_buf[buf_cnt])
       ENDIF
       CALL parser(p_buf[buf_cnt],1)
       SET p_buf[buf_cnt] = fillstring(132," ")
     ENDFOR
     CALL echo(build("akpk3 mem=",curmem))
     FOR (loopcount = 1 TO from_cnt)
       IF ((rreclist->from_rec[loopcount].delete_ind=1)
        AND dm_active=2)
        CALL main_del_from(main_dummy)
       ELSEIF ((rreclist->from_rec[loopcount].delete_ind=0))
        CALL main_upt_from(main_dummy)
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    SET aknum = size(rcmblist2->qual[maincount2].cmb_entity_ak,5)
    SET p_buf_cnt = 0
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "select into 'nl:' "
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = concat("from ",trim(dm_child_table)," FRM")
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = concat("where FRM.",trim(rcmblist2->qual[maincount2].cmb_entity_fk),
     " = CMB_FROM_ID")
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "and not exists (select  'x'"
    SET akpk_chg_pos = p_buf_cnt
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = concat("from   ",trim(dm_child_table)," TU")
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = concat(" where TU.",trim(rcmblist2->qual[maincount2].cmb_entity_fk),
     " = CMB_TO_ID")
    FOR (cnt2 = 1 TO aknum)
      IF ((rcmblist2->qual[maincount2].cmb_entity_ak[cnt2].col_name != rcmblist2->qual[maincount2].
      cmb_entity_fk))
       SET p_buf_cnt += 1
       SET p_buf[p_buf_cnt] = concat("           and FRM.",trim(rcmblist2->qual[maincount2].
         cmb_entity_ak[cnt2].col_name)," = ","TU.",trim(rcmblist2->qual[maincount2].cmb_entity_ak[
         cnt2].col_name))
      ENDIF
    ENDFOR
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = ") detail"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "    from_cnt = from_cnt + 1"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "    if (mod(from_cnt,10) = 1 and from_cnt != 1)"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "       stat = alter(rRecList->from_rec, from_cnt+ 9)"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "    endif"
    FOR (cnt1 = 1 TO pknum)
     SET p_buf_cnt += 1
     SET p_buf[p_buf_cnt] = concat("    rRecList->from_rec[from_cnt]->pk",build(cnt1)," = FRM.",trim(
       rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].col_name))
    ENDFOR
    IF (dm_active=2)
     SET p_buf_cnt += 1
     SET p_buf[p_buf_cnt] = "    rRecList->from_rec[from_cnt]->active_ind = FRM.active_ind"
     SET p_buf_cnt += 1
     SET p_buf[p_buf_cnt] =
     "    rRecList->from_rec[from_cnt]->active_status_cd = FRM.active_status_cd"
    ENDIF
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "rRecList->from_rec[from_cnt]->delete_ind = akpk_del"
    SET p_buf_cnt += 1
    SET p_buf[p_buf_cnt] = "with nocounter, forupdatewait(FRM) go"
    FOR (buf_cnt = 1 TO p_buf_cnt)
     IF (dm_debug_cmb=1)
      CALL echo(p_buf[buf_cnt])
     ENDIF
     CALL parser(p_buf[buf_cnt],1)
    ENDFOR
    SET ecode = error(emsg,1)
    IF (ecode != 0)
     SET failed = ccl_error
     GO TO cmb_check_error
    ENDIF
    SET p_buf[akpk_chg_pos] = "and exists (select  'x'"
    SET akpk_del = 1
    FOR (buf_cnt = 1 TO p_buf_cnt)
      IF (dm_debug_cmb=1)
       CALL echo(p_buf[buf_cnt])
      ENDIF
      CALL parser(p_buf[buf_cnt],1)
      SET p_buf[buf_cnt] = fillstring(132," ")
    ENDFOR
    SET p_buf_cnt = 0
    IF (from_cnt > 0)
     SET p_buf[1] = "select into 'nl:' "
     SET p_buf[2] = concat("from ",trim(dm_child_table)," TU")
     SET p_buf[3] = concat("where TU.",trim(rcmblist2->qual[maincount2].cmb_entity_fk),"= CMB_TO_ID")
     SET p_buf[4] = "with forupdatewait(TU) go"
     FOR (buf_cnt = 1 TO 4)
       IF (dm_debug_cmb=1)
        CALL echo(p_buf[buf_cnt])
       ENDIF
       CALL parser(p_buf[buf_cnt],1)
       SET p_buf[buf_cnt] = fillstring(132," ")
     ENDFOR
     SET ecode = error(emsg,1)
     IF (ecode != 0)
      SET failed = ccl_error
      GO TO cmb_check_error
     ENDIF
     CALL echo(build("akpk3 mem=",curmem))
     FOR (loopcount = 1 TO from_cnt)
       IF ((rreclist->from_rec[loopcount].delete_ind=1)
        AND dm_active=2)
        CALL main_del_from(main_dummy)
       ELSEIF ((rreclist->from_rec[loopcount].delete_ind=0))
        CALL main_upt_from(main_dummy)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE main_del_from(del_dummy)
   DECLARE mdf_where = vc
   SET mdf_where = "where"
   CALL echo("...")
   CALL echo("PERFORM MAIN_DEL_FROM")
   CALL echo("...")
   SET p_buf[1] = concat("update into ",dm_child_table," dct set")
   SET p_buf[2] = "       dct.active_ind              = FALSE,"
   SET p_buf[3] = "       dct.active_status_cd        = COMBINEDAWAY,"
   SET p_buf[4] = "       dct.active_status_dt_tm     = cnvtdatetime(curdate,curtime3),"
   SET p_buf[5] = "       dct.active_status_prsnl_id  = reqinfo->updt_id,"
   SET p_buf[6] = "       dct.updt_cnt                = dct.updt_cnt + 1,"
   SET p_buf[7] = "       dct.updt_id                 = reqinfo->updt_id,"
   SET p_buf[8] = "       dct.updt_applctx            = reqinfo->updt_applctx,"
   SET p_buf[9] = "       dct.updt_task               = reqinfo->updt_task,"
   SET p_buf[10] = "       dct.updt_dt_tm              = cnvtdatetime(curdate, curtime3)"
   FOR (cnt1 = 1 TO pknum)
    IF ((rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].data_type="DATE"))
     SET p_buf[(cnt1+ 10)] = concat(mdf_where," dct.",rcmblist2->qual[maincount2].cmb_entity_pk[cnt1]
      .col_name," = cnvtdatetime(rRecList->from_rec[loopcount]->pk",build(cnt1),
      ")")
    ELSE
     SET p_buf[(cnt1+ 10)] = concat(mdf_where," dct.",rcmblist2->qual[maincount2].cmb_entity_pk[cnt1]
      .col_name," = rRecList->from_rec[loopcount]->pk",build(cnt1))
    ENDIF
    SET mdf_where = " and "
   ENDFOR
   SET p_buf[(pknum+ 11)] = "with   nocounter go"
   FOR (buf_cnt = 1 TO (pknum+ 11))
    CALL parser(p_buf[buf_cnt])
    SET p_buf[buf_cnt] = fillstring(132," ")
   ENDFOR
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = concat("Could not inactivate ",trim(dm_child_table)," record with ",
     trim(rcmblist2->qual[maincount2].cmb_entity_pk[1].col_name)," = ",
     cnvtstring(rreclist->from_rec[loopcount].pk1))
    GO TO cmb_check_error
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_name = dm_child_table
   SET request->xxx_combine_det[icombinedet].attribute_name = rcmblist2->qual[maincount2].
   cmb_entity_fk
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[loopcount].
   active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[loopcount].
   active_status_cd
   FOR (cnt1 = 1 TO pknum)
     SET dm_data_type = rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].data_type
     SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,cnt1)
     SET request->xxx_combine_det[icombinedet].entity_pk[cnt1].col_name = rcmblist2->qual[maincount2]
     .cmb_entity_pk[cnt1].col_name
     SET request->xxx_combine_det[icombinedet].entity_pk[cnt1].data_type = dm_data_type
     CASE (dm_data_type)
      OF "INTEGER":
      OF "DOUBLE":
      OF "BIGINT":
      OF "NUMBER":
      OF "FLOAT":
       CALL parser(concat(
         "set request->xxx_combine_det[iCombineDet]->entity_pk[cnt1]->data_number = ",
         "rRecList->from_rec[loopcount]->pk",build(cnt1)," go"))
      OF "VARCHAR":
      OF "CHAR":
      OF "VARCHAR2":
       CALL parser(concat("set request->xxx_combine_det[iCombineDet]->entity_pk[cnt1]->data_char = ",
         "rRecList->from_rec[loopcount]->pk",build(cnt1)," go"))
      OF "TIME":
      OF "TIMESTAMP":
      OF "DATE":
       CALL parser(concat("set request->xxx_combine_det[iCombineDet]->entity_pk[cnt1]->data_date = ",
         "rRecList->from_rec[loopcount]->pk",build(cnt1)," go"))
     ENDCASE
   ENDFOR
 END ;Subroutine
 SUBROUTINE main_upt_from(upt_dummy)
   DECLARE mif_where = vc
   SET mif_where = "where"
   CALL echo("...")
   CALL echo("PERFORM MAIN_UPT_FROM")
   CALL echo("...")
   CALL echo(build("loopcount=",loopcount))
   SET p_buf[1] = concat("update into ",dm_child_table," dct set")
   SET p_buf[2] = concat("       dct.",trim(rcmblist2->qual[maincount2].cmb_entity_fk),
    " = CMB_TO_ID,")
   SET p_buf[3] = "       dct.updt_cnt     = dct.updt_cnt + 1,"
   SET p_buf[4] = "       dct.updt_id      = reqinfo->updt_id,"
   SET p_buf[5] = "       dct.updt_applctx = reqinfo->updt_applctx,"
   SET p_buf[6] = "       dct.updt_task    = reqinfo->updt_task,"
   SET p_buf[7] = "       dct.updt_dt_tm   = cnvtdatetime(curdate, curtime3)"
   FOR (cnt1 = 1 TO pknum)
    IF ((rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].data_type="DATE"))
     SET p_buf[(cnt1+ 7)] = concat(mif_where," dct.",rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].
      col_name," = cnvtdatetime(rRecList->from_rec[loopcount]->pk",build(cnt1),
      ")")
    ELSE
     SET p_buf[(cnt1+ 7)] = concat(mif_where," dct.",rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].
      col_name," = rRecList->from_rec[loopcount]->pk",build(cnt1))
    ENDIF
    SET mif_where = " and "
   ENDFOR
   SET p_buf[(pknum+ 8)] = "with   nocounter go"
   FOR (buf_cnt = 1 TO (pknum+ 11))
    CALL parser(p_buf[buf_cnt],1)
    SET p_buf[buf_cnt] = fillstring(132," ")
   ENDFOR
   CALL echo(build("upt_from mem=",curmem))
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat("Could not update ",trim(dm_child_table)," record with ",trim
     (rcmblist2->qual[maincount2].cmb_entity_pk[1].col_name)," = ",
     cnvtstring(rreclist->from_rec[loopcount].pk1))
    GO TO cmb_check_error
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = dm_child_table
   SET request->xxx_combine_det[icombinedet].attribute_name = rcmblist2->qual[maincount2].
   cmb_entity_fk
   FOR (cnt1 = 1 TO pknum)
     SET dm_data_type = rcmblist2->qual[maincount2].cmb_entity_pk[cnt1].data_type
     SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,cnt1)
     SET request->xxx_combine_det[icombinedet].entity_pk[cnt1].col_name = rcmblist2->qual[maincount2]
     .cmb_entity_pk[cnt1].col_name
     SET request->xxx_combine_det[icombinedet].entity_pk[cnt1].data_type = dm_data_type
     IF ((request->xxx_combine_det[icombinedet].entity_pk[cnt1].col_name != rcmblist2->qual[
     maincount2].cmb_entity_fk))
      CASE (dm_data_type)
       OF "INTEGER":
       OF "DOUBLE":
       OF "BIGINT":
       OF "NUMBER":
       OF "FLOAT":
        CALL parser(concat(
          "set request->xxx_combine_det[iCombineDet]->entity_pk[cnt1]->data_number = ",
          "rRecList->from_rec[loopcount]->pk",build(cnt1)," go"))
       OF "VARCHAR":
       OF "CHAR":
       OF "VARCHAR2":
        CALL parser(concat("set request->xxx_combine_det[iCombineDet]->entity_pk[cnt1]->data_char = ",
          "rRecList->from_rec[loopcount]->pk",build(cnt1)," go"))
       OF "TIME":
       OF "TIMESTAMP":
       OF "DATE":
        CALL parser(concat("set request->xxx_combine_det[iCombineDet]->entity_pk[cnt1]->data_date = ",
          "rRecList->from_rec[loopcount]->pk",build(cnt1)," go"))
      ENDCASE
     ELSE
      SET request->xxx_combine_det[icombinedet].entity_pk[cnt1].data_number = cmb_to_id
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE add_cmb_det_metadata(dummy)
   CALL echo("...")
   CALL echo("ADD_CMB_DET_METADATA")
   CALL echo("...")
   SET dm_child_table = request->xxx_combine_det[maincount5].entity_name
   SET pknum = size(request->xxx_combine_det[maincount5].entity_pk,5)
   SELECT INTO "nl:"
    y = seq(combine_seq,nextval)
    FROM dual
    DETAIL
     request->xxx_combine_det[maincount5].entity_id = cnvtreal(y)
    WITH nocounter
   ;end select
   INSERT  FROM combine_detail cd
    SET cd.combine_detail_id = request->xxx_combine_det[maincount5].entity_id, cd.combine_id =
     request->xxx_combine[icombine].xxx_combine_id, cd.entity_name = rcmbmetadatalist->qual[
     maincount5].cmb_entity,
     cd.entity_id = rcmbmetadatalist->qual[maincount5].cmb_entity_pk, cd.combine_action_cd =
     rcmbmetadatalist->qual[maincount5].cmb_action_cd, cd.attribute_name = rcmbmetadatalist->qual[
     maincount5].cmb_entity_attribute,
     cd.active_ind = active_active_ind, cd.active_status_cd = reqdata->active_status_cd, cd
     .active_status_dt_tm = cnvtdatetime(sysdate),
     cd.active_status_prsnl_id = reqinfo->updt_id, cd.updt_cnt = init_updt_cnt, cd.updt_dt_tm =
     cnvtdatetime(sysdate),
     cd.updt_id = reqinfo->updt_id, cd.updt_task = reqinfo->updt_task, cd.updt_applctx = reqinfo->
     updt_applctx,
     cd.prev_active_ind = request->xxx_combine_det[maincount5].prev_active_ind, cd
     .prev_active_status_cd = request->xxx_combine_det[maincount5].prev_active_status_cd, cd
     .prev_end_eff_dt_tm = cnvtdatetime(request->xxx_combine_det[maincount5].prev_end_eff_dt_tm),
     cd.to_record_ind = request->xxx_combine_det[maincount5].to_record_ind
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    SET rcmbmetadatalist->qual[maincount5].upt_ind = 1
   ENDIF
   SET count_of_inserts += curqual
   IF (dm_debug_cmb=1)
    CALL echo(build("table name =",rcmbmetadatalist->qual[maincount5].cmb_entity))
    CALL echo(build("number of rows inserted =",curqual))
    CALL echo(build("rCmbMetadataList->qual[maincount6]->upt_ind =",rcmbmetadatalist->qual[maincount5
      ].upt_ind))
   ENDIF
 END ;Subroutine
 SUBROUTINE add_cmb_det_custom(dummy)
   CALL echo("...")
   CALL echo("ADD_CMB_DET_CUSTOM")
   CALL echo("...")
   SET dm_child_table = request->xxx_combine_det[maincount4].entity_name
   SET pknum = size(request->xxx_combine_det[maincount4].entity_pk,5)
   SELECT INTO "nl:"
    y = seq(combine_seq,nextval)
    FROM dual
    DETAIL
     request->xxx_combine_det[maincount4].entity_id = cnvtreal(y)
    WITH nocounter
   ;end select
   INSERT  FROM combine_detail cd
    SET cd.combine_detail_id = request->xxx_combine_det[maincount4].entity_id, cd.combine_id =
     request->xxx_combine[icombine].xxx_combine_id, cd.entity_name = dm_child_table,
     cd.entity_id = request->xxx_combine_det[maincount4].entity_id, cd.combine_action_cd = request->
     xxx_combine_det[maincount4].combine_action_cd, cd.attribute_name = request->xxx_combine_det[
     maincount4].attribute_name,
     cd.active_ind = active_active_ind, cd.active_status_cd = reqdata->active_status_cd, cd
     .active_status_dt_tm = cnvtdatetime(sysdate),
     cd.active_status_prsnl_id = reqinfo->updt_id, cd.updt_cnt = init_updt_cnt, cd.updt_dt_tm =
     cnvtdatetime(sysdate),
     cd.updt_id = reqinfo->updt_id, cd.updt_task = reqinfo->updt_task, cd.updt_applctx = reqinfo->
     updt_applctx,
     cd.prev_active_ind = request->xxx_combine_det[maincount4].prev_active_ind, cd
     .prev_active_status_cd = request->xxx_combine_det[maincount4].prev_active_status_cd, cd
     .prev_end_eff_dt_tm = cnvtdatetime(request->xxx_combine_det[maincount4].prev_end_eff_dt_tm),
     cd.to_record_ind = request->xxx_combine_det[maincount4].to_record_ind
    WITH nocounter
   ;end insert
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET error_table = " "
    SET failed = ccl_error
    GO TO cmb_check_error
   ENDIF
   SET count_of_inserts += curqual
   FOR (cnt3 = 1 TO pknum)
     SET dm_data_type = fillstring(9," ")
     SET p_buf[1] = "insert into ENTITY_DETAIL"
     SET p_buf[2] = "set entity_id = request->xxx_combine_det[maincount4]->entity_id,"
     SET p_buf[3] = "column_name = request->xxx_combine_det[maincount4]->entity_pk[cnt3]->col_name,"
     SET p_buf[4] = "data_type = request->xxx_combine_det[maincount4]->entity_pk[cnt3]->data_type,"
     SET dm_data_type = request->xxx_combine_det[maincount4].entity_pk[cnt3].data_type
     CASE (dm_data_type)
      OF "VARCHAR":
      OF "CHAR":
      OF "VARCHAR2":
       SET p_buf[5] = "data_char = request->xxx_combine_det[maincount4]->entity_pk[cnt3]->data_char"
      OF "TIME":
      OF "TIMESTAMP":
      OF "DATE":
       SET p_buf[5] =
       "data_date = cnvtdatetime(request->xxx_combine_det[maincount4]->entity_pk[cnt3]->data_date)"
      OF "INTEGER":
      OF "DOUBLE":
      OF "BIGINT":
      OF "NUMBER":
      OF "FLOAT":
       SET p_buf[5] =
       "data_number = request->xxx_combine_det[maincount4]->entity_pk[cnt3]->data_number"
     ENDCASE
     SET p_buf[6] = "with nocounter go"
     FOR (buf_cnt = 1 TO 6)
       IF (dm_debug_cmb=1)
        CALL echo(p_buf[buf_cnt])
       ENDIF
       CALL parser(p_buf[buf_cnt],1)
       SET p_buf[buf_cnt] = fillstring(132," ")
     ENDFOR
     SET ecode = error(emsg,1)
     IF (ecode != 0)
      SET error_table = " "
      SET failed = ccl_error
      GO TO cmb_check_error
     ENDIF
   ENDFOR
 END ;Subroutine
#cmb_check_error
 IF (failed != false)
  CALL echorecord(request)
  ROLLBACK
  SELECT INTO "nl:"
   FROM combine c
   WHERE (c.combine_id=request->xxx_combine[icombine].xxx_combine_id)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET error_cnt += 1
   SET stat = alterlist(reply->error,error_cnt)
   SET etype = "COMMIT_ERROR"
   SET reply->error[error_cnt].error_msg =
   "A partial commit was detected after the combine process errored."
   SELECT INTO "nl:"
    y = seq(combine_error_seq,nextval)
    FROM dual
    DETAIL
     next_seq_val = cnvtreal(y)
    WITH nocounter
   ;end select
   CALL upd_cmb_audit(cmb2_audit_id,next_seq_val,1)
   CALL echo(fillstring(132,"*"))
   CALL echo("*")
   CALL echo("*")
   CALL echo(reply->error[error_cnt].error_msg)
   CALL echo("*")
   CALL echo("*")
   CALL echo(fillstring(132,"*"))
   UPDATE  FROM dm_combine_error dce
    SET dce.calling_script = "DM_COMBINE2", dce.operation_type = "COMBINE", dce.parent_entity =
     request->parent_table,
     dce.combine_id = 0, dce.from_id = request->xxx_combine[icombine].from_xxx_id, dce.to_id =
     request->xxx_combine[icombine].to_xxx_id,
     dce.encntr_id = 0, dce.error_table = error_table, dce.error_type = etype,
     dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false, dce.error_msg = substring(1,
      132,reply->error[error_cnt].error_msg),
     dce.combine_mode = request->cmb_mode, dce.transaction_type = request->transaction_type, dce
     .application_flag = request->xxx_combine[icombine].application_flag,
     dce.updt_id = reqinfo->updt_id, dce.updt_task = reqinfo->updt_task, dce.updt_applctx = reqinfo->
     updt_applctx,
     dce.updt_cnt = (dce.updt_cnt+ 1), dce.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE dce.combine_error_id=next_seq_val
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_combine_error dce
     SET dce.combine_error_id = next_seq_val, dce.calling_script = "DM_COMBINE2", dce.operation_type
       = "COMBINE",
      dce.parent_entity = request->parent_table, dce.combine_id = 0, dce.from_id = request->
      xxx_combine[icombine].from_xxx_id,
      dce.to_id = request->xxx_combine[icombine].to_xxx_id, dce.encntr_id = 0, dce.error_table =
      error_table,
      dce.error_type = etype, dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false,
      dce.error_msg = substring(1,132,reply->error[error_cnt].error_msg), dce.combine_mode = request
      ->cmb_mode, dce.transaction_type = request->transaction_type,
      dce.application_flag = request->xxx_combine[icombine].application_flag, dce.updt_id = reqinfo->
      updt_id, dce.updt_task = reqinfo->updt_task,
      dce.updt_applctx = reqinfo->updt_applctx, dce.updt_cnt = init_updt_cnt, dce.updt_dt_tm =
      cnvtdatetime(sysdate)
     WITH nocounter
    ;end insert
   ENDIF
   SET reply->error[error_cnt].create_dt_tm = cnvtdatetime(sysdate)
   SET reply->error[error_cnt].parent_table = request->parent_table
   SET reply->error[error_cnt].from_id = request->xxx_combine[icombine].from_xxx_id
   SET reply->error[error_cnt].to_id = request->xxx_combine[icombine].to_xxx_id
   SET reply->error[error_cnt].error_table = error_table
   SET reply->error[error_cnt].error_type = etype
   IF (validate(reply->error[error_cnt].combine_error_id) != 0)
    SET reply->error[error_cnt].combine_error_id = next_seq_val
   ENDIF
  ENDIF
  SET error_cnt += 1
  SET stat = alterlist(reply->error,error_cnt)
  SELECT INTO "nl:"
   y = seq(combine_error_seq,nextval)
   FROM dual
   DETAIL
    next_seq_val = cnvtreal(y)
   WITH nocounter
  ;end select
  CALL upd_cmb_audit(cmb2_audit_id,next_seq_val,1)
  SET etype = fillstring(50," ")
  CASE (failed)
   OF 3:
    SET etype = "GEN_NBR_ERROR"
   OF 4:
    SET etype = "INSERT_ERROR"
   OF 5:
    SET etype = "UPDATE_ERROR"
   OF 6:
    SET etype = "REPLACE_ERROR"
   OF 7:
    SET etype = "DELETE_ERROR"
   OF 8:
    SET etype = "UNDELETE_ERROR"
   OF 9:
    SET etype = "REMOVE_ERROR"
   OF 10:
    SET etype = "ATTRIBUTE_ERROR"
   OF 11:
    SET etype = "LOCK_ERROR"
   OF 12:
    SET etype = "NONE_FOUND"
   OF 13:
    SET etype = "SELECT_ERROR"
   OF 14:
    SET etype = "DATA_ERROR"
   OF 15:
    SET etype = "GENERAL_ERROR"
   OF 16:
    SET etype = "REACTIVATE_ERROR"
   OF 17:
    SET etype = "EFF_ERROR"
   OF 18:
    SET etype = "CCL_ERROR"
  ENDCASE
  SET test_msg = "request->error_message"
  IF (failed=ccl_error)
   SET reply->error[error_cnt].error_msg = emsg
  ELSE
   SET reply->error[error_cnt].error_msg = request->error_message
  ENDIF
  UPDATE  FROM dm_combine_error dce
   SET dce.calling_script = "DM_COMBINE2", dce.operation_type = "COMBINE", dce.parent_entity =
    request->parent_table,
    dce.combine_id = 0, dce.from_id = request->xxx_combine[icombine].from_xxx_id, dce.to_id = request
    ->xxx_combine[icombine].to_xxx_id,
    dce.encntr_id = 0, dce.error_table = error_table, dce.error_type = etype,
    dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false, dce.error_msg = substring(1,
     132,reply->error[error_cnt].error_msg),
    dce.combine_mode = request->cmb_mode, dce.transaction_type = request->transaction_type, dce
    .application_flag = request->xxx_combine[icombine].application_flag,
    dce.updt_id = reqinfo->updt_id, dce.updt_task = reqinfo->updt_task, dce.updt_applctx = reqinfo->
    updt_applctx,
    dce.updt_cnt = (dce.updt_cnt+ 1), dce.updt_dt_tm = cnvtdatetime(sysdate)
   WHERE dce.combine_error_id=next_seq_val
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_combine_error dce
    SET dce.combine_error_id = next_seq_val, dce.calling_script = "DM_COMBINE2", dce.operation_type
      = "COMBINE",
     dce.parent_entity = request->parent_table, dce.combine_id = 0, dce.from_id = request->
     xxx_combine[icombine].from_xxx_id,
     dce.to_id = request->xxx_combine[icombine].to_xxx_id, dce.encntr_id = 0, dce.error_table =
     error_table,
     dce.error_type = etype, dce.create_dt_tm = cnvtdatetime(sysdate), dce.resolved_ind = false,
     dce.error_msg = substring(1,132,reply->error[error_cnt].error_msg), dce.combine_mode = request->
     cmb_mode, dce.transaction_type = request->transaction_type,
     dce.application_flag = request->xxx_combine[icombine].application_flag, dce.updt_id = reqinfo->
     updt_id, dce.updt_task = reqinfo->updt_task,
     dce.updt_applctx = reqinfo->updt_applctx, dce.updt_cnt = init_updt_cnt, dce.updt_dt_tm =
     cnvtdatetime(sysdate)
    WITH nocounter
   ;end insert
  ENDIF
  SET reply->error[error_cnt].create_dt_tm = cnvtdatetime(sysdate)
  SET reply->error[error_cnt].parent_table = request->parent_table
  SET reply->error[error_cnt].from_id = request->xxx_combine[icombine].from_xxx_id
  SET reply->error[error_cnt].to_id = request->xxx_combine[icombine].to_xxx_id
  SET reply->error[error_cnt].error_table = error_table
  SET reply->error[error_cnt].error_type = etype
  IF (validate(reply->error[error_cnt].combine_error_id) != 0)
   SET reply->error[error_cnt].combine_error_id = next_seq_val
  ENDIF
  COMMIT
 ELSE
  SET reqinfo->commit_ind = true
  SET reply->status_data.status = "S"
 ENDIF
#cmb_end_script
 IF (size(reply->error,5) > 0)
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo("end dm_combine2")
 ENDIF
END GO
