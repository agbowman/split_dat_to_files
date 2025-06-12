CREATE PROGRAM cern_dcp_rpt_rounds:dba
 RECORD temp(
   1 name = vc
   1 age = vc
   1 sex = vc
   1 unit = vc
   1 room = vc
   1 bed = vc
   1 rb = vc
   1 admit_dt = vc
   1 type = vc
   1 los = vc
   1 mrn = vc
   1 fnbr = vc
   1 address = vc
   1 city = vc
   1 state = vc
   1 zip = vc
   1 csz = vc
   1 phone = vc
   1 height = vc
   1 weight = vc
   1 attend_cnt = i2
   1 attend_qual[*]
     2 doc = c23
   1 consult_cnt = i2
   1 consult_qual[*]
     2 doc = c23
   1 refer_cnt = i2
   1 refer_qual[*]
     2 doc = c23
   1 admit_cnt = i2
   1 admit_qual[*]
     2 doc = c23
   1 contact_cnt = i2
   1 contact_qual[*]
     2 name = c23
     2 phone = vc
   1 insur_cnt = i2
   1 insur_qual[*]
     2 insur_name = vc
 )
 RECORD vitals(
   1 cnt = i2
   1 v[*]
     2 date = vc
     2 t = vc
     2 p = vc
     2 r = vc
     2 s = vc
     2 d = vc
     2 o = vc
     2 bp = vc
 )
 RECORD allergy(
   1 cnt = i2
   1 qual[*]
     2 list = vc
 )
 RECORD orders(
   1 cnt = i2
   1 qual[*]
     2 mnemonic = vc
     2 mnem_cnt = i2
     2 mnem_qual[*]
       3 mnem_line = vc
     2 display_line = vc
     2 disp_cnt = i2
     2 disp_qual[*]
       3 disp_line = vc
     2 date = vc
 )
 RECORD meds(
   1 cnt = i2
   1 qual[*]
     2 mnemonic = vc
     2 mnem_cnt = i2
     2 mnem_qual[*]
       3 mnem_line = vc
     2 freq = vc
     2 dose = vc
     2 doseunit = vc
     2 display_line = vc
     2 disp_cnt = i2
     2 disp_qual[*]
       3 disp_line = vc
     2 date = vc
 )
 RECORD labs(
   1 cnt = i2
   1 qual[*]
     2 label = vc
     2 result = vc
     2 date = vc
     2 unit = vc
     2 ref_range = vc
     2 normalcy = vc
 )
 RECORD rad(
   1 result = vc
   1 ln_cnt = i2
   1 ln_qual[*]
     2 line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET modify = predeclare
 DECLARE height_cd = f8 WITH noconstant(0.0)
 DECLARE weight_cd = f8 WITH noconstant(0.0)
 DECLARE temp_cd = f8 WITH noconstant(0.0)
 DECLARE pulse_cd = f8 WITH noconstant(0.0)
 DECLARE resp_cd = f8 WITH noconstant(0.0)
 DECLARE sbp_cd = f8 WITH noconstant(0.0)
 DECLARE dbp_cd = f8 WITH noconstant(0.0)
 DECLARE ox_cd = f8 WITH noconstant(0.0)
 DECLARE rad_cd = f8 WITH noconstant(0.0)
 DECLARE person_mrn_cd = f8 WITH noconstant(0.0)
 DECLARE encntr_mrn_cd = f8 WITH noconstant(0.0)
 DECLARE fnbr_cd = f8 WITH noconstant(0.0)
 DECLARE attend_cd = f8 WITH noconstant(0.0)
 DECLARE admit_cd = f8 WITH noconstant(0.0)
 DECLARE refer_cd = f8 WITH noconstant(0.0)
 DECLARE consult_cd = f8 WITH noconstant(0.0)
 DECLARE error_cd = f8 WITH noconstant(0.0)
 DECLARE canceled_cd = f8 WITH noconstant(0.0)
 DECLARE ordered_cd = f8 WITH noconstant(0.0)
 DECLARE inprocess_cd = f8 WITH noconstant(0.0)
 DECLARE pending_cd = f8 WITH noconstant(0.0)
 DECLARE pharmacy_cd = f8 WITH noconstant(0.0)
 DECLARE lab_cd = f8 WITH noconstant(0.0)
 DECLARE genlab_cd = f8 WITH noconstant(0.0)
 DECLARE contact_cd = f8 WITH noconstant(0.0)
 DECLARE home_phone_cd = f8 WITH noconstant(0.0)
 DECLARE home_address_cd = f8 WITH noconstant(0.0)
 DECLARE person_id = f8 WITH noconstant(0.0)
 DECLARE encntr_id = f8 WITH noconstant(0.0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE max_length = i2 WITH noconstant(0)
 DECLARE sze = i4 WITH noconstant(0)
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE daylight = i2 WITH protect, noconstant(0)
 DECLARE tz_index = i4 WITH protect, noconstant(0)
 IF ((request->visit[1].encntr_id <= 0))
  GO TO report_failed
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.display_key IN ("HEIGHT", "WEIGHT", "TEMPERATURE", "HEARTRATE", "RESPIRATORYRATE",
   "SYSTOLICBLOODPRESSURE", "DIASTOLICBLOODPRESSURE", "PULSEOXIMETRY", "DXIMPRESSION")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.display_key="HEIGHT")
    height_cd = cv.code_value
   ELSEIF (cv.display_key="WEIGHT")
    weight_cd = cv.code_value
   ELSEIF (cv.display_key="TEMPERATURE")
    temp_cd = cv.code_value
   ELSEIF (cv.display_key="HEARTRATE")
    pulse_cd = cv.code_value
   ELSEIF (cv.display_key="RESPIRATORYRATE")
    resp_cd = cv.code_value
   ELSEIF (cv.display_key="SYSTOLICBLOODPRESSURE")
    sbp_cd = cv.code_value
   ELSEIF (cv.display_key="DIASTOLICBLOODPRESSURE")
    dbp_cd = cv.code_value
   ELSEIF (cv.display_key="PULSEOXIMETRY")
    ox_cd = cv.code_value
   ELSEIF (cv.display_key="DXIMPRESSION")
    rad_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET person_mrn_cd = uar_get_code_by("MEANING",4,"MRN")
 SET encntr_mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 SET fnbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET attend_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 SET admit_cd = uar_get_code_by("MEANING",333,"ADMITDOC")
 SET refer_cd = uar_get_code_by("MEANING",333,"REFERDOC")
 SET consult_cd = uar_get_code_by("MEANING",333,"CONSULTDOC")
 SET error_cd = uar_get_code_by("MEANING",8,"INERROR")
 SET canceled_cd = uar_get_code_by("MEANING",12025,"CANCELED")
 SET ordered_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET inprocess_cd = uar_get_code_by("MEANING",6004,"INPROCESS")
 SET pending_cd = uar_get_code_by("MEANING",6004,"PENDING REV")
 SET pharmacy_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET lab_cd = uar_get_code_by("MEANING",6000,"GENERAL LAB")
 SET genlab_cd = uar_get_code_by("MEANING",106,"GLB")
 SET contact_cd = uar_get_code_by("MEANING",351,"EMC")
 SET home_phone_cd = uar_get_code_by("MEANING",43,"HOME")
 SET home_address_cd = uar_get_code_by("MEANING",212,"HOME")
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   (dummyt d1  WITH seq = 1),
   encntr_alias ea,
   (dummyt d3  WITH seq = 1),
   address a,
   (dummyt d4  WITH seq = 1),
   phone ph,
   encntr_loc_hist elh,
   time_zone_r t
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id)
   JOIN (t
   WHERE t.parent_entity_id=outerjoin(elh.loc_facility_cd)
    AND t.parent_entity_name=outerjoin("LOCATION"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (fnbr_cd, encntr_mrn_cd))
   JOIN (d3)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=home_address_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d4)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd=home_phone_cd
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY a.address_type_seq DESC, ph.phone_type_seq DESC
  HEAD REPORT
   tempphone = fillstring(22," "), fmtphone = fillstring(22," ")
  DETAIL
   temp->name = p.name_full_formatted, temp->age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate),3),
   temp->sex = uar_get_code_display(p.sex_cd),
   temp->type = uar_get_code_display(e.encntr_type_cd), temp->los = cnvtstring(datetimediff(
     cnvtdatetime(curdate,curtime),e.reg_dt_tm))
   IF (ea.encntr_alias_type_cd=fnbr_cd)
    temp->fnbr = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSEIF (ea.encntr_alias_type_cd=encntr_mrn_cd)
    temp->mrn = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ENDIF
   temp->unit = uar_get_code_display(e.loc_nurse_unit_cd), temp->room = uar_get_code_display(e
    .loc_room_cd), temp->bed = uar_get_code_display(e.loc_bed_cd),
   temp->rb = concat(trim(temp->room),"-",trim(temp->bed)), tz_index = datetimezonebyname(trim(t
     .time_zone)), temp->admit_dt = concat(format(datetimezone(e.reg_dt_tm,tz_index),
     "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(tz_index,offset,daylight,7,e.reg_dt_tm))
   IF (ph.phone_num > " ")
    tempphone = cnvtalphanum(ph.phone_num)
    IF (tempphone != ph.phone_num)
     fmtphone = ph.phone_num
    ELSE
     IF (ph.phone_format_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSEIF (size(tempphone) < 8)
      fmtphone = format(trim(ph.phone_num),"###-####")
     ELSE
      fmtphone = format(trim(ph.phone_num),"(###) ###-####")
     ENDIF
    ENDIF
    IF (fmtphone <= " ")
     fmtphone = ph.phone_num
    ENDIF
    IF (ph.extension > " ")
     fmtphone = concat(trim(fmtphone)," x",ph.extension)
    ENDIF
    temp->phone = trim(fmtphone)
   ENDIF
   temp->address = a.street_addr, temp->city = a.city
   IF (a.state_cd > 0)
    temp->state = uar_get_code_display(a.state_cd)
   ELSE
    temp->state = a.state
   ENDIF
   temp->zip = a.zipcode, temp->csz = concat(trim(temp->city)," ",trim(temp->state),"  ",trim(temp->
     zip)), person_id = e.person_id,
   encntr_id = e.encntr_id
  WITH nocounter, outerjoin = d1, dontcare = ea,
   outerjoin = d3, dontcare = a, outerjoin = d4,
   dontcare = ph
 ;end select
 IF ((temp->mrn <= " "))
  SELECT INTO "nl"
   FROM person_alias pa
   WHERE pa.person_id=person_id
    AND pa.person_alias_type_cd=person_mrn_cd
    AND pa.active_ind=1
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    temp->mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_plan_reltn epr,
   health_plan hp
  PLAN (epr
   WHERE epr.encntr_id=encntr_id
    AND epr.priority_seq IN (1, 99)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.active_ind=1)
  HEAD REPORT
   temp->insur_cnt = 0
  DETAIL
   temp->insur_cnt = (temp->insur_cnt+ 1), stat = alterlist(temp->insur_qual,temp->insur_cnt), temp->
   insur_qual[temp->insur_cnt].insur_name = hp.plan_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_person_reltn epr,
   person p,
   (dummyt d  WITH seq = 1),
   phone ph
  PLAN (epr
   WHERE epr.encntr_id=encntr_id
    AND epr.active_ind=1
    AND epr.person_reltn_type_cd=contact_cd
    AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE epr.related_person_id=p.person_id)
   JOIN (d)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd=home_phone_cd
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ph.phone_type_seq DESC
  HEAD REPORT
   tempphone = fillstring(22," "), fmtphone = fillstring(22," "), temp->contact_cnt = 0
  DETAIL
   temp->contact_cnt = (temp->contact_cnt+ 1), stat = alterlist(temp->contact_qual,temp->contact_cnt),
   temp->contact_qual[temp->contact_cnt].name = p.name_full_formatted
   IF (ph.phone_num > " ")
    tempphone = cnvtalphanum(ph.phone_num)
    IF (tempphone != ph.phone_num)
     fmtphone = ph.phone_num
    ELSE
     IF (ph.phone_format_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSEIF (size(tempphone) < 8)
      fmtphone = format(trim(ph.phone_num),"###-####")
     ELSE
      fmtphone = format(trim(ph.phone_num),"(###) ###-####")
     ENDIF
    ENDIF
    IF (fmtphone <= " ")
     fmtphone = ph.phone_num
    ENDIF
    IF (ph.extension > " ")
     fmtphone = concat(trim(fmtphone)," x",ph.extension)
    ENDIF
    temp->contact_qual[temp->contact_cnt].phone = trim(fmtphone)
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (epr
   WHERE epr.encntr_id=encntr_id
    AND epr.encntr_prsnl_r_cd=consult_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   temp->consult_cnt = 0
  DETAIL
   temp->consult_cnt = (temp->consult_cnt+ 1), stat = alterlist(temp->consult_qual,temp->consult_cnt),
   temp->consult_qual[temp->consult_cnt].doc = pl.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (epr
   WHERE epr.encntr_id=encntr_id
    AND epr.encntr_prsnl_r_cd=refer_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   temp->refer_cnt = 0
  DETAIL
   temp->refer_cnt = (temp->refer_cnt+ 1), stat = alterlist(temp->refer_qual,temp->refer_cnt), temp->
   refer_qual[temp->refer_cnt].doc = pl.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (epr
   WHERE epr.encntr_id=encntr_id
    AND epr.encntr_prsnl_r_cd=admit_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   temp->admit_cnt = 0
  DETAIL
   temp->admit_cnt = (temp->admit_cnt+ 1), stat = alterlist(temp->admit_qual,temp->admit_cnt), temp->
   admit_qual[temp->admit_cnt].doc = pl.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (epr
   WHERE epr.encntr_id=encntr_id
    AND epr.encntr_prsnl_r_cd=attend_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   temp->attend_cnt = 0
  DETAIL
   temp->attend_cnt = (temp->attend_cnt+ 1), stat = alterlist(temp->attend_qual,temp->attend_cnt),
   temp->attend_qual[temp->attend_cnt].doc = pl.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM allergy a,
   (dummyt d  WITH seq = 1),
   nomenclature n
  PLAN (a
   WHERE a.person_id=person_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY cnvtdatetime(a.onset_dt_tm)
  HEAD REPORT
   allergy->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    allergy->cnt = (allergy->cnt+ 1), stat = alterlist(allergy->qual,allergy->cnt), allergy->qual[
    allergy->cnt].list = a.substance_ftdesc
    IF (n.source_string > " ")
     allergy->qual[allergy->cnt].list = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = n
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c
  PLAN (c
   WHERE c.person_id=person_id
    AND c.encntr_id=encntr_id
    AND c.event_cd IN (height_cd, weight_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != error_cd)
  ORDER BY c.event_end_dt_tm
  DETAIL
   IF (c.event_cd=height_cd)
    temp->height = concat(trim(c.result_val)," ",trim(uar_get_code_display(c.result_units_cd)))
   ELSEIF (c.event_cd=weight_cd)
    temp->weight = concat(trim(c.result_val)," ",trim(uar_get_code_display(c.result_units_cd)))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c
  PLAN (c
   WHERE c.person_id=person_id
    AND c.encntr_id=encntr_id
    AND c.event_cd IN (temp_cd, resp_cd, pulse_cd, sbp_cd, dbp_cd,
   ox_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime((curdate - 5),curtime)
    AND c.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
    AND c.result_status_cd != error_cd)
  ORDER BY c.event_end_dt_tm DESC, c.parent_event_id
  HEAD REPORT
   vitals->cnt = 0
  HEAD c.parent_event_id
   vitals->cnt = (vitals->cnt+ 1)
  DETAIL
   stat = alterlist(vitals->v,vitals->cnt), vitals->v[vitals->cnt].date = concat(format(datetimezone(
      c.event_end_dt_tm,c.event_end_tz),"mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,
     offset,daylight,7,c.event_end_dt_tm))
   IF (c.event_cd=temp_cd)
    vitals->v[vitals->cnt].t = c.result_val
   ELSEIF (c.event_cd=pulse_cd)
    vitals->v[vitals->cnt].p = c.result_val
   ELSEIF (c.event_cd=resp_cd)
    vitals->v[vitals->cnt].r = c.result_val
   ELSEIF (c.event_cd=sbp_cd)
    vitals->v[vitals->cnt].s = c.result_val
   ELSEIF (c.event_cd=dbp_cd)
    vitals->v[vitals->cnt].d = c.result_val
   ELSEIF (c.event_cd=ox_cd)
    vitals->v[vitals->cnt].o = c.result_val
   ENDIF
  FOOT  c.parent_event_id
   IF ((vitals->v[vitals->cnt].s > " ")
    AND (vitals->v[vitals->cnt].d > " "))
    vitals->v[vitals->cnt].bp = concat(trim(vitals->v[vitals->cnt].s),"/",trim(vitals->v[vitals->cnt]
      .d))
   ENDIF
  WITH nocounter
 ;end select
 IF ((vitals->cnt > 5))
  SET vitals->cnt = 5
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   clinical_event c
  PLAN (o
   WHERE o.encntr_id=encntr_id
    AND o.catalog_type_cd=lab_cd
    AND o.activity_type_cd=genlab_cd
    AND o.template_order_flag IN (0, 1))
   JOIN (c
   WHERE c.order_id=o.order_id
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime((curdate - 2),curtime)
    AND c.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
    AND c.result_status_cd != error_cd)
  ORDER BY c.event_end_dt_tm
  HEAD REPORT
   labs->cnt = 0
  DETAIL
   labs->cnt = (labs->cnt+ 1), stat = alterlist(labs->qual,labs->cnt), labs->qual[labs->cnt].label =
   uar_get_code_display(c.event_cd),
   labs->qual[labs->cnt].result = c.result_val, labs->qual[labs->cnt].date = concat(format(
     datetimezone(c.event_end_dt_tm,c.event_end_tz),"mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c
     .event_end_tz,offset,daylight,7,c.event_end_dt_tm)), labs->qual[labs->cnt].unit =
   uar_get_code_display(c.result_units_cd),
   labs->qual[labs->cnt].normalcy = uar_get_code_display(c.normalcy_cd)
   IF (c.normal_low > " "
    AND c.normal_high > " ")
    labs->qual[labs->cnt].ref_range = build("(",c.normal_low,"-",c.normal_high,")")
   ELSE
    labs->qual[labs->cnt].ref_range = "(Nrml rng unspecfd)"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.encntr_id=encntr_id
    AND o.catalog_type_cd != pharmacy_cd
    AND o.order_status_cd IN (ordered_cd, pending_cd, inprocess_cd)
    AND o.template_order_flag IN (0, 1))
  ORDER BY o.orig_order_dt_tm
  HEAD REPORT
   orders->cnt = 0
  DETAIL
   orders->cnt = (orders->cnt+ 1), stat = alterlist(orders->qual,orders->cnt), orders->qual[orders->
   cnt].mnemonic = o.hna_order_mnemonic,
   orders->qual[orders->cnt].display_line = o.clinical_display_line, orders->qual[orders->cnt].date
    = concat(format(datetimezone(o.orig_order_dt_tm,o.orig_order_tz),"mm/dd/yy hh:mm;;d")," ",
    datetimezonebyindex(o.orig_order_tz,offset,daylight,7,o.orig_order_dt_tm))
  WITH nocounter
 ;end select
 FOR (y = 1 TO orders->cnt)
   SET pt->line_cnt = 0
   SET max_length = 32
   SET modify = nopredeclare
   EXECUTE dcp_parse_text value(orders->qual[y].mnemonic), value(max_length)
   SET modify = predeclare
   SET stat = alterlist(orders->qual[y].mnem_qual,pt->line_cnt)
   SET orders->qual[y].mnem_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET orders->qual[y].mnem_qual[x].mnem_line = pt->lns[x].line
   ENDFOR
   SET pt->line_cnt = 0
   SET max_length = 65
   SET modify = nopredeclare
   EXECUTE dcp_parse_text value(orders->qual[y].display_line), value(max_length)
   SET modify = predeclare
   SET stat = alterlist(orders->qual[y].disp_qual,pt->line_cnt)
   SET orders->qual[y].disp_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET orders->qual[y].disp_qual[x].disp_line = pt->lns[x].line
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.encntr_id=encntr_id
    AND o.catalog_type_cd=pharmacy_cd
    AND o.order_status_cd IN (ordered_cd, pending_cd, inprocess_cd)
    AND o.template_order_flag IN (0, 1))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT"))
  ORDER BY o.orig_order_dt_tm, od.action_sequence
  HEAD REPORT
   meds->cnt = 0
  HEAD o.order_id
   meds->cnt = (meds->cnt+ 1), stat = alterlist(meds->qual,meds->cnt), meds->qual[meds->cnt].mnemonic
    = o.hna_order_mnemonic,
   meds->qual[meds->cnt].display_line = o.clinical_display_line, meds->qual[meds->cnt].date = concat(
    format(datetimezone(o.orig_order_dt_tm,o.orig_order_tz),"mm/dd/yy hh:mm;;d")," ",
    datetimezonebyindex(o.orig_order_tz,offset,daylight,7,o.orig_order_dt_tm))
  DETAIL
   IF (od.oe_field_meaning="FREQ")
    meds->qual[meds->cnt].freq = od.oe_field_display_value
   ELSEIF (((od.oe_field_meaning="FREETXTDOSE") OR (od.oe_field_meaning="DOSE")) )
    meds->qual[meds->cnt].dose = od.oe_field_display_value
   ELSEIF (od.oe_field_meaning="DOSEUNIT")
    meds->qual[meds->cnt].doseunit = od.oe_field_display_value
   ENDIF
  FOOT  o.order_id
   IF ((meds->qual[meds->cnt].dose > " ")
    AND (meds->qual[meds->cnt].doseunit > " "))
    meds->qual[meds->cnt].dose = concat(trim(meds->qual[meds->cnt].dose)," ",trim(meds->qual[meds->
      cnt].doseunit))
   ENDIF
  WITH nocounter
 ;end select
 FOR (y = 1 TO meds->cnt)
   SET pt->line_cnt = 0
   SET max_length = 55
   SET modify = nopredeclare
   EXECUTE dcp_parse_text value(meds->qual[y].mnemonic), value(max_length)
   SET modify = predeclare
   SET stat = alterlist(meds->qual[y].mnem_qual,pt->line_cnt)
   SET meds->qual[y].mnem_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET meds->qual[y].mnem_qual[x].mnem_line = pt->lns[x].line
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  sze = textlen(cb.blob_contents)
  FROM clinical_event c,
   ce_blob cb
  PLAN (c
   WHERE c.person_id=person_id
    AND c.encntr_id=encntr_id
    AND c.event_cd IN (rad_cd)
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime((curdate - 2),curtime)
    AND c.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
    AND c.result_status_cd != error_cd)
   JOIN (cb
   WHERE cb.event_id=c.event_id
    AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY c.event_end_dt_tm
  DETAIL
   blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_ret_len = 0,
   CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len),
   CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), rad->result = blob_out2
  WITH nocounter
 ;end select
 SET pt->line_cnt = 0
 SET max_length = 100
 SET modify = nopredeclare
 EXECUTE dcp_parse_text value(rad->result), value(max_length)
 SET modify = predeclare
 SET stat = alterlist(rad->ln_qual,pt->line_cnt)
 SET rad->ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET rad->ln_qual[x].line = pt->lns[x].line
 ENDFOR
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, vitals_cnt = 1, vitals_head = 1,
   meds_cnt = 1, meds_head = 1, orders_cnt = 1,
   orders_head = 1
  HEAD PAGE
   "{f/13}{cpi/10}", row + 1, "{pos/240/35}ROUNDS LIST",
   row + 1, xcol = 30, ycol = 60,
   "{f/8}{cpi/14}", row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}", temp->name, row + 1,
   ycol = 70
  DETAIL
   CALL print(calcpos(xcol,ycol)), temp->address, row + 1,
   ycol = 80,
   CALL print(calcpos(xcol,ycol)), temp->csz,
   row + 1, ycol = 90,
   CALL print(calcpos(xcol,ycol)),
   temp->phone, row + 1, xcol = 185,
   ycol = 60,
   CALL print(calcpos(xcol,ycol)), temp->age,
   row + 1, ycol = 70,
   CALL print(calcpos(xcol,ycol)),
   temp->sex, row + 1, ycol = 80,
   CALL print(calcpos(xcol,ycol)), "Day: ", temp->los,
   row + 1, ycol = 90,
   CALL print(calcpos(xcol,ycol)),
   temp->type, row + 1, ycol = 60,
   xcol = 240,
   CALL print(calcpos(xcol,ycol)), temp->rb,
   row + 1, ycol = 70,
   CALL print(calcpos(xcol,ycol)),
   temp->admit_dt, row + 1, xcol = 320,
   ycol = 60,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Insurance",
   row + 1, ycol = (ycol+ 10)
   FOR (x = 1 TO temp->insur_cnt)
     CALL print(calcpos(xcol,ycol)), temp->insur_qual[x].insur_name, row + 1,
     ycol = (ycol+ 10)
   ENDFOR
   IF ((temp->insur_cnt > 0))
    ycol = (ycol - 10)
   ENDIF
   IF (ycol < 90)
    ycol = 90
   ENDIF
   ycol = (ycol+ 30), xcol = 30,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Contacts", row + 1, xcol = 140,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Admitting", row + 1,
   xcol = 250,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Attending",
   row + 1, xcol = 360,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Referring", row + 1, xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Consulting", row + 1,
   ycol = (ycol+ 10), scol = ycol, xcol = 30
   FOR (x = 1 TO temp->contact_cnt)
     CALL print(calcpos(xcol,ycol)), temp->contact_qual[x].name, row + 1,
     ycol = (ycol+ 10),
     CALL print(calcpos(xcol,ycol)), temp->contact_qual[x].phone,
     row + 1, ycol = (ycol+ 10)
   ENDFOR
   zcol = ycol, xcol = 140, ycol = scol
   FOR (x = 1 TO temp->admit_cnt)
     CALL print(calcpos(xcol,ycol)), temp->admit_qual[x].doc, row + 1,
     ycol = (ycol+ 10)
   ENDFOR
   IF (ycol > zcol)
    zcol = ycol
   ENDIF
   xcol = 250, ycol = scol
   FOR (x = 1 TO temp->attend_cnt)
     CALL print(calcpos(xcol,ycol)), temp->attend_qual[x].doc, row + 1,
     ycol = (ycol+ 10)
   ENDFOR
   IF (ycol > zcol)
    zcol = ycol
   ENDIF
   xcol = 360, ycol = scol
   FOR (x = 1 TO temp->refer_cnt)
     CALL print(calcpos(xcol,ycol)), temp->refer_qual[x].doc, row + 1,
     ycol = (ycol+ 10)
   ENDFOR
   IF (ycol > zcol)
    zcol = ycol
   ENDIF
   xcol = 470, ycol = scol
   FOR (x = 1 TO temp->consult_cnt)
     CALL print(calcpos(xcol,ycol)), temp->consult_qual[x].doc, row + 1,
     ycol = (ycol+ 10)
   ENDFOR
   IF (ycol > zcol)
    zcol = ycol
   ENDIF
   ycol = zcol, ycol = (ycol+ 20), xcol = 30
   IF (vitals->cnt)
    FOR (x = vitals_cnt TO vitals->cnt)
      IF (vitals_head)
       CALL print(calcpos(xcol,ycol)), "{b}{u}Vitals", row + 1,
       xcol = 100,
       CALL print(calcpos(xcol,ycol)), "{b}{u}Temperature",
       row + 1, xcol = 170,
       CALL print(calcpos(xcol,ycol)),
       "{b}{u}Pulse", row + 1, xcol = 240,
       CALL print(calcpos(xcol,ycol)), "{b}{u}Respiratory", row + 1,
       xcol = 310,
       CALL print(calcpos(xcol,ycol)), "{b}{u}Blood Pressure",
       row + 1, xcol = 380,
       CALL print(calcpos(xcol,ycol)),
       "{b}{u}Pulse Ox", row + 1, xcol = 450,
       CALL print(calcpos(xcol,ycol)), "{b}{u}Height", row + 1,
       xcol = 520,
       CALL print(calcpos(xcol,ycol)), "{b}{u}Weight",
       row + 1, ycol = (ycol+ 10), xcol = 450,
       CALL print(calcpos(xcol,ycol)), temp->height, row + 1,
       xcol = 520,
       CALL print(calcpos(xcol,ycol)), temp->weight,
       row + 1, vitals_head = 0
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), vitals->v[x].date,
      row + 1, xcol = 100,
      CALL print(calcpos(xcol,ycol)),
      vitals->v[x].t, row + 1, xcol = 170,
      CALL print(calcpos(xcol,ycol)), vitals->v[x].p, row + 1,
      xcol = 240,
      CALL print(calcpos(xcol,ycol)), vitals->v[x].r,
      row + 1, xcol = 310,
      CALL print(calcpos(xcol,ycol)),
      vitals->v[x].bp, row + 1, xcol = 380,
      CALL print(calcpos(xcol,ycol)), vitals->v[x].o, row + 1,
      ycol = (ycol+ 10)
      IF (ycol > 700
       AND (x < vitals->cnt))
       vitals_cnt = (x+ 1), vitals_head = 1, BREAK
      ENDIF
    ENDFOR
   ELSE
    CALL print(calcpos(xcol,ycol)), "{b}{u}Vitals", row + 1,
    xcol = 100,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Temperature",
    row + 1, xcol = 170,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Pulse", row + 1, xcol = 240,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Respiratory", row + 1,
    xcol = 310,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Blood Pressure",
    row + 1, xcol = 380,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Pulse Ox", row + 1, xcol = 450,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Height", row + 1,
    xcol = 520,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Weight",
    row + 1, ycol = (ycol+ 10), xcol = 30,
    CALL print(calcpos(xcol,ycol)), "No Active Vitals Found", row + 1,
    xcol = 450,
    CALL print(calcpos(xcol,ycol)), temp->height,
    row + 1, xcol = 520,
    CALL print(calcpos(xcol,ycol)),
    temp->weight, row + 1, ycol = (ycol+ 10)
   ENDIF
   ycol = (ycol+ 20), xcol = 30
   IF (meds->cnt)
    FOR (x = meds_cnt TO meds->cnt)
      IF (meds_head)
       CALL print(calcpos(xcol,ycol)), "{b}{u}Medication", row + 1,
       xcol = 300,
       CALL print(calcpos(xcol,ycol)), "{b}{u}Dose",
       row + 1, xcol = 425,
       CALL print(calcpos(xcol,ycol)),
       "{b}{u}Frequency", row + 1, ycol = (ycol+ 10),
       meds_head = 0
      ENDIF
      xcol = 30, scol = ycol
      FOR (y = 1 TO meds->qual[x].mnem_cnt)
        CALL print(calcpos(xcol,ycol)), meds->qual[x].mnem_qual[y].mnem_line, row + 1,
        ycol = (ycol+ 10)
      ENDFOR
      ycol = scol, xcol = 300,
      CALL print(calcpos(xcol,ycol)),
      meds->qual[x].dose, row + 1, xcol = 425,
      CALL print(calcpos(xcol,ycol)), meds->qual[x].freq, row + 1,
      ycol = (ycol+ 10)
      IF (ycol > 700
       AND (x < meds->cnt))
       meds_cnt = (x+ 1), meds_head = 1, BREAK
      ENDIF
    ENDFOR
   ELSE
    CALL print(calcpos(xcol,ycol)), "{b}{u}Medication", row + 1,
    xcol = 300,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Dose",
    row + 1, xcol = 425,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Frequency", row + 1, ycol = (ycol+ 10),
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "No Active Medications Found",
    row + 1, ycol = (ycol+ 10)
   ENDIF
   ycol = (ycol+ 20), xcol = 30
   IF (orders->cnt)
    FOR (x = orders_cnt TO orders->cnt)
      IF (orders_head)
       CALL print(calcpos(xcol,ycol)), "{b}{u}Active Orders", row + 1,
       xcol = 120,
       CALL print(calcpos(xcol,ycol)), "{b}{u}Orderable",
       row + 1, xcol = 270,
       CALL print(calcpos(xcol,ycol)),
       "{b}{u}Details", row + 1, ycol = (ycol+ 10),
       orders_head = 0
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), orders->qual[x].date,
      row + 1, xcol = 120, scol = ycol
      FOR (y = 1 TO orders->qual[x].mnem_cnt)
        CALL print(calcpos(xcol,ycol)), orders->qual[x].mnem_qual[y].mnem_line, row + 1,
        ycol = (ycol+ 10)
      ENDFOR
      ycol = scol, xcol = 270
      FOR (y = 1 TO orders->qual[x].disp_cnt)
        CALL print(calcpos(xcol,ycol)), orders->qual[x].disp_qual[y].disp_line, row + 1,
        ycol = (ycol+ 10)
      ENDFOR
      IF ((orders->qual[x].mnem_cnt > orders->qual[x].disp_cnt))
       ycol = (scol+ (orders->qual[x].mnem_cnt * 10))
      ENDIF
      IF (ycol > 700
       AND (x < orders->cnt))
       orders_cnt = (x+ 1), orders_head = 1, BREAK
      ENDIF
    ENDFOR
   ELSE
    CALL print(calcpos(xcol,ycol)), "{b}{u}Active Orders", row + 1,
    xcol = 100,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Orderable",
    row + 1, xcol = 250,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Details", row + 1, ycol = (ycol+ 10),
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "No Active Orders Found",
    row + 1, ycol = (ycol+ 10)
   ENDIF
   ycol = (ycol+ 20)
  FOOT PAGE
   ycol = 750, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}{cpi/16}Page", curpage, row + 1,
   xcol = 310, print_time = concat(format(datetimezone(cnvtdatetime(curdate,curtime),curtimezoneapp),
     "mm/dd/yy  hh:mm;4;q")," ",datetimezonebyindex(curtimezoneapp,offset,daylight,7,sysdate)),
   CALL print(calcpos(xcol,ycol)),
   print_time, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
 GO TO exit_script
#report_failed
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, vitals_cnt = 1, vitals_head = 1,
   meds_cnt = 1, meds_head = 1, orders_cnt = 1,
   orders_head = 1
  HEAD PAGE
   "{f/13}{cpi/10}", row + 1, "{pos/240/35}ROUNDS LIST",
   row + 1, xcol = 30, ycol = 60,
   "{f/8}{cpi/14}", row + 1, "{pos/25/66}{b}Report Failed: Invalid encounter Id used (",
   request->visit[1].encntr_id, ")", row + 1,
   ycol = 70
  FOOT PAGE
   ycol = 750, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}{cpi/16}Page", curpage, row + 1,
   xcol = 310, print_time = concat(format(datetimezone(cnvtdatetime(curdate,curtime),curtimezoneapp),
     "mm/dd/yy  hh:mm;4;q")," ",datetimezonebyindex(curtimezoneapp,offset,daylight,7,sysdate)),
   CALL print(calcpos(xcol,ycol)),
   print_time, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
#exit_script
END GO
