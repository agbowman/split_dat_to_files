CREATE PROGRAM bbt_add_quarantine:dba
 RECORD reply(
   1 product_status[10]
     2 product_id = f8
     2 status = c1
     2 err_process = vc
     2 err_message = vc
     2 quar_status[10]
       3 quar_reason_cd = f8
       3 product_event_id = f8
       3 product_event_status = c2
       3 status = c1
       3 err_process = vc
       3 err_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD changed_products
 RECORD changed_products(
   1 product_cnt = i4
   1 products[*]
     2 product_id = f8
     2 status_flag = i2
     2 dereservation_dt_tm = dq8
     2 reason_cd = f8
 )
 DECLARE addproducttochangedproducts(productid=f8,dereservationdttm=dq8,reasoncd=f8,statusflag=i2) =
 null
 SUBROUTINE addproducttochangedproducts(productid,dereservationdttm,reasoncd,statusflag)
   DECLARE pcnt = i4 WITH noconstant(0)
   SET pcnt = (changed_products->product_cnt+ 1)
   IF (pcnt > size(changed_products->products,5))
    SET stat = alterlist(changed_products->products,(pcnt+ 5))
   ENDIF
   SET changed_products->product_cnt = pcnt
   SET changed_products->products[pcnt].product_id = productid
   IF (dereservationdttm != null)
    SET changed_products->products[pcnt].dereservation_dt_tm = dereservationdttm
   ENDIF
   SET changed_products->products[pcnt].reason_cd = reasoncd
   SET changed_products->products[pcnt].status_flag = statusflag
 END ;Subroutine
 DECLARE sendstatuschangemessage(null) = null
 SUBROUTINE sendstatuschangemessage(null)
   SET stat = alterlist(changed_products->products,changed_products->product_cnt)
   IF ((changed_products->product_cnt > 0))
    EXECUTE bbt_send_product_status_change  WITH replace("REQUEST","CHANGED_PRODUCTS"), replace(
     "REPLY","SC_REPLY")
   ENDIF
   FREE RECORD changed_products
 END ;Subroutine
 DECLARE gsub_code_value = f8 WITH protect, noconstant(0.0)
 DECLARE product_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE sub_product_event_id = f8 WITH protect, noconstant(0.0)
 SET product_state_code_set = 1610
 SET quarantined_cdf_meaning = "2"
 SET gsub_code_value = 0.0
 SET gsub_dummy = ""
 SET gsub_product_event_status = "  "
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET quar_cnt = 0
 SET max_quar_cnt = 0
 SET tot_quar_cnt = 0
 SET success_cnt = 0
 SET tot_success_cnt = 0
 SET count1 = 0
 SET quarantined_event_type_cd = 0.0
 SET sub_product_event_id = 0.0
 SET derivative_ind = " "
 SET cur_avail_qty = 0
 SET new_avail_qty = 0
 SET bp_inactivate_available_ind = " "
 DECLARE luspervial = i4 WITH noconstant(0)
#begin_main
 SET product_cnt = cnvtint(size(request->productlist,5))
 SET stat = alter(reply->product_status,product_cnt)
 CALL get_code_value(product_state_code_set,quarantined_cdf_meaning)
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get quarantined event_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get quarantined event_type_cd"
 ELSE
  SET quarantined_event_type_cd = gsub_code_value
  SET reply->status_data.status = "I"
  SET request->event_dt_tm = cnvtdatetime(curdate,curtime3)
  SET request->event_prsnl_id = reqinfo->updt_id
 ENDIF
 FOR (prod = 1 TO product_cnt)
   SET reply->product_status[prod].status = reply->status_data.status
   SET reply->product_status[prod].product_id = request->productlist[prod].product_id
   SET success_cnt = 0
   SET quar_cnt = 0
   SET quar_cnt = cnvtint(size(request->productlist[prod].quarlist,5))
   SET tot_quar_cnt = (tot_quar_cnt+ quar_cnt)
   IF (quar_cnt > max_quar_cnt)
    SET max_quar_cnt = quar_cnt
    SET stat = alter(reply->product_status.quar_status,max_quar_cnt)
   ENDIF
   CALL process_quarantines(gsub_dummy)
   SET tot_success_cnt = (tot_success_cnt+ success_cnt)
   IF ((reply->product_status[prod].status != "F"))
    CALL addproducttochangedproducts(request->productlist[prod].product_id,null,request->productlist[
     prod].quarlist[1].quar_reason_cd,1)
   ENDIF
   UPDATE  FROM product p
    SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     p.updt_task = reqinfo->updt_task, p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->
     updt_applctx
    PLAN (p
     WHERE (p.product_id=request->productlist[prod].product_id)
      AND (p.updt_cnt=request->productlist[prod].p_updt_cnt))
    WITH counter
   ;end update
   IF (curqual=0)
    IF ((reply->product_status[prod].status != "F"))
     SET reply->product_status[prod].status = "F"
     SET reply->product_status[prod].err_process = "update product"
     SET reply->product_status[prod].err_message =
     "product row could not be updated--Quarantines may have been added but product row is still locked"
    ENDIF
   ELSE
    SET ssuccess_cnt = cnvtstring(success_cnt)
    SET squar_cnt = cnvtstring(quar_cnt)
    SET smsg = concat("all rows updated for ",trim(ssuccess_cnt)," of ",trim(squar_cnt),
     " quarantines")
    SET reply->product_status[prod].err_message = smsg
    IF (success_cnt > 0)
     IF (success_cnt=quar_cnt)
      SET reply->product_status[prod].status = "S"
      SET reply->product_status[prod].err_process = "Success"
     ELSE
      SET reply->product_status[prod].status = "P"
      SET reply->product_status[prod].err_process = "Partial Success"
     ENDIF
    ELSE
     SET reply->product_status[prod].status = "Z"
     SET reply->product_status[prod].err_process = "Zero Success"
    ENDIF
   ENDIF
   IF ((reply->product_status[prod].status != "F"))
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
 ENDFOR
 CALL sendstatuschangemessage(null)
 GO TO exit_script
#end_main
 SUBROUTINE process_quarantines(sub_dummy)
  SET liuspervial = 0
  FOR (quar = 1 TO quar_cnt)
    SET reply->product_status[prod].quar_status[quar].quar_reason_cd = request->productlist[prod].
    quarlist[quar].quar_reason_cd
    SET reply->product_status[prod].quar_status[quar].status = "X"
    IF ((request->productlist[prod].quarlist[quar].quar_reason_cd > 0))
     SET reply->product_status[prod].quar_status[quar].status = "I"
     IF ((reply->product_status[prod].status != "F"))
      SET derivative_ind = "N"
      SET cur_avail_qty = 0
      SET bp_inactivate_available_ind = "N"
      SELECT INTO "nl:"
       p.product_id
       FROM product p
       PLAN (p
        WHERE (p.product_id=request->productlist[prod].product_id)
         AND (p.updt_cnt=request->productlist[prod].p_updt_cnt))
       WITH nocounter, forupdate(p)
      ;end select
      IF (curqual=0)
       SET reply->product_status[prod].status = "F"
       SET reply->product_status[prod].err_process = "lock product rows forupdate"
       SET reply->product_status[prod].err_message = "product rows could not be locked forupdate"
      ELSE
       SELECT INTO "nl:"
        p.product_id, drv.product_id, drv.cur_avail_qty,
        pe_drv.product_event_id, bp.product_id, pe_bp.product_event_id
        FROM (dummyt d_drv_bp  WITH seq = 1),
         derivative drv,
         product_event pe_drv,
         blood_product bp,
         (dummyt d_bp  WITH seq = 1),
         product_event pe_bp
        PLAN (d_drv_bp
         WHERE d_drv_bp.seq=1)
         JOIN (((drv
         WHERE (drv.product_id=request->productlist[prod].product_id)
          AND (drv.updt_cnt=request->productlist[prod].drv_updt_cnt))
         JOIN (pe_drv
         WHERE pe_drv.product_id=drv.product_id
          AND (pe_drv.product_event_id=request->productlist[prod].available_product_event_id)
          AND (pe_drv.updt_cnt=request->productlist[prod].available_pe_updt_cnt))
         ) ORJOIN ((bp
         WHERE (bp.product_id=request->productlist[prod].product_id))
         JOIN (d_bp
         WHERE d_bp.seq=1)
         JOIN (pe_bp
         WHERE pe_bp.product_id=bp.product_id
          AND (pe_bp.product_event_id=request->productlist[prod].available_product_event_id)
          AND (pe_bp.updt_cnt=request->productlist[prod].available_pe_updt_cnt))
         ))
        DETAIL
         IF (bp.seq > 0)
          derivative_ind = "N"
          IF ((request->productlist[prod].available_product_event_id != null)
           AND (request->productlist[prod].available_product_event_id != 0))
           IF (pe_bp.seq > 0
            AND quar=1)
            bp_inactivate_available_ind = "Y"
           ELSEIF (quar=1)
            reply->product_status[prod].status = "F", reply->product_status[prod].err_process =
            "lock available product_event row forupdate", reply->product_status[prod].err_message =
            "available product_event row could not be locked forupdate"
           ENDIF
          ENDIF
         ELSEIF (drv.seq > 0)
          derivative_ind = "Y", cur_avail_qty = drv.cur_avail_qty, luspervial = drv.units_per_vial
         ENDIF
        WITH nocounter, outerjoin(d_bp)
       ;end select
       IF (curqual=0)
        SET reply->product_status[prod].status = "F"
        SET reply->product_status[prod].err_process =
        "select product, product_event and/or derivative rows forupdate"
        SET reply->product_status[prod].err_message =
        "product, product_event and/or derivative rows could not be selected"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((reply->product_status[prod].quar_status[quar].status != "X"))
     SET reply->product_status[prod].quar_status[quar].status = reply->product_status[prod].status
     SET reply->product_status[prod].quar_status[quar].err_process = reply->product_status[prod].
     err_process
     SET reply->product_status[prod].quar_status[quar].err_message = reply->product_status[prod].
     err_message
    ENDIF
    IF ((reply->product_status[prod].quar_status[quar].status != "F")
     AND (reply->product_status[prod].quar_status[quar].status != "X"))
     CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
      quarantined_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
      0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
      reqinfo->updt_id)
     SET reply->product_status[prod].quar_status[quar].product_event_status =
     gsub_product_event_status
     SET sub_product_event_id = product_event_id
     IF (gsub_product_event_status="FS")
      SET reply->product_status[prod].quar_status[quar].status = "F"
      SET reply->product_status[prod].quar_status[quar].err_process = "add product_event"
      SET reply->product_status[prod].quar_status[quar].err_message =
      "get new product_event_id failed (seq) "
     ELSEIF (gsub_product_event_status="FA")
      SET reply->product_status[prod].quar_status[quar].status = "F"
      SET reply->product_status[prod].quar_status[quar].err_process = "add product_event"
      SET reply->product_status[prod].quar_status[quar].err_message =
      "product_event row could not be added"
     ELSEIF (gsub_product_event_status="OK")
      SET reply->product_status[prod].quar_status[quar].product_event_id = sub_product_event_id
      INSERT  FROM quarantine qu
       SET qu.product_event_id = sub_product_event_id, qu.product_id = request->productlist[prod].
        product_id, qu.quar_reason_cd = request->productlist[prod].quarlist[quar].quar_reason_cd,
        qu.orig_quar_qty = request->productlist[prod].quarlist[quar].quar_qty, qu.cur_quar_qty =
        request->productlist[prod].quarlist[quar].quar_qty, qu.active_ind = 1,
        qu.active_status_cd = reqdata->active_status_cd, qu.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3), qu.active_status_prsnl_id = reqinfo->updt_id,
        qu.updt_cnt = 0, qu.updt_dt_tm = cnvtdatetime(curdate,curtime3), qu.updt_task = reqinfo->
        updt_task,
        qu.updt_id = reqinfo->updt_id, qu.updt_applctx = reqinfo->updt_applctx, qu
        .cur_quar_intl_units = (request->productlist[prod].quarlist[quar].quar_qty * luspervial),
        qu.orig_quar_intl_units = (request->productlist[prod].quarlist[quar].quar_qty * luspervial)
       WITH counter
      ;end insert
      IF (curqual=0)
       SET reply->product_status[prod].quar_status[quar].status = "F"
       SET reply->product_status[prod].quar_status[quar].err_process = "add quarantine"
       SET reply->product_status[prod].quar_status[quar].err_message =
       "quarantine row could not be added"
      ELSE
       IF (derivative_ind="Y")
        SELECT INTO "nl:"
         drv.product_id
         FROM derivative drv
         PLAN (drv
          WHERE (drv.product_id=request->productlist[prod].product_id)
           AND (drv.updt_cnt=request->productlist[prod].drv_updt_cnt))
         WITH nocounter, forupdate(drv)
        ;end select
        IF (curqual=0)
         SET reply->product_status[prod].status = "F"
         SET reply->product_status[prod].err_process = "lock derivative rows forupdate"
         SET reply->product_status[prod].err_message =
         "derivative rows could not be locked forupdate"
        ELSE
         SET new_avail_qty = (cur_avail_qty - request->productlist[prod].quarlist[quar].quar_qty)
         UPDATE  FROM derivative drv
          SET drv.cur_avail_qty = new_avail_qty, drv.cur_intl_units = (new_avail_qty * drv
           .units_per_vial), drv.updt_cnt = (drv.updt_cnt+ 1),
           drv.updt_dt_tm = cnvtdatetime(curdate,curtime3), drv.updt_task = reqinfo->updt_task, drv
           .updt_id = reqinfo->updt_id,
           drv.updt_applctx = reqinfo->updt_applctx
          WHERE (drv.product_id=request->productlist[prod].product_id)
           AND (drv.updt_cnt=request->productlist[prod].drv_updt_cnt)
         ;end update
         IF (curqual=0)
          SET reply->product_status[prod].quar_status[quar].status = "F"
          SET reply->product_status[prod].quar_status[quar].err_process = "update derivative"
          SET reply->product_status[prod].quar_status[quar].err_message =
          "derivative row could not be added"
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      IF ((reply->product_status[prod].quar_status[quar].status != "F"))
       IF (((quar=1
        AND derivative_ind != "Y"
        AND bp_inactivate_available_ind="Y") OR (derivative_ind="Y"
        AND new_avail_qty <= 0)) )
        SET gsub_product_event_status = "  "
        SELECT INTO "nl:"
         pe_drv.product_id
         FROM product_event pe_drv
         PLAN (pe_drv
          WHERE (pe_drv.product_id=request->productlist[prod].product_id)
           AND (pe_drv.product_event_id=request->productlist[prod].available_product_event_id)
           AND (pe_drv.updt_cnt=request->productlist[prod].available_pe_updt_cnt))
         WITH nocounter, forupdate(pe_drv)
        ;end select
        IF (curqual=0)
         SET reply->product_status[prod].status = "F"
         SET reply->product_status[prod].err_process = "lock product_event rows forupdate"
         SET reply->product_status[prod].err_message =
         "product_event rows could not be locked forupdate"
        ELSE
         CALL chg_product_event(request->productlist[prod].available_product_event_id,cnvtdatetime(
           curdate,curtime3),0,0,0,
          reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->
          productlist[prod].available_pe_updt_cnt,0,
          0)
         IF (gsub_product_event_status != "OK")
          SET reply->product_status[prod].quar_status[quar].status = "F"
          SET reply->product_status[prod].quar_status[quar].err_process =
          "inactivate available product_event"
          SET reply->product_status[prod].quar_status[quar].err_message =
          "available product_event row could not be inactivated"
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ELSE
      SET reply->product_status[prod].quar_status[quar].status = "F"
      SET reply->product_status[prod].quar_status[quar].err_process = "add product_event"
      SET reply->product_status[prod].quar_status[quar].err_message = build(
       "Script error!  Invalid product_event_status--",gsub_product_event_status)
     ENDIF
    ENDIF
    IF ((reply->product_status[prod].quar_status[quar].status != "X"))
     IF ((reply->product_status[prod].quar_status[quar].status="F"))
      ROLLBACK
     ELSE
      COMMIT
      SET success_cnt = (success_cnt+ 1)
      SET reply->product_status[prod].quar_status[quar].status = "S"
      SET reply->product_status[prod].quar_status[quar].err_process = "COMPLETE"
      SET reply->product_status[prod].quar_status[quar].err_message =
      "all rows for quarantine added/updated"
     ENDIF
    ENDIF
  ENDFOR
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
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
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
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
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
   SET reply->product_status[prod].quar_status[quar].product_event_status = gsub_product_event_status
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
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
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
       pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
       reqinfo->updt_task,
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
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=sub_code_set
     AND cv.cdf_meaning=sub_cdf_meaning
    DETAIL
     gsub_code_value = cv.code_value
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "F"))
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "bbt_add_quarantine"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "Success"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "script completed successfully"
  IF (tot_success_cnt > 0)
   SET reqinfo->commit_ind = 1
   IF (tot_success_cnt=tot_quar_cnt)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "P"
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
