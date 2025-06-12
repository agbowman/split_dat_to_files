CREATE PROGRAM bbt_chg_disp_prod_order:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD disp_info(
   1 qual[*]
     2 corr_disp_prod_order_id = f8
     2 corr_disp_prov_id = f8
     2 orig_dispense_prov_id = f8
     2 orig_product_order_id = f8
     2 orig_updt_cnt = i4
     2 orig_updt_dt_tm = dq8
     2 orig_updt_id = f8
     2 orig_updt_task = i4
     2 orig_updt_applctx = f8
 )
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE prodcnt = i4 WITH protect, noconstant(0)
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
 SET prodcnt = size(request->qual,5)
 IF (prodcnt=0)
  SET failed = "T"
  SET count2 += 1
  SET reply->status_data.subeventstatus[count2].operationname = "No Product Info Provided"
  SET reply->status_data.subeventstatus[count2].operationstatus = "F"
  SET reply->status_data.subeventstatus[count2].targetobjectname = "Product"
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   p.*
   FROM product p,
    (dummyt d  WITH seq = value(prodcnt))
   PLAN (d)
    JOIN (p
    WHERE (p.product_id=request->qual[d.seq].product_id)
     AND (p.updt_cnt=request->qual[d.seq].product_updt_cnt)
     AND p.active_ind=1)
   WITH counter, forupdate(p)
  ;end select
  IF (curqual != prodcnt)
   SET failed = "T"
   SET count2 += 1
   SET reply->status_data.subeventstatus[count2].operationname = "Lock"
   SET reply->status_data.subeventstatus[count2].operationstatus = "F"
   SET reply->status_data.subeventstatus[count2].targetobjectname = "Product"
   GO TO exit_script
  ELSE
   UPDATE  FROM product p,
     (dummyt d  WITH seq = value(prodcnt))
    SET p.locked_ind = 0, p.updt_cnt = (request->qual[d.seq].product_updt_cnt+ 1), p.corrected_ind =
     1,
     p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
     updt_task,
     p.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (p
     WHERE (p.product_id=request->qual[d.seq].product_id)
      AND (p.updt_cnt=request->qual[d.seq].product_updt_cnt)
      AND p.active_ind=1)
    WITH counter
   ;end update
   IF (curqual != prodcnt)
    SET failed = "T"
    SET count2 += 1
    SET reply->status_data.subeventstatus[count2].operationname = "update"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "product"
    GO TO exit_script
   ELSE
    SELECT INTO "nl:"
     pe.*
     FROM product_event pe,
      (dummyt d  WITH seq = value(prodcnt))
     PLAN (d)
      JOIN (pe
      WHERE (pe.product_event_id=request->qual[d.seq].disp_event_id)
       AND (pe.updt_cnt=request->qual[d.seq].disp_pe_updt_cnt))
     WITH nocounter, forupdate(pe)
    ;end select
    IF (curqual != prodcnt)
     SET failed = "T"
     SET count2 += 1
     SET reply->status_data.subeventstatus[count2].operationname = "Lock"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
     GO TO exit_script
    ELSE
     SELECT INTO "nl:"
      pd.product_event_id
      FROM patient_dispense pd,
       (dummyt d  WITH seq = value(prodcnt))
      PLAN (d)
       JOIN (pd
       WHERE (pd.product_event_id=request->qual[d.seq].disp_event_id)
        AND (pd.updt_cnt=request->qual[d.seq].disp_updt_cnt))
      WITH nocounter, forupdate(pd)
     ;end select
     IF (curqual != prodcnt)
      SET failed = "T"
      SET count2 += 1
      SET reply->status_data.subeventstatus[count2].operationname = "Lock"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "patient_dispense"
      GO TO exit_script
     ELSE
      SELECT INTO "nl:"
       pe.*
       FROM product_event pe,
        patient_dispense pd,
        orders o,
        (dummyt d  WITH seq = value(prodcnt)),
        (dummyt do  WITH seq = value(1))
       PLAN (d)
        JOIN (pe
        WHERE (pe.product_event_id=request->qual[d.seq].disp_event_id))
        JOIN (pd
        WHERE pd.product_event_id=pe.product_event_id)
        JOIN (do)
        JOIN (o
        WHERE (request->qual[d.seq].disp_prod_order_id > 0)
         AND (o.order_id=request->qual[d.seq].disp_prod_order_id))
       HEAD REPORT
        stat = alterlist(disp_info->qual,prodcnt)
       DETAIL
        disp_info->qual[d.seq].corr_disp_prod_order_id = request->qual[d.seq].disp_prod_order_id,
        disp_info->qual[d.seq].corr_disp_prov_id = o.last_update_provider_id, disp_info->qual[d.seq].
        orig_dispense_prov_id = pd.dispense_prov_id,
        disp_info->qual[d.seq].orig_product_order_id = pe.order_id, disp_info->qual[d.seq].
        orig_updt_cnt = pe.updt_cnt, disp_info->qual[d.seq].orig_updt_dt_tm = pe.updt_dt_tm,
        disp_info->qual[d.seq].orig_updt_id = pe.updt_id, disp_info->qual[d.seq].orig_updt_task = pe
        .updt_task, disp_info->qual[d.seq].orig_updt_applctx = pe.updt_applctx
       WITH nocounter
      ;end select
      UPDATE  FROM product_event pe,
        (dummyt d  WITH seq = value(prodcnt))
       SET pe.order_id = request->qual[d.seq].disp_prod_order_id, pe.updt_cnt = (request->qual[d.seq]
        .disp_pe_updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate),
        pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
        updt_applctx
       PLAN (d)
        JOIN (pe
        WHERE (pe.product_event_id=request->qual[d.seq].disp_event_id)
         AND (pe.updt_cnt=request->qual[d.seq].disp_pe_updt_cnt))
       WITH nocounter
      ;end update
      IF (curqual != prodcnt)
       SET failed = "T"
       SET count2 += 1
       SET reply->status_data.subeventstatus[count2].operationname = "update"
       SET reply->status_data.subeventstatus[count2].operationstatus = "F"
       SET reply->status_data.subeventstatus[count2].targetobjectname = "product_event"
       GO TO exit_script
      ELSE
       UPDATE  FROM patient_dispense pd,
         (dummyt d  WITH seq = value(prodcnt))
        SET pd.dispense_prov_id = disp_info->qual[d.seq].corr_disp_prov_id, pd.updt_cnt = (request->
         qual[d.seq].disp_updt_cnt+ 1), pd.updt_dt_tm = cnvtdatetime(sysdate),
         pd.updt_id = reqinfo->updt_id, pd.updt_task = reqinfo->updt_task, pd.updt_applctx = reqinfo
         ->updt_applctx
        PLAN (d)
         JOIN (pd
         WHERE (pd.product_event_id=request->qual[d.seq].disp_event_id)
          AND (pd.updt_cnt=request->qual[d.seq].disp_updt_cnt))
        WITH nocounter
       ;end update
       IF (curqual != prodcnt)
        SET failed = "T"
        SET count2 += 1
        SET reply->status_data.subeventstatus[count2].operationname = "update"
        SET reply->status_data.subeventstatus[count2].operationstatus = "F"
        SET reply->status_data.subeventstatus[count2].targetobjectname = "patient_dispense"
        GO TO exit_script
       ELSE
        INSERT  FROM corrected_product cp,
          (dummyt d  WITH seq = value(prodcnt))
         SET cp.correction_id = seq(pathnet_seq,nextval), cp.product_id = request->qual[d.seq].
          product_id, cp.product_event_id = request->qual[d.seq].disp_event_id,
          cp.correction_type_cd = chg_disp_prod_order_cd, cp.correction_reason_cd = request->
          corr_reason_cd, cp.correction_note = request->corr_note,
          cp.orig_disp_prov_id = disp_info->qual[d.seq].orig_dispense_prov_id, cp
          .orig_disp_prod_order_id = disp_info->qual[d.seq].orig_product_order_id, cp
          .corr_disp_prod_order_id = disp_info->qual[d.seq].corr_disp_prod_order_id,
          cp.orig_updt_cnt = disp_info->qual[d.seq].orig_updt_cnt, cp.orig_updt_dt_tm = cnvtdatetime(
           disp_info->qual[d.seq].orig_updt_dt_tm), cp.orig_updt_id = disp_info->qual[d.seq].
          orig_updt_id,
          cp.orig_updt_task = disp_info->qual[d.seq].orig_updt_task, cp.orig_updt_applctx = disp_info
          ->qual[d.seq].orig_updt_applctx, cp.updt_cnt = 0,
          cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id, cp.updt_task =
          reqinfo->updt_task,
          cp.updt_applctx = reqinfo->updt_applctx, cp.unknown_patient_text = null, cp.product_nbr =
          null,
          cp.product_sub_nbr = null, cp.alternate_nbr = null, cp.product_cd = 0,
          cp.product_class_cd = 0, cp.product_cat_cd = 0, cp.supplier_id = 0,
          cp.recv_dt_tm = null, cp.volume = null, cp.unit_meas_cd = 0,
          cp.expire_dt_tm = null, cp.abo_cd = 0, cp.rh_cd = 0,
          cp.segment_nbr = null, cp.event_dt_tm = null, cp.reason_cd = 0,
          cp.autoclave_ind = null, cp.destruction_method_cd = 0, cp.destruction_org_id = 0,
          cp.manifest_nbr = null
         PLAN (d)
          JOIN (cp)
         WITH nocounter
        ;end insert
        IF (curqual != prodcnt)
         SET failed = "T"
         SET count2 += 1
         SET reply->status_data.subeventstatus[count2].operationname = "insert"
         SET reply->status_data.subeventstatus[count2].operationstatus = "F"
         SET reply->status_data.subeventstatus[count2].targetobjectname = "corrected_product"
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "T"
 ENDIF
END GO
