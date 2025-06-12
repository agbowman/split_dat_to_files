CREATE PROGRAM bhs_oudose_audit_detail:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date(dd-mmm-yyyy):" = "CURDATE",
  "Ending date(dd-mmm-yyyy):" = "CURDATE",
  "Facility:" = 673936.00,
  "Nurse unit(s):" = value(*),
  "Display per:" = 3
  WITH outdev, ms_start_date, ms_end_date,
  mf_facility, mf_nurse_unit, ml_display_type
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
 FREE RECORD audit_request
 RECORD audit_request(
   1 unit_cnt = i4
   1 unit[*]
     2 nurse_unit_cd = f8
 ) WITH protect
 FREE RECORD events_reply
 RECORD events_reply(
   1 administrations = i4
   1 not_done = i4
   1 total = i4
 ) WITH protect
 FREE RECORD parent_order
 RECORD parent_order(
   1 dupl_cnt = i4
   1 total_orders_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 template_order_id = f8
     2 action_seq = i4
     2 ordered_qual = i4
 ) WITH protect
 FREE RECORD ordered_ingrdnts
 RECORD ordered_ingrdnts(
   1 tot_par_order_cnt = i4
   1 dupl_cnt = i4
   1 qual[*]
     2 template_order_id = f8
     2 action_seq = i4
     2 dupl_ingr = i4
     2 dupl_cnt = i4
     2 total_ingr_cnt = i4
     2 ingr_qual[*]
       3 synonym_id = f8
       3 ordered_dose = c60
       3 catalog_disp = c60
       3 syn_mne = c60
 ) WITH protect
 FREE RECORD parent_admined
 RECORD parent_admined(
   1 dupl_cnt = i4
   1 total_ingr_cnt = i4
   1 qual[*]
     2 total_cnt = i4
     2 dupl_cnt = i4
     2 mame_id = f8
     2 ingr_qual[*]
       3 synonym_id = f8
       3 catalog_disp = c60
       3 dose_admin = c60
       3 syn_mne = c60
 ) WITH protect
 FREE RECORD audit_reply
 RECORD audit_reply(
   1 summary_qual_cnt = i4
   1 cancelled_cnt = i4
   1 continued_cnt = i4
   1 summary_qual[*]
     2 alert_type = c35
     2 date = vc
     2 patient = c60
     2 location = c60
     2 fin = c60
     2 med_ident = i4
     2 medication = c60
     2 user = c60
     2 order_id = f8
     2 event_id = f8
     2 encounter_id = f8
     2 alert_id = f8
     2 mame_id = f8
     2 admined_qual[*]
       3 synonym_id = f8
       3 syn_mne = vc
       3 dose_admin = vc
     2 ordered_qual[*]
       3 synonym_id = f8
       3 ordered_dose = vc
       3 syn_mne = vc
 ) WITH protect
 DECLARE mf_fac_cd = f8 WITH protect, constant( $MF_FACILITY)
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_nd_result_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_overdose_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"OVERDOSE"))
 DECLARE mf_underdose_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"UNDERDOSE"))
 DECLARE mn_display_ind = i4 WITH protect, constant( $ML_DISPLAY_TYPE)
 DECLARE ms_start_dt_tm = vc WITH protect, constant(concat(trim( $MS_START_DATE)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $MS_END_DATE)," 23:59:59"))
 DECLARE ms_title = vc WITH protect, constant("Point of Care Audit Over/Underdose Report")
 DECLARE ms_dashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE mf_temp = f8 WITH protect, noconstant(0)
 DECLARE mf_temp2 = f8 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_found = i4 WITH protect, noconstant(0)
 DECLARE ml_found2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loc_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_continued = i4 WITH protect, noconstant(0)
 DECLARE ml_ingr_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ingr_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cancelled_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_nurse_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_all_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_display = vc WITH protect, noconstant("")
 DECLARE ms_status = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_med_ident = vc WITH protect, noconstant("")
 DECLARE ms_outcome = vc WITH protect, noconstant("")
 DECLARE ms_last_row = c20 WITH protect, noconstant("00000000000000000000")
 DECLARE mc_status_ind = c1 WITH protect, noconstant("")
 IF (((trim( $MS_START_DATE)="") OR (trim( $MS_END_DATE)="")) )
  SET ms_status = "ERROR"
  SET ms_error = "Begin Date and End Date are required."
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_start_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_status = "ERROR"
  SET ms_error = "Begin Date must be less than End Date."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt = (aunit->l_cnt+ 1), stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->
   l_cnt].s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 SET mc_status_ind = substring(1,1,reflect(parameter(5,0)))
 IF (mc_status_ind="C")
  SET mn_all_ind = 1
  SELECT INTO "nl:"
   FROM nurse_unit n,
    code_value cv
   PLAN (n
    WHERE n.loc_facility_cd=mf_fac_cd
     AND n.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=n.location_cd
     AND cv.code_set=220
     AND cv.active_ind=1
     AND cv.active_type_cd=mf_active_cd
     AND cv.data_status_cd=mf_auth_cd
     AND ((cv.cdf_meaning="NURSEUNIT") OR (((cv.cdf_meaning="AMBULATORY"
     AND expand(ml_cnt2,1,aunit->l_cnt,cv.display_key,aunit->list[ml_cnt2].s_unit_display_key)) OR (
    ((cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="BFMCONCOLOGY"
     AND n.loc_facility_cd=673937) OR (cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="S15MED"
     AND n.loc_facility_cd=673936)) )) )) )
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt = (ml_cnt+ 1)
    IF (mod(ml_cnt,10)=1)
     CALL alterlist(audit_request->unit,(ml_cnt+ 9))
    ENDIF
    audit_request->unit[ml_cnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    CALL alterlist(audit_request->unit,ml_cnt), audit_request->unit_cnt = ml_cnt
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value= $MF_NURSE_UNIT)
     AND cv.active_ind=1
     AND cv.active_type_cd=mf_active_cd
     AND cv.data_status_cd=mf_auth_cd)
   ORDER BY cv.display
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt = (ml_cnt+ 1)
    IF (mod(ml_cnt,10)=1)
     CALL alterlist(audit_request->unit,(ml_cnt+ 9))
    ENDIF
    audit_request->unit[ml_cnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    CALL alterlist(audit_request->unit,ml_cnt), audit_request->unit_cnt = ml_cnt
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM med_admin_event mae,
   clinical_event ce
  PLAN (mae
   WHERE expand(ml_exp,1,size(audit_request->unit,5),mae.nurse_unit_cd,audit_request->unit[ml_exp].
    nurse_unit_cd)
    AND mae.updt_dt_tm BETWEEN cnvtdatetime(ms_start_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (ce
   WHERE ce.event_id=mae.event_id
    AND ce.result_status_cd IN (mf_nd_result_cd, mf_auth_cd))
  HEAD REPORT
   events_reply->administrations = 0, events_reply->not_done = 0, events_reply->total = 0,
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1)
   IF (ce.result_status_cd=mf_nd_result_cd)
    events_reply->not_done = (events_reply->not_done+ 1)
   ELSE
    events_reply->administrations = (events_reply->administrations+ 1)
   ENDIF
  FOOT REPORT
   events_reply->total = ml_cnt
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM med_admin_alert maa,
   med_admin_med_error mame,
   orders o
  PLAN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(ms_start_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND maa.alert_type_cd IN (mf_overdose_cd, mf_underdose_cd)
    AND expand(ml_exp,1,size(audit_request->unit,5),maa.nurse_unit_cd,audit_request->unit[ml_exp].
    nurse_unit_cd))
   JOIN (mame
   WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
   JOIN (o
   WHERE o.order_id=mame.order_id)
  ORDER BY o.order_id
  HEAD REPORT
   parent_order->dupl_cnt = 0, parent_order->total_orders_cnt = 0, mf_temp = 0,
   ml_cnt = 0
  DETAIL
   IF (mf_temp=o.order_id)
    parent_order->dupl_cnt = (parent_order->dupl_cnt+ 1)
   ELSE
    ml_cnt = (ml_cnt+ 1)
    IF (mod(ml_cnt,10)=1)
     CALL alterlist(parent_order->qual,(ml_cnt+ 9))
    ENDIF
    mf_temp = o.order_id, parent_order->qual[ml_cnt].order_id = o.order_id, parent_order->qual[ml_cnt
    ].action_seq = mame.action_sequence
    IF (o.template_order_id=0.00)
     parent_order->qual[ml_cnt].template_order_id = o.order_id
    ELSE
     parent_order->qual[ml_cnt].template_order_id = o.template_order_id
    ENDIF
   ENDIF
  FOOT REPORT
   CALL alterlist(parent_order->qual,ml_cnt), parent_order->total_orders_cnt = ml_cnt
  WITH expand = 1
 ;end select
 IF (size(parent_order->qual,5) <= 0)
  SET ms_status = "ERROR"
  SET ms_error = build2(ms_error,"No Data orders found for this date range: ",ms_start_dt_tm," - ",
   ms_end_dt_tm)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  template_order_id = parent_order->qual[d.seq].template_order_id
  FROM (dummyt d  WITH seq = size(parent_order->qual,5))
  ORDER BY template_order_id
  HEAD REPORT
   ml_cnt = 0
  HEAD template_order_id
   ml_cnt = (ml_cnt+ 1)
   IF (mod(ml_cnt,10)=1)
    CALL alterlist(ordered_ingrdnts->qual,(ml_cnt+ 9))
   ENDIF
   ordered_ingrdnts->qual[ml_cnt].template_order_id = template_order_id, ordered_ingrdnts->qual[
   ml_cnt].action_seq = parent_order->qual[d.seq].action_seq
  DETAIL
   ordered_ingrdnts->dupl_cnt = (ordered_ingrdnts->dupl_cnt+ 1), ordered_ingrdnts->qual[ml_cnt].
   dupl_cnt = (ordered_ingrdnts->qual[ml_cnt].dupl_cnt+ 1), parent_order->qual[d.seq].ordered_qual =
   ml_cnt
  FOOT REPORT
   CALL alterlist(ordered_ingrdnts->qual,ml_cnt), ordered_ingrdnts->tot_par_order_cnt = ml_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_ingredient oi,
   order_catalog_synonym ocs
  PLAN (oi
   WHERE expand(ml_exp,1,size(ordered_ingrdnts->qual,5),oi.order_id,ordered_ingrdnts->qual[ml_exp].
    template_order_id)
    AND (oi.action_sequence=ordered_ingrdnts->qual[ml_exp].action_seq))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(oi.synonym_id))
  ORDER BY oi.order_id, oi.synonym_id, cnvtdatetime(oi.updt_dt_tm)
  HEAD oi.order_id
   ml_found = locateval(ml_loc_cnt,1,ordered_ingrdnts->tot_par_order_cnt,oi.order_id,ordered_ingrdnts
    ->qual[ml_loc_cnt].template_order_id), ordered_ingrdnts->qual[ml_exp].dupl_cnt = 0, mf_temp = - (
   1.00),
   ml_cnt = 0
  DETAIL
   IF (mf_temp=oi.synonym_id)
    ordered_ingrdnts->qual[ml_found].dupl_ingr = (ordered_ingrdnts->qual[ml_found].dupl_ingr+ 1)
   ELSE
    ml_cnt = (ml_cnt+ 1)
    IF (mod(ml_cnt,10)=1)
     CALL alterlist(ordered_ingrdnts->qual[ml_found].ingr_qual,(ml_cnt+ 9))
    ENDIF
    mf_temp = oi.synonym_id, ordered_ingrdnts->qual[ml_found].ingr_qual[ml_cnt].synonym_id = oi
    .synonym_id, ordered_ingrdnts->qual[ml_found].ingr_qual[ml_cnt].syn_mne = trim(ocs.mnemonic),
    ordered_ingrdnts->qual[ml_found].ingr_qual[ml_cnt].catalog_disp = trim(uar_get_code_display(oi
      .catalog_cd))
    IF (oi.strength_unit > 0.00)
     IF (oi.volume_unit > 0.00)
      ordered_ingrdnts->qual[ml_found].ingr_qual[ml_cnt].ordered_dose = concat(trim(cnvtstring(oi
         .strength))," ",trim(uar_get_code_display(oi.strength_unit)),";",trim(cnvtstring(oi.volume)),
       " ",trim(uar_get_code_display(oi.volume_unit)))
     ELSE
      ordered_ingrdnts->qual[ml_found].ingr_qual[ml_cnt].ordered_dose = concat(trim(cnvtstring(oi
         .strength))," ",trim(uar_get_code_display(oi.strength_unit)))
     ENDIF
    ELSEIF (oi.volume_unit > 0.00)
     ordered_ingrdnts->qual[ml_found].ingr_qual[ml_cnt].ordered_dose = concat(trim(cnvtstring(oi
        .volume))," ",trim(uar_get_code_display(oi.volume_unit)))
    ELSE
     ordered_ingrdnts->qual[ml_found].ingr_qual[ml_cnt].ordered_dose = trim(oi.freetext_dose)
    ENDIF
   ENDIF
  FOOT  oi.order_id
   CALL alterlist(ordered_ingrdnts->qual[ml_found].ingr_qual,ml_cnt), ordered_ingrdnts->qual[ml_found
   ].total_ingr_cnt = ml_cnt
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM med_admin_alert maa,
   med_admin_med_error mame,
   med_admin_med_event_ingrdnt mamei,
   order_catalog_synonym ocs
  PLAN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(ms_start_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND maa.alert_type_cd IN (mf_overdose_cd, mf_underdose_cd)
    AND expand(ml_exp,1,size(audit_request->unit,5),maa.nurse_unit_cd,audit_request->unit[ml_exp].
    nurse_unit_cd))
   JOIN (mame
   WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
   JOIN (mamei
   WHERE mamei.parent_entity_id=outerjoin(mame.med_admin_med_error_id))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(mamei.synonym_id))
  ORDER BY mame.med_admin_med_error_id, mamei.parent_entity_id, mamei.synonym_id,
   cnvtdatetime(mamei.updt_dt_tm)
  HEAD REPORT
   parent_admined->dupl_cnt = 0, parent_admined->total_ingr_cnt = 1, mf_temp = - (1.00),
   ml_cnt2 = 0, ml_cnt = 0
  DETAIL
   IF (mame.med_admin_med_error_id > 0)
    IF (mf_temp != mame.med_admin_med_error_id)
     ml_cnt = (ml_cnt+ 1)
     IF (mod(ml_cnt,10)=1)
      CALL alterlist(parent_admined->qual,(ml_cnt+ 9))
     ENDIF
     mf_temp = mame.med_admin_med_error_id, parent_admined->qual[ml_cnt].mame_id = mame
     .med_admin_med_error_id, parent_admined->qual[ml_cnt].total_cnt = 0,
     parent_admined->qual[ml_cnt].dupl_cnt = 0, ml_cnt2 = 0, mf_temp2 = - (1.00)
    ENDIF
    IF (mamei.parent_entity_id > 0)
     IF (mf_temp2=mamei.synonym_id
      AND (parent_admined->qual[ml_cnt].total_cnt > 0))
      parent_admined->qual[ml_cnt].dupl_cnt = (parent_admined->qual[ml_cnt].dupl_cnt+ 1)
     ELSE
      ml_cnt2 = (ml_cnt2+ 1),
      CALL alterlist(parent_admined->qual[ml_cnt].ingr_qual,ml_cnt2), parent_admined->qual[ml_cnt].
      total_cnt = (parent_admined->qual[ml_cnt].total_cnt+ 1),
      mf_temp2 = mamei.synonym_id, parent_admined->qual[ml_cnt].ingr_qual[ml_cnt2].synonym_id = mamei
      .synonym_id, parent_admined->qual[ml_cnt].ingr_qual[ml_cnt2].syn_mne = trim(ocs.mnemonic),
      parent_admined->qual[ml_cnt].ingr_qual[ml_cnt2].catalog_disp = trim(uar_get_code_display(mamei
        .catalog_cd))
      IF (mamei.strength_unit_cd > 0.00)
       IF (mamei.volume_unit_cd > 0.00)
        parent_admined->qual[ml_cnt].ingr_qual[ml_cnt2].dose_admin = concat(trim(cnvtstring(mamei
           .strength))," ",trim(uar_get_code_display(mamei.strength_unit_cd)),";",trim(cnvtstring(
           mamei.volume)),
         " ",trim(uar_get_code_display(mamei.volume_unit_cd)))
       ELSE
        parent_admined->qual[ml_cnt].ingr_qual[ml_cnt2].dose_admin = concat(trim(cnvtstring(mamei
           .strength))," ",trim(uar_get_code_display(mamei.strength_unit_cd)))
       ENDIF
      ELSEIF (mamei.volume_unit_cd > 0.00)
       parent_admined->qual[ml_cnt].ingr_qual[ml_cnt2].dose_admin = concat(trim(cnvtstring(mamei
          .volume))," ",trim(uar_get_code_display(mamei.volume_unit_cd)))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   CALL alterlist(parent_admined->qual,ml_cnt), parent_admined->total_ingr_cnt = ml_cnt
  WITH expand = 1
 ;end select
 SELECT
  IF (mn_display_ind=1)
   ORDER BY maa.alert_type_cd, p2.name_full_formatted, p2.person_id,
    unit, maa.event_dt_tm
  ELSEIF (mn_display_ind=2)
   ORDER BY maa.alert_type_cd, date, p2.name_full_formatted,
    p2.person_id, maa.event_dt_tm, unit
  ELSEIF (mn_display_ind=3)
   ORDER BY maa.alert_type_cd, p1.name_full_formatted, p1.name_full_formatted,
    p2.person_id, unit, maa.event_dt_tm
  ELSE
  ENDIF
  INTO  $OUTDEV
  date = format(maa.event_dt_tm,"mm/dd/yy"), unit = uar_get_code_display(maa.nurse_unit_cd)
  FROM med_admin_alert maa,
   prsnl p1,
   med_admin_med_error mame,
   person p2,
   encntr_alias ea,
   med_admin_event mae
  PLAN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(ms_start_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND maa.alert_type_cd IN (mf_overdose_cd, mf_underdose_cd)
    AND expand(ml_exp,1,size(audit_request->unit,5),maa.nurse_unit_cd,audit_request->unit[ml_exp].
    nurse_unit_cd))
   JOIN (p1
   WHERE p1.person_id=outerjoin(maa.prsnl_id))
   JOIN (mame
   WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
   JOIN (p2
   WHERE p2.person_id=outerjoin(mame.person_id))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(mame.encounter_id)
    AND ea.encntr_alias_type_cd=outerjoin(mf_fin_cd))
   JOIN (mae
   WHERE mae.event_id=outerjoin(mame.event_id)
    AND mae.event_id > outerjoin(0.00))
  HEAD REPORT
   ms_last_row = "00000000000000000000", ml_cancelled_cnt = 0, ml_cnt = 0,
   ml_cnt2 = 0, ms_display = ""
  HEAD PAGE
   IF (( $OUTDEV != "MINE"))
    col 0, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
   ENDIF
   ms_display = concat("Date Range: ",ms_start_dt_tm," - ",ms_end_dt_tm), col 0, ms_display,
   ms_display = concat("Page: ",trim(cnvtstring(curpage))), col 122, ms_display,
   row + 1, ms_display = concat("Facility: ",trim(uar_get_code_display(mf_fac_cd))), col 0,
   ms_display, col 96, "Run Date: ",
   curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
   row + 1
   IF (mn_all_ind=1)
    ms_display = "Nurse Units: All"
   ELSEIF ((audit_request->unit_cnt > 1))
    ms_display = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].
       nurse_unit_cd),3))
    FOR (ml_nurse_cnt = 1 TO audit_request->unit_cnt)
      ms_display = concat(ms_display,", ",trim(uar_get_code_display(audit_request->unit[ml_nurse_cnt]
         .nurse_unit_cd),3))
    ENDFOR
    IF (textlen(ms_display) > 120)
     ms_display = substring(findstring(",",ms_display,120,0),textlen(ms_display),ms_display),
     ms_display = concat(ms_display," ...")
    ENDIF
   ELSEIF ((audit_request->unit_cnt=1))
    ms_display = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
       ),3))
   ELSE
    ms_display = "Nurse Unit: Unknown/Error"
   ENDIF
   col 0, ms_display, row + 1,
   CALL center(ms_title,1,131)
   IF (mn_display_ind=1)
    ms_display = "Display per: Patient"
   ELSEIF (mn_display_ind=2)
    ms_display = "Display per: Day"
   ELSEIF (mn_display_ind=3)
    ms_display = "Display per: User"
   ELSE
    ms_display = ""
   ENDIF
   col 111, ms_display, row + 1,
   col 0, ms_dashline, row + 1,
   col 50, "Ordered Med", col 95,
   "Ordered Dose", row + 1, col 0,
   "Date/Time", col 15, "Loc",
   col 25, "FIN", col 40,
   "Method", col 50, "Scanned Med",
   col 95, "Scanned Dose", col 115,
   "User", row + 1, col 0,
   ms_dashline, row + 1
  HEAD maa.alert_type_cd
   IF (row >= 46)
    BREAK
   ENDIF
   IF (maa.alert_type_cd=mf_overdose_cd)
    col 0, "Overdose"
   ELSE
    col 0, "Underdose"
   ENDIF
   row + 1, col 0, ms_dashline,
   row + 1
  HEAD p2.name_full_formatted
   IF (row >= 46)
    BREAK
   ENDIF
   col 0, p2.name_full_formatted, row + 1
  DETAIL
   IF (row >= 47)
    BREAK
   ENDIF
   IF (ms_last_row != maa.rowid)
    ml_cnt = (ml_cnt+ 1)
    IF (mod(ml_cnt,10)=1)
     CALL alterlist(audit_reply->summary_qual,(ml_cnt+ 9))
    ENDIF
    ms_last_row = maa.rowid, audit_reply->summary_qual[ml_cnt].date = format(maa.event_dt_tm,
     "mm/dd/yy hh:mm"), audit_reply->summary_qual[ml_cnt].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
    IF (mae.positive_med_ident_ind=0)
     ms_med_ident = "Select"
    ELSE
     ms_med_ident = "Scan"
    ENDIF
    IF (mame.event_id=0.00)
     ms_outcome = "Cancelled"
    ELSE
     ms_outcome = "Administered"
    ENDIF
    ml_found = locateval(ml_loc_cnt,1,parent_admined->total_ingr_cnt,mame.med_admin_med_error_id,
     parent_admined->qual[ml_loc_cnt].mame_id), ml_ingr_cnt = parent_admined->qual[ml_found].
    total_cnt,
    CALL alterlist(audit_reply->summary_qual[ml_cnt].admined_qual,ml_ingr_cnt),
    ml_cnt2 = 0
    WHILE (ml_cnt2 < ml_ingr_cnt)
      ml_cnt2 = (ml_cnt2+ 1), audit_reply->summary_qual[ml_cnt].admined_qual[ml_cnt2].synonym_id =
      parent_admined->qual[ml_found].ingr_qual[ml_cnt2].synonym_id, audit_reply->summary_qual[ml_cnt]
      .admined_qual[ml_cnt2].syn_mne = parent_admined->qual[ml_found].ingr_qual[ml_cnt2].syn_mne,
      audit_reply->summary_qual[ml_cnt].admined_qual[ml_cnt2].dose_admin = parent_admined->qual[
      ml_found].ingr_qual[ml_cnt2].dose_admin
    ENDWHILE
    ml_found2 = locateval(ml_loc_cnt2,1,parent_order->total_orders_cnt,mame.order_id,parent_order->
     qual[ml_loc_cnt2].order_id), ml_found2 = parent_order->qual[ml_found2].ordered_qual,
    ml_ingr_cnt2 = ordered_ingrdnts->qual[ml_found2].total_ingr_cnt,
    CALL alterlist(audit_reply->summary_qual[ml_cnt].ordered_qual,ml_ingr_cnt2), ml_cnt2 = 0
    WHILE (ml_cnt2 < ml_ingr_cnt2)
      ml_cnt2 = (ml_cnt2+ 1), audit_reply->summary_qual[ml_cnt].ordered_qual[ml_cnt2].synonym_id =
      ordered_ingrdnts->qual[ml_found2].ingr_qual[ml_cnt2].synonym_id, audit_reply->summary_qual[
      ml_cnt].ordered_qual[ml_cnt2].ordered_dose = ordered_ingrdnts->qual[ml_found2].ingr_qual[
      ml_cnt2].ordered_dose,
      audit_reply->summary_qual[ml_cnt].ordered_qual[ml_cnt2].syn_mne = ordered_ingrdnts->qual[
      ml_found2].ingr_qual[ml_cnt2].syn_mne
    ENDWHILE
    IF (row >= 47)
     BREAK
    ENDIF
    col 0, audit_reply->summary_qual[ml_cnt].date, col 15,
    unit, col 25, audit_reply->summary_qual[ml_cnt].fin,
    col 40, ms_med_ident
    FOR (i = 1 TO ml_ingr_cnt2)
      col 50,
      CALL print(substring(1,43,audit_reply->summary_qual[ml_cnt].ordered_qual[ml_cnt2].syn_mne)),
      col 95,
      CALL print(substring(1,18,audit_reply->summary_qual[ml_cnt].ordered_qual[ml_cnt2].ordered_dose)
      ), col 115, ms_outcome,
      row + 1
    ENDFOR
    FOR (i = 1 TO ml_ingr_cnt)
      col 50,
      CALL print(substring(1,43,audit_reply->summary_qual[ml_cnt].admined_qual[ml_cnt2].syn_mne)),
      col 95,
      CALL print(substring(1,18,audit_reply->summary_qual[ml_cnt].admined_qual[ml_cnt2].dose_admin)),
      col 115,
      CALL print(substring(1,16,trim(p1.name_full_formatted))),
      row + 1
    ENDFOR
    row + 1
   ENDIF
  FOOT REPORT
   IF (row > 45)
    BREAK
   ENDIF
   audit_reply->summary_qual_cnt = ml_cnt, audit_reply->cancelled_cnt = ml_cancelled_cnt,
   CALL alterlist(audit_reply->summary_qual,ml_cnt),
   ml_continued = (ml_cnt - ml_cancelled_cnt), audit_reply->continued_cnt = ml_continued, row + 2,
   col 20, "Administrations", ms_display = format(events_reply->administrations,"#########"),
   col 40, ms_display, col 60,
   "Total Alerts", ms_display = format(ml_cnt,"#########"), col 80,
   ms_display, row + 1, col 20,
   "Not Done", ms_display = format(events_reply->not_done,"#########"), col 40,
   ms_display, col 60, "Administered",
   ms_display = format(ml_continued,"#########"), col 80, ms_display,
   row + 1, col 20, "Total",
   ms_display = format(events_reply->total,"#########"), col 40, ms_display,
   col 60, "Cancelled", ms_display = format(ml_cancelled_cnt,"#########"),
   col 80, ms_display, row + 1
  WITH dio = postscript, maxrow = 50, expand = 1
 ;end select
 IF (((ms_status != "ERROR") OR (ms_status != "SUCCESS - EMAIL")) )
  SET ms_status = "SUCCESS"
 ENDIF
#exit_script
 IF (ms_status != "SUCCESS")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), "Point of Care Audit Over/Underdose Report - BHS_OUDOSE_AUDIT_DETAIL",
    "{F/1}{CPI/10}",
    CALL print(calcpos(10,30)), ms_error
   WITH dio = postscript, maxrow = 300, maxcol = 300
  ;end select
 ENDIF
 FREE RECORD audit_request
 FREE RECORD events_reply
 FREE RECORD parent_order
 FREE RECORD parent_admined
 FREE RECORD audit_reply
 FREE RECORD ordered_ingrdnts
END GO
