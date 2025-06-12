CREATE PROGRAM acm_chg_person_patient:dba
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
   SET reply->person_patient_qual[xref->chg[index].idx].status = 0
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
   person_patient p
  SET p.person_id = acm_request->person_patient_qual[xref->chg[d.seq].idx].person_id, p.adopted_cd =
   acm_request->person_patient_qual[xref->chg[d.seq].idx].adopted_cd, p.bad_debt_cd = acm_request->
   person_patient_qual[xref->chg[d.seq].idx].bad_debt_cd,
   p.birth_length = acm_request->person_patient_qual[xref->chg[d.seq].idx].birth_length, p
   .birth_length_units_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   birth_length_units_cd, p.birth_multiple_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx
   ].birth_multiple_cd,
   p.birth_name = acm_request->person_patient_qual[xref->chg[d.seq].idx].birth_name, p.birth_order =
   acm_request->person_patient_qual[xref->chg[d.seq].idx].birth_order, p.birth_weight = acm_request->
   person_patient_qual[xref->chg[d.seq].idx].birth_weight,
   p.callback_consent_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].callback_consent_cd,
   p.church_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].church_cd, p.contact_list_cd
    = acm_request->person_patient_qual[xref->chg[d.seq].idx].contact_list_cd,
   p.contact_method_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].contact_method_cd, p
   .contact_time = acm_request->person_patient_qual[xref->chg[d.seq].idx].contact_time, p
   .contributor_system_cd =
   IF ((acm_request->person_patient_qual[xref->chg[d.seq].idx].contributor_system_cd > 0.0))
    acm_request->person_patient_qual[xref->chg[d.seq].idx].contributor_system_cd
   ELSE pmhc_contributory_system_cd
   ENDIF
   ,
   p.credit_hrs_taking = acm_request->person_patient_qual[xref->chg[d.seq].idx].credit_hrs_taking, p
   .cumm_leave_days = acm_request->person_patient_qual[xref->chg[d.seq].idx].cumm_leave_days, p
   .current_balance = acm_request->person_patient_qual[xref->chg[d.seq].idx].current_balance,
   p.current_grade = acm_request->person_patient_qual[xref->chg[d.seq].idx].current_grade, p
   .custody_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].custody_cd, p
   .degree_complete_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].degree_complete_cd,
   p.diet_type_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].diet_type_cd, p
   .disease_alert_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].disease_alert_cd, p
   .family_income = acm_request->person_patient_qual[xref->chg[d.seq].idx].family_income,
   p.family_size = acm_request->person_patient_qual[xref->chg[d.seq].idx].family_size, p
   .highest_grade_complete_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   highest_grade_complete_cd, p.interp_required_cd = acm_request->person_patient_qual[xref->chg[d.seq
   ].idx].interp_required_cd,
   p.interp_type_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].interp_type_cd, p
   .last_bill_dt_tm =
   IF ((acm_request->person_patient_qual[xref->chg[d.seq].idx].last_bill_dt_tm > 0)) cnvtdatetime(
     acm_request->person_patient_qual[xref->chg[d.seq].idx].last_bill_dt_tm)
   ELSE null
   ENDIF
   , p.last_bind_dt_tm =
   IF ((acm_request->person_patient_qual[xref->chg[d.seq].idx].last_bind_dt_tm > 0)) cnvtdatetime(
     acm_request->person_patient_qual[xref->chg[d.seq].idx].last_bind_dt_tm)
   ELSE null
   ENDIF
   ,
   p.last_discharge_dt_tm =
   IF ((acm_request->person_patient_qual[xref->chg[d.seq].idx].last_discharge_dt_tm > 0))
    cnvtdatetime(acm_request->person_patient_qual[xref->chg[d.seq].idx].last_discharge_dt_tm)
   ELSE null
   ENDIF
   , p.last_event_updt_dt_tm =
   IF ((acm_request->person_patient_qual[xref->chg[d.seq].idx].last_event_updt_dt_tm > 0))
    cnvtdatetime(acm_request->person_patient_qual[xref->chg[d.seq].idx].last_event_updt_dt_tm)
   ELSE null
   ENDIF
   , p.last_payment_dt_tm =
   IF ((acm_request->person_patient_qual[xref->chg[d.seq].idx].last_payment_dt_tm > 0)) cnvtdatetime(
     acm_request->person_patient_qual[xref->chg[d.seq].idx].last_payment_dt_tm)
   ELSE null
   ENDIF
   ,
   p.last_trauma_dt_tm =
   IF ((acm_request->person_patient_qual[xref->chg[d.seq].idx].last_trauma_dt_tm > 0)) cnvtdatetime(
     acm_request->person_patient_qual[xref->chg[d.seq].idx].last_trauma_dt_tm)
   ELSE null
   ENDIF
   , p.living_arrangement_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   living_arrangement_cd, p.living_dependency_cd = acm_request->person_patient_qual[xref->chg[d.seq].
   idx].living_dependency_cd,
   p.living_will_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].living_will_cd, p
   .microfilm_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].microfilm_cd, p
   .mother_identifier = acm_request->person_patient_qual[xref->chg[d.seq].idx].mother_identifier,
   p.mother_identifier_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   mother_identifier_cd, p.nbr_of_brothers = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   nbr_of_brothers, p.nbr_of_pregnancies = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   nbr_of_pregnancies,
   p.nbr_of_sisters = acm_request->person_patient_qual[xref->chg[d.seq].idx].nbr_of_sisters, p
   .organ_donor_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].organ_donor_cd, p
   .parent_marital_status_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   parent_marital_status_cd,
   p.process_alert_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].process_alert_cd, p
   .smokes_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].smokes_cd, p.student_cd =
   acm_request->person_patient_qual[xref->chg[d.seq].idx].student_cd,
   p.tumor_registry_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].tumor_registry_cd, p
   .baptised_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].baptised_cd, p
   .gest_age_at_birth = acm_request->person_patient_qual[xref->chg[d.seq].idx].gest_age_at_birth,
   p.gest_age_method_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].gest_age_method_cd,
   p.written_format_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].written_format_cd, p
   .prev_contact_ind = acm_request->person_patient_qual[xref->chg[d.seq].idx].prev_contact_ind,
   p.birth_order_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].birth_order_cd, p
   .source_version_number = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   source_version_number, p.source_last_sync_dt_tm =
   IF ((acm_request->person_patient_qual[xref->chg[d.seq].idx].source_last_sync_dt_tm > 0))
    cnvtdatetime(acm_request->person_patient_qual[xref->chg[d.seq].idx].source_last_sync_dt_tm)
   ELSE null
   ENDIF
   ,
   p.beg_effective_dt_tm = cnvtdatetime(acm_request->person_patient_qual[xref->chg[d.seq].idx].
    beg_effective_dt_tm), p.end_effective_dt_tm = cnvtdatetime(acm_request->person_patient_qual[xref
    ->chg[d.seq].idx].end_effective_dt_tm), p.birth_sex_cd = acm_request->person_patient_qual[xref->
   chg[d.seq].idx].birth_sex_cd,
   p.source_sync_level_flag = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   source_sync_level_flag, p.active_ind = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   active_ind, p.active_status_cd = acm_request->person_patient_qual[xref->chg[d.seq].idx].
   active_status_cd,
   p.active_status_prsnl_id = active_status_prsnl_id, p.active_status_dt_tm = cnvtdatetime(
    active_status_dt_tm), p.updt_cnt = (p.updt_cnt+ 1),
   p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->
   updt_applctx,
   p.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=acm_request->person_patient_qual[xref->chg[d.seq].idx].person_id))
  WITH nocounter, status(reply->person_patient_qual[xref->chg[d.seq].idx].status)
 ;end update
 FOR (index = 1 TO xref->chg_cnt)
   IF ((reply->person_patient_qual[xref->chg[index].idx].status != 1))
    SET failed = update_error
    SET table_name = "PERSON_PATIENT"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (acm_hist_ind=1)
  EXECUTE acm_chg_person_patient_hist
  IF ((reply->status_data.status="F"))
   SET failed = true
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE getexistingrows(x)
   SELECT INTO "nl:"
    FROM person_patient p
    WHERE expand(t1,f_val,t_val,p.person_id,acm_request->person_patient_qual[xref->chg[t1].idx].
     person_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,p.person_id,acm_request->person_patient_qual[xref->chg[t1].idx].
      person_id,
      max_val), idx = xref->chg[t2].idx
     IF ((((p.updt_cnt=acm_request->person_patient_qual[idx].updt_cnt)) OR ((acm_request->
     force_updt_ind=1))) )
      reply->person_patient_qual[idx].status = - (1), reply->person_patient_qual[idx].person_id =
      acm_request->person_patient_qual[idx].person_id
     ELSE
      failed = update_cnt_error
     ENDIF
     chg_str = acm_request->person_patient_qual[idx].chg_str
     IF (findstring("ADOPTED_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].adopted_cd = p.adopted_cd
     ENDIF
     IF (findstring("BAD_DEBT_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].bad_debt_cd = p.bad_debt_cd
     ENDIF
     IF (findstring("BIRTH_LENGTH,",chg_str)=0)
      acm_request->person_patient_qual[idx].birth_length = p.birth_length
     ENDIF
     IF (findstring("BIRTH_LENGTH_UNITS_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].birth_length_units_cd = p.birth_length_units_cd
     ENDIF
     IF (findstring("BIRTH_MULTIPLE_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].birth_multiple_cd = p.birth_multiple_cd
     ENDIF
     IF (findstring("BIRTH_NAME,",chg_str)=0)
      acm_request->person_patient_qual[idx].birth_name = p.birth_name
     ENDIF
     IF (findstring("BIRTH_ORDER,",chg_str)=0)
      acm_request->person_patient_qual[idx].birth_order = p.birth_order
     ENDIF
     IF (findstring("BIRTH_WEIGHT,",chg_str)=0)
      acm_request->person_patient_qual[idx].birth_weight = p.birth_weight
     ENDIF
     IF (findstring("CALLBACK_CONSENT_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].callback_consent_cd = p.callback_consent_cd
     ENDIF
     IF (findstring("CHURCH_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].church_cd = p.church_cd
     ENDIF
     IF (findstring("CONTACT_LIST_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].contact_list_cd = p.contact_list_cd
     ENDIF
     IF (findstring("CONTACT_METHOD_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].contact_method_cd = p.contact_method_cd
     ENDIF
     IF (findstring("CONTACT_TIME,",chg_str)=0)
      acm_request->person_patient_qual[idx].contact_time = p.contact_time
     ENDIF
     IF (findstring("CONTRIBUTOR_SYSTEM_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].contributor_system_cd = p.contributor_system_cd
     ENDIF
     IF (findstring("CREDIT_HRS_TAKING,",chg_str)=0)
      acm_request->person_patient_qual[idx].credit_hrs_taking = p.credit_hrs_taking
     ENDIF
     IF (findstring("CUMM_LEAVE_DAYS,",chg_str)=0)
      acm_request->person_patient_qual[idx].cumm_leave_days = p.cumm_leave_days
     ENDIF
     IF (findstring("CURRENT_BALANCE,",chg_str)=0)
      acm_request->person_patient_qual[idx].current_balance = p.current_balance
     ENDIF
     IF (findstring("CURRENT_GRADE,",chg_str)=0)
      acm_request->person_patient_qual[idx].current_grade = p.current_grade
     ENDIF
     IF (findstring("CUSTODY_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].custody_cd = p.custody_cd
     ENDIF
     IF (findstring("DEGREE_COMPLETE_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].degree_complete_cd = p.degree_complete_cd
     ENDIF
     IF (findstring("DIET_TYPE_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].diet_type_cd = p.diet_type_cd
     ENDIF
     IF (findstring("DISEASE_ALERT_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].disease_alert_cd = p.disease_alert_cd
     ENDIF
     IF (findstring("FAMILY_INCOME,",chg_str)=0)
      acm_request->person_patient_qual[idx].family_income = p.family_income
     ENDIF
     IF (findstring("FAMILY_SIZE,",chg_str)=0)
      acm_request->person_patient_qual[idx].family_size = p.family_size
     ENDIF
     IF (findstring("HIGHEST_GRADE_COMPLETE_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].highest_grade_complete_cd = p.highest_grade_complete_cd
     ENDIF
     IF (findstring("INTERP_REQUIRED_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].interp_required_cd = p.interp_required_cd
     ENDIF
     IF (findstring("INTERP_TYPE_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].interp_type_cd = p.interp_type_cd
     ENDIF
     IF (findstring("LAST_BILL_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].last_bill_dt_tm = p.last_bill_dt_tm
     ENDIF
     IF (findstring("LAST_BIND_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].last_bind_dt_tm = p.last_bind_dt_tm
     ENDIF
     IF (findstring("LAST_DISCHARGE_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].last_discharge_dt_tm = p.last_discharge_dt_tm
     ENDIF
     IF (findstring("LAST_EVENT_UPDT_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].last_event_updt_dt_tm = p.last_event_updt_dt_tm
     ENDIF
     IF (findstring("LAST_PAYMENT_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].last_payment_dt_tm = p.last_payment_dt_tm
     ENDIF
     IF (findstring("LAST_TRAUMA_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].last_trauma_dt_tm = p.last_trauma_dt_tm
     ENDIF
     IF (findstring("LIVING_ARRANGEMENT_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].living_arrangement_cd = p.living_arrangement_cd
     ENDIF
     IF (findstring("LIVING_DEPENDENCY_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].living_dependency_cd = p.living_dependency_cd
     ENDIF
     IF (findstring("LIVING_WILL_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].living_will_cd = p.living_will_cd
     ENDIF
     IF (findstring("MICROFILM_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].microfilm_cd = p.microfilm_cd
     ENDIF
     IF (findstring("MOTHER_IDENTIFIER,",chg_str)=0)
      acm_request->person_patient_qual[idx].mother_identifier = p.mother_identifier
     ENDIF
     IF (findstring("MOTHER_IDENTIFIER_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].mother_identifier_cd = p.mother_identifier_cd
     ENDIF
     IF (findstring("NBR_OF_BROTHERS,",chg_str)=0)
      acm_request->person_patient_qual[idx].nbr_of_brothers = p.nbr_of_brothers
     ENDIF
     IF (findstring("NBR_OF_PREGNANCIES,",chg_str)=0)
      acm_request->person_patient_qual[idx].nbr_of_pregnancies = p.nbr_of_pregnancies
     ENDIF
     IF (findstring("NBR_OF_SISTERS,",chg_str)=0)
      acm_request->person_patient_qual[idx].nbr_of_sisters = p.nbr_of_sisters
     ENDIF
     IF (findstring("ORGAN_DONOR_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].organ_donor_cd = p.organ_donor_cd
     ENDIF
     IF (findstring("PARENT_MARITAL_STATUS_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].parent_marital_status_cd = p.parent_marital_status_cd
     ENDIF
     IF (findstring("PROCESS_ALERT_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].process_alert_cd = p.process_alert_cd
     ENDIF
     IF (findstring("SMOKES_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].smokes_cd = p.smokes_cd
     ENDIF
     IF (findstring("STUDENT_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].student_cd = p.student_cd
     ENDIF
     IF (findstring("TUMOR_REGISTRY_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].tumor_registry_cd = p.tumor_registry_cd
     ENDIF
     IF (findstring("BAPTISED_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].baptised_cd = p.baptised_cd
     ENDIF
     IF (findstring("GEST_AGE_AT_BIRTH,",chg_str)=0)
      acm_request->person_patient_qual[idx].gest_age_at_birth = p.gest_age_at_birth
     ENDIF
     IF (findstring("GEST_AGE_METHOD_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].gest_age_method_cd = p.gest_age_method_cd
     ENDIF
     IF (findstring("WRITTEN_FORMAT_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].written_format_cd = p.written_format_cd
     ENDIF
     IF (findstring("PREV_CONTACT_IND,",chg_str)=0)
      acm_request->person_patient_qual[idx].prev_contact_ind = p.prev_contact_ind
     ENDIF
     IF (findstring("BIRTH_ORDER_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].birth_order_cd = p.birth_order_cd
     ENDIF
     IF (findstring("SOURCE_VERSION_NUMBER,",chg_str)=0)
      acm_request->person_patient_qual[idx].source_version_number = p.source_version_number
     ENDIF
     IF (findstring("SOURCE_LAST_SYNC_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].source_last_sync_dt_tm = p.source_last_sync_dt_tm
     ENDIF
     IF (findstring("BEG_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].beg_effective_dt_tm = p.beg_effective_dt_tm
     ENDIF
     IF (findstring("END_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->person_patient_qual[idx].end_effective_dt_tm = p.end_effective_dt_tm
     ENDIF
     IF (findstring("BIRTH_SEX_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].birth_sex_cd = p.birth_sex_cd
     ENDIF
     IF (findstring("SOURCE_SYNC_LEVEL_FLAG,",chg_str)=0)
      acm_request->person_patient_qual[idx].source_sync_level_flag = p.source_sync_level_flag
     ENDIF
     IF (findstring("ACTIVE_IND,",chg_str)=0)
      acm_request->person_patient_qual[idx].active_ind = p.active_ind
     ENDIF
     IF (findstring("ACTIVE_STATUS_CD,",chg_str)=0)
      acm_request->person_patient_qual[idx].active_status_cd = p.active_status_cd
     ENDIF
     IF (((findstring("ACTIVE_IND,",chg_str) != 0) OR (findstring("ACTIVE_STATUS_CD,",chg_str) != 0
     )) )
      active_status_prsnl_id = reqinfo->updt_id, active_status_dt_tm = cnvtdatetime(sysdate)
     ELSE
      active_status_prsnl_id = p.active_status_prsnl_id, active_status_dt_tm = cnvtdatetime(p
       .active_status_dt_tm)
     ENDIF
    WITH nocounter, forupdatewait(p), time = 5
   ;end select
   IF (failed)
    SET table_name = "PERSON_PATIENT"
    GO TO exit_script
   ENDIF
   FOR (index = f_val TO t_val)
     IF ((reply->person_patient_qual[xref->chg[index].idx].status=0))
      SET failed = select_error
      SET table_name = "PERSON_PATIENT"
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
