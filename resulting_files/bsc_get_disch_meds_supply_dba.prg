CREATE PROGRAM bsc_get_disch_meds_supply:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 supplylocations[*]
     2 pharm_supply_loc_cd = f8
     2 pharm_supply_loc_disp = vc
     2 pharm_supply_loc_mean = vc
     2 orders[*]
       3 order_id = f8
       3 action_seq = i4
   1 orders[*]
     2 order_id = f8
     2 action_seq = i4
     2 iv_ind = i2
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 order_detail_disp_line = vc
     2 order_comment = vc
     2 order_status_cd = f8
     2 order_status_display = vc
     2 order_status_updt_dt_tm = dq8
     2 order_endstate_ind = i2
     2 pharmacy_comment = vc
     2 order_supply_review_id = f8
     2 duration_val = vc
     2 duration_unit = vc
     2 supplylocations[*]
       3 pharm_supply_loc_cd = f8
       3 location_display = vc
       3 pharm_supply_loc_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 FREE RECORD temporderdata
 RECORD temporderdata(
   1 qual[*]
     2 order_id = f8
     2 action_seq = i4
     2 iv_ind = i2
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 order_detail_disp_line = vc
     2 order_comment = vc
     2 order_status_cd = f8
     2 order_status_display = vc
     2 order_status_updt_dt_tm = dq8
     2 pharmacy_comment = vc
     2 pharm_review_ind = i2
     2 order_endstate_ind = i2
     2 order_supply_review_id = f8
     2 duration_val = vc
     2 duration_unit = vc
     2 order_supply[*]
       3 location_list[*]
         4 location_cd = f8
         4 location_display = vc
         4 pharm_supply_loc_mean = vc
 )
 FREE RECORD tempordersupplyreview
 RECORD tempordersupplyreview(
   1 qual[*]
     2 order_id = f8
     2 order_supply_review_id = f8
     2 location_list[*]
       3 location_cd = f8
       3 location_display = vc
       3 pharm_supply_loc_mean = vc
 )
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE failureind = i2 WITH protect, noconstant(0)
 DECLARE debugind = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE errorcode = i2 WITH protect, noconstant(0)
 DECLARE lastmod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE replycnt = i4 WITH protect, noconstant(0)
 DECLARE ordlistcnt = i4 WITH protect, noconstant(0)
 DECLARE ordsupplylistcnt = i4 WITH protect, noconstant(0)
 DECLARE getorderidanddetails(null) = null
 DECLARE getdurationdetails(null) = null
 DECLARE getordercomment(null) = null
 DECLARE getpharmacycomment(null) = null
 DECLARE getdischargesupplylocation(null) = null
 DECLARE updatetemporderdatastruct(null) = null
 DECLARE populatereply(null) = null
 DECLARE findlocationcode(supplylocationcd=f8) = i4 WITH protect
 DECLARE findorderid(orderid=f8) = i4 WITH protect
 DECLARE populateorderdataundersupply(ordersupplyidx=i4,ordersupplycnt=i4,replylocationpos=i4) = i2
 WITH protect
 DECLARE populateorderdataunderreply(null) = null
 IF (validate(request->debug_ind))
  SET debugind = request->debug_ind
 ENDIF
 IF ((((request->person_id=0)) OR ((request->encntr_id=0))) )
  CALL fillsubeventstatus("bsc_get_disch_meds_supply","F","REQUEST",
   "The 'person_id' or 'encntr_id' is invalid from the request.")
  SET failureind = 1
  GO TO status_update
 ENDIF
 CALL getorderidanddetails(null)
 IF (ordlistcnt=0)
  SET replycnt = 0
  GO TO status_update
 ENDIF
 CALL getdurationdetails(null)
 CALL getordercomment(null)
 IF (ordsupplylistcnt=0)
  SET replycnt = 0
  GO TO status_update
 ENDIF
 CALL getdischargesupplylocation(null)
 CALL updatetemporderdatastruct(null)
 CALL populatereply(null)
 SUBROUTINE getorderidanddetails(null)
   IF (debugind=1)
    CALL echo("*********Begin GetOrderIdAndDetails")
   ENDIF
   DECLARE iorderdatacnt = i4 WITH protect, noconstant(0)
   DECLARE ordersupplycnt = i4 WITH protect, noconstant(0)
   DECLARE ordersupplyreview = i4 WITH protect, noconstant(0)
   DECLARE incomplete_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "INCOMPLETE"))
   DECLARE inprocess_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"
     ))
   DECLARE med_student_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "MEDSTUDENT"))
   DECLARE future_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
   DECLARE pending_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
   DECLARE pending_rev_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "PENDING REV"))
   DECLARE unscheduled_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "UNSCHEDULED"))
   DECLARE canceled_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
   DECLARE discontinued_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "DISCONTINUED"))
   DECLARE voided_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
   DECLARE transfer_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "TRANS/CANCEL"))
   DECLARE suspended_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
   DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
   SELECT INTO "nl:"
    FROM order_supply_review ordsuprev,
     (left JOIN long_text lngtxt ON lngtxt.long_text_id=ordsuprev.long_text_id),
     orders ord,
     order_action ordact
    PLAN (ordsuprev
     WHERE (ordsuprev.encntr_id=request->encntr_id)
      AND ordsuprev.location_exists_ind=1
      AND ordsuprev.pharmacy_review_ind >= 1
      AND ordsuprev.active_ind=1)
     JOIN (ord
     WHERE ord.order_id=ordsuprev.order_id
      AND (ord.person_id=request->person_id)
      AND  NOT (ord.order_status_cd IN (incomplete_status_cd, inprocess_status_cd,
     med_student_status_cd, future_status_cd, pending_status_cd,
     pending_rev_status_cd, unscheduled_status_cd)))
     JOIN (ordact
     WHERE ordact.order_id=ord.order_id)
     JOIN (lngtxt)
    ORDER BY ordsuprev.order_id, ordact.action_sequence DESC
    HEAD REPORT
     iorderdatacnt = 0, ordersupplyreview = 0
    HEAD ordsuprev.order_id
     ordersupplycnt = 0, iorderdatacnt = (iorderdatacnt+ 1)
     IF (mod(iorderdatacnt,100)=1)
      stat = alterlist(temporderdata->qual,(iorderdatacnt+ 99))
     ENDIF
     temporderdata->qual[iorderdatacnt].order_id = ord.order_id, temporderdata->qual[iorderdatacnt].
     order_status_cd = ord.order_status_cd
     IF (((canceled_status_cd=ord.order_status_cd) OR (((discontinued_status_cd=ord.order_status_cd)
      OR (((voided_status_cd=ord.order_status_cd) OR (((transfer_cancelled_cd=ord.order_status_cd)
      OR (((suspended_cd=ord.order_status_cd) OR (completed_cd=ord.order_status_cd)) )) )) )) )) )
      temporderdata->qual[iorderdatacnt].order_endstate_ind = 1
     ENDIF
     temporderdata->qual[iorderdatacnt].order_status_display = uar_get_code_display(ord
      .order_status_cd), temporderdata->qual[iorderdatacnt].order_status_updt_dt_tm = ord
     .status_dt_tm, temporderdata->qual[iorderdatacnt].order_detail_disp_line = ordact
     .clinical_display_line,
     temporderdata->qual[iorderdatacnt].action_seq = ordact.action_sequence, temporderdata->qual[
     iorderdatacnt].iv_ind = ord.iv_ind, temporderdata->qual[iorderdatacnt].hna_order_mnemonic = ord
     .hna_order_mnemonic,
     temporderdata->qual[iorderdatacnt].ordered_as_mnemonic = ord.ordered_as_mnemonic, temporderdata
     ->qual[iorderdatacnt].order_mnemonic = ord.order_mnemonic
    DETAIL
     ordersupplyreview = (ordersupplyreview+ 1), stat = alterlist(tempordersupplyreview->qual,
      ordersupplyreview), tempordersupplyreview->qual[ordersupplyreview].order_supply_review_id =
     ordsuprev.order_supply_review_id,
     tempordersupplyreview->qual[ordersupplyreview].order_id = ordsuprev.order_id, ordersupplycnt = (
     ordersupplycnt+ 1)
     IF (mod(ordersupplycnt,100)=1)
      stat = alterlist(temporderdata->qual[iorderdatacnt].order_supply,(ordersupplycnt+ 99))
     ENDIF
     temporderdata->qual[iorderdatacnt].pharm_review_ind = ordsuprev.pharmacy_review_ind,
     temporderdata->qual[iorderdatacnt].pharmacy_comment = lngtxt.long_text, temporderdata->qual[
     iorderdatacnt].order_supply_review_id = ordsuprev.order_supply_review_id
    FOOT  ordsuprev.order_id
     stat = alterlist(temporderdata->qual[iorderdatacnt].order_supply,ordersupplycnt)
    FOOT REPORT
     stat = alterlist(temporderdata->qual,iorderdatacnt)
    WITH nocounter
   ;end select
   IF (debugind=1)
    CALL echo("*********End GetOrderIdAndDetails")
   ENDIF
   SET ordlistcnt = size(temporderdata->qual,5)
   SET ordsupplylistcnt = size(tempordersupplyreview->qual,5)
 END ;Subroutine
 SUBROUTINE getdurationdetails(null)
   IF (debugind=1)
    CALL echo("*********Begin GetDurationDetails")
   ENDIF
   DECLARE orddetidx = i4 WITH protect, noconstant(0)
   DECLARE orddetposidx = i4 WITH protect, noconstant(0)
   DECLARE orddetpos = i4 WITH protect, noconstant(0)
   DECLARE duration_meaning_id = i4 WITH protect, constant(2061)
   DECLARE duration_unit_meaning_id = i4 WITH protect, constant(2062)
   SELECT INTO "nl:"
    FROM order_detail orddet
    WHERE expand(orddetidx,1,ordlistcnt,orddet.order_id,temporderdata->qual[orddetidx].order_id)
     AND orddet.oe_field_meaning_id IN (duration_meaning_id, duration_unit_meaning_id)
     AND (orddet.action_sequence=
    (SELECT
     max(orddet2.action_sequence)
     FROM order_detail orddet2
     WHERE orddet.order_id > 0.0
      AND orddet2.order_id=orddet.order_id
      AND orddet2.oe_field_id=orddet.oe_field_id))
    ORDER BY orddet.order_id, orddet.oe_field_id, orddet.action_sequence DESC
    HEAD orddet.order_id
     orddetpos = locateval(orddetposidx,1,ordlistcnt,orddet.order_id,temporderdata->qual[orddetposidx
      ].order_id)
    DETAIL
     IF (orddetpos > 0)
      IF (orddet.oe_field_meaning_id=duration_meaning_id)
       temporderdata->qual[orddetpos].duration_val = orddet.oe_field_display_value
      ELSEIF (orddet.oe_field_meaning_id=duration_unit_meaning_id)
       temporderdata->qual[orddetpos].duration_unit = orddet.oe_field_display_value
      ENDIF
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*********End GetDurationDetails")
   ENDIF
 END ;Subroutine
 SUBROUTINE getordercomment(null)
   IF (debugind=1)
    CALL echo("*********Begin GetOrderComment")
   ENDIF
   DECLARE ordcmtidx = i4 WITH protect, noconstant(0)
   DECLARE ordcmtposidx = i4 WITH protect, noconstant(0)
   DECLARE ordcmtpos = i4 WITH protect, noconstant(0)
   DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
   SELECT INTO "nl:"
    FROM order_comment ordcmt,
     long_text lngtxt
    PLAN (ordcmt
     WHERE expand(ordcmtidx,1,ordlistcnt,ordcmt.order_id,temporderdata->qual[ordcmtidx].order_id)
      AND ordcmt.comment_type_cd=order_comment_cd)
     JOIN (lngtxt
     WHERE lngtxt.long_text_id=ordcmt.long_text_id)
    ORDER BY ordcmt.order_id, ordcmt.action_sequence DESC
    HEAD ordcmt.order_id
     ordcmtpos = locateval(ordcmtposidx,1,ordlistcnt,ordcmt.order_id,temporderdata->qual[ordcmtposidx
      ].order_id)
     IF (ordcmtpos > 0)
      temporderdata->qual[ordcmtpos].order_comment = lngtxt.long_text
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*********End GetOrderComment")
   ENDIF
 END ;Subroutine
 SUBROUTINE getdischargesupplylocation(null)
   IF (debugind=1)
    CALL echo("*********Begin GetDischargeSupplyLocation")
   ENDIF
   DECLARE discsuplocidx = i4 WITH protect, noconstant(0)
   DECLARE discsuplocposidx = i4 WITH protect, noconstant(0)
   DECLARE discsuplocpos = i4 WITH protect, noconstant(0)
   DECLARE loccnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM order_supply_location ordsuploc
    WHERE expand(discsuplocidx,1,ordsupplylistcnt,ordsuploc.order_supply_review_id,
     tempordersupplyreview->qual[discsuplocidx].order_supply_review_id)
     AND ordsuploc.order_supply_location_id != 0.0
     AND ordsuploc.active_ind=1
    ORDER BY ordsuploc.order_supply_review_id, ordsuploc.pharmacy_supply_location_cd
    HEAD REPORT
     loccnt = 0
    HEAD ordsuploc.order_supply_review_id
     loccnt = 0
    HEAD ordsuploc.pharmacy_supply_location_cd
     discsuplocpos = locateval(discsuplocposidx,1,ordsupplylistcnt,ordsuploc.order_supply_review_id,
      tempordersupplyreview->qual[discsuplocposidx].order_supply_review_id)
     IF (discsuplocpos > 0)
      loccnt = (loccnt+ 1), stat = alterlist(tempordersupplyreview->qual[discsuplocpos].location_list,
       loccnt), tempordersupplyreview->qual[discsuplocpos].location_list[loccnt].location_cd =
      ordsuploc.pharmacy_supply_location_cd,
      tempordersupplyreview->qual[discsuplocpos].location_list[loccnt].location_display =
      uar_get_code_display(ordsuploc.pharmacy_supply_location_cd), tempordersupplyreview->qual[
      discsuplocpos].location_list[loccnt].pharm_supply_loc_mean = uar_get_code_meaning(ordsuploc
       .pharmacy_supply_location_cd)
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*********End GetDischargeSupplyLocation")
   ENDIF
 END ;Subroutine
 SUBROUTINE updatetemporderdatastruct(null)
   IF (debugind=1)
    CALL echo("*********Begin UpdateTempOrderDataStruct")
   ENDIF
   DECLARE ordsuprevpos = i4 WITH protect, noconstant(0)
   DECLARE ordsuprevposidx = i4 WITH protect, noconstant(0)
   DECLARE ordsupreviewidx = i4 WITH protect, noconstant(0)
   DECLARE orddataidx = i4 WITH protect, noconstant(0)
   DECLARE orddatasuprevcnt = i4 WITH protect, noconstant(0)
   DECLARE orddatasuprevidx = i4 WITH protect, noconstant(0)
   DECLARE dorderdatareviewid = f8 WITH protect, noconstant(0)
   DECLARE ordsupplyloccnt = i4 WITH protect, noconstant(0)
   DECLARE ordsupplylocidx = i4 WITH protect, noconstant(0)
   FOR (orddataidx = 1 TO ordlistcnt)
     SET orddatasuprevcnt = 0
     SET orddatasuprevcnt = size(temporderdata->qual[orddataidx].order_supply,5)
     SET dorderdatareviewid = temporderdata->qual[orddataidx].order_supply_review_id
     FOR (orddatasuprevidx = 1 TO orddatasuprevcnt)
       FOR (ordsupreviewidx = 1 TO ordsupplylistcnt)
        SET ordsuprevpos = locateval(ordsuprevposidx,1,ordsupplylistcnt,dorderdatareviewid,
         tempordersupplyreview->qual[ordsuprevposidx].order_supply_review_id)
        IF (ordsuprevpos > 0)
         SET ordsupplyloccnt = size(tempordersupplyreview->qual[ordsuprevpos].location_list,5)
         IF (ordsupplyloccnt > 0)
          SET stat = alterlist(temporderdata->qual[orddataidx].order_supply[orddatasuprevidx].
           location_list,ordsupplyloccnt)
          FOR (ordsupplylocidx = 1 TO ordsupplyloccnt)
            SET temporderdata->qual[orddataidx].order_supply[orddatasuprevidx].location_list[
            ordsupplylocidx].location_cd = tempordersupplyreview->qual[ordsuprevpos].location_list[
            ordsupplylocidx].location_cd
            SET temporderdata->qual[orddataidx].order_supply[orddatasuprevidx].location_list[
            ordsupplylocidx].location_display = tempordersupplyreview->qual[ordsuprevpos].
            location_list[ordsupplylocidx].location_display
            SET temporderdata->qual[orddataidx].order_supply[orddatasuprevidx].location_list[
            ordsupplylocidx].pharm_supply_loc_mean = tempordersupplyreview->qual[ordsuprevpos].
            location_list[ordsupplylocidx].pharm_supply_loc_mean
          ENDFOR
         ENDIF
        ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   IF (debugind=1)
    CALL echo("*********End UpdateTempOrderDataStruct")
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereply(null)
   IF (debugind=1)
    CALL echo("*********Begin PopulateReply")
   ENDIF
   DECLARE orderdataidx = i4 WITH protect, noconstant(0)
   DECLARE ordersupplycnt = i4 WITH protect, noconstant(0)
   DECLARE orderlocationidx = i4 WITH protect, noconstant(0)
   DECLARE orderlocationcnt = i4 WITH protect, noconstant(0)
   DECLARE dorderlocationcd = f8 WITH protect, noconstant(0)
   DECLARE orderlocationcdpos = i4 WITH protect, noconstant(0)
   DECLARE ordersupplyincrement = i4 WITH protect, noconstant(0)
   DECLARE supplyorderincrement = i4 WITH protect, noconstant(0)
   DECLARE bordsupplystatus = i2 WITH protect, noconstant(0)
   FOR (orderdataidx = 1 TO ordlistcnt)
    SET ordersupplycnt = size(temporderdata->qual[orderdataidx].order_supply,5)
    IF (ordersupplycnt > 0)
     FOR (isupplyidx = 1 TO ordersupplycnt)
      SET orderlocationcnt = size(temporderdata->qual[orderdataidx].order_supply[isupplyidx].
       location_list,5)
      IF (orderlocationcnt > 0)
       FOR (orderlocationidx = 1 TO orderlocationcnt)
         SET supplyorderincrement = 0
         SET dorderlocationcd = temporderdata->qual[orderdataidx].order_supply[isupplyidx].
         location_list[orderlocationidx].location_cd
         SET orderlocationcdpos = findlocationcode(dorderlocationcd)
         IF (orderlocationcdpos=0)
          SET ordersupplyincrement = (ordersupplyincrement+ 1)
          SET stat = alterlist(reply->supplylocations,ordersupplyincrement)
          SET reply->supplylocations[ordersupplyincrement].pharm_supply_loc_cd = dorderlocationcd
          SET reply->supplylocations[ordersupplyincrement].pharm_supply_loc_disp = temporderdata->
          qual[orderdataidx].order_supply[isupplyidx].location_list[orderlocationidx].
          location_display
          SET reply->supplylocations[ordersupplyincrement].pharm_supply_loc_mean = temporderdata->
          qual[orderdataidx].order_supply[isupplyidx].location_list[orderlocationidx].
          pharm_supply_loc_mean
          IF ((temporderdata->qual[orderdataidx].pharm_review_ind >= 1))
           SET supplyorderincrement = (supplyorderincrement+ 1)
           SET stat = alterlist(reply->supplylocations[ordersupplyincrement].orders,
            supplyorderincrement)
           SET reply->supplylocations[ordersupplyincrement].orders[supplyorderincrement].order_id =
           temporderdata->qual[orderdataidx].order_id
           SET reply->supplylocations[ordersupplyincrement].orders[supplyorderincrement].action_seq
            = temporderdata->qual[orderdataidx].action_seq
          ENDIF
         ELSE
          SET bordsupplystatus = populateorderdataundersupply(orderdataidx,ordersupplycnt,
           orderlocationcdpos)
         ENDIF
       ENDFOR
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   CALL populateorderdataunderreply(null)
   SET replycnt = size(reply->orders,5)
   IF (debugind=1)
    CALL echo("*********End PopulateReply")
   ENDIF
 END ;Subroutine
 SUBROUTINE populateorderdataunderreply(null)
   IF (debugind=1)
    CALL echo("*********Begin PopulateOrderDataUnderReply")
   ENDIF
   DECLARE orderdataidx = i4 WITH protect, noconstant(0)
   DECLARE orderdatasupplycnt = i4 WITH protect, noconstant(0)
   DECLARE orderdatasupplyidx = i4 WITH protect, noconstant(0)
   DECLARE orderdatasupplyloccnt = i4 WITH protect, noconstant(0)
   DECLARE orderdatasupplylocidx = i4 WITH protect, noconstant(0)
   DECLARE pharmrevieworder = i4 WITH protect, noconstant(0)
   FOR (orderdataidx = 1 TO ordlistcnt)
     IF ((temporderdata->qual[orderdataidx].pharm_review_ind >= 1))
      SET pharmrevieworder = (pharmrevieworder+ 1)
      SET stat = alterlist(reply->orders,pharmrevieworder)
      SET reply->orders[pharmrevieworder].order_id = temporderdata->qual[orderdataidx].order_id
      SET reply->orders[pharmrevieworder].action_seq = temporderdata->qual[orderdataidx].action_seq
      SET reply->orders[pharmrevieworder].iv_ind = temporderdata->qual[orderdataidx].iv_ind
      SET reply->orders[pharmrevieworder].hna_order_mnemonic = temporderdata->qual[orderdataidx].
      hna_order_mnemonic
      SET reply->orders[pharmrevieworder].ordered_as_mnemonic = temporderdata->qual[orderdataidx].
      ordered_as_mnemonic
      SET reply->orders[pharmrevieworder].order_mnemonic = temporderdata->qual[orderdataidx].
      order_mnemonic
      SET reply->orders[pharmrevieworder].order_detail_disp_line = temporderdata->qual[orderdataidx].
      order_detail_disp_line
      SET reply->orders[pharmrevieworder].order_comment = temporderdata->qual[orderdataidx].
      order_comment
      SET reply->orders[pharmrevieworder].order_status_cd = temporderdata->qual[orderdataidx].
      order_status_cd
      SET reply->orders[pharmrevieworder].order_status_updt_dt_tm = temporderdata->qual[orderdataidx]
      .order_status_updt_dt_tm
      SET reply->orders[pharmrevieworder].order_endstate_ind = temporderdata->qual[orderdataidx].
      order_endstate_ind
      SET reply->orders[pharmrevieworder].order_status_display = temporderdata->qual[orderdataidx].
      order_status_display
      SET reply->orders[pharmrevieworder].pharmacy_comment = temporderdata->qual[orderdataidx].
      pharmacy_comment
      SET reply->orders[pharmrevieworder].order_supply_review_id = temporderdata->qual[orderdataidx].
      order_supply_review_id
      SET reply->orders[pharmrevieworder].duration_val = temporderdata->qual[orderdataidx].
      duration_val
      SET reply->orders[pharmrevieworder].duration_unit = temporderdata->qual[orderdataidx].
      duration_unit
      SET orderdatasupplycnt = size(temporderdata->qual[orderdataidx].order_supply,5)
      FOR (orderdatasupplyidx = 1 TO orderdatasupplycnt)
       SET orderdatasupplyloccnt = size(temporderdata->qual[orderdataidx].order_supply[
        orderdatasupplyidx].location_list,5)
       FOR (orderdatasupplylocidx = 1 TO orderdatasupplyloccnt)
         SET stat = alterlist(reply->orders[pharmrevieworder].supplylocations,orderdatasupplylocidx)
         SET reply->orders[pharmrevieworder].supplylocations[orderdatasupplylocidx].
         pharm_supply_loc_cd = temporderdata->qual[orderdataidx].order_supply[orderdatasupplyidx].
         location_list[orderdatasupplylocidx].location_cd
         SET reply->orders[pharmrevieworder].supplylocations[orderdatasupplylocidx].location_display
          = temporderdata->qual[orderdataidx].order_supply[orderdatasupplyidx].location_list[
         orderdatasupplylocidx].location_display
         SET reply->orders[pharmrevieworder].supplylocations[orderdatasupplylocidx].
         pharm_supply_loc_mean = temporderdata->qual[orderdataidx].order_supply[orderdatasupplyidx].
         location_list[orderdatasupplylocidx].pharm_supply_loc_mean
       ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   IF (debugind=1)
    CALL echo("*********End PopulateOrderDataUnderReply")
   ENDIF
 END ;Subroutine
 SUBROUTINE populateorderdataundersupply(ordersupplyidx,ordersupplycnt,replylocationpos)
   IF (debugind=1)
    CALL echo("*********Begin PopulateOrderDataUnderSupply")
   ENDIF
   DECLARE bordsupplyupdated = i4 WITH protect, noconstant(0)
   DECLARE ordpos = i4 WITH protect, noconstant(0)
   DECLARE ordidpos = i4 WITH protect, noconstant(0)
   DECLARE dreplyorderid = f8 WITH protect, noconstant(0)
   DECLARE supplyorderincrement = i4 WITH protect, noconstant(size(reply->supplylocations[
     replylocationpos].orders,5))
   SET dreplyorderid = temporderdata->qual[ordersupplyidx].order_id
   SET ordidpos = locateval(ordpos,1,size(reply->supplylocations[replylocationpos].orders,5),
    dreplyorderid,reply->supplylocations[replylocationpos].orders[ordpos].order_id)
   IF (ordidpos=0
    AND (temporderdata->qual[ordersupplyidx].pharm_review_ind >= 1))
    SET supplyorderincrement = (supplyorderincrement+ 1)
    SET stat = alterlist(reply->supplylocations[replylocationpos].orders,supplyorderincrement)
    SET reply->supplylocations[replylocationpos].orders[supplyorderincrement].order_id =
    temporderdata->qual[ordersupplyidx].order_id
    SET reply->supplylocations[replylocationpos].orders[supplyorderincrement].action_seq =
    temporderdata->qual[ordersupplyidx].action_seq
    SET bordsupplyupdated = 1
   ENDIF
   RETURN(bordsupplyupdated)
   IF (debugind=1)
    CALL echo("*********End PopulateOrderDataUnderSupply")
   ENDIF
 END ;Subroutine
 SUBROUTINE findlocationcode(supplylocationcd)
   IF (debugind=1)
    CALL echo("*********Begin FindLocationCode")
   ENDIF
   DECLARE suplocpos = i4 WITH protect, noconstant(0)
   DECLARE loccdpos = i4 WITH protect, noconstant(0)
   IF (size(reply->supplylocations,5) > 0)
    SET loccdpos = locateval(suplocpos,1,size(reply->supplylocations,5),supplylocationcd,reply->
     supplylocations[suplocpos].pharm_supply_loc_cd)
   ENDIF
   RETURN(loccdpos)
   IF (debugind=1)
    CALL echo("*********End FindLocationCode")
   ENDIF
 END ;Subroutine
#status_update
 SET errorcode = error(serrormsg,1)
 IF (errorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL fillsubeventstatus("ERROR","F","bsc_get_disch_meds_supply",serrormsg)
  SET reply->status_data.status = "F"
 ELSEIF (failureind=1)
  SET reply->status_data.status = "F"
 ELSEIF (replycnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debugind=1)
  CALL echorecord(reply)
  CALL echorecord(temporderdata)
 ENDIF
 SET lastmod = "07/28/2015"
 SET modify = nopredeclare
END GO
