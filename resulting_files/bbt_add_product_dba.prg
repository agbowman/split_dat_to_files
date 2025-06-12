CREATE PROGRAM bbt_add_product:dba
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 product_event_id = f8
     2 received_event_id = f8
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
 RECORD internal_date(
   1 event_dt_tm = dq8
 )
 IF ((request->backdate_ind=1))
  SET internal_date->event_dt_tm = cnvtdatetime(request->backdate_dt_tm)
 ELSE
  SET internal_date->event_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 SET success = 0
 SET event = 0
 SET prod = 0
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_to_add = size(request->productlist,5)
 SET seqnbr = 0.0
 SET seqnbr2 = 0.0
 SET y = 0
 SET failed = "F"
 SET product_cat_code = 0.0
 SET product_class_code = 0.0
 SET gsub_product_event_status = "  "
 SET gsub_status = " "
 SET gsub_process = " "
 SET gsub_message = " "
 SET gsub_bp_status = "  "
 SET gsub_ad_status = "  "
 SET gsub_rcvd_status = "  "
 SET gsub_quar_status = "  "
 SET product_event_id = 0.0
 SET assign_event_id = 0.0
 SET gsub_dummy = ""
 SET gsub_code_value = 0.0
 SET quar_code = 0.0
 SET auto_code = 0.0
 SET directed_code = 0.0
 SET received_code = 0.0
 SET unconfirmed_code = 0.0
 SET available_code = 0.0
 SET destroyed_code = 0.0
 SET disposed_code = 0.0
 SET stat = alterlist(reply->qual,nbr_to_add)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"2",code_cnt,quar_code)
 SET stat = uar_get_meaning_by_codeset(1610,"10",code_cnt,auto_code)
 SET stat = uar_get_meaning_by_codeset(1610,"11",code_cnt,directed_code)
 SET stat = uar_get_meaning_by_codeset(1610,"13",code_cnt,received_code)
 SET stat = uar_get_meaning_by_codeset(1610,"9",code_cnt,unconfirmed_code)
 SET stat = uar_get_meaning_by_codeset(1610,"12",code_cnt,available_code)
 SET stat = uar_get_meaning_by_codeset(1610,"14",code_cnt,destroyed_code)
 FOR (x = 1 TO nbr_to_add)
   SET prod = x
   SELECT INTO "nl:"
    snbr = seq(blood_bank_seq,nextval)"#####################;rp0"
    FROM dual
    DETAIL
     seqnbr = cnvtreal(snbr)
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
    SET reply->status_data.subeventstatus[y].operationname = "nextval"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "SEQUENCE"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "blood_bank_seq"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET failed = "T"
   ELSE
    IF ((request->productlist[x].product_id=0))
     SET reply->qual[x].product_id = seqnbr
    ELSE
     SET reply->qual[x].product_id = request->productlist[x].product_id
     SET seqnbr = request->productlist[x].product_id
    ENDIF
    SET reply->qual[x].product_event_id = 0
    SET product_nbr = cnvtupper(request->productlist[x].product_nbr)
    SET alternate_nbr = cnvtupper(request->productlist[x].alternate_nbr)
    SET barcode_nbr = cnvtupper(request->productlist[x].barcode_nbr)
    IF ((request->productlist[x].product_id=0))
     INSERT  FROM product p1
      SET p1.product_id = seqnbr, p1.product_nbr = trim(product_nbr), p1.alternate_nbr = trim(
        alternate_nbr),
       p1.barcode_nbr = trim(barcode_nbr), p1.product_cd = request->productlist[x].product_cd, p1
       .product_cat_cd = request->productlist[x].product_cat_cd,
       p1.product_class_cd = request->productlist[x].product_class_cd, p1.cur_owner_area_cd = request
       ->cur_owner_area_cd, p1.cur_inv_area_cd = request->cur_inv_area_cd,
       p1.recv_dt_tm = cnvtdatetime(internal_date->event_dt_tm), p1.recv_prsnl_id = reqinfo->updt_id,
       p1.cur_unit_meas_cd = request->productlist[x].cur_unit_meas_cd,
       p1.orig_unit_meas_cd = request->productlist[x].cur_unit_meas_cd, p1.cur_supplier_id = request
       ->productlist[x].cur_supplier_id, p1.storage_temp_cd = request->productlist[x].storage_temp_cd,
       p1.pooled_product_id = 0, p1.modified_product_id = 0, p1.donated_by_relative_ind = request->
       productlist[x].donated_by_relative_ind,
       p1.cur_expire_dt_tm = cnvtdatetime(request->productlist[x].cur_expire_dt_tm), p1.active_ind =
       1, p1.active_status_cd = reqdata->active_status_cd,
       p1.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p1.active_status_prsnl_id = reqinfo->
       updt_id, p1.updt_cnt = 0,
       p1.updt_dt_tm = cnvtdatetime(curdate,curtime3), p1.updt_id = reqinfo->updt_id, p1.updt_applctx
        = reqinfo->updt_applctx,
       p1.updt_task = reqinfo->updt_task, p1.create_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH counter
     ;end insert
     IF (curqual=0)
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
      SET reply->status_data.subeventstatus[y].operationname = "insert"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "product"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = request->productlist[x].
      product_nbr
      SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      SET failed = "T"
     ENDIF
    ELSE
     SELECT INTO "nl:"
      p.product_id
      FROM product p
      PLAN (p
       WHERE (p.product_id=request->productlist[x].product_id)
        AND (p.updt_cnt=request->productlist[x].p_updt_cnt))
      WITH nocounter, forupdate(p)
     ;end select
     IF (curqual=0)
      CALL load_process_status("F","FORUPDATE",build("Cannot lock PRODUCT for update",":",request->
        productlist[x].updt_cnt))
      GO TO exit_program
     ELSE
      UPDATE  FROM product p1
       SET p1.product_cat_cd = request->productlist[x].product_cat_cd, p1.product_class_cd = request
        ->productlist[x].product_class_cd, p1.cur_owner_area_cd = request->cur_owner_area_cd,
        p1.cur_inv_area_cd = request->cur_inv_area_cd, p1.recv_dt_tm = cnvtdatetime(curdate,curtime3),
        p1.recv_prsnl_id = reqinfo->updt_id,
        p1.cur_unit_meas_cd = request->productlist[x].cur_unit_meas_cd, p1.orig_unit_meas_cd =
        request->productlist[x].cur_unit_meas_cd, p1.storage_temp_cd = request->productlist[x].
        storage_temp_cd,
        p1.pooled_product_id = 0, p1.modified_product_id = 0, p1.donated_by_relative_ind = request->
        productlist[x].donated_by_relative_ind,
        p1.cur_expire_dt_tm = cnvtdatetime(request->productlist[x].cur_expire_dt_tm), p1.active_ind
         = 1, p1.active_status_cd = reqdata->active_status_cd,
        p1.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p1.active_status_prsnl_id = reqinfo
        ->updt_id, p1.updt_cnt = (p1.updt_cnt+ 1),
        p1.updt_dt_tm = cnvtdatetime(curdate,curtime3), p1.updt_id = reqinfo->updt_id, p1
        .updt_applctx = reqinfo->updt_applctx,
        p1.updt_task = reqinfo->updt_task
       WHERE (p1.product_id=request->productlist[x].product_id)
      ;end update
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
       SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
       SET reply->status_data.subeventstatus[y].operationname = "update into product"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "SEQUENCE"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "blood_bank_seq"
       SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
       SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
       SET failed = "T"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((request->productlist[x].processing_type_flag="B"))
    CALL blood_product_tbls(x)
    IF (gsub_bp_status != "OK")
     SET failed = "T"
     GO TO exit_program
    ENDIF
   ELSE
    IF ((request->productlist[x].processing_type_flag="D"))
     CALL derivative_tbls(x)
     IF (gsub_bp_status != "OK")
      SET failed = "T"
      GO TO exit_program
     ENDIF
    ELSE
     SET failed = "T"
     GO TO exit_program
    ENDIF
   ENDIF
   SET product_event_id = 0.0
   CALL add_product_event(seqnbr,0,0,0,0.0,
    received_code,internal_date->event_dt_tm,reqinfo->updt_id,0,0,
    0,0,0,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
    SET reply->status_data.subeventstatus[y].operationname = "add product event"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product_event"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "received event"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SET received_status = " "
   CALL add_received_event(product_event_id,request->productlist[x].orig_rcvd_qty,request->
    productlist[x].orig_ship_cond_cd,request->productlist[x].orig_vis_insp_cd,request->productlist[x]
    .cur_intl_units)
   IF (gsub_rcvd_status != "OK")
    SET failed = "T"
    GO TO exit_program
   ENDIF
   IF (received_status="F")
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
    SET reply->status_data.subeventstatus[y].operationname = "add received event"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "received event"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "add received event"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET failed = "T"
    GO TO exit_program
   ELSE
    SET reply->qual[x].received_event_id = product_event_id
   ENDIF
   IF ((request->productlist[x].available_ind=1))
    IF ((request->productlist[x].assign_ind=0)
     AND (request->productlist[x].quarantine_ind=0)
     AND (request->productlist[x].autologous_ind=0)
     AND (request->productlist[x].directed_ind=0))
     IF (available_code=0.0)
      SET failed = "T"
      GO TO exit_program
     ENDIF
     SET product_event_id = 0.0
     CALL add_product_event(seqnbr,0,0,0,0.0,
      available_code,internal_date->event_dt_tm,reqinfo->updt_id,0,0,
      0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
      reqinfo->updt_id)
     IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
      SET reply->status_data.subeventstatus[y].operationname = "add product event"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "available event"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
      SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      SET failed = "T"
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   IF ((request->productlist[x].assign_ind=1))
    SET assign_status = " "
    CALL add_assign(seqnbr,request->productlist[x].person_id,request->productlist[x].encntr_id,
     request->productlist[x].reason_cd,request->productlist[x].prov_id,
     request->productlist[x].qty_assigned,request->productlist[x].cur_intl_units,reqinfo->updt_id,
     reqinfo->updt_task,reqinfo->updt_applctx,
     reqdata->active_status_cd,reqinfo->updt_id,cnvtdatetime(curdate,curtime3))
    IF (assign_status="F")
     SET y = (y+ 1)
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
     SET reply->status_data.subeventstatus[y].operationname = "add product event"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "assign event"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET failed = "T"
     GO TO exit_program
    ELSE
     SET reply->qual[x].product_event_id = assign_event_id
    ENDIF
   ENDIF
   IF ((request->productlist[x].quarantine_ind=1))
    IF (((quar_code=0.0) OR ((request->productlist[x].orig_vis_insp_cd=0))) )
     SET failed = "T"
     GO TO exit_program
    ENDIF
    SET product_event_id = 0.0
    CALL add_product_event(seqnbr,0,0,0,0.0,
     quar_code,internal_date->event_dt_tm,reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id)
    IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
     SET y = (y+ 1)
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
     SET reply->status_data.subeventstatus[y].operationname = "add product event"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "product_event"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET failed = "T"
    ELSE
     CALL add_quarantine(product_event_id,request->quar_reason_cd,request->productlist[x].
      orig_quar_qty)
     IF (gsub_quar_status != "OK")
      SET failed = "T"
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE blood_product_tbls(idx)
   SET gsub_bp_status = "OK"
   SET ev_type_cd = 0.0
   IF ((request->productlist[idx].product_id=0))
    INSERT  FROM blood_product p2
     SET p2.product_id = seqnbr, p2.product_cd = request->productlist[idx].product_cd, p2
      .orig_expire_dt_tm = cnvtdatetime(request->productlist[idx].cur_expire_dt_tm),
      p2.drawn_dt_tm = cnvtdatetime(request->productlist[idx].drawn_dt_tm), p2.cur_volume = request->
      productlist[idx].cur_volume, p2.orig_volume = request->productlist[idx].cur_volume,
      p2.orig_label_abo_cd = request->productlist[idx].abo_cd, p2.orig_label_rh_cd = request->
      productlist[idx].rh_cd, p2.cur_abo_cd = request->productlist[idx].abo_cd,
      p2.cur_rh_cd = request->productlist[idx].rh_cd, p2.autologous_ind = request->productlist[idx].
      autologous_ind, p2.directed_ind = request->productlist[idx].directed_ind,
      p2.segment_nbr = trim(request->productlist[idx].segment_nbr), p2.supplier_prefix = request->
      productlist[idx].supplier_prefix, p2.active_ind = 1,
      p2.active_status_cd = reqdata->active_status_cd, p2.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), p2.active_status_prsnl_id = reqinfo->updt_id,
      p2.updt_cnt = 0, p2.updt_dt_tm = cnvtdatetime(curdate,curtime3), p2.updt_id = reqinfo->updt_id,
      p2.updt_task = reqinfo->updt_task, p2.updt_applctx = reqinfo->updt_applctx
     WITH counter
    ;end insert
    IF (curqual=0)
     SET y = (y+ 1)
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
     SET reply->status_data.subeventstatus[y].operationname = "insert"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = "blood_product"
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET gsub_bp_status = "FI"
     SET success = 0
    ELSE
     SET success = 1
    ENDIF
   ELSE
    CALL inactivate_events(gsub_dummy)
    SELECT INTO "nl:"
     bp.product_id
     FROM blood_product bp
     PLAN (bp
      WHERE (bp.product_id=request->productlist[idx].product_id)
       AND (bp.updt_cnt=request->productlist[idx].bp_updt_cnt))
     WITH nocounter, forupdate(bp)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","FORUPDATE","Cannot lock BLOOD_PRODUCT for update")
     GO TO exit_program
    ELSE
     UPDATE  FROM blood_product p2
      SET p2.cur_volume = request->productlist[idx].cur_volume, p2.cur_abo_cd = request->productlist[
       idx].abo_cd, p2.cur_rh_cd = request->productlist[idx].rh_cd,
       p2.autologous_ind = request->productlist[idx].autologous_ind, p2.directed_ind = request->
       productlist[idx].directed_ind, p2.segment_nbr = trim(request->productlist[idx].segment_nbr),
       p2.active_ind = 1, p2.active_status_cd = reqdata->active_status_cd, p2.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p2.active_status_prsnl_id = reqinfo->updt_id, p2.updt_cnt = 0, p2.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       p2.updt_id = reqinfo->updt_id, p2.updt_task = reqinfo->updt_task, p2.updt_applctx = reqinfo->
       updt_applctx
      WHERE (p2.product_id=request->productlist[idx].product_id)
     ;end update
     IF (curqual=0)
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
      SET reply->status_data.subeventstatus[y].operationname = "update"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = "blood_product"
      SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      SET gsub_bp_status = "FU"
      SET success = 0
     ELSE
      SET success = 1
     ENDIF
    ENDIF
   ENDIF
   IF (success=1)
    IF ((request->productlist[idx].available_ind=0))
     IF (unconfirmed_code=0.0)
      SET gsub_bp_status = "F"
     ELSE
      IF (request->productlist[idx].conf_req_ind)
       CALL add_product_event(seqnbr,0,0,0,0.0,
        unconfirmed_code,internal_date->event_dt_tm,reqinfo->updt_id,0,0,
        0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id)
       IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
        SET gsub_bp_status = "FI"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((request->productlist[idx].spectest_qty > 0))
     FOR (idx2 = 1 TO request->productlist[idx].spectest_qty)
      SELECT INTO "nl:"
       snbr = seq(pathnet_seq,nextval)"#####################;rp0"
       FROM dual
       DETAIL
        seqnbr2 = cnvtreal(snbr)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET gsub_bp_status = "FQ"
       SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
       SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
       SET reply->status_data.subeventstatus[y].operationname = "nextval"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "SEQUENCE"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "pathnet_seq"
       SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
       SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      ELSE
       INSERT  FROM special_testing s
        SET s.special_testing_id = seqnbr2, s.product_id = seqnbr, s.special_testing_cd = request->
         productlist[idx].spectestlist[idx2].special_testing_cd,
         s.confirmed_ind = request->productlist[idx].spectestlist[idx2].confirmed_ind, s.active_ind
          = 1, s.active_status_cd = reqdata->active_status_cd,
         s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo->
         updt_id, s.updt_cnt = 0,
         s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
         reqinfo->updt_task,
         s.updt_applctx = reqinfo->updt_applctx
        WITH counter
       ;end insert
       IF (curqual=0)
        SET gsub_bp_status = "FS"
        SET y = (y+ 1)
        IF (y > 1)
         SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
        SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
        SET reply->status_data.subeventstatus[y].operationname = "insert"
        SET reply->status_data.subeventstatus[y].operationstatus = "F"
        SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
        SET reply->status_data.subeventstatus[y].targetobjectvalue = "special_testing"
        SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
        SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
    IF ((request->productlist[idx].autologous_ind=1))
     IF (auto_code=0.0)
      SET gsub_bp_status = "F"
     ELSE
      SET product_event_id = 0.0
      CALL add_product_event(seqnbr,request->productlist[x].person_id,request->productlist[idx].
       encntr_id,0,0.0,
       auto_code,internal_date->event_dt_tm,reqinfo->updt_id,0,0,
       0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id)
      IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
       SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
       SET reply->status_data.subeventstatus[y].operationname = "add product event"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "autologous event"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = concat(
        "add product event -- product_event_status = ",gsub_product_event_status)
       SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
       SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
       SET failed = "T"
      ELSE
       CALL add_auto_directed(product_event_id,request->productlist[idx].person_id,request->
        productlist[idx].encntr_id,request->productlist[idx].expected_usage_dt_tm)
       IF (gsub_ad_status != "OK")
        SET gsub_bp_status = "F"
       ELSE
        SET reply->qual[x].product_event_id = product_event_id
       ENDIF
      ENDIF
     ENDIF
    ELSE
     IF ((request->productlist[idx].directed_ind=1))
      SET product_event_id = 0.0
      CALL add_product_event(seqnbr,request->productlist[x].person_id,request->productlist[idx].
       encntr_id,0,0.0,
       directed_code,internal_date->event_dt_tm,reqinfo->updt_id,0,0,
       0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id)
      IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
       SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
       SET reply->status_data.subeventstatus[y].operationname = "add product event"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "directed event"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
       SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
       SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
       SET gsub_bp_status = "F"
      ELSE
       CALL add_auto_directed(product_event_id,request->productlist[idx].person_id,request->
        productlist[idx].encntr_id,request->productlist[idx].expected_usage_dt_tm)
       IF (gsub_ad_status != "OK")
        SET gsub_bp_status = "F"
       ELSE
        SET reply->qual[x].product_event_id = product_event_id
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE derivative_tbls(idx)
  SET gsub_bp_status = "OK"
  IF ((request->productlist[idx].product_id=0))
   INSERT  FROM derivative d
    SET d.product_id = seqnbr, d.manufacturer_id = request->productlist[idx].manufacturer_id, d
     .product_cd = request->productlist[idx].product_cd,
     d.cur_avail_qty = request->productlist[idx].cur_avail_qty, d.cur_intl_units = request->
     productlist[idx].cur_intl_units, d.units_per_vial = request->productlist[idx].units_per_vial,
     d.item_volume = request->productlist[idx].item_volume, d.item_unit_meas_cd = request->
     productlist[idx].item_unit_meas_cd, d.active_ind = 1,
     d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), d.active_status_prsnl_id = reqinfo->updt_id,
     d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
     d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET gsub_bp_status = "FI"
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "special_testing"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   ENDIF
  ELSE
   SELECT INTO "nl:"
    drv.product_id
    FROM derivative drv
    PLAN (drv
     WHERE (drv.product_id=request->productlist[idx].product_id)
      AND (drv.updt_cnt=request->productlist[idx].drv_updt_cnt))
    WITH nocounter, forupdate(drv)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","FORUPDATE","Cannot lock DERIVATIVE for update")
    GO TO exit_program
   ELSE
    UPDATE  FROM derivative d
     SET d.cur_avail_qty = (d.cur_avail_qty+ request->productlist[idx].cur_avail_qty), d
      .cur_intl_units = (d.cur_intl_units+ request->productlist[idx].cur_intl_units), d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
      reqinfo->updt_task,
      d.updt_applctx = reqinfo->updt_applctx
     WHERE (d.product_id=request->productlist[idx].product_id)
    ;end update
    IF (curqual=0)
     SET y = (y+ 1)
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
     SET reply->status_data.subeventstatus[y].operationname = "Update"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = "Derivative"
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET gsub_bp_status = "FU"
     SET success = 0
    ELSE
     SET success = 1
    ENDIF
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
 SUBROUTINE add_received_event(rcvd_event_id,orig_rcvd_qty,ship_cond_cd,vis_insp_cd,rcv_intl_units)
   SET gsub_rcvd_status = "OK"
   INSERT  FROM receipt r
    SET r.product_event_id = rcvd_event_id, r.product_id = seqnbr, r.bb_supplier_id = request->
     productlist[x].bb_supplier_id,
     r.alpha_translation_id = request->productlist[x].alpha_translation_id, r.orig_rcvd_qty =
     orig_rcvd_qty, r.ship_cond_cd = ship_cond_cd,
     r.vis_insp_cd = vis_insp_cd, r.orig_intl_units = rcv_intl_units, r.active_ind = 0,
     r.active_status_cd = reqdata->active_status_cd, r.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), r.active_status_prsnl_id = reqinfo->updt_id,
     r.updt_cnt = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id,
     r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "receipt"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET gsub_rcvd_status = "FI"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_quarantine(quar_event_id,reason_cd,orig_quar_qty)
   SET gsub_quar_status = "OK"
   INSERT  FROM quarantine q
    SET q.product_event_id = quar_event_id, q.product_id = seqnbr, q.quar_reason_cd = reason_cd,
     q.orig_quar_qty = orig_quar_qty, q.cur_quar_qty = orig_quar_qty, q.active_ind = 1,
     q.active_status_cd = reqdata->active_status_cd, q.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), q.active_status_prsnl_id = reqinfo->updt_id,
     q.updt_cnt = 0, q.updt_dt_tm = cnvtdatetime(curdate,curtime3), q.updt_id = reqinfo->updt_id,
     q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "quarantine"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET gsub_quar_status = "FI"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_assign(sub_product_id,sub_person_id,encntr_id,sub_assign_reason_cd,sub_prov_id,
  qty_assigned,assign_intl_units,sub_updt_id,sub_updt_task,sub_updt_applctx,sub_active_status_cd,
  sub_active_status_prsnl_id,assign_dt_tm)
   SET assign_event_id = 0.0
   SET event_type_cd = 0.0
   CALL get_event_type("1")
   IF (event_type_cd=0)
    SET assign_status = "F"
   ELSE
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET product_event_id = 0.0
    SET sub_product_event_id = 0.0
    CALL add_product_event(sub_product_id,sub_person_id,encntr_id,0,0,
     event_type_cd,cnvtdatetime(assign_dt_tm),reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id)
    SET sub_product_event_id = product_event_id
    IF (curqual=0)
     SET assign_status = "F"
    ELSE
     INSERT  FROM assign a
      SET a.product_event_id = sub_product_event_id, a.product_id = sub_product_id, a.person_id =
       sub_person_id,
       a.assign_reason_cd = sub_assign_reason_cd, a.prov_id = sub_prov_id, a.orig_assign_qty =
       qty_assigned,
       a.cur_assign_qty = qty_assigned, a.cur_assign_intl_units = assign_intl_units, a
       .orig_assign_intl_units = assign_intl_units,
       a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = sub_updt_id,
       a.updt_task = sub_updt_task, a.updt_applctx = sub_updt_applctx, a.active_ind = 1,
       a.active_status_cd = sub_active_status_cd, a.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), a.active_status_prsnl_id = sub_active_status_prsnl_id
      WITH counter
     ;end insert
     IF (curqual=0)
      SET assign_status = "F"
     ELSE
      SET assign_event_id = sub_product_event_id
      SET assign_status = "S"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_event_type(meaning)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=1610
     AND cv.cdf_meaning=meaning
    DETAIL
     event_type_cd = cv.code_value
    WITH counter
   ;end select
 END ;Subroutine
 SUBROUTINE add_auto_directed(autodir_event_id,autodir_person_id,autodir_encntr_id,
  autodir_usage_dt_tm)
   SET gsub_ad_status = "OK"
   INSERT  FROM auto_directed ad
    SET ad.product_event_id = autodir_event_id, ad.product_id = seqnbr, ad.person_id =
     autodir_person_id,
     ad.encntr_id = autodir_encntr_id, ad.expected_usage_dt_tm = cnvtdatetime(autodir_usage_dt_tm),
     ad.associated_dt_tm = cnvtdatetime(curdate,curtime3),
     ad.active_ind = 1, ad.active_status_cd = reqdata->active_status_cd, ad.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     ad.active_status_prsnl_id = reqinfo->updt_id, ad.updt_cnt = 0, ad.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ad.updt_id = reqinfo->updt_id, ad.updt_task = reqinfo->updt_task, ad.updt_applctx = reqinfo->
     updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_blood_product"
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "auto_directed"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET gsub_ad_status = "F"
   ENDIF
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
 SUBROUTINE inactivate_events(gsub_dummy2)
  SET event_cnt = cnvtint(size(request->productlist[prod].eventlist,5))
  IF (event_cnt > 0)
   FOR (event = 1 TO event_cnt)
     IF ((request->productlist[prod].eventlist[event].event_type_cd=unconfirmed_code))
      CALL inactivate_unconfirmed(gsub_dummy)
     ELSEIF ((((request->productlist[prod].eventlist[event].event_type_cd=auto_code)) OR ((request->
     productlist[prod].eventlist[event].event_type_cd=directed_code))) )
      CALL inactivate_auto_directed(gsub_dummy)
     ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd=disposed_code))
      CALL inactivate_disposed(gsub_dummy)
     ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd=destroyed_code))
      CALL inactivate_destroyed(gsub_dummy)
     ENDIF
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_unconfirmed(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","forupdate",
     "unconfirmed product_event row could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
    prod].eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate",build(
      "Unconfirmed product_event row could not be inactivated--product_event_id:",internal->
      eventlist[event].product_event_id))
    RETURN
   ELSE
    IF (gsub_product_event_status != "OK")
     CALL load_process_status("F","inactivate",build("Script error!  Invalid product_event_status--",
       gsub_product_event_status))
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_auto_directed(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","forupdate","product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    ad.product_event_id
    FROM auto_directed ad
    PLAN (ad
     WHERE (ad.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (ad.updt_cnt=request->productlist[prod].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(ad)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","forupdate","auto_directed rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
    prod].eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate",build(
      "Auto_directed product_event row could not be inactivated--product_event_id:",internal->
      eventlist[event].product_event_id))
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    CALL chg_auto_directed(request->productlist[prod].eventlist[event].product_event_id,request->
     productlist[prod].eventlist[event].pe_child_updt_cnt,0,reqdata->inactive_status_cd,cnvtdatetime(
      curdate,curtime3),
     reqinfo->updt_id)
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ENDIF
   ELSE
    CALL load_process_status("F","inactivate auto_directed product_event",build(
      "Script error!  Invalid product_event_status--",gsub_product_event_status))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_destroyed(sub_dummy2)
   SELECT
    d.seq
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row 1, col 1, request->productlist[x].product_nbr,
     col 20, "DESTROYED"
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","forupdate","product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    d.product_event_id
    FROM destruction d
    PLAN (d
     WHERE (d.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (d.updt_cnt=request->productlist[prod].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(d)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","forupdate","destroyed rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
    prod].eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate",build(
      "Auto_directed product_event row could not be inactivated--product_event_id:",internal->
      eventlist[event].product_event_id))
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    CALL chg_destroyed(request->productlist[prod].eventlist[event].product_event_id,request->
     productlist[prod].eventlist[event].pe_child_updt_cnt,0,reqdata->inactive_status_cd,cnvtdatetime(
      curdate,curtime3),
     reqinfo->updt_id)
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ENDIF
   ELSE
    CALL load_process_status("F","inactivate",build("Script error!  Invalid product_event_status--",
      gsub_product_event_status))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_disposed(sub_dummy2)
   SELECT
    d.seq
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row 1, col 1, request->productlist[x].product_nbr,
     col 20, "DISPOSED"
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","forupdate","product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    di.product_event_id
    FROM disposition di
    PLAN (di
     WHERE (di.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (di.updt_cnt=request->productlist[prod].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(di)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","forupdate","disposed rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
    prod].eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate",build(
      "Disposed product_event row could not be inactivated--product_event_id:",internal->eventlist[
      event].product_event_id))
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    CALL chg_disposed(request->productlist[prod].eventlist[event].product_event_id,request->
     productlist[prod].eventlist[event].pe_child_updt_cnt,0,reqdata->inactive_status_cd,cnvtdatetime(
      curdate,curtime3),
     reqinfo->updt_id)
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ENDIF
   ELSE
    CALL load_process_status("F","inactivate",build("Script error!  Invalid product_event_status--",
      gsub_product_event_status))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_auto_directed(sub_product_event_id,sub_updt_cnt,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id)
  UPDATE  FROM auto_directed ad
   SET ad.active_ind = sub_active_ind, ad.active_status_cd = sub_active_status_cd, ad
    .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
    ad.active_status_prsnl_id = sub_active_status_prsnl_id, ad.updt_cnt = (ad.updt_cnt+ 1), ad
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ad.updt_task = reqinfo->updt_task, ad.updt_id = reqinfo->updt_id, ad.updt_applctx = reqinfo->
    updt_applctx
   WHERE ad.product_event_id=sub_product_event_id
    AND ad.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate auto_directed row"
   SET gsub_message = "auto_directed row could not be inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE chg_destroyed(sub_product_event_id,sub_updt_cnt,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id)
  UPDATE  FROM destruction d
   SET d.active_ind = sub_active_ind, d.active_status_cd = sub_active_status_cd, d
    .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
    d.active_status_prsnl_id = sub_active_status_prsnl_id, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    d.updt_task = reqinfo->updt_task, d.updt_id = reqinfo->updt_id, d.updt_applctx = reqinfo->
    updt_applctx
   WHERE d.product_event_id=sub_product_event_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate destruction row"
   SET gsub_message = "destruction row could not be inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE chg_disposed(sub_product_event_id,sub_updt_cnt,sub_active_ind,sub_active_status_cd,
  sub_active_status_dt_tm,sub_active_status_prsnl_id)
  UPDATE  FROM disposition di
   SET di.active_ind = sub_active_ind, di.active_status_cd = sub_active_status_cd, di
    .active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm),
    di.active_status_prsnl_id = sub_active_status_prsnl_id, di.updt_cnt = (di.updt_cnt+ 1), di
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_applctx = reqinfo->
    updt_applctx
   WHERE di.product_event_id=sub_product_event_id
    AND di.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate disposed row"
   SET gsub_message = "disposed row could not be inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data[prod].status = "F"
   SET reply->status_data[prod].subeventstatus[1].sourceobjectname = "BBT_ADD_PRODUCT"
   SET reply->status_data[prod].subeventstatus[1].sourceobjectqual = 0
   SET reply->status_data[prod].subeventstatus[1].sourceobjectvalue = ""
   SET reply->status_data[prod].subeventstatus[1].operationstatus = sub_status
   SET reply->status_data[prod].subeventstatus[1].targetobjectname = sub_process
   SET reply->status_data[prod].subeventstatus[1].targetobjectvalue = sub_message
   SET failed = "T"
   GO TO exit_program
 END ;Subroutine
#exit_program
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echo(build("status_data->status =",reply->status_data.status))
 FOR (x = 1 TO count1)
   CALL echo(reply->status_data.subeventstatus[x].operationname)
   CALL echo(reply->status_data.subeventstatus[x].operationstatus)
   CALL echo(reply->status_data.subeventstatus[x].targetobjectname)
   CALL echo(reply->status_data.subeventstatus[x].targetobjectvalue)
 ENDFOR
END GO
