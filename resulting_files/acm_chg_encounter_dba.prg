CREATE PROGRAM acm_chg_encounter:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE t1 = i4 WITH noconstant(0), protect
 DECLARE t2 = i4 WITH noconstant(0), protect
 DECLARE max_val = i4 WITH noconstant(200), protect
 DECLARE t_val = i4 WITH noconstant(xref->chg_cnt), protect
 DECLARE f_val = i4 WITH noconstant(1), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE chg_cnt = i4 WITH noconstant(xref->chg_cnt), protect
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE active_status_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE active_status_dt_tm = f8 WITH protect, noconstant(0.0)
 FOR (index = 1 TO xref->chg_cnt)
   SET reply->encounter_qual[xref->chg[index].idx].status = 0
 ENDFOR
 IF (t_val <= max_val)
  SET max_val = t_val
  CALL getexistingrows(max_val)
 ELSE
  SET t_val = max_val
  WHILE (chg_cnt > 0)
    CALL getexistingrows(max_val)
    SET chg_cnt -= max_val
    SET f_val = (t_val+ 1)
    IF (chg_cnt > max_val)
     SET t_val += max_val
    ELSE
     SET t_val += chg_cnt
    ENDIF
  ENDWHILE
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(xref->chg_cnt)),
   encounter e
  SET e.encntr_id = acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_id, e.accomp_by_cd =
   acm_request->encounter_qual[xref->chg[d.seq].idx].accomp_by_cd, e.admit_mode_cd = acm_request->
   encounter_qual[xref->chg[d.seq].idx].admit_mode_cd,
   e.admit_src_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].admit_src_cd, e.admit_type_cd
    = acm_request->encounter_qual[xref->chg[d.seq].idx].admit_type_cd, e.admit_with_medication_cd =
   acm_request->encounter_qual[xref->chg[d.seq].idx].admit_with_medication_cd,
   e.alc_decomp_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].alc_decomp_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].alc_decomp_dt_tm)
   ELSE null
   ENDIF
   , e.alc_reason_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].alc_reason_cd, e
   .alt_lvl_care_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].alt_lvl_care_cd,
   e.alt_lvl_care_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].alt_lvl_care_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].alt_lvl_care_dt_tm)
   ELSE null
   ENDIF
   , e.alt_result_dest_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].alt_result_dest_cd, e
   .ambulatory_cond_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].ambulatory_cond_cd,
   e.arrive_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].arrive_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->chg[d.seq].idx].arrive_dt_tm)
   ELSE null
   ENDIF
   , e.bbd_procedure_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].bbd_procedure_cd, e
   .beg_effective_dt_tm = cnvtdatetime(acm_request->encounter_qual[xref->chg[d.seq].idx].
    beg_effective_dt_tm),
   e.chart_complete_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].chart_complete_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].chart_complete_dt_tm)
   ELSE null
   ENDIF
   , e.confid_level_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].confid_level_cd, e
   .contributor_system_cd =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].contributor_system_cd > 0.0)) acm_request->
    encounter_qual[xref->chg[d.seq].idx].contributor_system_cd
   ELSE pmhc_contributory_system_cd
   ENDIF
   ,
   e.courtesy_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].courtesy_cd, e.depart_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].depart_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->chg[d.seq].idx].depart_dt_tm)
   ELSE null
   ENDIF
   , e.diet_type_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].diet_type_cd,
   e.disch_disposition_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].disch_disposition_cd, e
   .disch_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].disch_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->chg[d.seq].idx].disch_dt_tm)
   ELSE null
   ENDIF
   , e.disch_to_loctn_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].disch_to_loctn_cd,
   e.doc_rcvd_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].doc_rcvd_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].doc_rcvd_dt_tm)
   ELSE null
   ENDIF
   , e.encntr_class_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_class_cd, e
   .encntr_complete_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_complete_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_complete_dt_tm)
   ELSE cnvtdatetime(sysdate)
   ENDIF
   ,
   e.encntr_financial_id =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_financial_id > 0)) acm_request->
    encounter_qual[xref->chg[d.seq].idx].encntr_financial_id
   ELSE reply->encntr_financial_qual[acm_request->encounter_qual[xref->chg[d.seq].idx].
    encntr_financial_idx].encntr_financial_id
   ENDIF
   , e.encntr_status_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_status_cd, e
   .encntr_type_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_type_cd,
   e.encntr_type_class_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_type_class_cd, e
   .end_effective_dt_tm = cnvtdatetime(acm_request->encounter_qual[xref->chg[d.seq].idx].
    end_effective_dt_tm), e.est_arrive_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].est_arrive_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].est_arrive_dt_tm)
   ELSE null
   ENDIF
   ,
   e.est_depart_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].est_depart_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].est_depart_dt_tm)
   ELSE null
   ENDIF
   , e.est_length_of_stay = acm_request->encounter_qual[xref->chg[d.seq].idx].est_length_of_stay, e
   .financial_class_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].financial_class_cd,
   e.guarantor_type_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].guarantor_type_cd, e
   .info_given_by = acm_request->encounter_qual[xref->chg[d.seq].idx].info_given_by, e.isolation_cd
    = acm_request->encounter_qual[xref->chg[d.seq].idx].isolation_cd,
   e.location_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].location_cd, e.loc_bed_cd =
   acm_request->encounter_qual[xref->chg[d.seq].idx].loc_bed_cd, e.loc_building_cd = acm_request->
   encounter_qual[xref->chg[d.seq].idx].loc_building_cd,
   e.loc_facility_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].loc_facility_cd, e
   .loc_nurse_unit_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].loc_nurse_unit_cd, e
   .loc_room_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].loc_room_cd,
   e.loc_temp_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].loc_temp_cd, e.med_service_cd =
   acm_request->encounter_qual[xref->chg[d.seq].idx].med_service_cd, e.mental_health_cd = acm_request
   ->encounter_qual[xref->chg[d.seq].idx].mental_health_cd,
   e.mental_health_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].mental_health_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].mental_health_dt_tm)
   ELSE null
   ENDIF
   , e.organization_id = acm_request->encounter_qual[xref->chg[d.seq].idx].organization_id, e
   .person_id =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].person_id > 0)) acm_request->
    encounter_qual[xref->chg[d.seq].idx].person_id
   ELSE reply->person_qual[acm_request->encounter_qual[xref->chg[d.seq].idx].person_idx].person_id
   ENDIF
   ,
   e.placement_auth_prsnl_id = acm_request->encounter_qual[xref->chg[d.seq].idx].
   placement_auth_prsnl_id, e.preadmit_nbr = acm_request->encounter_qual[xref->chg[d.seq].idx].
   preadmit_nbr, e.preadmit_testing_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].
   preadmit_testing_cd,
   e.pre_reg_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].pre_reg_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].pre_reg_dt_tm)
   ELSE null
   ENDIF
   , e.pre_reg_prsnl_id = acm_request->encounter_qual[xref->chg[d.seq].idx].pre_reg_prsnl_id, e
   .program_service_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].program_service_cd,
   e.readmit_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].readmit_cd, e.reason_for_visit =
   acm_request->encounter_qual[xref->chg[d.seq].idx].reason_for_visit, e.referral_rcvd_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].referral_rcvd_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].referral_rcvd_dt_tm)
   ELSE null
   ENDIF
   ,
   e.referring_comment = acm_request->encounter_qual[xref->chg[d.seq].idx].referring_comment, e
   .refer_facility_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].refer_facility_cd, e
   .region_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].region_cd,
   e.reg_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].reg_dt_tm > 0)) cnvtdatetime(acm_request->
     encounter_qual[xref->chg[d.seq].idx].reg_dt_tm)
   ELSE null
   ENDIF
   , e.reg_prsnl_id = acm_request->encounter_qual[xref->chg[d.seq].idx].reg_prsnl_id, e
   .result_dest_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].result_dest_cd,
   e.safekeeping_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].safekeeping_cd, e
   .security_access_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].security_access_cd, e
   .service_category_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].service_category_cd,
   e.sitter_required_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].sitter_required_cd, e
   .specialty_unit_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].specialty_unit_cd, e
   .species_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].species_cd,
   e.trauma_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].trauma_cd, e.trauma_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].trauma_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->chg[d.seq].idx].trauma_dt_tm)
   ELSE null
   ENDIF
   , e.triage_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].triage_cd,
   e.triage_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].triage_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->chg[d.seq].idx].triage_dt_tm)
   ELSE null
   ENDIF
   , e.valuables_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].valuables_cd, e.vip_cd =
   acm_request->encounter_qual[xref->chg[d.seq].idx].vip_cd,
   e.visitor_status_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].visitor_status_cd, e
   .zero_balance_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].zero_balance_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].zero_balance_dt_tm)
   ELSE null
   ENDIF
   , e.mental_category_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].mental_category_cd,
   e.patient_classification_cd = acm_request->encounter_qual[xref->chg[d.seq].idx].
   patient_classification_cd, e.psychiatric_status_cd = acm_request->encounter_qual[xref->chg[d.seq].
   idx].psychiatric_status_cd, e.inpatient_admit_dt_tm =
   IF ((acm_request->encounter_qual[xref->chg[d.seq].idx].inpatient_admit_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->chg[d.seq].idx].inpatient_admit_dt_tm)
   ELSE null
   ENDIF
   ,
   e.active_ind = acm_request->encounter_qual[xref->chg[d.seq].idx].active_ind, e.active_status_cd =
   acm_request->encounter_qual[xref->chg[d.seq].idx].active_status_cd, e.active_status_prsnl_id =
   active_status_prsnl_id,
   e.active_status_dt_tm = cnvtdatetime(active_status_dt_tm), e.updt_cnt = (e.updt_cnt+ 1), e
   .updt_dt_tm = cnvtdatetime(sysdate),
   e.updt_id = reqinfo->updt_id, e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->
   updt_task
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=acm_request->encounter_qual[xref->chg[d.seq].idx].encntr_id))
  WITH nocounter, status(reply->encounter_qual[xref->chg[d.seq].idx].status)
 ;end update
 FOR (index = 1 TO xref->chg_cnt)
   IF ((reply->encounter_qual[xref->chg[index].idx].status != 1))
    SET failed = update_error
    SET table_name = "ENCOUNTER"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (acm_hist_ind=1)
  EXECUTE acm_chg_encntr_hist
  IF ((reply->status_data.status="F"))
   SET failed = true
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE getexistingrows(x)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE expand(t1,f_val,t_val,e.encntr_id,acm_request->encounter_qual[xref->chg[t1].idx].encntr_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,e.encntr_id,acm_request->encounter_qual[xref->chg[t1].idx].
      encntr_id,
      max_val), idx = xref->chg[t2].idx
     IF ((((e.updt_cnt=acm_request->encounter_qual[idx].updt_cnt)) OR ((acm_request->force_updt_ind=1
     ))) )
      reply->encounter_qual[idx].status = - (1), reply->encounter_qual[idx].encntr_id = acm_request->
      encounter_qual[idx].encntr_id
     ELSE
      failed = update_cnt_error
     ENDIF
     chg_str = acm_request->encounter_qual[idx].chg_str
     IF (findstring("ACCOMP_BY_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].accomp_by_cd = e.accomp_by_cd
     ENDIF
     IF (findstring("ADMIT_MODE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].admit_mode_cd = e.admit_mode_cd
     ENDIF
     IF (findstring("ADMIT_SRC_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].admit_src_cd = e.admit_src_cd
     ENDIF
     IF (findstring("ADMIT_TYPE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].admit_type_cd = e.admit_type_cd
     ENDIF
     IF (findstring("ADMIT_WITH_MEDICATION_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].admit_with_medication_cd = e.admit_with_medication_cd
     ENDIF
     IF (findstring("ALC_DECOMP_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].alc_decomp_dt_tm = e.alc_decomp_dt_tm
     ENDIF
     IF (findstring("ALC_REASON_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].alc_reason_cd = e.alc_reason_cd
     ENDIF
     IF (findstring("ALT_LVL_CARE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].alt_lvl_care_cd = e.alt_lvl_care_cd
     ENDIF
     IF (findstring("ALT_LVL_CARE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].alt_lvl_care_dt_tm = e.alt_lvl_care_dt_tm
     ENDIF
     IF (findstring("ALT_RESULT_DEST_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].alt_result_dest_cd = e.alt_result_dest_cd
     ENDIF
     IF (findstring("AMBULATORY_COND_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].ambulatory_cond_cd = e.ambulatory_cond_cd
     ENDIF
     IF (findstring("ARRIVE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].arrive_dt_tm = e.arrive_dt_tm
     ENDIF
     IF (findstring("BBD_PROCEDURE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].bbd_procedure_cd = e.bbd_procedure_cd
     ENDIF
     IF (findstring("BEG_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].beg_effective_dt_tm = e.beg_effective_dt_tm
     ENDIF
     IF (findstring("CHART_COMPLETE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].chart_complete_dt_tm = e.chart_complete_dt_tm
     ENDIF
     IF (findstring("CONFID_LEVEL_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].confid_level_cd = e.confid_level_cd
     ENDIF
     IF (findstring("CONTRIBUTOR_SYSTEM_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].contributor_system_cd = e.contributor_system_cd
     ENDIF
     IF (findstring("COURTESY_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].courtesy_cd = e.courtesy_cd
     ENDIF
     IF (findstring("DEPART_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].depart_dt_tm = e.depart_dt_tm
     ENDIF
     IF (findstring("DIET_TYPE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].diet_type_cd = e.diet_type_cd
     ENDIF
     IF (findstring("DISCH_DISPOSITION_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].disch_disposition_cd = e.disch_disposition_cd
     ENDIF
     IF (findstring("DISCH_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].disch_dt_tm = e.disch_dt_tm
     ENDIF
     IF (findstring("DISCH_TO_LOCTN_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].disch_to_loctn_cd = e.disch_to_loctn_cd
     ENDIF
     IF (findstring("DOC_RCVD_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].doc_rcvd_dt_tm = e.doc_rcvd_dt_tm
     ENDIF
     IF (findstring("ENCNTR_CLASS_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].encntr_class_cd = e.encntr_class_cd
     ENDIF
     IF (findstring("ENCNTR_COMPLETE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].encntr_complete_dt_tm = e.encntr_complete_dt_tm
     ENDIF
     IF (findstring("ENCNTR_FINANCIAL_ID,",chg_str)=0)
      acm_request->encounter_qual[idx].encntr_financial_id = e.encntr_financial_id
     ENDIF
     IF (findstring("ENCNTR_STATUS_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].encntr_status_cd = e.encntr_status_cd
     ENDIF
     IF (findstring("ENCNTR_TYPE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].encntr_type_cd = e.encntr_type_cd
     ENDIF
     IF (findstring("ENCNTR_TYPE_CLASS_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].encntr_type_class_cd = e.encntr_type_class_cd
     ENDIF
     IF (findstring("END_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].end_effective_dt_tm = e.end_effective_dt_tm
     ENDIF
     IF (findstring("EST_ARRIVE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].est_arrive_dt_tm = e.est_arrive_dt_tm
     ENDIF
     IF (findstring("EST_DEPART_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].est_depart_dt_tm = e.est_depart_dt_tm
     ENDIF
     IF (findstring("EST_LENGTH_OF_STAY,",chg_str)=0)
      acm_request->encounter_qual[idx].est_length_of_stay = e.est_length_of_stay
     ENDIF
     IF (findstring("FINANCIAL_CLASS_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].financial_class_cd = e.financial_class_cd
     ENDIF
     IF (findstring("GUARANTOR_TYPE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].guarantor_type_cd = e.guarantor_type_cd
     ENDIF
     IF (findstring("INFO_GIVEN_BY,",chg_str)=0)
      acm_request->encounter_qual[idx].info_given_by = e.info_given_by
     ENDIF
     IF (findstring("ISOLATION_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].isolation_cd = e.isolation_cd
     ENDIF
     IF (findstring("LOCATION_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].location_cd = e.location_cd
     ENDIF
     IF (findstring("LOC_BED_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].loc_bed_cd = e.loc_bed_cd
     ENDIF
     IF (findstring("LOC_BUILDING_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].loc_building_cd = e.loc_building_cd
     ENDIF
     IF (findstring("LOC_FACILITY_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].loc_facility_cd = e.loc_facility_cd
     ENDIF
     IF (findstring("LOC_NURSE_UNIT_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].loc_nurse_unit_cd = e.loc_nurse_unit_cd
     ENDIF
     IF (findstring("LOC_ROOM_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].loc_room_cd = e.loc_room_cd
     ENDIF
     IF (findstring("LOC_TEMP_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].loc_temp_cd = e.loc_temp_cd
     ENDIF
     IF (findstring("MED_SERVICE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].med_service_cd = e.med_service_cd
     ENDIF
     IF (findstring("MENTAL_HEALTH_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].mental_health_cd = e.mental_health_cd
     ENDIF
     IF (findstring("MENTAL_HEALTH_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].mental_health_dt_tm = e.mental_health_dt_tm
     ENDIF
     IF (findstring("ORGANIZATION_ID,",chg_str)=0)
      acm_request->encounter_qual[idx].organization_id = e.organization_id
     ENDIF
     IF (findstring("PERSON_ID,",chg_str)=0)
      acm_request->encounter_qual[idx].person_id = e.person_id
     ENDIF
     IF (findstring("PLACEMENT_AUTH_PRSNL_ID,",chg_str)=0)
      acm_request->encounter_qual[idx].placement_auth_prsnl_id = e.placement_auth_prsnl_id
     ENDIF
     IF (findstring("PREADMIT_NBR,",chg_str)=0)
      acm_request->encounter_qual[idx].preadmit_nbr = e.preadmit_nbr
     ENDIF
     IF (findstring("PREADMIT_TESTING_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].preadmit_testing_cd = e.preadmit_testing_cd
     ENDIF
     IF (findstring("PRE_REG_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].pre_reg_dt_tm = e.pre_reg_dt_tm
     ENDIF
     IF (findstring("PRE_REG_PRSNL_ID,",chg_str)=0)
      acm_request->encounter_qual[idx].pre_reg_prsnl_id = e.pre_reg_prsnl_id
     ENDIF
     IF (findstring("PROGRAM_SERVICE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].program_service_cd = e.program_service_cd
     ENDIF
     IF (findstring("READMIT_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].readmit_cd = e.readmit_cd
     ENDIF
     IF (findstring("REASON_FOR_VISIT,",chg_str)=0)
      acm_request->encounter_qual[idx].reason_for_visit = e.reason_for_visit
     ENDIF
     IF (findstring("REFERRAL_RCVD_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].referral_rcvd_dt_tm = e.referral_rcvd_dt_tm
     ENDIF
     IF (findstring("REFERRING_COMMENT,",chg_str)=0)
      acm_request->encounter_qual[idx].referring_comment = e.referring_comment
     ENDIF
     IF (findstring("REFER_FACILITY_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].refer_facility_cd = e.refer_facility_cd
     ENDIF
     IF (findstring("REGION_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].region_cd = e.region_cd
     ENDIF
     IF (findstring("REG_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].reg_dt_tm = e.reg_dt_tm
     ENDIF
     IF (findstring("REG_PRSNL_ID,",chg_str)=0)
      acm_request->encounter_qual[idx].reg_prsnl_id = e.reg_prsnl_id
     ENDIF
     IF (findstring("RESULT_DEST_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].result_dest_cd = e.result_dest_cd
     ENDIF
     IF (findstring("SAFEKEEPING_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].safekeeping_cd = e.safekeeping_cd
     ENDIF
     IF (findstring("SECURITY_ACCESS_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].security_access_cd = e.security_access_cd
     ENDIF
     IF (findstring("SERVICE_CATEGORY_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].service_category_cd = e.service_category_cd
     ENDIF
     IF (findstring("SITTER_REQUIRED_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].sitter_required_cd = e.sitter_required_cd
     ENDIF
     IF (findstring("SPECIALTY_UNIT_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].specialty_unit_cd = e.specialty_unit_cd
     ENDIF
     IF (findstring("SPECIES_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].species_cd = e.species_cd
     ENDIF
     IF (findstring("TRAUMA_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].trauma_cd = e.trauma_cd
     ENDIF
     IF (findstring("TRAUMA_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].trauma_dt_tm = e.trauma_dt_tm
     ENDIF
     IF (findstring("TRIAGE_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].triage_cd = e.triage_cd
     ENDIF
     IF (findstring("TRIAGE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].triage_dt_tm = e.triage_dt_tm
     ENDIF
     IF (findstring("VALUABLES_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].valuables_cd = e.valuables_cd
     ENDIF
     IF (findstring("VIP_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].vip_cd = e.vip_cd
     ENDIF
     IF (findstring("VISITOR_STATUS_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].visitor_status_cd = e.visitor_status_cd
     ENDIF
     IF (findstring("ZERO_BALANCE_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].zero_balance_dt_tm = e.zero_balance_dt_tm
     ENDIF
     IF (findstring("MENTAL_CATEGORY_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].mental_category_cd = e.mental_category_cd
     ENDIF
     IF (findstring("PATIENT_CLASSIFICATION_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].patient_classification_cd = e.patient_classification_cd
     ENDIF
     IF (findstring("PSYCHIATRIC_STATUS_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].psychiatric_status_cd = e.psychiatric_status_cd
     ENDIF
     IF (findstring("INPATIENT_ADMIT_DT_TM,",chg_str)=0)
      acm_request->encounter_qual[idx].inpatient_admit_dt_tm = e.inpatient_admit_dt_tm
     ENDIF
     IF (findstring("ACTIVE_IND,",chg_str)=0)
      acm_request->encounter_qual[idx].active_ind = e.active_ind
     ENDIF
     IF (findstring("ACTIVE_STATUS_CD,",chg_str)=0)
      acm_request->encounter_qual[idx].active_status_cd = e.active_status_cd
     ENDIF
     IF (((findstring("ACTIVE_IND,",chg_str) != 0) OR (findstring("ACTIVE_STATUS_CD,",chg_str) != 0
     )) )
      active_status_prsnl_id = reqinfo->updt_id, active_status_dt_tm = cnvtdatetime(sysdate)
     ELSE
      active_status_prsnl_id = e.active_status_prsnl_id, active_status_dt_tm = cnvtdatetime(e
       .active_status_dt_tm)
     ENDIF
    WITH nocounter, forupdatewait(e), time = 5
   ;end select
   IF (failed)
    SET table_name = "ENCOUNTER"
    GO TO exit_script
   ENDIF
   FOR (index = f_val TO t_val)
     IF ((reply->encounter_qual[xref->chg[index].idx].status=0))
      SET failed = select_error
      SET table_name = "ENCOUNTER"
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF (failed)
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
