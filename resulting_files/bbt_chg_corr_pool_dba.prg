CREATE PROGRAM bbt_chg_corr_pool:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 dup_product_cnt = i4
 )
 RECORD quar_eventlist(
   1 qual[*]
     2 product_event_id = f8
     2 quar_reason_cd = f8
 )
 SET product_cnt = 0
 SET failed = "F"
 SET product_cnt = size(request->productlist,5)
 SET idx = 0
 SET correction_id = 0.0
 SET pool_prod_correction_id = 0.0
 SET count = 0
 SET count1 = 0
 SET gsub_code_value = 0.0
 SET gsub_status = " "
 SET gsub_process = fillstring(200," ")
 SET gsub_message = fillstring(200," ")
 SET gsub_product_event_status = "  "
 DECLARE correct_type_reconrbc_mean = c12 WITH constant("RECONRBC")
 DECLARE recon_rbc_ind = i2 WITH noconstant(0)
 DECLARE dproductcatagory = f8 WITH noconstant(0.0)
 DECLARE dproductclass = f8 WITH noconstant(0.0)
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
 IF ((request->correction_type_cd > 0)
  AND (request->correction_type_cd=chg_reconrbc_cd))
  SET recon_rbc_ind = 1
  IF ((request->new_product_nbr=request->old_product_nbr)
   AND (request->new_product_sub_nbr=request->old_product_sub_nbr)
   AND (request->new_product_cd=request->old_product_cd)
   AND (request->new_supplier_id=request->old_supplier_id))
   SET reply->dup_product_cnt = 0
  ELSE
   CALL determine_duplicate_blood_product(null)
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  p.*
  FROM product p
  WHERE (p.product_id=request->pooled_product_id)
   AND (p.updt_cnt=request->pooled_product_updt_cnt)
  WITH nocounter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Lock pooled product row"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
   product_id)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (((recon_rbc_ind > 0) OR ((request->new_product_cd != - (1)))) )
  SET dproductcatagory = getproductcatagory(request->new_product_cd)
 ENDIF
 IF (((recon_rbc_ind > 0) OR ((request->new_product_cd != - (1)))) )
  SET dproductclass = getproductclass(request->new_product_cd)
 ENDIF
 UPDATE  FROM product p
  SET p.locked_ind = 0, p.cur_unit_meas_cd =
   IF ((request->new_meas_cd=- (1))) p.cur_unit_meas_cd
   ELSE request->new_meas_cd
   ENDIF
   , p.cur_expire_dt_tm =
   IF ((request->new_expire_dt_tm=- (1))) p.cur_expire_dt_tm
   ELSE cnvtdatetime(request->new_expire_dt_tm)
   ENDIF
   ,
   p.electronic_entry_flag =
   IF ((request->new_electronic_entry_flag=- (1))) p.electronic_entry_flag
   ELSE request->new_electronic_entry_flag
   ENDIF
   , p.donation_type_cd =
   IF ((request->new_donation_type_cd=- (1))) p.donation_type_cd
   ELSE request->new_donation_type_cd
   ENDIF
   , p.disease_cd =
   IF ((request->new_disease_cd=- (1))) p.disease_cd
   ELSE request->new_disease_cd
   ENDIF
   ,
   p.intended_use_print_parm_txt =
   IF (((recon_rbc_ind=0) OR ((request->old_intended_use="-"))) ) p.intended_use_print_parm_txt
   ELSE request->new_intended_use
   ENDIF
   , p.product_cd =
   IF (((recon_rbc_ind=0) OR ((request->new_product_cd=- (1)))) ) p.product_cd
   ELSE request->new_product_cd
   ENDIF
   , p.product_cat_cd =
   IF (((recon_rbc_ind=0) OR ((request->new_product_cd=- (1)))) ) p.product_cat_cd
   ELSE dproductcatagory
   ENDIF
   ,
   p.product_class_cd =
   IF (((recon_rbc_ind=0) OR ((request->new_product_cd=- (1)))) ) p.product_class_cd
   ELSE dproductclass
   ENDIF
   , p.cur_supplier_id =
   IF (((recon_rbc_ind=0) OR ((request->new_supplier_id=- (1)))) ) p.cur_supplier_id
   ELSE request->new_supplier_id
   ENDIF
   , p.product_nbr =
   IF (((recon_rbc_ind=0) OR ((request->new_product_nbr="-1"))) ) p.product_nbr
   ELSE request->new_product_nbr
   ENDIF
   ,
   p.alternate_nbr =
   IF (((recon_rbc_ind=0) OR ((request->new_alternate_nbr="-1"))) ) p.alternate_nbr
   ELSE request->new_alternate_nbr
   ENDIF
   , p.barcode_nbr =
   IF (((recon_rbc_ind=0) OR ((request->new_barcode_nbr="-1"))) ) p.barcode_nbr
   ELSE request->new_barcode_nbr
   ENDIF
   , p.product_sub_nbr =
   IF (((recon_rbc_ind=0) OR ((request->new_product_sub_nbr="-1"))) ) p.product_sub_nbr
   ELSE request->new_product_sub_nbr
   ENDIF
   ,
   p.flag_chars =
   IF (((recon_rbc_ind=0) OR ((request->new_flag_chars="-1"))) ) p.flag_chars
   ELSE request->new_flag_chars
   ENDIF
   , p.product_type_barcode =
   IF (((recon_rbc_ind=0) OR ((request->new_product_type_barcode="-1"))) ) p.product_type_barcode
   ELSE request->new_product_type_barcode
   ENDIF
   , p.corrected_ind =
   IF (recon_rbc_ind > 0) 1
   ELSE p.corrected_ind
   ENDIF
   ,
   p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
   p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_applctx = reqinfo->updt_applctx
  WHERE (p.product_id=request->pooled_product_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "update pooled product row"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
   product_id)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  bp.*
  FROM blood_product bp
  WHERE (bp.product_id=request->pooled_product_id)
   AND (bp.updt_cnt=request->bp_updt_cnt)
  WITH nocounter, forupdate(bp)
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Lock pooled blood product row"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Blood Product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
   product_id)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM blood_product bp
  SET bp.cur_abo_cd =
   IF ((request->new_abo_cd=- (1))) bp.cur_abo_cd
   ELSE request->new_abo_cd
   ENDIF
   , bp.cur_rh_cd =
   IF ((request->new_rh_cd=- (1))) bp.cur_rh_cd
   ELSE request->new_rh_cd
   ENDIF
   , bp.cur_volume =
   IF ((request->new_volume=- (1))) bp.cur_volume
   ELSE request->new_volume
   ENDIF
   ,
   bp.supplier_prefix =
   IF (((recon_rbc_ind=0) OR ((request->new_supplier_prefix="-1"))) ) bp.supplier_prefix
   ELSE request->new_supplier_prefix
   ENDIF
   , bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_dt_tm = cnvtdatetime(sysdate),
   bp.updt_id = reqinfo->updt_id, bp.updt_task = reqinfo->updt_task, bp.updt_applctx = reqinfo->
   updt_applctx
  WHERE (bp.product_id=request->pooled_product_id)
  WITH nocounter
 ;end update
 SELECT INTO "nl:"
  t.*
  FROM transfusion t
  WHERE (t.product_id=request->pooled_product_id)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SELECT INTO "nl:"
   t.*
   FROM transfusion t
   WHERE (t.product_id=request->pooled_product_id)
   WITH nocounter, forupdate(bp)
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "Lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Transfusion"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->pooled_product_id)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM transfusion t
   SET t.transfused_vol =
    IF ((request->new_volume=- (1))) t.transfused_vol
    ELSE request->new_volume
    ENDIF
    , t.updt_cnt = (t.updt_cnt+ 1), t.updt_dt_tm = cnvtdatetime(sysdate),
    t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
    updt_applctx
   WHERE (t.product_id=request->pooled_product_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Transfusion"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->pooled_product_id)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SET pool_prod_correction_id = next_pathnet_seq(0)
 INSERT  FROM corrected_product cp
  SET cp.correction_id = pool_prod_correction_id, cp.product_id =
   IF ((request->pooled_product_id > - (1))) request->pooled_product_id
   ELSE 0
   ENDIF
   , cp.correction_flag = 1,
   cp.related_correction_id = 0, cp.correction_type_cd =
   IF ((request->correction_type_cd > 0)) request->correction_type_cd
   ELSE chg_pool_cd
   ENDIF
   , cp.correction_reason_cd = request->corr_reason_cd,
   cp.orig_updt_cnt = request->pooled_product_updt_cnt, cp.orig_updt_dt_tm = cnvtdatetime(request->
    pool_prod_orig_updt_dt_tm), cp.orig_updt_id =
   IF ((request->pool_prod_orig_updt_id > - (1))) request->pool_prod_orig_updt_id
   ELSE 0
   ENDIF
   ,
   cp.orig_updt_task = request->pool_prod_orig_updt_task, cp.orig_updt_applctx = request->
   pool_prod_orig_updt_applctx, cp.correction_note = request->corr_note,
   cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id,
   cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->updt_applctx, cp.product_event_id =
   0,
   cp.event_dt_tm = null, cp.reason_cd = 0, cp.autoclave_ind = null,
   cp.destruction_method_cd = 0, cp.destruction_org_id = 0, cp.manifest_nbr = null,
   cp.encntr_id = 0, cp.person_id = 0, cp.expected_usage_dt_tm = null,
   cp.product_nbr =
   IF (((recon_rbc_ind=0) OR ((request->old_product_nbr="-1"))) ) null
   ELSE request->old_product_nbr
   ENDIF
   , cp.product_sub_nbr =
   IF (((recon_rbc_ind=0) OR ((request->old_product_sub_nbr="-1"))) ) null
   ELSE request->old_product_sub_nbr
   ENDIF
   , cp.alternate_nbr =
   IF (((recon_rbc_ind=0) OR ((request->old_alternate_nbr="-1"))) ) null
   ELSE request->old_alternate_nbr
   ENDIF
   ,
   cp.product_cd =
   IF (((recon_rbc_ind=0) OR ((request->old_product_cd=- (1)))) ) 0
   ELSE request->old_product_cd
   ENDIF
   , cp.product_class_cd =
   IF (((recon_rbc_ind=0) OR ((request->old_product_cd=- (1)))) ) 0
   ELSE dproductclass
   ENDIF
   , cp.product_cat_cd =
   IF (((recon_rbc_ind=0) OR ((request->old_product_cd=- (1)))) ) 0
   ELSE dproductcatagory
   ENDIF
   ,
   cp.supplier_id =
   IF (((recon_rbc_ind=0) OR ((request->old_supplier_id=- (1)))) ) 0
   ELSE request->old_supplier_id
   ENDIF
   , cp.supplier_prefix =
   IF (((recon_rbc_ind=0) OR ((request->old_supplier_prefix="-1"))) ) null
   ELSE request->old_supplier_prefix
   ENDIF
   , cp.recv_dt_tm = null,
   cp.segment_nbr = " ", cp.unit_meas_cd =
   IF ((request->old_meas_cd=- (1))) 0
   ELSE request->old_meas_cd
   ENDIF
   , cp.expire_dt_tm =
   IF ((request->old_expire_dt_tm=- (1))) cnvtdatetime("")
   ELSE cnvtdatetime(request->old_expire_dt_tm)
   ENDIF
   ,
   cp.abo_cd =
   IF ((request->old_abo_cd=- (1))) 0
   ELSE request->old_abo_cd
   ENDIF
   , cp.rh_cd =
   IF ((request->old_rh_cd=- (1))) 0
   ELSE request->old_rh_cd
   ENDIF
   , cp.volume =
   IF ((request->old_volume=- (1))) null
   ELSE request->old_volume
   ENDIF
   ,
   cp.donation_type_cd =
   IF ((request->old_donation_type_cd=- (1))) 0.0
   ELSE request->old_donation_type_cd
   ENDIF
   , cp.disease_cd =
   IF ((request->old_disease_cd=- (1))) 0.0
   ELSE request->old_disease_cd
   ENDIF
   , cp.barcode_nbr =
   IF (((recon_rbc_ind=0) OR ((request->old_barcode_nbr="-1"))) ) null
   ELSE request->old_barcode_nbr
   ENDIF
   ,
   cp.flag_chars =
   IF (((recon_rbc_ind=0) OR ((request->old_flag_chars="-1"))) ) null
   ELSE request->old_flag_chars
   ENDIF
   , cp.product_type_barcode =
   IF (((recon_rbc_ind=0) OR ((request->old_product_type_barcode="-1"))) ) null
   ELSE request->old_product_type_barcode
   ENDIF
   , cp.intended_use_print_parm_txt =
   IF (((recon_rbc_ind=0) OR ((request->old_intended_use="-"))) ) null
   ELSE request->old_intended_use
   ENDIF
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Update pooled blood_product row"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
   product_id)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (recon_rbc_ind > 0)
  CALL update_special_testing(null)
 ENDIF
 CALL get_code_value(1610,"12")
 IF (curqual=0)
  SET gsub_status = "F"
  SET gsub_process = "get available event_type_cd"
  SET gsub_message = "could not retrieve available event_type_cd--code_set = 1610, cdf_meaning = 12"
  CALL load_process_status(gsub_status,gsub_process,gsub_message)
  GO TO exit_script
 ELSE
  SET available_event_type_cd = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"2")
 IF (curqual=0)
  SET gsub_status = "F"
  SET gsub_process = "get quarantine event_type_cd"
  SET gsub_message = "could not retrieve quarantined event_type_cd--code_set = 1610, cdf_meaning = 2"
  CALL load_process_status(gsub_status,gsub_process,gsub_message)
  GO TO exit_script
 ELSE
  SET quarantined_event_type_cd = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"14")
 IF (curqual=0)
  SET gsub_status = "F"
  SET gsub_process = "get destroyed event_type_cd"
  SET gsub_message = "could not retrieve destroyed event_type_cd--code_set = 1610, cdf_meaning = 14"
  CALL load_process_status(gsub_status,gsub_process,gsub_message)
  GO TO exit_script
 ELSE
  SET destroyed_event_type_cd = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"10")
 IF (curqual=0)
  SET gsub_status = "F"
  SET gsub_process = "get autologous event_type_cd"
  SET gsub_message = "could not retrieve autologous event_type_cd--code_set = 1610, cdf_meaning = 10"
  CALL load_process_status(gsub_status,gsub_process,gsub_message)
  GO TO exit_script
 ELSE
  SET autologous_event_type_cd = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"11")
 IF (curqual=0)
  SET gsub_status = "F"
  SET gsub_process = "get directed event_type_cd"
  SET gsub_message = "could not retrieve directed event_type_cd--code_set = 1610, cdf_meaning = 11"
  CALL load_process_status(gsub_status,gsub_process,gsub_message)
  GO TO exit_script
 ELSE
  SET directed_event_type_cd = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"9")
 IF (curqual=0)
  SET gsub_status = "F"
  SET gsub_process = "get unconfirmed event_type_cd"
  SET gsub_message = "could not retrieve unconfirmed event_type_cd--code_set = 1610, cdf_meaning = 9"
  CALL load_process_status(gsub_status,gsub_process,gsub_message)
  GO TO exit_script
 ELSE
  SET unconfirmed_event_type_cd = gsub_code_value
 ENDIF
 FOR (idx = 1 TO product_cnt)
   SELECT INTO "nl:"
    bp.*
    FROM blood_product bp
    WHERE (bp.product_id=request->productlist[idx].product_id)
    WITH nocounter, forupdate(bp)
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Blood Product"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
     product_id)
    SET failed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM blood_product bp
    SET bp.cur_volume = bp.orig_volume, bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_dt_tm = cnvtdatetime(
      sysdate),
     bp.updt_id = reqinfo->updt_id, bp.updt_task = reqinfo->updt_task, bp.updt_applctx = reqinfo->
     updt_applctx
    WHERE (bp.product_id=request->productlist[idx].product_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "Update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Blood Product"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
     product_id)
    SET failed = "T"
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    p.*
    FROM product p
    WHERE (p.product_id=request->productlist[idx].product_id)
     AND (p.updt_cnt=request->productlist[idx].orig_updt_cnt)
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Product"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
     product_id)
    SET failed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM product p
    SET p.pooled_product_id = 0.0, p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(
      sysdate),
     p.updt_applctx = reqinfo->updt_applctx
    WHERE (p.product_id=request->productlist[idx].product_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "Update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Product"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
     product_id)
    SET failed = "T"
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    pe.*
    FROM product_event pe
    WHERE (pe.product_id=request->productlist[idx].product_id)
     AND pe.event_type_cd=destroyed_event_type_cd
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "Lock pooled product row"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Product"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->productlist[idx].
     product_id)
    SET failed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM product_event pe
    SET pe.active_ind = 0, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(sysdate),
     pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
     updt_applctx
    WHERE (pe.product_id=request->productlist[idx].product_id)
     AND pe.event_type_cd=destroyed_event_type_cd
     AND pe.active_ind=1
    WITH nocounter
   ;end update
   SELECT INTO "nl:"
    pe.product_event_id, qu.product_event_id, qr.product_event_id,
    qr_ind = decode(qr.seq,"QR","XX")
    FROM product_event pe,
     quarantine qu,
     (dummyt d_qr  WITH seq = 1),
     quarantine_release qr
    PLAN (pe
     WHERE (pe.product_id=request->productlist[idx].product_id)
      AND pe.event_type_cd=quarantined_event_type_cd)
     JOIN (qu
     WHERE qu.product_event_id=pe.product_event_id)
     JOIN (d_qr
     WHERE d_qr.seq=1)
     JOIN (qr
     WHERE qr.product_event_id=qu.product_event_id)
    HEAD REPORT
     count = 0, stat = alterlist(quar_eventlist->qual,5)
    DETAIL
     IF (qr_ind != "QR")
      count += 1
      IF (mod(count,5)=0)
       stat = alterlist(quar_eventlist->qual,(count+ 5))
      ENDIF
      quar_eventlist->qual[count].product_event_id = pe.product_event_id, quar_eventlist->qual[count]
      .quar_reason_cd = qu.quar_reason_cd
     ENDIF
    FOOT REPORT
     stat = alterlist(quar_eventlist->qual,count)
    WITH nocounter, outerjoin(d_qr)
   ;end select
   IF (curqual=0)
    IF (determine_available_state_req(null) > 0)
     CALL add_product_event(request->productlist[idx].product_id,0,0,0,0,
      available_event_type_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
      0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
      reqinfo->updt_id)
     CALL process_product_event_status("add",gsub_product_event_status,"available")
    ENDIF
   ELSE
    FOR (x = 1 TO count)
      CALL add_product_event(request->productlist[idx].product_id,0,0,0,0,
       quarantined_event_type_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
       0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
       reqinfo->updt_id)
      CALL process_product_event_status("add",gsub_product_event_status,"quarantined")
      IF ((reply->status_data.status="F"))
       GO TO exit_script
      ENDIF
      SET new_quarantine_product_event_id = new_product_event_id
      CALL add_quarantine(new_quarantine_product_event_id,request->productlist[idx].product_id,
       quar_event->qual[x].quar_reason_cd,1,reqdata->active_status_cd,
       cnvtdatetime(sysdate),reqinfo->updt_id)
      IF (curqual=0)
       CALL load_process_status("F","add quarantine row",
        "could not add quarantine row for pooled product")
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   SET correction_id = next_pathnet_seq(0)
   INSERT  FROM corrected_product cp
    SET cp.correction_id = correction_id, cp.product_id =
     IF ((request->productlist[idx].product_id > - (1))) request->productlist[idx].product_id
     ELSE 0
     ENDIF
     , cp.correction_flag = 2,
     cp.related_correction_id =
     IF ((pool_prod_correction_id > - (1))) pool_prod_correction_id
     ELSE 0
     ENDIF
     , cp.correction_type_cd =
     IF ((request->correction_type_cd > 0)) request->correction_type_cd
     ELSE chg_pool_cd
     ENDIF
     , cp.correction_reason_cd = request->corr_reason_cd,
     cp.orig_updt_cnt = request->productlist[idx].orig_updt_cnt, cp.orig_updt_dt_tm = cnvtdatetime(
      request->productlist[idx].orig_updt_dt_tm), cp.orig_updt_id =
     IF ((request->productlist[idx].orig_updt_id > - (1))) request->productlist[idx].orig_updt_id
     ELSE 0
     ENDIF
     ,
     cp.orig_updt_task = request->productlist[idx].orig_updt_task, cp.orig_updt_applctx = request->
     productlist[idx].orig_updt_applctx, cp.correction_note = request->corr_note,
     cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id,
     cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->updt_applctx, cp.product_event_id
      = 0,
     cp.event_dt_tm = null, cp.reason_cd = 0, cp.autoclave_ind = null,
     cp.destruction_method_cd = 0, cp.destruction_org_id = 0, cp.manifest_nbr = null,
     cp.encntr_id = 0, cp.person_id = 0, cp.expected_usage_dt_tm = null,
     cp.product_nbr = " ", cp.product_sub_nbr = " ", cp.alternate_nbr = " ",
     cp.product_cd = 0, cp.product_class_cd = 0, cp.product_cat_cd = 0,
     cp.supplier_id = 0, cp.recv_dt_tm = null, cp.volume = 0,
     cp.unit_meas_cd = 0, cp.expire_dt_tm = null, cp.abo_cd = 0,
     cp.rh_cd = 0, cp.segment_nbr = " "
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "Insert"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Corrected_Product"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
     "For removed component.  Product_Id =",request->productlist[idx].product_id)
    SET failed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
 SET cmpnt_cnt = size(request->cmpntlist,5)
 IF (cmpnt_cnt > 0)
  EXECUTE bbt_add_pooled_product
  IF (recon_rbc_ind > 0)
   SET eventlistcnt = size(request->pool_eventlist,5)
   FOR (eventidx = 1 TO eventlistcnt)
     IF ((request->pool_eventlist[eventidx].product_event_id > 0)
      AND (request->pool_eventlist[eventidx].inactivate_ind > 0)
      AND (((request->pool_eventlist[eventidx].event_type_cd=directed_event_type_cd)) OR ((request->
     pool_eventlist[eventidx].event_type_cd=autologous_event_type_cd))) )
      CALL inserteventcorrectedproductrow(1,request->pool_eventlist[eventidx].product_event_id,
       request->pool_eventlist[eventidx].person_id,- (1),request->pool_eventlist[eventidx].
       expected_usage_dt_tm,
       request->pool_eventlist[eventidx].donated_by_relative_ind)
     ENDIF
   ENDFOR
  ENDIF
  IF ((reply->status_data.status="S"))
   FOR (idx = 1 TO cmpnt_cnt)
     SELECT INTO "nl:"
      bp.*
      FROM blood_product bp
      WHERE (bp.product_id=request->cmpntlist[idx].product_id)
      WITH nocounter, forupdate(bp)
     ;end select
     IF (curqual=0)
      SET reply->status_data.subeventstatus[1].operationname = "Lock"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "Blood Product"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->cmpntlist[idx].
       product_id)
      SET failed = "T"
      GO TO exit_script
     ENDIF
     UPDATE  FROM blood_product bp
      SET bp.cur_volume = 0, bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_dt_tm = cnvtdatetime(sysdate),
       bp.updt_id = reqinfo->updt_id, bp.updt_task = reqinfo->updt_task, bp.updt_applctx = reqinfo->
       updt_applctx
      WHERE (bp.product_id=request->cmpntlist[idx].product_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "Blood Product"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build(request->cmpntlist[idx].
       product_id)
      SET failed = "T"
      GO TO exit_script
     ENDIF
     SET correction_id = next_pathnet_seq(0)
     INSERT  FROM corrected_product cp
      SET cp.correction_id = correction_id, cp.product_id =
       IF ((request->cmpntlist[idx].product_id > - (1))) request->cmpntlist[idx].product_id
       ELSE 0
       ENDIF
       , cp.correction_flag = 3,
       cp.related_correction_id =
       IF ((pool_prod_correction_id > - (1))) pool_prod_correction_id
       ELSE 0
       ENDIF
       , cp.correction_type_cd =
       IF ((request->correction_type_cd > 0)) request->correction_type_cd
       ELSE chg_pool_cd
       ENDIF
       , cp.correction_reason_cd = request->corr_reason_cd,
       cp.orig_updt_cnt = request->cmpntlist[idx].orig_updt_cnt, cp.orig_updt_dt_tm = cnvtdatetime(
        request->cmpntlist[idx].orig_updt_dt_tm), cp.orig_updt_id =
       IF ((request->cmpntlist[idx].orig_updt_id > - (1))) request->cmpntlist[idx].orig_updt_id
       ELSE 0
       ENDIF
       ,
       cp.orig_updt_task = request->cmpntlist[idx].orig_updt_task, cp.orig_updt_applctx = request->
       cmpntlist[idx].orig_updt_applctx, cp.correction_note = request->corr_note,
       cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id,
       cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->updt_applctx, cp
       .product_event_id = 0,
       cp.event_dt_tm = null, cp.reason_cd = 0, cp.autoclave_ind = null,
       cp.destruction_method_cd = 0, cp.destruction_org_id = 0, cp.manifest_nbr = null,
       cp.encntr_id = 0, cp.person_id = 0, cp.expected_usage_dt_tm = null,
       cp.product_nbr = " ", cp.product_sub_nbr = " ", cp.alternate_nbr = " ",
       cp.product_cd = 0, cp.product_class_cd = 0, cp.product_cat_cd = 0,
       cp.supplier_id = 0, cp.recv_dt_tm = null, cp.volume = 0,
       cp.unit_meas_cd = 0, cp.expire_dt_tm = null, cp.abo_cd = 0,
       cp.rh_cd = 0, cp.segment_nbr = " "
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.subeventstatus[1].operationname = "Insert"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "Corrected_Product"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
       "For added component.  Product_Id =",request->cmpntlist[idx].product_id)
      SET failed = "T"
      GO TO exit_script
     ENDIF
   ENDFOR
  ELSE
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE add_quarantine(sub_product_event_id,sub_product_id,sub_quar_reason_cd,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   INSERT  FROM quarantine qu
    SET qu.product_event_id = sub_product_event_id, qu.product_id = sub_product_id, qu.quar_reason_cd
      = sub_quar_reason_cd,
     qu.updt_cnt = 0, qu.updt_dt_tm = cnvtdatetime(sysdate), qu.updt_id = reqinfo->updt_id,
     qu.updt_task = reqinfo->updt_task, qu.updt_applctx = reqinfo->updt_applctx, qu.active_ind =
     sub_active_ind,
     qu.active_status_cd = sub_active_status_cd, qu.active_status_dt_tm = cnvtdatetime(
      sub_active_status_dt_tm), qu.active_status_prsnl_id = sub_active_status_prsnl_id
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=sub_code_set
     AND cv.cdf_meaning=sub_cdf_meaning
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     gsub_code_value = cv.code_value
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE process_product_event_status(sub_pe_type,sub_pe_status,sub_event_type_disp)
  SET sub_pe_process = concat(sub_pe_type," ",sub_event_type_disp," product_event")
  IF (sub_pe_status="FS")
   CALL load_process_status("F",sub_pe_process,"get new product_event_id failed (seq)")
  ELSEIF (sub_pe_status="FA")
   CALL load_process_status("F",sub_pe_process,concat("could not ",sub_pe_type," ",event_type_disp,
     " product_event row"))
  ELSEIF (gsub_product_event_status="FU")
   CALL load_process_status("F",concat(sub_pe_type," active ",sub_event_type_disp,
     " product_event row"),concat(sub_event_type_disp,
     " product_event row could not be released--product_event_id:  ",request->cmpntlist[cmpnt].
     eventlist[event].product_event_id))
  ELSEIF (sub_pe_status != "OK")
   CALL load_process_status("F",sub_pe_process,concat(
     "Script error!  Invalid product_event_status:  ",gsub_product_event_status))
  ENDIF
 END ;Subroutine
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_chg_corr_pool"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
 DECLARE determine_duplicate_blood_product() = null
 SUBROUTINE determine_duplicate_blood_product(null)
   DECLARE dup_cnt = i4 WITH noconstant(0)
   DECLARE serrormsg = vc WITH noconstant(fillstring(255," "))
   DECLARE snewproductnbr = c20 WITH noconstant("")
   DECLARE snewproductcd = f8 WITH noconstant(0)
   DECLARE snewsubnbr = c5 WITH noconstant("")
   DECLARE snewsupprefix = c5 WITH noconstant("")
   DECLARE snewsupid = f8 WITH noconstant(0)
   SET reply->dup_product_cnt = 0
   SELECT INTO "nl:"
    FROM product p,
     blood_product bp
    PLAN (p
     WHERE (p.product_id=request->pooled_product_id))
     JOIN (bp
     WHERE bp.product_id=p.product_id)
    DETAIL
     IF ((request->new_product_nbr="-1"))
      snewproductnbr = p.product_nbr
     ELSE
      snewproductnbr = request->new_product_nbr
     ENDIF
     IF ((request->new_product_cd=- (1)))
      snewproductcd = p.product_cd
     ELSE
      snewproductcd = request->new_product_cd
     ENDIF
     IF ((request->new_product_sub_nbr="-1"))
      snewsubnbr = p.product_sub_nbr
     ELSE
      snewsubnbr = request->new_product_sub_nbr
     ENDIF
     IF ((request->new_supplier_prefix="-1"))
      snewsupprefix = bp.supplier_prefix
     ELSE
      snewsupprefix = request->new_supplier_prefix
     ENDIF
     IF ((request->new_supplier_id=- (1)))
      snewsupid = p.cur_supplier_id
     ELSE
      snewsupid = request->new_supplier_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    *
    FROM product p,
     blood_product bp
    PLAN (p
     WHERE p.product_nbr=cnvtupper(snewproductnbr)
      AND p.product_cd=snewproductcd
      AND ((snewsubnbr <= " "
      AND ((nullind(p.product_sub_nbr)=1) OR (p.product_sub_nbr <= " ")) ) OR (p.product_sub_nbr=
     snewsubnbr))
      AND p.active_ind=1)
     JOIN (bp
     WHERE bp.product_id=p.product_id
      AND ((snewsupprefix > " "
      AND bp.supplier_prefix=snewsupprefix) OR (snewsupprefix <= " "
      AND p.cur_supplier_id=snewsupid)) )
    DETAIL
     dup_cnt += 1, reply->dup_product_cnt = dup_cnt
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET count1 += 1
    IF (count1 > 1)
     SET stat = alter(reply->status_data.subeventstatus,count1)
    ENDIF
    SET reply->status_data.subeventstatus[count1].operationname = "bbt_chg_corr_pool.prg"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname =
    "Select on product - dup check for blood products"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue = serrormsg
   ENDIF
   IF ((reply->dup_product_cnt > 0))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 DECLARE determine_available_state_req() = i2
 SUBROUTINE determine_available_state_req(null)
   IF (recon_rbc_ind=0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM product_event pe
    WHERE (pe.product_id=request->productlist[idx].product_id)
     AND pe.event_type_cd IN (unconfirmed_event_type_cd, directed_event_type_cd,
    autologous_event_type_cd)
     AND pe.active_ind=1
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE getproductcatagory(productcd) = f8
 SUBROUTINE getproductcatagory(productcd)
   DECLARE product_cat_cd = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM product_index pi
    WHERE pi.product_cd=productcd
    DETAIL
     product_cat_cd = pi.product_cat_cd
    WITH nocounter
   ;end select
   RETURN(product_cat_cd)
 END ;Subroutine
 DECLARE getproductclass(productcd) = f8
 SUBROUTINE getproductclass(productcd)
   DECLARE product_class_cd = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM product_index pi
    WHERE pi.product_cd=productcd
    DETAIL
     product_class_cd = pi.product_class_cd
    WITH nocounter
   ;end select
   RETURN(product_class_cd)
 END ;Subroutine
 SUBROUTINE inserteventcorrectedproductrow(activeind,producteventid,oldpersonid,oldencntrid,
  oldusagedttm,oldrelativeind)
   SET corr_id = next_pathnet_seq(0)
   INSERT  FROM corrected_product cp
    SET cp.correction_id = corr_id, cp.product_id =
     IF ((request->pooled_product_id > - (1))) request->pooled_product_id
     ELSE 0
     ENDIF
     , cp.correction_type_cd =
     IF ((request->correction_type_cd > 0)) request->correction_type_cd
     ELSE chg_reconrbc_cd
     ENDIF
     ,
     cp.correction_reason_cd = request->corr_reason_cd, cp.product_nbr = null, cp.barcode_nbr = null,
     cp.product_sub_nbr = null, cp.flag_chars = null, cp.alternate_nbr = null,
     cp.product_cd = - (1), cp.product_class_cd = - (1), cp.product_cat_cd = - (1),
     cp.supplier_id = 0, cp.supplier_prefix = null, cp.recv_dt_tm = null,
     cp.volume = null, cp.unit_meas_cd = - (1), cp.expire_dt_tm = null,
     cp.abo_cd = - (1), cp.rh_cd = - (1), cp.segment_nbr = null,
     cp.manufacturer_id = 0, cp.vis_insp_cd = - (1), cp.ship_cond_cd = - (1),
     cp.cur_intl_units = - (1), cp.cur_avail_qty = - (1), cp.orig_updt_cnt = null,
     cp.orig_updt_dt_tm = null, cp.orig_updt_id = 0, cp.orig_updt_task = null,
     cp.orig_updt_applctx = null, cp.correction_note = null, cp.product_event_id =
     IF ((producteventid > - (1))) producteventid
     ELSE 0
     ENDIF
     ,
     cp.drawn_dt_tm = null, cp.event_dt_tm = cnvtdatetime(""), cp.reason_cd = - (1),
     cp.autoclave_ind = null, cp.destruction_method_cd = - (1), cp.destruction_org_id = 0,
     cp.manifest_nbr = null, cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate),
     cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->
     updt_applctx,
     cp.person_id =
     IF ((((oldpersonid=- (1))) OR (activeind=0)) ) 0
     ELSE oldpersonid
     ENDIF
     , cp.encntr_id =
     IF ((((oldencntrid=- (1))) OR (activeind=0)) ) 0
     ELSE oldencntrid
     ENDIF
     , cp.expected_usage_dt_tm =
     IF ((((oldusagedttm=- (1))) OR (activeind=0)) ) null
     ELSE cnvtdatetime(oldusagedttm)
     ENDIF
     ,
     cp.donated_by_relative_ind =
     IF ((((oldrelativeind=- (1))) OR (activeind=0)) ) - (1)
     ELSE oldrelativeind
     ENDIF
     , cp.cur_owner_area_cd = - (1), cp.cur_inv_area_cd = - (1),
     cp.donation_type_cd = - (1), cp.disease_cd = - (1), cp.related_correction_id =
     IF ((pool_prod_correction_id > - (1))) pool_prod_correction_id
     ELSE 0
     ENDIF
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET count1 += 1
    SET stat = alter(reply->status_data.subeventstatus,count1)
    SET reply->status_data.subeventstatus[count1].operationname = "insert"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "corrected product"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(request->
     pooled_product_id)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 DECLARE update_special_testing() = null
 SUBROUTINE update_special_testing(null)
   DECLARE exist_count = i4 WITH protect, noconstant(0)
   DECLARE hold_spec_tests_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_count = i4 WITH protect, noconstant(0)
   DECLARE next_code = f8 WITH protect, noconstant(0.0)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   FOR (exist_count = 1 TO request->exist_count)
     SELECT INTO "nl:"
      s.*
      FROM special_testing s
      WHERE (s.special_testing_id=request->exist_list[exist_count].special_testing_id)
       AND (s.updt_cnt=request->exist_list[exist_count].spec_test_updt_cnt)
       AND s.active_ind=1
      WITH counter, forupdate(s)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET count1 += 1
      SET stat = alter(reply->status_data.subeventstatus,count1)
      SET reply->status_data.subeventstatus[count1].operationname = "Lock"
      SET reply->status_data.subeventstatus[count1].operationstatus = "F"
      SET reply->status_data.subeventstatus[count1].targetobjectname = "Special Testing"
      SET reply->status_data.subeventstatus[count1].targetobjectvalue = cnvtstring(request->
       product_id,32,2)
      GO TO exit_script
     ENDIF
     UPDATE  FROM special_testing s
      SET s.active_ind = 0, s.updt_cnt = (s.updt_cnt+ 1), s.updt_dt_tm = cnvtdatetime(sysdate),
       s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
       updt_applctx
      WHERE (s.special_testing_id=request->exist_list[exist_count].special_testing_id)
       AND (s.updt_cnt=request->exist_list[exist_count].spec_test_updt_cnt)
       AND s.active_ind=1
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET count1 += 1
      SET stat = alter(reply->status_data.subeventstatus,count1)
      SET reply->status_data.subeventstatus[count1].operationname = "update"
      SET reply->status_data.subeventstatus[count1].operationstatus = "F"
      SET reply->status_data.subeventstatus[count1].targetobjectname = "special testing"
      SET reply->status_data.subeventstatus[count1].targetobjectvalue = cnvtstring(request->
       product_id,32,2)
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
     INSERT  FROM corrected_special_tests c
      SET c.correct_spec_tests_id = new_pathnet_seq, c.orig_special_testing_id = request->exist_list[
       exist_count].special_testing_id, c.correction_id = pool_prod_correction_id,
       c.special_testing_cd = request->exist_list[exist_count].special_testing_cd, c
       .new_spec_test_ind = 0, c.updt_cnt = 0,
       c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
       updt_task,
       c.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET count1 += 1
      SET stat = alter(reply->status_data.subeventstatus,count1)
      SET reply->status_data.subeventstatus[count1].operationname = "insert"
      SET reply->status_data.subeventstatus[count1].operationstatus = "F"
      SET reply->status_data.subeventstatus[count1].targetobjectname = "corrected spec testing1"
      SET reply->status_data.subeventstatus[count1].targetobjectvalue = cnvtstring(request->
       product_id,32,2)
      GO TO exit_script
     ENDIF
   ENDFOR
   FOR (new_count = 1 TO request->new_count)
     SET new_pathnet_seq = 0.0
     SELECT INTO "nl:"
      seqn = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_pathnet_seq = seqn
      WITH format, nocounter
     ;end select
     SET hold_spec_tests_id = new_pathnet_seq
     INSERT  FROM special_testing s
      SET s.special_testing_id = new_pathnet_seq, s.product_id = request->pooled_product_id, s
       .special_testing_cd = request->new_list[new_count].special_testing_cd,
       s.confirmed_ind = request->new_list[new_count].confirmed_ind, s.updt_cnt = 0, s.updt_dt_tm =
       cnvtdatetime(sysdate),
       s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
       updt_applctx,
       s.active_ind = 1, s.active_status_cd = reqdata->active_status_cd, s.active_status_dt_tm =
       cnvtdatetime(sysdate),
       s.active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET count1 += 1
      SET stat = alter(reply->status_data.subeventstatus,count1)
      SET reply->status_data.subeventstatus[count1].operationname = "insert"
      SET reply->status_data.subeventstatus[count1].operationstatus = "F"
      SET reply->status_data.subeventstatus[count1].targetobjectname = "special testing"
      SET reply->status_data.subeventstatus[count1].targetobjectvalue = cnvtstring(request->
       product_id,32,2)
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
     INSERT  FROM corrected_special_tests c
      SET c.correct_spec_tests_id = new_pathnet_seq, c.orig_special_testing_id = hold_spec_tests_id,
       c.correction_id = pool_prod_correction_id,
       c.special_testing_cd = request->new_list[new_count].special_testing_cd, c.new_spec_test_ind =
       1, c.updt_cnt = 0,
       c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
       updt_task,
       c.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      SET count1 += 1
      SET stat = alter(reply->status_data.subeventstatus,count1)
      SET reply->status_data.subeventstatus[count1].operationname = "insert"
      SET reply->status_data.subeventstatus[count1].operationstatus = "F"
      SET reply->status_data.subeventstatus[count1].targetobjectname = "corrected spec testing2"
      SET reply->status_data.subeventstatus[count1].targetobjectvalue = cnvtstring(request->
       product_id,32,2)
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 SUBROUTINE add_product_event_with_inventory_area_cd(sub_product_id,sub_person_id,sub_encntr_id,
  sub_order_id,sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,
  sub_event_status_flag,sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_locn_cd)
   CALL echo(build(" PRODUCT_ID - ",sub_product_id," PERSON_ID - ",sub_person_id," ENCNTR_ID - ",
     sub_encntr_id," SUB_RODER_ID - ",sub_order_id," BB_RESULT_ID - ",sub_bb_result_id,
     " EVENT_TYPE_ID - ",sub_event_type_cd," EVENT_DT_TM_ID - ",sub_event_dt_tm," PRSNL_ID - ",
     sub_event_prsnl_id," EVENT_STATUS_FLAG - ",sub_event_status_flag," override_ind - ",
     sub_override_ind,
     " override_reason_cd - ",sub_override_reason_cd," related_pe_id - ",sub_related_product_event_id,
     " active_ind - ",
     sub_active_ind," active_status_cd - ",sub_active_status_cd," active_status_dt_tm - ",
     sub_active_status_dt_tm,
     " status_prsnl_id - ",sub_active_status_prsnl_id," inventoy_area_cd - ",sub_locn_cd))
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->
      updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
      , pe.inventory_area_cd = sub_locn_cd
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_product_event(sub_product_id,sub_person_id,sub_encntr_id,sub_order_id,
  sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,sub_event_status_flag,
  sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->
      updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
   SET new_product_event_id = product_event_id
 END ;Subroutine
 SUBROUTINE chg_product_event(sub_product_event_id,sub_event_dt_tm,sub_event_prsnl_id,
  sub_event_status_flag,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id,sub_updt_cnt,sub_lock_forupdate_ind,sub_updt_dt_tm_prsnl_ind)
   SET gsub_product_event_status = "  "
   IF (sub_lock_forupdate_ind=1)
    SELECT INTO "nl:"
     pe.product_event_id
     FROM product_event pe
     WHERE pe.product_event_id=sub_product_event_id
      AND pe.updt_cnt=sub_updt_cnt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET gsub_product_event_status = "FL"
    ENDIF
   ENDIF
   IF (((sub_lock_forupdate_ind=0) OR (sub_lock_forupdate_ind=1
    AND curqual > 0)) )
    IF (sub_updt_dt_tm_prsnl_ind=1)
     UPDATE  FROM product_event pe
      SET pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe.event_prsnl_id = sub_event_prsnl_id, pe
       .event_status_flag = sub_event_status_flag,
       pe.active_ind = sub_active_ind, pe.active_status_cd = sub_active_status_cd, pe
       .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
       pe.active_status_prsnl_id = sub_active_status_prsnl_id, pe.updt_cnt = (pe.updt_cnt+ 1), pe
       .updt_dt_tm = cnvtdatetime(sysdate),
       pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
       updt_applctx
      WHERE pe.product_event_id=sub_product_event_id
       AND pe.updt_cnt=sub_updt_cnt
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM product_event pe
      SET pe.event_status_flag = sub_event_status_flag, pe.active_ind = sub_active_ind, pe
       .active_status_cd = sub_active_status_cd,
       pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
       sub_active_status_prsnl_id, pe.updt_cnt = (pe.updt_cnt+ 1),
       pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->
       updt_task,
       pe.updt_applctx = reqinfo->updt_applctx
      WHERE pe.product_event_id=sub_product_event_id
       AND pe.updt_cnt=sub_updt_cnt
      WITH nocounter
     ;end update
    ENDIF
    IF (curqual=0)
     SET gsub_product_event_status = "FU"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "T"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
