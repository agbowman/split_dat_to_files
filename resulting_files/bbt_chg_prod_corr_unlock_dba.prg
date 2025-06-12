CREATE PROGRAM bbt_chg_prod_corr_unlock:dba
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 product_nbr = c20
     2 product_sub_nbr = c5
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE next_code = f8 WITH protect, noconstant(0.0)
 DECLARE corr_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
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
 FOR (count1 = 1 TO request->product_count)
  SELECT INTO "nl:"
   p.*
   FROM product p
   WHERE (p.product_id=request->qual[count1].product_id)
    AND (p.updt_cnt=request->qual[count1].updt_cnt)
    AND p.active_ind=1
   WITH counter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET count2 += 1
   SET stat = alterlist(reply->qual,count2)
   SET reply->status_data.status = "U"
   SET reply->qual[count2].product_id = request->qual[count1].product_id
   SET reply->qual[count2].product_nbr = request->qual[count1].product_nbr
  ELSE
   UPDATE  FROM product p
    SET p.locked_ind = 0, p.updt_cnt = (request->qual[count1].updt_cnt+ 1), p.corrected_ind = 1,
     p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
     updt_task,
     p.updt_applctx = reqinfo->updt_applctx
    WHERE (p.product_id=request->qual[count1].product_id)
     AND (p.updt_cnt=request->qual[count1].updt_cnt)
     AND p.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET count2 += 1
    SET stat = alterlist(reply->qual,count2)
    SET reply->qual[count2].product_id = request->qual[count1].product_id
    SET reply->status_data.status = "P"
    SET reply->qual[count2].product_nbr = request->qual[count1].product_nbr
   ELSE
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
     SET cp.correction_id = corr_id, cp.product_id = request->qual[count1].product_id, cp
      .correction_type_cd =
      IF ((request->qual[count1].correction_mode="DEMOG")) chg_demogr_cd
      ELSEIF ((request->qual[count1].correction_mode="ERDIS")) emerg_dispense_cd
      ELSEIF ((request->qual[count1].correction_mode="STATE")) chg_state_cd
      ELSE unlock_prod_cd
      ENDIF
      ,
      cp.correction_reason_cd = request->qual[count1].corr_reason_cd, cp.product_event_id = 0, cp
      .product_nbr = "",
      cp.product_sub_nbr = "", cp.alternate_nbr = "", cp.product_cd = 0,
      cp.product_class_cd = 0, cp.product_cat_cd = 0, cp.supplier_id = 0,
      cp.recv_dt_tm = null, cp.volume = null, cp.unit_meas_cd = 0,
      cp.expire_dt_tm = null, cp.abo_cd = 0, cp.rh_cd = 0,
      cp.segment_nbr = "", cp.orig_updt_cnt = request->qual[count1].orig_updt_cnt, cp.orig_updt_dt_tm
       = cnvtdatetime(request->qual[count1].orig_updt_dt_tm),
      cp.orig_updt_id = request->qual[count1].orig_updt_id, cp.orig_updt_task = request->qual[count1]
      .orig_updt_task, cp.orig_updt_applctx = request->qual[count1].orig_updt_applctx,
      cp.correction_note =
      IF ((request->qual[count1].corr_note="-1")) ""
      ELSE request->qual[count1].corr_note
      ENDIF
      , cp.event_dt_tm = null, cp.reason_cd = 0,
      cp.autoclave_ind = null, cp.destruction_method_cd = 0, cp.destruction_org_id = 0,
      cp.manifest_nbr = null, cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate),
      cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual != 0)
     COMMIT
    ELSE
     SET count2 += 1
     SET stat = alterlist(reply->qual,count2)
     SET reply->status_data.status = "C"
     SET reply->qual[count2].product_id = request->qual[count1].product_id
     SET reply->qual[count2].product_nbr = request->qual[count1].product_nbr
     ROLLBACK
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
END GO
