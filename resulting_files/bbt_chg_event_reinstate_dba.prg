CREATE PROGRAM bbt_chg_event_reinstate:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 results[1]
     2 product_event_id = f8
     2 new_product_event_id = f8
     2 status = c1
     2 err_process = vc
     2 err_message = vc
 )
 DECLARE this_prod_id = f8 WITH protect, noconstant(0.0)
 DECLARE avail_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE assign_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE product_event_id = f8 WITH public, noconstant(0.0)
 DECLARE gsub_product_event_status = c2 WITH public, noconstant(fillstring(2," "))
 DECLARE sub_product_event_id = f8 WITH public, noconstant(0.0)
 DECLARE xmdttmchange = f8 WITH protect, noconstant(0.0)
 DECLARE statusflag = i2 WITH protect, noconstant(0)
 DECLARE success_cnt = i4 WITH protect, noconstant(0)
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET active_avail = "F"
 SET active_assign = "F"
 SET multiple_xm = "F"
 SET error_process = "                                      "
 SET error_message = "                                      "
 SET failure_occured = "F"
 SET quantity_val = 0
 SET pe_avail_updt_cnt = 0
 SET pe_assign_updt_cnt = 0
 SET assign_updt_cnt = 0
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
 RECORD temp_pe(
   1 order_id = f8
   1 bb_result_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 override_ind = i2
   1 override_reason_cd = f8
 )
 RECORD temp_xm(
   1 person_id = f8
   1 crossmatch_qty = i4
   1 bb_id_nbr = vc
   1 xm_reason_cd = f8
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
 SUBROUTINE (addproducttochangedproducts(productid=f8,dereservationdttm=dq8,reasoncd=f8,statusflag=i2
  ) =null)
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
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SET nbr_to_update = cnvtint(size(request->productlist,5))
 SET stat = alter(reply->results,nbr_to_update)
 SET stat = alter(reply->status_data.subeventstatus,nbr_to_update)
 SET uar_failed = 0
 SET avail_event_type_cd = 0.0
 SET xmtch_event_type_cd = 0.0
 SET assigned_event_type_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "1"
 SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,assigned_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "3"
 SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,xmtch_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "12"
 SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,avail_event_type_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
#skip_rest
 IF (uar_failed=1)
  SET reply->status_data.status = "F"
  SET error_process = "bbt_chg_event_reintstate"
  SET error_message = "code value not found"
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "reinstate"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset failed"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "F"
 ENDIF
 FOR (prod = 1 TO nbr_to_update)
   SET failure_occured = "F"
   SET active_avail = "F"
   SET active_assign = "F"
   SET this_prod_id = 0.0
   SET other_events = "F"
   SET avail_event_id = 0.0
   SET assign_event_id = 0.0
   SET pe_avail_updt_cnt = 0
   SET pe_assign_updt_cnt = 0
   SET assign_updt_cnt = 0
   SET temp_pe->order_id = 0.0
   SET temp_pe->bb_result_id = 0.0
   SET temp_pe->person_id = 0.0
   SET temp_pe->encntr_id = 0.0
   SET temp_pe->override_ind = 0
   SET temp_pe->override_reason_cd = 0.0
   SET temp_xm->person_id = 0.0
   SET temp_xm->crossmatch_qty = 0
   SET temp_xm->bb_id_nbr = ""
   SET temp_xm->xm_reason_cd = 0.0
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    WHERE pe.active_ind=1
     AND (pe.product_id=request->productlist[prod].product_id)
    DETAIL
     IF (pe.event_type_cd=avail_event_type_cd)
      active_avail = "T", avail_event_id = pe.product_event_id, pe_avail_updt_cnt = pe.updt_cnt
     ELSEIF (pe.event_type_cd=assigned_event_type_cd)
      active_assign = "T", assign_event_id = pe.product_event_id, pe_assign_updt_cnt = pe.updt_cnt
     ENDIF
    WITH counter
   ;end select
   IF (failure_occured="F")
    SELECT INTO "nl:"
     xm.product_id, xm.product_event_id
     FROM crossmatch xm
     WHERE (xm.product_event_id=request->productlist[prod].product_event_id)
      AND (xm.product_id=request->productlist[prod].product_id)
      AND (xm.updt_cnt=request->productlist[prod].xm_updt_cnt)
     DETAIL
      temp_xm->person_id = xm.person_id, temp_xm->crossmatch_qty = xm.crossmatch_qty, temp_xm->
      bb_id_nbr = xm.bb_id_nbr,
      temp_xm->xm_reason_cd = xm.xm_reason_cd
     WITH nocounter, forupdate(xm)
    ;end select
    IF (curqual=0)
     SET error_process = "bbt_chg_event_reintstate"
     SET error_message = "crossmatch not locked"
     SET failure_occured = "T"
     GO TO end_script
    ELSE
     SELECT INTO "nl:"
      pe.product_id, pe.product_event_id
      FROM product_event pe
      WHERE (pe.product_event_id=request->productlist[prod].product_event_id)
       AND (pe.product_id=request->productlist[prod].product_id)
       AND (pe.updt_cnt=request->productlist[prod].pe_xm_updt_cnt)
      DETAIL
       temp_pe->order_id = pe.order_id, temp_pe->bb_result_id = pe.bb_result_id, temp_pe->person_id
        = pe.person_id,
       temp_pe->encntr_id = pe.encntr_id, temp_pe->override_ind = pe.override_ind, temp_pe->
       override_reason_cd = pe.override_reason_cd
      WITH nocounter, forupdate(pe)
     ;end select
    ENDIF
    IF (curqual=0)
     SET error_process = "bbt_chg_event_reintstate"
     SET error_message = "product_event not locked"
     SET failure_occured = "T"
     GO TO end_script
    ELSE
     UPDATE  FROM crossmatch xm
      SET xm.active_ind = 0, xm.active_status_cd = reqdata->inactive_status_cd, xm.updt_cnt = (xm
       .updt_cnt+ 1),
       xm.updt_dt_tm = cnvtdatetime(sysdate), xm.updt_task = reqinfo->updt_task, xm.updt_id = reqinfo
       ->updt_id,
       xm.updt_applctx = reqinfo->updt_applctx
      PLAN (xm
       WHERE (xm.product_event_id=request->productlist[prod].product_event_id)
        AND (xm.product_id=request->productlist[prod].product_id)
        AND (xm.updt_cnt=request->productlist[prod].xm_updt_cnt))
      WITH counter
     ;end update
     SET serror_check = error(serrormsg,0)
     IF (nerrorstatus != 0)
      SET error_process = "bbt_chg_event_reintstate"
      SET error_message = "update crossmatch failed."
      SET failure_occured = "T"
     ENDIF
     UPDATE  FROM product_event pe
      SET pe.active_ind = 0, pe.active_status_cd = reqdata->inactive_status_cd, pe.updt_cnt = (pe
       .updt_cnt+ 1),
       pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_task = reqinfo->updt_task, pe.updt_id = reqinfo
       ->updt_id,
       pe.updt_applctx = reqinfo->updt_applctx
      PLAN (pe
       WHERE (pe.product_event_id=request->productlist[prod].product_event_id)
        AND (pe.product_id=request->productlist[prod].product_id)
        AND pe.event_type_cd=xmtch_event_type_cd
        AND (pe.updt_cnt=request->productlist[prod].pe_xm_updt_cnt))
      WITH counter
     ;end update
     SET serror_check = error(serrormsg,0)
     IF (nerrorstatus != 0)
      SET error_process = "bbt_chg_event_reintstate"
      SET error_message = "update crossmatch failed."
      SET failure_occured = "T"
     ENDIF
     CALL add_product_event(request->productlist[prod].product_id,temp_pe->person_id,temp_pe->
      encntr_id,temp_pe->order_id,temp_pe->bb_result_id,
      xmtch_event_type_cd,cnvtdatetime(sysdate),reqinfo->updt_id,0,temp_pe->override_ind,
      temp_pe->override_reason_cd,request->productlist[prod].product_event_id,1,reqdata->
      active_status_cd,cnvtdatetime(sysdate),
      reqinfo->updt_id)
     SET sub_product_event_id = product_event_id
     IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
      SET error_process = "bbt_chg_event_reintstate"
      IF (gsub_product_event_status="FS")
       SET error_message = "Generate product event id failed."
      ELSE
       SET error_message = "Insert product event failed."
      ENDIF
      SET failure_occured = "T"
     ELSE
      INSERT  FROM crossmatch xm
       SET xm.product_event_id = sub_product_event_id, xm.product_id = request->productlist[prod].
        product_id, xm.person_id = temp_xm->person_id,
        xm.crossmatch_qty = temp_xm->crossmatch_qty, xm.release_prsnl_id = 0, xm.release_reason_cd =
        0,
        xm.release_qty = 0, xm.updt_cnt = 0, xm.updt_dt_tm = cnvtdatetime(sysdate),
        xm.updt_task = reqinfo->updt_task, xm.updt_id = reqinfo->updt_id, xm.updt_applctx = reqinfo->
        updt_applctx,
        xm.active_ind = 1, xm.active_status_cd = reqdata->active_status_cd, xm.active_status_dt_tm =
        cnvtdatetime(sysdate),
        xm.active_status_prsnl_id = reqinfo->updt_id, xm.crossmatch_exp_dt_tm = cnvtdatetime(request
         ->productlist[prod].xm_exp_dt_tm), xm.reinstate_reason_cd = request->productlist[prod].
        reinstate_reason_cd,
        xm.bb_id_nbr = temp_xm->bb_id_nbr, xm.xm_reason_cd = temp_xm->xm_reason_cd
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_process = "bbt_chg_event_reintstate"
       SET error_message = "crossmatch not insert."
       SET failure_occured = "T"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (failure_occured="F"
    AND active_avail="T"
    AND avail_event_id > 0)
    UPDATE  FROM product_event pe
     SET pe.active_ind = 0, pe.active_status_cd = reqdata->inactive_status_cd, pe.updt_cnt = (pe
      .updt_cnt+ 1),
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_task = reqinfo->updt_task, pe.updt_id = reqinfo
      ->updt_id,
      pe.updt_applctx = reqinfo->updt_applctx
     PLAN (pe
      WHERE pe.product_event_id=avail_event_id
       AND (pe.product_id=request->productlist[prod].product_id)
       AND pe.event_type_cd=avail_event_type_cd
       AND pe.updt_cnt=pe_avail_updt_cnt)
     WITH counter
    ;end update
    IF (curqual=0)
     SET error_process = "bbt_chg_event_reintstate"
     SET error_message = "available product_event row not inactivated"
     SET failure_occured = "T"
    ENDIF
   ENDIF
   IF (failure_occured="F"
    AND active_assign="T"
    AND assign_event_id > 0)
    UPDATE  FROM product_event pe
     SET pe.active_ind = 0, pe.active_status_cd = reqdata->inactive_status_cd, pe.updt_cnt = (pe
      .updt_cnt+ 1),
      pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_task = reqinfo->updt_task, pe.updt_id = reqinfo
      ->updt_id,
      pe.updt_applctx = reqinfo->updt_applctx
     PLAN (pe
      WHERE pe.product_event_id=assign_event_id
       AND (pe.product_id=request->productlist[prod].product_id)
       AND pe.event_type_cd=assigned_event_type_cd
       AND pe.updt_cnt=pe_assign_updt_cnt)
     WITH counter
    ;end update
    IF (curqual=0)
     SET error_process = "bbt_chg_event_reintstate"
     SET error_message = "assign product_event row not inactivated"
     SET failure_occured = "T"
    ELSE
     UPDATE  FROM assign asg
      SET asg.active_ind = 1, asg.active_status_cd = reqdata->inactive_status_cd, asg.updt_cnt = (asg
       .updt_cnt+ 1),
       asg.updt_dt_tm = cnvtdatetime(sysdate), asg.updt_task = reqinfo->updt_task, asg.updt_id =
       reqinfo->updt_id,
       asg.updt_applctx = reqinfo->updt_applctx
      WHERE asg.product_event_id=assign_event_id
      WITH counter
     ;end update
     IF (curqual=0)
      SET error_process = "bbt_chg_event_reintstate"
      SET error_message = "available row not inactivated"
      SET failure_occured = "T"
     ENDIF
    ENDIF
   ENDIF
   IF ((request->more_processing_ind=0))
    SET this_prod_id = request->productlist[prod].product_id
    IF (prod < nbr_to_update)
     FOR (count1 = (prod+ 1) TO nbr_to_update)
       IF ((this_prod_id=request->productlist[count1].product_id))
        SET other_events = "T"
       ENDIF
     ENDFOR
    ENDIF
    IF (failure_occured="F"
     AND other_events="F")
     SELECT INTO "nl:"
      p.product_id
      FROM product p
      PLAN (p
       WHERE (p.product_id=request->productlist[prod].product_id)
        AND (p.updt_cnt=request->productlist[prod].p_updt_cnt)
        AND p.locked_ind=1)
      WITH nocounter, forupdate(p)
     ;end select
     IF (curqual=0)
      SET error_process = "bbt_chg_event_reintstate"
      SET error_message = "product not locked"
      SET failure_occured = "T"
     ELSE
      UPDATE  FROM product p
       SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
        p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
        updt_applctx
       PLAN (p
        WHERE (p.product_id=request->productlist[prod].product_id)
         AND (p.updt_cnt=request->productlist[prod].p_updt_cnt)
         AND p.locked_ind=1)
       WITH counter
      ;end update
      IF (curqual=0)
       SET error_process = "bbt_chg_event_reintstate"
       SET error_message = "product not updated to unlocked"
       SET failure_occured = "T"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (failure_occured="F")
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus[prod].operationname = "Complete"
    SET reply->status_data.subeventstatus[prod].operationstatus = "S"
    SET reply->status_data.subeventstatus[prod].targetobjectname = "Tables Updated"
    SET reply->status_data.subeventstatus[prod].targetobjectvalue = "S"
    IF ((request->more_processing_ind=0))
     COMMIT
    ENDIF
    SET reply->results[prod].product_event_id = request->productlist[prod].product_event_id
    SET reply->results[prod].new_product_event_id = sub_product_event_id
    SET reply->results[prod].status = "S"
    SET reply->results[prod].err_process = "complete"
    SET reply->results[prod].err_message = "no errors"
    SET statusflag = 0
    SET xmdttmchange = datetimediff(request->productlist[prod].xm_exp_dt_tm,cnvtdatetime(sysdate),5)
    IF (xmdttmchange <= 0)
     SET statusflag = 1
    ENDIF
    CALL echo(build("NO FAIL OCCURRED, ADD PROD TO LIST: ",request->productlist[prod].product_id))
    CALL addproducttochangedproducts(request->productlist[prod].product_id,request->productlist[prod]
     .xm_exp_dt_tm,request->productlist[prod].reinstate_reason_cd,statusflag)
    SET success_cnt += 1
   ELSE
    IF ((request->more_processing_ind=0))
     ROLLBACK
    ENDIF
    SET reply->status_data.subeventstatus[prod].operationname = error_process
    SET reply->status_data.subeventstatus[prod].operationstatus = "F"
    SET reply->status_data.subeventstatus[prod].targetobjectname = error_message
    SET reply->status_data.subeventstatus[prod].targetobjectvalue = "F"
    SET reply->results[prod].product_event_id = request->productlist[prod].product_event_id
    SET reply->results[prod].new_product_event_id = sub_product_event_id
    SET reply->results[prod].status = "F"
    SET reply->results[prod].err_process = error_process
    SET reply->results[prod].err_message = error_message
   ENDIF
 ENDFOR
 IF (success_cnt=0)
  SET reply->status_data.status = "F"
 ELSEIF (success_cnt < nbr_to_update)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL sendstatuschangemessage(null)
#end_script
 FREE RECORD temp_pe
 FREE RECORD temp_xm
END GO
