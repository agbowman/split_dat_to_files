CREATE PROGRAM bsc_get_clinical_disch_meds:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 action_seq = i4
     2 order_mnemonic = vc
     2 iv_ind = i2
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 clinical_display_line = vc
     2 order_comment = vc
     2 event_id = f8
     2 clinical_event_id = f8
     2 event_dt_tm = dq8
     2 performed_prsnl_id = f8
     2 performed_prsnl_name = vc
     2 not_given_ind = i2
     2 not_given_reason_cd = f8
     2 not_given_reason_disp = vc
     2 location_cd = f8
     2 location_display = vc
     2 nurse_comment_details[*]
       3 nurse_comment_text = vc
       3 nurse_comment_prsnl_id = f8
       3 nurse_comment_prsnl_name = vc
     2 pharm_supply_review_comment = vc
     2 pharm_supply_review_dt_tm = dq8
     2 order_modified_dt_tm = dq8
     2 duration_val = vc
     2 duration_unit = vc
     2 additional_supply_loc[*]
       3 location_cd = f8
       3 location_display = vc
       3 ord_signed_ind = i2
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
     2 order_supply_review_id = f8
     2 action_seq = i4
     2 iv_ind = i2
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 clinical_display_line = vc
     2 order_comment = vc
     2 event_id = f8
     2 clinical_event_id = f8
     2 event_dt_tm = dq8
     2 performed_prsnl_id = f8
     2 performed_prsnl_name = vc
     2 not_given_ind = i2
     2 not_given_reason_cd = f8
     2 not_given_reason_disp = vc
     2 location_cd = f8
     2 location_display = vc
     2 nurse_comment_details[*]
       3 nurse_comment_text = vc
       3 nurse_comment_prsnl_id = f8
       3 nurse_comment_prsnl_name = vc
     2 pharm_supply_review_comment = vc
     2 pharm_supply_review_dt_tm = dq8
     2 order_modified_dt_tm = dq8
     2 duration_val = vc
     2 duration_unit = vc
     2 additional_supply_loc[*]
       3 location_cd = f8
       3 location_display = vc
       3 collation_seq = i4
       3 ord_signed_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE failureind = i2 WITH protect, noconstant(0)
 DECLARE debugind = i2 WITH protect, noconstant(0)
 DECLARE errormsg = vc WITH protect, noconstant("")
 DECLARE errorcode = i2 WITH protect, noconstant(0)
 DECLARE lastmod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE eventcnt = i4 WITH protect, noconstant(0)
 DECLARE replycnt = i4 WITH protect, noconstant(0)
 DECLARE not_given_reason = f8 WITH protect, constant(4002376.00)
 DECLARE getclinicaldetailsonpharmdischargeorders(null) = null
 DECLARE getclinicalcommentonpharmdischargeorders(null) = null
 DECLARE parsecommentlongblobtext(note_format_cd=f8,compression_cd=f8,long_blob=vc) = vc
 DECLARE findeventid(eventid=f8) = i4 WITH protect
 DECLARE findordersupplylocation(supplylocpos=i4,supplylocationcd=f8) = i4 WITH protect
 DECLARE getpharmreviewinfo(null) = null
 DECLARE updatepharmsupplyreviewinfo(orderid=f8,ordersequence=i4,ordersupplyreviewid=f8,
  ordermodifieddttm=dq8,pharmsupplyreviewcomment=vc,
  pharmsupplyreviewdttm=dq8) = null
 DECLARE getdischargesupplylocation(null) = null
 DECLARE updateadditionalsupplylocations(ordersupplyreviewid=f8,ordersupplylocationcd=f8,
  collation_seq=i4) = null
 DECLARE populatereply(null) = null
 DECLARE updateorderdetails(orderid=f8,ordersequence=i4,order_mnemonic=vc,clinical_display_line=vc)
  = null
 DECLARE getorderdetails(null) = null
 DECLARE getdurationdetails(null) = null
 DECLARE updatedurationdetails(ordid=f8,actionseq=i4,duration=vc,durationunit=vc) = null
 DECLARE updateordercomment(orderid=f8,ordersequence=i4,order_comment_text=vc) = null
 DECLARE getordercomment(null) = null
 IF (validate(request->debug_ind))
  SET debugind = request->debug_ind
 ENDIF
 IF ((((request->person_id=0)) OR ((request->encntr_id=0))) )
  CALL fillsubeventstatus("bsc_get_clinical_disch_meds","F","REQUEST",
   "The 'person_id' or 'encntr_id' is invalid from the request.")
  SET failureind = 1
  GO TO status_update
 ENDIF
 CALL getclinicaldetailsonpharmdischargeorders(null)
 IF (eventcnt=0)
  SET replycnt = 0
  GO TO status_update
 ENDIF
 CALL getorderdetails(null)
 CALL getdurationdetails(null)
 CALL getordercomment(null)
 CALL getclinicalcommentonpharmdischargeorders(null)
 CALL getpharmreviewinfo(null)
 CALL getdischargesupplylocation(null)
 CALL populatereply(null)
 SUBROUTINE getclinicaldetailsonpharmdischargeorders(null)
   IF (debugind=1)
    CALL echo("*********Begin GetClinicalDetailsOnPharmDischargeOrders")
   ENDIF
   DECLARE clindetcnt = i4 WITH protect, noconstant(0)
   DECLARE eventidpos = i4 WITH protect, noconstant(0)
   DECLARE eventidcnt = i4 WITH protect, noconstant(0)
   DECLARE supplyloccnt = i4 WITH protect, noconstant(0)
   DECLARE supplylocpos = i4 WITH protect, noconstant(0)
   DECLARE primsignedlocationcd = f8 WITH protect, noconstant(0)
   DECLARE concept_cki = vc WITH protect, constant("CERNER!603C84D8-624F-40F6-B86B-C0D78D449A94")
   DECLARE disch_event_cd = f8 WITH protect, noconstant(0.0)
   DECLARE result_given = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
   DECLARE result_not_given = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
   DECLARE result_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
   DECLARE prsnl_event_perform = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
   DECLARE record_active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
   DECLARE event_done = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DONE"))
   CALL uar_get_code_list_by_conceptcki(72,concept_cki,1,1,0,
    disch_event_cd)
   SELECT INTO "nl:"
    FROM clinical_event clinevent,
     ce_coded_result cecoderes,
     ce_event_prsnl ceevenprs,
     person per
    PLAN (clinevent
     WHERE (clinevent.person_id=request->person_id)
      AND (clinevent.encntr_id=request->encntr_id)
      AND clinevent.event_cd=disch_event_cd
      AND clinevent.event_class_cd=event_done
      AND clinevent.record_status_cd=record_active
      AND clinevent.result_status_cd IN (result_given, result_not_given, result_modified)
      AND clinevent.valid_until_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime),1))
     JOIN (cecoderes
     WHERE cecoderes.event_id=clinevent.event_id)
     JOIN (ceevenprs
     WHERE ceevenprs.event_id=cecoderes.event_id
      AND ceevenprs.action_type_cd=prsnl_event_perform)
     JOIN (per
     WHERE per.person_id=clinevent.performed_prsnl_id)
    ORDER BY clinevent.event_id, clinevent.updt_dt_tm DESC
    HEAD REPORT
     clindetcnt = 0, eventidcnt = 0, supplyloccnt = 0,
     primsignedlocationcd = 0
    HEAD clinevent.event_id
     supplyloccnt = 0, primsignedlocationcd = 0, clindetcnt = (clindetcnt+ 1)
     IF (mod(clindetcnt,100)=1)
      stat = alterlist(temporderdata->qual,(clindetcnt+ 99))
     ENDIF
     temporderdata->qual[clindetcnt].order_id = clinevent.order_id, temporderdata->qual[clindetcnt].
     event_id = clinevent.event_id, temporderdata->qual[clindetcnt].clinical_event_id = clinevent
     .clinical_event_id,
     temporderdata->qual[clindetcnt].event_dt_tm = clinevent.event_end_dt_tm, temporderdata->qual[
     clindetcnt].performed_prsnl_id = clinevent.performed_prsnl_id, temporderdata->qual[clindetcnt].
     performed_prsnl_name = per.name_full_formatted,
     temporderdata->qual[clindetcnt].action_seq = clinevent.order_action_sequence
     IF (clinevent.result_status_cd=result_not_given)
      temporderdata->qual[clindetcnt].not_given_ind = 1
     ENDIF
    HEAD cecoderes.sequence_nbr
     IF (cecoderes.result_set=not_given_reason
      AND (temporderdata->qual[clindetcnt].not_given_ind=1))
      temporderdata->qual[clindetcnt].not_given_reason_cd = cecoderes.result_cd, temporderdata->qual[
      clindetcnt].not_given_reason_disp = uar_get_code_display(cecoderes.result_cd)
     ELSE
      primsignedlocationcd = cecoderes.result_cd, temporderdata->qual[clindetcnt].location_cd =
      cecoderes.result_cd, temporderdata->qual[clindetcnt].location_display = uar_get_code_display(
       cecoderes.result_cd)
      IF (primsignedlocationcd != cecoderes.result_cd
       AND primsignedlocationcd != 0.0)
       eventidpos = findeventid(cecoderes.event_id)
       IF (eventidpos > 0)
        supplylocpos = findordersupplylocation(eventidpos,cecoderes.result_cd)
        IF (supplylocpos=0)
         supplyloccnt = (supplyloccnt+ 1), stat = alterlist(temporderdata->qual[eventidpos].
          additional_supply_loc,supplyloccnt), temporderdata->qual[eventidpos].additional_supply_loc[
         supplyloccnt].location_cd = cecoderes.result_cd,
         temporderdata->qual[eventidpos].additional_supply_loc[supplyloccnt].location_display =
         uar_get_code_display(cecoderes.result_cd), temporderdata->qual[eventidpos].
         additional_supply_loc[supplyloccnt].ord_signed_ind = 1
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(temporderdata->qual,clindetcnt)
    WITH nocounter
   ;end select
   SET eventcnt = size(temporderdata->qual,5)
   IF (debugind=1)
    CALL echo("*********End GetClinicalDetailsOnPharmDischargeOrders")
   ENDIF
 END ;Subroutine
 SUBROUTINE getclinicalcommentonpharmdischargeorders(null)
   IF (debugind=1)
    CALL echo("*********Begin GetClinicalCommentOnPharmDischargeOrders")
   ENDIF
   DECLARE ordcmtidx = i4 WITH protect, noconstant(0)
   DECLARE ordercmtposidx = i4 WITH protect, noconstant(0)
   DECLARE ordercmtpos = i4 WITH protect, noconstant(0)
   DECLARE note_res_comment = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"RES COMMENT"))
   DECLARE note_entry_method = f8 WITH protect, constant(uar_get_code_by("MEANING",13,"CERNER"))
   DECLARE note_record_status = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
   SELECT INTO "nl:"
    FROM ce_event_note ceevennot,
     long_blob lngblob,
     person per
    PLAN (ceevennot
     WHERE expand(ordcmtidx,1,eventcnt,ceevennot.event_id,temporderdata->qual[ordcmtidx].event_id)
      AND ceevennot.note_type_cd=note_res_comment
      AND ceevennot.record_status_cd=note_record_status
      AND ceevennot.entry_method_cd=note_entry_method
      AND ceevennot.valid_until_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime),1)
      AND (ceevennot.updt_dt_tm=
     (SELECT
      max(ce.updt_dt_tm)
      FROM ce_event_note ce
      WHERE ce.event_id=ceevennot.event_id)))
     JOIN (lngblob
     WHERE lngblob.parent_entity_id=ceevennot.ce_event_note_id
      AND lngblob.parent_entity_name="CE_EVENT_NOTE")
     JOIN (per
     WHERE per.person_id=ceevennot.updt_id)
    ORDER BY ceevennot.updt_dt_tm DESC
    HEAD ceevennot.event_id
     ordercmtpos = locateval(ordercmtposidx,1,eventcnt,ceevennot.event_id,temporderdata->qual[
      ordercmtposidx].event_id)
     IF (ordercmtpos > 0)
      stat = alterlist(temporderdata->qual[ordercmtpos].nurse_comment_details,1), temporderdata->
      qual[ordercmtpos].nurse_comment_details[1].nurse_comment_text = parsecommentlongblobtext(
       ceevennot.note_format_cd,ceevennot.compression_cd,lngblob.long_blob), temporderdata->qual[
      ordercmtpos].nurse_comment_details[1].nurse_comment_prsnl_id = ceevennot.updt_id,
      temporderdata->qual[ordercmtpos].nurse_comment_details[1].nurse_comment_prsnl_name = per
      .name_full_formatted
     ENDIF
     IF (debugind=1)
      CALL echo("*********End GetClinicalCommentOnPharmDischargeOrders")
     ENDIF
   ;end select
 END ;Subroutine
 SUBROUTINE parsecommentlongblobtext(note_format_cd,compression_cd,long_blob)
   IF (debugind=1)
    CALL echo("*********Begin ParseCommentLongBlobText")
   ENDIF
   DECLARE rtf = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"RTF"))
   DECLARE compressed = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
   DECLARE inbuffer = vc WITH protect, noconstant("")
   DECLARE inbuflen = i4 WITH noconstant(0)
   DECLARE outbuffer = c32000 WITH noconstant("")
   DECLARE outbuflen = i4 WITH noconstant(32000)
   DECLARE retbuflen = i4 WITH noconstant(0)
   DECLARE comment_text = vc WITH protect, noconstant("")
   DECLARE ocf = i2 WITH protect, noconstant(0)
   DECLARE bflag = i4 WITH protect, noconstant(0)
   IF (note_format_cd=rtf)
    IF (compression_cd=compressed)
     SET inbuflen = size(long_blob)
     CALL uar_ocf_uncompress(long_blob,inbuflen,outbuffer,30000,outbuflen)
     SET inbuflen = size(outbuffer)
     IF (debugind=1)
      CALL echo(build("InBuff",inbuflen))
     ENDIF
     SET comment_text = outbuffer
    ELSE
     SET inbuffer = long_blob
     SET inbuflen = size(inbuffer)
     IF (debugind=1)
      CALL echo(build("InBuff",inbuflen))
     ENDIF
     SET comment_text = long_blob
    ENDIF
   ELSE
    IF (compression_cd=compressed)
     SET inbuflen = size(long_blob)
     CALL uar_ocf_uncompress(long_blob,inbuflen,outbuffer,30000,outbuflen)
     SET inbuflen = size(outbuffer)
     SET comment_text = outbuffer
    ELSE
     SET comment_text = long_blob
    ENDIF
   ENDIF
   SET ocf = findstring("ocf_blob",comment_text)
   IF (ocf=0)
    SET comment_text = comment_text
   ELSE
    SET comment_text = substring(1,(ocf - 1),comment_text)
   ENDIF
   RETURN(comment_text)
   IF (debugind=1)
    CALL echo("*********End ParseCommentLongBlobText")
   ENDIF
 END ;Subroutine
 SUBROUTINE findeventid(eventid)
   IF (debugind=1)
    CALL echo("*********Begin FindEventId")
   ENDIF
   DECLARE eventpos = i4 WITH protect, noconstant(0)
   DECLARE eventidx = i4 WITH protect, noconstant(0)
   IF (size(temporderdata->qual,5) > 0)
    SET eventidx = locateval(eventidx,1,size(temporderdata->qual,5),eventid,temporderdata->qual[
     eventidx].event_id)
   ENDIF
   RETURN(eventidx)
   IF (debugind=1)
    CALL echo("*********End FindEventId")
   ENDIF
 END ;Subroutine
 SUBROUTINE findordersupplylocation(supplylocpos,supplylocationcd)
   IF (debugind=1)
    CALL echo("*********Begin FindOrderSupplyLocation")
   ENDIF
   DECLARE ordsupplylocpos = i4 WITH protect, noconstant(0)
   DECLARE ordsupplylocidx = i4 WITH protect, noconstant(0)
   IF (size(temporderdata->qual[supplylocpos].additional_supply_loc,5) > 0)
    SET ordsupplylocidx = locateval(ordsupplylocpos,1,size(temporderdata->qual[supplylocpos].
      additional_supply_loc,5),supplylocationcd,temporderdata->qual[supplylocpos].
     additional_supply_loc[ordsupplylocpos].location_cd)
   ENDIF
   RETURN(ordsupplylocidx)
   IF (debugind=1)
    CALL echo("*********End FindOrderSupplyLocation")
   ENDIF
 END ;Subroutine
 SUBROUTINE getpharmreviewinfo(null)
   IF (debugind=1)
    CALL echo("*********Begin GetPharmReviewInfo")
   ENDIF
   DECLARE ordactidx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM order_action ordact,
     order_supply_review ordsuprev,
     long_text lngtxt
    PLAN (ordact
     WHERE expand(ordactidx,1,eventcnt,ordact.order_id,temporderdata->qual[ordactidx].order_id))
     JOIN (ordsuprev
     WHERE ordsuprev.order_id=ordact.order_id
      AND (ordsuprev.encntr_id=request->encntr_id)
      AND ordsuprev.order_supply_review_id != 0.0
      AND ordsuprev.active_ind=1
      AND ordsuprev.pharmacy_review_ind >= 1)
     JOIN (lngtxt
     WHERE lngtxt.long_text_id=ordsuprev.long_text_id)
    ORDER BY ordact.order_id, ordact.action_sequence DESC
    HEAD ordact.order_id
     CALL updatepharmsupplyreviewinfo(ordact.order_id,ordact.action_sequence,ordsuprev
     .order_supply_review_id,ordact.action_dt_tm,lngtxt.long_text,ordsuprev.updt_dt_tm)
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*********End GetPharmReviewInfo")
   ENDIF
 END ;Subroutine
 SUBROUTINE updatepharmsupplyreviewinfo(orderid,ordersequence,ordersupplyreviewid,ordermodifieddttm,
  pharmsupplyreviewcomment,pharmsupplyreviewdttm)
   IF (debugind=1)
    CALL echo("*********Begin UpdatePharmSupplyReviewInfo")
   ENDIF
   DECLARE ordidcnt = i4 WITH protect, noconstant(0)
   DECLARE ordid = f8 WITH protect, noconstant(0)
   FOR (ordidcnt = 1 TO eventcnt)
    SET ordid = temporderdata->qual[ordidcnt].order_id
    IF (orderid=ordid)
     SET temporderdata->qual[ordidcnt].order_supply_review_id = ordersupplyreviewid
     SET temporderdata->qual[ordidcnt].order_modified_dt_tm = ordermodifieddttm
     SET temporderdata->qual[ordidcnt].pharm_supply_review_comment = pharmsupplyreviewcomment
     SET temporderdata->qual[ordidcnt].pharm_supply_review_dt_tm = pharmsupplyreviewdttm
    ENDIF
   ENDFOR
   IF (debugind=1)
    CALL echo("*********End UpdatePharmSupplyReviewInfo")
   ENDIF
 END ;Subroutine
 SUBROUTINE getdischargesupplylocation(null)
   IF (debugind=1)
    CALL echo("*********Begin GetDischargeSupplyLocation")
   ENDIF
   DECLARE discsuplocidx = i4 WITH protect, noconstant(0)
   DECLARE ordsupplyreviewid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM order_supply_location ordsuploc,
     code_value cv
    PLAN (ordsuploc
     WHERE expand(discsuplocidx,1,eventcnt,ordsuploc.order_supply_review_id,temporderdata->qual[
      discsuplocidx].order_supply_review_id)
      AND ordsuploc.order_supply_location_id != 0.0
      AND ordsuploc.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=ordsuploc.pharmacy_supply_location_cd)
    ORDER BY cv.collation_seq, ordsuploc.order_supply_review_id, ordsuploc
     .pharmacy_supply_location_cd
    HEAD REPORT
     ordsupplyreviewid = 0
    HEAD ordsuploc.order_supply_review_id
     ordsupplyreviewid = 0, ordsupplyreviewid = ordsuploc.order_supply_review_id
    HEAD ordsuploc.pharmacy_supply_location_cd
     CALL updateadditionalsupplylocations(ordsupplyreviewid,ordsuploc.pharmacy_supply_location_cd,cv
     .collation_seq)
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*********End GetDischargeSupplyLocation")
   ENDIF
 END ;Subroutine
 SUBROUTINE updateadditionalsupplylocations(ordersupplyreviewid,ordersupplylocationcd,collation_seq)
   IF (debugind=1)
    CALL echo("*********Begin UpdateAdditionalSupplyLocations")
   ENDIF
   DECLARE ordsupplycntidx = i4 WITH protect, noconstant(0)
   DECLARE ordsupplyid = f8 WITH protect, noconstant(0)
   DECLARE primsupplylocationcd = f8 WITH protect, noconstant(0)
   DECLARE primnotgivenlocationcd = f8 WITH protect, noconstant(0)
   DECLARE addsupplycnt = i4 WITH protect, noconstant(0)
   DECLARE addsupplycntidx = i4 WITH protect, noconstant(0)
   DECLARE discsuplocposidx = i4 WITH protect, noconstant(0)
   DECLARE discsuplocpos = i4 WITH protect, noconstant(0)
   FOR (ordsupplycntidx = 1 TO eventcnt)
    SET ordsupplyid = temporderdata->qual[ordsupplycntidx].order_supply_review_id
    IF (ordersupplyreviewid=ordsupplyid)
     SET primsupplylocationcd = temporderdata->qual[ordsupplycntidx].location_cd
     SET primnotgivenlocationcd = temporderdata->qual[ordsupplycntidx].not_given_reason_cd
     SET addsupplycnt = size(temporderdata->qual[ordsupplycntidx].additional_supply_loc,5)
     IF (addsupplycnt=0
      AND primsupplylocationcd != primnotgivenlocationcd
      AND primnotgivenlocationcd != 0)
      SET addsupplycnt = (addsupplycnt+ 1)
      SET stat = alterlist(temporderdata->qual[ordsupplycntidx].additional_supply_loc,addsupplycnt)
      SET temporderdata->qual[ordsupplycntidx].additional_supply_loc[addsupplycnt].location_cd =
      ordersupplylocationcd
      SET temporderdata->qual[ordsupplycntidx].additional_supply_loc[addsupplycnt].location_display
       = uar_get_code_display(ordersupplylocationcd)
      SET temporderdata->qual[ordsupplycntidx].additional_supply_loc[addsupplycnt].collation_seq =
      collation_seq
     ELSE
      IF (primsupplylocationcd != ordersupplylocationcd)
       SET discsuplocpos = locateval(discsuplocposidx,1,addsupplycnt,ordersupplylocationcd,
        temporderdata->qual[ordsupplycntidx].additional_supply_loc[discsuplocposidx].location_cd)
       IF (discsuplocpos=0)
        SET addsupplycnt = (addsupplycnt+ 1)
        SET stat = alterlist(temporderdata->qual[ordsupplycntidx].additional_supply_loc,addsupplycnt)
        SET temporderdata->qual[ordsupplycntidx].additional_supply_loc[addsupplycnt].location_cd =
        ordersupplylocationcd
        SET temporderdata->qual[ordsupplycntidx].additional_supply_loc[addsupplycnt].location_display
         = uar_get_code_display(ordersupplylocationcd)
        SET temporderdata->qual[ordsupplycntidx].additional_supply_loc[addsupplycnt].collation_seq =
        collation_seq
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   IF (debugind=1)
    CALL echo("*********End UpdateAdditionalSupplyLocations")
   ENDIF
 END ;Subroutine
 SUBROUTINE getorderdetails(null)
   IF (debugind=1)
    CALL echo("*********Begin GetOrderDetails")
   ENDIF
   DECLARE ordcntidx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM order_action ordact,
     clinical_event clinevent,
     orders ord
    PLAN (ordact
     WHERE expand(ordcntidx,1,eventcnt,ordact.order_id,temporderdata->qual[ordcntidx].order_id,
      ordact.action_sequence,temporderdata->qual[ordcntidx].action_seq))
     JOIN (clinevent
     WHERE clinevent.order_id=ordact.order_id)
     JOIN (ord
     WHERE ord.order_id=ordact.order_id)
    HEAD clinevent.event_id
     CALL updateorderdetails(ordact.order_id,ordact.action_sequence,ord.iv_ind,ord.hna_order_mnemonic,
     ord.ordered_as_mnemonic,ord.order_mnemonic,ordact.clinical_display_line)
     IF (debugind=1)
      CALL echo("*********End GetOrderDetails")
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE updateorderdetails(orderid,ordersequence,ivind,hnaordermnemonic,orderedasmnemonic,
  order_mnemonic,clinical_display_line)
   IF (debugind=1)
    CALL echo("*********Begin UpdateOrderDetails")
   ENDIF
   DECLARE ordidcnt = i4 WITH protect, noconstant(0)
   DECLARE ordid = f8 WITH protect, noconstant(0)
   DECLARE actionseq = i4 WITH protect, noconstant(0)
   FOR (ordidcnt = 1 TO eventcnt)
     SET ordid = temporderdata->qual[ordidcnt].order_id
     SET actionseq = temporderdata->qual[ordidcnt].action_seq
     IF (orderid=ordid
      AND ordersequence=actionseq)
      SET temporderdata->qual[ordidcnt].iv_ind = ivind
      SET temporderdata->qual[ordidcnt].hna_order_mnemonic = hnaordermnemonic
      SET temporderdata->qual[ordidcnt].ordered_as_mnemonic = orderedasmnemonic
      SET temporderdata->qual[ordidcnt].order_mnemonic = order_mnemonic
      SET temporderdata->qual[ordidcnt].clinical_display_line = clinical_display_line
     ENDIF
   ENDFOR
   IF (debugind=1)
    CALL echo("*********End UpdateOrderDetails")
   ENDIF
 END ;Subroutine
 SUBROUTINE getdurationdetails(null)
   IF (debugind=1)
    CALL echo("*********Begin GetDurationDetails")
   ENDIF
   DECLARE orddetidx = i4 WITH protect, noconstant(0)
   DECLARE ordcnt = i4 WITH protect, noconstant(size(temporderdata->qual,5))
   DECLARE orddetposidx = i4 WITH protect, noconstant(0)
   DECLARE orddetpos = i4 WITH protect, noconstant(0)
   DECLARE duration_meaning_id = i4 WITH protect, constant(2061)
   DECLARE duration_unit_meaning_id = i4 WITH protect, constant(2062)
   DECLARE sduration = vc WITH private, noconstant("")
   DECLARE sdurationunit = vc WITH private, noconstant("")
   DECLARE iordactseq = i4 WITH private, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ordcnt)),
     order_action ordact,
     order_detail orddet,
     clinical_event clinevent
    PLAN (d)
     JOIN (ordact
     WHERE (ordact.order_id=temporderdata->qual[d.seq].order_id)
      AND (ordact.action_sequence=temporderdata->qual[d.seq].action_seq))
     JOIN (orddet
     WHERE orddet.order_id=ordact.order_id
      AND orddet.oe_field_meaning_id IN (duration_meaning_id, duration_unit_meaning_id)
      AND (orddet.action_sequence=
     (SELECT
      max(orddet2.action_sequence)
      FROM order_detail orddet2
      WHERE orddet.order_id > 0.0
       AND orddet2.order_id=orddet.order_id
       AND orddet2.oe_field_id=orddet.oe_field_id
       AND orddet2.action_sequence <= ordact.action_sequence)))
     JOIN (clinevent
     WHERE clinevent.order_id=ordact.order_id)
    ORDER BY orddet.order_id, orddet.oe_field_id, orddet.action_sequence DESC
    HEAD clinevent.event_id
     orddetpos = locateval(orddetposidx,1,ordcnt,orddet.order_id,temporderdata->qual[orddetposidx].
      order_id), iordactseq = ordact.action_sequence
    DETAIL
     IF (orddetpos > 0)
      IF (orddet.oe_field_meaning_id=duration_meaning_id)
       sduration = orddet.oe_field_display_value
      ELSEIF (orddet.oe_field_meaning_id=duration_unit_meaning_id)
       sdurationunit = orddet.oe_field_display_value
      ENDIF
     ENDIF
    FOOT  clinevent.event_id
     CALL updatedurationdetails(orddet.order_id,iordactseq,sduration,sdurationunit)
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*********End GetDurationDetails")
   ENDIF
 END ;Subroutine
 SUBROUTINE updatedurationdetails(ordid,actionseq,sduration,sdurationunit)
   IF (debugind=1)
    CALL echo("*********Begin UpdateDurationDetails")
   ENDIF
   DECLARE ordidcnt = i4 WITH protect, noconstant(0)
   DECLARE orderid = f8 WITH protect, noconstant(0)
   DECLARE ordersequence = i4 WITH protect, noconstant(0)
   FOR (ordidcnt = 1 TO eventcnt)
     SET orderid = temporderdata->qual[ordidcnt].order_id
     SET ordersequence = temporderdata->qual[ordidcnt].action_seq
     IF (orderid=ordid
      AND ordersequence=actionseq)
      SET temporderdata->qual[ordidcnt].duration_val = sduration
      SET temporderdata->qual[ordidcnt].duration_unit = sdurationunit
     ENDIF
   ENDFOR
   IF (debugind=1)
    CALL echo("*********End UpdateDurationDetails")
   ENDIF
 END ;Subroutine
 SUBROUTINE getordercomment(null)
   IF (debugind=1)
    CALL echo("*********Begin GetOrderComment")
   ENDIF
   DECLARE ordcmtidx = i4 WITH protect, noconstant(0)
   DECLARE ordcnt = i4 WITH protect, noconstant(size(temporderdata->qual,5))
   DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ordcnt)),
     order_action ordact,
     order_comment ordcmt,
     long_text lngtxt,
     clinical_event clinevent
    PLAN (d)
     JOIN (ordact
     WHERE (ordact.order_id=temporderdata->qual[d.seq].order_id)
      AND (ordact.action_sequence=temporderdata->qual[d.seq].action_seq))
     JOIN (ordcmt
     WHERE ordcmt.order_id=ordact.order_id
      AND ordcmt.comment_type_cd=order_comment_cd
      AND (ordcmt.action_sequence=
     (SELECT
      max(oc2.action_sequence)
      FROM order_comment oc2
      WHERE oc2.order_id=ordcmt.order_id
       AND ordcmt.comment_type_cd=order_comment_cd
       AND oc2.action_sequence <= ordact.action_sequence)))
     JOIN (lngtxt
     WHERE lngtxt.long_text_id=ordcmt.long_text_id)
     JOIN (clinevent
     WHERE clinevent.order_id=ordact.order_id)
    ORDER BY ordcmt.order_id, ordcmt.action_sequence DESC
    HEAD clinevent.event_id
     CALL updateordercomment(ordact.order_id,ordact.action_sequence,lngtxt.long_text)
     IF (debugind=1)
      CALL echo("*********End GetOrderComment")
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE updateordercomment(orderid,ordersequence,order_comment_text)
   IF (debugind=1)
    CALL echo("*********Begin UpdateOrderComment")
   ENDIF
   DECLARE ordidcnt = i4 WITH protect, noconstant(0)
   DECLARE ordid = f8 WITH protect, noconstant(0)
   DECLARE actionseq = i4 WITH protect, noconstant(0)
   FOR (ordidcnt = 1 TO eventcnt)
     SET ordid = temporderdata->qual[ordidcnt].order_id
     SET actionseq = temporderdata->qual[ordidcnt].action_seq
     IF (orderid=ordid
      AND ordersequence=actionseq)
      SET temporderdata->qual[ordidcnt].order_comment = order_comment_text
     ENDIF
   ENDFOR
   IF (debugind=1)
    CALL echo("*********End UpdateOrderComment")
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereply(null)
   IF (debugind=1)
    CALL echo("*********Begin PopulateReply")
   ENDIF
   DECLARE orderdatacntrep = i4 WITH protect, noconstant(size(temporderdata->qual,5))
   DECLARE orderdataidx = i4 WITH protect, noconstant(0)
   DECLARE orderdatasupplycnt = i4 WITH protect, noconstant(0)
   DECLARE orderdatasupplyidx = i4 WITH protect, noconstant(0)
   DECLARE pharmrevieworder = i4 WITH protect, noconstant(0)
   DECLARE locationcd = f8 WITH protect, noconstant(0)
   FOR (orderdataidx = 1 TO orderdatacntrep)
     SET pharmrevieworder = (pharmrevieworder+ 1)
     SET stat = alterlist(reply->orders,pharmrevieworder)
     SET reply->orders[orderdataidx].order_id = temporderdata->qual[orderdataidx].order_id
     SET reply->orders[orderdataidx].action_seq = temporderdata->qual[orderdataidx].action_seq
     SET reply->orders[orderdataidx].iv_ind = temporderdata->qual[orderdataidx].iv_ind
     SET reply->orders[orderdataidx].hna_order_mnemonic = temporderdata->qual[orderdataidx].
     hna_order_mnemonic
     SET reply->orders[orderdataidx].ordered_as_mnemonic = temporderdata->qual[orderdataidx].
     ordered_as_mnemonic
     SET reply->orders[orderdataidx].order_mnemonic = temporderdata->qual[orderdataidx].
     order_mnemonic
     SET reply->orders[orderdataidx].clinical_display_line = temporderdata->qual[orderdataidx].
     clinical_display_line
     SET reply->orders[orderdataidx].order_comment = temporderdata->qual[orderdataidx].order_comment
     SET reply->orders[orderdataidx].event_id = temporderdata->qual[orderdataidx].event_id
     SET reply->orders[orderdataidx].clinical_event_id = temporderdata->qual[orderdataidx].
     clinical_event_id
     SET reply->orders[orderdataidx].event_dt_tm = temporderdata->qual[orderdataidx].event_dt_tm
     SET reply->orders[orderdataidx].performed_prsnl_id = temporderdata->qual[orderdataidx].
     performed_prsnl_id
     SET reply->orders[orderdataidx].performed_prsnl_name = temporderdata->qual[orderdataidx].
     performed_prsnl_name
     SET reply->orders[orderdataidx].not_given_ind = temporderdata->qual[orderdataidx].not_given_ind
     SET reply->orders[orderdataidx].not_given_reason_cd = temporderdata->qual[orderdataidx].
     not_given_reason_cd
     SET reply->orders[orderdataidx].not_given_reason_disp = temporderdata->qual[orderdataidx].
     not_given_reason_disp
     SET reply->orders[orderdataidx].location_cd = temporderdata->qual[orderdataidx].location_cd
     SET reply->orders[orderdataidx].location_display = temporderdata->qual[orderdataidx].
     location_display
     SET stat = alterlist(reply->orders[orderdataidx].nurse_comment_details,1)
     IF (size(temporderdata->qual[orderdataidx].nurse_comment_details,5) > 0)
      SET reply->orders[orderdataidx].nurse_comment_details[1].nurse_comment_text = temporderdata->
      qual[orderdataidx].nurse_comment_details[1].nurse_comment_text
      SET reply->orders[orderdataidx].nurse_comment_details[1].nurse_comment_prsnl_id = temporderdata
      ->qual[orderdataidx].nurse_comment_details[1].nurse_comment_prsnl_id
      SET reply->orders[orderdataidx].nurse_comment_details[1].nurse_comment_prsnl_name =
      temporderdata->qual[orderdataidx].nurse_comment_details[1].nurse_comment_prsnl_name
     ENDIF
     SET reply->orders[orderdataidx].order_modified_dt_tm = temporderdata->qual[orderdataidx].
     order_modified_dt_tm
     SET reply->orders[orderdataidx].pharm_supply_review_dt_tm = temporderdata->qual[orderdataidx].
     pharm_supply_review_dt_tm
     SET reply->orders[orderdataidx].pharm_supply_review_comment = temporderdata->qual[orderdataidx].
     pharm_supply_review_comment
     SET reply->orders[orderdataidx].duration_val = temporderdata->qual[orderdataidx].duration_val
     SET reply->orders[orderdataidx].duration_unit = temporderdata->qual[orderdataidx].duration_unit
     SET orderdatasupplycnt = size(temporderdata->qual[orderdataidx].additional_supply_loc,5)
     FOR (orderdatasupplyidx = 1 TO orderdatasupplycnt)
       SET locationcd = temporderdata->qual[orderdataidx].additional_supply_loc[orderdatasupplyidx].
       location_cd
       SET stat = alterlist(reply->orders[orderdataidx].additional_supply_loc,orderdatasupplyidx)
       SET reply->orders[orderdataidx].additional_supply_loc[orderdatasupplyidx].location_cd =
       locationcd
       SET reply->orders[orderdataidx].additional_supply_loc[orderdatasupplyidx].location_display =
       temporderdata->qual[orderdataidx].additional_supply_loc[orderdatasupplyidx].location_display
       SET reply->orders[orderdataidx].additional_supply_loc[orderdatasupplyidx].ord_signed_ind =
       temporderdata->qual[orderdataidx].additional_supply_loc[orderdatasupplyidx].ord_signed_ind
     ENDFOR
   ENDFOR
   IF (pharmrevieworder > 0)
    SET replycnt = 1
   ENDIF
   IF (debugind=1)
    CALL echo("*********End PopulateReply")
   ENDIF
 END ;Subroutine
#status_update
 SET errorcode = error(errormsg,1)
 IF (errorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",errormsg))
  CALL echo("*********************************")
  CALL fillsubeventstatus("ERROR","F","bsc_get_clinical_disch_meds",errormsg)
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
 SET last_mod = "006"
 SET lastmod = "07/22/2015"
 SET modify = nopredeclare
END GO
