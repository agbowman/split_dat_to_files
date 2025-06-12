CREATE PROGRAM bhs_athn_get_ord_details
 SET order_id = cnvtint( $2)
 FREE RECORD ord_det
 RECORD ord_det(
   1 order_id = f8
   1 targ_dose = c30
   1 actual_dose = c30
   1 nurse_review = c30
   1 doctor_cosign = c30
   1 pharmacy_review = c30
   1 qual[*]
     2 field_meaning_id = f8
     2 field_meaning = c30
     2 field_id = f8
     2 oe_field_disp_val = c50
     2 oe_field_val = c50
     2 oef_desc = c50
     2 action_seq = i2
     2 detail_sequence = i2
     2 lock_on_modify = i2
 )
 SELECT INTO "NL:"
  od.order_id, od.oe_field_meaning, od_field_display_value = trim(replace(replace(replace(replace(
       replace(od.oe_field_display_value,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3),
  od.oe_field_id, oef_desc = trim(replace(replace(replace(replace(replace(o.label_text,"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o.lock_on_modify_flag,
  nursereviewindicator = trim(replace(replace(replace(replace(replace(substring(0,25,
         IF (ord.need_nurse_review_ind=1) "NurseReviewRequired"
         ELSE "NurseReviewNotRequired"
         ENDIF
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  providercosignflag = trim(replace(replace(replace(replace(replace(substring(0,30,
         IF (ord.need_doctor_cosign_ind=0) "DoesNotNeedDoctorCosign"
         ELSEIF (ord.need_doctor_cosign_ind=1) "NeedsDoctorCosign"
         ELSEIF (ord.need_doctor_cosign_ind=2) "CosignRefusedByDoctor"
         ENDIF
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  pharmacyreviewflag = trim(replace(replace(replace(replace(replace(substring(0,30,
         IF (ord.need_rx_verify_ind=0) "PharmacistReviewNotRequired"
         ELSEIF (ord.need_rx_verify_ind=1) "NeedsPharmacistReview"
         ELSEIF (ord.need_rx_verify_ind=2) "RejectedByPharmacist"
         ENDIF
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM order_detail od,
   oe_format_fields o,
   orders ord
  PLAN (od
   WHERE od.order_id=order_id)
   JOIN (ord
   WHERE ord.order_id=od.order_id)
   JOIN (o
   WHERE o.oe_field_id=outerjoin(od.oe_field_id)
    AND o.oe_format_id=ord.oe_format_id)
  ORDER BY od.order_id, od.oe_field_meaning_id, od.action_sequence DESC,
   o.updt_dt_tm DESC, o.updt_cnt DESC
  HEAD REPORT
   i = 0
  DETAIL
   ord_det->order_id = od.order_id, ord_det->nurse_review = nursereviewindicator, ord_det->
   doctor_cosign = providercosignflag,
   ord_det->pharmacy_review = pharmacyreviewflag, i = (i+ 1), stat = alterlist(ord_det->qual,i),
   ord_det->qual[i].field_meaning_id = cnvtint(od.oe_field_meaning_id), ord_det->qual[i].
   field_meaning = od.oe_field_meaning, ord_det->qual[i].field_id = cnvtint(od.oe_field_id),
   ord_det->qual[i].oe_field_disp_val = od_field_display_value, ord_det->qual[i].oe_field_val =
   cnvtstring(od.oe_field_value), ord_det->qual[i].action_seq = od.action_sequence,
   ord_det->qual[i].detail_sequence = od.detail_sequence, ord_det->qual[i].oef_desc = trim(replace(
     replace(replace(replace(replace(o.label_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), ord_det->qual[i].lock_on_modify = o.lock_on_modify_flag
  WITH nocounter, time = 10
 ;end select
 SELECT INTO "NL:"
  FROM order_ingredient o,
   order_action oa,
   orders os,
   long_text lt
  PLAN (oa
   WHERE oa.order_id=order_id
    AND ((oa.action_type_cd=2534) OR (((oa.action_type_cd=2533) OR (((oa.action_type_cd=2535) OR (((
   oa.action_type_cd=2524) OR (((oa.action_type_cd=2528) OR (oa.action_type_cd=614536)) )) )) )) )) )
   JOIN (os
   WHERE os.order_id=oa.order_id)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.action_sequence=oa.action_sequence)
   JOIN (lt
   WHERE lt.long_text_id=o.dose_calculator_long_text_id)
  HEAD REPORT
   targetdosex = findstring("<TargetDose",lt.long_text), targetdosey = findstring(">",lt.long_text,
    targetdosex), targetdosez = findstring("</TargetDose",lt.long_text),
   target_dose1 = substring((targetdosey+ 1),(targetdosez - (targetdosey+ 1)),lt.long_text),
   targetdoseunitx = findstring("<TargetDoseUnitDisp",lt.long_text), targetdoseunity = findstring(">",
    lt.long_text,targetdoseunitx),
   targetdoseunitz = findstring("</TargetDoseUnitDisp",lt.long_text), target_dose_unit = substring((
    targetdoseunity+ 1),(targetdoseunitz - (targetdoseunity+ 1)),lt.long_text), actualdosex =
   findstring("<ActualFinalDose",lt.long_text),
   actualdosey = findstring(">",lt.long_text,actualdosex), actualdosez = findstring(
    "</ActualFinalDose",lt.long_text), actual_dose1 = substring((actualdosey+ 1),(actualdosez - (
    actualdosey+ 1)),lt.long_text),
   actualdoseunitx = findstring("<ActualFinalDoseUnitDisp",lt.long_text), actualdoseunity =
   findstring(">",lt.long_text,actualdoseunitx), actualdoseunitz = findstring(
    "</ActualFinalDoseUnitDisp",lt.long_text),
   actual_dose_unit = substring((actualdoseunity+ 1),(actualdoseunitz - (actualdoseunity+ 1)),lt
    .long_text)
   IF (target_dose1 != " ")
    ord_det->targ_dose = build(target_dose1,"|",target_dose_unit)
   ENDIF
   IF (actual_dose1 != " ")
    ord_det->actual_dose = trim(build(actual_dose1,"|",actual_dose_unit),3)
   ENDIF
   ord_det->order_id = o.order_id
  WITH time = 10
 ;end select
 IF (size(ord_det->qual,5) > 0)
  SELECT INTO  $1
   order_id = ord_det->order_id, target_dose = ord_det->targ_dose, actual_dose = ord_det->actual_dose,
   nurse_review_ind = ord_det->nurse_review, doctor_cosign_ind = ord_det->doctor_cosign,
   pharmacy_review_ind = ord_det->pharmacy_review,
   oef_desc = ord_det->qual[d1.seq].oef_desc, oe_field_val = ord_det->qual[d1.seq].oe_field_val,
   oe_field_disp_val = ord_det->qual[d1.seq].oe_field_disp_val,
   oe_field_meaning_id = ord_det->qual[d1.seq].field_meaning_id, oe_field_meaning = ord_det->qual[d1
   .seq].field_meaning, oe_field_id = ord_det->qual[d1.seq].field_id,
   detail_seq = ord_det->qual[d1.seq].detail_sequence, action_seq = ord_det->qual[d1.seq].action_seq,
   lock_on_modify = ord_det->qual[d1.seq].lock_on_modify
   FROM (dummyt d1  WITH seq = size(ord_det->qual,5))
   ORDER BY order_id, oe_field_id, oe_field_meaning_id,
    action_seq, detail_seq DESC
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<OrderId>",trim(replace(cnvtstring(ord_det->order_id),".0*","",0),3),
     "</OrderId>"), col + 1,
    v1, row + 1, v2 = build("<TargetDose>",trim(replace(replace(replace(replace(replace(ord_det->
           targ_dose,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
     "</TargetDose>"),
    col + 1, v2, row + 1,
    v3 = build("<ActualDose>",trim(replace(replace(replace(replace(replace(ord_det->actual_dose,"&",
           "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ActualDose>"),
    col + 1, v3,
    row + 1, v31 = build("<NurseReviewIndicator>",nurse_review_ind,"</NurseReviewIndicator>"), col +
    1,
    v31, row + 1, v32 = build("<ProviderCosignFlag>",doctor_cosign_ind,"</ProviderCosignFlag>"),
    col + 1, v32, row + 1,
    v33 = build("<PharmacistReviewFlag>",pharmacy_review_ind,"</PharmacistReviewFlag>"), col + 1, v33,
    row + 1, col + 1, "<UnknownOrderDetails>",
    row + 1
   HEAD oe_field_id
    col + 1, "<UnknownOrderDetail>", row + 1,
    v4 = build("<FieldMeaningId>",cnvtint(oe_field_meaning_id),"</FieldMeaningId>"), col + 1, v4,
    row + 1, v5 = build("<FieldMeaning>",trim(oe_field_meaning),"</FieldMeaning>"), col + 1,
    v5, row + 1, v6 = build("<FieldId>",cnvtint(oe_field_id),"</FieldId>"),
    col + 1, v6, row + 1,
    v7 = build("<DisplayValue>",oe_field_disp_val,"</DisplayValue>"), col + 1, v7,
    row + 1, v8 = build("<Value>",cnvtint(oe_field_val),"</Value>"), col + 1,
    v8, row + 1, v9 = build("<Description>",oef_desc,"</Description>"),
    col + 1, v9, row + 1,
    v10 = build("<ActionSequence>",cnvtint(action_seq),"</ActionSequence>"), col + 1, v10,
    row + 1, v11 = build("<DetailSequence>",cnvtint(detail_seq),"</DetailSequence>"), col + 1,
    v11, row + 1, v12 = build("<LockOnModify>",
     IF (lock_on_modify=1) "LOCKED"
     ELSE "UNLOCKED"
     ENDIF
     ,"</LockOnModify>"),
    col + 1, v12, row + 1,
    col + 1, "</UnknownOrderDetail>", row + 1
   FOOT REPORT
    col + 1, "</UnknownOrderDetails>", row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, maxrow = 0, nocounter,
    nullreport, formfeed = none, format = variable,
    time = 30
  ;end select
 ELSE
  SELECT INTO  $1
   FROM dummyt d1
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, col + 1, "<UnknownOrderDetails>",
    row + 1
   FOOT REPORT
    col + 1, "</UnknownOrderDetails>", row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, maxrow = 0, nocounter,
    nullreport, formfeed = none, format = variable,
    time = 30
  ;end select
 ENDIF
END GO
