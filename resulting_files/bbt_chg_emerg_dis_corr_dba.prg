CREATE PROGRAM bbt_chg_emerg_dis_corr:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE next_code = f8 WITH protect, noconstant(0.0)
 DECLARE corr_id = f8 WITH protect, noconstant(0.0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
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
  p.*
  FROM product p
  WHERE (p.product_id=request->product_id)
   AND (p.updt_cnt=request->product_updt_cnt)
   AND p.active_ind=1
  WITH counter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET count2 += 1
  SET reply->status_data.subeventstatus[count2].operationname = "Lock"
  SET reply->status_data.subeventstatus[count2].operationstatus = "F"
  SET reply->status_data.subeventstatus[count2].targetobjectname = "Product"
  SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->product_id)
  GO TO exit_script
 ELSE
  UPDATE  FROM product p
   SET p.locked_ind = 0, p.updt_cnt = (request->product_updt_cnt+ 1), p.corrected_ind = 1,
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
   SET count2 += 1
   SET reply->status_data.subeventstatus[count2].operationname = "update"
   SET reply->status_data.subeventstatus[count2].operationstatus = "F"
   SET reply->status_data.subeventstatus[count2].targetobjectname = "product"
   SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->product_id)
   GO TO exit_script
  ELSE
   SELECT INTO "nl:"
    d.*
    FROM patient_dispense d
    WHERE (d.product_id=request->product_id)
     AND (d.product_event_id=request->product_event_id)
     AND (d.updt_cnt=request->patient_updt_cnt)
     AND d.active_ind=1
    WITH counter, forupdate(d)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET reply->status_data.subeventstatus[count2].operationname = "Lock"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "Patient Dispense"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->product_id)
    GO TO exit_script
   ELSE
    UPDATE  FROM patient_dispense d
     SET d.person_id = request->person_id, d.updt_cnt = (request->patient_updt_cnt+ 1), d.updt_dt_tm
       = cnvtdatetime(sysdate),
      d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
      updt_applctx
     WHERE (d.product_id=request->product_id)
      AND (d.product_event_id=request->product_event_id)
      AND (d.updt_cnt=request->patient_updt_cnt)
      AND d.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET count2 += 1
     SET reply->status_data.subeventstatus[count2].operationname = "update"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "patient_dispense"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->product_id)
     GO TO exit_script
    ELSE
     SELECT INTO "nl:"
      p.*
      FROM product_event p
      WHERE (p.product_event_id=request->product_event_id)
       AND (p.updt_cnt=request->product_event_updt_cnt)
       AND p.active_ind=1
      WITH counter, forupdate(p)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET count2 += 1
      SET reply->status_data.subeventstatus[count2].operationname = "Lock"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "Product Event"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->product_id)
      GO TO exit_script
     ELSE
      UPDATE  FROM product_event p
       SET p.person_id = request->person_id, p.encntr_id = request->encntr_id, p.updt_cnt = (request
        ->product_event_updt_cnt+ 1),
        p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
        updt_task,
        p.updt_applctx = reqinfo->updt_applctx
       WHERE (p.product_event_id=request->product_event_id)
        AND (p.updt_cnt=request->product_event_updt_cnt)
        AND p.active_ind=1
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET failed = "T"
       SET count2 += 1
       SET reply->status_data.subeventstatus[count2].operationname = "update"
       SET reply->status_data.subeventstatus[count2].operationstatus = "F"
       SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
       SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->product_id)
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
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
    SET cp.correction_id = corr_id, cp.product_id = request->product_id, cp.product_event_id =
     request->product_event_id,
     cp.correction_type_cd =
     IF ((request->correction_mode="DEMOG")) chg_demogr_cd
     ELSEIF ((request->correction_mode="ERDIS")) emerg_dispense_cd
     ELSEIF ((request->correction_mode="STATE")) chg_state_cd
     ELSE unlock_prod_cd
     ENDIF
     , cp.correction_reason_cd = request->corr_reason_cd, cp.unknown_patient_text = request->
     unknown_patient_text,
     cp.product_nbr = null, cp.product_sub_nbr = null, cp.alternate_nbr = null,
     cp.product_cd = 0, cp.product_class_cd = 0, cp.product_cat_cd = 0,
     cp.supplier_id = 0, cp.recv_dt_tm = null, cp.volume = null,
     cp.unit_meas_cd = 0, cp.expire_dt_tm = null, cp.abo_cd = 0,
     cp.rh_cd = 0, cp.segment_nbr = null, cp.orig_updt_cnt = request->orig_updt_cnt,
     cp.orig_updt_dt_tm = cnvtdatetime(request->orig_updt_dt_tm), cp.orig_updt_id = request->
     orig_updt_id, cp.orig_updt_task = request->orig_updt_task,
     cp.orig_updt_applctx = request->orig_updt_applctx, cp.correction_note = request->corr_note, cp
     .event_dt_tm = null,
     cp.reason_cd = 0, cp.autoclave_ind = null, cp.destruction_method_cd = 0,
     cp.destruction_org_id = 0, cp.manifest_nbr = null, cp.updt_cnt = 0,
     cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->
     updt_task,
     cp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET reply->status_data.subeventstatus[count2].operationname = "intert"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "corrected product"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = build(request->product_id)
    GO TO exit_script
   ENDIF
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
