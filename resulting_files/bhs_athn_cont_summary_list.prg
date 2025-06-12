CREATE PROGRAM bhs_athn_cont_summary_list
 FREE RECORD iv_data
 RECORD iv_data(
   1 qual[*]
     2 order_id = f8
     2 order_comm = c500
 )
 DECLARE vcnt = i4
 DECLARE temp_p_eid = f8
 SET modify maxvarlen 10000000
 DECLARE pharmacy = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",106,"PHARMACY"))
 DECLARE completed = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",14281,"COMPLETED"))
 DECLARE canceled = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6004,"CANCELED"))
 DECLARE completed1 = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6004,"COMPLETED1"))
 DECLARE deleted = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6004,"DELETED"))
 DECLARE discontinued = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6004,"DISCONTINUED"))
 DECLARE transfercanceled = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6004,
   "TRANSFERCANCELED"))
 DECLARE voidedwithresults = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6004,
   "VOIDEDWITHRESULTS"))
 DECLARE entrymode1 = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"MEDADMIN"))
 DECLARE entrymode2 = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"UNDEFINED"))
 IF (( $2=0))
  SET where_params = build("O.ENCNTR_ID =", $3)
 ELSE
  SET where_params = build("O.PERSON_ID =", $2)
 ENDIF
 SELECT INTO "NL:"
  o_order_id = o.order_id
  FROM orders o,
   encounter e
  PLAN (o
   WHERE parser(where_params)
    AND o.activity_type_cd=pharmacy
    AND o.iv_ind=1
    AND o.freq_type_flag != 5
    AND o.template_order_flag IN (0, 1)
    AND o.orig_ord_as_flag IN (0.00, 3.00, 5.00)
    AND o.active_ind=1
    AND o.active_status_cd=188
    AND o.order_status_cd IN (2550.00, 2552.00, 643466, 2547))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1)
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(iv_data->qual,vcnt), iv_data->qual[vcnt].order_id = o_order_id
  WITH time = 30
 ;end select
 SELECT INTO "NL:"
  o_order_id = o.order_id
  FROM orders o,
   encounter e
  PLAN (o
   WHERE parser(where_params)
    AND o.activity_type_cd=pharmacy
    AND o.template_order_flag IN (0, 1)
    AND o.iv_ind=1
    AND o.freq_type_flag != 5
    AND o.orig_ord_as_flag IN (0.00, 3.00, 5.00)
    AND o.active_ind=1
    AND o.active_status_cd=188
    AND o.order_status_cd IN (2542.00, 2544.00, 643467, 2545.00, 2543.00,
   614538)
    AND o.current_start_dt_tm BETWEEN cnvtdatetime( $4) AND cnvtdatetime( $5))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1)
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(iv_data->qual,vcnt), iv_data->qual[vcnt].order_id = o_order_id
  WITH time = 30
 ;end select
 SELECT INTO "NL:"
  o_order_id = o.order_id
  FROM orders o,
   encounter e
  PLAN (o
   WHERE parser(where_params)
    AND o.activity_type_cd=pharmacy
    AND o.template_order_flag IN (0, 1)
    AND o.iv_ind=1
    AND o.freq_type_flag != 5
    AND o.orig_ord_as_flag IN (0.00, 3.00, 5.00)
    AND o.active_ind=1
    AND o.active_status_cd=188
    AND o.order_status_cd IN (2542.00, 2544.00, 643467, 2545.00, 2543.00,
   614538)
    AND o.status_dt_tm >= cnvtdatetime( $4))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1)
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(iv_data->qual,vcnt), iv_data->qual[vcnt].order_id = o_order_id
  WITH time = 30
 ;end select
 DECLARE temp_comments = vc
 SELECT INTO "NL:"
  comments = substring(1,500,trim(l.long_text,3)), comment_dt = format(l.active_status_dt_tm,
   "MM/DD/YYYY HH:MM;;D"), comment_prsnl = substring(1,30,trim(p.name_full_formatted,3)),
  comment_type = trim(uar_get_code_display(oc.comment_type_cd),3)
  FROM (dummyt d1  WITH seq = value(size(iv_data->qual,5))),
   order_comment oc,
   long_text l,
   prsnl p
  PLAN (d1)
   JOIN (oc
   WHERE (oc.order_id=iv_data->qual[d1.seq].order_id))
   JOIN (l
   WHERE l.long_text_id=oc.long_text_id)
   JOIN (p
   WHERE p.person_id=l.active_status_prsnl_id)
  ORDER BY oc.order_id, oc.action_sequence DESC
  HEAD oc.order_id
   temp_comments = fillstring(32000," ")
  HEAD oc.comment_type_cd
   temp_comments = build(temp_comments,comment_type,"|",comments,"|",
    comment_dt,"|",comment_prsnl,"###"), iv_data->qual[d1.seq].order_comm = replace(trim(
     temp_comments,3),"###","",2)
  WITH time = 30
 ;end select
 IF (vcnt > 0)
  SELECT INTO  $1
   oid = trim(replace(cnvtstring(o.order_id),".0*","",0),3), o_catalog_disp = trim(replace(replace(
      replace(replace(replace(uar_get_code_display(o.catalog_cd),"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), hna_ord_mne = trim(replace(replace(replace(
       replace(replace(o.hna_order_mnemonic,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0
      ),'"',"&quot;",0),3),
   ord_mne = trim(replace(replace(replace(replace(replace(o.ordered_as_mnemonic,"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), clin_disp = trim(replace(replace(
      replace(replace(replace(o.clinical_display_line,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), o_order_status_disp = trim(replace(replace(replace(replace(
        replace(uar_get_code_display(o.order_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
      "'","&apos;",0),'"',"&quot;",0),3),
   order_class = "IV", beg_dt_tm = format(c1.event_end_dt_tm,"MM/DD/YYYY HH:MM"), beg_dt_timezone =
   substring(21,3,datetimezoneformat(c1.event_end_dt_tm,c1.event_end_tz,"MM/dd/yyyy hh:mm:ss ZZZ",
     curtimezonedef)),
   admin_start_dt_tm = format(cm.admin_start_dt_tm,"MM/DD/YYYY HH:MM"), admin_start_dt_tz = substring
   (21,3,datetimezoneformat(cm.admin_start_dt_tm,cm.admin_start_tz,"MM/dd/yyyy hh:mm:ss ZZZ",
     curtimezonedef)), e1_tag = trim(replace(replace(replace(replace(replace(c1.event_tag,"&","&amp;",
         0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   e1id = replace(cnvtstring(c1.event_id),".00*","",0), parent_e1id = replace(cnvtstring(c1
     .parent_event_id),".00*","",0), ord_comment = trim(replace(replace(replace(replace(replace(
         iv_data->qual[d1.seq].order_comm,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
     '"',"&quot;",0),3),
   oi_ord_display_line = trim(replace(replace(replace(replace(replace(oi.order_detail_display_line,
         "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), oi_ord_as_mne
    = trim(replace(replace(replace(replace(replace(oi.ordered_as_mnemonic,"&","&amp;",0),"<","&lt;",0
        ),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), disp_category = trim(replace(replace(
      replace(replace(replace(od.oe_field_display_value,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
      "'","&apos;",0),'"',"&quot;",0),3),
   performed_prsnl = trim(replace(replace(replace(replace(replace(pe.name_full_formatted,"&","&amp;",
         0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), frequency = trim(replace(
     replace(replace(replace(replace(odd.oe_field_display_value,"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), event_disp = trim(replace(replace(replace(
       replace(replace(uar_get_code_display(c1.event_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
      "'","&apos;",0),'"',"&quot;",0),3),
   route = trim(replace(replace(replace(replace(replace(uar_get_code_display(cm.admin_route_cd),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), site = trim(
    replace(replace(replace(replace(replace(uar_get_code_display(cm.admin_site_cd),"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), ingredients = trim(replace(
     replace(replace(replace(replace(uar_get_code_display(os.catalog_cd),"&","&amp;",0),"<","&lt;",0),
       ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   lot_nbr = trim(cm.substance_lot_number,3), initial_dosage = cm.initial_dosage, dosage_unit_cd =
   trim(uar_get_code_display(cm.dosage_unit_cd),3),
   initial_volume = cm.initial_volume, infusion_rate = cm.infusion_rate, infusion_unit_cd = trim(
    uar_get_code_display(cm.infusion_unit_cd),3),
   infused_volume_unit_cd = trim(uar_get_code_display(cm.infused_volume_unit_cd),3), weight = concat(
    trim(cnvtstring(cm.weight_value),3)," ",trim(uar_get_code_display(cm.weight_unit_cd),3)),
   iv_event_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(cm.iv_event_cd),
         "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   nursereviewindicator = trim(replace(replace(replace(replace(replace(substring(0,25,
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
   authenticflag = trim(replace(replace(replace(replace(replace(substring(0,30,
          IF (c1.authentic_flag=1) "Authenticated"
          ELSEIF (c1.authentic_flag=0) "Unauthenticated"
          ELSE "Unkown"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   c_record_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(c1
          .record_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3), p.display_description,
   op_proposal_status_disp = uar_get_code_display(op.proposal_status_cd), c_result_status_disp = trim
   (replace(replace(replace(replace(replace(uar_get_code_display(c1.result_status_cd),"&","&amp;",0),
        "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o_med_order_type_disp =
   uar_get_code_meaning(o.med_order_type_cd),
   original_ordered_as_flag = trim(replace(replace(replace(replace(replace(substring(0,30,
          IF (o.orig_ord_as_flag=0) "NormalOrder"
          ELSEIF (o.orig_ord_as_flag=1) "PrescriptionDischarge"
          ELSEIF (o.orig_ord_as_flag=2) "RecordedOrHomeMeds"
          ELSEIF (o.orig_ord_as_flag=3) "PatientOwnsMeds"
          ELSEIF (o.orig_ord_as_flag=4) "PharmacyChargeOnly"
          ELSEIF (o.orig_ord_as_flag=5) "SatelliteSuperBillsMeds"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), odd1
   .oe_field_display_value
   FROM (dummyt d1  WITH seq = value(size(iv_data->qual,5))),
    orders o,
    clinical_event c1,
    order_ingredient oi,
    order_detail od,
    person pe,
    order_detail odd,
    ce_med_result cm,
    order_catalog_synonym os,
    pathway_catalog p,
    order_proposal op,
    order_detail odd1
   PLAN (d1)
    JOIN (o
    WHERE (o.order_id=iv_data->qual[d1.seq].order_id))
    JOIN (c1
    WHERE c1.order_id=outerjoin(o.order_id)
     AND c1.event_tag != outerjoin("DCP GENERIC CODE")
     AND c1.valid_from_dt_tm < outerjoin(sysdate)
     AND c1.valid_until_dt_tm > outerjoin(sysdate))
    JOIN (pe
    WHERE pe.person_id=outerjoin(c1.performed_prsnl_id))
    JOIN (oi
    WHERE oi.order_id=outerjoin(o.order_id)
     AND oi.include_in_total_volume_flag=outerjoin(1))
    JOIN (od
    WHERE od.order_id=outerjoin(o.order_id)
     AND od.oe_field_meaning=outerjoin("DISPENSECATEGORY"))
    JOIN (odd
    WHERE odd.order_id=outerjoin(o.order_id)
     AND odd.oe_field_meaning=outerjoin("FREQ"))
    JOIN (odd1
    WHERE odd1.order_id=outerjoin(o.order_id)
     AND odd1.oe_field_meaning=outerjoin("RXPRIORITY"))
    JOIN (cm
    WHERE cm.event_id=outerjoin(c1.event_id)
     AND cm.valid_from_dt_tm < outerjoin(sysdate)
     AND cm.valid_until_dt_tm > outerjoin(sysdate))
    JOIN (os
    WHERE os.synonym_id=outerjoin(cm.synonym_id))
    JOIN (p
    WHERE p.pathway_catalog_id=outerjoin(o.pathway_catalog_id))
    JOIN (op
    WHERE op.order_id=outerjoin(o.order_id)
     AND op.encntr_id=outerjoin(o.encntr_id))
   ORDER BY o.order_id, c1.parent_event_id, c1.event_id
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   HEAD o.order_id
    col 1, "<Orders>", row + 1,
    v1 = build("<ParentOrderId>",oid,"</ParentOrderId>"), col + 1, v1,
    row + 1, v2 = build("<CatalogDisplay>",o_catalog_disp,"</CatalogDisplay>"), col + 1,
    v2, row + 1, v3 = build("<HNAOrderMnemonic>",hna_ord_mne,"</HNAOrderMnemonic>"),
    col + 1, v3, row + 1,
    v4 = build("<OrderedAsMnemonic>",ord_mne,"</OrderedAsMnemonic>"), col + 1, v4,
    row + 1, v5 = build("<ClinicalDisplay>",clin_disp,"</ClinicalDisplay>"), col + 1,
    v5, row + 1, v6 = build("<OrderStatus>",o_order_status_disp,"</OrderStatus>"),
    col + 1, v6, row + 1,
    v7 = build("<OrderClass>",order_class,"</OrderClass>"), col + 1, v7,
    row + 1, v8 = build("<OrderComment>",ord_comment,"</OrderComment>"), col + 1,
    v8, row + 1
    IF (oi.order_id != 0)
     col 1, "<OrderIngrediant>", row + 1,
     v9 = build("<IngOrdDetailLine>",oi_ord_display_line,"</IngOrdDetailLine>"), col + 1, v9,
     row + 1, v10 = build("<IngOrdAsMne>",oi_ord_as_mne,"</IngOrdAsMne>"), col + 1,
     v10, row + 1, col 1,
     "</OrderIngrediant>", row + 1
    ENDIF
    v11 = build("<DispenseCategory>",disp_category,"</DispenseCategory>"), col + 1, v11,
    row + 1, v12 = build("<Frequency>",frequency,"</Frequency>"), col + 1,
    v12, row + 1, v120 = build("<RxPriority>",odd1.oe_field_display_value,"</RxPriority>"),
    col + 1, v120, row + 1,
    v201 = build("<FrequencyTypeFlag>",o.freq_type_flag,"</FrequencyTypeFlag>"), col + 1, v201,
    row + 1, v202 = build("<MedicationOrderedAsFlag>",original_ordered_as_flag,
     "</MedicationOrderedAsFlag>"), col + 1,
    v202, row + 1, v50 = build("<NurseReviewIndicator>",nursereviewindicator,
     "</NurseReviewIndicator>"),
    col + 1, v50, row + 1,
    v51 = build("<ProviderCosignFlag>",providercosignflag,"</ProviderCosignFlag>"), col + 1, v51,
    row + 1, v52 = build("<PharmacistReviewFlag>",pharmacyreviewflag,"</PharmacistReviewFlag>"), col
     + 1,
    v52, row + 1, v521 = build("<PathwayPlan>",p.display_description,"</PathwayPlan>"),
    col + 1, v521, row + 1,
    v522 = build("<ProposalStatus>",op_proposal_status_disp,"</ProposalStatus>"), col + 1, v522,
    row + 1, v523 = build("<MedOrderType>",o_med_order_type_disp,"</MedOrderType>"), col + 1,
    v523, row + 1
   HEAD c1.parent_event_id
    IF (c1.entry_mode_cd IN (entrymode1, entrymode2))
     col 1, "<ParentEvents>", row + 1,
     v13 = build("<BegDtTm>",beg_dt_tm,"</BegDtTm>"), col + 1, v13,
     row + 1, v131 = build("<BegDtTimezone>",beg_dt_timezone,"</BegDtTimezone>"), col + 1,
     v131, row + 1, v14 = build("<EventId>",e1id,"</EventId>"),
     col + 1, v14, row + 1,
     v14_1 = build("<ParentEventId>",parent_e1id,"</ParentEventId>"), col + 1, v14_1,
     row + 1, v15 = build("<EventDisplay>",event_disp,"</EventDisplay>"), col + 1,
     v15, row + 1, v16 = build("<EventTag>",e1_tag,"</EventTag>"),
     col + 1, v16, row + 1,
     v17 = build("<DocumentedBy>",performed_prsnl,"</DocumentedBy>"), col + 1, v17,
     row + 1, v18 = build("<Route>",route,"</Route>"), col + 1,
     v18, row + 1, v19 = build("<Site>",site,"</Site>"),
     col + 1, v19, row + 1,
     v20 = build("<Ingredients>",ingredients,"</Ingredients>"), col + 1, v20,
     row + 1, v21 = build("<LotNumber>",lot_nbr,"</LotNumber>"), col + 1,
     v21, row + 1, v22 = build("<InitialDose>",initial_dosage,"</InitialDose>"),
     col + 1, v22, row + 1,
     v23 = build("<DosageUnit>",dosage_unit_cd,"</DosageUnit>"), col + 1, v23,
     row + 1, v24 = build("<InitialVolume>",initial_volume,"</InitialVolume>"), col + 1,
     v24, row + 1, v25 = build("<InfusionRate>",infusion_rate,"</InfusionRate>"),
     col + 1, v25, row + 1,
     v26 = build("<InfusionUnit>",infusion_unit_cd,"</InfusionUnit>"), col + 1, v26,
     row + 1, v27 = build("<InfusionVolumeUnit>",infused_volume_unit_cd,"</InfusionVolumeUnit>"), col
      + 1,
     v27, row + 1, v28 = build("<Weight>",weight,"</Weight>"),
     col + 1, v28, row + 1,
     v29 = build("<IVEventDisplay>",iv_event_disp,"</IVEventDisplay>"), col + 1, v29,
     row + 1, v30 = build("<AdminStartDate>",admin_start_dt_tm,"</AdminStartDate>"), col + 1,
     v30, row + 1, v300 = build("<AdminStartTimeZone>",admin_start_dt_tz,"</AdminStartTimeZone>"),
     col + 1, v300, row + 1
    ENDIF
   HEAD c1.event_id
    IF (c1.entry_mode_cd IN (entrymode1, entrymode2))
     col 1, "<ChildEvents>", row + 1,
     v31 = build("<BegDtTm>",beg_dt_tm,"</BegDtTm>"), col + 1, v31,
     row + 1, v311 = build("<BegDtTimezone>",beg_dt_timezone,"</BegDtTimezone>"), col + 1,
     v311, row + 1, v32 = build("<EventId>",e1id,"</EventId>"),
     col + 1, v32, row + 1,
     v33 = build("<ParentEventId>",parent_e1id,"</ParentEventId>"), col + 1, v33,
     row + 1, v34 = build("<EventDisplay>",event_disp,"</EventDisplay>"), col + 1,
     v34, row + 1, v35 = build("<EventTag>",e1_tag,"</EventTag>"),
     col + 1, v35, row + 1,
     v36 = build("<DocumentedBy>",performed_prsnl,"</DocumentedBy>"), col + 1, v36,
     row + 1, v37 = build("<Route>",route,"</Route>"), col + 1,
     v37, row + 1, v38 = build("<Site>",site,"</Site>"),
     col + 1, v38, row + 1,
     v39 = build("<Ingredients>",ingredients,"</Ingredients>"), col + 1, v39,
     row + 1, v40 = build("<LotNumber>",lot_nbr,"</LotNumber>"), col + 1,
     v40, row + 1, v41 = build("<InitialDose>",initial_dosage,"</InitialDose>"),
     col + 1, v41, row + 1,
     v42 = build("<DosageUnit>",dosage_unit_cd,"</DosageUnit>"), col + 1, v42,
     row + 1, v43 = build("<InitialVolume>",initial_volume,"</InitialVolume>"), col + 1,
     v43, row + 1, v44 = build("<InfusionRate>",infusion_rate,"</InfusionRate>"),
     col + 1, v44, row + 1,
     v45 = build("<InfusionUnit>",infusion_unit_cd,"</InfusionUnit>"), col + 1, v45,
     row + 1, v46 = build("<InfusionVolumeUnit>",infused_volume_unit_cd,"</InfusionVolumeUnit>"), col
      + 1,
     v46, row + 1, v47 = build("<Weight>",weight,"</Weight>"),
     col + 1, v47, row + 1,
     v48 = build("<IVEventDisplay>",iv_event_disp,"</IVEventDisplay>"), col + 1, v48,
     row + 1, v49 = build("<AdminStartDate>",admin_start_dt_tm,"</AdminStartDate>"), col + 1,
     v49, row + 1, v491 = build("<AdminStartTimeZone>",admin_start_dt_tz,"</AdminStartTimeZone>"),
     col + 1, v491, row + 1,
     v490 = build("<AuthenticFlag>",authenticflag,"</AuthenticFlag>"), col + 1, v490,
     row + 1, v491 = build("<ClinicalStatus>",c_record_status_disp,"</ClinicalStatus>"), col + 1,
     v491, row + 1, v492 = build("<ResultStatus>",c_result_status_disp,"</ResultStatus>"),
     col + 1, v492, row + 1,
     col 1, "</ChildEvents>", row + 1
    ENDIF
   DETAIL
    row + 0
   FOOT  c1.event_id
    row + 0
   FOOT  c1.parent_event_id
    IF (c1.entry_mode_cd IN (entrymode1, entrymode2))
     col 1, "</ParentEvents>", row + 1
    ENDIF
   FOOT  o.order_id
    col 1, "</Orders>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 30
  ;end select
 ELSE
  SELECT INTO  $1
   FROM dummyt d
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 30
  ;end select
 ENDIF
END GO
