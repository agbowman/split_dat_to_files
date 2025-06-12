CREATE PROGRAM bbt_add_destruction:dba
 RECORD reply(
   1 product_status[*]
     2 product_id = f8
     2 eventlist[*]
       3 product_event_id = f8
     2 status = c1
     2 message = vc
     2 process_status[*]
       3 status = c1
       3 process = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET method_cd_hd = 0.0
 SET success_cnt = 0
 SET event_cnt = 0
 SET event = 0
 SET x = 0
 SET new_pathnet_seq = 0.0
 SET product_event_id = 0.0
 SET destroyed_product_event_id = 0.0
 SET destruction_active_ind = 0
 SET destruction_active_status_cd = 0.0
 SET destruction_event_dt_tm = cnvtdatetime(curdate,curtime3)
 SET destruction_event_status_flag = 0
 SET disposed_product_event_id = 0.0
 SET dispose_active_ind = 0
 SET dispose_active_status_cd = 0.0
 SET process_status_cnt = 0
 SET max_process_status_cnt = 0
 SET derivative_ind = " "
 SET cur_qty = 0
 SET new_cur_qty = 0
 SET new_active_status_cd = 0.0
 SET new_active_ind = 0
 SET new_drv_updt_cnt = 0
 DECLARE units_per_vial = i4 WITH protected, noconstant(0)
 DECLARE new_cur_intl_units = i4 WITH protected, noconstant(0)
 DECLARE product_state_code_set = i4
 SET product_state_code_set = 1610
 DECLARE assigned_cdf_meaning = c12
 SET assigned_cdf_meaning = "1"
 DECLARE crossmatched_cdf_meaning = c12
 SET crossmatched_cdf_meaning = "3"
 DECLARE in_progress_cdf_meaning = c12
 SET in_progress_cdf_meaning = "16"
 DECLARE quarantined_cdf_meaning = c12
 SET quarantined_cdf_meaning = "2"
 DECLARE autologous_cdf_meaning = c12
 SET autologous_cdf_meaning = "10"
 DECLARE directed_cdf_meaning = c12
 SET directed_cdf_meaning = "11"
 DECLARE available_cdf_meaning = c12
 SET available_cdf_meaning = "12"
 DECLARE unconfirmed_cdf_meaning = c12
 SET unconfirmed_cdf_meaning = "9"
 DECLARE disposed_cdf_meaning = c12
 SET disposed_cdf_meaning = "5"
 DECLARE destroyed_cdf_meaning = c12
 SET destroyed_cdf_meaning = "14"
 DECLARE destruction_method_code_set = i4
 SET destruction_method_code_set = 1609
 DECLARE dispense_cdf_meaning = c12
 SET dispense_cdf_meaning = "4"
 SET gsub_dummy = ""
 SET gsub_product_event_status = "  "
 SET gsub_status = " "
 SET gsub_process = fillstring(200," ")
 SET gsub_message = fillstring(200," ")
 SET gsub_active_status_cd = 0.0
 SET gsub_active_ind = 0
 SET gsub_derivative_ind = " "
 SET code_cnt = 1
 SET disposed_event_type_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(product_state_code_set,disposed_cdf_meaning,code_cnt,
  disposed_event_type_cd)
 IF (disposed_event_type_cd=0.0)
  SET gsub_status = "F"
  SET gsub_process = "get disposed event_type_cd"
  SET gsub_message = "could not retrieve disosed event_type_cd--code_set = 1610, cdf_meaning = 5"
 ELSE
  SET code_cnt = 1
  SET destroyed_event_type_cd = 0.0
  SET stat = uar_get_meaning_by_codeset(product_state_code_set,destroyed_cdf_meaning,code_cnt,
   destroyed_event_type_cd)
  IF (destroyed_event_type_cd=0.0)
   SET gsub_status = "F"
   SET gsub_process = "get destroyed event_type_cd"
   SET gsub_message = "could not retrieve destroyed event_type_cd--code_set = 1610, cdf_meaning = 14"
  ELSE
   SET code_cnt = 1
   SET assigned_event_type_cd = 0.0
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,assigned_cdf_meaning,code_cnt,
    assigned_event_type_cd)
   IF (assigned_event_type_cd=0.0)
    SET gsub_status = "F"
    SET gsub_process = "get assigned event_type_cd"
    SET gsub_message = "could not retrieve assigned event_type_cd--code_set = 1610, cdf_meaning = 1"
   ELSE
    SET code_cnt = 1
    SET crossmatched_event_type_cd = 0.0
    SET stat = uar_get_meaning_by_codeset(product_state_code_set,crossmatched_cdf_meaning,code_cnt,
     crossmatched_event_type_cd)
    IF (crossmatched_event_type_cd=0.0)
     SET gsub_status = "F"
     SET gsub_process = "get crossmatched event_type_cd"
     SET gsub_message =
     "could not retrieve crossmatched event_type_cd--code_set = 1610, cdf_meaning = 3"
    ELSE
     SET code_cnt = 1
     SET in_progress_event_type_cd = 0.0
     SET stat = uar_get_meaning_by_codeset(product_state_code_set,in_progress_cdf_meaning,code_cnt,
      in_progress_event_type_cd)
     IF (in_progress_event_type_cd=0.0)
      SET gsub_status = "F"
      SET gsub_process = "get in_progress event_type_cd"
      SET gsub_message =
      "could not retrieve in_progress event_type_cd--code_set = 1610, cdf_meaning = 16"
     ELSE
      SET code_cnt = 1
      SET quarantined_event_type_cd = 0.0
      SET stat = uar_get_meaning_by_codeset(product_state_code_set,quarantined_cdf_meaning,code_cnt,
       quarantined_event_type_cd)
      IF (quarantined_event_type_cd=0.0)
       SET gsub_status = "F"
       SET gsub_process = "get quarantine event_type_cd"
       SET gsub_message =
       "could not retrieve quarantined event_type_cd--code_set = 1610, cdf_meaning = 2"
      ELSE
       SET code_cnt = 1
       SET directed_event_type_cd = 0.0
       SET stat = uar_get_meaning_by_codeset(product_state_code_set,directed_cdf_meaning,code_cnt,
        directed_event_type_cd)
       IF (directed_event_type_cd=0.0)
        SET gsub_status = "F"
        SET gsub_process = "get directed event_type_cd"
        SET gsub_message =
        "could not retrieve directed event_type_cd--code_set = 1610, cdf_meaning = 11"
       ELSE
        SET code_cnt = 1
        SET autologous_event_type_cd = 0.0
        SET stat = uar_get_meaning_by_codeset(product_state_code_set,autologous_cdf_meaning,code_cnt,
         autologous_event_type_cd)
        IF (autologous_event_type_cd=0.0)
         SET gsub_status = "F"
         SET gsub_process = "get autologous event_type_cd"
         SET gsub_message =
         "could not retrieve autologous event_type_cd--code_set = 1610, cdf_meaning = 10"
        ELSE
         SET code_cnt = 1
         SET unconfirmed_event_type_cd = 0.0
         SET stat = uar_get_meaning_by_codeset(product_state_code_set,unconfirmed_cdf_meaning,
          code_cnt,unconfirmed_event_type_cd)
         IF (unconfirmed_event_type_cd=0.0)
          SET gsub_status = "F"
          SET gsub_process = "get unconfirmed event_type_cd"
          SET gsub_message =
          "could not retrieve unconfirmed event_type_cd--code_set = 1610, cdf_meaning = 9"
         ELSE
          SET code_cnt = 1
          SET available_event_type_cd = 0.0
          SET stat = uar_get_meaning_by_codeset(product_state_code_set,available_cdf_meaning,code_cnt,
           available_event_type_cd)
          IF (available_event_type_cd=0.0)
           SET gsub_status = "F"
           SET gsub_process = "get available event_type_cd"
           SET gsub_message =
           "could not retrieve available event_type_cd--code_set = 1610, cdf_meaning = 12"
          ELSE
           SET code_cnt = 1
           SET dispense_event_type_cd = 0.0
           SET stat = uar_get_meaning_by_codeset(product_state_code_set,dispense_cdf_meaning,code_cnt,
            dispense_event_type_cd)
           IF (dispense_event_type_cd=0.0)
            SET gsub_status = "F"
            SET gsub_process = "get dispense event_type_cd"
            SET gsub_message =
            "could not retrieve dispense event_type_cd--code_set = 1610, cdf_meaning = 4"
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (gsub_status > " ")
  SET reply->status_data.status = gsub_status
  SET count1 = (count1+ 1)
  SET stat = alterlist(reply->status_data.subeventstatus,count1)
  SET reply->status_data.subeventstatus[count1].operationname = gsub_process
  SET reply->status_data.subeventstatus[count1].operationstatus = gsub_status
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_destruction"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = gsub_message
 ELSE
  SET reply->status_data.status = "I"
 ENDIF
#begin_main
 SET prod_cnt = cnvtint(size(request->productlist,5))
 SET stat = alterlist(reply->product_status,prod_cnt)
 SET request->event_dt_tm = cnvtdatetime(curdate,curtime3)
 IF ((request->event_prsnl_id <= 0))
  SET request->event_prsnl_id = reqinfo->updt_id
 ENDIF
 FOR (prod = 1 TO prod_cnt)
   SET reply->product_status[prod].product_id = request->productlist[prod].product_id
   SET reply->product_status[prod].status = "I"
   SET process_status_cnt = 0
   SET event_cnt = cnvtint(size(request->productlist[prod].eventlist,5))
   IF (event_cnt < 1)
    SET event_cnt = 1
   ENDIF
   FREE SET internal
   RECORD internal(
     1 eventlist[*]
       2 product_event_id = f8
   )
   SET stat = alterlist(internal->eventlist,event_cnt)
   SET stat = alterlist(reply->product_status[prod].eventlist,event_cnt)
   IF ((reply->status_data.status != "F"))
    IF ((request->productlist[prod].method_cd != method_cd_hd))
     SET method_cd_hd = request->productlist[prod].method_cd
     SET method_cdf_meaning = fillstring(12," ")
     SET method_cdf_meaning = uar_get_code_meaning(request->productlist[prod].method_cd)
     IF (method_cdf_meaning="            ")
      CALL load_process_status("F","get destruction method cdf_meaning",
       "could not retrieve destruction method cdf_meaning")
     ENDIF
    ENDIF
    CALL process_product(gsub_dummy)
    IF ((reply->product_status[prod].status="F"))
     ROLLBACK
    ENDIF
   ENDIF
   CALL unlock_product(request->productlist[prod].product_id,request->productlist[prod].p_updt_cnt)
   IF (curqual=0)
    ROLLBACK
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
   ENDIF
   IF ((reply->product_status[prod].status != "F"))
    FOR (x = 1 TO event_cnt)
      SET reply->product_status[prod].eventlist[x].product_event_id = internal->eventlist[x].
      product_event_id
    ENDFOR
    COMMIT
    SET success_cnt = (success_cnt+ 1)
    SET reply->product_status[prod].status = "S"
    SET reply->product_status[prod].message = "Product disposed.  All associated data updated."
   ELSE
    ROLLBACK
    SET reply->product_status[prod].message = "Product NOT disposed.  NO associated data updated."
   ENDIF
 ENDFOR
 GO TO exit_script
#end_main
 SUBROUTINE process_product(sub_dummy)
   SET derivative_ind = " "
   CALL lock_product_forupdate(request->productlist[prod].product_id,1,request->productlist[prod].
    p_updt_cnt)
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ELSE
    SET derivative_ind = gsub_derivative_ind
   ENDIF
   IF (method_cdf_meaning="DESTLATR")
    SET dispose_active_ind = 1
    SET dispose_active_status_cd = reqdata->active_status_cd
    SET destruction_active_ind = 1
    SET destruction_active_status_cd = reqdata->active_status_cd
    SET destruction_event_dt_tm = null
    SET destruction_event_status_flag = 1
   ELSE
    SET dispose_active_ind = 0
    SET dispose_active_status_cd = reqdata->inactive_status_cd
    SET destruction_active_ind = 1
    SET destruction_active_status_cd = reqdata->active_status_cd
    SET destruction_event_dt_tm = cnvtdatetime(request->event_dt_tm)
    SET destruction_event_status_flag = 0
   ENDIF
   SET new_drv_updt_cnt = request->productlist[prod].drv_updt_cnt
   IF (event_cnt > 0)
    FOR (event = 1 TO event_cnt)
      IF ((request->productlist[prod].eventlist[event].product_event_id > 0))
       IF (((derivative_ind="Y") OR (derivative_ind != "Y"
        AND event=1)) )
        CALL process_dispose_destroy(gsub_dummy)
        IF ((reply->product_status[prod].status="F"))
         RETURN
        ENDIF
       ENDIF
       IF (((derivative_ind="Y") OR (derivative_ind != "Y"
        AND event=1)) )
        SET internal->eventlist[event].product_event_id = disposed_product_event_id
       ELSE
        SET internal->eventlist[event].product_event_id = 0
       ENDIF
       IF ((request->productlist[prod].eventlist[event].event_type_cd=assigned_event_type_cd))
        CALL release_assign(gsub_dummy)
       ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd=crossmatched_event_type_cd)
       )
        CALL release_crossmatch(gsub_dummy)
       ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd=in_progress_event_type_cd))
        CALL release_in_progress(gsub_dummy)
       ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd=quarantined_event_type_cd))
        CALL inactivate_quarantine(gsub_dummy)
       ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd=available_event_type_cd))
        CALL inactivate_available(gsub_dummy)
       ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd=dispense_event_type_cd))
        CALL inactivate_dispense(gsub_dummy)
       ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd=unconfirmed_event_type_cd))
        CALL inactivate_unconfirmed(gsub_dummy)
       ELSEIF ((request->productlist[prod].eventlist[event].event_type_cd !=
       unconfirmed_event_type_cd)
        AND (request->productlist[prod].eventlist[event].event_type_cd != autologous_event_type_cd)
        AND (request->productlist[prod].eventlist[event].event_type_cd != directed_event_type_cd))
        CALL load_process_status("F","release active product events/states",build(
          "invalid active product state for dispose/destroy--event_type_cd = ",request->productlist[
          prod].eventlist[event].event_type_cd))
       ENDIF
       IF ((reply->product_status[prod].status="F"))
        RETURN
       ENDIF
      ELSE
       IF (event=1)
        CALL process_dispose_destroy(gsub_dummy)
        SET internal->eventlist[0].product_event_id = disposed_product_event_id
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    CALL process_dispose_destroy(gsub_dummy)
    SET internal->eventlist[1].product_event_id = disposed_product_event_id
   ENDIF
 END ;Subroutine
 SUBROUTINE process_dispose_destroy(gsub_dummy2)
  CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
   disposed_event_type_cd,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,0,0,
   0,0,dispose_active_ind,dispose_active_status_cd,cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id)
  IF (gsub_product_event_status="FS")
   CALL load_process_status("F","add disposed product_event","get new product_event_id failed (seq)")
   RETURN
  ELSEIF (gsub_product_event_status="FA")
   CALL load_process_status("F","add disposed product_event",
    "disposed product_event row could not be added")
   RETURN
  ELSEIF (gsub_product_event_status="OK")
   SET disposed_product_event_id = product_event_id
   CALL add_dispose(disposed_product_event_id,request->productlist[prod].product_id,request->
    productlist[prod].reason_cd,request->productlist[prod].eventlist[event].select_qty,
    dispose_active_ind,
    dispose_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
   IF (curqual=0)
    CALL load_process_status(gsub_status,gsub_process,gsub_message)
    RETURN
   ENDIF
   CALL add_product_event(request->productlist[prod].product_id,0,0,0,0,
    destroyed_event_type_cd,cnvtdatetime(destruction_event_dt_tm),request->event_prsnl_id,
    destruction_event_status_flag,0,
    0,disposed_product_event_id,destruction_active_ind,destruction_active_status_cd,cnvtdatetime(
     curdate,curtime3),
    reqinfo->updt_id)
   IF (gsub_product_event_status="FS")
    CALL load_process_status("F","add destroyed product_event",
     "get new product_event_id failed (seq) ")
    RETURN
   ELSEIF (gsub_product_event_status="FA")
    CALL load_process_status("F","add destroyed product_event",
     "destroyed product_event row could not be added")
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    SET destroyed_product_event_id = product_event_id
    CALL add_destruction(destroyed_product_event_id,request->productlist[prod].product_id,request->
     productlist[prod].method_cd,method_cdf_meaning,request->productlist[prod].box_nbr,
     null,request->productlist[prod].eventlist[event].select_qty,request->productlist[prod].
     autoclave_ind,destruction_active_ind,destruction_active_status_cd,
     cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ENDIF
   ELSE
    CALL load_process_status("F","add destroyed product_event",build(
      "Script error!  Invalid product_event_status--",gsub_product_event_status))
    RETURN
   ENDIF
  ELSE
   CALL load_process_status("F","add disposed product_event",build(
     "Script error!  Invalid product_event_status--",gsub_product_event_status))
   RETURN
  ENDIF
 END ;Subroutine
 SUBROUTINE release_assign(sub_dummy2)
   SET derivative_ind = " "
   SET cur_qty = 0
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    a.product_event_id
    FROM assign a
    PLAN (a
     WHERE (a.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (a.updt_cnt=request->productlist[prod].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(a)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock assign forupdate","assign rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    pe.product_event_id, a.product_event_id, a.cur_assign_qty,
    drv.seq, drv.product_id, bp.product_id
    FROM product_event pe,
     assign a,
     (dummyt d_drv_bp  WITH seq = 1),
     derivative drv,
     blood_product bp
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
     JOIN (a
     WHERE a.product_event_id=pe.product_event_id
      AND (a.updt_cnt=request->productlist[prod].eventlist[event].pe_child_updt_cnt))
     JOIN (d_drv_bp
     WHERE d_drv_bp.seq=1)
     JOIN (((drv
     WHERE drv.product_id=pe.product_id
      AND drv.updt_cnt=new_drv_updt_cnt)
     ) ORJOIN ((bp
     WHERE bp.product_id=pe.product_id)
     ))
    DETAIL
     IF (drv.seq > 0)
      derivative_ind = "Y", cur_qty = a.cur_assign_qty, units_per_vial = drv.units_per_vial
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","select product_event/assign forupdate",
     "product_event and assign rows could not be retrieved")
    RETURN
   ENDIF
   IF (derivative_ind="Y")
    SELECT INTO "nl:"
     drv.seq
     FROM derivative drv
     PLAN (drv
      WHERE (drv.product_id=request->productlist[prod].product_id)
       AND drv.updt_cnt=new_drv_updt_cnt)
     WITH nocounter, forupdate(drv)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","select derivative forupdate",
      "derivative rows could not be retrieved")
     RETURN
    ENDIF
   ENDIF
   CALL set_new_active_status(derivative_ind,cur_qty,request->productlist[prod].eventlist[event].
    select_qty,units_per_vial)
   IF (gsub_status="F")
    CALL load_process_status("F","release assign",
     "selected release quantity > assigned quantity--cannot release assign")
    RETURN
   ELSE
    SET new_active_status_cd = gsub_active_status_cd
    SET new_active_ind = gsub_active_ind
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,
    new_active_ind,
    new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[prod].
    eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Release active assign product_event row",build(
      "Assign product_event row could not be released--product_event_id:",request->productlist[prod].
      eventlist[event].product_event_id))
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    CALL chg_assign(request->productlist[prod].eventlist[event].product_event_id,new_cur_qty,request
     ->productlist[prod].eventlist[event].pe_child_updt_cnt,new_cur_intl_units,new_active_ind,
     new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,derivative_ind)
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ELSE
     CALL add_assign_release(request->productlist[prod].eventlist[event].product_event_id,request->
      productlist[prod].product_id,cnvtdatetime(request->event_dt_tm),request->event_prsnl_id,request
      ->productlist[prod].release_reason_cd,
      request->productlist[prod].eventlist[event].select_qty,derivative_ind)
     IF (curqual=0)
      CALL load_process_status(gsub_status,gsub_process,gsub_message)
      RETURN
     ENDIF
    ENDIF
   ELSE
    CALL load_process_status("F","inactivate assigned product_event",build(
      "Script error!  Invalid product_event_status--",gsub_product_event_status))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_assign(sub_product_event_id,sub_new_cur_qty,sub_updt_cnt,sub_cur_intl_units,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,
  sub_derivative_ind)
  UPDATE  FROM assign a
   SET a.cur_assign_qty =
    IF (sub_derivative_ind="Y") sub_new_cur_qty
    ELSE 0
    ENDIF
    , a.cur_assign_intl_units =
    IF (sub_derivative_ind="Y") sub_cur_intl_units
    ELSE 0
    ENDIF
    , a.active_ind = sub_active_ind,
    a.active_status_cd = sub_active_status_cd, a.active_status_dt_tm = cnvtdatetime(
     sub_active_status_dt_tm), a.active_status_prsnl_id = sub_active_status_prsnl_id,
    a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_task =
    reqinfo->updt_task,
    a.updt_id = reqinfo->updt_id, a.updt_applctx = reqinfo->updt_applctx
   WHERE a.product_event_id=sub_product_event_id
    AND a.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "release/inactivate assign row"
   SET gsub_message = "assign row could not be released/inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE add_assign_release(sub_product_event_id,sub_product_id,sub_release_dt_tm,
  sub_release_prsnl_id,sub_release_reason_cd,sub_release_qty,sub_derivative_ind)
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
    SET gsub_status = "F"
    SET gsub_process = "add_assign_release"
    SET gsub_message = "get pathnet seq failed for assign_release_id"
   ELSE
    INSERT  FROM assign_release ar
     SET ar.assign_release_id = new_pathnet_seq, ar.product_event_id = sub_product_event_id, ar
      .product_id = sub_product_id,
      ar.release_dt_tm = cnvtdatetime(sub_release_dt_tm), ar.release_prsnl_id = sub_release_prsnl_id,
      ar.release_reason_cd = sub_release_reason_cd,
      ar.release_qty =
      IF (sub_derivative_ind="Y") sub_release_qty
      ELSE 0
      ENDIF
      , ar.updt_cnt = 0, ar.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ar.updt_task = reqinfo->updt_task, ar.updt_id = reqinfo->updt_id, ar.updt_applctx = reqinfo->
      updt_applctx,
      ar.active_ind = 1, ar.active_status_cd = reqdata->active_status_cd, ar.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ar.active_status_prsnl_id = reqinfo->updt_id
    ;end insert
    IF (curqual=0)
     SET gsub_status = "F"
     SET gsub_process = "add_assign_release"
     SET gsub_message = "could not add assign_release row"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE release_crossmatch(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    xm.product_event_id
    FROM crossmatch xm
    PLAN (xm
     WHERE (xm.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (xm.updt_cnt=request->productlist[prod].eventlist[event].pe_child_updt_cnt))
    WITH nocounter, forupdate(xm)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock crossmatch forupdate",
     "crossmatch rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
    prod].eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Release active crossmatch product_event row",build(
      "Crossmatch product_event row could not be released--product_event_id:",internal->eventlist[
      event].product_event_id))
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    CALL chg_crossmatch(request->productlist[prod].eventlist[event].product_event_id,request->
     productlist[prod].eventlist[event].pe_child_updt_cnt,cnvtdatetime(request->event_dt_tm),request
     ->event_prsnl_id,request->productlist[prod].release_reason_cd,
     request->productlist[prod].eventlist[event].select_qty,0,reqdata->inactive_status_cd,
     cnvtdatetime(curdate,curtime3),reqinfo->updt_id)
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ENDIF
   ELSE
    CALL load_process_status("F","inactivate crossmatched product_event",build(
      "Script error!  Invalid product_event_status--",gsub_product_event_status))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_crossmatch(sub_product_event_id,sub_updt_cnt,sub_release_dt_tm,sub_release_prsnl_id,
  sub_release_reason_cd,sub_release_qty,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id)
  UPDATE  FROM crossmatch xm
   SET xm.release_dt_tm = cnvtdatetime(sub_release_dt_tm), xm.release_prsnl_id = sub_release_prsnl_id,
    xm.release_reason_cd = sub_release_reason_cd,
    xm.release_qty = sub_release_qty, xm.active_ind = sub_active_ind, xm.active_status_cd =
    sub_active_status_cd,
    xm.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), xm.active_status_prsnl_id =
    sub_active_status_prsnl_id, xm.updt_cnt = (xm.updt_cnt+ 1),
    xm.updt_dt_tm = cnvtdatetime(curdate,curtime3), xm.updt_task = reqinfo->updt_task, xm.updt_id =
    reqinfo->updt_id,
    xm.updt_applctx = reqinfo->updt_applctx
   WHERE xm.product_event_id=sub_product_event_id
    AND xm.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "release/inactivate crossmatch row"
   SET gsub_message = "crossmatch row could not be released/inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE release_in_progress(sub_dummy2)
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock in_progress product_event forupdate",
     "in_progress product_event row could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
    prod].eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate active in_progress product_event row",build(
      "In_progress product_event row could not be inactivated--product_event_id:",internal->
      eventlist[event].product_event_id))
    RETURN
   ELSE
    IF (gsub_product_event_status != "OK")
     CALL load_process_status("F","inactivate in_progress product_event",build(
       "Script error!  Invalid product_event_status--",gsub_product_event_status))
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_quarantine(sub_dummy2)
   SET derivative_ind = " "
   SET cur_qty = 0
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    pe.product_event_id, qu.product_event_id, qu.cur_quar_qty,
    drv.seq, drv.product_id, bp.product_id
    FROM product_event pe,
     quarantine qu,
     (dummyt d_drv_bp  WITH seq = 1),
     derivative drv,
     blood_product bp
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
     JOIN (qu
     WHERE qu.product_event_id=pe.product_event_id
      AND (qu.updt_cnt=request->productlist[prod].eventlist[event].pe_child_updt_cnt))
     JOIN (d_drv_bp
     WHERE d_drv_bp.seq=1)
     JOIN (((drv
     WHERE drv.product_id=pe.product_id
      AND drv.updt_cnt=new_drv_updt_cnt)
     ) ORJOIN ((bp
     WHERE bp.product_id=pe.product_id)
     ))
    DETAIL
     IF (drv.seq > 0)
      derivative_ind = "Y", cur_qty = qu.cur_quar_qty, units_per_vial = drv.units_per_vial
     ENDIF
    WITH nocounter
   ;end select
   IF (derivative_ind="Y")
    SELECT INTO "nl:"
     drv.seq, drv.product_id
     FROM derivative drv
     PLAN (drv
      WHERE (drv.product_id=request->productlist[prod].product_id)
       AND drv.updt_cnt=new_drv_updt_cnt)
     WITH nocounter, forupdate(drv)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","lock derivative forupdate",
      "derivative rows could not be locked forupdate")
     RETURN
    ENDIF
   ENDIF
   CALL set_new_active_status(derivative_ind,cur_qty,request->productlist[prod].eventlist[event].
    select_qty,units_per_vial)
   IF (gsub_status="F")
    CALL load_process_status("F","release quarantine",
     "selected release quantity > quarantined quantity--cannot release quarantine")
    RETURN
   ELSE
    SET new_active_status_cd = gsub_active_status_cd
    SET new_active_ind = gsub_active_ind
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,
    new_active_ind,
    new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[prod].
    eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Release active quarantine product_event row",build(
      "Quarantine product_event row could not be released--product_event_id:",request->productlist[
      prod].eventlist[event].product_event_id))
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    CALL chg_quarantine(request->productlist[prod].eventlist[event].product_event_id,new_cur_qty,
     request->productlist[prod].eventlist[event].pe_child_updt_cnt,new_cur_intl_units,new_active_ind,
     new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,derivative_ind)
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ENDIF
   ELSE
    CALL load_process_status("F","inactivate quarantined product_event",build(
      "Script error!  Invalid product_event_status--",gsub_product_event_status))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_quarantine(sub_product_event_id,sub_cur_quar_qty,sub_updt_cnt,sub_cur_intl_units,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,
  sub_derivative_ind)
  UPDATE  FROM quarantine qu
   SET qu.cur_quar_qty =
    IF (sub_derivative_ind="Y") sub_cur_quar_qty
    ELSE 0
    ENDIF
    , qu.cur_quar_intl_units =
    IF (sub_derivative_ind="Y") sub_cur_intl_units
    ELSE 0
    ENDIF
    , qu.updt_cnt = (qu.updt_cnt+ 1),
    qu.updt_dt_tm = cnvtdatetime(curdate,curtime3), qu.updt_task = reqinfo->updt_task, qu.updt_id =
    reqinfo->updt_id,
    qu.updt_applctx = reqinfo->updt_applctx, qu.active_ind = sub_active_ind, qu.active_status_cd =
    sub_active_status_cd,
    qu.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), qu.active_status_prsnl_id =
    sub_active_status_prsnl_id
   WHERE qu.product_event_id=sub_product_event_id
    AND qu.updt_cnt=sub_updt_cnt
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate quarantine row"
   SET gsub_message = "quarantine row could not be inactivated"
  ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_available(sub_dummy2)
   SET derivative_ind = " "
   SET cur_qty = 0
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    pe.product_event_id, drv.seq, drv.cur_avail_qty,
    drv.product_id, bp.product_id
    FROM product_event pe,
     (dummyt d_drv_bp  WITH seq = 1),
     derivative drv,
     blood_product bp
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
     JOIN (d_drv_bp
     WHERE d_drv_bp.seq=1)
     JOIN (((drv
     WHERE drv.product_id=pe.product_id
      AND drv.updt_cnt=new_drv_updt_cnt)
     ) ORJOIN ((bp
     WHERE bp.product_id=pe.product_id)
     ))
    DETAIL
     IF (drv.seq > 0)
      derivative_ind = "Y", cur_qty = drv.cur_avail_qty, units_per_vial = drv.units_per_vial
     ENDIF
    WITH nocounter
   ;end select
   IF (derivative_ind="Y")
    SELECT INTO "nl:"
     drv.seq, drv.product_id
     FROM derivative drv
     PLAN (drv
      WHERE (drv.product_id=request->productlist[prod].product_id)
       AND drv.updt_cnt=new_drv_updt_cnt)
     WITH nocounter, forupdate(drv)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","lock derivative forupdate",
      "derivative rows could not be locked forupdate")
     RETURN
    ENDIF
   ENDIF
   CALL set_new_active_status(derivative_ind,cur_qty,request->productlist[prod].eventlist[event].
    select_qty,units_per_vial)
   IF (gsub_status="F")
    CALL load_process_status("F","inactivate available product_event",
     "selected quantity > available quantity--cannot inactivate available product_event")
    RETURN
   ELSE
    SET new_active_status_cd = gsub_active_status_cd
    SET new_active_ind = gsub_active_ind
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,
    new_active_ind,
    new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[prod].
    eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate active available product_event row",build(
      "Available product_event row could not be inactivated--product_event_id:",internal->eventlist[
      event].product_event_id))
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    IF (derivative_ind="Y")
     CALL chg_derivative(request->productlist[prod].product_id,new_cur_qty,new_drv_updt_cnt,
      new_cur_intl_units)
     IF (curqual=0)
      CALL load_process_status(gsub_status,gsub_process,gsub_message)
      RETURN
     ENDIF
    ENDIF
   ELSE
    CALL load_process_status("F","inactivate available product_event",build(
      "Script error!  Invalid product_event_status--",gsub_product_event_status))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_derivative(sub_product_id,sub_cur_avail_qty,sub_updt_cnt,sub_cur_intl_units)
  UPDATE  FROM derivative drv
   SET drv.cur_avail_qty = sub_cur_avail_qty, drv.updt_cnt = (drv.updt_cnt+ 1), drv.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    drv.updt_task = reqinfo->updt_task, drv.updt_id = reqinfo->updt_id, drv.updt_applctx = reqinfo->
    updt_applctx,
    drv.cur_intl_units = sub_cur_intl_units
   WHERE drv.product_id=sub_product_id
    AND drv.updt_cnt=sub_updt_cnt
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "update derivative row"
   SET gsub_message = "derivative current available quantity could not be updated"
  ELSE
   SET new_drv_updt_cnt = (new_drv_updt_cnt+ 1)
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
    CALL load_process_status("F","lock unconfirmed product_event forupdate",
     "unconfirmed product_event row could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
    prod].eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate active unconfirmed product_event row",build(
      "Unconfirmed product_event row could not be inactivated--product_event_id:",internal->
      eventlist[event].product_event_id))
    RETURN
   ELSE
    IF (gsub_product_event_status != "OK")
     CALL load_process_status("F","inactivate unconfirmed product_event",build(
       "Script error!  Invalid product_event_status--",gsub_product_event_status))
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_dispense(sub_dummy2)
   SET derivative_ind = " "
   SET cur_qty = 0
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
    WITH nocounter, forupdate(pe)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock dispense product_event forupdate",
     "dispense product_event row could not be locked forupdate")
    RETURN
   ENDIF
   SELECT INTO "nl:"
    pe.product_event_id, pd.product_event_id, pd.cur_dispense_qty,
    drv.seq, drv.product_id, bp.product_id
    FROM product_event pe,
     patient_dispense pd,
     (dummyt d_drv_bp  WITH seq = 1),
     derivative drv,
     blood_product bp
    PLAN (pe
     WHERE (pe.product_event_id=request->productlist[prod].eventlist[event].product_event_id)
      AND (pe.updt_cnt=request->productlist[prod].eventlist[event].pe_updt_cnt))
     JOIN (pd
     WHERE pd.product_event_id=pe.product_event_id
      AND (pd.updt_cnt=request->productlist[prod].eventlist[event].pe_child_updt_cnt))
     JOIN (d_drv_bp
     WHERE d_drv_bp.seq=1)
     JOIN (((drv
     WHERE drv.product_id=pe.product_id
      AND drv.updt_cnt=new_drv_updt_cnt)
     ) ORJOIN ((bp
     WHERE bp.product_id=pe.product_id)
     ))
    DETAIL
     IF (drv.seq > 0)
      derivative_ind = "Y", cur_qty = pd.cur_dispense_qty, units_per_vial = drv.units_per_vial
     ENDIF
    WITH nocounter
   ;end select
   IF (derivative_ind="Y")
    SELECT INTO "nl:"
     drv.seq, drv.product_id
     FROM derivative drv
     PLAN (drv
      WHERE (drv.product_id=request->productlist[prod].product_id)
       AND drv.updt_cnt=new_drv_updt_cnt)
     WITH nocounter, forupdate(drv)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","lock derivative forupdate",
      "derivative rows could not be locked forupdate")
     RETURN
    ENDIF
   ENDIF
   CALL set_new_active_status(derivative_ind,cur_qty,request->productlist[prod].eventlist[event].
    select_qty,units_per_vial)
   IF (gsub_status="F")
    CALL load_process_status("F","inactivate dispense product_event",
     "selected quantity > dispense quantity--cannot inactivate dispense product_event")
    RETURN
   ELSE
    SET new_active_status_cd = gsub_active_status_cd
    SET new_active_ind = gsub_active_ind
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,
    new_active_ind,
    new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[prod].
    eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate active dispense product_event row",build(
      "Dispense product_event row could not be inactivated--product_event_id:",internal->eventlist[
      event].product_event_id))
    RETURN
   ELSEIF (gsub_product_event_status="OK")
    CALL chg_patient_dispense(request->productlist[prod].eventlist[event].product_event_id,
     new_cur_qty,request->productlist[prod].eventlist[event].pe_child_updt_cnt,new_cur_intl_units,
     new_active_ind,
     new_active_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,derivative_ind)
    IF (curqual=0)
     CALL load_process_status(gsub_status,gsub_process,gsub_message)
     RETURN
    ENDIF
   ELSE
    CALL load_process_status("F","inactivate dispense product_event",build(
      "Script error!  Invalid product_event_status--",gsub_product_event_status))
    RETURN
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
    CALL load_process_status("F","lock product_event forupdate",
     "product_event rows could not be locked forupdate")
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
    CALL load_process_status("F","lock auto_directed product_event forupdate",
     "auto_directed rows could not be locked forupdate")
    RETURN
   ENDIF
   CALL chg_product_event(request->productlist[prod].eventlist[event].product_event_id,0,0,0,0,
    reqdata->inactive_status_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,request->productlist[
    prod].eventlist[event].pe_updt_cnt,0,
    0)
   IF (gsub_product_event_status="FU")
    CALL load_process_status("F","Inactivate active auto_directed product_event row",build(
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
 SUBROUTINE unlock_product(sub_product_id,sub_updt_cnt)
  UPDATE  FROM product p
   SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx,
    p.interfaced_device_flag =
    IF ((reply->product_status[prod].status="F")) p.interfaced_device_flag
    ELSE 0
    ENDIF
   WHERE p.product_id=sub_product_id
    AND p.updt_cnt=sub_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "unlock product row"
   SET gsub_message = "product row could not be unlocked"
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
 SUBROUTINE lock_product_forupdate(sub_product_id,sub_locked_ind,sub_updt_cnt)
   SET gsub_derivative_ind = " "
   SELECT INTO "nl:"
    p.product_id
    FROM product p
    PLAN (p
     WHERE p.product_id=sub_product_id
      AND p.updt_cnt=sub_updt_cnt)
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "lock product row forupdate"
    SET gsub_message = "product row could not be locked for update"
   ENDIF
   SELECT INTO "nl:"
    p.product_id, drv.product_id, bp.product_id
    FROM product p,
     (dummyt d_drv_bp  WITH seq = 1),
     derivative drv,
     blood_product bp
    PLAN (p
     WHERE p.product_id=sub_product_id
      AND p.updt_cnt=sub_updt_cnt)
     JOIN (d_drv_bp
     WHERE d_drv_bp.seq=1)
     JOIN (((drv
     WHERE drv.product_id=p.product_id
      AND (drv.updt_cnt=request->productlist[prod].drv_updt_cnt))
     ) ORJOIN ((bp
     WHERE bp.product_id=p.product_id)
     ))
    DETAIL
     IF (drv.seq > 0)
      gsub_derivative_ind = "Y"
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "select product row forupdate"
    SET gsub_message = "product row could not be selected for update"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_dispose(sub_product_event_id,sub_product_id,sub_reason_cd,sub_disposed_qty,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
  INSERT  FROM disposition dsp
   SET dsp.product_event_id = sub_product_event_id, dsp.product_id = sub_product_id, dsp.reason_cd =
    sub_reason_cd,
    dsp.disposed_qty = sub_disposed_qty, dsp.active_ind = sub_active_ind, dsp.active_status_cd =
    sub_active_status_cd,
    dsp.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), dsp.active_status_prsnl_id =
    sub_active_status_prsnl_id, dsp.updt_cnt = 0,
    dsp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsp.updt_id = reqinfo->updt_id, dsp.updt_task =
    reqinfo->updt_task,
    dsp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "create dispose row"
   SET gsub_message = "dispose row could not be created"
  ENDIF
 END ;Subroutine
 SUBROUTINE add_destruction(sub_product_event_id,sub_product_id,sub_method_cd,sub_method_cdf_meaning,
  sub_box_nbr,sub_manifest_nbr,sub_destroyed_qty,sub_autoclave_ind,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
  INSERT  FROM destruction dst
   SET dst.product_event_id = sub_product_event_id, dst.product_id = sub_product_id, dst.method_cd =
    sub_method_cd,
    dst.box_nbr = trim(cnvtupper(sub_box_nbr)), dst.manifest_nbr = sub_manifest_nbr, dst
    .destroyed_qty = sub_destroyed_qty,
    dst.autoclave_ind =
    IF (sub_method_cdf_meaning="DESTNOW") sub_autoclave_ind
    ELSE 0
    ENDIF
    , dst.destruction_org_id = 0, dst.active_ind = sub_active_ind,
    dst.active_status_cd = sub_active_status_cd, dst.active_status_dt_tm = cnvtdatetime(
     sub_active_status_dt_tm), dst.active_status_prsnl_id = sub_active_status_prsnl_id,
    dst.updt_cnt = 0, dst.updt_dt_tm = cnvtdatetime(curdate,curtime3), dst.updt_id = reqinfo->updt_id,
    dst.updt_task = reqinfo->updt_task, dst.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "create destruction row"
   SET gsub_message = "destruction row could not be created"
  ENDIF
 END ;Subroutine
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->product_status[prod].status = "F"
   SET process_status_cnt = (process_status_cnt+ 1)
   IF (process_status_cnt > max_process_status_cnt)
    SET max_process_status_cnt = process_status_cnt
    SET stat = alterlist(reply->product_status.process_status,max_process_status_cnt)
   ENDIF
   SET reply->product_status[prod].process_status[process_status_cnt].status = sub_status
   SET reply->product_status[prod].process_status[process_status_cnt].process = sub_process
   SET reply->product_status[prod].process_status[process_status_cnt].message = sub_message
 END ;Subroutine
 SUBROUTINE set_new_active_status(sub_derivative_ind,sub_cur_qty,sub_select_qty,sub_units_per_vail)
   SET gsub_status = "F"
   SET new_cur_qty = 0
   SET gsub_active_status_cd = reqdata->inactive_status_cd
   SET gsub_active_ind = 0
   SET new_cur_intl_units = 0
   IF (sub_derivative_ind="Y")
    IF (sub_select_qty > sub_cur_qty)
     SET gsub_status = "F"
    ELSE
     SET gsub_status = "S"
     SET new_cur_qty = (sub_cur_qty - sub_select_qty)
     SET new_cur_intl_units = (new_cur_qty * sub_units_per_vail)
     IF (new_cur_qty > 0)
      SET gsub_active_status_cd = reqdata->active_status_cd
      SET gsub_active_ind = 1
     ENDIF
    ENDIF
   ELSE
    SET gsub_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_patient_dispense(sub_product_event_id,sub_cur_dispense_qty,sub_updt_cnt,
  sub_cur_intl_units,sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,
  sub_active_status_prsnl_id,sub_derivative_ind)
  UPDATE  FROM patient_dispense pd
   SET pd.cur_dispense_qty =
    IF (sub_derivative_ind="Y") sub_cur_dispense_qty
    ELSE 0
    ENDIF
    , pd.cur_dispense_intl_units =
    IF (sub_derivative_ind="Y") sub_cur_intl_units
    ELSE 0
    ENDIF
    , pd.updt_cnt = (pd.updt_cnt+ 1),
    pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_task = reqinfo->updt_task, pd.updt_id =
    reqinfo->updt_id,
    pd.updt_applctx = reqinfo->updt_applctx, pd.active_ind = sub_active_ind, pd.active_status_cd =
    sub_active_status_cd,
    pd.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pd.active_status_prsnl_id =
    sub_active_status_prsnl_id
   WHERE pd.product_event_id=sub_product_event_id
    AND pd.updt_cnt=sub_updt_cnt
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate dispense row"
   SET gsub_message = "dispense row could not be inactivated"
  ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "F"))
  IF (success_cnt > 0)
   SET reqinfo->commit_ind = 1
   IF (success_cnt=prod_cnt)
    SET reply->status_data[1].status = "S"
   ELSE
    SET reply->status_data[1].status = "P"
   ENDIF
  ELSE
   SET reply->status_data[1].status = "Z"
  ENDIF
 ENDIF
 CALL echo(build("assigned     :",assigned_event_type_cd))
 CALL echo(build("crossmatched :",crossmatched_event_type_cd))
 CALL echo(build("in_progress  :",in_progress_event_type_cd))
 CALL echo(build("quarantined  :",quarantined_event_type_cd))
 CALL echo(build("autologous   :",autologous_event_type_cd))
 CALL echo(build("directed     :",directed_event_type_cd))
 CALL echo(build("available    :",available_event_type_cd))
 CALL echo(build("unconfirmed  :",unconfirmed_event_type_cd))
 CALL echo(build("disposed     :",disposed_event_type_cd))
 CALL echo(build("destroyed    :",destroyed_event_type_cd))
 FOR (prod = 1 TO prod_cnt)
   CALL echo("     ")
   CALL echo(build("product_id     =",reply->product_status[prod].product_id))
   FOR (x = 1 TO size(reply->product_status[prod].eventlist,5))
     CALL echo(build(".....",reply->product_status[prod].eventlist[x].product_event_id))
   ENDFOR
   CALL echo(build("status         =",reply->product_status[prod].status))
   CALL echo(build("message        =",reply->product_status[prod].message))
   CALL echo("    ")
   FOR (process_status_cnt = 1 TO max_process_status_cnt)
     CALL echo(build("status  =",reply->product_status[prod].process_status[process_status_cnt].
       status))
     CALL echo(build("process =",reply->product_status[prod].process_status[process_status_cnt].
       process))
     CALL echo(build("message =",reply->product_status[prod].process_status[process_status_cnt].
       message))
   ENDFOR
 ENDFOR
END GO
