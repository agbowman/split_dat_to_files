CREATE PROGRAM bhs_prax_get_ord_details
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
  ORDER BY od.order_id, od.oe_field_meaning_id, od.action_sequence DESC
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
   target_dose1 = substring(27,2,substring(cnvtint(findstring("<TargetDose",lt.long_text,0,0)),(
     cnvtint(findstring("</TargetDoseUnitDisp>",lt.long_text,0,0)) - cnvtint(findstring("<TargetDose",
       lt.long_text,0,0))),lt.long_text)), target_dose_unit = substring(143,5,concat(substring(
      cnvtint(findstring("<TargetDose",lt.long_text,0,0)),(cnvtint(findstring("</TargetDoseUnitDisp>",
        lt.long_text,0,0)) - cnvtint(findstring("<TargetDose",lt.long_text,0,0))),lt.long_text),
     "<TargetDoseUnitDisp>")), actual_dose1 = substring(32,2,substring(cnvtint(findstring(
       "<ActualFinalDose",lt.long_text,0,0)),(cnvtint(findstring("</ActualFinalDoseUnitDisp>",lt
       .long_text,0,0)) - cnvtint(findstring("<ActualFinalDose",lt.long_text,0,0))),lt.long_text)),
   actual_dose_unit = substring(168,5,concat(substring(cnvtint(findstring("<ActualFinalDose",lt
        .long_text,0,0)),(cnvtint(findstring("</ActualFinalDoseUnitDisp>",lt.long_text,0,0)) -
      cnvtint(findstring("<ActualFinalDose",lt.long_text,0,0))),lt.long_text),
     "</ActualFinalDoseUnitDisp>")), ord_det->targ_dose = trim(concat(target_dose1,target_dose_unit),
    3), ord_det->actual_dose = trim(concat(actual_dose1,actual_dose_unit),3),
   ord_det->order_id = o.order_id
  WITH time = 10
 ;end select
 IF (size(ord_det->qual,5) > 0)
  SELECT DISTINCT INTO  $1
   o_order_id = trim(replace(cnvtstring(o.order_id),".0*","",0),3), o.person_id, o.encntr_id,
   catalog_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o.catalog_cd),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o.catalog_cd, o
   .synonym_id,
   o.oe_format_id, hna_order_mnemonic = trim(replace(replace(replace(replace(replace(o
         .hna_order_mnemonic,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3), ordered_as_mnemonic = trim(replace(replace(replace(replace(replace(o.ordered_as_mnemonic,
         "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   order_mnemonic = trim(replace(replace(replace(replace(replace(os.mnemonic,"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), ordereddatetime = format(o
    .orig_order_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), orderedtimezone = substring(21,3,datetimezoneformat(
     o.orig_order_dt_tm,o.orig_order_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
   startdatetime = format(o.current_start_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), startdatetimezone =
   substring(21,3,datetimezoneformat(o.current_start_dt_tm,o.current_start_tz,
     "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), oa.action_personnel_id,
   originalorderingprovidername = trim(replace(replace(replace(replace(replace(prl
         .name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3), o.last_update_provider_id, lastupdateprsnlname = trim(replace(replace(replace(replace(
        replace(prl1.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
     '"',"&quot;",0),3),
   communication_type_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
          .latest_communication_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
     '"',"&quot;",0),3), communication_type_meaning = trim(replace(replace(replace(replace(replace(
         uar_get_code_meaning(o.latest_communication_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",
       0),"'","&apos;",0),'"',"&quot;",0),3), o.latest_communication_type_cd,
   orderstatus_display = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
          .order_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
     ),3), o.order_status_cd, nursereviewindicator = trim(replace(replace(replace(replace(replace(
         substring(0,25,
          IF (o.need_nurse_review_ind=1) "NurseReviewRequired"
          ELSE "NurseReviewNotRequired"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   providercosignflag = trim(replace(replace(replace(replace(replace(substring(0,30,
          IF (o.need_doctor_cosign_ind=0) "DoesNotNeedDoctorCosign"
          ELSEIF (o.need_doctor_cosign_ind=1) "NeedsDoctorCosign"
          ELSEIF (o.need_doctor_cosign_ind=2) "CosignRefusedByDoctor"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   pharmacyreviewflag = trim(replace(replace(replace(replace(replace(substring(0,30,
          IF (o.need_rx_verify_ind=0) "PharmacistReviewNotRequired"
          ELSEIF (o.need_rx_verify_ind=1) "NeedsPharmacistReview"
          ELSEIF (o.need_rx_verify_ind=2) "RejectedByPharmacist"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   clinicaldisplayline = trim(replace(replace(replace(replace(replace(o.clinical_display_line,"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   catalogtype_display = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
          .catalog_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
     ),3), catalogtype_meaning = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o
          .catalog_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
     ),3), o.catalog_type_cd,
   activitytype_display = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
          .activity_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3), o.activity_type_cd, clinicalcategory = trim(replace(replace(replace(replace(replace(
         uar_get_code_display(o.dcp_clin_cat_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3),
   o.dcp_clin_cat_cd, stop_type_disp = trim(replace(replace(replace(replace(replace(
         uar_get_code_display(o.stop_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
      0),'"',"&quot;",0),3), stoptype_meaning = trim(replace(replace(replace(replace(replace(
         uar_get_code_meaning(o.stop_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
      0),'"',"&quot;",0),3),
   o.stop_type_cd, orderable_type_flag = trim(replace(replace(replace(replace(replace(substring(0,8,
          IF (o.orderable_type_flag=0) "NORMAL"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), oa
   .action_sequence,
   updt_dt = format(o.updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), status_dt = format(o.status_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"), o.prescription_order_id,
   ac.accession_id, unformattednumber = trim(replace(replace(replace(replace(replace(ac.accession,"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), formattednumber
    =
   IF (ac.accession != " ") format(substring(6,14,ac.accession),"##-###-########")
   ELSE " "
   ENDIF
   ,
   activity_subtype = trim(replace(replace(replace(replace(replace(uar_get_code_display(oc
          .activity_subtype_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), oc.activity_subtype_cd, dept_status_disp = trim(replace(replace(replace(replace(
        replace(uar_get_code_display(o.dept_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3),
   dept_status_meaning = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o
          .dept_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
    3), o.dept_status_cd, departmentaldisplayline = trim(replace(replace(replace(replace(replace(o
         .order_detail_display_line,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3),
   template_order_flag = trim(replace(replace(replace(replace(replace(substring(0,25,
          IF (o.template_order_flag=0) "None"
          ELSEIF (o.template_order_flag=1) "Template"
          ELSEIF (o.template_order_flag=2) "Order Based Instance"
          ELSEIF (o.template_order_flag=3) "Task Based Instance"
          ELSEIF (o.template_order_flag=4) "Rx Based Instance"
          ELSEIF (o.template_order_flag=5) "Future Recurring Template"
          ELSEIF (o.template_order_flag=6) "Future Recurring Instance"
          ELSEIF (o.template_order_flag=7) "Protocol"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o
   .template_order_id, bill_only_ind = trim(replace(replace(replace(replace(replace(substring(0,5,
          IF (oc.bill_only_ind=1) "TRUE"
          ELSE "FALSE"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   lab_report_priority_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(ol
          .report_priority_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), ol.report_priority_cd, rad_report_priority_disp = trim(replace(replace(replace(
       replace(replace(uar_get_code_display(orr.priority_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",
       0),"'","&apos;",0),'"',"&quot;",0),3),
   lab_coll_priority_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(ol
          .collection_priority_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), ol.report_priority_cd, orr.priority_cd,
   disc_ind =
   IF (o.discontinue_ind=1) "TRUE"
   ELSE "FALSE"
   ENDIF
   , disc_datetime = format(o.discontinue_effective_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   disc_datetimezone = substring(21,3,datetimezoneformat(o.discontinue_effective_dt_tm,o
     .discontinue_effective_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
   disc_type_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
          .discontinue_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), witness_ind =
   IF (os.witness_flag=1) "TRUE"
   ELSE "FALSE"
   ENDIF
   , p.display_description,
   op_proposal_status_disp = uar_get_code_display(op.proposal_status_cd), oc.dc_display_days, oc
   .stop_duration,
   oc.stop_duration_unit_cd, stop_duration_unit = uar_get_code_meaning(oc.stop_duration_unit_cd), od1
   .action_sequence,
   oc_stop_type_meaning = uar_get_code_meaning(oc.stop_type_cd)
   FROM orders o,
    order_action oa,
    prsnl prl,
    prsnl prl1,
    accession_order_r aor,
    accession ac,
    order_catalog oc,
    order_radiology orr,
    order_laboratory ol,
    container_accession c,
    order_catalog_synonym os,
    pathway_catalog p,
    order_proposal op,
    frequency_schedule fs,
    order_detail od1
   PLAN (o
    WHERE o.order_id=order_id)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=2534.00)
    JOIN (prl
    WHERE prl.person_id=outerjoin(oa.order_provider_id))
    JOIN (prl1
    WHERE prl1.person_id=o.last_update_provider_id)
    JOIN (aor
    WHERE aor.order_id=outerjoin(o.order_id))
    JOIN (ac
    WHERE ac.accession_id=outerjoin(aor.accession_id))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (ol
    WHERE ol.order_id=outerjoin(o.order_id))
    JOIN (orr
    WHERE orr.order_id=outerjoin(o.order_id))
    JOIN (c
    WHERE c.accession_id=outerjoin(ac.accession_id))
    JOIN (os
    WHERE os.synonym_id=outerjoin(o.synonym_id)
     AND os.catalog_cd=outerjoin(o.catalog_cd))
    JOIN (p
    WHERE p.pathway_catalog_id=outerjoin(o.pathway_catalog_id))
    JOIN (op
    WHERE op.order_id=outerjoin(o.order_id)
     AND op.encntr_id=outerjoin(o.encntr_id))
    JOIN (fs
    WHERE fs.frequency_id=outerjoin(o.frequency_id)
     AND fs.active_ind=outerjoin(1))
    JOIN (od1
    WHERE od1.order_id=outerjoin(o.order_id)
     AND od1.oe_field_meaning=outerjoin("STOPDTTM"))
   ORDER BY o.dcp_clin_cat_cd, o.encntr_id, o.order_id
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   HEAD o.order_id
    v1 = build("<OrderId>",o_order_id,"</OrderId>"), col + 1, v1,
    row + 1, v2 = build("<PersonId>",cnvtint(o.person_id),"</PersonId>"), col + 1,
    v2, row + 1, v3 = build("<EncounterId>",cnvtint(o.encntr_id),"</EncounterId>"),
    col + 1, v3, row + 1,
    v4 = build("<","Catalog",">"), col + 1, v4,
    row + 1, v5 = build("<Display>",catalog_disp,"</Display>"), col + 1,
    v5, row + 1, v6 = build("<Value>",cnvtint(o.catalog_cd),"</Value>"),
    col + 1, v6, row + 1,
    v7 = build("</","Catalog",">"), col + 1, v7,
    row + 1, v8 = build("<OrderCatalogSynonymId>",cnvtint(o.synonym_id),"</OrderCatalogSynonymId>"),
    col + 1,
    v8, row + 1, v9 = build("<FormatId>",cnvtint(o.oe_format_id),"</FormatId>"),
    col + 1, v9, row + 1,
    v10 = build("<HNAOrderMnemonic>",hna_order_mnemonic,"</HNAOrderMnemonic>"), col + 1, v10,
    row + 1, v11 = build("<OrderedAsMnemonic>",ordered_as_mnemonic,"</OrderedAsMnemonic>"), col + 1,
    v11, row + 1, v1111 = build("<Mnemonic>",order_mnemonic,"</Mnemonic>"),
    col + 1, v1111, row + 1,
    v12 = build("<OrderedDateTime>",ordereddatetime,"</OrderedDateTime>"), col + 1, v12,
    row + 1, v13 = build("<OrderedTimeZone>",orderedtimezone,"</OrderedTimeZone>"), col + 1,
    v13, row + 1, v14 = build("<StartDateTime>",startdatetime,"</StartDateTime>"),
    col + 1, v14, row + 1,
    v15 = build("<StartDateTimeZone>",startdatetimezone,"</StartDateTimeZone>"), col + 1, v15,
    row + 1, v18 = build("<OriginalOrderingProviderId>",cnvtint(oa.order_provider_id),
     "</OriginalOrderingProviderId>"), col + 1,
    v18, row + 1, v19 = build("<OriginalOrderingProviderName>",originalorderingprovidername,
     "</OriginalOrderingProviderName>"),
    col + 1, v19, row + 1,
    v20 = build("<LastUpdateProviderId>",cnvtint(o.last_update_provider_id),"</LastUpdateProviderId>"
     ), col + 1, v20,
    row + 1, v21 = build("<LastUpdateProviderName>",lastupdateprsnlname,"</LastUpdateProviderName>"),
    col + 1,
    v21, row + 1, v22 = build("<","OriginalOrderCommunicationType",">"),
    col + 1, v22, row + 1,
    v23 = build("<Display>",communication_type_disp,"</Display>"), col + 1, v23,
    row + 1, v24 = build("<Meaning>",communication_type_meaning,"</Meaning>"), col + 1,
    v24, row + 1, v25 = build("<Value>",cnvtint(o.latest_communication_type_cd),"</Value>"),
    col + 1, v25, row + 1,
    v26 = build("</","OriginalOrderCommunicationType",">"), col + 1, v26,
    row + 1, v27 = build("<","OrderStatus",">"), col + 1,
    v27, row + 1, v28 = build("<Display>",orderstatus_display,"</Display>"),
    col + 1, v28, row + 1,
    v29 = build("<Meaning>",uar_get_code_meaning(o.order_status_cd),"</Meaning>"), col + 1, v29,
    row + 1, v30 = build("<Value>",cnvtint(o.order_status_cd),"</Value>"), col + 1,
    v30, row + 1, v31 = build("</","OrderStatus",">"),
    col + 1, v31, row + 1,
    v32 = build("<NurseReviewIndicator>",nursereviewindicator,"</NurseReviewIndicator>"), col + 1,
    v32,
    row + 1, v33 = build("<ProviderCosignFlag>",providercosignflag,"</ProviderCosignFlag>"), col + 1,
    v33, row + 1, v34 = build("<PharmacistReviewFlag>",pharmacyreviewflag,"</PharmacistReviewFlag>"),
    col + 1, v34, row + 1,
    v35 = build("<ClinicalDisplayLine>",clinicaldisplayline,"</ClinicalDisplayLine>"), col + 1, v35,
    row + 1, v36 = build("<","CatalogType",">"), col + 1,
    v36, row + 1, v37 = build("<Display>",catalogtype_display,"</Display>"),
    col + 1, v37, row + 1,
    v38 = build("<Meaning>",catalogtype_meaning,"</Meaning>"), col + 1, v38,
    row + 1, v39 = build("<Value>",cnvtint(o.catalog_type_cd),"</Value>"), col + 1,
    v39, row + 1, v40 = build("</","CatalogType",">"),
    col + 1, v40, row + 1,
    v41 = build("<","ActivityType",">"), col + 1, v41,
    row + 1, v42 = build("<Display>",activitytype_display,"</Display>"), col + 1,
    v42, row + 1, v43 = build("<Meaning>",uar_get_code_meaning(o.activity_type_cd),"</Meaning>"),
    col + 1, v43, row + 1,
    v44 = build("<Value>",cnvtint(o.activity_type_cd),"</Value>"), col + 1, v44,
    row + 1, v45 = build("</","ActivityType",">"), col + 1,
    v45, row + 1, v46 = build("<","ClinicalCategory",">"),
    col + 1, v46, row + 1,
    v47 = build("<Display>",clinicalcategory,"</Display>"), col + 1, v47,
    row + 1, v48 = build("<Meaning>",uar_get_code_meaning(o.dcp_clin_cat_cd),"</Meaning>"), col + 1,
    v48, row + 1, v49 = build("<Value>",cnvtint(o.dcp_clin_cat_cd),"</Value>"),
    col + 1, v49, row + 1,
    v50 = build("</","ClinicalCategory",">"), col + 1, v50,
    row + 1, v51 = build("<","StopType",">"), col + 1,
    v51, row + 1, v52 = build("<Display>",stop_type_disp,"</Display>"),
    col + 1, v52, row + 1,
    v53 = build("<Meaning>",stoptype_meaning,"</Meaning>"), col + 1, v53,
    row + 1, v54 = build("<Value>",cnvtint(o.stop_type_cd),"</Value>"), col + 1,
    v54, row + 1, v55 = build("</","StopType",">"),
    col + 1, v55, row + 1,
    v56 = build("<OrderableTypeFlag>",orderable_type_flag,"</OrderableTypeFlag>"), col + 1, v56,
    row + 1, v57 = build("<ActionSequence>",cnvtint(oa.action_sequence),"</ActionSequence>"), col + 1,
    v57, row + 1, v58 = build("<UpdateDateTime>",updt_dt,"</UpdateDateTime>"),
    col + 1, v58, row + 1,
    v59 = build("<StatusDateTime>",status_dt,"</StatusDateTime>"), col + 1, v59,
    row + 1, v60 = build("<PrescriptionOrderId>",cnvtint(o.prescription_order_id),
     "</PrescriptionOrderId>"), col + 1,
    v60, row + 1, v61 = build("<","Accession",">"),
    col + 1, v61, row + 1,
    v62 = build("<AccessionId>",cnvtint(ac.accession_id),"</AccessionId>"), col + 1, v62,
    row + 1, v63 = build("<UnformattedNumber>",unformattednumber,"</UnformattedNumber>"), col + 1,
    v63, row + 1, v64 = build("<FormattedNumber>",formattednumber,"</FormattedNumber>"),
    col + 1, v64, row + 1,
    v65 = build("</","Accession",">"), col + 1, v65,
    row + 1, v66 = build("<","ActivitySubType",">"), col + 1,
    v66, row + 1, v67 = build("<Display>",activity_subtype,"</Display>"),
    col + 1, v67, row + 1,
    v68 = build("<Meaning>",uar_get_code_meaning(oc.activity_subtype_cd),"</Meaning>"), col + 1, v68,
    row + 1, v69 = build("<Value>",cnvtint(oc.activity_subtype_cd),"</Value>"), col + 1,
    v69, row + 1, v70 = build("</","ActivitySubType",">"),
    col + 1, v70, row + 1,
    v71 = build("<","DepartmentStatus",">"), col + 1, v71,
    row + 1, v72 = build("<Display>",dept_status_disp,"</Display>"), col + 1,
    v72, row + 1, v73 = build("<Meaning>",dept_status_meaning,"</Meaning>"),
    col + 1, v73, row + 1,
    v74 = build("<Value>",cnvtint(o.dept_status_cd),"</Value>"), col + 1, v74,
    row + 1, v75 = build("</","DepartmentStatus",">"), col + 1,
    v75, row + 1, v76 = build("<DepartmentalDisplayLine>",departmentaldisplayline,
     "</DepartmentalDisplayLine>"),
    col + 1, v76, row + 1,
    v77 = build("<TemplateOrderFlag>",template_order_flag,"</TemplateOrderFlag>"), col + 1, v77,
    row + 1, v78 = build("<TemplateOrderId>",cnvtint(o.template_order_id),"</TemplateOrderId>"), col
     + 1,
    v78, row + 1, v79 = build("<BillOnlyIndicator>",bill_only_ind,"</BillOnlyIndicator>"),
    col + 1, v79, row + 1,
    v98 = build("<DiscontinueIndicator>",disc_ind,"</DiscontinueIndicator>"), col + 1, v98,
    row + 1, v99 = build("<DiscontinueDateTime>",disc_datetime,"</DiscontinueDateTime>"), col + 1,
    v99, row + 1, v100 = build("<DiscontinueDateTimeZone>",disc_datetimezone,
     "</DiscontinueDateTimeZone>"),
    col + 1, v100, row + 1,
    v101 = build("<DiscontinueType>",disc_type_disp,"</DiscontinueType>"), col + 1, v101,
    row + 1, v102 = build("<WitnessFlag>",witness_ind,"</WitnessFlag>"), col + 1,
    v102, row + 1, v103 = build("<PathwayPlan>",p.display_description,"</PathwayPlan>"),
    col + 1, v103, row + 1,
    v104 = build("<ProposalStatus>",op_proposal_status_disp,"</ProposalStatus>"), col + 1, v104,
    row + 1, v105 = build("<DCDisplayDays>",cnvtint(oc.dc_display_days),"</DCDisplayDays>"), col + 1,
    v105, row + 1, v106 = build("<DefaultStopDuration>",cnvtint(oc.stop_duration),
     "</DefaultStopDuration>"),
    col + 1, v106, row + 1,
    v107 = build("<StopDurationUnitCd>",cnvtint(oc.stop_duration_unit_cd),"</StopDurationUnitCd>"),
    col + 1, v107,
    row + 1, v108 = build("<StopDurationUnit>",stop_duration_unit,"</StopDurationUnit>"), col + 1,
    v108, row + 1, v1081 = build("<CatStopTypeCd>",cnvtint(oc.stop_type_cd),"</CatStopTypeCd>"),
    col + 1, v1081, row + 1,
    v1082 = build("<CatStopTypeMeaning>",oc_stop_type_meaning,"</CatStopTypeMeaning>"), col + 1,
    v1082,
    row + 1
    IF (o.dcp_clin_cat_cd=10576)
     v80 = build("<","ReportingPriority",">"), col + 1, v80,
     row + 1, v81 = build("<Display>",lab_report_priority_disp,"</Display>"), col + 1,
     v81, row + 1, v82 = build("<Meaning>",uar_get_code_meaning(ol.report_priority_cd),"</Meaning>"),
     col + 1, v82, row + 1,
     v83 = build("<Value>",cnvtint(ol.report_priority_cd),"</Value>"), col + 1, v83,
     row + 1, v84 = build("</","ReportingPriority",">"), col + 1,
     v84, row + 1, v85 = build("<","CollectionPriority",">"),
     col + 1, v85, row + 1,
     v86 = build("<Display>",lab_coll_priority_disp,"</Display>"), col + 1, v86,
     row + 1, v87 = build("<Meaning>",uar_get_code_meaning(ol.collection_priority_cd),"</Meaning>"),
     col + 1,
     v87, row + 1, v88 = build("<Value>",cnvtint(ol.collection_priority_cd),"</Value>"),
     col + 1, v88, row + 1,
     v89 = build("</","CollectionPriority",">"), col + 1, v89,
     row + 1
    ENDIF
    IF (o.dcp_clin_cat_cd=10573)
     v90 = build("<","ReportingPriority",">"), col + 1, v90,
     row + 1, v91 = build("<Display>",rad_report_priority_disp,"</Display>"), col + 1,
     v91, row + 1, v92 = build("<Meaning>",uar_get_code_meaning(orr.priority_cd),"</Meaning>"),
     col + 1, v92, row + 1,
     v93 = build("<Value>",cnvtint(orr.priority_cd),"</Value>"), col + 1, v93,
     row + 1, v94 = build("</","ReportingPriority",">"), col + 1,
     v94, row + 1
    ENDIF
    v941 = build("<Frequency>",cnvtint(fs.frequency_cd),"</Frequency>"), col + 1, v941,
    row + 1, v16 = build("<StopDateTime>",format(od1.oe_field_dt_tm_value,"MM/DD/YYYY HH:MM;;D"),
     "</StopDateTime>"), v17 = build("<StopDateTimeZone>",substring(21,3,datetimezoneformat(od1
       .oe_field_dt_tm_value,od1.oe_field_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
     "</StopDateTimeZone>"),
    col + 1, v16, row + 1,
    col + 1, v17, row + 1
   WITH maxcol = 32000, maxrow = 0, nocounter,
    nullreport, formfeed = none, format = variable,
    time = 30, append
  ;end select
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
     '"',"UTF-8",'"'," ?>"), v2 = build("<TargetDose>",trim(replace(replace(replace(replace(replace(
           ord_det->targ_dose,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
       0),3),"</TargetDose>"), col + 1,
    v2, row + 1, v3 = build("<ActualDose>",trim(replace(replace(replace(replace(replace(ord_det->
           actual_dose,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
     "</ActualDose>"),
    col + 1, v3, row + 1,
    col + 1, "<UnknownOrderDetails>", row + 1
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
    time = 30, append
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
