CREATE PROGRAM bbd_upd_shipment_products:dba
 RECORD reply(
   1 shipment_in_process_cd = f8
   1 shipment_in_process_mean = c12
   1 shipment_in_process_disp = c40
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
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE cntrcount = i4 WITH protect, noconstant(size(request->container,5))
 DECLARE ship_in_process_cd = f8 WITH protect, noconstant(0.0)
 DECLARE quarantine_cd = f8 WITH protect, noconstant(0.0)
 DECLARE exception_type_code = f8 WITH protect, noconstant(0.0)
 DECLARE shipped_cd = f8 WITH protect, noconstant(0.0)
 DECLARE transferred_cd = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE cur_inv_area_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cur_owner_area_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cur_abo_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cur_rh_cd = f8 WITH protect, noconstant(0.0)
 DECLARE bb_exception_id = f8 WITH protect, noconstant(0.0)
 DECLARE returned_product_ind = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET code_set = 1610
 DECLARE cdf_mean = c12 WITH protect, noconstant(fillstring(12," "))
 SET cdf_mean = "22"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,ship_in_process_cd)
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "2"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,quarantine_cd)
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "15"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,shipped_cd)
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "6"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,transferred_cd)
 SET code_set = 14072
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "SHIPQUARPROD"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,exception_type_code)
 IF (((ship_in_process_cd=0.0) OR (((quarantine_cd=0.0) OR (((shipped_cd=0.0) OR (((transferred_cd=
 0.0) OR (exception_type_code=0.0)) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (ship_in_process_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the shipment in process event type code value."
  ELSEIF (quarantine_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the quarantine event type code value."
  ELSEIF (shipped_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the shipped event type code value."
  ELSEIF (transferred_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the transferred event type code value."
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the exception type code value."
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ELSE
  SET reply->shipment_in_process_cd = ship_in_process_cd
  SET reply->shipment_in_process_disp = uar_get_code_display(ship_in_process_cd)
  SET reply->shipment_in_process_mean = uar_get_code_meaning(ship_in_process_cd)
 ENDIF
 IF ((request->shipment_update_ind="C"))
  UPDATE  FROM bb_shipment s
   SET s.updt_cnt = (s.updt_cnt+ 1), s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_applctx =
    reqinfo->updt_applctx,
    s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.shipment_status_flag = 3
   WHERE (s.shipment_id=request->shipment_id)
    AND s.active_ind=1
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIPMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error inactivating the shipment."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  FOR (x = 1 TO cntrcount)
    UPDATE  FROM bb_ship_container c
     SET c.active_ind = 0, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,curtime3
       ),
      c.updt_applctx = reqinfo->updt_applctx, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
      updt_task
     WHERE (c.container_id=request->container[x].container_id)
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
     SET reply->status_data.subeventstatus[1].operationname = "Update"
     SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIP_CONTAINER"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inactivating the shipment's containers."
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
     GO TO exit_script
    ENDIF
    SET prodcount = size(request->container[x].product,5)
    FOR (y = 1 TO prodcount)
      UPDATE  FROM bb_ship_event e
       SET e.active_ind = 0, e.updt_cnt = (e.updt_cnt+ 1), e.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        e.updt_applctx = reqinfo->updt_applctx, e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->
        updt_task
       WHERE (e.product_id=request->container[x].product[y].product_id)
        AND (e.shipment_id=request->shipment_id)
        AND (e.container_id=request->container[x].container_id)
      ;end update
      IF (curqual=0)
       SET failed = "T"
       SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
       SET reply->status_data.subeventstatus[1].operationname = "Update"
       SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIP_EVENT"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Error inactivating the shipment products."
       SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
       GO TO exit_script
      ENDIF
      UPDATE  FROM product_event p
       SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        p.updt_applctx = reqinfo->updt_applctx, p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
        updt_task
       WHERE (p.product_id=request->container[x].product[y].product_id)
        AND p.event_type_cd=ship_in_process_cd
        AND p.active_ind=1
      ;end update
      IF (curqual=0)
       SET failed = "T"
       SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
       SET reply->status_data.subeventstatus[1].operationname = "Update"
       SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Error inactivating the shipment products in the product_event table."
       SET reply->status_data.subeventstatus[1].sourceobjectqual = 4
       GO TO exit_script
      ENDIF
    ENDFOR
  ENDFOR
 ELSEIF ((request->shipment_update_ind="U"))
  FOR (x = 1 TO cntrcount)
    IF ((request->container[x].container_update_ind="U"))
     UPDATE  FROM bb_ship_container c
      SET c.total_weight = request->container[x].total_weight, c.unit_of_meas_cd = request->
       container[x].unit_of_meas_cd, c.temperature_value = request->container[x].temperature,
       c.temperature_degree_cd = request->container[x].temperature_degree_cd, c.updt_applctx =
       reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1)
      WHERE (c.container_id=request->container[x].container_id)
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIP_CONTAINER"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Error on updating container information."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 5
      GO TO exit_script
     ENDIF
    ELSEIF ((request->container[x].container_update_ind="D"))
     UPDATE  FROM bb_ship_container c
      SET c.active_ind = 0, c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1)
      WHERE (c.container_id=request->container[x].container_id)
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
      SET reply->status_data.subeventstatus[1].operationname = "Update"
      SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIP_CONTAINER"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Error on deleting container information."
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 6
      GO TO exit_script
     ENDIF
    ENDIF
    SET prodcount = size(request->container[x].product,5)
    FOR (y = 1 TO prodcount)
      IF ((request->container[x].product[y].product_update_ind="A"))
       SET gsub_product_event_status = "  "
       SET product_event_id = 0.0
       SET new_product_event_id = 0.0
       CALL add_product_event(request->container[x].product[y].product_id,0.0,0.0,0.0,0.0,
        ship_in_process_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
        0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id)
       SET new_product_event_id = product_event_id
       IF (gsub_product_event_status != "OK")
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
        SET reply->status_data.subeventstatus[1].operationname = "Insert"
        SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Error on inserting new a ship in process product event."
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 7
        GO TO exit_script
       ENDIF
       SELECT INTO "nl:"
        p.cur_inv_area_cd, p.cur_owner_area_cd
        FROM product p
        WHERE (p.product_id=request->container[x].product[y].product_id)
         AND p.active_ind=1
        HEAD REPORT
         cur_inv_area_cd = p.cur_inv_area_cd, cur_owner_area_cd = p.cur_owner_area_cd
        WITH nocounter
       ;end select
       INSERT  FROM bb_ship_event e
        SET e.product_event_id = new_product_event_id, e.container_id = request->container[x].
         container_id, e.product_id = request->container[x].product[y].product_id,
         e.shipment_id = request->shipment_id, e.return_vis_insp_cd = request->container[x].product[y
         ].return_vis_insp_cd, e.return_dt_tm = null,
         e.return_condition_cd = request->container[x].product[y].return_condition_cd, e.vis_insp_cd
          = request->container[x].product[y].visual_inspection_cd, e.from_owner_area_cd =
         cur_owner_area_cd,
         e.from_inventory_area_cd = cur_inv_area_cd, e.active_status_cd = reqdata->active_status_cd,
         e.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         e.active_status_prsnl_id = reqinfo->updt_id, e.active_ind = 1, e.updt_applctx = reqinfo->
         updt_applctx,
         e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id, e.updt_task =
         reqinfo->updt_task,
         e.updt_cnt = 0
       ;end insert
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
        SET reply->status_data.subeventstatus[1].operationname = "Insert"
        SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIP_EVENT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Error on inserting new product information."
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 8
        GO TO exit_script
       ENDIF
      ELSEIF ((request->container[x].product[y].product_update_ind="D"))
       UPDATE  FROM bb_ship_event e
        SET e.active_ind = 0, e.updt_applctx = reqinfo->updt_applctx, e.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->updt_task, e.updt_cnt = 0
        WHERE (e.shipment_id=request->shipment_id)
         AND (e.container_id=request->container[x].container_id)
         AND (e.product_id=request->container[x].product[y].product_id)
       ;end update
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
        SET reply->status_data.subeventstatus[1].operationname = "Insert"
        SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIP_EVENT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Error on deleting product information."
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 9
        GO TO exit_script
       ENDIF
       UPDATE  FROM product_event p
        SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         p.updt_applctx = reqinfo->updt_applctx, p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo
         ->updt_task
        WHERE (p.product_id=request->container[x].product[y].product_id)
         AND p.event_type_cd=ship_in_process_cd
         AND p.active_ind=1
       ;end update
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
        SET reply->status_data.subeventstatus[1].operationname = "Update"
        SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Error inactivating the shipment products in the product_event table."
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 10
        GO TO exit_script
       ENDIF
      ELSEIF ((request->container[x].product[y].product_update_ind="U"))
       IF ((request->container[x].product[y].return_vis_insp_cd > 0.0)
        AND cnvtdatetime(request->container[x].product[y].return_dt_tm) > 0
        AND request->container[x].product[y].return_condition_cd)
        SET returned_product_ind = 1
       ENDIF
       UPDATE  FROM bb_ship_event e
        SET e.updt_applctx = reqinfo->updt_applctx, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
         .updt_id = reqinfo->updt_id,
         e.updt_task = reqinfo->updt_task, e.updt_cnt = (e.updt_cnt+ 1), e.vis_insp_cd = request->
         container[x].product[y].visual_inspection_cd,
         e.return_vis_insp_cd = request->container[x].product[y].return_vis_insp_cd, e.return_dt_tm
          =
         IF (cnvtdatetime(request->container[x].product[y].return_dt_tm) > 0) cnvtdatetime(request->
           container[x].product[y].return_dt_tm)
         ELSE null
         ENDIF
         , e.active_ind =
         IF (returned_product_ind=1) 0
         ELSE e.active_ind
         ENDIF
         ,
         e.return_condition_cd = request->container[x].product[y].return_condition_cd
        WHERE (e.shipment_id=request->shipment_id)
         AND (e.container_id=request->container[x].container_id)
         AND (e.product_id=request->container[x].product[y].product_id)
       ;end update
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
        SET reply->status_data.subeventstatus[1].operationname = "Update"
        SET reply->status_data.subeventstatus[1].targetobjectname = "BB_SHIP_EVENT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Error updating product information."
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 11
        GO TO exit_script
       ENDIF
       IF (returned_product_ind=1)
        UPDATE  FROM product_event p
         SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,
           curtime3),
          p.updt_applctx = reqinfo->updt_applctx, p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo
          ->updt_task
         WHERE (p.product_id=request->container[x].product[y].product_id)
          AND p.event_type_cd IN (shipped_cd, transferred_cd)
          AND p.active_ind=1
        ;end update
        IF (curqual=0)
         SET failed = "T"
         SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
         SET reply->status_data.subeventstatus[1].operationname = "Update"
         SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
         SET reply->status_data.subeventstatus[1].targetobjectvalue =
         "Error inactivating the shipped/transferred products in the product_event table."
         SET reply->status_data.subeventstatus[1].sourceobjectqual = 12
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      IF ((request->container[x].product[y].quarantine_reason_cd > 0.0))
       SET gsub_product_event_status = "  "
       SET product_event_id = 0.0
       SET new_product_event_id = 0.0
       CALL add_product_event(request->container[x].product[y].product_id,0.0,0.0,0.0,0.0,
        quarantine_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
        0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id)
       SET new_product_event_id = product_event_id
       IF (gsub_product_event_status != "OK")
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
        SET reply->status_data.subeventstatus[1].operationname = "Insert"
        SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Error on inserting new a quarantine product event."
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 13
        GO TO exit_script
       ENDIF
       INSERT  FROM quarantine q
        SET q.product_event_id = new_product_event_id, q.product_id = request->container[x].product[y
         ].product_id, q.quar_reason_cd = request->container[x].product[y].quarantine_reason_cd,
         q.orig_quar_qty = 0, q.cur_quar_qty = 0, q.active_ind = 1,
         q.active_status_cd = reqdata->active_status_cd, q.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), q.active_status_prsnl_id = reqinfo->updt_id,
         q.updt_cnt = 0, q.updt_dt_tm = cnvtdatetime(curdate,curtime3), q.updt_id = reqinfo->updt_id,
         q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
        SET reply->status_data.subeventstatus[1].operationname = "Insert"
        SET reply->status_data.subeventstatus[1].targetobjectname = "QUARANTINE"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Error updating product information."
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 14
        GO TO exit_script
       ELSE
        SET returned_product_ind = 0
       ENDIF
      ENDIF
      SET exceptcount = size(request->container[x].product[y].exceptions,5)
      FOR (z = 1 TO exceptcount)
        SELECT INTO "nl:"
         bp.cur_abo_cd, bp.cur_rh_cd
         FROM blood_product bp
         WHERE (bp.product_id=request->container[x].product[y].product_id)
          AND bp.active_ind=1
         HEAD REPORT
          cur_abo_cd = bp.cur_abo_cd, cur_rh_cd = bp.cur_rh_cd
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         seqn = seq(pathnet_seq,nextval)
         FROM dual
         DETAIL
          bb_exception_id = seqn
         WITH format, nocounter
        ;end select
        INSERT  FROM bb_exception b
         SET b.exception_id = bb_exception_id, b.product_event_id = new_product_event_id, b
          .exception_type_cd = exception_type_code,
          b.event_type_cd = quarantine_cd, b.product_abo_cd = cur_abo_cd, b.product_rh_cd = cur_rh_cd,
          b.override_reason_cd = request->container[x].product[y].exceptions[z].override_reason_cd, b
          .updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
          b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1,
          b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(
           curdate,curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
          b.exception_dt_tm = cnvtdatetime(curdate,curtime3), b.exception_id = reqinfo->updt_id, b
          .from_abo_cd = 0.0,
          b.from_rh_cd = 0.0, b.to_abo_cd = 0.0, b.to_rh_cd = 0.0,
          b.result_id = 0.0, b.perform_result_id = 0.0, b.updt_cnt = 0,
          b.order_id = 0.0, b.person_id = 0.0, b.person_abo_cd = 0.0,
          b.person_rh_cd = 0.0, b.donor_contact_id = 0.0, b.donor_contact_type_cd = 0.0,
          b.review_status_cd = 0.0, b.review_dt_tm = null, b.review_doc_id = 0.0,
          b.review_by_prsnl_id = 0.0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET failed = "T"
         SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_shipment_products.prg"
         SET reply->status_data.subeventstatus[1].operationname = "Insert"
         SET reply->status_data.subeventstatus[1].targetobjectname = "BB_EXCEPTION"
         SET reply->status_data.subeventstatus[1].targetobjectvalue =
         "Error inserting a new exception."
         SET reply->status_data.subeventstatus[1].sourceobjectqual = 15
         GO TO exit_script
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
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
 END ;Subroutine
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
