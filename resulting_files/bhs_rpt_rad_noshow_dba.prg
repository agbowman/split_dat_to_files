CREATE PROGRAM bhs_rpt_rad_noshow:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Report Type:" = "details",
  "Facility:" = 0,
  "Resource:" = value(0.0),
  "Modality:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_rpt_type, f_inst_cd, f_resource_cd,
  s_modality
 FREE RECORD m_rec
 RECORD m_rec(
   1 res[*]
     2 f_res_cd = f8
   1 totals[*]
     2 s_facility = vc
     2 f_tot_cnt = f8
     2 f_nos_cnt = f8
     2 section[*]
       3 s_section = vc
       3 f_tot_cnt = f8
       3 f_nos_cnt = f8
   1 rollup[*]
     2 s_loc = vc
     2 s_nos_pct = vc
     2 s_tot_cnt = vc
     2 s_nos_cnt = vc
   1 details[*]
     2 f_schedule_id = f8
     2 f_person_id = f8
     2 s_facility = vc
     2 s_service_res = vc
     2 s_modality = vc
     2 s_appt_type = vc
     2 s_appt_dt_tm = vc
     2 s_reason_for_exam = vc
     2 s_patient_name = vc
     2 s_phone = vc
     2 s_dob = vc
     2 s_acc = vc
     2 s_ord_provider = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE ms_rpt_type = vc WITH protect, constant(trim(cnvtlower( $S_RPT_TYPE),3))
 DECLARE ms_modality = vc WITH protect, constant(trim(cnvtlower( $S_MODALITY),3))
 DECLARE mf_res_cd = f8 WITH protect, constant(cnvtreal( $F_RESOURCE_CD))
 DECLARE mf_home_ph_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"HOME"))
 DECLARE mf_cell_ph_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"CELL"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_rad_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_noshow_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",14233,"No Show"))
 DECLARE mf_arrived_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",14233,"Checked In"))
 DECLARE ms_res_parse = vc WITH protect, noconstant(" ")
 DECLARE ms_mod_parse = vc WITH protect, noconstant(" ")
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop_i = i4 WITH protect, noconstant(0)
 DECLARE ml_loop_j = i4 WITH protect, noconstant(0)
 DECLARE ml_fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_sec_cnt = i4 WITH protect, noconstant(0)
 IF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_error = "Start date must be prior to end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(ms_end_dt_tm),cnvtdatetime(ms_beg_dt_tm)) > 90)
  SET ms_error = "Date range exceeds 90 days."
  GO TO exit_script
 ENDIF
 IF (( $F_RESOURCE_CD=0.0))
  SET ms_res_parse = "1=1"
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value= $F_RESOURCE_CD)
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt += 1,
    CALL alterlist(m_rec->res,ml_cnt), m_rec->res[ml_cnt].f_res_cd = cv.code_value
    IF (ml_cnt > 1)
     ms_tmp = concat(ms_tmp,",")
    ENDIF
    ms_tmp = concat(ms_tmp,trim(cnvtstring(cv.code_value),3),".0")
   WITH nocounter
  ;end select
  SET ms_res_parse = concat("sa.resource_cd in (",ms_tmp,")")
 ENDIF
 IF (ms_modality="0")
  SET ms_mod_parse = "1=1"
 ELSE
  SET ms_data_type = build(reflect(parameter(parameter2( $S_MODALITY),0)))
  IF (substring(1,1,ms_data_type)="C")
   SET ms_mod_parse = concat(" cv.display_key = '",trim( $S_MODALITY,3),"*'")
  ELSEIF (substring(1,1,ms_data_type)="L")
   FOR (ml_loop = 1 TO cnvtint(substring(2,(textlen(ms_data_type) - 1),ms_data_type)))
     SET ms_tmp = parameter(parameter2( $S_MODALITY),ml_loop)
     SET ms_tmp = trim(ms_tmp,3)
     IF (ml_loop=1)
      SET ms_mod_parse = concat(" (cv.display_key = '",ms_tmp,"*' ")
     ELSE
      SET ms_mod_parse = concat(ms_mod_parse," or cv.display_key = '",ms_tmp,"*' ")
     ENDIF
   ENDFOR
   SET ms_mod_parse = concat(ms_mod_parse,")")
  ENDIF
 ENDIF
 IF (ms_rpt_type="details")
  SELECT INTO "nl:"
   facility = substring(1,20,uar_get_code_display(rg4.parent_service_resource_cd)), service_resource
    = substring(1,20,uar_get_code_display(sa.service_resource_cd)), modality = trim(substring(1,3,cv
     .display),3),
   appt_type = substring(1,50,uar_get_code_display(se.appt_type_cd)), appt_dt_tm = format(sa
    .beg_dt_tm,"mm/dd/yyyy HH:mm:ss;;d"), reason_for_exam = substring(1,25,od.oe_field_display_value),
   ordering_provider = substring(1,50,pr.name_full_formatted)
   FROM sch_appt sa,
    sch_event se,
    code_value cv,
    sch_event_attach sea,
    orders o,
    order_detail od,
    order_action oa,
    prsnl pr,
    resource_group rg1,
    resource_group rg2,
    resource_group rg3,
    resource_group rg4
   PLAN (sa
    WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
     AND parser(ms_res_parse)
     AND sa.sch_state_cd=mf_noshow_cd
     AND sa.role_meaning="EXAMROOM"
     AND sa.active_ind=1)
    JOIN (se
    WHERE se.sch_event_id=sa.sch_event_id
     AND se.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=se.appt_type_cd
     AND parser(ms_mod_parse)
     AND trim(substring(1,3,cv.display),3) IN ("CT", "MM", "MRI", "NM", "US",
    "XR"))
    JOIN (sea
    WHERE sea.sch_event_id=sa.sch_event_id)
    JOIN (o
    WHERE o.order_id=sea.order_id
     AND o.catalog_type_cd=mf_rad_cat_cd
     AND o.active_ind=1)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_meaning="REASONFOREXAM")
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=mf_order_cd)
    JOIN (pr
    WHERE pr.person_id=oa.order_provider_id)
    JOIN (rg1
    WHERE rg1.child_service_resource_cd=sa.service_resource_cd)
    JOIN (rg2
    WHERE rg2.child_service_resource_cd=rg1.parent_service_resource_cd)
    JOIN (rg3
    WHERE rg3.child_service_resource_cd=rg2.parent_service_resource_cd)
    JOIN (rg4
    WHERE rg4.child_service_resource_cd=rg3.parent_service_resource_cd)
   ORDER BY facility, service_resource, modality,
    sa.beg_dt_tm
   HEAD REPORT
    ml_cnt = 0
   HEAD sa.schedule_id
    ml_cnt += 1
    IF (ml_cnt > size(m_rec->details,5))
     CALL alterlist(m_rec->details,(ml_cnt+ 99))
    ENDIF
    m_rec->details[ml_cnt].f_schedule_id = sa.schedule_id, m_rec->details[ml_cnt].s_facility =
    uar_get_code_display(rg4.parent_service_resource_cd), m_rec->details[ml_cnt].s_service_res =
    uar_get_code_display(sa.service_resource_cd),
    m_rec->details[ml_cnt].s_modality = substring(1,3,cv.display), m_rec->details[ml_cnt].s_appt_type
     = uar_get_code_display(se.appt_type_cd), m_rec->details[ml_cnt].s_appt_dt_tm = format(sa
     .beg_dt_tm,"mm/dd/yyyy HH:mm:ss;;d"),
    m_rec->details[ml_cnt].s_reason_for_exam = od.oe_field_display_value, m_rec->details[ml_cnt].
    s_ord_provider = pr.name_full_formatted
   FOOT REPORT
    CALL alterlist(m_rec->details,ml_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_rec->details,5))),
    sch_appt sa,
    person p,
    encntr_alias ea
   PLAN (d)
    JOIN (sa
    WHERE (sa.schedule_id=m_rec->details[d.seq].f_schedule_id)
     AND sa.role_meaning="PATIENT"
     AND sa.active_ind=1)
    JOIN (p
    WHERE p.person_id=sa.person_id)
    JOIN (ea
    WHERE ea.encntr_id=sa.encntr_id
     AND ea.encntr_alias_type_cd=mf_fin_cd
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   HEAD d.seq
    m_rec->details[d.seq].f_person_id = p.person_id, m_rec->details[d.seq].s_patient_name = p
    .name_full_formatted, m_rec->details[d.seq].s_acc = ea.alias,
    m_rec->details[d.seq].s_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d")
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_rec->details,5))),
    phone ph
   PLAN (d)
    JOIN (ph
    WHERE (ph.parent_entity_id=m_rec->details[d.seq].f_person_id)
     AND ph.parent_entity_name="PERSON"
     AND ph.phone_type_cd IN (mf_home_ph_cd, mf_cell_ph_cd)
     AND ph.active_ind=1
     AND  NOT (ph.phone_num IN (null, "(000)000-0000"))
     AND ph.phone_type_seq=1)
   DETAIL
    IF (textlen(trim(m_rec->details[d.seq].s_phone,3))=0
     AND (m_rec->details[d.seq].s_phone != build2("*",trim(ph.phone_num,3),"*")))
     m_rec->details[d.seq].s_phone = build2("(",trim(cnvtupper(uar_get_code_display(ph.phone_type_cd)
        ),3),") ",trim(ph.phone_num,3))
    ELSE
     m_rec->details[d.seq].s_phone = build2(trim(m_rec->details[d.seq].s_phone,3),", (",trim(
       cnvtupper(uar_get_code_display(ph.phone_type_cd)),3),") ",trim(ph.phone_num,3))
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO value( $OUTDEV)
   facility = m_rec->details[d.seq].s_facility, service_resource = m_rec->details[d.seq].
   s_service_res, modality = m_rec->details[d.seq].s_modality,
   appt_type = m_rec->details[d.seq].s_appt_type, appt_dt_tm = m_rec->details[d.seq].s_appt_dt_tm,
   reason_for_exam = m_rec->details[d.seq].s_reason_for_exam,
   patient_name = substring(1,50,m_rec->details[d.seq].s_patient_name), patient_phone = substring(1,
    100,m_rec->details[d.seq].s_phone), dob = m_rec->details[d.seq].s_dob,
   acc# = m_rec->details[d.seq].s_acc, ordering_provider = substring(1,50,m_rec->details[d.seq].
    s_ord_provider)
   FROM (dummyt d  WITH seq = value(size(m_rec->details,5)))
   PLAN (d)
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (ms_rpt_type="totals")
  SELECT INTO "nl:"
   facility = uar_get_code_display(rg4.parent_service_resource_cd), section = uar_get_code_display(
    rg2.parent_service_resource_cd), service_resource = uar_get_code_display(sa.service_resource_cd),
   modality = trim(substring(1,3,cv.display),3)
   FROM sch_appt sa,
    sch_event se,
    code_value cv,
    resource_group rg1,
    resource_group rg2,
    resource_group rg3,
    resource_group rg4
   PLAN (sa
    WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
     AND parser(ms_res_parse)
     AND sa.sch_state_cd IN (mf_noshow_cd, mf_arrived_cd)
     AND sa.role_meaning="EXAMROOM"
     AND sa.active_ind=1)
    JOIN (se
    WHERE se.sch_event_id=sa.sch_event_id
     AND se.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=se.appt_type_cd
     AND parser(ms_mod_parse)
     AND trim(substring(1,3,cv.display),3) IN ("CT", "MM", "MRI", "NM", "US",
    "XR"))
    JOIN (rg1
    WHERE rg1.child_service_resource_cd=sa.service_resource_cd)
    JOIN (rg2
    WHERE rg2.child_service_resource_cd=rg1.parent_service_resource_cd)
    JOIN (rg3
    WHERE rg3.child_service_resource_cd=rg2.parent_service_resource_cd)
    JOIN (rg4
    WHERE rg4.child_service_resource_cd=rg3.parent_service_resource_cd)
   ORDER BY facility, section, modality,
    service_resource, sa.beg_dt_tm
   HEAD REPORT
    ml_cnt = 0, ml_fac_cnt = 0, ml_sec_cnt = 0
   HEAD rg4.parent_service_resource_cd
    ml_fac_cnt = (size(m_rec->totals,5)+ 1),
    CALL alterlist(m_rec->totals,ml_fac_cnt), m_rec->totals[ml_fac_cnt].s_facility = trim(facility,3)
   HEAD rg2.parent_service_resource_cd
    ml_sec_cnt = (size(m_rec->totals[ml_fac_cnt].section,5)+ 1),
    CALL alterlist(m_rec->totals[ml_fac_cnt].section,ml_sec_cnt), m_rec->totals[ml_fac_cnt].section[
    ml_sec_cnt].s_section = build2("  ",trim(section,3))
   HEAD sa.sch_appt_id
    m_rec->totals[ml_fac_cnt].f_tot_cnt += 1, m_rec->totals[ml_fac_cnt].section[ml_sec_cnt].f_tot_cnt
     += 1
    IF (sa.sch_state_cd=mf_noshow_cd)
     m_rec->totals[ml_fac_cnt].f_nos_cnt += 1, m_rec->totals[ml_fac_cnt].section[ml_sec_cnt].
     f_nos_cnt += 1
    ENDIF
   WITH nocounter
  ;end select
  SET ml_cnt = 1
  CALL alterlist(m_rec->rollup,(ml_cnt+ 99))
  SET m_rec->rollup[ml_cnt].s_loc = build2("Date Range: ",format(cnvtdatetime(ms_beg_dt_tm),
    "mm/dd/yyyy;;d")," - ",format(cnvtdatetime(ms_end_dt_tm),"mm/dd/yyyy;;d"))
  SET m_rec->rollup[ml_cnt].s_tot_cnt = "-"
  SET m_rec->rollup[ml_cnt].s_nos_cnt = "-"
  SET m_rec->rollup[ml_cnt].s_nos_pct = "-"
  FOR (ml_loop_i = 1 TO size(m_rec->totals,5))
    SET ml_cnt += 1
    IF (ml_cnt > size(m_rec->rollup,5))
     CALL alterlist(m_rec->rollup,(ml_cnt+ 99))
    ENDIF
    SET m_rec->rollup[ml_cnt].s_loc = m_rec->totals[ml_loop_i].s_facility
    SET m_rec->rollup[ml_cnt].s_tot_cnt = cnvtstring(m_rec->totals[ml_loop_i].f_tot_cnt)
    SET m_rec->rollup[ml_cnt].s_nos_cnt = cnvtstring(m_rec->totals[ml_loop_i].f_nos_cnt)
    SET m_rec->rollup[ml_cnt].s_nos_pct = trim(format(((m_rec->totals[ml_loop_i].f_nos_cnt/ m_rec->
      totals[ml_loop_i].f_tot_cnt) * 100),"###.##%;R"),3)
    FOR (ml_loop_j = 1 TO size(m_rec->totals[ml_loop_i].section,5))
      SET ml_cnt += 1
      IF (ml_cnt > size(m_rec->rollup,5))
       CALL alterlist(m_rec->rollup,(ml_cnt+ 99))
      ENDIF
      SET m_rec->rollup[ml_cnt].s_loc = m_rec->totals[ml_loop_i].section[ml_loop_j].s_section
      SET m_rec->rollup[ml_cnt].s_tot_cnt = cnvtstring(m_rec->totals[ml_loop_i].section[ml_loop_j].
       f_tot_cnt)
      SET m_rec->rollup[ml_cnt].s_nos_cnt = cnvtstring(m_rec->totals[ml_loop_i].section[ml_loop_j].
       f_nos_cnt)
      SET m_rec->rollup[ml_cnt].s_nos_pct = trim(format(((m_rec->totals[ml_loop_i].section[ml_loop_j]
        .f_nos_cnt/ m_rec->totals[ml_loop_i].section[ml_loop_j].f_tot_cnt) * 100),"###.##%;R"),3)
    ENDFOR
  ENDFOR
  CALL alterlist(m_rec->rollup,ml_cnt)
  SELECT INTO value( $OUTDEV)
   location = substring(1,50,m_rec->rollup[d.seq].s_loc), total_appt_cnt = m_rec->rollup[d.seq].
   s_tot_cnt, noshow_cnt = m_rec->rollup[d.seq].s_nos_cnt,
   noshow_pct = m_rec->rollup[d.seq].s_nos_pct
   FROM (dummyt d  WITH seq = value(size(m_rec->rollup,5)))
   PLAN (d)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 IF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
