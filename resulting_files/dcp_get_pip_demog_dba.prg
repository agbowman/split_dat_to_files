CREATE PROGRAM dcp_get_pip_demog:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 name_full_formatted = vc
      2 gender_cd = f8
      2 gender_disp = c40
      2 birthdate = dq8
      2 age = c12
      2 vip_cd = f8
      2 confid_cd = f8
      2 confid_disp = c40
      2 mrn = vc
      2 reg_dt_tm = dq8
      2 bed_location_cd = f8
      2 bed_location_disp = c40
      2 bed_collation_seq = i4
      2 room_location_cd = f8
      2 room_location_disp = c40
      2 room_collation_seq = i4
      2 unit_location_cd = f8
      2 unit_location_disp = c40
      2 unit_collation_seq = i4
      2 building_location_cd = f8
      2 building_location_disp = c40
      2 building_collation_seq = i4
      2 facility_location_cd = f8
      2 facility_location_disp = c40
      2 facility_collation_seq = i4
      2 temp_location_cd = f8
      2 temp_location_disp = c40
      2 service_cd = f8
      2 service_disp = c40
      2 leave_ind = i2
      2 visit_reason = vc
      2 fin_nbr = vc
      2 los = vc
      2 encntr_type = f8
      2 encntr_type_disp = vc
      2 sticky_notes_ind = i2
      2 assign_notes_ind = i2
      2 rounds_notes_ind = i2
      2 plan_name = vc
      2 patient_status = f8
      2 discharge_date = dq8
      2 street_addr = vc
      2 street_addr2 = vc
      2 city = vc
      2 state = vc
      2 zipcode = vc
      2 phone_num = vc
      2 encntr_contact_info[*]
        3 person_reltn_type_cd = f8
        3 person_reltn_cd = f8
        3 name_full_formatted = vc
        3 street_addr = vc
        3 street_addr2 = vc
        3 city = vc
        3 state = vc
        3 zipcode = vc
        3 phone_num = vc
        3 priority_seq = i4
      2 lifetime_contact_info[*]
        3 person_reltn_type_cd = f8
        3 person_reltn_cd = f8
        3 name_full_formatted = vc
        3 street_addr = vc
        3 street_addr2 = vc
        3 city = vc
        3 state = vc
        3 zipcode = vc
        3 phone_num = vc
        3 priority_seq = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE cs = f8 WITH noconstant(0.0)
 DECLARE temp_phone = vc WITH public, noconstant(fillstring(40," "))
 DECLARE fmt_phone = vc WITH public, noconstant(fillstring(40," "))
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE code_set = i4 WITH noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE temp_phone = c22 WITH public, noconstant(fillstring(12," "))
 DECLARE fmt_phone = c22 WITH public, noconstant(fillstring(12," "))
 DECLARE guardian_cd = f8 WITH noconstant(0.0)
 DECLARE emc_cd = f8 WITH noconstant(0.0)
 DECLARE family_cd = f8 WITH noconstant(0.0)
 DECLARE nok_cd = f8 WITH noconstant(0.0)
 DECLARE valid_ind = i2 WITH noconstant(0)
 SET code_set = 281
 SET cdf_meaning = "DEFAULT"
 EXECUTE cpm_get_cd_for_cdf
 DECLARE default_format_cd = f8 WITH public, constant(code_value)
 SET code_set = 351
 SET cdf_meaning = "GUARDIAN"
 EXECUTE cpm_get_cd_for_cdf
 SET guardian_cd = code_value
 SET code_set = 351
 SET cdf_meaning = "EMC"
 EXECUTE cpm_get_cd_for_cdf
 SET emc_cd = code_value
 SET code_set = 351
 SET cdf_meaning = "FAMILY"
 EXECUTE cpm_get_cd_for_cdf
 SET family_cd = code_value
 SET code_set = 351
 SET cdf_meaning = "NOK"
 EXECUTE cpm_get_cd_for_cdf
 SET nok_cd = code_value
 SET sz = size(request->persons,5)
 SET cnt = 0
 SET stat = 0
 SET shiftnote_cd = 0.0
 SET shiftnote_mean = "ASGMTNOTE"
 SET powerchart_cd = 0.0
 SET powerchart_mean = "POWERCHART"
 SET roundnote_cd = 0.0
 SET roundnote_mean = "ROUNDNOTE"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET code_value = 0
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET homeaddresscode = code_value
 SET code_set = 43
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET homephonecode = code_value
 SET code_set = 14122
 SET cdf_meaning = shiftnote_mean
 EXECUTE cpm_get_cd_for_cdf
 SET shiftnote_cd = code_value
 SET code_set = 14122
 SET cdf_meaning = powerchart_mean
 EXECUTE cpm_get_cd_for_cdf
 SET powerchart_cd = code_value
 SET code_set = 14122
 SET cdf_meaning = roundnote_mean
 EXECUTE cpm_get_cd_for_cdf
 SET roundnote_cd = code_value
 SET cs = 71
 IF (sz > 0)
  SELECT INTO "nl:"
   FROM app_prefs a,
    name_value_prefs n
   PLAN (a
    WHERE (a.application_number=reqinfo->updt_app)
     AND a.position_cd=0
     AND a.prsnl_id=0)
    JOIN (n
    WHERE n.parent_entity_id=a.app_prefs_id
     AND n.parent_entity_name="APP_PREFS"
     AND n.pvc_name="ENCNTR_CODESET")
   DETAIL
    IF (n.pvc_value="*69*")
     cs = 69
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  nulld = nullind(p.deceased_dt_tm)
  FROM (dummyt d  WITH seq = value(sz)),
   person p,
   person_alias pa,
   address a,
   phone ph
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=request->persons[d.seq].person_id)
    AND p.active_ind=1)
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.active_ind=outerjoin(1)
    AND a.address_type_cd=outerjoin(homeaddresscode)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.phone_type_cd=outerjoin(homephonecode)
    AND ph.active_ind=outerjoin(1)
    AND ph.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ph.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.active_ind=outerjoin(1))
  ORDER BY p.person_id, a.address_type_seq DESC, ph.phone_type_seq DESC,
   pa.person_alias_id
  HEAD p.person_id
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].person_id = p.person_id,
   reply->qual[cnt].encntr_id = request->persons[d.seq].encntr_id, reply->qual[cnt].
   name_full_formatted = p.name_full_formatted, reply->qual[cnt].gender_cd = p.sex_cd,
   reply->qual[cnt].birthdate = p.birth_dt_tm, reply->qual[cnt].sticky_notes_ind = 0, reply->qual[cnt
   ].assign_notes_ind = 0,
   reply->qual[cnt].rounds_notes_ind = 0
   IF (nulld=0)
    reply->qual[cnt].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),
     cnvtint(format(p.birth_dt_tm,"hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,"mm/dd/yyyy;;d"),
      "mm/dd/yyyy"),cnvtint(format(p.deceased_dt_tm,"hhmm;;m")))
   ELSE
    reply->qual[cnt].age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),
     cnvtint(format(p.birth_dt_tm,"hhmm;;m")))
   ENDIF
   reply->qual[cnt].vip_cd = p.vip_cd, reply->qual[cnt].confid_cd = p.confid_level_cd
  HEAD a.address_type_seq
   reply->qual[cnt].street_addr = a.street_addr, reply->qual[cnt].street_addr2 = a.street_addr2,
   reply->qual[cnt].city = a.city
   IF (a.state > " ")
    reply->qual[cnt].state = a.state
   ELSE
    reply->qual[cnt].state = uar_get_code_display(a.state_cd)
   ENDIF
   reply->qual[cnt].zipcode = a.zipcode
  HEAD ph.phone_type_seq
   pprcnt = 0, fmt_phone = " "
   IF (ph.phone_num > " "
    AND ph.parent_entity_id > 0)
    temp_phone = cnvtalphanum(ph.phone_num)
    IF (temp_phone != ph.phone_num)
     fmt_phone = ph.phone_num
    ELSEIF (ph.phone_format_cd > 0)
     fmt_phone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
    ELSEIF (default_format_cd > 0)
     fmt_phone = cnvtphone(trim(ph.phone_num),default_format_cd)
    ELSEIF (size(trim(temp_phone)) < 8)
     fmt_phone = format(trim(ph.phone_num),"###-####")
    ELSE
     fmt_phone = format(trim(ph.phone_num),"(###) ###-####")
    ENDIF
    IF (fmt_phone <= " ")
     fmt_phone = ph.phone_num
    ENDIF
    reply->qual[cnt].phone_num = fmt_phone
   ENDIF
  HEAD pa.person_alias_id
   IF (pa.person_alias_type_cd=mrn_cd)
    reply->qual[cnt].mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fin_cd = code_value
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   encounter e,
   encntr_leave el,
   encntr_alias ea,
   encntr_plan_reltn eplr,
   person_plan_reltn pplr,
   health_plan hp1,
   health_plan hp2,
   encntr_person_reltn epsr,
   person_person_reltn ppsr,
   person p1,
   person p2,
   address a1,
   address a2,
   phone ph1,
   phone ph2,
   sticky_note sn
  PLAN (d
   WHERE (reply->qual[d.seq].encntr_id > 0))
   JOIN (e
   WHERE (e.encntr_id=reply->qual[d.seq].encntr_id))
   JOIN (el
   WHERE el.encntr_id=outerjoin(e.encntr_id)
    AND el.active_ind=outerjoin(1))
   JOIN (eplr
   WHERE eplr.encntr_id=outerjoin(e.encntr_id)
    AND eplr.health_plan_id > outerjoin(0)
    AND eplr.active_ind=outerjoin(1))
   JOIN (hp1
   WHERE hp1.health_plan_id=outerjoin(eplr.health_plan_id)
    AND hp1.active_ind=outerjoin(1))
   JOIN (pplr
   WHERE pplr.person_id=outerjoin(e.person_id)
    AND pplr.active_ind=outerjoin(1))
   JOIN (hp2
   WHERE hp2.health_plan_id=outerjoin(pplr.health_plan_id)
    AND hp2.active_ind=outerjoin(1))
   JOIN (epsr
   WHERE epsr.encntr_id=outerjoin(e.encntr_id)
    AND epsr.active_ind=outerjoin(1))
   JOIN (p1
   WHERE p1.person_id=outerjoin(epsr.related_person_id)
    AND p1.active_ind=outerjoin(1))
   JOIN (a1
   WHERE a1.parent_entity_name=outerjoin("PERSON")
    AND a1.parent_entity_id=outerjoin(p1.person_id)
    AND a1.active_ind=outerjoin(1)
    AND a1.address_type_cd=outerjoin(homeaddresscode)
    AND a1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ph1
   WHERE ph1.parent_entity_name=outerjoin("PERSON")
    AND ph1.parent_entity_id=outerjoin(p1.person_id)
    AND ph1.phone_type_cd=outerjoin(homephonecode)
    AND ph1.active_ind=outerjoin(1)
    AND ph1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ph1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ppsr
   WHERE ppsr.person_id=outerjoin(e.person_id)
    AND ppsr.active_ind=outerjoin(1))
   JOIN (p2
   WHERE p2.person_id=outerjoin(ppsr.related_person_id)
    AND p2.active_ind=outerjoin(1))
   JOIN (a2
   WHERE a2.parent_entity_name=outerjoin("PERSON")
    AND a2.parent_entity_id=outerjoin(p2.person_id)
    AND a2.active_ind=outerjoin(1)
    AND a2.address_type_cd=outerjoin(homeaddresscode)
    AND a2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ph2
   WHERE ph2.parent_entity_name=outerjoin("PERSON")
    AND ph2.parent_entity_id=outerjoin(p2.person_id)
    AND ph2.phone_type_cd=outerjoin(homephonecode)
    AND ph2.active_ind=outerjoin(1)
    AND ph2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ph2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1))
   JOIN (sn
   WHERE ((sn.parent_entity_id=e.person_id
    AND sn.parent_entity_name="PERSON"
    AND sn.sticky_note_type_cd IN (powerchart_cd, shiftnote_cd, roundnote_cd)) OR (sn.sticky_note_id=
   0)) )
  ORDER BY e.encntr_id, epsr.encntr_person_reltn_id, a1.address_type_seq DESC,
   ph1.phone_type_seq DESC, ppsr.person_person_reltn_id, a2.address_type_seq DESC,
   ph2.phone_type_seq DESC, sn.parent_entity_id, uar_get_collation_seq(epsr.person_reltn_type_cd),
   uar_get_collation_seq(ppsr.person_reltn_type_cd)
  HEAD d.seq
   epsrcnt = 0, ppsrcnt = 0, valid_ind = 0,
   reply->qual[d.seq].patient_status = e.encntr_status_cd, reply->qual[d.seq].discharge_date = e
   .disch_dt_tm, reply->qual[d.seq].encntr_id = e.encntr_id,
   reply->qual[d.seq].confid_cd = e.confid_level_cd, reply->qual[d.seq].reg_dt_tm = e.reg_dt_tm,
   reply->qual[d.seq].bed_location_cd = e.loc_bed_cd,
   reply->qual[d.seq].bed_collation_seq = uar_get_collation_seq(e.loc_bed_cd), reply->qual[d.seq].
   room_location_cd = e.loc_room_cd, reply->qual[d.seq].room_collation_seq = uar_get_collation_seq(e
    .loc_room_cd),
   reply->qual[d.seq].unit_location_cd = e.loc_nurse_unit_cd, reply->qual[d.seq].unit_collation_seq
    = uar_get_collation_seq(e.loc_nurse_unit_cd), reply->qual[d.seq].building_location_cd = e
   .loc_building_cd,
   reply->qual[d.seq].building_collation_seq = uar_get_collation_seq(e.loc_building_cd), reply->qual[
   d.seq].facility_location_cd = e.loc_facility_cd, reply->qual[d.seq].facility_collation_seq =
   uar_get_collation_seq(e.loc_facility_cd),
   reply->qual[d.seq].temp_location_cd = e.loc_temp_cd, reply->qual[d.seq].service_cd = e
   .med_service_cd, reply->qual[d.seq].visit_reason = e.reason_for_visit,
   reply->qual[d.seq].leave_ind = el.leave_ind
   IF (cs=71)
    reply->qual[d.seq].encntr_type = e.encntr_type_cd, reply->qual[d.seq].encntr_type_disp =
    uar_get_code_display(e.encntr_type_cd)
   ELSE
    reply->qual[d.seq].encntr_type = e.encntr_type_class_cd, reply->qual[d.seq].encntr_type_disp =
    uar_get_code_display(e.encntr_type_class_cd)
   ENDIF
   IF (e.reg_dt_tm > 0)
    IF (e.disch_dt_tm > 0)
     tempday = datetimediff(e.disch_dt_tm,e.reg_dt_tm), reply->qual[d.seq].los = concat(format(
       tempday,"####.#")," ","Days")
    ELSE
     tempday = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm), reply->qual[d.seq].los =
     concat(format(tempday,"####.#")," ","Days")
    ENDIF
   ELSE
    reply->qual[d.seq].los = " "
   ENDIF
   IF (hp1.health_plan_id > 0)
    reply->qual[d.seq].plan_name = hp1.plan_name
   ELSE
    reply->qual[d.seq].plan_name = hp2.plan_name
   ENDIF
  HEAD epsr.encntr_person_reltn_id
   IF (epsr.encntr_person_reltn_id != 0)
    IF (epsr.person_reltn_type_cd IN (guardian_cd, emc_cd, family_cd, nok_cd))
     epsrcnt = (epsrcnt+ 1), stat = alterlist(reply->qual[d.seq].encntr_contact_info,epsrcnt), reply
     ->qual[d.seq].encntr_contact_info[epsrcnt].person_reltn_type_cd = epsr.person_reltn_type_cd,
     reply->qual[d.seq].encntr_contact_info[epsrcnt].person_reltn_cd = epsr.person_reltn_cd, reply->
     qual[d.seq].encntr_contact_info[epsrcnt].priority_seq = epsr.priority_seq, reply->qual[d.seq].
     encntr_contact_info[epsrcnt].name_full_formatted = p1.name_full_formatted
    ELSE
     valid_ind = 1
    ENDIF
   ENDIF
  HEAD a1.address_type_seq
   IF (a1.address_id != 0)
    IF (valid_ind=0)
     reply->qual[d.seq].encntr_contact_info[epsrcnt].street_addr = a1.street_addr, reply->qual[d.seq]
     .encntr_contact_info[epsrcnt].street_addr2 = a1.street_addr2, reply->qual[d.seq].
     encntr_contact_info[epsrcnt].city = a1.city
     IF (a1.state > " ")
      reply->qual[d.seq].encntr_contact_info[epsrcnt].state = a1.state
     ELSE
      reply->qual[d.seq].encntr_contact_info[epsrcnt].state = uar_get_code_display(a1.state_cd)
     ENDIF
     reply->qual[d.seq].encntr_contact_info[epsrcnt].zipcode = a1.zipcode
    ENDIF
   ENDIF
  HEAD ph1.phone_type_seq
   IF (ph1.phone_id != 0)
    IF (valid_ind=0)
     fmt_phone = " "
     IF (ph1.phone_num > " "
      AND ph1.parent_entity_id > 0)
      temp_phone = cnvtalphanum(ph1.phone_num)
      IF (temp_phone != ph1.phone_num)
       fmt_phone = ph1.phone_num
      ELSEIF (ph1.phone_format_cd > 0)
       fmt_phone = cnvtphone(trim(ph1.phone_num),ph1.phone_format_cd)
      ELSEIF (default_format_cd > 0)
       fmt_phone = cnvtphone(trim(ph1.phone_num),default_format_cd)
      ELSEIF (size(trim(temp_phone)) < 8)
       fmt_phone = format(trim(ph1.phone_num),"###-####")
      ELSE
       fmt_phone = format(trim(ph1.phone_num),"(###) ###-####")
      ENDIF
      IF (fmt_phone <= " ")
       fmt_phone = ph1.phone_num
      ENDIF
      reply->qual[d.seq].encntr_contact_info[epsrcnt].phone_num = fmt_phone
     ENDIF
    ENDIF
   ENDIF
  HEAD ppsr.person_person_reltn_id
   IF (ppsr.person_person_reltn_id != 0)
    IF (ppsr.person_reltn_type_cd IN (guardian_cd, emc_cd, family_cd, nok_cd))
     ppsrcnt = (ppsrcnt+ 1), stat = alterlist(reply->qual[d.seq].lifetime_contact_info,ppsrcnt),
     reply->qual[d.seq].lifetime_contact_info[ppsrcnt].person_reltn_type_cd = ppsr
     .person_reltn_type_cd,
     reply->qual[d.seq].lifetime_contact_info[ppsrcnt].person_reltn_cd = ppsr.person_reltn_cd, reply
     ->qual[d.seq].lifetime_contact_info[ppsrcnt].priority_seq = ppsr.priority_seq, reply->qual[d.seq
     ].lifetime_contact_info[ppsrcnt].name_full_formatted = p2.name_full_formatted
    ELSE
     valid_ind = 1
    ENDIF
   ENDIF
  HEAD a2.address_type_seq
   IF (a2.address_id != 0)
    IF (valid_ind=0)
     reply->qual[d.seq].lifetime_contact_info[ppsrcnt].street_addr = a2.street_addr, reply->qual[d
     .seq].lifetime_contact_info[ppsrcnt].street_addr2 = a2.street_addr2, reply->qual[d.seq].
     lifetime_contact_info[ppsrcnt].city = a2.city
     IF (a2.state > " ")
      reply->qual[d.seq].lifetime_contact_info[ppsrcnt].state = a2.state
     ELSE
      reply->qual[d.seq].lifetime_contact_info[ppsrcnt].state = uar_get_code_display(a2.state_cd)
     ENDIF
     reply->qual[d.seq].lifetime_contact_info[ppsrcnt].zipcode = a2.zipcode
    ENDIF
   ENDIF
  HEAD ph2.phone_type_seq
   IF (ph2.phone_id != 0)
    IF (valid_ind=0)
     fmt_phone = " "
     IF (ph2.phone_num > " "
      AND ph2.parent_entity_id > 0)
      temp_phone = cnvtalphanum(ph2.phone_num)
      IF (temp_phone != ph2.phone_num)
       fmt_phone = ph2.phone_num
      ELSEIF (ph2.phone_format_cd > 0)
       fmt_phone = cnvtphone(trim(ph2.phone_num),ph2.phone_format_cd)
      ELSEIF (default_format_cd > 0)
       fmt_phone = cnvtphone(trim(ph2.phone_num),default_format_cd)
      ELSEIF (size(trim(temp_phone)) < 8)
       fmt_phone = format(trim(ph2.phone_num),"###-####")
      ELSE
       fmt_phone = format(trim(ph2.phone_num),"(###) ###-####")
      ENDIF
      IF (fmt_phone <= " ")
       fmt_phone = ph2.phone_num
      ENDIF
      reply->qual[d.seq].lifetime_contact_info[ppsrcnt].phone_num = fmt_phone
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (ea.encntr_alias_type_cd=mrn_cd)
    reply->qual[d.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSEIF (ea.encntr_alias_type_cd=fin_cd)
    reply->qual[d.seq].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
   ENDIF
   IF (sn.sticky_note_type_cd=powerchart_cd)
    reply->qual[d.seq].sticky_notes_ind = 1
   ELSEIF (sn.sticky_note_type_cd=shiftnote_cd)
    reply->qual[d.seq].assign_notes_ind = 1
   ELSEIF (sn.sticky_note_type_cd=roundnote_cd
    AND (((sn.parent_entity_id=reqinfo->updt_id)) OR (sn.public_ind=1)) )
    reply->qual[d.seq].rounds_notes_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#finish
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
