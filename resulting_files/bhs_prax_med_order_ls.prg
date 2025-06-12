CREATE PROGRAM bhs_prax_med_order_ls
 DECLARE order_status_list = vc WITH constant( $5)
 DECLARE active_ord_status = vc WITH noconstant("1")
 FREE RECORD act_order_status_ls
 RECORD act_order_status_ls(
   1 qual[6]
     2 order_status_cd = vc
 )
 SET act_order_status_ls->qual[0].order_status_cd = "1"
 SET act_order_status_ls->qual[1].order_status_cd = "2546"
 SET act_order_status_ls->qual[2].order_status_cd = "2547"
 SET act_order_status_ls->qual[3].order_status_cd = "2548"
 SET act_order_status_ls->qual[4].order_status_cd = "2549"
 SET act_order_status_ls->qual[5].order_status_cd = "2550"
 SET act_order_status_ls->qual[6].order_status_cd = "2552"
 FOR (i = 0 TO 6)
  SET act_ord_status = act_order_status_ls->qual[i].order_status_cd
  IF (findstring(act_ord_status,order_status_list) > 0)
   SET active_ord_status = build(active_ord_status,",",act_ord_status)
  ENDIF
 ENDFOR
 SET where_act_ord_params = build(" O.order_status_cd IN (",trim(active_ord_status),") ")
 DECLARE other_ord_status = vc WITH noconstant("1")
 FREE RECORD oth_order_status_ls1
 RECORD oth_order_status_ls1(
   1 qual[6]
     2 order_status_cd = vc
 )
 FREE RECORD oth_order_status_ls2
 RECORD oth_order_status_ls2(
   1 qual[3]
     2 order_status_cd = vc
 )
 SET oth_order_status_ls1->qual[0].order_status_cd = "1"
 SET oth_order_status_ls1->qual[1].order_status_cd = "2542"
 SET oth_order_status_ls1->qual[2].order_status_cd = "2543"
 SET oth_order_status_ls1->qual[3].order_status_cd = "2544"
 SET oth_order_status_ls1->qual[4].order_status_cd = "2545"
 SET oth_order_status_ls1->qual[5].order_status_cd = "2551"
 SET oth_order_status_ls1->qual[6].order_status_cd = "2553"
 SET oth_order_status_ls2->qual[0].order_status_cd = "1"
 SET oth_order_status_ls2->qual[1].order_status_cd = "614538"
 SET oth_order_status_ls2->qual[2].order_status_cd = "643466"
 SET oth_order_status_ls2->qual[3].order_status_cd = "643467"
 FOR (i = 0 TO 6)
  SET oth_ord_status1 = oth_order_status_ls1->qual[i].order_status_cd
  IF (findstring(oth_ord_status1,order_status_list) > 0)
   SET other_ord_status = build(other_ord_status,",",oth_ord_status1)
  ENDIF
 ENDFOR
 FOR (i = 0 TO 3)
  SET oth_ord_status2 = oth_order_status_ls2->qual[i].order_status_cd
  IF (findstring(oth_ord_status2,order_status_list) > 0)
   SET other_ord_status = build(other_ord_status,",",oth_ord_status2)
  ENDIF
 ENDFOR
 SET where_oth_ord_params = build(" O.order_status_cd IN (",trim(other_ord_status),") ")
 SET where_params = build(" O.CATALOG_TYPE_CD IN ", $4)
 IF (( $3 != 0))
  SET where_params1 = build("(O.ENCNTR_ID =", $3," OR O.ENCNTR_ID=0) AND O.PERSON_ID=", $2)
 ELSE
  SET where_params1 = build("O.PERSON_ID =", $2)
 ENDIF
 DECLARE ncollect_ind = i4
 DECLARE request_st_ind = i4
 DECLARE vcnt = i4
 DECLARE dx_str = vc
 FREE RECORD order_list
 RECORD order_list(
   1 qual[*]
     2 order_id = f8
     2 dx_string = c5000
 )
 SELECT INTO "nl:"
  o.order_id
  FROM orders o
  PLAN (o
   WHERE parser(where_params)
    AND parser(where_params1)
    AND parser(where_oth_ord_params)
    AND o.updt_dt_tm BETWEEN cnvtdatetime( $6) AND cnvtdatetime( $7)
    AND o.template_order_flag IN (0, 1))
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(order_list->qual,vcnt), order_list->qual[vcnt].order_id = o
   .order_id
  WITH nocounter, separator = " ", format,
   time = 60
 ;end select
 SELECT INTO "nl:"
  o.order_id
  FROM orders o
  PLAN (o
   WHERE parser(where_params)
    AND parser(where_params1)
    AND parser(where_act_ord_params)
    AND o.template_order_flag IN (0, 1))
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(order_list->qual,vcnt), order_list->qual[vcnt].order_id = o
   .order_id
  WITH nocounter, separator = " ", format,
   time = 60
 ;end select
 SELECT INTO "nl:"
  n.source_identifier, n.source_string, n.nomenclature_id,
  d.entity1_id, rank = trim(cnvtstring(d.rank_sequence))
  FROM (dummyt d1  WITH seq = size(order_list->qual,5)),
   dcp_entity_reltn d,
   diagnosis dx,
   nomenclature n
  PLAN (d1)
   JOIN (d
   WHERE (d.entity1_id=order_list->qual[d1.seq].order_id)
    AND d.entity_reltn_mean="ORDERS/DIAGN")
   JOIN (dx
   WHERE dx.diagnosis_id=d.entity2_id)
   JOIN (n
   WHERE n.nomenclature_id=dx.nomenclature_id)
  ORDER BY d.entity1_id
  HEAD d.entity1_id
   dx_str = ""
  DETAIL
   dx_str = concat(dx_str,trim(cnvtstring(d.entity2_id),3),"|",trim(n.source_identifier,3),"|",
    trim(d.entity2_display,3),"|",trim(rank),"||")
  FOOT  d.entity1_id
   order_list->qual[d1.seq].dx_string = dx_str
  WITH nocounter, separator = " ", format,
   time = 10
 ;end select
 SELECT DISTINCT INTO  $1
  o_order_id = trim(replace(cnvtstring(o.order_id),".0*","",0),3), o.person_id, o.encntr_id,
  catalog_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o.catalog_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o.catalog_cd, o
  .synonym_id,
  o.oe_format_id, hna_order_mnemonic = trim(replace(replace(replace(replace(replace(o
        .hna_order_mnemonic,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), ordered_as_mnemonic = trim(replace(replace(replace(replace(replace(o.ordered_as_mnemonic,
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  order_mnemonic = trim(replace(replace(replace(replace(replace(os.mnemonic,"&","&amp;",0),"<","&lt;",
       0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), ordereddatetime = format(o
   .orig_order_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), orderedtimezone = substring(21,3,datetimezoneformat(o
    .orig_order_dt_tm,o.orig_order_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
  startdatetime = format(o.current_start_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), startdatetimezone =
  substring(21,3,datetimezoneformat(o.current_start_dt_tm,o.current_start_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), oa.action_personnel_id,
  originalorderingprovidername = trim(replace(replace(replace(replace(replace(prl.name_full_formatted,
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o
  .last_update_provider_id, lastupdateprsnlname = trim(replace(replace(replace(replace(replace(prl1
        .name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3),
  communication_type_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
         .latest_communication_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3), communication_type_meaning = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(o.latest_communication_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",
      0),"'","&apos;",0),'"',"&quot;",0),3), o.latest_communication_type_cd,
  orderstatus_display = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
         .order_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), o.order_status_cd, nursereviewindicator = trim(replace(replace(replace(replace(replace(
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
         .catalog_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), o.catalog_type_cd, activitytype_display = trim(replace(replace(replace(replace(replace(
        uar_get_code_display(o.activity_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  o.activity_type_cd, clinicalcategory = trim(replace(replace(replace(replace(replace(
        uar_get_code_display(o.dcp_clin_cat_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), o.dcp_clin_cat_cd,
  stop_type_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o.stop_type_cd),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  stoptype_meaning = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o.stop_type_cd
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o
  .stop_type_cd,
  orderable_type_flag = trim(replace(replace(replace(replace(replace(substring(0,8,
         IF (o.orderable_type_flag=0) "NORMAL"
         ENDIF
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), oa
  .action_sequence, updt_dt = format(o.updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
  status_dt = format(o.status_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), o.prescription_order_id,
  dept_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
         .dept_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3),
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
  od.oe_field_meaning, od_field_display_value = trim(replace(replace(replace(replace(replace(od
        .oe_field_display_value,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), od.oe_field_id,
  disc_ind =
  IF (o.discontinue_ind=1) "TRUE"
  ELSE "FALSE"
  ENDIF
  , disc_datetime = format(o.discontinue_effective_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), disc_datetimezone
   = substring(21,3,datetimezoneformat(o.discontinue_effective_dt_tm,o.discontinue_effective_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
  disc_type_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
         .discontinue_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), witness_ind =
  IF (os.witness_flag=1) "TRUE"
  ELSE "FALSE"
  ENDIF
  , off_label_text = trim(replace(replace(replace(replace(replace(off.label_text,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  off_lock_on_modify =
  IF (off.lock_on_modify_flag=1) "LOCKED"
  ELSE "UNLOCKED"
  ENDIF
  , o.prn_ind, order_cki = trim(replace(replace(replace(replace(replace(o.cki,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  med_order_type_meaning = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o
         .med_order_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), o.med_order_type_cd, original_ordered_as_flag = trim(replace(replace(replace(replace(
       replace(substring(0,30,
         IF (o.orig_ord_as_flag=0) "NormalOrder"
         ELSEIF (o.orig_ord_as_flag=1) "PrescriptionDischarge"
         ELSEIF (o.orig_ord_as_flag=2) "RecordedOrHomeMeds"
         ELSEIF (o.orig_ord_as_flag=3) "PatientOwnsMeds"
         ELSEIF (o.orig_ord_as_flag=4) "PharmacyChargeOnly"
         ELSEIF (o.orig_ord_as_flag=5) "SatelliteSuperBillsMeds"
         ENDIF
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p.display_description, op_proposal_status_disp = uar_get_code_display(op.proposal_status_cd), oc
  .dc_display_days,
  oc.stop_duration, oc.stop_duration_unit_cd, stop_duration_unit = uar_get_code_display(oc
   .stop_duration_unit_cd),
  t.reference_task_id, od1.action_sequence, dx_string = trim(replace(replace(replace(replace(replace(
        order_list->qual[d1.seq].dx_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3)
  FROM (dummyt d1  WITH seq = size(order_list->qual,5)),
   orders o,
   order_detail od,
   order_action oa,
   prsnl prl,
   prsnl prl1,
   order_catalog oc,
   order_catalog_synonym os,
   pathway_catalog p,
   order_proposal op,
   task_activity t,
   oe_format_fields off,
   frequency_schedule fs,
   order_detail od1
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=order_list->qual[d1.seq].order_id))
   JOIN (od
   WHERE od.order_id=outerjoin(o.order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=2534.00)
   JOIN (prl
   WHERE prl.person_id=outerjoin(oa.order_provider_id))
   JOIN (prl1
   WHERE prl1.person_id=outerjoin(o.last_update_provider_id))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (os
   WHERE os.synonym_id=outerjoin(o.synonym_id)
    AND os.catalog_cd=outerjoin(o.catalog_cd))
   JOIN (off
   WHERE off.oe_format_id=outerjoin(o.oe_format_id)
    AND off.oe_field_id=od.oe_field_id)
   JOIN (p
   WHERE p.pathway_catalog_id=outerjoin(o.pathway_catalog_id))
   JOIN (op
   WHERE op.order_id=outerjoin(o.order_id)
    AND op.encntr_id=outerjoin(o.encntr_id))
   JOIN (t
   WHERE t.order_id=outerjoin(o.order_id))
   JOIN (fs
   WHERE fs.frequency_id=outerjoin(o.frequency_id)
    AND fs.active_ind=outerjoin(1))
   JOIN (od1
   WHERE od1.order_id=outerjoin(o.order_id)
    AND od1.oe_field_meaning=outerjoin("STOPDTTM"))
  ORDER BY o.catalog_type_cd, o.encntr_id, o.order_id,
   od.oe_field_id, od.oe_field_meaning_id, od.action_sequence DESC,
   od1.action_sequence DESC, uar_get_code_display(off.action_type_cd) DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD o.order_id
   header_grp = build("<","StandardMedOrder",">"), col + 1, header_grp,
   row + 1, v1 = build("<OrderId>",o_order_id,"</OrderId>"), col + 1,
   v1, row + 1, v2 = build("<PersonId>",cnvtint(o.person_id),"</PersonId>"),
   col + 1, v2, row + 1,
   v3 = build("<EncounterId>",cnvtint(o.encntr_id),"</EncounterId>"), col + 1, v3,
   row + 1, v4 = build("<","Catalog",">"), col + 1,
   v4, row + 1, v5 = build("<Display>",catalog_disp,"</Display>"),
   col + 1, v5, row + 1,
   v6 = build("<Value>",cnvtint(o.catalog_cd),"</Value>"), col + 1, v6,
   row + 1, v7 = build("</","Catalog",">"), col + 1,
   v7, row + 1, v8 = build("<OrderCatalogSynonymId>",cnvtint(o.synonym_id),"</OrderCatalogSynonymId>"
    ),
   col + 1, v8, row + 1,
   v9 = build("<FormatId>",cnvtint(o.oe_format_id),"</FormatId>"), col + 1, v9,
   row + 1, v10 = build("<HNAOrderMnemonic>",hna_order_mnemonic,"</HNAOrderMnemonic>"), col + 1,
   v10, row + 1, v11 = build("<OrderedAsMnemonic>",ordered_as_mnemonic,"</OrderedAsMnemonic>"),
   col + 1, v11, row + 1,
   v1111 = build("<Mnemonic>",order_mnemonic,"</Mnemonic>"), col + 1, v1111,
   row + 1, v12 = build("<OrderedDateTime>",ordereddatetime,"</OrderedDateTime>"), col + 1,
   v12, row + 1, v13 = build("<OrderedTimeZone>",orderedtimezone,"</OrderedTimeZone>"),
   col + 1, v13, row + 1,
   v14 = build("<StartDateTime>",startdatetime,"</StartDateTime>"), col + 1, v14,
   row + 1, v15 = build("<StartDateTimeZone>",startdatetimezone,"</StartDateTimeZone>"), col + 1,
   v15, row + 1, v15_1 = build("<DxString>",dx_string,"</DxString>"),
   col + 1, v15_1, row + 1,
   v18 = build("<OriginalOrderingProviderId>",cnvtint(oa.order_provider_id),
    "</OriginalOrderingProviderId>"), col + 1, v18,
   row + 1, v19 = build("<OriginalOrderingProviderName>",originalorderingprovidername,
    "</OriginalOrderingProviderName>"), col + 1,
   v19, row + 1, v20 = build("<LastUpdateProviderId>",cnvtint(o.last_update_provider_id),
    "</LastUpdateProviderId>"),
   col + 1, v20, row + 1,
   v21 = build("<LastUpdateProviderName>",lastupdateprsnlname,"</LastUpdateProviderName>"), col + 1,
   v21,
   row + 1, v22 = build("<","OriginalOrderCommunicationType",">"), col + 1,
   v22, row + 1, v23 = build("<Display>",communication_type_disp,"</Display>"),
   col + 1, v23, row + 1,
   v24 = build("<Meaning>",communication_type_meaning,"</Meaning>"), col + 1, v24,
   row + 1, v25 = build("<Value>",cnvtint(o.latest_communication_type_cd),"</Value>"), col + 1,
   v25, row + 1, v26 = build("</","OriginalOrderCommunicationType",">"),
   col + 1, v26, row + 1,
   v27 = build("<","OrderStatus",">"), col + 1, v27,
   row + 1, v28 = build("<Display>",orderstatus_display,"</Display>"), col + 1,
   v28, row + 1, v29 = build("<Meaning>",uar_get_code_meaning(o.order_status_cd),"</Meaning>"),
   col + 1, v29, row + 1,
   v30 = build("<Value>",cnvtint(o.order_status_cd),"</Value>"), col + 1, v30,
   row + 1, v31 = build("</","OrderStatus",">"), col + 1,
   v31, row + 1, v32 = build("<NurseReviewIndicator>",nursereviewindicator,"</NurseReviewIndicator>"),
   col + 1, v32, row + 1,
   v33 = build("<ProviderCosignFlag>",providercosignflag,"</ProviderCosignFlag>"), col + 1, v33,
   row + 1, v34 = build("<PharmacistReviewFlag>",pharmacyreviewflag,"</PharmacistReviewFlag>"), col
    + 1,
   v34, row + 1, v35 = build("<ClinicalDisplayLine>",clinicaldisplayline,"</ClinicalDisplayLine>"),
   col + 1, v35, row + 1,
   v36 = build("<","CatalogType",">"), col + 1, v36,
   row + 1, v37 = build("<Display>",catalogtype_display,"</Display>"), col + 1,
   v37, row + 1, v38 = build("<Meaning>",uar_get_code_meaning(o.catalog_type_cd),"</Meaning>"),
   col + 1, v38, row + 1,
   v39 = build("<Value>",cnvtint(o.catalog_type_cd),"</Value>"), col + 1, v39,
   row + 1, v40 = build("</","CatalogType",">"), col + 1,
   v40, row + 1, v41 = build("<","ActivityType",">"),
   col + 1, v41, row + 1,
   v42 = build("<Display>",activitytype_display,"</Display>"), col + 1, v42,
   row + 1, v43 = build("<Meaning>",uar_get_code_meaning(o.activity_type_cd),"</Meaning>"), col + 1,
   v43, row + 1, v44 = build("<Value>",cnvtint(o.activity_type_cd),"</Value>"),
   col + 1, v44, row + 1,
   v45 = build("</","ActivityType",">"), col + 1, v45,
   row + 1, v46 = build("<","ClinicalCategory",">"), col + 1,
   v46, row + 1, v47 = build("<Display>",clinicalcategory,"</Display>"),
   col + 1, v47, row + 1,
   v48 = build("<Meaning>",uar_get_code_meaning(o.dcp_clin_cat_cd),"</Meaning>"), col + 1, v48,
   row + 1, v49 = build("<Value>",cnvtint(o.dcp_clin_cat_cd),"</Value>"), col + 1,
   v49, row + 1, v50 = build("</","ClinicalCategory",">"),
   col + 1, v50, row + 1,
   v501 = build("<OrderCatalogCKI>",order_cki,"</OrderCatalogCKI>"), col + 1, v501,
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
   v60, row + 1, v601 = build("<PRNIndicator>",
    IF (o.prn_ind=1) "true"
    ELSE "false"
    ENDIF
    ,"</PRNIndicator>"),
   col + 1, v601, row + 1,
   v602 = build("<","MedicationOrderType",">"), col + 1, v602,
   row + 1, v603 = build("<Meaning>",med_order_type_meaning,"</Meaning>"), col + 1,
   v603, row + 1, v604 = build("<Value>",cnvtint(o.med_order_type_cd),"</Value>"),
   col + 1, v604, row + 1,
   v605 = build("</","MedicationOrderType",">"), col + 1, v605,
   row + 1, v606 = build("<MedicationOrderedAsFlag>",original_ordered_as_flag,
    "</MedicationOrderedAsFlag>"), col + 1,
   v606, row + 1, v607 = build("<FrequencyTypeFlag>",cnvtint(o.freq_type_flag),"</FrequencyTypeFlag>"
    ),
   col + 1, v607, row + 1,
   v608 = build("<IVIndicator>",
    IF (o.iv_ind=1) "true"
    ELSE "false"
    ENDIF
    ,"</IVIndicator>"), col + 1, v608,
   row + 1, v71 = build("<","DepartmentStatus",">"), col + 1,
   v71, row + 1, v72 = build("<Display>",dept_status_disp,"</Display>"),
   col + 1, v72, row + 1,
   v73 = build("<Meaning>",dept_status_meaning,"</Meaning>"), col + 1, v73,
   row + 1, v74 = build("<Value>",cnvtint(o.dept_status_cd),"</Value>"), col + 1,
   v74, row + 1, v75 = build("</","DepartmentStatus",">"),
   col + 1, v75, row + 1,
   v76 = build("<DepartmentalDisplayLine>",departmentaldisplayline,"</DepartmentalDisplayLine>"), col
    + 1, v76,
   row + 1, v77 = build("<TemplateOrderFlag>",template_order_flag,"</TemplateOrderFlag>"), col + 1,
   v77, row + 1, v78 = build("<TemplateOrderId>",cnvtint(o.template_order_id),"</TemplateOrderId>"),
   col + 1, v78, row + 1,
   v79 = build("<BillOnlyIndicator>",bill_only_ind,"</BillOnlyIndicator>"), col + 1, v79,
   row + 1, v98 = build("<DiscontinueIndicator>",disc_ind,"</DiscontinueIndicator>"), col + 1,
   v98, row + 1, v99 = build("<DiscontinueDateTime>",disc_datetime,"</DiscontinueDateTime>"),
   col + 1, v99, row + 1,
   v100 = build("<DiscontinueDateTimeZone>",disc_datetimezone,"</DiscontinueDateTimeZone>"), col + 1,
   v100,
   row + 1, v101 = build("<DiscontinueType>",disc_type_disp,"</DiscontinueType>"), col + 1,
   v101, row + 1, v102 = build("<WitnessFlag>",witness_ind,"</WitnessFlag>"),
   col + 1, v102, row + 1,
   v103 = build("<PathwayPlan>",p.display_description,"</PathwayPlan>"), col + 1, v103,
   row + 1, v104 = build("<ProposalStatus>",op_proposal_status_disp,"</ProposalStatus>"), col + 1,
   v104, row + 1, v105 = build("<IngredientDisplay>",1,"</IngredientDisplay>"),
   col + 1, v105, row + 1,
   v106 = build("<DCDisplayDays>",cnvtint(oc.dc_display_days),"</DCDisplayDays>"), col + 1, v106,
   row + 1, v107 = build("<DefaultStopDuration>",cnvtint(oc.stop_duration),"</DefaultStopDuration>"),
   col + 1,
   v107, row + 1, v108 = build("<StopDurationUnitCd>",cnvtint(oc.stop_duration_unit_cd),
    "</StopDurationUnitCd>"),
   col + 1, v108, row + 1,
   v109 = build("<StopDurationUnit>",stop_duration_unit,"</StopDurationUnit>"), col + 1, v109,
   row + 1, v110 = build("<RefTaskID>",cnvtint(t.reference_task_id),"</RefTaskID>"), col + 1,
   v110, row + 1, v941 = build("<Frequency>",cnvtint(fs.frequency_cd),"</Frequency>"),
   col + 1, v941, row + 1,
   v16 = build("<StopDateTime>",format(od1.oe_field_dt_tm_value,"MM/DD/YYYY HH:MM;;D"),
    "</StopDateTime>"), v17 = build("<StopDateTimeZone>",substring(21,3,datetimezoneformat(od1
      .oe_field_dt_tm_value,od1.oe_field_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
    "</StopDateTimeZone>"), col + 1,
   v16, row + 1, col + 1,
   v17, row + 1, col + 1,
   "<UnknownOrderDetails>", row + 1
  HEAD od.oe_field_id
   col + 1, "<UnknownOrderDetail>", row + 1,
   col + 1, "<OrderField>", row + 1,
   vd1 = build("<FieldMeaningId>",cnvtint(od.oe_field_meaning_id),"</FieldMeaningId>"), col + 1, vd1,
   row + 1, vd2 = build("<FieldMeaning>",trim(od.oe_field_meaning),"</FieldMeaning>"), col + 1,
   vd2, row + 1, vd3 = build("<FieldId>",cnvtint(od.oe_field_id),"</FieldId>"),
   col + 1, vd3, row + 1,
   vd4 = build("<DisplayValue>",od_field_display_value,"</DisplayValue>"), col + 1, vd4,
   row + 1, vd41 = build("<DateTimeZone>",od.oe_field_tz,"</DateTimeZone>"), col + 1,
   vd41, row + 1, vd5 = build("<Value>",cnvtint(od.oe_field_value),"</Value>"),
   col + 1, vd5, row + 1,
   vd6 = build("<Description>",off_label_text,"</Description>"), col + 1, vd6,
   row + 1, vd7 = build("<ActionSequence>",cnvtint(od.action_sequence),"</ActionSequence>"), col + 1,
   vd7, row + 1, vd8 = build("<DetailSequence>",cnvtint(od.detail_sequence),"</DetailSequence>"),
   col + 1, vd8, row + 1,
   vd9 = build("<LockOnModify>",off_lock_on_modify,"</LockOnModify>"), col + 1, vd9,
   row + 1
   IF (trim(od.oe_field_meaning)="NURSECOLLECT")
    v95 = build("<NurseCollectIndicator>",od_field_display_value,"</NurseCollectIndicator>"),
    ncollect_ind = 1
   ENDIF
   IF (trim(od.oe_field_meaning)="REQSTARTDTTM")
    v96 = build("<RequestedStartDateTime>",format(od.oe_field_dt_tm_value,"MM/DD/YYYY HH:MM:SS;;D"),
     "</RequestedStartDateTime>"), v97 = build("<RequestedStartTimeZone>",substring(21,3,
      datetimezoneformat(od.oe_field_dt_tm_value,od.oe_field_tz,"MM/dd/yyyy hh:mm:ss ZZZ",
       curtimezonedef)),"</RequestedStartTimeZone>"), request_st_ind = 1
   ENDIF
   col + 1, "</OrderField>", row + 1
  FOOT  od.oe_field_id
   col + 1, "</UnknownOrderDetail>", row + 1
  FOOT  o.order_id
   col + 1, "</UnknownOrderDetails>", row + 1
   IF (ncollect_ind=1)
    col + 1, v95, row + 1
   ENDIF
   IF (request_st_ind=1)
    col + 1, v96, row + 1,
    col + 1, v97, row + 1
   ENDIF
   ncollect_ind = 0, request_st_ind = 0, foot_grp = build("</","StandardMedOrder",">"),
   col + 1, foot_grp, row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 90
 ;end select
 FREE RECORD act_order_status_ls
 FREE RECORD oth_order_status_ls1
 FREE RECORD oth_order_status_ls2
 FREE RECORD order_list
END GO
