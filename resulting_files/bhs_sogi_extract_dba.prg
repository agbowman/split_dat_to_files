CREATE PROGRAM bhs_sogi_extract:dba
 PROMPT
  "Output to File/Printer/MINE: " = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Facility:" = 0
  WITH outdev, startdate, enddate,
  facility
 DECLARE mc_start_date = vc WITH protect, constant(format(cnvtdatetime( $STARTDATE),
   "DD-MMM-YYYY 00:00:00;;q"))
 DECLARE mc_end_date = vc WITH protect, constant(format(cnvtdatetime( $ENDDATE),
   "DD-MMM-YYYY 23:59:59;;q"))
 DECLARE mf_facility = f8 WITH protect, constant( $FACILITY)
 DECLARE mf_inpatient = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_observation = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE mf_outpatient = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE mf_daystay = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_emergency = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_race_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_ndx = i4 WITH protect, noconstant(0)
 DECLARE ml_ndx2 = i4 WITH protect, noconstant(0)
 DECLARE mc_data_description = vc WITH protect, noconstant("")
 DECLARE mc_data_element = vc WITH protect, noconstant("")
 DECLARE mc_race = vc WITH protect, noconstant("")
 DECLARE ml_inp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_out_day_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_emer_cnt = i4 WITH protect, noconstant(0)
 DECLARE mc_lang = vc WITH protect, noconstant("")
 FREE RECORD data
 RECORD data(
   1 list[*]
     2 facility_name = vc
     2 data_element = vc
     2 data_description = vc
     2 race = vc
     2 ethnicity = vc
     2 language = vc
     2 numerator = f8
     2 denominator = f8
     2 percentage = f8
 )
 SELECT INTO "nl:"
  FROM encounter e,
   person_info pi
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd=mf_facility
    AND e.encntr_type_cd IN (mf_inpatient, mf_observation, mf_outpatient, mf_daystay, mf_emergency))
   JOIN (pi
   WHERE pi.person_id=e.person_id
    AND pi.info_sub_type_cd=mf_race_cd)
  ORDER BY e.encntr_type_cd
  HEAD REPORT
   ml_for_cnt = 0, ml_inp_cnt = 0, ml_out_day_cnt = 0,
   ml_emer_cnt = 0
  DETAIL
   mc_race = uar_get_code_display(pi.value_cd)
   CASE (e.encntr_type_cd)
    OF mf_inpatient:
    OF mf_observation:
     mc_data_description = concat(trim(uar_get_code_display(mf_facility),3)," Inpatients by Race"),
     ml_inp_cnt += 1
    OF mf_outpatient:
    OF mf_daystay:
     mc_data_description = concat(trim(uar_get_code_display(mf_facility),3),
      " Ambulatory Patients by Race"),ml_out_day_cnt += 1
    OF mf_emergency:
     mc_data_description = concat(trim(uar_get_code_display(mf_facility),3),
      " Emergency Department Patients by Race"),ml_emer_cnt += 1
   ENDCASE
   ml_pos = locateval(ml_ndx,1,ml_cnt,mc_data_description,data->list[ml_ndx].data_description,
    mc_race,data->list[ml_ndx].race)
   IF (ml_pos=0
    AND mc_race != "Unknown")
    ml_cnt += 1, stat = alterlist(data->list,ml_cnt), data->list[ml_cnt].facility_name =
    uar_get_code_display(mf_facility),
    data->list[ml_cnt].data_element = uar_get_code_display(mf_race_cd), data->list[ml_cnt].
    data_description = mc_data_description, data->list[ml_cnt].race = mc_race,
    ml_pos = ml_cnt
   ENDIF
   IF (textlen(mc_race) > 0
    AND mc_race != "Unknown")
    data->list[ml_pos].numerator += 1
   ENDIF
   mc_data_description = concat(trim(uar_get_code_display(mf_facility),3)," Patients by Race"),
   ml_pos = locateval(ml_ndx,1,ml_cnt,mc_data_description,data->list[ml_ndx].data_description,
    mc_race,data->list[ml_ndx].race)
   IF (ml_pos=0
    AND mc_race != "Unknown")
    ml_cnt += 1, stat = alterlist(data->list,ml_cnt), data->list[ml_cnt].facility_name =
    uar_get_code_display(mf_facility),
    data->list[ml_cnt].data_element = uar_get_code_display(mf_race_cd), data->list[ml_cnt].
    data_description = mc_data_description, data->list[ml_cnt].race = mc_race,
    ml_pos = ml_cnt
   ENDIF
   IF (textlen(mc_race) > 0
    AND mc_race != "Unknown")
    data->list[ml_pos].numerator += 1
   ENDIF
  FOOT REPORT
   FOR (ml_for_cnt = 1 TO ml_cnt)
    CASE (data->list[ml_for_cnt].data_description)
     OF concat(trim(uar_get_code_display(mf_facility),3)," Inpatients by Race"):
      data->list[ml_for_cnt].denominator = ml_inp_cnt
     OF concat(trim(uar_get_code_display(mf_facility),3)," Ambulatory Patients by Race"):
      data->list[ml_for_cnt].denominator = ml_out_day_cnt
     OF concat(trim(uar_get_code_display(mf_facility),3)," Emergency Department Patients by Race"):
      data->list[ml_for_cnt].denominator = ml_emer_cnt
     OF concat(trim(uar_get_code_display(mf_facility),3)," Patients by Race"):
      data->list[ml_for_cnt].denominator = ((ml_inp_cnt+ ml_out_day_cnt)+ ml_emer_cnt)
    ENDCASE
    ,data->list[ml_for_cnt].percentage = (data->list[ml_for_cnt].numerator/ data->list[ml_for_cnt].
    denominator)
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd=mf_facility
    AND e.encntr_type_cd IN (mf_inpatient, mf_observation, mf_outpatient, mf_daystay, mf_emergency))
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   ml_for_cnt = 0, ml_inp_cnt = 0, ml_out_day_cnt = 0,
   ml_emer_cnt = 0
  DETAIL
   mc_lang = uar_get_code_display(p.language_cd)
   CASE (e.encntr_type_cd)
    OF mf_inpatient:
    OF mf_observation:
     mc_data_description = concat(trim(uar_get_code_display(mf_facility),3)," Inpatients by Language"
      ),ml_inp_cnt += 1
    OF mf_outpatient:
    OF mf_daystay:
     mc_data_description = concat(trim(uar_get_code_display(mf_facility),3),
      " Ambulatory Patients by Language"),ml_out_day_cnt += 1
    OF mf_emergency:
     mc_data_description = concat(trim(uar_get_code_display(mf_facility),3),
      " Emergency Department Patients by Language"),ml_emer_cnt += 1
   ENDCASE
   ml_pos = locateval(ml_ndx,1,ml_cnt,mc_data_description,data->list[ml_ndx].data_description,
    mc_lang,data->list[ml_ndx].language)
   IF (ml_pos=0
    AND mc_lang != "Unknown")
    ml_cnt += 1, stat = alterlist(data->list,ml_cnt), data->list[ml_cnt].facility_name =
    uar_get_code_display(mf_facility),
    data->list[ml_cnt].data_element = "Language Spoken", data->list[ml_cnt].data_description =
    mc_data_description, data->list[ml_cnt].language = mc_lang,
    ml_pos = ml_cnt
   ENDIF
   IF (textlen(mc_lang) > 0
    AND mc_lang != "Unknown")
    data->list[ml_pos].numerator += 1
   ENDIF
   mc_data_description = concat(trim(uar_get_code_display(mf_facility),3)," Patients by Language"),
   ml_pos = locateval(ml_ndx,1,ml_cnt,mc_data_description,data->list[ml_ndx].data_description,
    mc_lang,data->list[ml_ndx].language)
   IF (ml_pos=0
    AND mc_lang != "Unknown")
    ml_cnt += 1, stat = alterlist(data->list,ml_cnt), data->list[ml_cnt].facility_name =
    uar_get_code_display(mf_facility),
    data->list[ml_cnt].data_element = "Language Spoken", data->list[ml_cnt].data_description =
    mc_data_description, data->list[ml_cnt].language = mc_lang,
    ml_pos = ml_cnt
   ENDIF
   IF (textlen(mc_lang) > 0
    AND mc_lang != "Unknown")
    data->list[ml_pos].numerator += 1
   ENDIF
  FOOT REPORT
   FOR (ml_for_cnt = 1 TO ml_cnt)
    CASE (data->list[ml_for_cnt].data_description)
     OF concat(trim(uar_get_code_display(mf_facility),3)," Inpatients by Language"):
      data->list[ml_for_cnt].denominator = ml_inp_cnt
     OF concat(trim(uar_get_code_display(mf_facility),3)," Ambulatory Patients by Language"):
      data->list[ml_for_cnt].denominator = ml_out_day_cnt
     OF concat(trim(uar_get_code_display(mf_facility),3)," Emergency Department Patients by Language"
     ):
      data->list[ml_for_cnt].denominator = ml_emer_cnt
     OF concat(trim(uar_get_code_display(mf_facility),3)," Patients by Language"):
      data->list[ml_for_cnt].denominator = ((ml_inp_cnt+ ml_out_day_cnt)+ ml_emer_cnt)
    ENDCASE
    ,data->list[ml_for_cnt].percentage = (data->list[ml_for_cnt].numerator/ data->list[ml_for_cnt].
    denominator)
   ENDFOR
  WITH nocounter
 ;end select
 GO TO exit_program
 SELECT
  fac = uar_get_code_display(e.loc_facility_cd), eth = uar_get_code_display(p.ethnic_grp_cd), count(*
   )
  FROM encounter e,
   health_plan hp,
   encntr_plan_reltn epr,
   person p
  PLAN (e
   WHERE e.service_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id)
  GROUP BY e.loc_facility_cd, p.ethnic_grp_cd
 ;end select
 SELECT INTO "jm6512_disability.dat"
  fac = uar_get_code_display(e.loc_facility_cd), question = uar_get_code_display(ce.event_cd), answer
   = ce.event_tag,
  count(*)
  FROM encounter e,
   health_plan hp,
   encntr_plan_reltn epr,
   clinical_event ce
  PLAN (e
   WHERE e.service_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.event_cd IN (2152008669.00, 2152008701.0, 2152008735.00, 2152008771.0, 2152008807.00,
   2152008841.00))
  GROUP BY e.loc_facility_cd, ce.event_cd, ce.event_tag
 ;end select
 SELECT INTO "jm6512_sogi.dat"
  fac = uar_get_code_display(e.loc_facility_cd), sr.task_assay_cd, sogi = n.source_string,
  count(*)
  FROM encounter e,
   health_plan hp,
   encntr_plan_reltn epr,
   shx_activity s,
   shx_response sr,
   shx_alpha_response sar,
   nomenclature n
  PLAN (e
   WHERE e.service_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
   JOIN (s
   WHERE s.person_id=e.person_id)
   JOIN (sr
   WHERE sr.shx_activity_id=s.shx_activity_id
    AND sr.task_assay_cd=563829548.0)
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND (n.nomenclature_id> Outerjoin(0)) )
  GROUP BY e.loc_facility_cd, sr.task_assay_cd, n.source_string
 ;end select
 SELECT INTO "jm6512_gend_ident.dat"
  fac = uar_get_code_display(e.loc_facility_cd), sr.task_assay_cd, gi = n.source_string,
  count(*)
  FROM encounter e,
   health_plan hp,
   encntr_plan_reltn epr,
   shx_activity s,
   shx_response sr,
   shx_alpha_response sar,
   nomenclature n
  PLAN (e
   WHERE e.service_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
   JOIN (s
   WHERE s.person_id=e.person_id)
   JOIN (sr
   WHERE sr.shx_activity_id=s.shx_activity_id
    AND sr.task_assay_cd=567878076.0)
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND (n.nomenclature_id> Outerjoin(0)) )
  GROUP BY e.loc_facility_cd, sr.task_assay_cd, n.source_string
 ;end select
 SELECT INTO "jm6512_lang.dat"
  fac = uar_get_code_display(e.loc_facility_cd), lang = uar_get_code_display(p.language_cd), count(*)
  FROM encounter e,
   health_plan hp,
   encntr_plan_reltn epr,
   person p
  PLAN (e
   WHERE e.service_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id)
  GROUP BY e.loc_facility_cd, p.language_cd
 ;end select
 SELECT INTO "jm6512_town.dat"
  fac = uar_get_code_display(e.loc_facility_cd), a.city, count(*)
  FROM encounter e,
   health_plan hp,
   encntr_plan_reltn epr,
   address a
  PLAN (e
   WHERE e.service_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
   JOIN (a
   WHERE a.address_type_cd=756.0
    AND a.parent_entity_name="PERSON"
    AND a.parent_entity_id=e.person_id
    AND a.inst_id=1)
  GROUP BY e.loc_facility_cd, a.city
 ;end select
 SELECT INTO "jm6512_zip.dat"
  fac = uar_get_code_display(e.loc_facility_cd), a.zipcode, count(*)
  FROM encounter e,
   health_plan hp,
   encntr_plan_reltn epr,
   address a
  PLAN (e
   WHERE e.service_dt_tm BETWEEN cnvtdatetime(mc_start_date) AND cnvtdatetime(mc_end_date)
    AND e.loc_facility_cd IN (673936.0, 673937.0, 580062482.0, 780848199.0))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.health_plan_id IN (27186718.00, 15141532.00, 17118922.00, 7882693.00, 590083.00,
   15141655.00, 8398675.00, 8398676.00, 22614614.00, 589911.00,
   3631269.00, 3250881.00, 2563063.00, 3211055.00, 3173529.00,
   589895.00, 9496805.00, 9897593.00, 8477482.00, 8477483.00,
   7882695.0, 18683748.0, 15141672.0, 15141713.0, 56132421.0,
   6700174.0, 19489491.0, 15141443.0)
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
   JOIN (a
   WHERE a.address_type_cd=756.0
    AND a.parent_entity_name="PERSON"
    AND a.parent_entity_id=e.person_id
    AND a.inst_id=1)
  GROUP BY e.loc_facility_cd, a.zipcode
 ;end select
#exit_program
 CALL echorecord(data)
 FREE RECORD data
END GO
