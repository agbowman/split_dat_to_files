CREATE PROGRAM bbd_upd_shipment_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 RECORD product(
   1 product[*]
     2 product_id = f8
     2 product_event_id = f8
     2 updt_cnt = i4
 )
 DECLARE failed = c1 WITH protect, constant("F")
 DECLARE shipped_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE in_transit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ship_in_process_cd = f8 WITH protect, noconstant(0.0)
 DECLARE unconfirmed_cd = f8 WITH protect, noconstant(0.0)
 DECLARE available_cd = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE ecount = i4 WITH protect, noconstant(0)
 SET code_set = 1610
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "15"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,shipped_type_cd)
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "25"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,in_transit_cd)
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "22"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,ship_in_process_cd)
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "9"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,unconfirmed_cd)
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "12"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,available_cd)
 IF (((shipped_type_cd=0.0) OR (((ship_in_process_cd=0.0) OR (((in_transit_cd=0.0) OR (((
 unconfirmed_cd=0.0) OR (available_cd=0.0)) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_info.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error retrieving product states."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 IF ((request->update_ind="A"))
  UPDATE  FROM bb_shipment s
   SET s.needed_dt_tm = cnvtdatetime(request->needed_dt_tm), s.order_dt_tm = cnvtdatetime(request->
     order_dt_tm), s.order_placed_by = request->order_placed_by,
    s.owner_area_cd = request->owner_area_cd, s.inventory_area_cd = request->inventory_area_cd, s
    .organization_id = request->organization_id,
    s.shipment_dt_tm =
    IF (cnvtdatetime(request->shipment_dt_tm) > 0) cnvtdatetime(request->shipment_dt_tm)
    ELSE s.shipment_dt_tm
    ENDIF
    , s.shipment_status_flag =
    IF ((request->shipment_status_flag > 0)) request->shipment_status_flag
    ELSE s.shipment_status_flag
    ENDIF
    , s.courier_cd =
    IF ((request->courier_cd > 0.0)) request->courier_cd
    ELSE s.courier_cd
    ENDIF
    ,
    s.order_priority_cd = request->order_priority_cd, s.active_ind = request->active_ind, s
    .updt_applctx = reqinfo->updt_applctx,
    s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->
    updt_task,
    s.updt_cnt = (s.updt_cnt+ 1)
   WHERE (s.shipment_id=request->shipment_id)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_info.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIPMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error on updating shipment information."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
   GO TO exit_script
  ENDIF
 ELSEIF ((request->update_ind="S"))
  SELECT INTO "nl:"
   e.product_id, p.product_event_id, p.updt_cnt
   FROM bb_ship_event e,
    product_event p
   PLAN (e
    WHERE (e.shipment_id=request->shipment_id)
     AND e.active_ind=1)
    JOIN (p
    WHERE p.product_id=e.product_id
     AND p.event_type_cd=ship_in_process_cd
     AND p.active_ind=1)
   ORDER BY e.product_id
   HEAD e.product_id
    IF (e.product_id > 0.0)
     ecount += 1, stat = alterlist(product->product,ecount), product->product[ecount].product_id = e
     .product_id,
     product->product[ecount].product_event_id = p.product_event_id, product->product[ecount].
     updt_cnt = p.updt_cnt
    ENDIF
   FOOT  e.product_id
    row + 1
   WITH nocounter
  ;end select
  FOR (i = 1 TO ecount)
    SET gsub_product_event_status = "  "
    SET product_event_id = 0.0
    CALL add_product_event(product->product[i].product_id,0.0,0.0,0.0,0.0,
     IF ((request->organization_id > 0.0)) shipped_type_cd
     ELSE in_transit_cd
     ENDIF
     ,cnvtdatetime(sysdate),reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(sysdate),
     reqinfo->updt_id)
    IF (gsub_product_event_status != "OK")
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
     SET reply->status_data.subeventstatus[1].operationname = "Insert"
     SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error on inserting new a product event."
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
     GO TO exit_script
    ENDIF
    CALL chg_product_event(product->product[i].product_event_id,cnvtdatetime(sysdate),reqinfo->
     updt_id,0,0,
     reqdata->active_status_cd,cnvtdatetime(sysdate),reqinfo->updt_id,product->product[i].updt_cnt,0,
     0)
    IF (gsub_product_event_status != "OK")
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
     SET reply->status_data.subeventstatus[1].operationname = "Insert"
     SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error on inactivating a SHIPMENT IN PROCESS product event."
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 4
     GO TO exit_script
    ENDIF
    UPDATE  FROM bb_ship_event e
     SET e.product_event_id = product_event_id, e.updt_cnt = (e.updt_cnt+ 1), e.updt_dt_tm =
      cnvtdatetime(sysdate),
      e.updt_applctx = reqinfo->updt_applctx, e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->
      updt_task
     WHERE (e.product_event_id=product->product[i].product_event_id)
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_info.prg"
     SET reply->status_data.subeventstatus[1].operationname = "Update"
     SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIP_EVENT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error updating shipment products."
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     p.product_id
     FROM product_event p
     WHERE (p.product_id=product->product[i].product_id)
      AND p.active_ind=1
      AND p.event_type_cd IN (available_cd, unconfirmed_cd)
    ;end select
    IF (curqual != 0)
     UPDATE  FROM product_event e
      SET e.active_ind = 0, e.updt_cnt = (e.updt_cnt+ 1), e.updt_dt_tm = cnvtdatetime(sysdate),
       e.updt_applctx = reqinfo->updt_applctx, e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->
       updt_task
      WHERE (e.product_id=product->product[i].product_id)
       AND e.event_type_cd IN (available_cd, unconfirmed_cd)
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_info.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Error inactivating available and unconfirmed states."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  UPDATE  FROM bb_shipment s
   SET s.shipment_dt_tm = cnvtdatetime(request->shipment_dt_tm), s.shipment_status_flag = 2, s
    .courier_cd = request->courier_cd,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo
    ->updt_id,
    s.updt_task = reqinfo->updt_task, s.updt_cnt = (s.updt_cnt+ 1)
   WHERE (s.shipment_id=request->shipment_id)
    AND s.active_ind=1
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_info.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIPMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error on updating shipment information when shipped."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 5
   GO TO exit_script
  ENDIF
 ENDIF
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
 END ;Subroutine
#exit_script
 FREE SET product
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
