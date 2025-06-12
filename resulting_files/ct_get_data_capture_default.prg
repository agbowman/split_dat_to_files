CREATE PROGRAM ct_get_data_capture_default
 CALL echorecord(request)
 FREE RECORD ct_request
 RECORD ct_request(
   1 person_id = f8
   1 prot_master_id = f8
   1 encounter_id = f8
   1 con_med_time = f8
   1 con_med_unit_cd = f8
   1 condition_time = f8
   1 condition_unit_cd = f8
   1 organization_id = f8
 )
 FREE RECORD ct_reply
 RECORD ct_reply(
   1 subject_number = vc
   1 birth_dt_tm = dq8
   1 birth_dt_tz = i4
   1 sex_cd = f8
   1 sex_disp = c50
   1 sex_desc = c50
   1 sex_mean = c12
   1 race_cd = f8
   1 race_disp = c50
   1 race_desc = c50
   1 race_mean = c12
   1 ethnicity_cd = f8
   1 ethnicity_disp = c50
   1 ethnicity_desc = c50
   1 ethnicity_mean = c12
   1 consent_dt_tm = dq8
   1 on_study_dt_tm = dq8
   1 off_study_dt_tm = dq8
   1 off_treatment_dt_tm = dq8
   1 current_amendment_nbr = i4
   1 current_revision_nbr = vc
   1 original_amendment_nbr = i4
   1 original_revision_nbr = vc
   1 event_group[*]
     2 parent_event_alias = vc
     2 performed_person_id = f8
     2 performed_person = vc
     2 performed_dt_tm = dq8
     2 performed_tz = i4
     2 events[*]
       3 event_name = vc
       3 event_cd = f8
       3 event_status_cd = f8
       3 event_alias = vc
       3 event_value = vc
       3 event_unit = vc
       3 event_dt_tm = dq8
       3 event_tz = i4
       3 event_result_type = i2
       3 event_task_person_id = f8
       3 event_task_person = vc
       3 performed_person_id = f8
       3 performed_person = vc
       3 performed_dt_tm = dq8
       3 performed_tz = i4
   1 aes[*]
     2 ae_model_name = c20
     2 ae_id = f8
     2 ae_sub_id = f8
     2 description = vc
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 onset_prec_flag = i2
     2 resolved_prec_flag = i2
     2 resolved_dt_tm = dq8
     2 resolved_tz = i4
     2 ongoing_ind = i2
     2 serious_ind = i2
     2 severity_category = f8
     2 severity_flag = vc
     2 reaction = vc
     2 outcome = vc
     2 performed_person_id = f8
     2 performed_dt_tm = dq8
     2 performed_tz = i4
     2 performed_person = vc
   1 conmeds[*]
     2 med_name = vc
     2 med_dose = vc
     2 med_dose_unit = vc
     2 med_dose_unit_cd = f8
     2 med_frequency = vc
     2 med_frequency_cd = f8
     2 med_route_cd = f8
     2 med_route = vc
     2 med_form_cd = f8
     2 med_form = vc
     2 med_start_dt_tm = dq8
     2 med_start_tz = i4
     2 med_end_val = i2
     2 med_end_dt_tm = dq8
     2 med_end_tz = i4
     2 order_id = f8
     2 performed_person_id = f8
     2 performed_person = vc
     2 performed_dt_tm = dq8
     2 performed_tz = i4
   1 protocol_name = vc
   1 location_id = f8
   1 location_name = vc
   1 user_id = f8
   1 user_name = vc
   1 principal_investigator_id = f8
   1 principal_investigator_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getcodedvalue(code_value=vc) = vc
 SUBROUTINE getcodedvalue(code_value)
   DECLARE coded_value = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=cnvtreal(code_value))
    DETAIL
     IF (size(trim(cv.concept_cki),1) > 0)
      coded_value = cv.concept_cki
     ELSEIF (size(trim(cv.cki),1) > 0)
      coded_value = cv.cki
     ELSEIF (size(trim(cv.cdf_meaning),1) > 0)
      coded_value = cv.cdf_meaning
     ELSEIF (size(trim(cv.display),1) > 0)
      coded_value = cv.display
     ENDIF
    WITH nocounter
   ;end select
   RETURN(coded_value)
 END ;Subroutine
 DECLARE visit_num = i2 WITH protect, noconstant(0)
 DECLARE encntr_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE temp_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE vital_cnt = i2 WITH protect, noconstant(0)
 DECLARE vital_grp_cnt = i2 WITH protect, noconstant(0)
 DECLARE item_group_cnt = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE grp_idx = i2 WITH protect, noconstant(0)
 DECLARE vital_idx = i2 WITH protect, noconstant(0)
 DECLARE ae_idx = i2 WITH protect, noconstant(0)
 DECLARE ae_cnt = i2 WITH protect, noconstant(0)
 DECLARE cm_idx = i2 WITH protect, noconstant(0)
 DECLARE cm_cnt = i2 WITH protect, noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("S")
 DECLARE failuremsg = vc WITH protect, noconstant("")
 DECLARE audit_record_id = vc WITH protect, noconstant("")
 DECLARE fm_common = i2 WITH protect, constant(1)
 DECLARE cdash_dm = i2 WITH protect, constant(2)
 DECLARE cdash_sv = i2 WITH protect, constant(3)
 DECLARE cdash_ds = i2 WITH protect, constant(4)
 DECLARE cdash_vs = i2 WITH protect, noconstant(0)
 DECLARE cdash_ae = i2 WITH protect, noconstant(0)
 DECLARE cdash_cm = i2 WITH protect, noconstant(0)
 DECLARE cdash_ce = i2 WITH protect, noconstant(0)
 DECLARE total_forms = i2 WITH protect, noconstant(0)
 DECLARE hr_type = i2 WITH protect, constant(1)
 DECLARE diabp_type = i2 WITH protect, constant(2)
 DECLARE sysbp_type = i2 WITH protect, constant(3)
 DECLARE audit_record_idx = i4 WITH protect, noconstant(0)
 DECLARE item_group_repeat_key = i4 WITH protect, noconstant(0)
 DECLARE getnextitemauditrecord(itemidx=12) = vc WITH protect
 DECLARE formatisodate(datetime=f8,timezone=i4,precisionflag=i2) = vc WITH protect
 DECLARE build_vitals_form(subject_idx=i4,study_event_idx=i4,form_idx=i4,item_grp_idx=i4,vitals_idx=
  i4,
  type_flag=i2) = null
 DECLARE build_ce_item_group(subject_idx=i4,study_event_idx=i4,form_idx=i4,item_grp_idx=i4,
  event_group_idx=i4) = null
 DECLARE get_person_name_by_id(id=f8) = vc
 SUBROUTINE get_person_name_by_id(id)
   DECLARE personname = vc WITH protect
   SELECT INTO "nl:"
    FROM person p
    PLAN (p
     WHERE p.person_id=id)
    HEAD p.person_id
     personname = p.name_full_formatted
    WITH nocounter
   ;end select
   RETURN(personname)
 END ;Subroutine
 SET ct_request->person_id = request->person[1].person_id
 IF (size(request->person[1].visits,5) > 0)
  SET ct_request->encounter_id = request->person[1].visits[1].encntr_id
  SET visit_num = request->person[1].visits[1].visit_num
  SET encntr_dt_tm = request->person[1].visits[1].encntr_dt_tm
 ENDIF
 SET ct_request->prot_master_id = request->prot_master_id
 SET ct_request->con_med_time = request->con_med_time
 SET ct_request->con_med_unit_cd = request->con_med_unit_cd
 SET ct_request->condition_time = request->condition_time
 SET ct_request->condition_unit_cd = request->condition_unit_cd
 SET trace = recpersist
 EXECUTE ct_get_pt_data_capture_info  WITH replace("REQUEST","CT_REQUEST"), replace("REPLY",
  "CT_REPLY")
 IF ((ct_reply->status_data.status != "S"))
  SET cfailed = ct_reply->status_data.status
  SET failuremsg = ct_reply->status_data.subeventstatus[1].targetobjectvalue
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->subject_data,1)
 SET reply->subject_data[1].subject_key = ct_reply->subject_number
 SET stat = alterlist(reply->subject_data[1].study_event_data,1)
 SET reply->subject_data[1].study_event_data[1].study_event_oid = "StudyEventOID"
 SET reply->subject_data[1].study_event_data[1].audit_user_oid = ct_reply->user_name
 SET reply->subject_data[1].study_event_data[1].audit_location_oid = request->site_ident
 SET total_forms = 4
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data,total_forms)
 SET reply->subject_data[1].study_event_data[1].form_data[fm_common].form_oid = "FM_COMMON"
 SET idx = 1
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[fm_common].item_group_data,
  idx)
 SET reply->subject_data[1].study_event_data[1].form_data[fm_common].item_group_data[idx].
 item_group_oid = "IG_COMMON"
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[fm_common].
  item_group_data[idx].item_data,5)
 SET curalias item_data_struct reply->subject_data[1].study_event_data[1].form_data[fm_common].
 item_group_data[idx].item_data[x]
 FOR (x = 1 TO 5)
  IF (x=1)
   SET item_data_struct->item_oid = "STUDYID"
   SET item_data_struct->value = request->study_ident
  ELSEIF (x=2)
   SET item_data_struct->item_oid = "SUBJID"
   SET item_data_struct->value = ct_reply->subject_number
  ELSEIF (x=3)
   SET item_data_struct->item_oid = "USUBJID"
   SET item_data_struct->value = ct_reply->subject_number
  ELSEIF (x=4)
   SET item_data_struct->item_oid = "SITENO"
   SET item_data_struct->value = request->site_ident
  ELSEIF (x=5)
   SET item_data_struct->item_oid = "VISIT"
   SET item_data_struct->value = format(visit_num,"V##;P0")
  ENDIF
  SET item_data_struct->item_type = "ItemDataString"
 ENDFOR
 SET curalias item_data_struct off
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data,cdash_dm)
 SET reply->subject_data[1].study_event_data[1].form_data[cdash_dm].form_oid = "FM_DM"
 SET idx = 1
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_dm].item_group_data,
  idx)
 SET reply->subject_data[1].study_event_data[1].form_data[cdash_dm].item_group_data[idx].
 item_group_oid = "IG_DM"
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_dm].item_group_data[
  idx].item_data,11)
 SET curalias item_data_struct reply->subject_data[1].study_event_data[1].form_data[cdash_dm].
 item_group_data[idx].item_data[x]
 FOR (x = 1 TO 11)
   IF (x=1)
    SET item_data_struct->item_oid = "DOMAIN"
    SET item_data_struct->item_type = "ItemDataString"
    SET item_data_struct->value = "DM"
   ELSEIF (x=2)
    SET item_data_struct->item_oid = "SEX"
    SET item_data_struct->item_type = "ItemDataString"
    IF ((ct_reply->sex_cd > 0.0))
     SET item_data_struct->value = getcodedvalue(ct_reply->sex_cd)
    ENDIF
   ELSEIF (x=3)
    SET item_data_struct->item_oid = "SEXDISP"
    SET item_data_struct->item_type = "ItemDataString"
    IF ((ct_reply->sex_cd > 0.0))
     SET item_data_struct->value = uar_get_code_display(ct_reply->sex_cd)
    ENDIF
   ELSEIF (x=4)
    SET item_data_struct->item_oid = "RACE"
    SET item_data_struct->item_type = "ItemDataString"
    IF ((ct_reply->race_cd > 0.0))
     SET item_data_struct->value = getcodedvalue(ct_reply->race_cd)
    ENDIF
   ELSEIF (x=5)
    SET item_data_struct->item_oid = "RACEDISP"
    SET item_data_struct->item_type = "ItemDataString"
    IF ((ct_reply->race_cd > 0.0))
     SET item_data_struct->value = uar_get_code_display(ct_reply->race_cd)
    ENDIF
   ELSEIF (x=6)
    SET item_data_struct->item_oid = "BRTHDTC"
    SET item_data_struct->item_type = "ItemDataDatetime"
    SET item_data_struct->value = formatisodate(ct_reply->birth_dt_tm,ct_reply->birth_dt_tz,0)
   ELSEIF (x=7)
    SET item_data_struct->item_oid = "BRTHDY"
    SET item_data_struct->item_type = "ItemDataInteger"
    SET item_data_struct->value = build(day(ct_reply->birth_dt_tm))
   ELSEIF (x=8)
    SET item_data_struct->item_oid = "BRTHMO"
    SET item_data_struct->item_type = "ItemDataInteger"
    SET item_data_struct->value = build(month(ct_reply->birth_dt_tm))
   ELSEIF (x=9)
    SET item_data_struct->item_oid = "BRTHYR"
    SET item_data_struct->item_type = "ItemDataInteger"
    SET item_data_struct->value = build(year(ct_reply->birth_dt_tm))
   ELSEIF (x=10)
    SET item_data_struct->item_oid = "ETHNIC"
    SET item_data_struct->item_type = "ItemDataString"
    IF ((ct_reply->ethnicity_cd > 0.0))
     SET item_data_struct->value = getcodedvalue(ct_reply->ethnicity_cd)
    ENDIF
   ELSEIF (x=11)
    SET item_data_struct->item_oid = "ETHNICDISP"
    SET item_data_struct->item_type = "ItemDataString"
    IF ((ct_reply->ethnicity_cd > 0.0))
     SET item_data_struct->value = uar_get_code_display(ct_reply->ethnicity_cd)
    ENDIF
   ENDIF
 ENDFOR
 SET curalias item_data_struct off
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data,cdash_sv)
 SET reply->subject_data[1].study_event_data[1].form_data[cdash_sv].form_oid = "FM_SV"
 SET idx = 1
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_sv].item_group_data,
  idx)
 SET reply->subject_data[1].study_event_data[1].form_data[cdash_sv].item_group_data[idx].
 item_group_oid = "IG_SV"
 SET reply->subject_data[1].study_event_data[1].form_data[cdash_sv].item_group_data[idx].
 item_group_repeat_key = "1"
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_sv].item_group_data[
  idx].item_data,3)
 SET curalias item_data_struct reply->subject_data[1].study_event_data[1].form_data[cdash_sv].
 item_group_data[idx].item_data[x]
 FOR (x = 1 TO 3)
   IF (x=1)
    SET item_data_struct->item_oid = "DOMAIN"
    SET item_data_struct->item_type = "ItemDataString"
    SET item_data_struct->value = "SV"
   ELSEIF (x=2)
    SET item_data_struct->item_oid = "SVSEQ"
    SET item_data_struct->item_type = "ItemDataString"
    SET item_data_struct->value = build(visit_num)
   ELSE
    SET item_data_struct->item_oid = "SVSTDTC"
    SET item_data_struct->item_type = "ItemDataDatetime"
    SET item_data_struct->value = formatisodate(encntr_dt_tm,datetimezonebyname(curtimezone),0)
   ENDIF
 ENDFOR
 SET curalias item_data_struct off
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data,cdash_ds)
 SET reply->subject_data[1].study_event_data[1].form_data[cdash_ds].form_oid = "FM_DS"
 SET idx = 1
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_ds].item_group_data,
  idx)
 SET reply->subject_data[1].study_event_data[1].form_data[cdash_ds].item_group_data[idx].
 item_group_oid = "IG_DS"
 SET reply->subject_data[1].study_event_data[1].form_data[cdash_ds].item_group_data[idx].
 item_group_repeat_key = "1"
 SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_ds].item_group_data[
  idx].item_data,9)
 SET curalias item_data_struct reply->subject_data[1].study_event_data[1].form_data[cdash_ds].
 item_group_data[idx].item_data[x]
 FOR (x = 1 TO 9)
   IF (x=1)
    SET item_data_struct->item_oid = "DOMAIN"
    SET item_data_struct->item_type = "ItemDataString"
    SET item_data_struct->value = "DS"
   ELSEIF (x=2)
    SET item_data_struct->item_oid = "DSSTDTC"
    SET item_data_struct->item_type = "ItemDataDatetime"
    SET item_data_struct->value = formatisodate(ct_reply->on_study_dt_tm,datetimezonebyname(
      curtimezone),0)
   ELSEIF (x=3)
    SET item_data_struct->item_oid = "OFFSTUDYDTTM"
    SET item_data_struct->item_type = "ItemDataDatetime"
    SET item_data_struct->value = formatisodate(ct_reply->off_study_dt_tm,datetimezonebyname(
      curtimezone),0)
   ELSEIF (x=4)
    SET item_data_struct->item_oid = "OFFTXDTTM"
    SET item_data_struct->item_type = "ItemDataDatetime"
    SET item_data_struct->value = formatisodate(ct_reply->off_treatment_dt_tm,datetimezonebyname(
      curtimezone),0)
   ELSEIF (x=5)
    SET item_data_struct->item_oid = "CONSENTDTTM"
    SET item_data_struct->item_type = "ItemDataDatetime"
    SET item_data_struct->value = formatisodate(ct_reply->consent_dt_tm,datetimezonebyname(
      curtimezone),0)
   ELSEIF (x=6)
    SET item_data_struct->item_oid = "ORIGAMD"
    SET item_data_struct->item_type = "ItemDataString"
    SET item_data_struct->value = build(ct_reply->original_amendment_nbr)
   ELSEIF (x=7)
    SET item_data_struct->item_oid = "CURRAMD"
    SET item_data_struct->item_type = "ItemDataString"
    SET item_data_struct->value = build(ct_reply->current_amendment_nbr)
   ELSEIF (x=8)
    SET item_data_struct->item_oid = "ORIGREV"
    SET item_data_struct->item_type = "ItemDataString"
    SET item_data_struct->value = ct_reply->original_revision_nbr
   ELSEIF (x=9)
    SET item_data_struct->item_oid = "CURRREV"
    SET item_data_struct->item_type = "ItemDataString"
    SET item_data_struct->value = ct_reply->current_revision_nbr
   ENDIF
 ENDFOR
 SET curalias item_data_struct off
 SET event_cnt = size(ct_reply->event_group,5)
 IF (event_cnt > 0)
  SET total_forms = (total_forms+ 1)
  SET cdash_ce = total_forms
  SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data,total_forms)
  SET reply->subject_data[1].study_event_data[1].form_data[cdash_ce].form_oid = "FM_CE"
  SET group_idx = 1
  DECLARE ce_item_grp_cnt = i4 WITH protect, noconstant(0)
  FOR (group_idx = 1 TO event_cnt)
    SET ce_item_grp_cnt = (ce_item_grp_cnt+ 1)
    SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_ce].
     item_group_data,ce_item_grp_cnt)
    CALL build_ce_item_group(1,1,cdash_ce,ce_item_grp_cnt,group_idx)
  ENDFOR
 ENDIF
 SET ae_cnt = size(ct_reply->aes,5)
 IF (ae_cnt > 0)
  SET total_forms = (total_forms+ 1)
  SET cdash_ae = total_forms
  SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data,total_forms)
  SET reply->subject_data[1].study_event_data[1].form_data[cdash_ae].form_oid = "FM_AE"
  SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_ae].item_group_data,
   ae_cnt)
  SET ae_idx = 0
  SET grp_idx = idx
  FOR (ae_idx = 1 TO ae_cnt)
    SET reply->subject_data[1].study_event_data[1].form_data[cdash_ae].item_group_data[ae_idx].
    item_group_oid = "AE"
    SET reply->subject_data[1].study_event_data[1].form_data[cdash_ae].item_group_data[ae_idx].
    item_group_repeat_key = build(ae_idx)
    SET reply->subject_data[1].study_event_data[1].form_data[cdash_ae].item_group_data[ae_idx].
    audit_performed_by = ct_reply->aes[ae_idx].performed_person
    SET reply->subject_data[1].study_event_data[1].form_data[cdash_ae].item_group_data[ae_idx].
    audit_performed_timestamp = formatisodate(ct_reply->aes[ae_idx].performed_dt_tm,ct_reply->aes[
     ae_idx].performed_tz,0)
    SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_ae].
     item_group_data[ae_idx].item_data,13)
    SET curalias item_data_struct reply->subject_data[1].study_event_data[1].form_data[cdash_ae].
    item_group_data[ae_idx].item_data[x]
    FOR (x = 1 TO 13)
      IF (x=1)
       SET item_data_struct->item_oid = "DOMAIN"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = "AE"
      ELSEIF (x=2)
       SET item_data_struct->item_oid = "AESTAT"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = "DONE"
      ELSEIF (x=3)
       SET item_data_struct->item_oid = "AEGRPID"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = build(ae_idx)
      ELSEIF (x=4)
       SET item_data_struct->item_oid = "AESEQ"
       SET item_data_struct->item_type = "ItemDataInteger"
       SET item_data_struct->value = build(ae_idx)
      ELSEIF (x=5)
       SET item_data_struct->item_oid = "AETERM"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->aes[ae_idx].description
      ELSEIF (x=6)
       SET item_data_struct->item_oid = "AESEV"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->aes[ae_idx].severity_flag
      ELSEIF (x=7)
       SET item_data_struct->item_oid = "AESTDTC"
       SET item_data_struct->item_type = "ItemDataDatetime"
       SET item_data_struct->value = formatisodate(ct_reply->aes[ae_idx].onset_dt_tm,ct_reply->aes[
        ae_idx].onset_tz,ct_reply->aes[ae_idx].onset_prec_flag)
      ELSEIF (x=8)
       SET item_data_struct->item_oid = "AEENDDTC"
       SET item_data_struct->item_type = "ItemDataDatetime"
       SET item_data_struct->value = formatisodate(ct_reply->aes[ae_idx].resolved_dt_tm,ct_reply->
        aes[ae_idx].resolved_tz,ct_reply->aes[ae_idx].resolved_prec_flag)
      ELSEIF (x=9)
       SET item_data_struct->item_oid = "AEONGO"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = build(ct_reply->aes[ae_idx].ongoing_ind)
      ELSEIF (x=10)
       SET item_data_struct->item_oid = "AESEVCODE"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = getcodedvalue(ct_reply->aes[ae_idx].severity_category)
      ELSEIF (x=11)
       SET item_data_struct->item_oid = "AESEVDISP"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = uar_get_code_display(ct_reply->aes[ae_idx].severity_category)
      ELSEIF (x=12)
       SET item_data_struct->item_oid = "AEOUT"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->aes[ae_idx].outcome
      ELSEIF (x=13)
       SET item_data_struct->item_oid = "AEREACTION"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->aes[ae_idx].reaction
      ENDIF
    ENDFOR
    SET curalias item_data_struct off
  ENDFOR
 ENDIF
 SET cm_cnt = size(ct_reply->conmeds,5)
 IF (cm_cnt > 0)
  SET total_forms = (total_forms+ 1)
  SET cdash_cm = total_forms
  SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data,total_forms)
  SET reply->subject_data[1].study_event_data[1].form_data[cdash_cm].form_oid = "FM_CM"
  SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_cm].item_group_data,
   cm_cnt)
  FOR (cm_idx = 1 TO cm_cnt)
    SET reply->subject_data[1].study_event_data[1].form_data[cdash_cm].item_group_data[cm_idx].
    item_group_oid = "CM"
    SET reply->subject_data[1].study_event_data[1].form_data[cdash_cm].item_group_data[cm_idx].
    item_group_repeat_key = build(cm_idx)
    SET reply->subject_data[1].study_event_data[1].form_data[cdash_cm].item_group_data[cm_idx].
    audit_performed_by = ct_reply->conmeds[cm_idx].performed_person
    SET reply->subject_data[1].study_event_data[1].form_data[cdash_cm].item_group_data[cm_idx].
    audit_performed_timestamp = formatisodate(ct_reply->conmeds[cm_idx].performed_dt_tm,ct_reply->
     conmeds[cm_idx].performed_tz,0)
    SET stat = alterlist(reply->subject_data[1].study_event_data[1].form_data[cdash_cm].
     item_group_data[cm_idx].item_data,14)
    SET curalias item_data_struct reply->subject_data[1].study_event_data[1].form_data[cdash_cm].
    item_group_data[cm_idx].item_data[x]
    FOR (x = 1 TO 14)
      IF (x=1)
       SET item_data_struct->item_oid = "DOMAIN"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = "CM"
      ELSEIF (x=2)
       SET item_data_struct->item_oid = "CMTRT"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->conmeds[cm_idx].med_name
      ELSEIF (x=3)
       SET item_data_struct->item_oid = "CMDSTXT"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->conmeds[cm_idx].med_dose
      ELSEIF (x=4)
       SET item_data_struct->item_oid = "CMDOSUCODE"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = getcodedvalue(ct_reply->conmeds[cm_idx].med_dose_unit_cd)
      ELSEIF (x=5)
       SET item_data_struct->item_oid = "CMDOSUDISP"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->conmeds[cm_idx].med_dose_unit
      ELSEIF (x=6)
       SET item_data_struct->item_oid = "CMSTDTC"
       SET item_data_struct->item_type = "ItemDataDatetime"
       SET item_data_struct->value = formatisodate(ct_reply->conmeds[cm_idx].med_start_dt_tm,ct_reply
        ->conmeds[cm_idx].med_start_tz,0)
      ELSEIF (x=7)
       SET item_data_struct->item_oid = "CMONGO"
       SET item_data_struct->item_type = "ItemDataInteger"
       SET item_data_struct->value = build(ct_reply->conmeds[cm_idx].med_end_val)
      ELSEIF (x=8)
       SET item_data_struct->item_oid = "CMENDAT"
       SET item_data_struct->item_type = "ItemDataDatetime"
       SET item_data_struct->value = formatisodate(ct_reply->conmeds[cm_idx].med_end_dt_tm,ct_reply->
        conmeds[cm_idx].med_end_tz,0)
      ELSEIF (x=9)
       SET item_data_struct->item_oid = "CMROUTECODE"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = getcodedvalue(ct_reply->conmeds[cm_idx].med_route_cd)
      ELSEIF (x=10)
       SET item_data_struct->item_oid = "CMROUTEDISP"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->conmeds[cm_idx].med_route
      ELSEIF (x=11)
       SET item_data_struct->item_oid = "CMDOSFRQCODE"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = getcodedvalue(ct_reply->conmeds[cm_idx].med_frequency_cd)
      ELSEIF (x=12)
       SET item_data_struct->item_oid = "CMDOSFRQDISP"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->conmeds[cm_idx].med_frequency
      ELSEIF (x=13)
       SET item_data_struct->item_oid = "CMDOSFRMCODE"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = getcodedvalue(ct_reply->conmeds[cm_idx].med_form_cd)
      ELSEIF (x=14)
       SET item_data_struct->item_oid = "CMDOSFRMDISP"
       SET item_data_struct->item_type = "ItemDataString"
       SET item_data_struct->value = ct_reply->conmeds[cm_idx].med_form
      ENDIF
    ENDFOR
    SET curalias item_data_struct off
  ENDFOR
 ENDIF
 SET reply->text_type = "ODMv1.3"
 SUBROUTINE build_ce_item_group(subject_idx,study_event_idx,form_idx,item_grp_idx,event_group_idx)
   SET curalias item_data_struct off
   DECLARE event_cnt = i2 WITH protect, noconstant(0)
   DECLARE item_cnt = i2 WITH protect, noconstant(1)
   DECLARE alias_size = i2 WITH protect, noconstant(0)
   DECLARE status = i2 WITH protect, noconstant(0)
   SET curalias item_group reply->subject_data[subject_idx].study_event_data[study_event_idx].
   form_data[form_idx].item_group_data[item_grp_idx]
   SET curalias reply_event_group ct_reply->event_group[event_group_idx]
   SET item_group->item_group_oid = reply_event_group->parent_event_alias
   SET item_group->item_group_repeat_key = build(item_grp_idx)
   SET item_group->audit_performed_by = reply_event_group->performed_person
   SET item_group->audit_performed_timestamp = formatisodate(reply_event_group->performed_dt_tm,
    reply_event_group->performed_tz,0)
   SET event_cnt = size(reply_event_group->events,5)
   SET stat = alterlist(item_group->item_data,0)
   SET curalias item_data_struct item_group->item_data[item_cnt]
   SET item_cnt = 0
   FOR (x = 1 TO event_cnt)
     SET alias_size = (size(trim(reply_event_group->events[x].event_alias))+ 1)
     SET task_flag = findstring(".TASK",reply_event_group->events[x].event_alias)
     IF (task_flag > 0)
      SET item_cnt = (item_cnt+ 1)
      SET stat = alterlist(item_group->item_data,(item_cnt+ 1))
      IF (uar_get_code_meaning(reply_event_group->events[x].event_status_cd)="NOT DONE")
       SET status = 0
      ELSE
       SET status = 1
      ENDIF
      SET item_group->item_data[item_cnt].item_oid = substring(1,(alias_size - 6),reply_event_group->
       events[x].event_alias)
      SET item_group->item_data[item_cnt].item_type = "ItemDataInteger"
      SET item_group->item_data[item_cnt].audit_performed_by = reply_event_group->events[x].
      performed_person
      SET item_group->item_data[item_cnt].audit_performed_timestamp = formatisodate(reply_event_group
       ->events[x].performed_dt_tm,reply_event_group->events[x].performed_tz,0)
      SET item_group->item_data[item_cnt].audit_record_id = getnextitemauditrecord(0)
      IF (status=0)
       SET item_group->item_data[item_cnt].value = "0"
       SET item_cnt = (item_cnt+ 1)
       SET item_group->item_data[item_cnt].item_oid = build(substring(1,(alias_size - 6),
         reply_event_group->events[x].event_alias),"REASON")
       SET item_group->item_data[item_cnt].item_type = "ItemDataString"
       SET item_group->item_data[item_cnt].value = reply_event_group->events[x].event_value
       SET item_group->item_data[item_cnt].audit_performed_by = reply_event_group->events[x].
       performed_person
       SET item_group->item_data[item_cnt].audit_performed_timestamp = formatisodate(
        reply_event_group->events[x].performed_dt_tm,reply_event_group->events[x].performed_tz,0)
       SET item_group->item_data[item_cnt].audit_record_id = getnextitemauditrecord(0)
      ELSE
       SET stat = alterlist(item_group->item_data,(item_cnt+ 2))
       SET item_group->item_data[item_cnt].value = "1"
       SET item_cnt = (item_cnt+ 1)
       SET item_group->item_data[item_cnt].item_oid = build(substring(1,(alias_size - 6),
         reply_event_group->events[x].event_alias),"DATE")
       SET item_group->item_data[item_cnt].item_type = "ItemDataDatetime"
       SET item_group->item_data[item_cnt].value = item_group->audit_performed_timestamp
       SET item_group->item_data[item_cnt].audit_performed_by = reply_event_group->events[x].
       performed_person
       SET item_cnt = (item_cnt+ 1)
       SET item_group->item_data[item_cnt].item_oid = build(substring(1,(alias_size - 6),
         reply_event_group->events[x].event_alias),"PID")
       SET item_group->item_data[item_cnt].item_type = "ItemDataString"
       SET item_group->item_data[item_cnt].value = reply_event_group->events[x].event_task_person
       SET item_group->item_data[item_cnt].audit_performed_by = reply_event_group->events[x].
       performed_person
       SET item_group->item_data[item_cnt].audit_performed_timestamp = formatisodate(
        reply_event_group->events[x].performed_dt_tm,reply_event_group->events[x].performed_tz,0)
       SET item_group->item_data[item_cnt].audit_record_id = getnextitemauditrecord(0)
      ENDIF
     ELSE
      SET item_cnt = (item_cnt+ 1)
      SET stat = alterlist(item_group->item_data,item_cnt)
      SET item_group->item_data[item_cnt].item_oid = reply_event_group->events[x].event_alias
      IF ((reply_event_group->events[x].event_result_type=0))
       SET item_group->item_data[item_cnt].item_type = "ItemDataString"
       IF (size(reply_event_group->events[x].event_unit,1) > 0)
        SET item_group->item_data[item_cnt].value = reply_event_group->events[x].event_value
        SET item_group->item_data[item_cnt].measurement_unit_oid = reply_event_group->events[x].
        event_unit
       ELSE
        SET item_group->item_data[item_cnt].value = reply_event_group->events[x].event_value
       ENDIF
      ELSEIF ((reply_event_group->events[x].event_result_type=1))
       SET item_group->item_data[item_cnt].item_type = "ItemDataInteger"
       IF (size(reply_event_group->events[x].event_unit,1) > 0)
        SET item_group->item_data[item_cnt].value = reply_event_group->events[x].event_value
        SET item_group->item_data[item_cnt].measurement_unit_oid = reply_event_group->events[x].
        event_unit
       ELSE
        SET item_group->item_data[item_cnt].value = reply_event_group->events[x].event_value
       ENDIF
      ELSEIF ((reply_event_group->events[x].event_result_type=2))
       SET item_group->item_data[item_cnt].item_type = "ItemDataDatetime"
       SET item_group->item_data[item_cnt].value = formatisodate(reply_event_group->events[x].
        event_dt_tm,reply_event_group->events[x].event_tz,0)
      ENDIF
      SET item_group->item_data[item_cnt].audit_performed_by = reply_event_group->events[x].
      performed_person
      SET item_group->item_data[item_cnt].audit_performed_timestamp = formatisodate(reply_event_group
       ->events[x].performed_dt_tm,reply_event_group->events[x].performed_tz,0)
      SET item_group->item_data[item_cnt].audit_record_id = getnextitemauditrecord(0)
     ENDIF
   ENDFOR
   SET curalias item_data_struct off
 END ;Subroutine
 SUBROUTINE getnextitemauditrecord(itemidx)
   SET audit_record_idx = (audit_record_idx+ 1)
   SET audit_record_id = build("ITEMAUDIT:",audit_record_idx)
   RETURN(audit_record_id)
 END ;Subroutine
 SUBROUTINE formatisodate(datetime,timezone,precisionflag)
   DECLARE utcdatetime = f8 WITH protect, noconstant(0)
   DECLARE isoformat = vc WITH protect, noconstant("")
   DECLARE offsetminutes = i4 WITH protect, noconstant(0)
   DECLARE offset = vc WITH protect, noconstant("")
   IF (datetime > 0)
    IF (((precisionflag=1) OR (precisionflag=40)) )
     SET isoformat = format(datetime,"YYYY-MM;;D")
    ELSEIF (((precisionflag=2) OR (precisionflag=50)) )
     SET isoformat = format(datetime,"YYYY;;D")
    ELSE
     SET utcdatetime = cnvtdatetimeutc(datetime,3,timezone)
     SET offsetminutes = datetimediff(datetime,utcdatetime,4)
     IF (offsetminutes >= 0)
      SET offset = format(cnvttime(offsetminutes),"+HH:MM;;M")
     ELSE
      SET offset = format(cnvttime(abs(offsetminutes)),"-HH:MM;;M")
     ENDIF
     SET isoformat = build(format(datetime,"YYYY-MM-DDTHH:MM:SS;;D"),offset)
    ENDIF
   ENDIF
   RETURN(isoformat)
 END ;Subroutine
#exit_script
 IF (cfailed != "S")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = failuremsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "007"
 SET mod_date = "December 20, 2012"
 FREE RECORD ct_reply
 FREE RECORD ct_request
 SET trace = norecpersist
END GO
