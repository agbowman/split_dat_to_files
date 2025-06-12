CREATE PROGRAM bhs_athn_mar_summary_list
 FREE RECORD mar_data
 RECORD mar_data(
   1 qual[*]
     2 order_id = f8
     2 order_comm = c500
     2 last_dose_dt_tm = vc
     2 last_dose_tz = vc
 )
 DECLARE vcnt = i4
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
 DECLARE event_reltn_child_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",24,"CHILD"))
 DECLARE admin_event_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,
   "TASKCOMPLETE"))
 IF (( $2=0))
  SET where_params = build("O.ENCNTR_ID =", $3)
 ELSE
  SET where_params = build("O.PERSON_ID =", $2)
 ENDIF
 SELECT INTO "NL:"
  o.order_id
  FROM orders o,
   encounter e
  PLAN (o
   WHERE parser(where_params)
    AND o.activity_type_cd=pharmacy
    AND o.prn_ind=0
    AND o.iv_ind=0
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
   vcnt = (vcnt+ 1), stat = alterlist(mar_data->qual,vcnt), mar_data->qual[vcnt].order_id = o
   .order_id
  WITH time = 30
 ;end select
 SELECT INTO "NL:"
  o.order_id
  FROM orders o,
   encounter e
  PLAN (o
   WHERE parser(where_params)
    AND o.activity_type_cd=pharmacy
    AND o.prn_ind=0
    AND o.iv_ind=0
    AND o.freq_type_flag != 5
    AND o.template_order_flag IN (0, 1)
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
   vcnt = (vcnt+ 1), stat = alterlist(mar_data->qual,vcnt), mar_data->qual[vcnt].order_id = o
   .order_id
  WITH time = 30
 ;end select
 SELECT INTO "NL:"
  o.order_id
  FROM orders o,
   encounter e
  PLAN (o
   WHERE parser(where_params)
    AND o.activity_type_cd=pharmacy
    AND o.prn_ind=0
    AND o.iv_ind=0
    AND o.freq_type_flag != 5
    AND o.template_order_flag IN (0, 1)
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
   vcnt = (vcnt+ 1), stat = alterlist(mar_data->qual,vcnt), mar_data->qual[vcnt].order_id = o
   .order_id
  WITH time = 30
 ;end select
 IF (vcnt > 0)
  DECLARE temp_comments = vc
  SELECT INTO "NL:"
   comments = substring(1,500,trim(l.long_text,3)), comment_dt = format(l.active_status_dt_tm,
    "MM/DD/YYYY HH:MM;;D"), comment_prsnl = substring(1,30,trim(p.name_full_formatted,3)),
   comment_type = trim(uar_get_code_display(oc.comment_type_cd),3)
   FROM (dummyt d1  WITH seq = value(size(mar_data->qual,5))),
    order_comment oc,
    long_text l,
    prsnl p
   PLAN (d1)
    JOIN (oc
    WHERE (oc.order_id=mar_data->qual[d1.seq].order_id))
    JOIN (l
    WHERE l.long_text_id=oc.long_text_id)
    JOIN (p
    WHERE p.person_id=l.active_status_prsnl_id)
   ORDER BY oc.order_id, oc.action_sequence DESC
   HEAD oc.order_id
    temp_comments = fillstring(32000," "), temp_comments = build(temp_comments,comment_type,"|",
     comments,"|",
     comment_dt,"|",comment_prsnl,"###"), mar_data->qual[d1.seq].order_comm = replace(trim(
      temp_comments,3),"###","",2)
   WITH time = 30
  ;end select
  SELECT INTO "NL:"
   m.order_id, last_dose_dt = format(c.event_end_dt_tm,"MM/DD/YYYY HH:MM"), last_dose_tz = substring(
    21,3,datetimezoneformat(c.event_end_dt_tm,c.event_end_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef
     ))
   FROM (dummyt d1  WITH seq = value(size(mar_data->qual,5))),
    med_admin_event m,
    clinical_event c
   PLAN (d1)
    JOIN (m
    WHERE (m.template_order_id=mar_data->qual[d1.seq].order_id)
     AND m.event_type_cd=admin_event_type_cd)
    JOIN (c
    WHERE c.order_id=m.order_id
     AND c.event_end_dt_tm != null
     AND c.view_level=1
     AND c.event_reltn_cd=event_reltn_child_cd
     AND c.authentic_flag=1)
   ORDER BY c.event_end_dt_tm DESC
   HEAD m.order_id
    IF ((mar_data->qual[d1.seq].last_dose_dt_tm=" "))
     mar_data->qual[d1.seq].last_dose_dt_tm = trim(last_dose_dt,3), mar_data->qual[d1.seq].
     last_dose_tz = trim(last_dose_tz,3)
    ENDIF
   WITH time = 30
  ;end select
  SELECT INTO  $1
   oid = o.order_id, o_catalog_disp = trim(replace(replace(replace(replace(replace(
         uar_get_code_display(o.catalog_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0
      ),'"',"&quot;",0),3), hna_ord_mne = trim(replace(replace(replace(replace(replace(o
         .hna_order_mnemonic,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3),
   ord_mne = trim(replace(replace(replace(replace(replace(o.ordered_as_mnemonic,"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), clin_disp = trim(replace(replace(
      replace(replace(replace(o.clinical_display_line,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), o_order_status_disp = trim(replace(replace(replace(replace(
        replace(uar_get_code_display(o.order_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
      "'","&apos;",0),'"',"&quot;",0),3),
   order_class =
   IF (o.prn_ind=1) "PRN"
   ELSEIF (o.iv_ind=1) "Continuous Infusions"
   ELSEIF (o.freq_type_flag=5) "Unscheduled"
   ELSE "Scheduled"
   ENDIF
   , toid =
   IF (cnvtint(o1.order_id)=0) o.order_id
   ELSE o1.order_id
   ENDIF
   , beg_dt_tm = evaluate(format(c.event_end_dt_tm,"MM/DD/YYYY HH:MM")," ",format(c1.performed_dt_tm,
     "MM/DD/YYYY HH:MM"),format(c.event_end_dt_tm,"MM/DD/YYYY HH:MM")),
   beg_dt_timezone = substring(21,3,datetimezoneformat(c.event_end_dt_tm,c.event_end_tz,
     "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), sch_dt_tm =
   IF (cnvtint(o1.order_id) != 0) format(o1.current_start_dt_tm,"MM/DD/YYYY HH:MM")
   ELSE format(o.current_start_dt_tm,"MM/DD/YYYY HH:MM")
   ENDIF
   , sch_dt_timezone =
   IF (cnvtint(o1.order_id) != 0) substring(21,3,datetimezoneformat(o1.current_start_dt_tm,o1
      .current_start_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef))
   ELSE substring(21,3,datetimezoneformat(o.current_start_dt_tm,o.current_start_tz,
      "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef))
   ENDIF
   ,
   m_event_type_disp = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(m
          .event_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
    3), e_tag = trim(replace(replace(replace(replace(replace(
         IF (((m.event_type_cd=180239458) OR (m.event_type_cd=180239459)) ) c.event_tag
         ELSE c1.event_tag
         ENDIF
         ,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), eid =
   IF (m.event_id != 0) replace(cnvtstring(m.event_id),".00*","",0)
   ELSE replace(cnvtstring(c1.event_id),".00*","",0)
   ENDIF
   ,
   parent_eid = replace(cnvtstring(c1.parent_event_id),".00*","",0), ord_comment = trim(replace(
     replace(replace(replace(replace(mar_data->qual[d1.seq].order_comm,"&","&amp;",0),"<","&lt;",0),
       ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), oi_ord_display_line = trim(replace(replace(
      replace(replace(replace(oi.order_detail_display_line,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
      "'","&apos;",0),'"',"&quot;",0),3),
   oi_ord_as_mne = trim(replace(replace(replace(replace(replace(oi.ordered_as_mnemonic,"&","&amp;",0),
        "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), disp_category = trim(replace(
     replace(replace(replace(replace(od.oe_field_display_value,"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), performed_prsnl = trim(replace(replace(replace(
       replace(replace(pe.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
      0),'"',"&quot;",0),3),
   performed_dt_tm = format(c.performed_dt_tm,"MM/DD/YYYY HH:MM"), performedtimezone = substring(21,3,
    datetimezoneformat(c.performed_dt_tm,c.performed_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
   frequency = trim(replace(replace(replace(replace(replace(odd.oe_field_display_value,"&","&amp;",0),
        "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   curr_start_dt_tm = format(o.current_start_dt_tm,"MM/DD/YYYY HH:MM"), nursereviewindicator = trim(
    replace(replace(replace(replace(replace(substring(0,25,
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
          IF (c.authentic_flag=1) "Authenticated"
          ELSEIF (c.authentic_flag=0) "Unauthenticated"
          ELSE "Unkown"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   c_record_status_disp = uar_get_code_display(c.record_status_cd),
   p.display_description, op_proposal_status_disp = uar_get_code_display(op.proposal_status_cd),
   route = trim(replace(replace(replace(replace(replace(uar_get_code_display(cm.admin_route_cd),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   site = trim(replace(replace(replace(replace(replace(uar_get_code_display(cm.admin_site_cd),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   c_result_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(c
          .result_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3), o_med_order_type_disp = uar_get_code_meaning(o.med_order_type_cd),
   original_ordered_as_flag = trim(replace(replace(replace(replace(replace(substring(0,30,
          IF (o.orig_ord_as_flag=0) "NormalOrder"
          ELSEIF (o.orig_ord_as_flag=1) "PrescriptionDischarge"
          ELSEIF (o.orig_ord_as_flag=2) "RecordedOrHomeMeds"
          ELSEIF (o.orig_ord_as_flag=3) "PatientOwnsMeds"
          ELSEIF (o.orig_ord_as_flag=4) "PharmacyChargeOnly"
          ELSEIF (o.orig_ord_as_flag=5) "SatelliteSuperBillsMeds"
          ENDIF
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), odd1
   .oe_field_display_value, last_dose_dt_tm = trim(mar_data->qual[d1.seq].last_dose_dt_tm,3),
   last_dose_tz = trim(mar_data->qual[d1.seq].last_dose_tz,3)
   FROM (dummyt d1  WITH seq = value(size(mar_data->qual,5))),
    orders o,
    orders o1,
    med_admin_event m,
    clinical_event c,
    clinical_event c1,
    order_ingredient oi,
    order_detail od,
    person pe,
    order_detail odd,
    pathway_catalog p,
    order_proposal op,
    ce_med_result cm,
    order_detail odd1
   PLAN (d1)
    JOIN (o
    WHERE (o.order_id=mar_data->qual[d1.seq].order_id))
    JOIN (o1
    WHERE ((o1.template_order_id=o.order_id) OR (o1.order_id=o.order_id)) )
    JOIN (m
    WHERE m.order_id=outerjoin(o1.order_id)
     AND m.event_type_cd != outerjoin(180239457.00))
    JOIN (c
    WHERE c.event_id=outerjoin(m.event_id)
     AND c.result_status_cd != 31
     AND c.valid_from_dt_tm < sysdate
     AND c.valid_until_dt_tm > sysdate
     AND c.event_end_dt_tm BETWEEN cnvtdatetime( $4) AND cnvtdatetime( $5))
    JOIN (pe
    WHERE pe.person_id=outerjoin(c.performed_prsnl_id))
    JOIN (c1
    WHERE c1.order_id=outerjoin(o1.order_id)
     AND c1.event_reltn_cd=outerjoin(132.00))
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
    JOIN (p
    WHERE p.pathway_catalog_id=outerjoin(o.pathway_catalog_id))
    JOIN (op
    WHERE op.order_id=outerjoin(o.order_id)
     AND op.encntr_id=outerjoin(o.encntr_id))
    JOIN (cm
    WHERE cm.event_id=outerjoin(c1.event_id)
     AND cm.valid_from_dt_tm < outerjoin(sysdate)
     AND cm.valid_until_dt_tm > outerjoin(sysdate))
   ORDER BY o.order_id, o1.order_id, m.beg_dt_tm DESC
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   HEAD o.order_id
    col 1, "<Orders>", row + 1,
    v1 = build("<ParentOrderId>",oid,"</ParentOrderId>"), col + 1, v1,
    row + 1, v2 = build("<CatalogDisplay>",o_catalog_disp,"</CatalogDisplay>"), col + 1,
    v2, row + 1, v31 = build("<HNAOrderMnemonic>",hna_ord_mne,"</HNAOrderMnemonic>"),
    col + 1, v31, row + 1,
    v3 = build("<OrderedAsMnemonic>",ord_mne,"</OrderedAsMnemonic>"), col + 1, v3,
    row + 1, v4 = build("<ClinicalDisplay>",clin_disp,"</ClinicalDisplay>"), col + 1,
    v4, row + 1, v5 = build("<OrderStatus>",o_order_status_disp,"</OrderStatus>"),
    col + 1, v5, row + 1,
    v6 = build("<OrderClass>",order_class,"</OrderClass>"), col + 1, v6,
    row + 1, v7 = build("<NurseReviewIndicator>",nursereviewindicator,"</NurseReviewIndicator>"), col
     + 1,
    v7, row + 1, v8 = build("<ProviderCosignFlag>",providercosignflag,"</ProviderCosignFlag>"),
    col + 1, v8, row + 1,
    v9 = build("<PharmacistReviewFlag>",pharmacyreviewflag,"</PharmacistReviewFlag>"), col + 1, v9,
    row + 1, v10 = build("<EncounterId>",trim(replace(cnvtstring(o.encntr_id),".0*","",0),3),
     "</EncounterId>"), col + 1,
    v10, row + 1, v12 = build("<OrderComment>",ord_comment,"</OrderComment>"),
    col + 1, v12, row + 1
    IF (oi.order_id != 0)
     col 1, "<OrderIngrediant>", row + 1,
     v18 = build("<IngOrdDetailLine>",oi_ord_display_line,"</IngOrdDetailLine>"), col + 1, v18,
     row + 1, v19 = build("<IngOrdAsMne>",oi_ord_as_mne,"</IngOrdAsMne>"), col + 1,
     v19, row + 1, col 1,
     "</OrderIngrediant>", row + 1
    ENDIF
    v20 = build("<DispenseCategory>",disp_category,"</DispenseCategory>"), col + 1, v20,
    row + 1, v201 = build("<FrequencyTypeFlag>",o.freq_type_flag,"</FrequencyTypeFlag>"), col + 1,
    v201, row + 1, v202 = build("<MedicationOrderedAsFlag>",original_ordered_as_flag,
     "</MedicationOrderedAsFlag>"),
    col + 1, v202, row + 1,
    v21 = build("<Frequency>",frequency,"</Frequency>"), col + 1, v21,
    row + 1, v210 = build("<RxPriority>",odd1.oe_field_display_value,"</RxPriority>"), col + 1,
    v210, row + 1, v211 = build("<OrderStartDateTime>",curr_start_dt_tm,"</OrderStartDateTime>"),
    col + 1, v211, row + 1,
    v212 = build("<PathwayPlan>",p.display_description,"</PathwayPlan>"), col + 1, v212,
    row + 1, v213 = build("<ProposalStatus>",op_proposal_status_disp,"</ProposalStatus>"), col + 1,
    v213, row + 1, v214 = build("<MedOrderType>",o_med_order_type_disp,"</MedOrderType>"),
    col + 1, v214, row + 1,
    last_dos_dt = build("<LastDoseDateTime>",last_dose_dt_tm,"</LastDoseDateTime>"), col + 1,
    last_dos_dt,
    row + 1, last_dos_tz = build("<LastDoseTimeZone>",last_dose_tz,"</LastDoseTimeZone>"), col + 1,
    last_dos_tz, row + 1
   HEAD eid
    IF (eid != " ")
     col 1, "<ChildOrders>", row + 1,
     v12 = build("<ChildOrderId>",toid,"</ChildOrderId>"), col + 1, v12,
     row + 1, v13 = build("<ScheduleDtTm>",sch_dt_tm,"</ScheduleDtTm>"), col + 1,
     v13, row + 1, v131 = build("<ScheduleDtTimezone>",sch_dt_timezone,"</ScheduleDtTimezone>"),
     col + 1, v131, row + 1,
     v14 = build("<BegDtTm>",beg_dt_tm,"</BegDtTm>"), col + 1, v14,
     row + 1, v141 = build("<BegDtTimezone>",beg_dt_timezone,"</BegDtTimezone>"), col + 1,
     v141, row + 1, v15 = build("<EventType>",m_event_type_disp,"</EventType>"),
     col + 1, v15, row + 1,
     v16 = build("<EventId>",eid,"</EventId>"), col + 1, v16,
     row + 1, v16_1 = build("<ParentEventId>",parent_eid,"</ParentEventId>"), col + 1,
     v16_1, row + 1, v17 = build("<EventTag>",e_tag,"</EventTag>"),
     col + 1, v17, row + 1,
     v18 = build("<PerformedBy>",performed_prsnl,"</PerformedBy>"), col + 1, v18,
     row + 1, v19 = build("<PerformedOn>",concat(performed_dt_tm," ",performedtimezone),
      "</PerformedOn>"), col + 1,
     v19, row + 1, v22 = build("<AuthenticFlag>",authenticflag,"</AuthenticFlag>"),
     col + 1, v22, row + 1,
     v23 = build("<ClinicalRecStatus>",c_record_status_disp,"</ClinicalRecStatus>"), col + 1, v23,
     row + 1, v24 = build("<Route>",route,"</Route>"), col + 1,
     v24, row + 1, v241 = build("<Site>",site,"</Site>"),
     col + 1, v241, row + 1,
     v25 = build("<ResultStatus>",c_result_status_disp,"</ResultStatus>"), col + 1, v25,
     row + 1, col 1, "</ChildOrders>",
     row + 1
    ENDIF
   FOOT  o.order_id
    col 1, "</Orders>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 60
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
    time = 60
  ;end select
 ENDIF
END GO
