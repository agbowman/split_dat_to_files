CREATE PROGRAM bbt_chg_return_product:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 DECLARE available_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE quarantine_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE destroyed_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE disposed_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sub_product_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE disp_product_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE dest_product_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE next_code = f8 WITH protect, noconstant(0.0)
 DECLARE corr_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 SET chg_demogr_cd = 0.0
 SET emerg_dispense_cd = 0.0
 SET chg_state_cd = 0.0
 SET unlock_prod_cd = 0.0
 SET spec_test_cd = 0.0
 SET chg_pool_cd = 0.0
 SET chg_reconrbc_cd = 0.0
 SET chg_disp_prod_order_cd = 0.0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=14115
   AND c.active_ind=1
  DETAIL
   IF (c.cdf_meaning="DEMOG")
    chg_demogr_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="ERDIS")
    emerg_dispense_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="STATE")
    chg_state_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="UNLOCK")
    unlock_prod_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="SPECTEST")
    spec_test_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="POOL")
    chg_pool_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="RECONRBC")
    chg_reconrbc_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="DISPPRODORD")
    chg_disp_prod_order_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=1610
   AND c.active_ind=1
   AND ((c.cdf_meaning="12") OR (((c.cdf_meaning="2") OR (((c.cdf_meaning="14") OR (c.cdf_meaning="5"
  )) )) ))
  DETAIL
   IF (c.cdf_meaning="12")
    available_type_cd = c.code_value
   ELSEIF (c.cdf_meaning="2")
    quarantine_type_cd = c.code_value
   ELSEIF (c.cdf_meaning="14")
    destroyed_type_cd = c.code_value
   ELSEIF (c.cdf_meaning="5")
    disposed_type_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.*
  FROM product p
  WHERE (p.product_id=request->product_id)
   AND (p.updt_cnt=request->product_updt_cnt)
   AND p.active_ind=1
  WITH counter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "Lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product table Lock"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM product p
  SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.corrected_ind = 1,
   p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
   updt_task,
   p.updt_applctx = reqinfo->updt_applctx
  WHERE (p.product_id=request->product_id)
   AND (p.updt_cnt=request->product_updt_cnt)
   AND p.active_ind=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product Table Update"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.*
  FROM product_event p
  WHERE (p.product_id=request->product_id)
   AND (p.product_event_id=request->dispose_product_event_id)
   AND (p.updt_cnt=request->dispose_pe_updt_cnt)
   AND (p.active_ind=request->dispose_pe_active_ind)
  WITH counter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "Lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Disposition Product event"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM product_event p
  SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx
  WHERE (p.product_id=request->product_id)
   AND (p.product_event_id=request->dispose_product_event_id)
   AND (p.updt_cnt=request->dispose_pe_updt_cnt)
   AND (p.active_ind=request->dispose_pe_active_ind)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inactivate Disp Product Event"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.*
  FROM disposition d
  WHERE (d.product_id=request->product_id)
   AND (d.product_event_id=request->dispose_product_event_id)
   AND (d.updt_cnt=request->dispose_d_updt_cnt)
  WITH counter, forupdate(d)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "Lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "disposition"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Lock Disposition to Inactivate"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM disposition d
  SET d.active_ind = 0, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(sysdate),
   d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
   updt_applctx
  WHERE (d.product_id=request->product_id)
   AND (d.product_event_id=request->dispose_product_event_id)
   AND (d.updt_cnt=request->dispose_d_updt_cnt)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "disposition"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inactivate Disposition"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET new_pathnet_seq = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET corr_id = new_pathnet_seq
 INSERT  FROM corrected_product cp
  SET cp.correction_id = corr_id, cp.product_id = request->product_id, cp.correction_type_cd =
   IF ((request->correction_mode="DEMOG")) chg_demogr_cd
   ELSEIF ((request->correction_mode="ERDIS")) emerg_dispense_cd
   ELSEIF ((request->correction_mode="STATE")) chg_state_cd
   ELSE unlock_prod_cd
   ENDIF
   ,
   cp.correction_reason_cd = request->corr_reason_cd, cp.product_nbr = null, cp.product_sub_nbr =
   null,
   cp.alternate_nbr = null, cp.product_cd = 0, cp.product_class_cd = 0,
   cp.product_cat_cd = 0, cp.supplier_id = 0, cp.recv_dt_tm = null,
   cp.volume = null, cp.unit_meas_cd = 0, cp.expire_dt_tm = null,
   cp.abo_cd = 0, cp.rh_cd = 0, cp.segment_nbr = null,
   cp.orig_updt_cnt = request->disp_orig_updt_cnt, cp.orig_updt_dt_tm = cnvtdatetime(request->
    disp_orig_updt_dt_tm), cp.orig_updt_id = request->disp_orig_updt_id,
   cp.orig_updt_task = request->disp_orig_updt_task, cp.orig_updt_applctx = request->
   disp_orig_updt_applctx, cp.correction_note =
   IF ((request->corr_note="-1")) null
   ELSE request->corr_note
   ENDIF
   ,
   cp.unknown_patient_text = null, cp.event_dt_tm =
   IF ((request->disposed_event_dt_tm=- (1))) null
   ELSE cnvtdatetime(request->disposed_event_dt_tm)
   ENDIF
   , cp.reason_cd = 0,
   cp.autoclave_ind = null, cp.destruction_method_cd = 0, cp.destruction_org_id = 0,
   cp.manifest_nbr = null, cp.product_event_id = request->dispose_product_event_id, cp.updt_cnt = 0,
   cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->
   updt_task,
   cp.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "update1"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "corrected product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Disposition Corrected Product"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.*
  FROM product_event p
  WHERE (p.product_id=request->product_id)
   AND (p.product_event_id=request->destruction_product_event_id)
   AND (p.updt_cnt=request->destruction_pe_updt_cnt)
   AND (p.active_ind=request->destruction_pe_active_ind)
  WITH counter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "Lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Lock Dest Product Event"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM product_event p
  SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx
  WHERE (p.product_id=request->product_id)
   AND (p.product_event_id=request->destruction_product_event_id)
   AND (p.updt_cnt=request->destruction_pe_updt_cnt)
   AND (p.active_ind=request->destruction_pe_active_ind)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product event2"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inactivate Dest Product Event"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.*
  FROM destruction d
  WHERE (d.product_id=request->product_id)
   AND (d.product_event_id=request->destruction_product_event_id)
   AND (d.updt_cnt=request->destruction_d_updt_cnt)
  WITH counter, forupdate(d)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "destruction"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Lock Inactivate Destruction"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM destruction d
  SET d.active_ind = 0, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(sysdate),
   d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
   updt_applctx
  WHERE (d.product_id=request->product_id)
   AND (d.product_event_id=request->destruction_product_event_id)
   AND (d.updt_cnt=request->destruction_d_updt_cnt)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "destruction"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inactivate Destruction"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET new_pathnet_seq = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET corr_id = new_pathnet_seq
 INSERT  FROM corrected_product cp
  SET cp.correction_id = corr_id, cp.product_id = request->product_id, cp.correction_type_cd =
   IF ((request->correction_mode="DEMOG")) chg_demogr_cd
   ELSEIF ((request->correction_mode="ERDIS")) emerg_dispense_cd
   ELSEIF ((request->correction_mode="STATE")) chg_state_cd
   ELSE unlock_prod_cd
   ENDIF
   ,
   cp.correction_reason_cd = request->corr_reason_cd, cp.product_nbr = null, cp.product_sub_nbr =
   null,
   cp.alternate_nbr = null, cp.product_cd = 0, cp.product_class_cd = 0,
   cp.product_cat_cd = 0, cp.supplier_id = 0, cp.recv_dt_tm = null,
   cp.volume = null, cp.unit_meas_cd = 0, cp.expire_dt_tm = null,
   cp.abo_cd = 0, cp.rh_cd = 0, cp.segment_nbr = null,
   cp.orig_updt_cnt = request->dest_orig_updt_cnt, cp.orig_updt_dt_tm = cnvtdatetime(request->
    dest_orig_updt_dt_tm), cp.orig_updt_id = request->dest_orig_updt_id,
   cp.orig_updt_task = request->dest_orig_updt_task, cp.orig_updt_applctx = request->
   dest_orig_updt_applctx, cp.correction_note =
   IF ((request->corr_note="-1")) null
   ELSE request->corr_note
   ENDIF
   ,
   cp.unknown_patient_text = null, cp.event_dt_tm =
   IF ((request->destruction_event_dt_tm=- (1))) null
   ELSE cnvtdatetime(request->destruction_event_dt_tm)
   ENDIF
   , cp.reason_cd = 0,
   cp.autoclave_ind = null, cp.destruction_method_cd = 0, cp.destruction_org_id = 0,
   cp.manifest_nbr = null, cp.product_event_id = request->destruction_product_event_id, cp.updt_cnt
    = 0,
   cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->
   updt_task,
   cp.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "update2"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "corrected product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Destruction Corrected Product"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET sub_product_event_id = new_pathnet_seq
 IF ((request->avail_quar_ind="A"))
  IF ((request->orig_derivative_qty=0))
   INSERT  FROM product_event p
    SET p.product_event_id = sub_product_event_id, p.product_id = request->product_id, p.order_id = 0,
     p.bb_result_id = 0, p.event_type_cd = available_type_cd, p.event_dt_tm = cnvtdatetime(sysdate),
     p.event_prsnl_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(sysdate),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx,
     p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
     cnvtdatetime(sysdate),
     p.active_status_prsnl_id = reqinfo->updt_id, p.event_status_flag = 0, p.person_id = 0,
     p.encntr_id = 0, p.override_ind = 0, p.override_reason_cd = 0,
     p.related_product_event_id = 0, p.event_tz =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product event"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Available Product Event"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->avail_quar_ind="Q"))
  INSERT  FROM product_event p
   SET p.product_event_id = sub_product_event_id, p.product_id = request->product_id, p.order_id = 0,
    p.bb_result_id = 0, p.event_type_cd = quarantine_type_cd, p.event_dt_tm = cnvtdatetime(sysdate),
    p.event_prsnl_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(sysdate),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx,
    p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
    cnvtdatetime(sysdate),
    p.active_status_prsnl_id = reqinfo->updt_id, p.event_status_flag = 0, p.person_id = 0,
    p.encntr_id = 0, p.override_ind = 0, p.override_reason_cd = 0,
    p.related_product_event_id = 0, p.event_tz =
    IF (curutc=1) curtimezoneapp
    ELSE 0
    ENDIF
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Quarantine Product Event"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  INSERT  FROM quarantine q
   SET q.product_event_id = sub_product_event_id, q.product_id = request->product_id, q
    .quar_reason_cd = request->quar_reason_cd,
    q.updt_cnt = 0, q.updt_dt_tm = cnvtdatetime(sysdate), q.updt_id = reqinfo->updt_id,
    q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->updt_applctx, q.active_ind = 1,
    q.active_status_cd = reqdata->active_status_cd, q.active_status_dt_tm = cnvtdatetime(sysdate), q
    .active_status_prsnl_id = reqinfo->updt_id,
    q.orig_quar_qty = request->orig_quar_qty, q.cur_quar_qty = request->cur_quar_qty
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "quarantine"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "New Quarantine"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->avail_quar_ind="A"))
  IF ((request->derivative_ind=1))
   SELECT INTO "nl:"
    d.*
    FROM derivative d
    WHERE (d.product_id=request->product_id)
     AND (d.updt_cnt=request->derivative_updt_cnt)
    WITH counter, forupdate(d)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "derivative"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "derivative"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
   UPDATE  FROM derivative d
    SET d.cur_avail_qty = (d.cur_avail_qty+ request->derivative_qty), d.updt_cnt = (d.updt_cnt+ 1), d
     .updt_dt_tm = cnvtdatetime(sysdate),
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx
    WHERE (d.product_id=request->product_id)
     AND (d.updt_cnt=request->derivative_updt_cnt)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "derivative"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "derivative"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET disp_product_event_id = new_pathnet_seq
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET dest_product_event_id = new_pathnet_seq
 IF ((request->remaining_qty > 0))
  INSERT  FROM product_event p
   SET p.product_event_id = disp_product_event_id, p.product_id = request->product_id, p.order_id = 0,
    p.bb_result_id = 0, p.event_type_cd = disposed_type_cd, p.event_dt_tm = cnvtdatetime(request->
     disposed_event_dt_tm),
    p.event_prsnl_id = request->disposed_event_prsnl_id, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(
     sysdate),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx,
    p.active_ind = request->new_disp_active_ind, p.active_status_cd = reqdata->active_status_cd, p
    .active_status_dt_tm = cnvtdatetime(sysdate),
    p.active_status_prsnl_id = reqinfo->updt_id, p.event_status_flag = 0, p.person_id = 0,
    p.encntr_id = 0, p.override_ind = 0, p.override_reason_cd = 0,
    p.related_product_event_id = 0, p.event_tz =
    IF (curutc=1) curtimezoneapp
    ELSE 0
    ENDIF
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product Event Disposed Remaining"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  INSERT  FROM disposition d
   SET d.product_event_id = disp_product_event_id, d.product_id = request->product_id, d.reason_cd =
    request->disp_reason_cd,
    d.disposed_qty = request->remaining_qty, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(sysdate),
    d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
    updt_applctx,
    d.active_ind = 1, d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm =
    cnvtdatetime(sysdate),
    d.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "diposition"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Dispostion Remaining New"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  INSERT  FROM product_event p
   SET p.product_event_id = dest_product_event_id, p.product_id = request->product_id, p.order_id = 0,
    p.bb_result_id = 0, p.event_type_cd = destroyed_type_cd, p.event_dt_tm = cnvtdatetime(request->
     destruction_event_dt_tm),
    p.event_prsnl_id = request->destruction_event_prsnl_id, p.updt_cnt = 0, p.updt_dt_tm =
    cnvtdatetime(sysdate),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx,
    p.active_ind = request->new_dest_active_ind, p.active_status_cd = reqdata->active_status_cd, p
    .active_status_dt_tm = cnvtdatetime(sysdate),
    p.active_status_prsnl_id = reqinfo->updt_id, p.event_status_flag = request->
    new_dest_event_status_flag, p.person_id = 0,
    p.encntr_id = 0, p.override_ind = 0, p.override_reason_cd = 0,
    p.related_product_event_id = disp_product_event_id, p.event_tz =
    IF (curutc=1) curtimezoneapp
    ELSE 0
    ENDIF
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "product event"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product Event Remaining Destruction"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  INSERT  FROM destruction d
   SET d.product_event_id = dest_product_event_id, d.product_id = request->product_id, d.method_cd =
    request->dest_method_cd,
    d.box_nbr = request->box_nbr, d.manifest_nbr = request->manifest_nbr, d.destroyed_qty = request->
    remaining_qty,
    d.autoclave_ind = request->autoclave_ind, d.destruction_org_id = request->destruction_org_id, d
    .updt_cnt = 0,
    d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
    updt_task,
    d.updt_applctx = reqinfo->updt_applctx, d.active_ind = 1, d.active_status_cd = reqdata->
    active_status_cd,
    d.active_status_dt_tm = cnvtdatetime(sysdate), d.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "destruction"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Destruction Remaining"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "T"
 ENDIF
END GO
