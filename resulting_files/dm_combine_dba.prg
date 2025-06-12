CREATE PROGRAM dm_combine:dba
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
      2 parent_table = c30
      2 from_xxx_id = f8
      2 to_xxx_id = f8
      2 encntr_id = f8
    1 error[*]
      2 create_dt_tm = dq8
      2 parent_table = c30
      2 from_id = f8
      2 to_id = f8
      2 encntr_id = f8
      2 error_table = c30
      2 error_type = vc
      2 error_msg = vc
      2 combine_error_id = f8
  )
 ENDIF
 RECORD rencupdt(
   1 enc[*]
     2 encntr_id = f8
     2 updt_dt_tm = dq8
 )
 IF (validate(rcmblist->qual[1].cmb_entity,"Z")="Z")
  FREE SET rcmblist
  RECORD rcmblist(
    1 qual[*]
      2 cmb_entity = c30
      2 cmb_entity_attribute = c30
      2 cmb_entity_pk = c30
      2 cmb_entity_encntr_attr = c30
      2 upt_ind = i2
      2 ignore_ind = i2
      2 cmb_audit_id = f8
    1 custom[*]
      2 table_name = c30
      2 script_name = c30
      2 script_run_order = i4
      2 ignore_ind = i2
      2 cmb_audit_id = f8
  )
 ENDIF
 FREE RECORD mp
 RECORD mp(
   1 tbl_cnt = i4
   1 tbl[*]
     2 child_table = vc
     2 child_cmb_col = vc
     2 child_pk_col = vc
     2 parent_table = vc
     2 parent_cmb_col = vc
     2 from_clause = vc
     2 where_clause = vc
     2 run_order = i4
     2 active_ind = i2
     2 ignore_ind = i2
     2 status = vc
     2 cmd_str = vc
     2 err_str = vc
 )
 SET mp->tbl_cnt = 0
 SET stat = alterlist(mp->tbl,0)
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
 DECLARE get_cmb_enc_info(null) = null WITH protect
 IF ((validate(rcmbencinfo->enc_cnt,- (1))=- (1)))
  FREE RECORD rcmbencinfo
  RECORD rcmbencinfo(
    1 enc_cnt = i4
    1 enc[*]
      2 encntr_id = f8
      2 active_ind = i2
      2 encntr_status_cd = f8
  )
 ENDIF
 SUBROUTINE get_cmb_enc_info(null)
   SET rcmbencinfo->enc_cnt = 0
   SELECT
    IF ((request->xxx_combine[icombine].encntr_id=0)
     AND (rev_cmb_request->reverse_ind=1))
     FROM encounter e
     WHERE (e.person_id=request->xxx_combine[icombine].to_xxx_id)
    ELSEIF ((request->xxx_combine[icombine].encntr_id=0))
     FROM encounter e
     WHERE (e.person_id=request->xxx_combine[icombine].from_xxx_id)
    ELSE
     FROM encounter e
     WHERE (e.encntr_id=request->xxx_combine[icombine].encntr_id)
    ENDIF
    INTO "nl:"
    DETAIL
     rcmbencinfo->enc_cnt += 1
     IF (mod(rcmbencinfo->enc_cnt,10)=1)
      stat = alterlist(rcmbencinfo->enc,(rcmbencinfo->enc_cnt+ 9))
     ENDIF
     rcmbencinfo->enc[rcmbencinfo->enc_cnt].encntr_id = e.encntr_id, rcmbencinfo->enc[rcmbencinfo->
     enc_cnt].active_ind = e.active_ind, rcmbencinfo->enc[rcmbencinfo->enc_cnt].encntr_status_cd = e
     .encntr_status_cd
    FOOT REPORT
     stat = alterlist(rcmbencinfo->enc,rcmbencinfo->enc_cnt)
    WITH nocounter, forupdatewait(e)
   ;end select
   IF (dm_debug_cmb)
    CALL echorecord(rcmbencinfo)
   ENDIF
 END ;Subroutine
 IF ((validate(bbd_request->qual[1].encntr_id,- (1))=- (1)))
  FREE RECORD bbd_request
  RECORD bbd_request(
    1 qual[*]
      2 encntr_id = f8
  )
 ENDIF
 IF ((validate(bbd_reply->qual[1].encntr_id,- (1))=- (1)))
  FREE RECORD bbd_reply
  RECORD bbd_reply(
    1 qual[*]
      2 encntr_id = f8
      2 donor_encntr_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE init_bbd_request(null) = null
 DECLARE init_bbd_reply(null) = null
 SUBROUTINE init_bbd_request(null)
   SET stat = alterlist(bbd_request->qual,0)
 END ;Subroutine
 SUBROUTINE init_bbd_reply(null)
   SET stat = alterlist(bbd_reply->qual,0)
 END ;Subroutine
 SUBROUTINE (cmb_script_check(csc_script_name=vc) =i2)
   DECLARE sbr_csc_exist_ind = i2
   SET sbr_csc_exist_ind = 0
   SELECT INTO "nl:"
    d.object_name
    FROM dprotect d
    WHERE d.object="P"
     AND d.object_name=cnvtupper(csc_script_name)
    DETAIL
     sbr_csc_exist_ind = 1
    WITH nocounter
   ;end select
   RETURN(sbr_csc_exist_ind)
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
 DECLARE dm_det_qual_ind = i2 WITH protect, noconstant(0)
 DECLARE etype = c50 WITH protect, noconstant(" ")
 DECLARE prsnl_cmb_ind = i2 WITH protect, noconstant(0)
 DECLARE dm_p_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_combine_id = f8 WITH protect, noconstant(0.0)
 DECLARE dm_encupdt_cnt = i4 WITH protect, noconstant(0)
 DECLARE begin_icombinedet = i4 WITH protect, noconstant(0)
 DECLARE totalcombinedet = i4 WITH protect, noconstant(0)
 DECLARE dc_refresh_dcc_ind = i2 WITH protect, noconstant(0)
 DECLARE dc_refresh_dcc2_ind = i2 WITH protect, noconstant(0)
 DECLARE next_seq_val = f8 WITH protect, noconstant(0.0)
 DECLARE dc_cmb_dt_tm_ind = i2 WITH protect, noconstant(0)
 DECLARE revdel = f8 WITH protect, noconstant(0.0)
 DECLARE revendeff = f8 WITH protect, noconstant(0.0)
 DECLARE cmb_audit_id = f8 WITH protect, noconstant(0.0)
 DECLARE cmb_group_id = f8 WITH public, noconstant(0.0)
 DECLARE icombinedetem = i4 WITH protect, noconstant(0)
 DECLARE totalcombinedetem = i4 WITH protect, noconstant(0)
 DECLARE max_em_run_order = i4 WITH protect, noconstant(0)
 DECLARE uptem = f8 WITH protect, noconstant(0.0)
 DECLARE ti = i4 WITH protect, noconstant(0)
 SET auto_encntr_move_child_ind = " "
 SET icombinedetem = 0
 SET totalcombinedetem = 0
 SET max_em_run_order = 0
 SET uptem = 0.0
 SET ti = 0
 DECLARE noop = f8 WITH protect, noconstant(0.0)
 DECLARE commit_check_ind = i4 WITH protect, noconstant(false)
 DECLARE recombining = i2 WITH protect, noconstant(0)
 DECLARE bypass_uid = f8 WITH protect, noconstant(0)
 DECLARE cmbmetadatacount = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET dm_det_qual_ind = 0
 SET dc_refresh_dcc_ind = 0
 SET dc_refresh_dcc2_ind = 0
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE maincount1 = i4 WITH protect, noconstant(0)
 DECLARE maincount2 = i4 WITH protect, noconstant(0)
 DECLARE maincount3 = i4 WITH protect, noconstant(0)
 DECLARE maincount4 = i4 WITH protect, noconstant(0)
 DECLARE maincount5 = i4 WITH protect, noconstant(0)
 DECLARE maincount6 = i4 WITH protect, noconstant(0)
 DECLARE init_updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE active_active_ind = i2 WITH protect, noconstant(1)
 DECLARE childcount1 = i4 WITH protect, noconstant(0)
 DECLARE childcount2 = i4 WITH protect, noconstant(0)
 DECLARE max_script_run_order = i4 WITH protect, noconstant(0)
 DECLARE error_table = vc WITH protect, noconstant(fillstring(32," "))
 DECLARE main_dummy = i2 WITH protect, noconstant(0)
 DECLARE icombinedet = i4 WITH protect, noconstant(0)
 SET parser_buffer[33] = fillstring(132," ")
 DECLARE emsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE ecode = i4 WITH protect, noconstant(0)
 SET next_seq_val = 0.0
 DECLARE icombine = i4 WITH protect, noconstant(1)
 DECLARE z = i4 WITH protect, noconstant(1)
 DECLARE error_ind = i4 WITH protect, noconstant(0)
 DECLARE custom_det_ind = i4 WITH protect, noconstant(0)
 DECLARE init_blank = vc WITH protect, noconstant(fillstring(32," "))
 DECLARE meaning = vc WITH protect, noconstant(fillstring(12," "))
 DECLARE nbr_to_combine = i4 WITH protect, noconstant(size(request->xxx_combine,5))
 DECLARE err_op_type = vc WITH protect, noconstant(fillstring(20," "))
 DECLARE dc_cmb_dt_tm_ind = i2 WITH protect, noconstant(0)
 IF (dm_debug_cmb=1)
  CALL echo(build("call script=",call_script))
  CALL echo(build("cmb_mode =",request->cmb_mode))
  CALL echo(build("nbr_to_combine =",nbr_to_combine))
 ENDIF
 IF (call_script="DM_CALL_COMBINE"
  AND (request->cmb_mode != "RE-CMB"))
  FOR (zz = 1 TO nbr_to_combine)
    CASE (cnvtupper(trim(request->parent_table,3)))
     OF "PERSON":
      IF (request->xxx_combine[zz].encntr_id)
       CALL check_move(request->xxx_combine[zz].from_xxx_id,request->xxx_combine[zz].encntr_id)
       CALL check_person(request->xxx_combine[zz].to_xxx_id)
      ELSE
       IF (dm_debug_cmb=1)
        CALL echo("Check if from and to person_id are valid.")
       ENDIF
       CALL check_person(request->xxx_combine[zz].to_xxx_id)
       CALL check_person(request->xxx_combine[zz].from_xxx_id)
      ENDIF
     OF "ENCOUNTER":
      CALL check_encounter(request->xxx_combine[zz].to_xxx_id)
      CALL check_encounter(request->xxx_combine[zz].from_xxx_id)
    ENDCASE
  ENDFOR
 ENDIF
 DECLARE combinedaway = f8 WITH protect, noconstant(0.0)
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'COMBINED' for code_set 48"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("COMBINEDAWAY =",combinedaway))
 ENDIF
 DECLARE del = f8 WITH protect, noconstant(0.0)
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'DEL' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("DEL =",del))
 ENDIF
 DECLARE upt = f8 WITH protect, noconstant(0.0)
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'UPT' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("UPT =",upt))
 ENDIF
 DECLARE add = f8 WITH protect, noconstant(0.0)
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'ADD' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("ADD =",add))
 ENDIF
 DECLARE eff = f8 WITH protect, noconstant(0.0)
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'EFF' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("EFF =",eff))
 ENDIF
 DECLARE physdel = f8 WITH protect, noconstant(0.0)
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'PHYSDEL' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("PHYSDEL =",physdel))
 ENDIF
 DECLARE recalc = f8 WITH protect, noconstant(0.0)
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'RECALC' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("RECALC =",recalc))
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'REVDEL' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("REVDEL =",revdel))
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'REVENDEFF' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("REVENDEFF =",revendeff))
 ENDIF
 IF ((validate(request->reverse_cmb_ind,- (123))=- (123)))
  SET rev_cmb_request->reverse_ind = 0
 ELSE
  SET rev_cmb_request->reverse_ind = request->reverse_cmb_ind
 ENDIF
 SET meaning = "ENCNTRMVCHLD"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=327
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   uptem = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'ENCNTRMVCHLD' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("UPTEM =",uptem))
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'NOOP' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("NOOP =",noop))
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
  SET failed = data_error
  SET request->error_message =
  "No active, effective code_value exists for cdf_meaning 'BYPASS_UID' for code_set 327"
  SET error_table = "CODE_VALUE"
  GO TO cmb_check_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("BYPASS_UID =",bypass_uid))
 ENDIF
 IF (trim(request->parent_table)="PERSON")
  SET cmb_table_id = "PERSON_COMBINE_ID"
  SET cmb_det_table = "PERSON_COMBINE_DET"
  SET cmb_seq = "PERSON_COMBINE_SEQ"
  SET cmb_det_table_id = "PERSON_COMBINE_DET_ID"
  SET cmb_table = "PERSON_COMBINE"
  SET cmb_from = "FROM_PERSON_ID"
  SET cmb_to = "TO_PERSON_ID"
  SET cmb_id = "PERSON_ID"
 ELSEIF (trim(request->parent_table)="ENCOUNTER")
  SET cmb_table_id = "ENCNTR_COMBINE_ID"
  SET cmb_det_table = "ENCNTR_COMBINE_DET"
  SET cmb_seq = "ENCOUNTER_COMBINE_SEQ"
  SET cmb_det_table_id = "ENCNTR_COMBINE_DET_ID"
  SET cmb_table = "ENCNTR_COMBINE"
  SET cmb_from = "FROM_ENCNTR_ID"
  SET cmb_to = "TO_ENCNTR_ID"
  SET cmb_id = "ENCNTR_ID"
 ENDIF
 CALL parser(concat("range of cmbcol is ",cmb_table," go"))
 SET dc_cmb_dt_tm_ind = evaluate(validate(cmbcol.cmb_dt_tm,- (999999.0)),- (999999.0),0,1)
 FREE RANGE cmbcol
 SELECT INTO "nl:"
  d.parent_table
  FROM dm_cmb_children d
  WITH maxqual(d,100)
 ;end select
 IF (curqual < 100)
  SET dc_refresh_dcc_ind = 1
 ENDIF
 DECLARE cmb_last_updt = f8
 SET cmb_last_updt = 0.0
 DECLARE schema_last_updt = f8
 SET schema_last_updt = 0.0
 IF (call_script="DM_CALL_COMBINE")
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="CMB_LAST_UPDT"
   DETAIL
    cmb_last_updt = d.info_date
   WITH forupdatewait(d)
  ;end select
  SET ecode = error(emsg,0)
  IF (ecode != 0)
   SET failed = ccl_error
   GO TO cmb_check_error
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="USERLASTUPDT"
   DETAIL
    schema_last_updt = d.info_date
   WITH nocounter
  ;end select
  SET ecode = error(emsg,0)
  IF (ecode != 0)
   SET failed = ccl_error
   GO TO cmb_check_error
  ENDIF
  IF (schema_last_updt=0)
   SET failed = data_error
   SET request->error_message = "USERLASTUPDT not found in DM_INFO table."
   SET error_table = "DM_INFO"
   GO TO cmb_check_error
  ELSEIF (((schema_last_updt > cmb_last_updt) OR (dc_refresh_dcc_ind=1)) )
   CALL cmb_call_create_audit_procs(null)
   FREE RECORD ct_error
   RECORD ct_error(
     1 message = vc
     1 err_ind = i2
   )
   EXECUTE dm_ins_user_cmb_children
   IF ((ct_error->err_ind=1))
    IF (size(trim(ct_error->message,3)))
     SET failed = data_error
     SET request->error_message = ct_error->message
     GO TO cmb_check_error
    ENDIF
   ENDIF
  ELSE
   ROLLBACK
  ENDIF
  SET ecode = error(emsg,0)
  IF (ecode != 0)
   SET failed = ccl_error
   GO TO cmb_check_error
  ENDIF
 ELSE
  IF (dc_refresh_dcc_ind=1)
   SET failed = data_error
   SET request->error_message =
   "Combine called by uncombine, and DM_CMB_CHILDREN not populated correctly. Please log a point with Cerner!"
   GO TO cmb_check_error
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="CMB_LAST_UPDT"
   DETAIL
    cmb_last_updt = d.info_date
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->parent_table="PERSON")
  AND (request->xxx_combine[1].encntr_id=0))
  IF (validate(personcmb->last_load,0) < cmb_last_updt)
   FREE SET personcmb
   SET trace = recpersist
   RECORD personcmb(
     1 generic[*]
       2 table_name = c30
       2 pk_col_name = c30
       2 person_col_name = c30
     1 generic_count = i4
     1 custom[*]
       2 table_name = c30
       2 script_name = c30
       2 script_run_order = i4
     1 custom_count = i4
     1 last_load = f8
   )
   SET trace = norecpersist
   SELECT INTO "nl:"
    a.child_table, a.child_pk, a.child_column
    FROM dm_cmb_person_children a
    ORDER BY a.child_table, a.child_column
    DETAIL
     childcount1 += 1, stat = alterlist(personcmb->generic,childcount1), personcmb->generic[
     childcount1].table_name = a.child_table,
     personcmb->generic[childcount1].pk_col_name = a.child_pk, personcmb->generic[childcount1].
     person_col_name = a.child_column
    WITH nocounter
   ;end select
   SET personcmb->generic_count = childcount1
   SELECT INTO "nl:"
    a.child_entity
    FROM dm_cmb_exception a
    WHERE a.operation_type="COMBINE"
     AND a.parent_entity="PERSON"
     AND a.child_entity="ENCOUNTER"
     AND a.script_name != "NONE"
    ORDER BY a.script_run_order
    DETAIL
     childcount2 += 1, stat = alterlist(personcmb->custom,childcount2), personcmb->custom[childcount2
     ].table_name = a.child_entity,
     personcmb->custom[childcount2].script_name = a.script_name, personcmb->custom[childcount2].
     script_run_order = a.script_run_order
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    a.child_entity
    FROM dm_cmb_exception a
    WHERE a.operation_type="COMBINE"
     AND a.parent_entity="PERSON"
     AND a.child_entity != "ENCOUNTER"
     AND a.script_name != "NONE"
    ORDER BY a.script_run_order, a.child_entity
    DETAIL
     IF ((((request->cmb_mode != "RE-CMB")) OR (a.child_entity != "PERSON")) )
      childcount2 += 1, stat = alterlist(personcmb->custom,childcount2), personcmb->custom[
      childcount2].table_name = a.child_entity,
      personcmb->custom[childcount2].script_name = a.script_name, personcmb->custom[childcount2].
      script_run_order = a.script_run_order
     ENDIF
    WITH nocounter
   ;end select
   SET personcmb->custom_count = childcount2
   SET personcmb->last_load = cnvtdatetime(sysdate)
  ENDIF
  SET childcount1 = personcmb->generic_count
  SET childcount2 = personcmb->custom_count
  FOR (dm_cnt1 = 1 TO childcount1)
    SET stat = alterlist(rcmblist->qual,dm_cnt1)
    SET rcmblist->qual[dm_cnt1].cmb_entity = personcmb->generic[dm_cnt1].table_name
    SET rcmblist->qual[dm_cnt1].cmb_entity_pk = personcmb->generic[dm_cnt1].pk_col_name
    SET rcmblist->qual[dm_cnt1].cmb_entity_attribute = personcmb->generic[dm_cnt1].person_col_name
  ENDFOR
  FOR (dm_cnt2 = 1 TO childcount2)
    SET stat = alterlist(rcmblist->custom,dm_cnt2)
    SET rcmblist->custom[dm_cnt2].table_name = personcmb->custom[dm_cnt2].table_name
    SET rcmblist->custom[dm_cnt2].script_name = personcmb->custom[dm_cnt2].script_name
    SET rcmblist->custom[dm_cnt2].script_run_order = personcmb->custom[dm_cnt2].script_run_order
    IF ((rcmblist->custom[dm_cnt2].script_run_order > max_script_run_order))
     SET max_script_run_order = rcmblist->custom[dm_cnt2].script_run_order
    ENDIF
  ENDFOR
 ELSEIF ((request->parent_table="PERSON")
  AND (request->xxx_combine[1].encntr_id != 0))
  IF (validate(encntrmove->last_load,0) < cmb_last_updt)
   FREE SET encntrmove
   SET trace = recpersist
   RECORD encntrmove(
     1 generic[*]
       2 table_name = c30
       2 pk_col_name = c30
       2 person_col_name = c30
       2 encntr_col_name = c30
     1 generic_count = i4
     1 custom[*]
       2 table_name = c30
       2 script_name = c30
       2 script_run_order = i4
     1 custom_count = i4
     1 last_load = f8
   )
   SET trace = norecpersist
   SELECT INTO "nl:"
    a.child_table, a.child_pk, a.person_column,
    a.encounter_column
    FROM dm_cmb_both_children a
    ORDER BY a.child_table, a.person_column
    DETAIL
     childcount1 += 1, stat = alterlist(encntrmove->generic,childcount1), encntrmove->generic[
     childcount1].table_name = a.child_table,
     encntrmove->generic[childcount1].pk_col_name = a.child_pk, encntrmove->generic[childcount1].
     person_col_name = a.person_column, encntrmove->generic[childcount1].encntr_col_name = a
     .encounter_column
    WITH nocounter
   ;end select
   SET encntrmove->generic_count = childcount1
   SELECT INTO "nl:"
    a.child_entity
    FROM dm_cmb_exception a
    WHERE a.operation_type="COMBINE"
     AND a.parent_entity="PERSON"
     AND a.child_entity="ENCOUNTER"
     AND a.single_encntr_ind=1
     AND a.script_name != "NONE"
    ORDER BY a.script_run_order
    DETAIL
     childcount2 += 1, stat = alterlist(encntrmove->custom,childcount2), encntrmove->custom[
     childcount2].table_name = a.child_entity,
     encntrmove->custom[childcount2].script_name = a.script_name, encntrmove->custom[childcount2].
     script_run_order = a.script_run_order
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    a.child_entity
    FROM dm_cmb_exception a
    WHERE a.operation_type="COMBINE"
     AND a.parent_entity="PERSON"
     AND a.child_entity != "ENCOUNTER"
     AND a.single_encntr_ind=1
     AND a.script_name != "NONE"
    ORDER BY a.script_run_order, a.child_entity
    DETAIL
     childcount2 += 1, stat = alterlist(encntrmove->custom,childcount2), encntrmove->custom[
     childcount2].table_name = a.child_entity,
     encntrmove->custom[childcount2].script_name = a.script_name, encntrmove->custom[childcount2].
     script_run_order = a.script_run_order
    WITH nocounter
   ;end select
   SET encntrmove->custom_count = childcount2
   SET encntrmove->last_load = cnvtdatetime(sysdate)
  ENDIF
  SET childcount1 = encntrmove->generic_count
  SET childcount2 = encntrmove->custom_count
  FOR (dm_cnt1 = 1 TO childcount1)
    SET stat = alterlist(rcmblist->qual,dm_cnt1)
    SET rcmblist->qual[dm_cnt1].cmb_entity = encntrmove->generic[dm_cnt1].table_name
    SET rcmblist->qual[dm_cnt1].cmb_entity_pk = encntrmove->generic[dm_cnt1].pk_col_name
    SET rcmblist->qual[dm_cnt1].cmb_entity_attribute = encntrmove->generic[dm_cnt1].person_col_name
    SET rcmblist->qual[dm_cnt1].cmb_entity_encntr_attr = encntrmove->generic[dm_cnt1].encntr_col_name
  ENDFOR
  FOR (dm_cnt2 = 1 TO childcount2)
    SET stat = alterlist(rcmblist->custom,dm_cnt2)
    SET rcmblist->custom[dm_cnt2].table_name = encntrmove->custom[dm_cnt2].table_name
    SET rcmblist->custom[dm_cnt2].script_name = encntrmove->custom[dm_cnt2].script_name
    SET rcmblist->custom[dm_cnt2].script_run_order = encntrmove->custom[dm_cnt2].script_run_order
    IF ((rcmblist->custom[dm_cnt2].script_run_order > max_script_run_order))
     SET max_script_run_order = rcmblist->custom[dm_cnt2].script_run_order
    ENDIF
  ENDFOR
  SET auto_encntr_move_child_ind = " "
  SELECT INTO "nl:"
   cce.field_value
   FROM code_cdf_ext cce
   WHERE cce.code_set=327
    AND cce.field_name="AUTO_ENCNTR_MOVE_CHILD_IND"
    AND cce.cdf_meaning="ENCNTRMVCHLD"
   DETAIL
    auto_encntr_move_child_ind = cce.field_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM code_cdf_ext cce
    SET cce.code_set = 327, cce.cdf_meaning = "ENCNTRMVCHLD", cce.field_name =
     "AUTO_ENCNTR_MOVE_CHILD_IND",
     cce.updt_task = 0, cce.updt_id = 0, cce.updt_cnt = 0,
     cce.updt_dt_tm = cnvtdatetime(sysdate), cce.updt_applctx = 0, cce.field_seq = 1,
     cce.field_type = 1, cce.field_len = 0, cce.val_code_set = 0,
     cce.field_value = "1"
    WITH nocounter
   ;end insert
   SET auto_encntr_move_child_ind = "1"
  ENDIF
  IF (auto_encntr_move_child_ind="1")
   SET max_em_run_order = 1
   SELECT INTO "nl:"
    FROM dm_cmb_em_children mp
    WHERE  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_cmb_exception x
     WHERE x.operation_type="COMBINE"
      AND x.parent_entity="PERSON"
      AND x.script_name="NONE"
      AND x.child_entity=mp.child_table)))
     AND mp.active_ind=1
     AND  EXISTS (
    (SELECT
     "y"
     FROM user_tab_columns y
     WHERE y.table_name=mp.child_table
      AND y.column_name=mp.child_cmb_column))
     AND  EXISTS (
    (SELECT
     "z"
     FROM user_tab_columns z
     WHERE z.table_name=mp.parent_table
      AND z.column_name=mp.parent_cmb_column))
    ORDER BY mp.parent_table, mp.parent_cmb_column, mp.child_table,
     mp.child_cmb_column
    HEAD REPORT
     mcnt = 0
    DETAIL
     mcnt += 1, mp->tbl_cnt = mcnt, stat = alterlist(mp->tbl,mcnt),
     mp->tbl[mcnt].child_table = mp.child_table, mp->tbl[mcnt].child_cmb_col = mp.child_cmb_column,
     mp->tbl[mcnt].child_pk_col = mp.child_pk_column,
     mp->tbl[mcnt].parent_table = mp.parent_table, mp->tbl[mcnt].parent_cmb_col = mp
     .parent_cmb_column, mp->tbl[mcnt].from_clause = mp.from_clause,
     mp->tbl[mcnt].where_clause = mp.where_clause, mp->tbl[mcnt].active_ind = mp.active_ind, mp->tbl[
     mcnt].run_order = mp.run_order
     IF ((mp->tbl[mcnt].run_order < 1))
      mp->tbl[mcnt].run_order = 1
     ENDIF
     IF ((mp->tbl[mcnt].run_order > max_em_run_order))
      max_em_run_order = mp->tbl[mcnt].run_order
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF ((request->parent_table="ENCOUNTER"))
  IF (validate(encntrcmb->last_load,0) < cmb_last_updt)
   FREE SET encntrcmb
   SET trace = recpersist
   RECORD encntrcmb(
     1 generic[*]
       2 table_name = c30
       2 pk_col_name = c30
       2 encntr_col_name = c30
     1 generic_count = i4
     1 custom[*]
       2 table_name = c30
       2 script_name = c30
       2 script_run_order = i4
     1 custom_count = i4
     1 last_load = f8
   )
   SET trace = norecpersist
   SELECT INTO "nl:"
    a.child_table, a.child_pk, a.child_column
    FROM dm_cmb_encounter_children a
    ORDER BY a.child_table, a.child_column
    DETAIL
     childcount1 += 1, stat = alterlist(encntrcmb->generic,childcount1), encntrcmb->generic[
     childcount1].table_name = a.child_table,
     encntrcmb->generic[childcount1].pk_col_name = a.child_pk, encntrcmb->generic[childcount1].
     encntr_col_name = a.child_column
    WITH nocounter
   ;end select
   SET encntrcmb->generic_count = childcount1
   SELECT INTO "nl:"
    a.child_entity
    FROM dm_cmb_exception a
    WHERE a.operation_type="COMBINE"
     AND a.parent_entity="ENCOUNTER"
     AND a.child_entity="ENCOUNTER"
     AND a.script_name != "NONE"
    ORDER BY a.script_run_order
    DETAIL
     childcount2 += 1, stat = alterlist(encntrcmb->custom,childcount2), encntrcmb->custom[childcount2
     ].table_name = a.child_entity,
     encntrcmb->custom[childcount2].script_name = a.script_name, encntrcmb->custom[childcount2].
     script_run_order = a.script_run_order
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    a.child_entity
    FROM dm_cmb_exception a
    WHERE a.operation_type="COMBINE"
     AND a.parent_entity="ENCOUNTER"
     AND a.child_entity != "ENCOUNTER"
     AND a.script_name != "NONE"
    ORDER BY a.script_run_order, a.child_entity
    DETAIL
     childcount2 += 1, stat = alterlist(encntrcmb->custom,childcount2), encntrcmb->custom[childcount2
     ].table_name = a.child_entity,
     encntrcmb->custom[childcount2].script_name = a.script_name, encntrcmb->custom[childcount2].
     script_run_order = a.script_run_order
    WITH nocounter
   ;end select
   SET encntrcmb->custom_count = childcount2
   SET encntrcmb->last_load = cnvtdatetime(sysdate)
  ENDIF
  SET childcount1 = encntrcmb->generic_count
  SET childcount2 = encntrcmb->custom_count
  FOR (dm_cnt1 = 1 TO childcount1)
    SET stat = alterlist(rcmblist->qual,dm_cnt1)
    SET rcmblist->qual[dm_cnt1].cmb_entity = encntrcmb->generic[dm_cnt1].table_name
    SET rcmblist->qual[dm_cnt1].cmb_entity_pk = encntrcmb->generic[dm_cnt1].pk_col_name
    SET rcmblist->qual[dm_cnt1].cmb_entity_attribute = encntrcmb->generic[dm_cnt1].encntr_col_name
  ENDFOR
  FOR (dm_cnt2 = 1 TO childcount2)
    SET stat = alterlist(rcmblist->custom,dm_cnt2)
    SET rcmblist->custom[dm_cnt2].table_name = encntrcmb->custom[dm_cnt2].table_name
    SET rcmblist->custom[dm_cnt2].script_name = encntrcmb->custom[dm_cnt2].script_name
    SET rcmblist->custom[dm_cnt2].script_run_order = encntrcmb->custom[dm_cnt2].script_run_order
    IF ((rcmblist->custom[dm_cnt2].script_run_order > max_script_run_order))
     SET max_script_run_order = rcmblist->custom[dm_cnt2].script_run_order
    ENDIF
  ENDFOR
 ENDIF
 FOR (tcnt = 1 TO size(rcmblist->qual,5))
   IF (dm_debug_cmb)
    CALL echo(build("Check ccl definition for table ",rcmblist->qual[tcnt].cmb_entity," and column ",
      rcmblist->qual[tcnt].cmb_entity_attribute))
   ENDIF
   SET rcmblist->qual[tcnt].ignore_ind = chk_ccl_def_tbl_col(rcmblist->qual[tcnt].cmb_entity,rcmblist
    ->qual[tcnt].cmb_entity_attribute)
   IF ((rcmblist->qual[tcnt].ignore_ind=0)
    AND (request->parent_table="PERSON")
    AND (request->xxx_combine[1].encntr_id != 0))
    SET rcmblist->qual[tcnt].ignore_ind = chk_ccl_def_col(rcmblist->qual[tcnt].cmb_entity,rcmblist->
     qual[tcnt].cmb_entity_encntr_attr)
   ENDIF
   IF (dm_debug_cmb)
    IF ((rcmblist->qual[tcnt].ignore_ind=1))
     CALL echo(build("Table =",rcmblist->qual[tcnt].cmb_entity," will be ignored."))
    ENDIF
   ENDIF
   IF ((rcmblist->qual[tcnt].ignore_ind=- (1)))
    IF (dm_debug_cmb)
     CALL echo(build("No ccl definition found for table= ",rcmblist->qual[tcnt].cmb_entity))
    ENDIF
    SET error_table = rcmblist->qual[tcnt].cmb_entity
    SET request->error_message = build("Table (",error_table,") does not have a CCL definition.")
    CALL echo(request->error_message)
    SET failed = data_error
    GO TO cmb_check_error
   ENDIF
 ENDFOR
 FOR (tcnt = 1 TO size(rcmblist->custom,5))
  SET rcmblist->custom[tcnt].ignore_ind = chk_ccl_def_tbl(rcmblist->custom[tcnt].table_name)
  IF ((rcmblist->custom[tcnt].ignore_ind=- (1)))
   SET error_table = rcmblist->custom[tcnt].table_name
   SET request->error_message = build("Table (",error_table,") does not have a CCL definition.")
   SET failed = data_error
   GO TO cmb_check_error
  ENDIF
 ENDFOR
 IF (auto_encntr_move_child_ind="1")
  FOR (tcnt = 1 TO mp->tbl_cnt)
    SET ti = locateval(ti,1,size(rcmblist->qual,5),mp->tbl[tcnt].child_table,rcmblist->qual[ti].
     cmb_entity)
    IF (ti > 0)
     IF ((rcmblist->qual[ti].ignore_ind != 0))
      SET mp->tbl[tcnt].ignore_ind = rcmblist->qual[ti].ignore_ind
     ENDIF
    ENDIF
    IF ((mp->tbl[tcnt].ignore_ind=0))
     SET mp->tbl[tcnt].ignore_ind = chk_ccl_def_tbl_col(mp->tbl[tcnt].child_table,mp->tbl[tcnt].
      child_cmb_col)
     SET error_table = mp->tbl[tcnt].child_table
     IF (dm_debug_cmb)
      IF ((mp->tbl[tcnt].ignore_ind=1))
       CALL echo(build("Child table =",mp->tbl[tcnt].child_table," will be ignored."))
      ENDIF
     ENDIF
    ENDIF
    IF ((mp->tbl[tcnt].ignore_ind=0))
     SET mp->tbl[tcnt].ignore_ind = chk_ccl_def_tbl_col(mp->tbl[tcnt].parent_table,mp->tbl[tcnt].
      parent_cmb_col)
     SET error_table = mp->tbl[tcnt].parent_table
     IF (dm_debug_cmb)
      IF ((mp->tbl[tcnt].ignore_ind=1))
       CALL echo(build("Child table =",mp->tbl[tcnt].child_table,
         " will be ignored due to parent table =",mp->tbl[tcnt].parent_table))
      ENDIF
     ENDIF
    ENDIF
    IF ((mp->tbl[tcnt].ignore_ind=- (1)))
     SET request->error_message = build("Table (",error_table,
      ") has data but does not have a CCL definition.")
     SET failed = data_error
     GO TO cmb_check_error
    ENDIF
  ENDFOR
 ENDIF
 SET auto_encntr_cmb_ind = " "
 IF ((request->parent_table="PERSON")
  AND call_script="DM_CALL_COMBINE")
  SELECT INTO "nl:"
   cce.field_value
   FROM code_cdf_ext cce
   WHERE cce.code_set=327
    AND cce.field_name="AUTO_ENCNTR_COMBINE_IND"
    AND cce.cdf_meaning="ENCNTRCMB"
   DETAIL
    auto_encntr_cmb_ind = cce.field_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM code_cdf_ext cce
    SET cce.code_set = 327, cce.cdf_meaning = "ENCNTRCMB", cce.field_name = "AUTO_ENCNTR_COMBINE_IND",
     cce.updt_task = 0, cce.updt_id = 0, cce.updt_cnt = 0,
     cce.updt_dt_tm = cnvtdatetime(sysdate), cce.updt_applctx = 0, cce.field_seq = 1,
     cce.field_type = 1, cce.field_len = 0, cce.val_code_set = 0,
     cce.field_value = "1"
    WITH nocounter
   ;end insert
   SET auto_encntr_cmb_ind = "1"
  ENDIF
 ENDIF
 IF ((((request->xxx_combine[1].encntr_id=0)
  AND (request->parent_table="PERSON")) OR ((request->parent_table="ENCOUNTER"))) )
  CALL get_cmb_metadata(rcmblist)
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
 ENDIF
#begin_for
 SET recombining = 0
 IF (dm_debug_cmb=1)
  CALL echo(build("Below are the list of child tables need to be combined for parent ",request->
    parent_table))
  CALL echorecord(rcmblist)
  CALL echorecord(rcmbmetadatalist)
 ENDIF
 FOR (icombine = z TO nbr_to_combine)
   CALL echo(build("loop:",z,"/",nbr_to_combine))
   IF ( NOT (recombining))
    SET cmb_audit_id = 0.0
    SET cmb_group_id = 0.0
   ENDIF
   SET count_of_inserts = 0
   SET count_of_updates = 0
   SET cmb_action = 0
   SET cmb_id_value = 0.0
   SET from_prsnl_action = "X"
   SET cmb_from_id = request->xxx_combine[icombine].from_xxx_id
   SET cmb_to_id = request->xxx_combine[icombine].to_xxx_id
   SET custom_cmb_det_cnt = 0
   SET error_ind = 1
   IF (call_script="DM_UNCOMBINE")
    SET cmb_group_id = ucb_group_id_pub
   ENDIF
   IF (dm_debug_cmb=1)
    CALL echo("Check validity for from_id and to_id for RE-CMB mode...")
    CALL echo(build("from_id =",request->xxx_combine[icombine].from_xxx_id))
    CALL echo(build("to_id =",request->xxx_combine[icombine].to_xxx_id))
   ENDIF
   IF (((cmb_from_id=0) OR (((cmb_to_id=0) OR (cmb_from_id=cmb_to_id)) )) )
    SET failed = data_error
    SET request->error_message =
    "Either one or both of the from and to id's was 0, or both id's were equal"
    SET error_table = "REQUEST"
    GO TO cmb_check_error
   ENDIF
   IF (trim(request->cmb_mode) != "RE-CMB"
    AND  NOT (recombining))
    IF (call_script="DM_CALL_COMBINE"
     AND (request->xxx_combine[icombine].encntr_id > 0))
     SET encntr_chk_cnt = 0
     SELECT INTO "nl:"
      e.encntr_id
      FROM encounter e
      WHERE (e.encntr_id=request->xxx_combine[icombine].encntr_id)
       AND e.person_id=cmb_from_id
       AND e.active_ind=1
      DETAIL
       encntr_chk_cnt += 1
      WITH nocounter
     ;end select
     IF (encntr_chk_cnt=0)
      SET failed = data_error
      SET request->error_message = concat("Encounter ",trim(cnvtstring(request->xxx_combine[icombine]
         .encntr_id))," is not an active encounter of Person ",trim(cnvtstring(request->xxx_combine[
         icombine].from_xxx_id)),".")
      SET error_table = "REQUEST"
      GO TO cmb_check_error
     ENDIF
     IF ((request->transaction_type != "CMBTOOL"))
      IF (cmb_script_check("BBD_VALIDATE_ENCOUNTER")=1)
       CALL init_bbd_request(null)
       CALL init_bbd_reply(null)
       SET stat = alterlist(bbd_request->qual,1)
       SET bbd_request->qual[1].encntr_id = request->xxx_combine[icombine].encntr_id
       EXECUTE bbd_validate_encounter  WITH replace(reply,bbd_reply), replace(request,bbd_request)
       IF ((bbd_reply->status_data.status != "S"))
        SET failed = data_error
        SET request->error_message = bbd_reply->status_data.subeventstatus[1].targetobjectvalue
        SET error_table = "REQUEST"
        GO TO cmb_check_error
       ELSE
        FOR (crlp_cnt = 1 TO value(size(bbd_reply->qual,5)))
          IF ((bbd_reply->qual[crlp_cnt].donor_encntr_ind=1))
           SET failed = data_error
           SET error_table = "REQUEST"
           SET request->error_message = concat(
            "The encounter being moved is a Blood Bank Donor encounter.",
            "It can only be moved via the Combine Tool by a user with the proper authorization.")
           GO TO cmb_check_error
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
    ELSEIF ((request->parent_table="ENCOUNTER"))
     IF (cmb_script_check("BBD_VALIDATE_ENCOUNTER")=1)
      CALL init_bbd_request(null)
      CALL init_bbd_reply(null)
      SET stat = alterlist(bbd_request->qual,2)
      SET bbd_request->qual[1].encntr_id = request->xxx_combine[icombine].from_xxx_id
      SET bbd_request->qual[2].encntr_id = request->xxx_combine[icombine].to_xxx_id
      EXECUTE bbd_validate_encounter  WITH replace(reply,bbd_reply), replace(request,bbd_request)
      IF ((bbd_reply->status_data.status != "S"))
       SET failed = data_error
       SET request->error_message = bbd_reply->status_data.subeventstatus[1].targetobjectvalue
       SET error_table = "REQUEST"
       GO TO cmb_check_error
      ELSE
       FOR (crlp_cnt = 1 TO value(size(bbd_reply->qual,5)))
         IF ((bbd_reply->qual[crlp_cnt].donor_encntr_ind=1))
          SET failed = data_error
          SET error_table = "REQUEST"
          SET request->error_message = concat("One or both of the encounters being combined are ",
           "Blood Bank Donor encounters, and cannot participate in encounter combines.")
          GO TO cmb_check_error
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ( NOT (recombining))
    SET prsnl_cmb_ind = 0
   ENDIF
   IF (dm_debug_cmb=1)
    CALL echo("Check for PRSNL COMBINE...")
   ENDIF
   IF ((request->parent_table="PERSON")
    AND (request->xxx_combine[icombine].encntr_id=0)
    AND (request->cmb_mode != "RE-CMB")
    AND  NOT (recombining))
    SELECT INTO "nl:"
     p.person_id
     FROM prsnl p
     WHERE (p.person_id=request->xxx_combine[icombine].from_xxx_id)
     DETAIL
      prsnl_cmb_ind = 1
     WITH nocounter
    ;end select
   ELSEIF ((request->parent_table="PERSON")
    AND (request->xxx_combine[icombine].encntr_id=0)
    AND (request->cmb_mode="RE-CMB")
    AND  NOT (recombining))
    SELECT INTO "nl:"
     pcd.person_combine_det_id
     FROM person_combine_det pcd,
      combine c
     PLAN (pcd
      WHERE (pcd.person_combine_id=request->xxx_combine[icombine].xxx_combine_id)
       AND pcd.combine_action_cd=prsnl_cmb
       AND pcd.entity_name="PRSNL_COMBINE"
       AND pcd.active_ind=1)
      JOIN (c
      WHERE c.combine_id=pcd.entity_id
       AND (c.from_id=request->xxx_combine[icombine].from_xxx_id)
       AND (c.to_id=request->xxx_combine[icombine].to_xxx_id)
       AND c.active_ind=1)
     HEAD REPORT
      prsnl_cmb_ind = 1
     DETAIL
      prsnl_cnt += 1, stat = alterlist(rcmbprsnl->qual,prsnl_cnt), rcmbprsnl->qual[prsnl_cnt].
      person_combine_id = request->xxx_combine[icombine].xxx_combine_id,
      rcmbprsnl->qual[prsnl_cnt].from_prsnl_id = request->xxx_combine[icombine].from_xxx_id,
      rcmbprsnl->qual[prsnl_cnt].to_prsnl_id = request->xxx_combine[icombine].to_xxx_id, rcmbprsnl->
      qual[prsnl_cnt].prsnl_combine_id = c.combine_id
     FOOT REPORT
      rcmbprsnl->size = prsnl_cnt
     WITH nocounter
    ;end select
    IF (dm_debug_cmb=1)
     CALL echo(build("prsnl_cmb_ind =",prsnl_cmb_ind))
     CALL echo(build("prsnl_cmb =",prsnl_cmb))
     CALL echo(build("prsnl_cnt =",prsnl_cnt))
     CALL echorecord(rcmbprsnl)
    ENDIF
   ENDIF
   IF (prsnl_cmb_ind=1
    AND  NOT (recombining))
    DECLARE cmb_last_updt2 = f8
    SET cmb_last_updt2 = 0.0
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CMB_LAST_UPDT2"
     DETAIL
      cmb_last_updt2 = d.info_date
     WITH forupdatewait(d)
    ;end select
    SET ecode = error(emsg,0)
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
     SET dc_refresh_dcc2_ind = 1
    ENDIF
    IF (((schema_last_updt > cmb_last_updt2) OR (dc_refresh_dcc2_ind=1)) )
     FREE RECORD cmb_ins_reply
     RECORD cmb_ins_reply(
       1 error_ind = i2
       1 error_msg = vc
     )
     EXECUTE dm_cmb_ins_user_children2
     IF ((cmb_ins_reply->error_ind > 0))
      SET failed = ccl_error
      SET request->error_message = cmb_ins_reply->error_msg
      SET error_table = "DM_CMB_CHILDREN2"
      GO TO cmb_check_error
     ENDIF
    ELSE
     ROLLBACK
    ENDIF
   ENDIF
   IF ((request->parent_table="PERSON"))
    SELECT INTO "nl:"
     p.person_id
     FROM person p
     WHERE (((p.person_id=request->xxx_combine[icombine].from_xxx_id)) OR ((p.person_id=request->
     xxx_combine[icombine].to_xxx_id)))
     WITH forupdatewait(p)
    ;end select
    SET ecode = error(emsg,0)
    IF (ecode != 0)
     SET failed = ccl_error
     GO TO cmb_check_error
    ENDIF
    IF (dm_debug_cmb=1)
     CALL echo("Prevent deadlock for PERSON table...")
    ENDIF
    SELECT INTO "nl:"
     p.person_id
     FROM person p
     WHERE (((p.person_id=request->xxx_combine[icombine].from_xxx_id)) OR ((p.person_id=request->
     xxx_combine[icombine].to_xxx_id)))
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
     WITH nocounter
    ;end select
    IF (curqual != 2)
     SET failed = data_error
     SET error_table = "REQUEST"
     SET request->error_message = concat(
      "One or both of the persons being combined are not active or effective.")
     GO TO cmb_check_error
    ENDIF
    IF ((request->xxx_combine[icombine].encntr_id > 0.0))
     SELECT INTO "nl:"
      e.encntr_id
      FROM encounter e
      WHERE (e.encntr_id=request->xxx_combine[icombine].encntr_id)
      WITH forupdatewait(e)
     ;end select
     SET ecode = error(emsg,0)
     IF (ecode != 0)
      SET failed = ccl_error
      GO TO cmb_check_error
     ENDIF
    ENDIF
   ELSEIF ((request->parent_table="ENCOUNTER"))
    SET dm_p_id = 0.0
    SELECT INTO "nl:"
     e.person_id
     FROM encounter e
     WHERE (((e.encntr_id=request->xxx_combine[icombine].from_xxx_id)) OR ((e.encntr_id=request->
     xxx_combine[icombine].to_xxx_id)))
     DETAIL
      dm_p_id = e.person_id
     WITH forupdatewait(e)
    ;end select
    SET ecode = error(emsg,0)
    IF (ecode != 0)
     SET failed = ccl_error
     GO TO cmb_check_error
    ENDIF
    SELECT INTO "nl:"
     p.person_id
     FROM person p
     WHERE p.person_id=dm_p_id
     WITH forupdatewait(p)
    ;end select
    SET ecode = error(emsg,0)
    IF (ecode != 0)
     SET failed = ccl_error
     GO TO cmb_check_error
    ENDIF
   ENDIF
   IF ((request->parent_table="PERSON")
    AND call_script="DM_CALL_COMBINE"
    AND auto_encntr_cmb_ind="1"
    AND  NOT (recombining))
    SET dm_encupdt_cnt = 0
    SET stat = alterlist(rencupdt->enc,dm_encupdt_cnt)
    SELECT INTO "nl:"
     e.encntr_id
     FROM encounter e
     WHERE (((e.person_id=request->xxx_combine[icombine].from_xxx_id)) OR ((e.person_id=request->
     xxx_combine[icombine].to_xxx_id)))
     DETAIL
      dm_encupdt_cnt += 1, stat = alterlist(rencupdt->enc,dm_encupdt_cnt), rencupdt->enc[
      dm_encupdt_cnt].encntr_id = e.encntr_id,
      rencupdt->enc[dm_encupdt_cnt].updt_dt_tm = e.updt_dt_tm
     WITH nocounter
    ;end select
   ENDIF
   IF (trim(request->cmb_mode) != "RE-CMB"
    AND  NOT (recombining)
    AND (request->parent_table="PERSON"))
    CALL get_cmb_enc_info(null)
   ENDIF
   IF (trim(request->cmb_mode) != "RE-CMB"
    AND  NOT (recombining))
    SET error_table = cmb_table
    CALL add_cmb(main_dummy)
    IF (dm_debug_cmb=1)
     CALL echo(build("Insert into ",cmb_table," with combine_id =",request->xxx_combine[icombine].
       xxx_combine_id))
    ENDIF
   ELSE
    CALL upt_cmb(main_dummy)
    IF (dm_debug_cmb=1)
     CALL echo(build("Update ",cmb_table," with combine_id =",request->xxx_combine[icombine].
       xxx_combine_id))
    ENDIF
   ENDIF
   SET ecode = error(emsg,0)
   IF (ecode != 0)
    SET failed = ccl_error
    GO TO cmb_check_error
   ENDIF
   IF ( NOT (recombining))
    SET cmb_audit_id = ins_cmb_audit(request,icombine,call_script," "," ",
     " ",cmb_group_id,"COMBINE",rev_cmb_request->reverse_ind,1)
   ENDIF
   FOR (maincount1 = 1 TO childcount1)
     SET count_of_inserts = 0
     SET count_of_updates = 0
     IF ( NOT (rcmblist->qual[maincount1].ignore_ind))
      SET rcmblist->qual[maincount1].cmb_audit_id = ins_cmb_audit(request,icombine,call_script,
       rcmblist->qual[maincount1].cmb_entity_attribute,rcmblist->qual[maincount1].cmb_entity,
       " ",cmb_group_id,"COMBINE",rev_cmb_request->reverse_ind,2)
      SET cmb_action = upt
      SET error_table = rcmblist->qual[maincount1].cmb_entity
      CALL add_cmb_det_generic(main_dummy)
      SET ecode = error(emsg,0)
      IF (ecode != 0)
       SET failed = ccl_error
       GO TO cmb_check_error
      ENDIF
     ENDIF
     IF ((rcmblist->qual[maincount1].upt_ind=1))
      SET error_table = rcmblist->qual[maincount1].cmb_entity
      FOR (buf_cnt = 1 TO 26)
        SET parser_buffer[buf_cnt] = fillstring(132," ")
      ENDFOR
      CALL echo(concat("Updating ",trim(error_table),"....."))
      SET parser_buffer[1] = concat("update from ",trim(rcmblist->qual[maincount1].cmb_entity)," x")
      SET parser_buffer[2] = concat("set x.",trim(rcmblist->qual[maincount1].cmb_entity_attribute),
       " = CMB_TO_ID, ")
      SET parser_buffer[3] = "x.updt_cnt = x.updt_cnt + 1, "
      SET parser_buffer[4] = "x.updt_dt_tm = cnvtdatetime(curdate, curtime3), "
      SET parser_buffer[5] = "x.updt_id = reqinfo->updt_id, "
      SET parser_buffer[6] = "x.updt_task = 100102, "
      SET parser_buffer[7] = "x.updt_applctx = reqinfo->updt_applctx"
      SET parser_buffer[8] = concat("where x.",trim(rcmblist->qual[maincount1].cmb_entity_attribute),
       " = CMB_FROM_ID")
      IF ((request->xxx_combine[icombine].encntr_id=0))
       SET parser_buffer[9] = "go"
       FOR (x = 1 TO 9)
         CALL parser(parser_buffer[x])
       ENDFOR
      ELSEIF ((request->parent_table="PERSON")
       AND (request->xxx_combine[icombine].encntr_id != 0))
       SET parser_buffer[9] = concat("and x.",trim(rcmblist->qual[maincount1].cmb_entity_encntr_attr),
        " = ")
       SET parser_buffer[10] = "request->xxx_combine[icombine]->encntr_id"
       SET parser_buffer[11] = "go"
       FOR (x = 1 TO 11)
         CALL parser(parser_buffer[x])
       ENDFOR
      ELSE
       SET failed = data_error
       SET request->error_message =
       "request->xxx_combine[*]->encntr_id was != 0 for a parent entity other than person."
       GO TO cmb_check_error
      ENDIF
      SET count_of_updates = curqual
      SET ecode = error(emsg,0)
      IF (ecode != 0)
       SET error_table = rcmblist->qual[maincount1].cmb_entity
       SET failed = ccl_error
       GO TO cmb_check_error
      ENDIF
     ENDIF
     CALL upd_cmb_audit(rcmblist->qual[maincount1].cmb_audit_id,0.0,2)
     IF (count_of_inserts != count_of_updates)
      SET error_table = rcmblist->qual[maincount1].cmb_entity
      SET request->error_message = concat(
       "Number of combine details inserted != number of records updated for generic table ",trim(
        error_table,3),"."," Try combine again.")
      SET failed = general_error
      GO TO cmb_check_error
     ENDIF
   ENDFOR
   SET cmbmetadatacount = size(rcmbmetadatalist->qual,5)
   FOR (maincount6 = 1 TO cmbmetadatacount)
     SET error_table = rcmbmetadatalist->qual[maincount6].cmb_entity
     CALL echo(concat("Generate metadata sql for ",trim(error_table),"....."))
     SET count_of_inserts = 0
     SET count_of_updates = 0
     IF ( NOT (rcmbmetadatalist->qual[maincount6].ignore_ind))
      SET rcmbmetadatalist->qual[maincount6].cmb_audit_id = ins_cmb_audit(request,icombine,
       call_script,rcmbmetadatalist->qual[maincount6].cmb_entity_attribute,rcmbmetadatalist->qual[
       maincount6].cmb_entity,
       " ",cmb_group_id,"COMBINE",rev_cmb_request->reverse_ind,2)
      CALL add_cmb_det_metadata(main_dummy)
      SET ecode = error(emsg,0)
      IF (ecode != 0)
       SET failed = ccl_error
       GO TO cmb_check_error
      ENDIF
     ENDIF
     IF ((rcmbmetadatalist->qual[maincount6].upt_ind=1))
      SET error_table = rcmbmetadatalist->qual[maincount6].cmb_entity
      FOR (buf_cnt = 1 TO 26)
        SET parser_buffer[buf_cnt] = fillstring(132," ")
      ENDFOR
      CALL echo(concat("Updating ",trim(error_table),"....."))
      CALL echo(concat("Combine_TO_ID = ",cnvtstring(cmb_to_id,20,0)))
      SET parser_buffer[1] = concat("update from ",trim(rcmbmetadatalist->qual[maincount6].cmb_entity
        )," x")
      IF ((rcmbmetadatalist->qual[maincount6].cmb_action_cd=del))
       SET parser_buffer[2] = "set x.active_ind = 0,"
      ELSE
       SET parser_buffer[2] = concat("set x.",trim(rcmbmetadatalist->qual[maincount6].
         cmb_entity_attribute)," = CMB_TO_ID, ")
      ENDIF
      SET parser_buffer[3] = "x.updt_cnt = x.updt_cnt + 1, "
      SET parser_buffer[4] = "x.updt_dt_tm = cnvtdatetime(curdate, curtime3), "
      IF ((rcmbmetadatalist->qual[maincount6].cmb_action_cd=bypass_uid))
       SET parser_buffer[5] = "x.updt_id = x.updt_id, "
      ELSE
       SET parser_buffer[5] = "x.updt_id = reqinfo->updt_id, "
      ENDIF
      SET parser_buffer[6] = "x.updt_task = 100102, "
      SET parser_buffer[7] = "x.updt_applctx = reqinfo->updt_applctx"
      SET parser_buffer[8] = concat("where x.",trim(rcmbmetadatalist->qual[maincount6].
        cmb_entity_attribute)," = CMB_FROM_ID")
      SET parser_buffer[9] = concat("and ",trim(rcmbmetadatalist->qual[maincount6].where_clause))
      IF ((request->xxx_combine[icombine].encntr_id=0))
       SET parser_buffer[10] = "go"
       FOR (x = 1 TO 10)
        CALL echo(parser_buffer[x])
        CALL parser(parser_buffer[x])
       ENDFOR
      ELSE
       SET failed = data_error
       SET request->error_message =
       "request->xxx_combine[*]->encntr_id was != 0 for a a table on DM_CMB_METADATA."
       GO TO cmb_check_error
      ENDIF
      SET count_of_updates = curqual
      SET ecode = error(emsg,0)
      IF (ecode != 0)
       SET error_table = rcmbmetadatalist->qual[maincount6].cmb_entity
       SET failed = ccl_error
       GO TO cmb_check_error
      ENDIF
     ENDIF
     CALL upd_cmb_audit(rcmbmetadatalist->qual[maincount6].cmb_audit_id,0.0,2)
     IF (count_of_inserts != count_of_updates)
      SET error_table = rcmbmetadatalist->qual[maincount6].cmb_entity
      SET request->error_message = build2("Number of combine details inserted",count_of_inserts,
       " != number of records updated",count_of_updates," for generic table ",
       trim(error_table,3),"."," Try combine again.")
      SET failed = general_error
      GO TO cmb_check_error
     ENDIF
   ENDFOR
   SET begin_icombinedet = (icombinedet+ 1)
   SET totalcombinedet = 0
   IF (dm_debug_cmb=1)
    CALL echo(build("max_script_run_order =",max_script_run_order))
    CALL echo(build("childcount2 =",childcount2))
   ENDIF
   FOR (script_run_cnt = 1 TO max_script_run_order)
     FOR (maincount3 = 1 TO childcount2)
       IF ((rcmblist->custom[maincount3].script_run_order=script_run_cnt))
        IF ( NOT (rcmblist->custom[maincount3].ignore_ind))
         IF (dm_debug_cmb=1)
          SET mem_save = curmem
          CALL echo(build("mem_save =",mem_save))
         ENDIF
         SET rcmblist->custom[maincount3].cmb_audit_id = ins_cmb_audit(request,icombine,call_script,
          " ",rcmblist->custom[maincount3].table_name,
          rcmblist->custom[maincount3].script_name,cmb_group_id,"COMBINE",rev_cmb_request->
          reverse_ind,2)
         SET icombinedet = 0
         CALL echo(" ")
         CALL echo(concat("Executing ",trim(rcmblist->custom[maincount3].script_name),"....."))
         CALL echo(" ")
         CALL echo("**************************")
         CALL echo("**************************")
         SET modify = nopredeclare
         SET trace = norecpersist
         CALL parser(concat("execute ",rcmblist->custom[maincount3].script_name," go"))
         IF (dm_debug_cmb=1)
          CALL echo(build("iCombineDet =",icombinedet))
         ENDIF
         IF (failed != false)
          SET error_table = rcmblist->custom[maincount3].table_name
          GO TO cmb_check_error
         ENDIF
         SET ecode = error(emsg,0)
         IF (ecode != 0)
          SET error_table = rcmblist->custom[maincount3].table_name
          SET failed = ccl_error
          GO TO cmb_check_error
         ENDIF
         IF (icombinedet > 0)
          IF (dm_debug_cmb)
           SET mem1 = curmem
           CALL echo(build("mem_userd_rec=",(mem_save - mem1)))
          ENDIF
          EXECUTE dm_cmb_add_det_custom
          IF (dm_det_qual_ind=0
           AND (request->cmb_mode != "RE-CMB"))
           SET failed = insert_error
           SET request->error_message = concat("Couldn't insert custom detail information into",
            cmb_det_table)
           GO TO cmb_check_error
          ENDIF
          IF (dm_debug_cmb)
           SET mem2 = curmem
           CALL echo(build("mem_used_parser=",(mem1 - mem2)))
          ENDIF
          IF (dm_debug_cmb)
           CALL echo(build("memory used =",(mem_save - curmem)))
           CALL echo("before alterlist to zero.")
           CALL trace(7)
          ENDIF
          SET stat = alterlist(request->xxx_combine_det,0)
          IF (dm_debug_cmb)
           CALL echo("after alterlist to zero.")
           CALL trace(7)
           CALL echo(build("curmem3 =",curmem))
          ENDIF
          SET totalcombinedet += icombinedet
         ELSE
          IF ( NOT (recombining))
           SET icombinedet += 1
           SET stat = alterlist(request->xxx_combine_det,icombinedet)
           SET request->xxx_combine_det[icombinedet].combine_action_cd = noop
           SET request->xxx_combine_det[icombinedet].entity_id = 0.0
           SET request->xxx_combine_det[icombinedet].entity_name = rcmblist->custom[maincount3].
           table_name
           SET request->xxx_combine_det[icombinedet].attribute_name = rcmblist->custom[maincount3].
           script_name
           EXECUTE dm_cmb_add_det_custom
          ENDIF
         ENDIF
         SET ecode = error(emsg,0)
         IF (ecode != 0)
          SET failed = ccl_error
          GO TO cmb_check_error
         ENDIF
         CALL upd_cmb_audit(rcmblist->custom[maincount3].cmb_audit_id,0.0,2)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (dm_debug_cmb=1)
    CALL echo(build("TotalCombineDet =",totalcombinedet))
   ENDIF
   SET end_icombinedet = icombinedet
   SET icombinedet = totalcombinedet
   SET custom_det_ind = 1
   SET ecode = error(emsg,0)
   IF (ecode != 0)
    SET error_table = " "
    SET failed = ccl_error
    GO TO cmb_check_error
   ENDIF
   IF (auto_encntr_move_child_ind="1")
    SET totalcombinedetem = 0
    SET stat = alterlist(request->xxx_combine_det,0)
    FOR (em_run_cnt = 1 TO max_em_run_order)
     FOR (maincount5 = 1 TO mp->tbl_cnt)
       IF ((mp->tbl[maincount5].run_order=em_run_cnt))
        IF ( NOT (mp->tbl[maincount5].ignore_ind))
         IF (dm_debug_cmb=1)
          SET mem_save = curmem
          CALL echo(build("mem_save =",mem_save))
          CALL echo(" ")
          CALL echo(concat("Executing dm_cmb_add_det_em"))
          CALL echo(" ")
          CALL echo("**************************")
          CALL echo("**************************")
         ENDIF
         SET icombinedetem = 0
         EXECUTE dm_cmb_add_det_em mp->tbl[maincount5].child_table, mp->tbl[maincount5].child_cmb_col,
         mp->tbl[maincount5].child_pk_col,
         mp->tbl[maincount5].parent_table, mp->tbl[maincount5].parent_cmb_col, mp->tbl[maincount5].
         from_clause,
         mp->tbl[maincount5].where_clause
         IF (dm_debug_cmb=1)
          CALL echo(build("iCombineDetEM =",icombinedetem))
         ENDIF
         IF (failed != false)
          SET error_table = mp->tbl[maincount5].child_table
          GO TO cmb_check_error
         ENDIF
         SET totalcombinedetem += icombinedetem
         SET stat = alterlist(request->xxx_combine_det,0)
        ENDIF
       ENDIF
     ENDFOR
     IF (dm_debug_cmb=1)
      CALL echo(build("TotalCombineDetEM =",totalcombinedetem))
     ENDIF
    ENDFOR
    SET icombinedetem = totalcombinedetem
   ENDIF
   IF (count_of_inserts=0
    AND totalcombinedet=0
    AND totalcombinedetem=0
    AND call_script="DM_UNCOMBINE"
    AND (request->parent_table="PERSON"))
    DELETE  FROM person_combine pc
     WHERE (pc.person_combine_id=request->xxx_combine[icombine].xxx_combine_id)
    ;end delete
   ENDIF
   IF ( NOT (recombining))
    SET reply_cnt += 1
    SET stat = alterlist(reply->xxx_combine_id,reply_cnt)
    SET reply->xxx_combine_id[reply_cnt].combine_id = request->xxx_combine[icombine].xxx_combine_id
    SET reply->xxx_combine_id[reply_cnt].parent_table = request->parent_table
    SET reply->xxx_combine_id[reply_cnt].from_xxx_id = request->xxx_combine[icombine].from_xxx_id
    SET reply->xxx_combine_id[reply_cnt].to_xxx_id = request->xxx_combine[icombine].to_xxx_id
    SET reply->xxx_combine_id[reply_cnt].encntr_id = request->xxx_combine[icombine].encntr_id
   ENDIF
   IF ((request->parent_table="PERSON")
    AND (request->xxx_combine[icombine].encntr_id=0)
    AND (request->cmb_mode != "RE-CMB")
    AND  NOT (recombining))
    IF (prsnl_cmb_ind=1
     AND  NOT (recombining))
     SET prsnl_cnt += 1
     SET stat = alterlist(rcmbprsnl->qual,prsnl_cnt)
     SET rcmbprsnl->qual[prsnl_cnt].person_combine_id = request->xxx_combine[icombine].xxx_combine_id
     SET rcmbprsnl->qual[prsnl_cnt].from_prsnl_id = request->xxx_combine[icombine].from_xxx_id
     SET rcmbprsnl->qual[prsnl_cnt].to_prsnl_id = request->xxx_combine[icombine].to_xxx_id
     SET rcmbprsnl->qual[prsnl_cnt].cmb_group_id = cmb_group_id
     SET rcmbprsnl->size = prsnl_cnt
    ENDIF
   ENDIF
   IF (call_script != "DM_UNCOMBINE"
    AND (request->cmb_mode != "TESTING")
    AND prsnl_cmb_ind=0
    AND dm_debug_cmb != 1)
    COMMIT
   ENDIF
   IF ( NOT (recombining))
    IF ((request->parent_table="PERSON")
     AND call_script="DM_CALL_COMBINE")
     IF (dm_debug_cmb=1)
      CALL echo(build("auto_encntr = ",auto_encntr_cmb_ind))
     ENDIF
     IF (auto_encntr_cmb_ind="1")
      IF (dm_debug_cmb=1)
       CALL echo("Check for duplicate encounters...")
      ENDIF
      EXECUTE dm_check_encntrs request->xxx_combine[icombine].to_xxx_id, request->xxx_combine[
      icombine].to_xxx_id
      IF (failed != false)
       GO TO cmb_check_error
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (dm_debug_cmb=1)
    CALL echo(build("recombining =",recombining))
    CALL echo("Loop back if not recombining...")
   ENDIF
   IF (call_script="DM_CALL_COMBINE")
    IF (recombining)
     SET recombining = 0
    ELSE
     CASE (cnvtupper(trim(request->parent_table,3)))
      OF "PERSON":
       IF ((request->cmb_mode != "RE-CMB"))
        IF ( NOT (request->xxx_combine[icombine].encntr_id))
         UPDATE  FROM person p
          SET p.active_ind = 1, p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
          WHERE (p.person_id=request->xxx_combine[icombine].from_xxx_id)
          WITH nocounter
         ;end update
        ENDIF
       ENDIF
      OF "ENCOUNTER":
       IF ((request->cmb_mode != "RE-CMB"))
        UPDATE  FROM encounter e
         SET e.active_ind = 1, e.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WHERE (e.encntr_id=request->xxx_combine[icombine].from_xxx_id)
         WITH nocounter
        ;end update
       ENDIF
     ENDCASE
     SET recombining = 1
     SET icombine -= 1
    ENDIF
   ENDIF
   SET ecode = error(emsg,0)
   IF (ecode != 0)
    SET failed = ccl_error
    GO TO cmb_check_error
   ENDIF
   IF ((( NOT (recombining)) OR (call_script="DM_UNCOMBINE")) )
    CALL upd_cmb_audit(cmb_audit_id,0.0,1)
   ENDIF
 ENDFOR
 SUBROUTINE add_cmb(dummy)
   SET new_combine_id = 0.0
   FOR (buf_cnt = 1 TO 26)
     SET parser_buffer[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = 'select into "nl:"'
   SET parser_buffer[2] = concat("y = seq(",trim(cmb_seq),", nextval)")
   SET parser_buffer[3] = "from dual"
   SET parser_buffer[4] = "detail"
   SET parser_buffer[5] = "new_combine_id = cnvtreal(y)"
   SET parser_buffer[6] = "with nocounter go"
   FOR (x = 1 TO 6)
     CALL parser(parser_buffer[x])
   ENDFOR
   SET request->xxx_combine[icombine].xxx_combine_id = new_combine_id
   IF (curqual=0)
    SET failed = gen_nbr_error
    SET request->error_message = concat("Couldn't get next sequence value from ",cmb_seq)
    GO TO cmb_check_error
    SET error_ind = 0
   ENDIF
   FOR (buf_cnt = 1 TO 33)
     SET parser_buffer[buf_cnt] = fillstring(132," ")
   ENDFOR
   IF (trim(request->parent_table)="PERSON")
    SET parser_buffer[1] = concat("insert into ",trim(cmb_table))
    SET parser_buffer[2] = concat("(",trim(cmb_table_id),
     ",updt_cnt,updt_dt_tm,updt_id,updt_task,updt_applctx,")
    SET parser_buffer[3] =
    "active_ind, active_status_cd, active_status_dt_tm, active_status_prsnl_id, "
    SET parser_buffer[4] = concat(trim(cmb_from),",",trim(cmb_to),
     ",contributor_system_cd,combine_action_cd,")
    SET parser_buffer[5] = "from_mrn, from_alias_pool_cd, from_alias_type_cd,"
    IF (dc_cmb_dt_tm_ind=1)
     SET parser_buffer[6] = concat("to_mrn, to_alias_pool_cd, to_alias_type_cd,",
      "transaction_type, application_flag, combine_weight,","cmb_dt_tm, cmb_updt_id,")
    ELSE
     SET parser_buffer[6] = concat("to_mrn, to_alias_pool_cd, to_alias_type_cd,",
      "transaction_type, application_flag, combine_weight,")
    ENDIF
    SET parser_buffer[7] = "prev_active_ind, prev_active_status_cd, prev_confid_level_cd, encntr_id)"
    SET parser_buffer[8] = "(select NEW_COMBINE_ID, "
    SET parser_buffer[9] = "INIT_UPDT_CNT, "
    SET parser_buffer[10] = "cnvtdatetime(curdate, curtime3), "
    SET parser_buffer[11] = "reqinfo->updt_id, "
    SET parser_buffer[12] = "reqinfo->updt_task, "
    SET parser_buffer[13] = "reqinfo->updt_applctx, "
    SET parser_buffer[14] = "ACTIVE_ACTIVE_IND, "
    SET parser_buffer[15] = "reqdata->active_status_cd, "
    SET parser_buffer[16] = "cnvtdatetime(curdate, curtime3), "
    SET parser_buffer[17] = "reqinfo->updt_id, "
    SET parser_buffer[18] = "request->xxx_combine[iCombine]->from_xxx_id, "
    SET parser_buffer[19] = "request->xxx_combine[iCombine]->to_xxx_id, "
    SET parser_buffer[20] = "reqdata->contributor_system_cd, "
    SET parser_buffer[21] = "DEL, "
    SET parser_buffer[22] = "request->xxx_combine[iCombine]->from_mrn, "
    SET parser_buffer[23] = "request->xxx_combine[iCombine]->from_alias_pool_cd, "
    SET parser_buffer[24] = "request->xxx_combine[iCombine]->from_alias_type_cd, "
    SET parser_buffer[25] = "request->xxx_combine[iCombine]->to_mrn, "
    SET parser_buffer[26] = concat("request->xxx_combine[iCombine]->to_alias_pool_cd, ",
     "request->xxx_combine[iCombine]->to_alias_type_cd, ")
    SET parser_buffer[27] = concat("request->transaction_type, ",
     "request->xxx_combine[iCombine]->application_flag, ",
     "request->xxx_combine[iCombine]->combine_weight,")
    IF (dc_cmb_dt_tm_ind=1)
     SET parser_buffer[28] = "cnvtdatetime(curdate, curtime3), reqinfo->updt_id, x.active_ind, "
    ELSE
     SET parser_buffer[28] = "x.active_ind, "
    ENDIF
    SET parser_buffer[29] = "x.active_status_cd, "
    SET parser_buffer[30] = "x.confid_level_cd, "
    SET parser_buffer[31] = "request->xxx_combine[iCombine]->encntr_id "
    SET parser_buffer[32] = concat("from ",trim(request->parent_table)," x")
    SET parser_buffer[33] = concat("where x.",trim(cmb_id)," = CMB_FROM_ID) go")
    FOR (x = 1 TO 33)
      CALL parser(parser_buffer[x])
    ENDFOR
   ELSE
    SET parser_buffer[1] = concat("insert into ",trim(cmb_table))
    SET parser_buffer[2] = concat("(",trim(cmb_table_id),
     ",updt_cnt,updt_dt_tm,updt_id,updt_task,updt_applctx,")
    SET parser_buffer[3] = concat(
     "active_ind, active_status_cd, active_status_dt_tm, active_status_prsnl_id, ",
     "transaction_type, application_flag, ")
    SET parser_buffer[4] = concat(trim(cmb_from),",",trim(cmb_to),
     ",contributor_system_cd,combine_action_cd,")
    IF (dc_cmb_dt_tm_ind=1)
     SET parser_buffer[5] = "cmb_dt_tm, cmb_updt_id,"
    ENDIF
    IF (trim(request->parent_table)="ENCOUNTER")
     SET parser_buffer[6] = "prev_active_ind, prev_active_status_cd, prev_confid_level_cd)"
    ELSE
     SET parser_buffer[6] = "prev_active_ind, prev_active_status_cd)"
    ENDIF
    SET parser_buffer[7] = "(select NEW_COMBINE_ID, "
    SET parser_buffer[8] = "INIT_UPDT_CNT, "
    SET parser_buffer[9] = "cnvtdatetime(curdate, curtime3), "
    SET parser_buffer[10] = "reqinfo->updt_id, "
    SET parser_buffer[11] = "reqinfo->updt_task, "
    SET parser_buffer[12] = "reqinfo->updt_applctx, "
    SET parser_buffer[13] = "ACTIVE_ACTIVE_IND, "
    SET parser_buffer[14] = "reqdata->active_status_cd, "
    SET parser_buffer[15] = "cnvtdatetime(curdate, curtime3), "
    SET parser_buffer[16] = concat("reqinfo->updt_id, ","request->transaction_type, ",
     "request->xxx_combine[iCombine]->application_flag, ")
    SET parser_buffer[17] = "request->xxx_combine[iCombine]->from_xxx_id, "
    SET parser_buffer[18] = "request->xxx_combine[iCombine]->to_xxx_id, "
    SET parser_buffer[19] = "reqdata->contributor_system_cd, "
    SET parser_buffer[20] = "DEL, "
    IF (dc_cmb_dt_tm_ind=1)
     SET parser_buffer[21] = "cnvtdatetime(curdate, curtime3), reqinfo->updt_id,"
    ENDIF
    SET parser_buffer[22] = "x.active_ind, "
    IF (trim(request->parent_table)="ENCOUNTER")
     SET parser_buffer[23] = "x.active_status_cd, "
     SET parser_buffer[24] = "x.confid_level_cd"
    ELSE
     SET parser_buffer[23] = "x.active_status_cd "
    ENDIF
    SET parser_buffer[25] = concat("from ",trim(request->parent_table)," x")
    SET parser_buffer[26] = concat("where x.",trim(cmb_id)," = CMB_FROM_ID) go")
    FOR (x = 1 TO 26)
      CALL parser(parser_buffer[x])
    ENDFOR
   ENDIF
   IF (curqual=0)
    SET failed = insert_error
    SET request->error_message = concat("Couldn't insert into ",cmb_table,".  Check if 'from' ",trim(
      request->parent_table)," exists or if tablespace is full.")
    SET error_ind = 0
    GO TO cmb_check_error
   ENDIF
   SET request->xxx_combine[icombine].xxx_combine_id = new_combine_id
 END ;Subroutine
 SUBROUTINE add_cmb_det_generic(dummy)
   FOR (buf_cnt = 1 TO 26)
     SET parser_buffer[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = concat("insert into ",trim(cmb_det_table))
   SET parser_buffer[2] = "(attribute_name, combine_action_cd, "
   SET parser_buffer[3] = concat(trim(cmb_table_id),", entity_id, ")
   SET parser_buffer[4] = concat("entity_name, ",trim(cmb_det_table_id),
    ", updt_cnt, updt_dt_tm, updt_id, updt_task,")
   SET parser_buffer[5] = concat("updt_applctx, active_ind, active_status_cd, ",
    "active_status_dt_tm, active_status_prsnl_id)")
   SET parser_buffer[6] = concat('(select "',trim(rcmblist->qual[maincount1].cmb_entity_attribute),
    '", ')
   SET parser_buffer[7] = "CMB_ACTION, "
   SET parser_buffer[8] = "request->xxx_combine[iCombine]->xxx_combine_id, "
   SET parser_buffer[9] = concat("x.",trim(rcmblist->qual[maincount1].cmb_entity_pk),", ")
   SET parser_buffer[10] = concat('"',trim(rcmblist->qual[maincount1].cmb_entity),'", ')
   SET parser_buffer[11] = concat("seq(",trim(cmb_seq),", nextval), ")
   SET parser_buffer[12] = "INIT_UPDT_CNT, "
   SET parser_buffer[13] = "cnvtdatetime(curdate, curtime3), "
   SET parser_buffer[14] = "reqinfo->updt_id, "
   SET parser_buffer[15] = "reqinfo->updt_task, "
   SET parser_buffer[16] = "reqinfo->updt_applctx, "
   SET parser_buffer[17] = "ACTIVE_ACTIVE_IND, "
   SET parser_buffer[18] = "reqdata->active_status_cd, "
   SET parser_buffer[19] = "cnvtdatetime(curdate, curtime3), "
   SET parser_buffer[20] = "reqinfo->updt_id "
   SET parser_buffer[21] = concat("from ",trim(rcmblist->qual[maincount1].cmb_entity)," x")
   SET parser_buffer[22] = concat("where x.",trim(rcmblist->qual[maincount1].cmb_entity_attribute),
    " = CMB_FROM_ID")
   IF ((request->xxx_combine[icombine].encntr_id=0))
    SET parser_buffer[23] = ") go"
   ELSEIF ((request->parent_table="PERSON")
    AND (request->xxx_combine[icombine].encntr_id != 0))
    SET parser_buffer[23] = concat("and x.",trim(rcmblist->qual[maincount1].cmb_entity_encntr_attr),
     " = ")
    SET parser_buffer[24] = "request->xxx_combine[icombine]->encntr_id "
    SET parser_buffer[25] = ") go"
   ELSE
    SET failed = data_error
    SET request->error_message =
    "request->xxx_combine[*]->encntr_id was != 0 for a parent entity other than person."
    GO TO cmb_check_error
   ENDIF
   FOR (x = 1 TO 25)
     CALL parser(parser_buffer[x])
   ENDFOR
   SET count_of_inserts += curqual
   IF (curqual > 0)
    SET rcmblist->qual[maincount1].upt_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE add_cmb_det_metadata(dummy)
   FOR (buf_cnt = 1 TO 26)
     SET parser_buffer[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = concat("insert into ",trim(cmb_det_table))
   SET parser_buffer[2] = "(attribute_name, combine_action_cd, "
   SET parser_buffer[3] = concat(trim(cmb_table_id),", entity_id, ")
   SET parser_buffer[4] = concat("entity_name, ",trim(cmb_det_table_id),
    ", updt_cnt, updt_dt_tm, updt_id, updt_task,")
   SET parser_buffer[5] = concat("updt_applctx, active_ind, active_status_cd, ",
    "active_status_dt_tm, active_status_prsnl_id)")
   SET parser_buffer[6] = concat('(select "',trim(rcmbmetadatalist->qual[maincount6].
     cmb_entity_attribute),'", ')
   SET parser_buffer[7] = "rCmbMetadataList->qual[maincount6]->cmb_action_cd, "
   SET parser_buffer[8] = "request->xxx_combine[iCombine]->xxx_combine_id, "
   SET parser_buffer[9] = concat("x.",trim(rcmbmetadatalist->qual[maincount6].cmb_entity_pk),", ")
   SET parser_buffer[10] = concat('"',trim(rcmbmetadatalist->qual[maincount6].cmb_entity),'", ')
   SET parser_buffer[11] = concat("seq(",trim(cmb_seq),", nextval), ")
   SET parser_buffer[12] = "INIT_UPDT_CNT, "
   SET parser_buffer[13] = "cnvtdatetime(curdate, curtime3), "
   SET parser_buffer[14] = "reqinfo->updt_id, "
   SET parser_buffer[15] = "reqinfo->updt_task, "
   SET parser_buffer[16] = "reqinfo->updt_applctx, "
   SET parser_buffer[17] = "ACTIVE_ACTIVE_IND, "
   SET parser_buffer[18] = "reqdata->active_status_cd, "
   SET parser_buffer[19] = "cnvtdatetime(curdate, curtime3), "
   SET parser_buffer[20] = "reqinfo->updt_id "
   SET parser_buffer[21] = concat("from ",trim(rcmbmetadatalist->qual[maincount6].cmb_entity)," x")
   SET parser_buffer[22] = concat("where x.",trim(rcmbmetadatalist->qual[maincount6].
     cmb_entity_attribute)," = CMB_FROM_ID")
   SET parser_buffer[23] = concat("and ",trim(rcmbmetadatalist->qual[maincount6].where_clause))
   IF ((request->xxx_combine[icombine].encntr_id=0))
    SET parser_buffer[24] = ") go"
   ELSE
    SET failed = data_error
    SET request->error_message =
    "request->xxx_combine[*]->encntr_id was != 0 for a parent entity other than person."
    GO TO cmb_check_error
   ENDIF
   FOR (x = 1 TO 25)
    CALL echo(parser_buffer[x])
    CALL parser(parser_buffer[x])
   ENDFOR
   IF (curqual > 0)
    SET rcmbmetadatalist->qual[maincount6].upt_ind = 1
   ENDIF
   SET count_of_inserts += curqual
   IF (dm_debug_cmb=1)
    CALL echo(build("table name =",rcmbmetadatalist->qual[maincount6].cmb_entity))
    CALL echo(build("number of rows inserted =",curqual))
    CALL echo(build("rCmbMetadataList->qual[maincount6]->upt_ind =",rcmbmetadatalist->qual[maincount6
      ].upt_ind))
   ENDIF
 END ;Subroutine
 SUBROUTINE add_cmb_det_custom(dummy)
   IF (((recombining) OR ((request->cmb_mode="RE-CMB"))) )
    FOR (buf_cnt = 1 TO 6)
      SET parser_buffer[buf_cnt] = fillstring(132," ")
    ENDFOR
    SET parser_buffer[1] = "select into 'nl:' d.entity_id"
    SET parser_buffer[2] = concat("from ",trim(cmb_det_table)," d")
    SET parser_buffer[3] = concat("where d.",trim(cmb_table_id),
     " = request->xxx_combine_det[maincount4]->xxx_combine_id")
    SET parser_buffer[4] = "and d.entity_id = request->xxx_combine_det[maincount4]->entity_id"
    SET parser_buffer[5] = "and d.entity_name = request->xxx_combine_det[maincount4]->entity_name"
    SET parser_buffer[6] = "with nocounter go"
    FOR (buf_cnt = 1 TO 6)
      CALL parser(parser_buffer[buf_cnt])
    ENDFOR
    IF (curqual)
     IF (dm_debug_cmb=1)
      CALL echo(build("entity_id=",request->xxx_combine_det[maincount4].entity_id," on table=",
        request->xxx_combine_det[maincount4].entity_name," already exists..."))
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   FOR (buf_cnt = 1 TO 26)
     SET parser_buffer[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = concat("insert into ",trim(cmb_det_table)," set")
   SET parser_buffer[2] = "attribute_name=request->xxx_combine_det[maincount4]->attribute_name,"
   SET parser_buffer[3] =
   "combine_action_cd=request->xxx_combine_det[maincount4]->combine_action_cd,"
   SET parser_buffer[4] = concat(trim(cmb_table_id),
    "=request->xxx_combine_det[maincount4]->xxx_combine_id,")
   SET parser_buffer[5] = "entity_id=request->xxx_combine_det[maincount4]->entity_id,"
   SET parser_buffer[6] = "entity_name=request->xxx_combine_det[maincount4]->entity_name,"
   SET parser_buffer[7] = concat(trim(cmb_det_table_id),"=seq(",trim(cmb_seq),", nextval),")
   SET parser_buffer[8] = "updt_cnt=INIT_UPDT_CNT,"
   SET parser_buffer[9] = "updt_dt_tm=cnvtdatetime(curdate, curtime3),"
   SET parser_buffer[10] = "updt_id=reqinfo->updt_id,"
   SET parser_buffer[11] = "updt_task=reqinfo->updt_task,"
   SET parser_buffer[12] = "updt_applctx=reqinfo->updt_applctx,"
   SET parser_buffer[13] = "active_ind=ACTIVE_ACTIVE_IND,"
   SET parser_buffer[14] = "active_status_cd=reqdata->active_status_cd,"
   SET parser_buffer[15] = "active_status_dt_tm=cnvtdatetime(curdate, curtime3),"
   SET parser_buffer[16] = "active_status_prsnl_id=reqinfo->updt_id,"
   SET parser_buffer[17] = "prev_active_ind = request->xxx_combine_det[maincount4]->prev_active_ind,"
   SET parser_buffer[18] = "combine_desc_cd = request->xxx_combine_det[maincount4]->combine_desc_cd,"
   SET parser_buffer[19] = "to_record_ind = request->xxx_combine_det[maincount4]->to_record_ind,"
   SET parser_buffer[20] =
   "prev_active_status_cd = request->xxx_combine_det[maincount4]->prev_active_status_cd,"
   SET parser_buffer[21] =
   "prev_end_eff_dt_tm = cnvtdatetime(request->xxx_combine_det[maincount4]->prev_end_eff_dt_tm) "
   SET parser_buffer[22] = "go"
   FOR (buf_cnt = 1 TO 22)
     CALL parser(parser_buffer[buf_cnt])
   ENDFOR
   IF (curqual=0)
    SET failed = insert_error
    SET request->error_message = concat("Couldn't insert custom detail information into",
     cmb_det_table)
    GO TO cmb_check_error
   ENDIF
   SET custom_cmb_det_cnt += 1
 END ;Subroutine
 SUBROUTINE upt_cmb(dummy)
  IF ((request->parent_table="PERSON"))
   UPDATE  FROM person_combine pc
    SET pc.updt_task = 77777, pc.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (pc.person_combine_id=request->xxx_combine[icombine].xxx_combine_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat(
     "Couldn't update person_combine table where person_combine_id = ",build(request->xxx_combine[
      icombine].xxx_combine_id))
    GO TO cmb_check_error
   ENDIF
  ELSEIF ((request->parent_table="ENCOUNTER"))
   UPDATE  FROM encntr_combine ec
    SET ec.updt_task = 77777, ec.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (ec.encntr_combine_id=request->xxx_combine[icombine].xxx_combine_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat(
     "Couldn't update encntr_combine table where encntr_combine_id = ",build(request->xxx_combine[
      icombine].xxx_combine_id))
    GO TO cmb_check_error
   ENDIF
  ENDIF
  IF (dm_debug_cmb=1)
   IF (curqual >= 1)
    CALL echo(build("Updated combine_id =",request->xxx_combine[icombine].xxx_combine_id))
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE check_encounter(ce_encntr_id)
   IF (ce_encntr_id)
    SELECT INTO "nl:"
     c.from_encntr_id
     FROM encntr_combine c
     WHERE c.from_encntr_id=ce_encntr_id
      AND c.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual)
     SET failed = data_error
     SET request->error_message = concat("Encounter ",trim(cnvtstring(ce_encntr_id),3),
      " has previously been combined away.")
     GO TO cmb_check_error
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_move(cm_person_id,cm_encntr_id)
   IF (cm_encntr_id
    AND cm_person_id)
    SELECT INTO "nl:"
     c.to_person_id
     FROM person_combine c
     WHERE c.encntr_id=cm_encntr_id
      AND c.to_person_id != cm_person_id
      AND c.active_ind=1
      AND c.person_combine_id IN (
     (SELECT
      max(x.person_combine_id)
      FROM person_combine x
      WHERE x.encntr_id=cm_encntr_id
       AND x.active_ind=1))
     WITH nocounter
    ;end select
    IF (curqual)
     SET failed = data_error
     SET request->error_message = concat("Encounter ",trim(cnvtstring(cm_encntr_id),3),
      " has previously been moved to a different person.")
     GO TO cmb_check_error
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_person(cp_person_id)
   IF (cp_person_id)
    SELECT INTO "nl:"
     c.from_person_id
     FROM person_combine c
     WHERE c.from_person_id=cp_person_id
      AND c.encntr_id=0.0
      AND c.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual)
     SET failed = data_error
     SET request->error_message = concat("Person ",trim(cnvtstring(cp_person_id),3),
      " has previously been combined away.")
     GO TO cmb_check_error
    ENDIF
   ENDIF
 END ;Subroutine
#cmb_check_error
 IF (failed != false)
  IF (validate(recombining,0))
   SET request->cmb_mode = "RECOMBINING"
   SET request->error_message = concat("Uncombine required.  ",trim(request->error_message,3))
  ENDIF
  ROLLBACK
  SET error_cnt += 1
  SET stat = alterlist(reply->error,error_cnt)
  SELECT INTO "nl:"
   y = seq(combine_error_seq,nextval)
   FROM dual
   DETAIL
    next_seq_val = cnvtreal(y)
   WITH nocounter
  ;end select
  SET etype = fillstring(50," ")
  IF (failed=3)
   SET etype = "GEN_NBR_ERROR"
  ELSEIF (failed=4)
   SET etype = "INSERT_ERROR"
  ELSEIF (failed=5)
   SET etype = "UPDATE_ERROR"
  ELSEIF (failed=6)
   SET etype = "REPLACE_ERROR"
  ELSEIF (failed=7)
   SET etype = "DELETE_ERROR"
  ELSEIF (failed=8)
   SET etype = "UNDELETE_ERROR"
  ELSEIF (failed=9)
   SET etype = "REMOVE_ERROR"
  ELSEIF (failed=10)
   SET etype = "ATTRIBUTE_ERROR"
  ELSEIF (failed=11)
   SET etype = "LOCK_ERROR"
  ELSEIF (failed=12)
   SET etype = "NONE_FOUND"
  ELSEIF (failed=13)
   SET etype = "SELECT_ERROR"
  ELSEIF (failed=14)
   SET etype = "DATA_ERROR"
  ELSEIF (failed=15)
   SET etype = "GENERAL_ERROR"
  ELSEIF (failed=16)
   SET etype = "REACTIVATE_ERROR"
  ELSEIF (failed=17)
   SET etype = "EFF_ERROR"
  ELSEIF (failed=18)
   SET etype = "CCL_ERROR"
  ELSEIF (failed=21)
   SET etype = "COMMIT_ERROR"
  ENDIF
  IF (failed=ccl_error)
   IF (validate(recombining,0))
    SET reply->error[error_cnt].error_msg = concat("Uncombine required.",trim(emsg))
   ELSE
    SET reply->error[error_cnt].error_msg = emsg
   ENDIF
  ELSE
   SET reply->error[error_cnt].error_msg = request->error_message
  ENDIF
  UPDATE  FROM dm_combine_error dce
   SET dce.calling_script = call_script, dce.operation_type = "COMBINE", dce.parent_entity = request
    ->parent_table,
    dce.combine_id = parent_combine_id, dce.from_id = request->xxx_combine[icombine].from_xxx_id, dce
    .to_id = request->xxx_combine[icombine].to_xxx_id,
    dce.encntr_id = request->xxx_combine[icombine].encntr_id, dce.error_table = error_table, dce
    .error_type = etype,
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
    SET dce.combine_error_id = next_seq_val, dce.calling_script = call_script, dce.operation_type =
     "COMBINE",
     dce.parent_entity = request->parent_table, dce.combine_id = parent_combine_id, dce.from_id =
     request->xxx_combine[icombine].from_xxx_id,
     dce.to_id = request->xxx_combine[icombine].to_xxx_id, dce.encntr_id = request->xxx_combine[
     icombine].encntr_id, dce.error_table = error_table,
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
  SET reply->error[error_cnt].encntr_id = request->xxx_combine[icombine].encntr_id
  SET reply->error[error_cnt].error_table = error_table
  SET reply->error[error_cnt].error_type = etype
  IF (validate(reply->error[error_cnt].combine_error_id) != 0)
   SET reply->error[error_cnt].combine_error_id = next_seq_val
  ENDIF
  COMMIT
  IF ( NOT (recombining)
   AND commit_check_ind=false
   AND (request->xxx_combine[icombine].xxx_combine_id > 0))
   FOR (buf_cnt = 1 TO 4)
     SET parser_buffer[buf_cnt] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = "select into 'nl:' "
   SET parser_buffer[2] = concat("from ",trim(cmb_table)," d")
   SET parser_buffer[3] = concat("where d.",trim(cmb_table_id),
    " = request->xxx_combine[iCombine]->xxx_combine_id")
   SET parser_buffer[4] = "with nocounter go"
   FOR (buf_cnt = 1 TO 4)
     CALL parser(parser_buffer[buf_cnt])
   ENDFOR
   IF (curqual > 0)
    SET failed = commit_error
    SET commit_check_ind = true
    SET request->error_message = "A partial commit was detected after the combine process errored."
    CALL echo(fillstring(132,"*"))
    CALL echo("*")
    CALL echo("*")
    CALL echo(request->error_message)
    CALL echo("*")
    CALL echo("*")
    CALL echo(fillstring(132,"*"))
    GO TO cmb_check_error
   ENDIF
  ENDIF
  IF (error_cnt <= 5)
   SET ecode = error(emsg,0)
   IF (ecode != 0)
    SET failed = ccl_error
    GO TO cmb_check_error
   ENDIF
  ENDIF
  CALL upd_cmb_audit(cmb_audit_id,next_seq_val,1)
  COMMIT
 ELSE
  SET reqinfo->commit_ind = true
  SET reply->status_data.status = "S"
 ENDIF
 IF (call_script != "DM_UNCOMBINE")
  IF (error_ind=0)
   IF (nbr_to_combine > 1)
    FOR (abc = 2 TO nbr_to_combine)
      SET stat = alterlist(reply->error,abc)
      SET reply->error[abc].create_dt_tm = cnvtdatetime(sysdate)
      SET reply->error[abc].parent_table = request->parent_table
      SET reply->error[abc].from_id = request->xxx_combine[abc].from_xxx_id
      SET reply->error[abc].to_id = request->xxx_combine[abc].to_xxx_id
      SET reply->error[abc].encntr_id = request->xxx_combine[abc].encntr_id
      SET reply->error[abc].error_table = error_table
      SET reply->error[abc].error_type = etype
      SET reply->error[abc].error_msg =
      "Unable to combine due to a fatal error on the previous combine."
    ENDFOR
   ENDIF
   GO TO cmb_end_script
  ELSEIF (error_ind=1)
   IF (icombine < nbr_to_combine)
    IF (custom_det_ind=1)
     SET clean_det_cnt = 0
     SET icombinedet = (begin_icombinedet - 1)
     FOR (clean_det_cnt = begin_icombinedet TO end_icombinedet)
       SET request->xxx_combine_det[clean_det_cnt].xxx_combine_det_id = 0
       SET request->xxx_combine_det[clean_det_cnt].xxx_combine_id = 0
       SET request->xxx_combine_det[clean_det_cnt].entity_name = init_blank
       SET request->xxx_combine_det[clean_det_cnt].entity_id = 0
       SET request->xxx_combine_det[clean_det_cnt].combine_action_cd = 0
       SET request->xxx_combine_det[clean_det_cnt].attribute_name = init_blank
       SET request->xxx_combine_det[clean_det_cnt].prev_active_ind = 0
       SET request->xxx_combine_det[clean_det_cnt].prev_active_status_cd = 0
       SET request->xxx_combine_det[clean_det_cnt].prev_end_eff_dt_tm = 0
       SET request->xxx_combine_det[clean_det_cnt].combine_desc_cd = 0
     ENDFOR
    ENDIF
    CALL echo(build("error_ind=",error_ind,"; z =",z,"; iCombine=",
      icombine))
    SET z = (icombine+ 1)
    SET failed = false
    GO TO begin_for
   ENDIF
  ENDIF
 ENDIF
#cmb_end_script
 IF (size(reply->error,5) > 0)
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
 ENDIF
END GO
