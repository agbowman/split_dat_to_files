CREATE PROGRAM bbt_chg_quarantine:dba
 RECORD reply(
   1 product_status[5]
     2 product_id = f8
     2 status = c1
     2 err_process = vc
     2 err_message = vc
     2 quar_status[1]
       3 release_reason_cd = f8
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
 RECORD internal(
   1 gsub_event_dt_tm = f8
 )
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
 SET product_event_id = 0.0
 SET new_pathnet_seq = 0.0
 SET cur_quar_qty = 0
 SET new_quar_qty = 0
 SET quar_active_status_cd = 0.0
 SET quar_active_ind = 0
 SET derivative_ind = " "
 SET new_drv_updt_cnt = 0
 SET add_available_ind = " "
 SET new_avail_qty = 0
 DECLARE luspervial = i4 WITH noconstant(0)
 DECLARE assigned_cdf_meaning = c12
 DECLARE quarantined_cdf_meaning = c12
 DECLARE crossmatched_cdf_meaning = c12
 DECLARE issued_cdf_meaning = c12
 DECLARE disposed_cdf_meaning = c12
 DECLARE transferred_cdf_meaning = c12
 DECLARE transfused_cdf_meaning = c12
 DECLARE modified_cdf_meaning = c12
 DECLARE unconfirmed_cdf_meaning = c12
 DECLARE autologous_cdf_meaning = c12
 DECLARE directed_cdf_meaning = c12
 DECLARE available_cdf_meaning = c12
 DECLARE received_cdf_meaning = c12
 DECLARE destroyed_cdf_meaning = c12
 DECLARE shipped_cdf_meaning = c12
 DECLARE in_progress_cdf_meaning = c12
 DECLARE pooled_cdf_meaning = c12
 DECLARE pooled_product_cdf_meaning = c12
 DECLARE confirmed_cdf_meaning = c12
 DECLARE drawn_cdf_meaning = c12
 DECLARE tested_cdf_meaning = c12
 DECLARE intransit_cdf_meaning = c12
 DECLARE transferred_from_cdf_meaning = c12
 SET product_state_code_set = 1610
 SET product_state_expected_cnt = 19
 SET assigned_cdf_meaning = "1"
 SET quarantined_cdf_meaning = "2"
 SET crossmatched_cdf_meaning = "3"
 SET issued_cdf_meaning = "4"
 SET disposed_cdf_meaning = "5"
 SET transferred_cdf_meaning = "6"
 SET transfused_cdf_meaning = "7"
 SET modified_cdf_meaning = "8"
 SET unconfirmed_cdf_meaning = "9"
 SET autologous_cdf_meaning = "10"
 SET directed_cdf_meaning = "11"
 SET available_cdf_meaning = "12"
 SET received_cdf_meaning = "13"
 SET destroyed_cdf_meaning = "14"
 SET shipped_cdf_meaning = "15"
 SET in_progress_cdf_meaning = "16"
 SET pooled_cdf_meaning = "17"
 SET pooled_product_cdf_meaning = "18"
 SET confirmed_cdf_meaning = "19"
 SET drawn_cdf_meaning = "20"
 SET tested_cdf_meaning = "21"
 SET intransit_cdf_meaning = "25"
 SET modified_product_cdf_meaning = "24"
 SET transferred_from_cdf_meaning = "26"
 SET assigned_event_type_cd = 0.0
 SET quarantined_event_type_cd = 0.0
 SET crossmatched_event_type_cd = 0.0
 SET issued_event_type_cd = 0.0
 SET disposed_event_type_cd = 0.0
 SET transferred_event_type_cd = 0.0
 SET transfused_event_type_cd = 0.0
 SET modified_event_type_cd = 0.0
 SET unconfirmed_event_type_cd = 0.0
 SET autologous_event_type_cd = 0.0
 SET directed_event_type_cd = 0.0
 SET available_event_type_cd = 0.0
 SET received_event_type_cd = 0.0
 SET destroyed_event_type_cd = 0.0
 SET shipped_event_type_cd = 0.0
 SET in_progress_event_type_cd = 0.0
 SET pooled_event_type_cd = 0.0
 SET pooled_product_event_type_cd = 0.0
 SET confirmed_event_type_cd = 0.0
 SET drawn_event_type_cd = 0.0
 SET tested_event_type_cd = 0.0
 SET in_transit_event_type_cd = 0.0
 SET modified_product_event_type_cd = 0.0
 SET transferred_from_event_type_cd = 0.0
 SET get_event_type_cds_status = " "
 DECLARE get_event_type_cds(event_type_status) = c1
 SUBROUTINE get_event_type_cds(event_type_cd_dummy)
   SET event_type_status = "F"
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,assigned_cdf_meaning,1,
    assigned_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,quarantined_cdf_meaning,1,
    quarantined_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,crossmatched_cdf_meaning,1,
    crossmatched_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,issued_cdf_meaning,1,
    issued_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,disposed_cdf_meaning,1,
    disposed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transferred_cdf_meaning,1,
    transferred_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transfused_cdf_meaning,1,
    transfused_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,modified_cdf_meaning,1,
    modified_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,unconfirmed_cdf_meaning,1,
    unconfirmed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,autologous_cdf_meaning,1,
    autologous_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,directed_cdf_meaning,1,
    directed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,available_cdf_meaning,1,
    available_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,received_cdf_meaning,1,
    received_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,destroyed_cdf_meaning,1,
    destroyed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,shipped_cdf_meaning,1,
    shipped_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,in_progress_cdf_meaning,1,
    in_progress_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,pooled_cdf_meaning,1,
    pooled_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,pooled_product_cdf_meaning,1,
    pooled_product_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,confirmed_cdf_meaning,1,
    confirmed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,drawn_cdf_meaning,1,
    drawn_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,tested_cdf_meaning,1,
    tested_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,intransit_cdf_meaning,1,
    in_transit_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,modified_product_cdf_meaning,1,
    modified_product_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transferred_from_cdf_meaning,1,
    transferred_from_event_type_cd)
   SET event_type_status = "S"
   RETURN(event_type_status)
 END ;Subroutine
#begin_main
 SET product_cnt = cnvtint(size(request->productlist,5))
 SET stat = alter(reply->product_status,product_cnt)
 SET get_event_type_cds_status = get_event_type_cds(gsub_dummy)
 IF (((get_event_type_cds_status="F") OR (0.0 IN (assigned_event_type_cd, quarantined_event_type_cd,
 crossmatched_event_type_cd, issued_event_type_cd, transferred_event_type_cd,
 transfused_event_type_cd, unconfirmed_event_type_cd, autologous_event_type_cd,
 directed_event_type_cd, shipped_event_type_cd,
 in_progress_event_type_cd, available_event_type_cd, in_transit_event_type_cd))) )
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get event_type code_values"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  IF (get_event_type_cds_status="F")
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get event_type code_values, select failed"
  ELSEIF (assigned_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get assigned event_type_cd"
  ELSEIF (quarantined_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get quarantined event_type_cd"
  ELSEIF (crossmatched_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get crossmatched event_type_cd"
  ELSEIF (issuted_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get issuted event_type_cd"
  ELSEIF (transferred_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get transferred event_type_cd"
  ELSEIF (transfused_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get transfused event_type_cd"
  ELSEIF (unconfirmed_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get unconfirmed event_type_cd"
  ELSEIF (autologous_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get autologous event_type_cd"
  ELSEIF (directed_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get directed event_type_cd"
  ELSEIF (available_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get available event_type_cd"
  ELSEIF (shipped_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get shipped event_type_cd"
  ELSEIF (in_progress_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get in_progress event_type_cd"
  ELSEIF (in_transit_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get in_transit_event_type_cd"
  ENDIF
  GO TO exit_script
 ELSE
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
     "product row could not be updated--Quarantines added but product still locked"
    ENDIF
   ELSE
    SET ssuccess_cnt = cnvtstring(success_cnt)
    SET squar_cnt = cnvtstring(quar_cnt)
    SET smsg = concat(trim(ssuccess_cnt)," of ",trim(squar_cnt)," quarantines released for product.")
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
 GO TO exit_script
#end_main
 SUBROUTINE process_quarantines(sub_dummy)
   SET new_drv_updt_cnt = request->productlist[prod].drv_updt_cnt
   SET luspervial = 0
   FOR (quar = 1 TO quar_cnt)
     SET reply->product_status[prod].quar_status[quar].release_reason_cd = request->productlist[prod]
     .quarlist[quar].release_reason_cd
     SET reply->product_status[prod].quar_status[quar].product_event_id = request->productlist[prod].
     quarlist[quar].product_event_id
     SET reply->product_status[prod].quar_status[quar].status = "X"
     IF ((request->productlist[prod].quarlist[quar].product_event_id > 0))
      SET reply->product_status[prod].quar_status[quar].status = "I"
      IF ((reply->product_status[prod].status != "F"))
       SET derivative_ind = " "
       SET add_available_ind = " "
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
         p.product_id, pe.product_event_id, pe.event_type_cd,
         qu.cur_quar_qty, bp.seq, bp.product_id,
         drv.seq, drv.product_id
         FROM product p,
          product_event pe,
          quarantine qu,
          (dummyt d_drv_bp  WITH seq = 1),
          derivative drv,
          blood_product bp
         PLAN (p
          WHERE (p.product_id=request->productlist[prod].product_id)
           AND (p.updt_cnt=request->productlist[prod].p_updt_cnt))
          JOIN (pe
          WHERE pe.product_id=p.product_id
           AND (((pe.product_event_id=request->productlist[prod].quarlist[quar].product_event_id)
           AND (pe.updt_cnt=request->productlist[prod].quarlist[quar].pe_updt_cnt)) OR (pe.active_ind
          =1
           AND (pe.product_event_id != request->productlist[prod].quarlist[quar].product_event_id)
           AND pe.event_type_cd IN (assigned_event_type_cd, quarantined_event_type_cd,
          crossmatched_event_type_cd, issued_event_type_cd, transferred_event_type_cd,
          transfused_event_type_cd, unconfirmed_event_type_cd, autologous_event_type_cd,
          directed_event_type_cd, shipped_event_type_cd,
          in_progress_event_type_cd, available_event_type_cd, drawn_event_type_cd,
          tested_event_type_cd, in_transit_event_type_cd))) )
          JOIN (qu
          WHERE (qu.product_event_id=request->productlist[prod].quarlist[quar].product_event_id)
           AND (qu.updt_cnt=request->productlist[prod].quarlist[quar].qu_updt_cnt))
          JOIN (d_drv_bp
          WHERE d_drv_bp.seq=1)
          JOIN (((drv
          WHERE drv.product_id=p.product_id
           AND drv.updt_cnt=new_drv_updt_cnt)
          ) ORJOIN ((bp
          WHERE bp.product_id=p.product_id)
          ))
         ORDER BY p.product_id, pe.product_event_id
         HEAD p.product_id
          add_available_ind = "Y"
          IF (drv.seq > 0)
           derivative_ind = "Y", cur_quar_qty = qu.cur_quar_qty, luspervial = drv.units_per_vial
          ELSEIF (bp.seq > 0)
           derivative_ind = "N"
          ENDIF
         HEAD pe.product_event_id
          IF (derivative_ind="Y"
           AND pe.event_type_cd=available_event_type_cd)
           add_available_ind = "N"
          ELSEIF (derivative_ind != "Y"
           AND pe.event_type_cd IN (assigned_event_type_cd, quarantined_event_type_cd,
          crossmatched_event_type_cd, issued_event_type_cd, transferred_event_type_cd,
          transfused_event_type_cd, unconfirmed_event_type_cd, autologous_event_type_cd,
          directed_event_type_cd, shipped_event_type_cd,
          in_progress_event_type_cd, available_event_type_cd, drawn_event_type_cd,
          tested_event_type_cd, in_transit_event_type_cd)
           AND (pe.product_event_id != request->productlist[prod].quarlist[quar].product_event_id))
           add_available_ind = "N"
          ENDIF
         WITH nocounter
        ;end select
        IF (curqual=0)
         SET reply->product_status[prod].status = "F"
         SET reply->product_status[prod].err_process = "update product_event/quarantine/derivative"
         SET reply->product_status[prod].err_message =
         "could not lock product/product_event/quarantine/derivative row for update"
        ELSE
         IF ((request->productlist[prod].quarlist[quar].release_qty > cur_quar_qty))
          SET reply->product_status[prod].status = "F"
          SET reply->product_status[prod].err_process = "update product_event/quarantine/derivative"
          SET reply->product_status[prod].err_message =
          "release_qty > cur_quar_qty--cannot release quarantine"
         ENDIF
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
      IF (derivative_ind="Y"
       AND ((cur_quar_qty - request->productlist[prod].quarlist[quar].release_qty) > 0))
       SET quar_active_status_cd = reqdata->active_status_cd
       SET quar_active_ind = 1
      ELSE
       SET quar_active_status_cd = reqdata->inactive_status_cd
       SET quar_active_ind = 0
      ENDIF
      SELECT INTO "nl:"
       pe.product_id
       FROM product_event pe
       PLAN (pe
        WHERE (pe.product_id=request->productlist[prod].product_id)
         AND (pe.product_event_id=request->productlist[prod].quarlist[quar].product_event_id)
         AND (pe.updt_cnt=request->productlist[prod].quarlist[quar].pe_updt_cnt))
       WITH nocounter, forupdate(pe)
      ;end select
      IF (curqual=0)
       SET reply->product_status[prod].status = "F"
       SET reply->product_status[prod].err_process = "lock product_event rows forupdate"
       SET reply->product_status[prod].err_message =
       "product_event rows could not be locked forupdate"
      ELSE
       CALL chg_product_event(request->productlist[prod].quarlist[quar].product_event_id,cnvtdatetime
        (curdate,curtime3),0,0,quar_active_ind,
        quar_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
        prod].quarlist[quar].pe_updt_cnt,0,
        0)
       SET reply->product_status[prod].quar_status[quar].product_event_status =
       gsub_product_event_status
       IF (gsub_product_event_status="FU")
        SET reply->product_status[prod].quar_status[quar].status = "F"
        SET reply->product_status[prod].quar_status[quar].err_process = "update product_event"
        SET reply->product_status[prod].quar_status[quar].err_message =
        "quarantine product_event row could not be inactivated"
       ELSEIF (gsub_product_event_status="OK")
        IF (derivative_ind="Y")
         SET new_quar_qty = (cur_quar_qty - request->productlist[prod].quarlist[quar].release_qty)
        ELSE
         SET new_quar_qty = null
        ENDIF
        SELECT INTO "nl:"
         qu.product_id
         FROM quarantine qu
         PLAN (qu
          WHERE (qu.product_id=request->productlist[prod].product_id)
           AND (qu.product_event_id=request->productlist[prod].quarlist[quar].product_event_id)
           AND (qu.updt_cnt=request->productlist[prod].quarlist[quar].qu_updt_cnt))
         WITH nocounter, forupdate(qu)
        ;end select
        IF (curqual=0)
         SET reply->product_status[prod].status = "F"
         SET reply->product_status[prod].err_process = "lock quarantine rows forupdate"
         SET reply->product_status[prod].err_message =
         "quarantine rows could not be locked forupdate"
        ELSE
         UPDATE  FROM quarantine qu
          SET qu.cur_quar_qty = new_quar_qty, qu.updt_cnt = (qu.updt_cnt+ 1), qu.updt_dt_tm =
           cnvtdatetime(curdate,curtime3),
           qu.updt_task = reqinfo->updt_task, qu.updt_id = reqinfo->updt_id, qu.updt_applctx =
           reqinfo->updt_applctx,
           qu.active_ind = quar_active_ind, qu.active_status_cd = quar_active_status_cd, qu
           .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
           qu.active_status_prsnl_id = reqinfo->updt_id, qu.cur_quar_intl_units = (new_quar_qty *
           luspervial)
          WHERE (qu.product_event_id=request->productlist[prod].quarlist[quar].product_event_id)
           AND (qu.updt_cnt=request->productlist[prod].quarlist[quar].qu_updt_cnt)
         ;end update
         IF (curqual=0)
          SET reply->product_status[prod].quar_status[quar].status = "F"
          SET reply->product_status[prod].quar_status[quar].err_process = "update quarantine"
          SET reply->product_status[prod].quar_status[quar].err_message =
          "quarantine row could not be released/inactivated"
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
          INSERT  FROM quarantine_release qr
           SET qr.quar_release_id = new_pathnet_seq, qr.product_event_id = request->productlist[prod]
            .quarlist[quar].product_event_id, qr.product_id = request->productlist[prod].product_id,
            qr.release_dt_tm = cnvtdatetime(request->event_dt_tm), qr.release_prsnl_id = request->
            event_prsnl_id, qr.release_qty =
            IF (derivative_ind="Y") request->productlist[prod].quarlist[quar].release_qty
            ELSE null
            ENDIF
            ,
            qr.release_reason_cd = request->productlist[prod].quarlist[quar].release_reason_cd, qr
            .updt_cnt = 0, qr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
            qr.updt_task = reqinfo->updt_task, qr.updt_id = reqinfo->updt_id, qr.updt_applctx =
            reqinfo->updt_applctx,
            qr.active_ind = 1, qr.active_status_cd = reqdata->active_status_cd, qr
            .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
            qr.active_status_prsnl_id = reqinfo->updt_id, qr.release_intl_units = (request->
            productlist[prod].quarlist[quar].release_qty * luspervial)
          ;end insert
          IF (curqual=0)
           SET reply->product_status[prod].quar_status[quar].status = "F"
           SET reply->product_status[prod].quar_status[quar].err_process =
           "add quarantine_release row"
           SET reply->product_status[prod].quar_status[quar].err_message =
           "quarantine_release row could not be added"
          ELSE
           IF (add_available_ind="Y")
            CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
             available_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
             0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
             reqinfo->updt_id)
            SET reply->product_status[prod].quar_status[quar].product_event_status =
            gsub_product_event_status
            IF (gsub_product_event_status="FS")
             SET reply->product_status[prod].quar_status[quar].status = "F"
             SET reply->product_status[prod].quar_status[quar].err_process = "add product_event"
             SET reply->product_status[prod].quar_status[quar].err_message =
             "get new product_event_id failed (seq) "
            ELSEIF (gsub_product_event_status="FA")
             SET reply->product_status[prod].quar_status[quar].status = "F"
             SET reply->product_status[prod].quar_status[quar].err_process = "add product_event"
             SET reply->product_status[prod].quar_status[quar].err_message =
             "available product_event row could not be added"
            ENDIF
           ENDIF
           IF (derivative_ind="Y"
            AND (reply->product_status[prod].quar_status[quar].status != "F"))
            SELECT INTO "nl:"
             drv.product_id
             FROM derivative drv
             PLAN (drv
              WHERE (drv.product_id=request->productlist[prod].product_id)
               AND drv.updt_cnt=new_drv_updt_cnt)
             DETAIL
              new_avail_qty = (drv.cur_avail_qty+ request->productlist[prod].quarlist[quar].
              release_qty)
             WITH nocounter, forupdate(drv)
            ;end select
            IF (curqual=0)
             SET reply->product_status[prod].status = "F"
             SET reply->product_status[prod].err_process = "lock derivative rows forupdate"
             SET reply->product_status[prod].err_message =
             "derivative rows could not be locked forupdate"
            ENDIF
            UPDATE  FROM derivative drv
             SET drv.cur_avail_qty = new_avail_qty, drv.cur_intl_units = (new_avail_qty * drv
              .units_per_vial), drv.updt_cnt = (drv.updt_cnt+ 1),
              drv.updt_dt_tm = cnvtdatetime(curdate,curtime3), drv.updt_task = reqinfo->updt_task,
              drv.updt_id = reqinfo->updt_id,
              drv.updt_applctx = reqinfo->updt_applctx
             WHERE (drv.product_id=request->productlist[prod].product_id)
              AND drv.updt_cnt=new_drv_updt_cnt
            ;end update
            IF (curqual=0)
             SET reply->product_status[prod].quar_status[quar].status = "F"
             SET reply->product_status[prod].quar_status[quar].err_process = "update derivative row"
             SET reply->product_status[prod].quar_status[quar].err_message = build(
              "derivative   row could not be added")
            ELSE
             SET new_drv_updt_cnt = (new_drv_updt_cnt+ 1)
            ENDIF
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
       "quarantine released--all rows updated/inactivated"
      ENDIF
     ENDIF
   ENDFOR
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
