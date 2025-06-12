CREATE PROGRAM dcp_get_apache_adm:dba
 RECORD reply(
   1 risk_adjustment_id = f8
   1 dialysis_ind = i2
   1 admitsource_flag = i2
   1 admit_source = vc
   1 admit_source_cd = f8
   1 admit_source_disp = vc
   1 body_system = vc
   1 body_system_cd = f8
   1 body_system_disp = vc
   1 xfer_within_48hr_ind = i2
   1 readmit_ind = i2
   1 readmit_within_24hr_ind = i2
   1 ami_location = vc
   1 ami_location_cd = f8
   1 ami_location_disp = f8
   1 ptca_device = vc
   1 ptca_device_cd = f8
   1 ptca_device_disp = vc
   1 sv_graft_ind = i2
   1 mi_within_6mo_ind = i2
   1 cc_during_stay_ind = i2
   1 icu_admit_dt_tm = dq8
   1 hosp_admit_dt_tm = dq8
   1 admitdiagnosis = vc
   1 admitdiagnosis_cd = f8
   1 admitdiagnosis_disp = vc
   1 thrombolytics_ind = i2
   1 aids_ind = i2
   1 hepaticfailure_ind = i2
   1 lymphoma_ind = i2
   1 metastaticcancer_ind = i2
   1 leukemia_ind = i2
   1 immunosuppression_ind = i2
   1 cirrhosis_ind = i2
   1 electivesurgery_ind = i2
   1 ima_ind = i2
   1 midur_ind = i2
   1 ventday1_ind = i2
   1 oobventday1_ind = i2
   1 oobintubday1_ind = i2
   1 diabetes_ind = i2
   1 var03hspxlos = f8
   1 ejectfx = f8
   1 loc_nurse_unit_cd = f8
   1 loc_nurse_unit_disp = vc
   1 loc_room_cd = f8
   1 loc_room_disp = vc
   1 loc_bed_cd = f8
   1 loc_bed_disp = vc
   1 med_service_cd = f8
   1 med_service_disp = vc
   1 adm_doc_id = f8
   1 adm_doc = vc
   1 time_at_source = i4
   1 copd_ind = i2
   1 copd_flag = i2
   1 chronic_health_unavail_ind = i2
   1 chronic_health_none_ind = i2
   1 nbr_grafts_performed = i4
   1 icu_disch_dt_tm = dq8
   1 discharge_location_cd = f8
   1 diedinicu_ind = i2
   1 hosp_disch_dt_tm = dq8
   1 diedinhospital_ind = i2
   1 consec_vent_days = i2
   1 consec_pa_days = i2
   1 bedhist[*]
     2 nu_room_bed_disp = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 cc_day[*]
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 RECORD hdeath_parameters(
   1 risk_adjustment_id = f8
 )
 RECORD hdeath_reply(
   1 hosp_death_ind = i4
 )
 DECLARE meaning_code(p1,p1) = f8
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_read TO 2099_read_exit
 EXECUTE FROM 3000_get_chi TO 3099_get_chi_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
 SET cc_day = 0
 SET ra_entry_found = "N"
 SET body_system_cd = 0.0
 SET admit_source_cd = 0.0
 SET admitdiagnosis_cd = 0.0
 SET ptca_device_cd = 0.0
 SET ami_location_cd = 0.0
 SET doc_cd = 0.0
 SET vent_cnt = 0
 SET pa_cnt = 0
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 DECLARE nu = vc
 DECLARE rm = vc
 DECLARE bd = vc
 DECLARE nu_rm_bd = vc
 SET reply->risk_adjustment_id = - (1)
 SET reply->dialysis_ind = - (1)
 SET reply->admitsource_flag = 0
 SET reply->admit_source = ""
 SET reply->admit_source_cd = - (1)
 SET reply->admit_source_disp = ""
 SET reply->body_system = ""
 SET reply->body_system_cd = - (1)
 SET reply->body_system_disp = ""
 SET reply->xfer_within_48hr_ind = - (1)
 SET reply->readmit_ind = 0
 SET reply->readmit_within_24hr_ind = - (1)
 SET reply->ami_location = ""
 SET reply->ami_location_cd = - (1)
 SET reply->ami_location_disp = - (1)
 SET reply->ptca_device = ""
 SET reply->ptca_device_cd = - (1)
 SET reply->ptca_device_disp = ""
 SET reply->sv_graft_ind = - (1)
 SET reply->mi_within_6mo_ind = - (1)
 SET reply->cc_during_stay_ind = - (1)
 SET reply->icu_admit_dt_tm = - (1)
 SET reply->hosp_admit_dt_tm = - (1)
 SET reply->admitdiagnosis = ""
 SET reply->admitdiagnosis_cd = - (1)
 SET reply->admitdiagnosis_disp = ""
 SET reply->thrombolytics_ind = - (1)
 SET reply->aids_ind = 0
 SET reply->hepaticfailure_ind = 0
 SET reply->lymphoma_ind = 0
 SET reply->metastaticcancer_ind = 0
 SET reply->leukemia_ind = 0
 SET reply->immunosuppression_ind = 0
 SET reply->cirrhosis_ind = 0
 SET reply->electivesurgery_ind = - (1)
 SET reply->ima_ind = - (1)
 SET reply->midur_ind = - (1)
 SET reply->ventday1_ind = - (1)
 SET reply->oobventday1_ind = - (1)
 SET reply->oobintubday1_ind = - (1)
 SET reply->diabetes_ind = 0
 SET reply->var03hspxlos = - (1)
 SET reply->ejectfx = - (1)
 SET reply->loc_nurse_unit_cd = - (1)
 SET reply->loc_nurse_unit_disp = ""
 SET reply->loc_room_cd = - (1)
 SET reply->loc_room_disp = ""
 SET reply->loc_bed_cd = - (1)
 SET reply->loc_bed_disp = ""
 SET reply->med_service_cd = - (1)
 SET reply->med_service_disp = ""
 SET reply->adm_doc_id = - (1)
 SET reply->adm_doc = ""
 SET reply->time_at_source = - (1)
 SET reply->copd_ind = 0
 SET reply->copd_flag = 0
 SET reply->chronic_health_unavail_ind = 0
 SET reply->chronic_health_none_ind = 0
 SET reply->nbr_grafts_performed = - (1)
 SET reply->icu_disch_dt_tm = - (1)
 SET reply->discharge_location_cd = - (1)
 SET reply->diedinicu_ind = - (1)
 SET reply->hosp_disch_dt_tm = - (1)
 SET reply->diedinhospital_ind = - (1)
 SET reply->consec_vent_days = - (1)
 SET reply->consec_pa_days = - (1)
 SET reply->loc_nurse_unit_cd = - (1)
#1099_initialize_exit
#2000_read
 EXECUTE FROM 2100_read_risk_adjustment TO 2199_risk_adjustment_exit
 IF ((reply->risk_adjustment_id=0.0))
  EXECUTE FROM 2200_read_for_readmit TO 2299_read_for_readmit_exit
 ENDIF
 SET reply->status_data.status = "S"
#2099_read_exit
#2100_read_risk_adjustment
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND (ra.encntr_id=request->encntr_id)
    AND ra.active_ind=1)
  ORDER BY cnvtdatetime(ra.icu_admit_dt_tm) DESC
  HEAD REPORT
   data_loaded = "N"
  HEAD ra.icu_admit_dt_tm
   IF (data_loaded="N")
    IF (ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm))
     data_loaded = "Y", ra_entry_found = "Y", reply->risk_adjustment_id = ra.risk_adjustment_id,
     reply->dialysis_ind = ra.dialysis_ind, reply->admitsource_flag = ra.admitsource_flag, reply->
     admit_source = ra.admit_source,
     reply->med_service_cd = ra.med_service_cd, reply->body_system = ra.body_system, reply->
     xfer_within_48hr_ind = ra.xfer_within_48hr_ind,
     reply->readmit_ind = ra.readmit_ind, reply->readmit_within_24hr_ind = ra.readmit_within_24hr_ind,
     reply->ami_location = ra.ami_location,
     reply->ptca_device = ra.ptca_device, reply->sv_graft_ind = ra.sv_graft_ind, reply->
     mi_within_6mo_ind = ra.mi_within_6mo_ind,
     reply->cc_during_stay_ind = ra.cc_during_stay_ind, this_icu_admit_no_seconds = format(ra
      .icu_admit_dt_tm,"DD-MMM-YYYY HH:MM;;D"), reply->icu_admit_dt_tm = cnvtdatetime(
      this_icu_admit_no_seconds),
     reply->admitdiagnosis = ra.admit_diagnosis, reply->thrombolytics_ind = ra.thrombolytics_ind,
     reply->aids_ind = ra.aids_ind,
     reply->hepaticfailure_ind = ra.hepaticfailure_ind, reply->lymphoma_ind = ra.lymphoma_ind, reply
     ->metastaticcancer_ind = ra.metastaticcancer_ind,
     reply->leukemia_ind = ra.leukemia_ind, reply->immunosuppression_ind = ra.immunosuppression_ind,
     reply->cirrhosis_ind = ra.cirrhosis_ind,
     reply->electivesurgery_ind = ra.electivesurgery_ind, reply->ima_ind = ra.ima_ind, reply->
     midur_ind = ra.midur_ind,
     reply->diabetes_ind = ra.diabetes_ind, reply->var03hspxlos = ra.var03hspxlos_value, reply->
     ejectfx = ra.ejectfx_fraction,
     reply->time_at_source = ra.hrs_at_source, reply->copd_ind = ra.copd_ind, reply->copd_flag = ra
     .copd_flag,
     reply->chronic_health_unavail_ind = ra.chronic_health_unavail_ind, reply->
     chronic_health_none_ind = ra.chronic_health_none_ind, reply->nbr_grafts_performed = ra
     .nbr_grafts_performed,
     reply->adm_doc_id = ra.adm_doc_id, reply->icu_disch_dt_tm = ra.icu_disch_dt_tm, reply->
     discharge_location_cd = ra.discharge_location_cd,
     reply->diedinicu_ind = ra.diedinicu_ind, reply->loc_nurse_unit_cd = ra.admit_icu_cd
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET hdeath_parameters->risk_adjustment_id = reply->risk_adjustment_id
 EXECUTE cco_get_died_hosp_from_ra
 SET reply->diedinhospital_ind = hdeath_reply->hosp_death_ind
 IF (ra_entry_found="Y")
  IF ((reply->body_system > " "))
   SET body_system_cd = meaning_code(28980,reply->body_system)
   IF (body_system_cd > 0.0)
    SET reply->body_system_cd = body_system_cd
   ENDIF
  ENDIF
  IF ((reply->admit_source > " "))
   SET admit_source_cd = meaning_code(28981,reply->admit_source)
   IF (admit_source_cd > 0.0)
    SET reply->admit_source_cd = admit_source_cd
   ENDIF
  ENDIF
  IF ((reply->admitdiagnosis > " "))
   SET admitdiagnosis_cd = meaning_code(28984,reply->admitdiagnosis)
   IF (admitdiagnosis_cd > 0.0)
    SET reply->admitdiagnosis_cd = admitdiagnosis_cd
   ENDIF
  ENDIF
  IF ((reply->ptca_device > " "))
   SET ptca_device_cd = meaning_code(28983,reply->ptca_device)
   IF (ptca_device_cd > 0.0)
    SET reply->ptca_device_cd = ptca_device_cd
   ENDIF
  ENDIF
  IF ((reply->ami_location > " "))
   SET ami_location_cd = meaning_code(28980,reply->ami_location)
   IF (ami_location_cd > 0.0)
    SET reply->ami_location_cd = ami_location_cd
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (p
   WHERE (p.person_id=request->person_id))
  DETAIL
   reply->hosp_admit_dt_tm = cnvtdatetime(e.reg_dt_tm)
   IF (ra_entry_found != "Y")
    this_reg_dt_no_seconds = format(e.reg_dt_tm,"DD-MMM-YYYY HH:MM;;D"), reply->icu_admit_dt_tm =
    cnvtdatetime(this_reg_dt_no_seconds)
   ENDIF
   reply->hosp_disch_dt_tm = cnvtdatetime(e.disch_dt_tm)
   IF ((reply->loc_nurse_unit_cd <= 0.0))
    reply->loc_nurse_unit_cd = e.loc_nurse_unit_cd
   ENDIF
   reply->loc_room_cd = e.loc_room_cd, reply->loc_bed_cd = e.loc_bed_cd
  WITH nocounter
 ;end select
 IF ((reply->adm_doc_id <= 0.0))
  SET doc_cd = meaning_code(333,"ATTENDDOC")
  SELECT INTO "nl:"
   FROM encntr_prsnl_reltn epr,
    prsnl p
   PLAN (epr
    WHERE (epr.encntr_id=request->encntr_id)
     AND epr.encntr_prsnl_r_cd=doc_cd
     AND epr.active_ind=1
     AND epr.expiration_ind=0
     AND epr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
     AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=epr.prsnl_person_id)
   DETAIL
    reply->adm_doc_id = p.person_id, reply->adm_doc = p.name_full_formatted
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=reply->adm_doc_id))
   DETAIL
    reply->adm_doc = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh
  PLAN (elh
   WHERE (elh.encntr_id=request->encntr_id)
    AND elh.active_ind=1)
  ORDER BY elh.end_effective_dt_tm DESC
  HEAD REPORT
   cnt = 0, nu = " ", rm = " ",
   bd = " ", nu_rm_bd = " "
  DETAIL
   IF (ra_entry_found != "Y"
    AND elh.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    this_transfer_no_seconds = format(elh.beg_effective_dt_tm,"DD-MMM-YYYY HH:MM;;D"), reply->
    icu_admit_dt_tm = cnvtdatetime(this_transfer_no_seconds)
   ENDIF
   cnt = (cnt+ 1), stat = alterlist(reply->bedhist,cnt), reply->bedhist[cnt].beg_effective_dt_tm =
   elh.beg_effective_dt_tm,
   reply->bedhist[cnt].end_effective_dt_tm = elh.end_effective_dt_tm, nu = trim(uar_get_code_display(
     elh.loc_nurse_unit_cd)), rm = trim(uar_get_code_display(elh.loc_room_cd)),
   bd = trim(uar_get_code_display(elh.loc_bed_cd))
   IF (rm > " ")
    nu_rm_bd = concat(nu,":",rm)
    IF (bd > " ")
     nu_rm_bd = concat(nu_rm_bd,"-",bd)
    ENDIF
   ELSE
    nu_rm_bd = nu
   ENDIF
   reply->bedhist[cnt].nu_room_bed_disp = nu_rm_bd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=reply->risk_adjustment_id)
    AND rad.active_ind=1)
  ORDER BY rad.cc_day
  HEAD REPORT
   pa_cnt = 0, vent_cnt = 0, keep_counting_pa = "Y",
   keep_counting_vent = "Y"
  DETAIL
   IF (keep_counting_pa="Y")
    IF (rad.pa_line_today_ind=1)
     pa_cnt = (pa_cnt+ 1)
    ELSE
     keep_counting_pa = "N"
    ENDIF
   ENDIF
   IF (keep_counting_vent="Y")
    IF (rad.vent_today_ind=1)
     vent_cnt = (vent_cnt+ 1)
    ELSE
     keep_counting_vent = "N"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET reply->consec_pa_days = pa_cnt
 SET reply->consec_vent_days = vent_cnt
 IF (ra_entry_found != "Y")
  SET reply->risk_adjustment_id = 0.0
  SET reply->icu_disch_dt_tm = cnvtdatetime("31-DEC-2100 00:00")
  SET reply->discharge_location_cd = - (1)
 ENDIF
 IF ((reply->icu_admit_dt_tm < reply->hosp_admit_dt_tm))
  SET this_icu_admit_no_seconds = format(reply->hosp_admit_dt_tm,"DD-MMM-YYYY HH:MM;;D")
  SET reply->icu_admit_dt_tm = cnvtdatetime(this_icu_admit_no_seconds)
 ENDIF
#2199_risk_adjustment_exit
#2200_read_for_readmit
 DECLARE dischargedatetime = dq8
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND (ra.encntr_id=request->encntr_id)
    AND ra.active_ind=1)
  ORDER BY cnvtdatetime(ra.icu_disch_dt_tm) DESC
  HEAD REPORT
   first_time = "Y"
  DETAIL
   IF (first_time="Y")
    first_time = "N", dischargedatetime = ra.icu_disch_dt_tm, reply->readmit_ind = 1,
    datetimediff = datetimediff(reply->icu_admit_dt_tm,dischargedatetime,3)
    IF (abs(datetimediff) < 24)
     reply->readmit_within_24hr_ind = 1
    ELSE
     reply->readmit_within_24hr_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#2299_read_for_readmit_exit
#3000_get_chi
 SET inerror_cd = meaning_code(8,"INERROR")
 SET event_tag_num = - (1.0)
 SET aids_cd = 0.0
 SET hepatic_cd = 0.0
 SET lymphoma_cd = 0.0
 SET metastatic_cd = 0.0
 SET leukemia_cd = 0.0
 SET leukemia2_cd = 0.0
 SET immuno_cd = 0.0
 SET cirrhosis_cd = 0.0
 SET copd_mod_cd = 0.0
 SET copd_nolim_cd = 0.0
 SET copd_sev_cd = 0.0
 SET diabetes_cd = 0.0
 SET dialysis_cd = 0.0
 SET chi_unknown_cd = 0.0
 SET aids_cd = uar_get_code_by_cki("CKI.EC!7061")
 SET hepatic_cd = uar_get_code_by_cki("CKI.EC!7673")
 SET lymphoma_cd = uar_get_code_by_cki("CKI.EC!7327")
 SET metastatic_cd = uar_get_code_by_cki("CKI.EC!7674")
 SET leukemia_cd = uar_get_code_by_cki("CKI.EC!6085")
 SET leukemia2_cd = uar_get_code_by_cki("CKI.EC!7678")
 SET immuno_cd = uar_get_code_by_cki("CKI.EC!7063")
 SET cirrhosis_cd = uar_get_code_by_cki("CKI.EC!7667")
 SET copd_mod_cd = uar_get_code_by_cki("CKI.EC!7668")
 SET copd_nolim_cd = uar_get_code_by_cki("CKI.EC!7669")
 SET copd_sev_cd = uar_get_code_by_cki("CKI.EC!7670")
 SET diabetes_cd = uar_get_code_by_cki("CKI.EC!5963")
 SET dialysis_cd = uar_get_code_by_cki("CKI.EC!7671")
 SET chi_unknown_cd = uar_get_code_by_cki("CKI.EC!5944")
 IF (((aids_cd > 0.0) OR (((hepatic_cd > 0.0) OR (((lymphoma_cd > 0.0) OR (((metastatic_cd > 0.0) OR
 (((leukemia_cd > 0.0) OR (((leukemia2_cd > 0.0) OR (((immuno_cd > 0.0) OR (((cirrhosis_cd > 0.0) OR
 (((diabetes_cd > 0.0) OR (((copd_mod_cd > 0.0) OR (((copd_nolim_cd > 0.0) OR (((copd_sev_cd > 0.0)
  OR (((dialysis_cd > 0.0) OR (chi_unknown_cd > 0)) )) )) )) )) )) )) )) )) )) )) )) )) )
  EXECUTE FROM 3500_get_ce TO 3599_get_ce_exit
 ENDIF
#3099_get_chi_exit
#3500_get_ce
 SET temp_tag = 0.0
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.event_cd IN (aids_cd, hepatic_cd, lymphoma_cd, metastatic_cd, leukemia_cd,
   leukemia2_cd, immuno_cd, cirrhosis_cd, copd_sev_cd, copd_mod_cd,
   copd_nolim_cd, diabetes_cd, dialysis_cd, chi_unknown_cd)
    AND ce.event_end_dt_tm >= cnvtdatetime(reply->icu_admit_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(reply->icu_disch_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ((ce.encntr_id+ 0)=request->encntr_id)
    AND ((ce.view_level+ 0)=1)
    AND ((ce.publish_flag+ 0)=1)
    AND ce.event_cd > 0)
  ORDER BY cnvtdatetime(ce.updt_dt_tm)
  HEAD REPORT
   temp_tag = 0.0
  DETAIL
   IF (ce.event_cd=aids_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->aids_ind = 0
     ELSE
      reply->aids_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=hepatic_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->hepaticfailure_ind = 0
     ELSE
      reply->hepaticfailure_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=lymphoma_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->lymphoma_ind = 0
     ELSE
      reply->lymphoma_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=metastatic_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->metastaticcancer_ind = 0
     ELSE
      reply->metastaticcancer_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd IN (leukemia_cd, leukemia2_cd))
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->leukemia_ind = 0
     ELSE
      reply->leukemia_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=immuno_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->immunosuppression_ind = 0
     ELSE
      reply->immunosuppression_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=cirrhosis_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->cirrhosis_ind = 0
     ELSE
      reply->cirrhosis_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=copd_nolim_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->copd_flag = - (1), reply->copd_ind = 0
     ELSE
      reply->copd_flag = 0, reply->copd_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=copd_mod_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->copd_flag = - (1), reply->copd_ind = 0
     ELSE
      reply->copd_flag = 1, reply->copd_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=copd_sev_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->copd_flag = - (1), reply->copd_ind = 0
     ELSE
      reply->copd_flag = 2, reply->copd_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=diabetes_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->diabetes_ind = 0
     ELSE
      reply->diabetes_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=dialysis_cd)
    IF (cnvtupper(ce.event_tag)="SELF")
     IF (ce.result_status_cd=inerror_cd)
      reply->dialysis_ind = 0
     ELSE
      reply->dialysis_ind = 1
     ENDIF
    ELSEIF ((reply->dialysis_ind=- (1))
     AND ce.result_status_cd != inerror_cd)
     reply->dialysis_ind = 0
    ENDIF
   ELSEIF (ce.event_cd=chi_unknown_cd)
    IF (cnvtupper(ce.event_tag)="UNABLE TO OBTAIN")
     IF (ce.result_status_cd=inerror_cd)
      reply->chronic_health_unavail_ind = 0
     ELSE
      reply->chronic_health_unavail_ind = 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->aids_ind < 1)
  AND (reply->hepaticfailure_ind < 1)
  AND (reply->lymphoma_ind < 1)
  AND (reply->metastaticcancer_ind < 1)
  AND (reply->leukemia_ind < 1)
  AND (reply->immunosuppression_ind < 1)
  AND (reply->cirrhosis_ind < 1)
  AND (reply->copd_ind < 1)
  AND (reply->copd_flag < 1)
  AND (reply->chronic_health_unavail_ind < 1)
  AND (reply->chronic_health_none_ind < 1)
  AND (reply->diabetes_ind < 1))
  SELECT INTO "nl:"
   FROM dcp_forms_activity dfa
   WHERE (dfa.person_id=request->person_id)
    AND dfa.form_dt_tm >= cnvtdatetime(reply->icu_admit_dt_tm)
    AND dfa.form_dt_tm < cnvtdatetime(reply->icu_disch_dt_tm)
    AND dfa.flags=2
    AND cnvtupper(dfa.description) IN (cnvtupper("Adult Patient History ICU"), cnvtupper(
    "ICU Transfer Patient History"))
    AND ((dfa.encntr_id+ 0)=request->encntr_id)
    AND dfa.active_ind=1
   DETAIL
    reply->chronic_health_none_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#3599_get_ce_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
