CREATE PROGRAM bhs_rpt_act_wnd_incis_abnorm:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 0,
  "Unit" = value(0.0)
  WITH outdev, fname, f_unit
 FREE RECORD wound
 RECORD wound(
   1 l_patcnt = i4
   1 encntr[*]
     2 f_encntrid = f8
     2 f_personid = f8
     2 f_woundcareorder_id = f8
     2 s_facility_location = vc
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_nurse_unit = vc
     2 s_admit_dt_tm = vc
     2 s_skin_integrity = vc
     2 s_skin_assessment_2nd_person = vc
     2 s_skin_abnormality_type = vc
     2 s_wound_photo_uploaded = vc
     2 s_2nd_personintegumentary_assessment = vc
     2 s_pressure_wound_date_identified = vc
     2 s_pressure_injury_staging = vc
     2 s_braden_score_adult = vc
     2 s_braden_q_score_pedi = vc
     2 s_braden_q_score_newborn = vc
     2 s_braden_score_date = vc
     2 s_mattress_device = vc
     2 s_therapeutic_bed_order = vc
     2 s_therapeutic_bed_order_date = vc
     2 s_nursing_care_plan_initiated_updated = vc
     2 s_prevention_interventions_skin = vc
     2 s_maintenance_interventions_skin = vc
     2 s_pressure_interventions_skin = vc
     2 s_wound_interventions_skin = vc
     2 s_diaper_dermatitis_interventions = vc
     2 s_adhesive_interventions = vc
     2 s_skin_breakdown_prevention_intervention = vc
     2 s_wound_care_rn_consult_order_date = vc
     2 s_wound_care_orders_info = vc
     2 s_wound_care_orders_dates = vc
     2 s_wound_care_order_date1 = vc
     2 s_wound_care_order_info1 = vc
     2 s_wound_care_order_date2 = vc
     2 s_wound_care_order_info2 = vc
     2 s_wound_care_order_date3 = vc
     2 s_wound_care_order_info3 = vc
     2 s_wound_care_order_date4 = vc
     2 s_wound_care_order_info4 = vc
     2 s_wound_care_order_date5 = vc
     2 s_wound_care_order_info5 = vc
     2 s_wound_care_order_date6 = vc
     2 s_wound_care_order_info6 = vc
     2 s_wound_care_order_date7 = vc
     2 s_wound_care_order_info7 = vc
     2 s_wound_care_order_date8 = vc
     2 s_wound_care_order_info8 = vc
     2 s_wound_care_order_date9 = vc
     2 s_wound_care_order_info9 = vc
     2 s_wound_care_order_date10 = vc
     2 s_wound_care_order_info10 = vc
     2 s_wound_vac_order_date = vc
     2 s_baseline_functional_status = vc
     2 s_activity_assistance = vc
     2 s_turn_and_reposition = vc
     2 s_turn_and_repositioning = vc
     2 s_changing_of_o2sat_probes_q_4_hours = vc
     2 s_race_1 = vc
     2 s_ethnicity_1 = vc
     2 s_surgical_wound_interventions = vc
     2 s_wound_present_on_admission = vc
     2 s_pressure_injury_stage = vc
     2 s_pressure_injury_present_on_admission = vc
     2 s_nut_service_consult = vc
     2 s_nut_service_date = vc
 ) WITH protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs8_inprogress = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"INPROGRESS")), protect
 DECLARE mf_cs355_user_def_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,
   "USERDEFINED"))
 DECLARE mf_106_communicationorders = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "COMMUNICATIONORDERS")), protect
 DECLARE mf_cs200_woundcare = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"WOUNDCARE")),
 protect
 DECLARE mf_cs200_woundcarernconsult = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "WOUNDCARERNCONSULT")), protect
 DECLARE mf_cs200_woundvac = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"WOUNDVAC")), protect
 DECLARE mf_cs6004_deleted = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED")), protect
 DECLARE mf_cs72_pressureinjurystage = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PRESSUREINJURYSTAGE")), protect
 DECLARE mf_cs72_woundpresentonadmission = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "WOUNDPRESENTONADMISSION")), protect
 DECLARE s_tran_result = vc WITH protect
 DECLARE mf_cs72_surgicalwoundinterventions = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SURGICALWOUNDINTERVENTIONS")), protect
 DECLARE mf_cs72_oxyprobesitechangeq4hrs = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYPROBESITECHANGEQ4HRS")), protect
 DECLARE mf_cs72_pressureinjurywounddateidentified = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PRESSUREINJURYWOUNDDATEIDENTIFIED")), protect
 DECLARE mf_cs200_therapeuticbedlowbed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDLOWBED")), protect
 DECLARE mf_cs72_turnandreposition = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TURNANDREPOSITION")), protect
 DECLARE mf_cs72_activityassistance = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,
   "Activity Assistance")), protect
 DECLARE mf_cs72_baselinefunctionalstatus = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BASELINEFUNCTIONALSTATUS")), protect
 DECLARE mf_cs72_skinbreakdownpreventioninterventions = f8 WITH constant(uar_get_code_by("DISPLAYKEY",
   72,"SKINBREAKDOWNPREVENTIONINTERVENTIONS")), protect
 DECLARE mf_cs72_adhesiveinterventions = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ADHESIVEINTERVENTIONS")), protect
 DECLARE mf_cs72_diaperdermatitisinterventions = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIAPERDERMATITISINTERVENTIONS")), protect
 DECLARE mf_cs72_woundinterventions = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "WOUNDINTERVENTIONS")), protect
 DECLARE mf_cs72_pressureinterventionsskin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PRESSUREINTERVENTIONSSKIN")), protect
 DECLARE mf_cs72_maintenanceinterventionsskin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAINTENANCEINTERVENTIONSSKIN")), protect
 DECLARE mf_cs72_preventioninterventionsskin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PREVENTIONINTERVENTIONSSKIN")), protect
 DECLARE mf_cs72_nursingcareplaninitiatedupdated = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSINGCAREPLANINITIATEDUPDATED")), protect
 DECLARE mf_cs72_mattressdevicechg = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MATTRESSDEVICECHG")), protect
 DECLARE mf_cs72_bradenqassessmentnewborn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BRADENQASSESSMENTNEWBORN")), protect
 DECLARE mf_cs72_bradenqassessmentpediatric = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BRADENQASSESSMENTPEDIATRIC")), protect
 DECLARE mf_cs72_bradenscore = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BRADENSCORE")),
 protect
 DECLARE mf_cs72_2ndpersonintegumentaryassessment = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "2NDPERSONINTEGUMENTARYASSESSMENT")), protect
 DECLARE mf_cs72_woundphotouploaded = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "WOUNDPHOTOUPLOADED")), protect
 DECLARE mf_cs72_skinabnormalitytype = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SKINABNORMALITYTYPE")), protect
 DECLARE mf_cs72_skinintegrity = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SKININTEGRITY")),
 protect
 DECLARE mf_cs72_skinassessment2ndperson = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SKINASSESSMENT2NDPERSON")), protect
 DECLARE mf_cs200_consultnutritionservices = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTNUTRITIONSERVICES")), protect
 DECLARE mf_cs72_pressureinjurypresentonadmission = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PRESSUREINJURYPRESENTONADMISSION")), protect
 DECLARE mf_cd72_woundpresentonadmission = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "WOUNDPRESENTONADMISSION")), protect
 DECLARE mf_cs339_census = f8 WITH constant(uar_get_code_by("DISPLAYKEY",339,"CENSUS")), protect
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs_71_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs71_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE ml_wnd_cnt = i4 WITH noconstant(0), protect
 DECLARE ml_det_cnt = i4 WITH noconstant(0), protect
 DECLARE i_first = i4 WITH noconstant(0), protect
 DECLARE location = vc WITH protect, noconstant("              ")
 DECLARE patient_name = vc WITH protect, noconstant("              ")
 DECLARE skin_integrity = vc WITH protect, noconstant("              ")
 DECLARE skin_assessment_2nd_person = vc WITH protect, noconstant("              ")
 DECLARE skin_abnormality_type = vc WITH protect, noconstant("              ")
 DECLARE wound_photo_uploaded = vc WITH protect, noconstant("              ")
 DECLARE 2nd_personintegumentary_assessment = vc WITH protect, noconstant("              ")
 DECLARE pressure_wound_date_identified = vc WITH protect, noconstant("              ")
 DECLARE pressure_injury_staging = vc WITH protect, noconstant("              ")
 DECLARE braden_score_adult = vc WITH protect, noconstant("              ")
 DECLARE braden_q_score_pedi = vc WITH protect, noconstant("              ")
 DECLARE braden_q_score_newborn = vc WITH protect, noconstant("              ")
 DECLARE braden_score_date = vc WITH protect, noconstant("              ")
 DECLARE mattress_device = vc WITH protect, noconstant("              ")
 DECLARE therapeutic_bed_order = vc WITH protect, noconstant("              ")
 DECLARE therapeutic_bed_order_date = vc WITH protect, noconstant("              ")
 DECLARE nursing_care_plan_initiated_updated = vc WITH protect, noconstant("              ")
 DECLARE prevention_interventions_skin = vc WITH protect, noconstant("              ")
 DECLARE maintenance_interventions_skin = vc WITH protect, noconstant("              ")
 DECLARE pressure_interventions_skin = vc WITH protect, noconstant("              ")
 DECLARE wound_interventions_skin = vc WITH protect, noconstant("              ")
 DECLARE diaper_dermatitis_interventions = vc WITH protect, noconstant("              ")
 DECLARE adhesive_interventions = vc WITH protect, noconstant("              ")
 DECLARE skin_breakdown_prevention_intervention = vc WITH protect, noconstant("              ")
 DECLARE wound_care_rn_consult_order_date = vc WITH protect, noconstant("              ")
 DECLARE wound_care_order = vc WITH protect, noconstant("              ")
 DECLARE wound_vac_order = vc WITH protect, noconstant("              ")
 DECLARE baseline_functional_status = vc WITH protect, noconstant("              ")
 DECLARE activity_assistance = vc WITH protect, noconstant("              ")
 DECLARE turn_and_reposition = vc WITH protect, noconstant("              ")
 DECLARE turn_and_repositioning = vc WITH protect, noconstant("              ")
 DECLARE changing_of_o2sat_probes_q_4_hours = vc WITH protect, noconstant("              ")
 DECLARE race_1 = vc WITH protect, noconstant("              ")
 DECLARE ethnicity_1 = vc WITH protect, noconstant("              ")
 DECLARE mrn = vc WITH protect, noconstant("              ")
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml_cnt2 = i4 WITH noconstant(0), protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE opr_var = vc WITH protect
 DECLARE lcheck = vc WITH protect
 DECLARE gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_facility_name = vc WITH protect, noconstant(" ")
 DECLARE ms_nursingunit_name = vc WITH protect, noconstant(" ")
 DECLARE line1 = vc WITH protect, noconstant(" ")
 DECLARE nurseunit = vc WITH protect, noconstant(" ")
 DECLARE patientname = vc WITH protect, noconstant(" ")
 DECLARE finnumber = vc WITH protect, noconstant(" ")
 DECLARE ms_fac = vc WITH protect, noconstant(" ")
 DECLARE ml_tmp_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_bmc = f8 WITH protect, noconstant(0)
 DECLARE mf_bfmc = f8 WITH protect, noconstant(0)
 DECLARE nurseunitcd = f8 WITH protect, noconstant(0)
 DECLARE md_begin = f8 WITH protect, noconstant(0)
 DECLARE md_end = f8 WITH protect, noconstant(0)
 DECLARE unit_cnt = i4 WITH noconstant(0)
 DECLARE patient_cnt = i4 WITH noconstant(0)
 DECLARE ms_tmp = vc WITH protect
 DECLARE ml_attloc = i4 WITH protect
 DECLARE ml_num = i4 WITH noconstant(0)
 DECLARE ml_loc = i4 WITH protect
 DECLARE ml_numres = i4 WITH protect
 SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
 RECORD grec1(
   1 list[*]
     2 cv = f8
     2 disp = c15
 )
 IF (lcheck="L")
  SET opr_var = "IN"
  WHILE (lcheck > " ")
    SET gcnt += 1
    SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),gcnt)))
    CALL echo(lcheck)
    IF (lcheck > " ")
     IF (mod(gcnt,5)=1)
      SET stat = alterlist(grec1->list,(gcnt+ 4))
     ENDIF
     SET grec1->list[gcnt].cv = cnvtint(parameter(parameter2( $F_UNIT),gcnt))
     SET grec1->list[gcnt].disp = uar_get_code_display(parameter(parameter2( $F_UNIT),gcnt))
    ENDIF
  ENDWHILE
  SET gcnt -= 1
  SET stat = alterlist(grec1->list,gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET gcnt = 1
  SET grec1->list[1].cv =  $F_UNIT
  IF ((grec1->list[1].cv=0.0))
   SET grec1->list[1].disp = "All Units"
   SET opr_var = "!="
  ELSE
   SET grec1->list[1].disp = uar_get_code_display(grec1->list[1].cv)
   SET opr_var = "="
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_alias fin,
   person p,
   encounter e,
   clinical_event ce,
   ce_date_result cdr,
   person_info pi,
   bhs_demographics bd,
   code_value unit,
   code_value fac,
   encntr_domain ed
  PLAN (ed
   WHERE ed.encntr_domain_type_cd=mf_cs339_census
    AND ed.active_ind=1
    AND (ed.loc_facility_cd= $FNAME)
    AND operator(ed.loc_nurse_unit_cd,opr_var, $F_UNIT))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1
    AND e.disch_dt_tm=null
    AND e.active_status_cd=mf_cs48_active
    AND e.encntr_type_cd IN (mf_cs71_inpatient, mf_cs71_observation, mf_cs71_daystay,
   mf_cs_71_emergency))
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active)
    AND ce.event_cd IN (mf_cs72_skinassessment2ndperson, mf_cs72_skinintegrity,
   mf_cs72_skinabnormalitytype, mf_cs72_woundphotouploaded, mf_cs72_2ndpersonintegumentaryassessment,
   mf_cs72_bradenscore, mf_cs72_bradenqassessmentpediatric, mf_cs72_bradenqassessmentnewborn,
   mf_cs72_mattressdevicechg, mf_cs72_nursingcareplaninitiatedupdated,
   mf_cs72_preventioninterventionsskin, mf_cs72_maintenanceinterventionsskin,
   mf_cs72_preventioninterventionsskin, mf_cs72_woundinterventions, mf_cs72_pressureinterventionsskin,
   mf_cs72_diaperdermatitisinterventions, mf_cs72_adhesiveinterventions,
   mf_cs72_skinbreakdownpreventioninterventions, mf_cs72_baselinefunctionalstatus,
   mf_cs72_activityassistance,
   mf_cs72_turnandreposition, mf_cs72_oxyprobesitechangeq4hrs,
   mf_cs72_pressureinjurywounddateidentified, mf_cs72_surgicalwoundinterventions,
   mf_cs72_woundpresentonadmission,
   mf_cs72_pressureinjurypresentonadmission, mf_cs72_pressureinjurystage))
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_ind=1
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm)
   JOIN (fac
   WHERE fac.active_ind=1
    AND fac.code_set=220
    AND fac.code_value=e.loc_facility_cd)
   JOIN (unit
   WHERE unit.active_ind=1
    AND unit.code_set=220
    AND unit.code_value=e.loc_nurse_unit_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce.event_id)) )
   JOIN (pi
   WHERE (pi.person_id= Outerjoin(e.person_id))
    AND (pi.active_ind= Outerjoin(1))
    AND (pi.end_effective_dt_tm> Outerjoin(sysdate))
    AND (pi.info_type_cd= Outerjoin(mf_cs355_user_def_cd))
    AND (pi.info_sub_type_cd= Outerjoin(mf_cs356_race1)) )
   JOIN (bd
   WHERE (bd.person_id= Outerjoin(e.person_id))
    AND (bd.active_ind= Outerjoin(1))
    AND (bd.end_effective_dt_tm> Outerjoin(sysdate))
    AND (trim(bd.description,3)= Outerjoin("ethnicity 1")) )
  ORDER BY fac.display, unit.display, p.name_full_formatted,
   p.person_id, e.encntr_id, ce.event_cd,
   ce.event_end_dt_tm DESC
  HEAD REPORT
   stat = alterlist(wound->encntr,10)
  HEAD e.encntr_id
   wound->l_patcnt += 1
   IF (mod(wound->l_patcnt,10)=1
    AND (wound->l_patcnt > 1))
    stat = alterlist(wound->encntr,(wound->l_patcnt+ 9))
   ENDIF
   wound->encntr[wound->l_patcnt].f_encntrid = e.encntr_id, wound->encntr[wound->l_patcnt].f_personid
    = p.person_id, wound->encntr[wound->l_patcnt].s_patient_name = trim(p.name_full_formatted,3),
   wound->encntr[wound->l_patcnt].s_fin = trim(fin.alias,3), wound->encntr[wound->l_patcnt].
   s_admit_dt_tm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;Q"), wound->encntr[wound->l_patcnt].
   s_facility_location = concat(trim(uar_get_code_display(e.loc_facility_cd),3),"/",trim(
     uar_get_code_display(e.loc_nurse_unit_cd),3)),
   wound->encntr[wound->l_patcnt].s_ethnicity_1 = trim(uar_get_code_display(bd.code_value),3), wound
   ->encntr[wound->l_patcnt].s_race_1 = trim(uar_get_code_display(pi.value_cd),3)
  HEAD ce.event_cd
   IF (cdr.event_id > 0)
    s_tran_result = format(cnvtdatetime(cdr.result_dt_tm),"mm/dd/yyyy hh:mm;;Q")
   ELSE
    s_tran_result = build2(trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd)))
   ENDIF
   IF (ce.event_cd IN (mf_cs72_activityassistance))
    wound->encntr[wound->l_patcnt].s_activity_assistance = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_adhesiveinterventions))
    wound->encntr[wound->l_patcnt].s_adhesive_interventions = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_baselinefunctionalstatus))
    wound->encntr[wound->l_patcnt].s_baseline_functional_status = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_bradenqassessmentnewborn))
    wound->encntr[wound->l_patcnt].s_braden_q_score_newborn = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_bradenqassessmentpediatric))
    wound->encntr[wound->l_patcnt].s_braden_q_score_pedi = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_bradenscore))
    wound->encntr[wound->l_patcnt].s_braden_score_adult = s_tran_result, wound->encntr[wound->
    l_patcnt].s_braden_score_date = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;Q")
   ELSEIF (ce.event_cd IN (mf_cs72_oxyprobesitechangeq4hrs))
    wound->encntr[wound->l_patcnt].s_changing_of_o2sat_probes_q_4_hours = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_diaperdermatitisinterventions))
    wound->encntr[wound->l_patcnt].s_diaper_dermatitis_interventions = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_maintenanceinterventionsskin))
    wound->encntr[wound->l_patcnt].s_maintenance_interventions_skin = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_preventioninterventionsskin))
    wound->encntr[wound->l_patcnt].s_prevention_interventions_skin = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_pressureinterventionsskin))
    wound->encntr[wound->l_patcnt].s_pressure_interventions_skin = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_woundinterventions))
    wound->encntr[wound->l_patcnt].s_wound_interventions_skin = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_surgicalwoundinterventions))
    wound->encntr[wound->l_patcnt].s_surgical_wound_interventions = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_skinintegrity))
    wound->encntr[wound->l_patcnt].s_skin_integrity = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_skinabnormalitytype))
    wound->encntr[wound->l_patcnt].s_skin_abnormality_type = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_woundphotouploaded))
    wound->encntr[wound->l_patcnt].s_wound_photo_uploaded = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_skinassessment2ndperson))
    wound->encntr[wound->l_patcnt].s_skin_assessment_2nd_person = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_woundpresentonadmission))
    wound->encntr[wound->l_patcnt].s_wound_present_on_admission = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_pressureinjurywounddateidentified))
    wound->encntr[wound->l_patcnt].s_pressure_wound_date_identified = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_pressureinjurystage))
    wound->encntr[wound->l_patcnt].s_pressure_injury_stage = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_pressureinjurypresentonadmission))
    wound->encntr[wound->l_patcnt].s_pressure_injury_present_on_admission = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_nursingcareplaninitiatedupdated))
    wound->encntr[wound->l_patcnt].s_nursing_care_plan_initiated_updated = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_turnandreposition))
    wound->encntr[wound->l_patcnt].s_turn_and_reposition = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_mattressdevicechg))
    wound->encntr[wound->l_patcnt].s_mattress_device = s_tran_result
   ELSEIF (ce.event_cd IN (mf_cs72_skinbreakdownpreventioninterventions))
    wound->encntr[wound->l_patcnt].s_skin_breakdown_prevention_intervention = s_tran_result
   ENDIF
  FOOT REPORT
   stat = alterlist(wound->encntr,wound->l_patcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_num,1,size(wound->encntr,5),o.encntr_id,wound->encntr[ml_num].f_encntrid,
    o.person_id,wound->encntr[ml_num].f_personid)
    AND o.template_order_flag IN (0, 1)
    AND o.order_status_cd != mf_cs6004_deleted
    AND o.active_ind=1
    AND (((o.catalog_cd=
   (SELECT
    cv.code_value
    FROM code_value cv,
     order_catalog oc
    WHERE cv.display_key="THERAPEUTICBED*"
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm >= sysdate
     AND cv.code_set=200
     AND oc.catalog_cd=cv.code_value
     AND oc.activity_type_cd=mf_106_communicationorders
    WITH nocounter, time = 60))) OR (o.catalog_cd IN (mf_cs200_woundcarernconsult, mf_cs200_woundvac,
   mf_cs200_consultnutritionservices))) )
  ORDER BY o.encntr_id, 0
  HEAD o.encntr_id
   ml_loc = 0, ml_loc = locateval(ml_numres,1,size(wound->encntr,5),o.encntr_id,wound->encntr[
    ml_numres].f_encntrid)
   IF (o.catalog_cd=mf_cs200_woundvac)
    wound->encntr[ml_loc].s_wound_vac_order_date = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (o.catalog_cd=mf_cs200_woundcarernconsult)
    wound->encntr[ml_loc].s_wound_care_rn_consult_order_date = format(o.orig_order_dt_tm,
     "mm/dd/yyyy hh:mm;;q")
   ELSEIF (o.catalog_cd=mf_cs200_consultnutritionservices)
    wound->encntr[ml_loc].s_nut_service_date = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSE
    wound->encntr[ml_loc].s_therapeutic_bed_order = trim(o.ordered_as_mnemonic,3), wound->encntr[
    ml_loc].s_therapeutic_bed_order_date = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od,
   order_entry_fields oef,
   oe_format_fields of1
  PLAN (o
   WHERE expand(ml_num,1,size(wound->encntr,5),o.encntr_id,wound->encntr[ml_num].f_encntrid,
    o.person_id,wound->encntr[ml_num].f_personid)
    AND o.order_status_cd != mf_cs6004_deleted
    AND o.active_ind=1
    AND o.catalog_cd=mf_cs200_woundcare
    AND o.template_order_flag IN (0, 1))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="OTHER")
   JOIN (of1
   WHERE of1.oe_format_id=o.oe_format_id
    AND of1.oe_field_id=od.oe_field_id)
   JOIN (oef
   WHERE of1.oe_field_id=oef.oe_field_id
    AND of1.clin_line_label IN ("Wound Site:", "Irrigate with:", "Mechanical Debridement:",
   "Skin Care:", "Enzymatic Debridement:",
   "Dressing:", "Bed Setting:"))
  ORDER BY o.encntr_id, o.orig_order_dt_tm, o.order_id,
   od.detail_sequence
  HEAD o.encntr_id
   ml_wnd_cnt = 0, ml_det_cnt = 0, ml_loc = 0,
   ml_loc = locateval(ml_numres,1,size(wound->encntr,5),o.encntr_id,wound->encntr[ml_numres].
    f_encntrid)
  HEAD o.order_id
   ml_wnd_cnt += 1
   IF (ml_wnd_cnt=1)
    wound->encntr[ml_loc].s_wound_care_order_date1 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=2)
    wound->encntr[ml_loc].s_wound_care_order_date2 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=3)
    wound->encntr[ml_loc].s_wound_care_order_date3 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=4)
    wound->encntr[ml_loc].s_wound_care_order_date4 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=5)
    wound->encntr[ml_loc].s_wound_care_order_date5 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=6)
    wound->encntr[ml_loc].s_wound_care_order_date6 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=7)
    wound->encntr[ml_loc].s_wound_care_order_date7 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=8)
    wound->encntr[ml_loc].s_wound_care_order_date8 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=9)
    wound->encntr[ml_loc].s_wound_care_order_date9 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ELSEIF (ml_wnd_cnt=10)
    wound->encntr[ml_loc].s_wound_care_order_date10 = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q"
     )
   ENDIF
   IF (ml_wnd_cnt=1)
    wound->encntr[ml_loc].s_wound_care_orders_dates = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q"
     )
   ELSEIF (ml_wnd_cnt > 1)
    wound->encntr[ml_loc].s_wound_care_orders_dates = concat(wound->encntr[ml_loc].
     s_wound_care_orders_dates,";",format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q"))
   ENDIF
   ml_det_cnt = 0
  HEAD od.detail_sequence
   ml_det_cnt += 1
   IF (ml_wnd_cnt=1)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info1 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info1 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info1,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=2)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info2 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info2 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info2,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=3)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info3 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info3 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info3,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=4)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info4 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info4 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info4,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=5)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info5 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info5 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info5,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=6)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info6 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info6 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info6,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=7)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info7 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info7 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info7,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=8)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info8 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info8 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info8,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=9)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info9 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info9 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info9,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ELSEIF (ml_wnd_cnt=10)
    IF (ml_det_cnt=1)
     wound->encntr[ml_loc].s_wound_care_order_info10 = concat(trim(of1.clin_line_label,3),trim(od
       .oe_field_display_value,3))
    ELSEIF (ml_det_cnt > 1)
     wound->encntr[ml_loc].s_wound_care_order_info10 = concat(wound->encntr[ml_loc].
      s_wound_care_order_info10,";",trim(of1.clin_line_label,3),trim(od.oe_field_display_value,3))
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (size(wound->encntr,5) > 0)
  SELECT INTO  $OUTDEV
   facility_location = substring(1,30,wound->encntr[d1.seq].s_facility_location), patient_name =
   substring(1,60,wound->encntr[d1.seq].s_patient_name), account_number = substring(1,20,wound->
    encntr[d1.seq].s_fin),
   admit_dt_tm = substring(1,30,wound->encntr[d1.seq].s_admit_dt_tm), skin_integrity = substring(1,
    100,wound->encntr[d1.seq].s_skin_integrity), skin_abnormality_type = substring(1,100,wound->
    encntr[d1.seq].s_skin_abnormality_type),
   wound_photo_uploaded = substring(1,100,wound->encntr[d1.seq].s_wound_photo_uploaded),
   skin_assessment_2nd_person = substring(1,100,wound->encntr[d1.seq].s_skin_assessment_2nd_person),
   wound_present_on_admission = substring(1,100,wound->encntr[d1.seq].s_wound_present_on_admission),
   pressure_wound_date_identified = substring(1,100,wound->encntr[d1.seq].
    s_pressure_wound_date_identified), pressure_injury_present_on_admission = substring(1,100,wound->
    encntr[d1.seq].s_pressure_injury_present_on_admission), pressure_injury_stage = substring(1,100,
    wound->encntr[d1.seq].s_pressure_injury_stage),
   braden_score = substring(1,100,wound->encntr[d1.seq].s_braden_score_adult), braden_q_score_pedi =
   substring(1,100,wound->encntr[d1.seq].s_braden_q_score_pedi), braden_q_score_newborn = substring(1,
    100,wound->encntr[d1.seq].s_braden_q_score_newborn),
   braden_score_date = substring(1,100,wound->encntr[d1.seq].s_braden_score_date), mattress_device =
   substring(1,100,wound->encntr[d1.seq].s_mattress_device), therapeutic_bed_order = substring(1,100,
    wound->encntr[d1.seq].s_therapeutic_bed_order),
   therapeutic_bed_order_date = substring(1,100,wound->encntr[d1.seq].s_therapeutic_bed_order_date),
   nursing_care_plan_initiated_updated = substring(1,100,wound->encntr[d1.seq].
    s_nursing_care_plan_initiated_updated), prevention_interventions_skin = substring(1,100,wound->
    encntr[d1.seq].s_prevention_interventions_skin),
   maintenance_interventions_skin = substring(1,100,wound->encntr[d1.seq].
    s_maintenance_interventions_skin), pressure_interventions_skin = substring(1,100,wound->encntr[d1
    .seq].s_pressure_interventions_skin), wound_interventions_skin = substring(1,100,wound->encntr[d1
    .seq].s_wound_interventions_skin),
   surgical_wound_interventions = substring(1,100,wound->encntr[d1.seq].
    s_surgical_wound_interventions), diaper_dermatitis_interventions = substring(1,100,wound->encntr[
    d1.seq].s_diaper_dermatitis_interventions), adhesive_interventions = substring(1,100,wound->
    encntr[d1.seq].s_adhesive_interventions),
   skin_breakdown_prevention_intervention = substring(1,100,wound->encntr[d1.seq].
    s_skin_breakdown_prevention_intervention), wound_care_rn_consult_order_date = substring(1,100,
    wound->encntr[d1.seq].s_wound_care_rn_consult_order_date), wound_care_order_date1 = substring(1,
    100,wound->encntr[d1.seq].s_wound_care_order_date1),
   wound_care_order_info1 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info1),
   wound_care_order_date2 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date2),
   wound_care_order_info2 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info2),
   wound_care_order_date3 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date3),
   wound_care_order_info3 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info3),
   wound_care_order_date4 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date4),
   wound_care_order_info4 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info4),
   wound_care_order_date5 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date5),
   wound_care_order_info5 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info5),
   wound_care_order_date6 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date6),
   wound_care_order_info6 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info6),
   wound_care_order_date7 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date7),
   wound_care_order_info7 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info7),
   wound_care_order_date8 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date8),
   wound_care_order_info8 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info8),
   wound_care_order_date9 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date9),
   wound_care_order_info9 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info9),
   wound_care_order_date10 = substring(1,100,wound->encntr[d1.seq].s_wound_care_order_date10),
   wound_care_order_info10 = substring(1,250,wound->encntr[d1.seq].s_wound_care_order_info10),
   wound_vac_order_date = substring(1,100,wound->encntr[d1.seq].s_wound_vac_order_date),
   nutrition_services_order_date = substring(1,100,wound->encntr[d1.seq].s_nut_service_date),
   baseline_functional_status = substring(1,100,wound->encntr[d1.seq].s_baseline_functional_status),
   activity_assistance = substring(1,100,wound->encntr[d1.seq].s_activity_assistance),
   turn_and_reposition = substring(1,100,wound->encntr[d1.seq].s_turn_and_reposition),
   changing_of_o2sat_probes_q_4_hours = substring(1,100,wound->encntr[d1.seq].
    s_changing_of_o2sat_probes_q_4_hours), race_1 = substring(1,100,wound->encntr[d1.seq].s_race_1),
   ethnicity_1 = substring(1,100,wound->encntr[d1.seq].s_ethnicity_1)
   FROM (dummyt d1  WITH seq = size(wound->encntr,5))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "No Data Qualified",
    CALL print(calcpos(36,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
