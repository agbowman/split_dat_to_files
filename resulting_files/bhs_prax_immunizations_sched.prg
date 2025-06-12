CREATE PROGRAM bhs_prax_immunizations_sched
 FREE RECORD expect_series
 RECORD expect_series(
   1 list[*]
     2 series_id = f8
     2 reminder_idx = i4
     2 hmrecord_idx = i4
 ) WITH protect
 FREE RECORD immunizations
 RECORD immunizations(
   1 person_id = f8
   1 facility_cd = f8
   1 age_in_days = f8
   1 series[*]
     2 expect_series_id = f8
     2 expect_series_name = vc
     2 first_step_age = i4
     2 expect_id = f8
     2 expect_name = vc
     2 expect_meaning = vc
     2 step_count = i4
     2 max_age = i4
     2 expired_ind = i2
     2 admin_count = i4
     2 steps[*]
       3 expect_step_id = f8
       3 expect_step_name = vc
       3 step_meaning = vc
       3 valid_recommend_start_age = i4
       3 valid_recommend_end_age = i4
       3 min_age = i4
       3 min_interval_to_admin = i4
       3 min_interval_to_count = i4
       3 recommended_interval = i4
       3 max_interval_to_count = i4
       3 start_time_of_year = i4
       3 end_time_of_year = i4
       3 due_duration = i4
       3 near_due_duration = i4
       3 audience_flag = i2
       3 clinical_event_id = f8
       3 event_id = f8
       3 admin_dt_tm = dq8
       3 recommend_due_dt_tm = dq8
       3 step_nbr = i4
 ) WITH protect
 FREE RECORD events
 RECORD events(
   1 series[*]
     2 expect_id = f8
     2 expect_name = vc
     2 expect_meaning = vc
     2 admins[*]
       3 clinical_event_id = f8
       3 event_id = f8
       3 admin_dt_tm = dq8
       3 performed_prsnl_id = f8
       3 tag = vc
       3 dose = vc
       3 dose_units_cd = f8
 ) WITH protect
 FREE RECORD result
 RECORD result(
   1 person_id = f8
   1 age_in_days = f8
   1 series[*]
     2 expect_series_id = f8
     2 expect_series_name = vc
     2 first_step_age = i4
     2 expect_id = f8
     2 expect_name = vc
     2 expect_meaning = vc
     2 step_count = i4
     2 max_age = i4
     2 steps[*]
       3 expect_step_id = f8
       3 expect_step_name = vc
       3 step_meaning = vc
       3 valid_recommend_start_age = i4
       3 valid_recommend_end_age = i4
       3 min_age = i4
       3 min_interval_to_admin = i4
       3 min_interval_to_count = i4
       3 recommended_interval = i4
       3 max_interval_to_count = i4
       3 start_time_of_year = i4
       3 end_time_of_year = i4
       3 due_duration = i4
       3 near_due_duration = i4
       3 audience_flag = i2
       3 clinical_event_id = f8
       3 event_id = f8
       3 admin_dt_tm = dq8
       3 recommend_due_dt_tm = dq8
       3 step_nbr = i4
 ) WITH protect
 DECLARE ecnt = i4 WITH protect, noconstant(0)
 DECLARE scnt = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(0)
 DECLARE rcnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE mpersonid = f8 WITH protect, constant(request->person[1].person_id)
 SET immunizations->person_id = mpersonid
 DECLARE c_auth_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE c_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE c_altered_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE c_notdone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE c_placeholder_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE c_res_comment_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"RES COMMENT"))
 IF (((size(request->person,5)=0) OR ((request->person[1].person_id <= 0.0))) )
  CALL echo("INVALID REQUEST...EXITING")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM person p,
   encounter e
  PLAN (p
   WHERE (p.person_id=immunizations->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   immunizations->age_in_days = datetimediff(sysdate,p.birth_dt_tm), immunizations->facility_cd = e
   .loc_facility_cd
  WITH nocounter, time = 30
 ;end select
 IF ((((immunizations->age_in_days <= 0.0)) OR ((immunizations->facility_cd <= 0.0))) )
  CALL echo("INVALID PATIENT DETAILS...EXITING")
  GO TO exit_script
 ENDIF
 FREE RECORD hm_request
 RECORD hm_request(
   1 eval_start_dt_tm = dq8
   1 eval_end_dt_tm = dq8
   1 location_cd = f8
   1 prsnl_id = f8
   1 override_relationship = i2
   1 person[*]
     2 person_id = f8
     2 sex_cd = f8
     2 use_sex = i2
     2 birth_dt_tm = dq8
     2 use_birth_dt_tm = i2
     2 use_problems = i2
     2 problem[*]
       3 nomenclature_id = f8
       3 life_cycle_status_cd = f8
       3 organization_id = f8
     2 use_diagnoses = i2
     2 diagnosis[*]
       3 nomenclature_id = f8
       3 diag_type_cd = f8
       3 organization_id = i2
     2 procedure[*]
       3 procedure_id = f8
       3 nomenclature_id = f8
       3 proc_prsnl_id = f8
       3 proc_prsnl_name = vc
       3 active_ind = i2
       3 proc_dt_tm = dq8
       3 text = vc
       3 organization_id = f8
   1 allow_recommendation_server_ind = i2
 ) WITH protect
 SET hm_request->eval_start_dt_tm = cnvtdatetime(curdate,curtime3)
 SET hm_request->eval_end_dt_tm = cnvtdatetime(curdate,curtime3)
 SET hm_request->location_cd = immunizations->facility_cd
 SET hm_request->prsnl_id = reqinfo->updt_id
 SET stat = alterlist(hm_request->person,1)
 SET hm_request->person[1].person_id = immunizations->person_id
 FREE RECORD reply
 EXECUTE pco_get_hm_recommendations_two  WITH replace("REQUEST","HM_REQUEST")
 IF ((((reply->status_data.status="F")) OR (size(reply->person,5) <= 0)) )
  CALL echo("PCO_GET_HM_RECOMMENDATIONS_TWO FAILED...EXITING")
  GO TO exit_script
 ELSE
  CALL echorecord(reply)
  SET stat = alterlist(expect_series->list,(size(reply->person[1].reminder,5)+ size(reply->person[1].
    hmrecord,5)))
  SET ecnt = 0
  FOR (idx = 1 TO size(reply->person[1].reminder,5))
   SET pos = locateval(locidx,1,size(expect_series->list,5),reply->person[1].reminder[idx].series_id,
    expect_series->list[locidx].series_id)
   IF (pos=0)
    SET ecnt = (ecnt+ 1)
    SET expect_series->list[ecnt].series_id = reply->person[1].reminder[idx].series_id
    SET expect_series->list[ecnt].reminder_idx = idx
   ENDIF
  ENDFOR
  FOR (idx = 1 TO size(reply->person[1].hmrecord,5))
   SET pos = locateval(locidx,1,size(expect_series->list,5),reply->person[1].hmrecord[idx].series_id,
    expect_series->list[locidx].series_id)
   IF (pos=0)
    SET ecnt = (ecnt+ 1)
    SET expect_series->list[ecnt].series_id = reply->person[1].hmrecord[idx].series_id
    SET expect_series->list[ecnt].hmrecord_idx = idx
   ENDIF
  ENDFOR
  SET stat = alterlist(expect_series->list,ecnt)
  SET ecnt = 0
  SELECT INTO "NL:"
   FROM hm_expect_series hes,
    hm_expect he,
    hm_expect_step hep
   PLAN (hes
    WHERE expand(idx,1,size(expect_series->list,5),hes.expect_series_id,expect_series->list[idx].
     series_id)
     AND hes.active_ind=1
     AND hes.beg_effective_dt_tm < sysdate
     AND hes.end_effective_dt_tm > sysdate
     AND hes.series_meaning != "CERNER_AD_HOC")
    JOIN (he
    WHERE he.expect_series_id=hes.expect_series_id
     AND he.active_ind=1
     AND he.beg_effective_dt_tm < sysdate
     AND he.end_effective_dt_tm > sysdate
     AND he.interval_only_ind=0)
    JOIN (hep
    WHERE hep.expect_id=he.expect_id
     AND hep.active_ind=1
     AND hep.beg_effective_dt_tm < sysdate
     AND hep.end_effective_dt_tm > sysdate)
   ORDER BY hes.first_step_age, he.expect_name, hep.step_nbr
   HEAD he.expect_id
    ecnt = (ecnt+ 1), stat = alterlist(immunizations->series,ecnt), immunizations->series[ecnt].
    expect_series_id = hes.expect_series_id,
    immunizations->series[ecnt].expect_series_name = hes.expect_series_name, immunizations->series[
    ecnt].first_step_age = hes.first_step_age, immunizations->series[ecnt].expect_id = he.expect_id,
    immunizations->series[ecnt].expect_name = he.expect_name, immunizations->series[ecnt].
    expect_meaning = he.expect_meaning, immunizations->series[ecnt].step_count = he.step_count,
    immunizations->series[ecnt].max_age = he.max_age, scnt = 0
   HEAD hep.expect_step_id
    scnt = (scnt+ 1), stat = alterlist(immunizations->series[ecnt].steps,scnt), immunizations->
    series[ecnt].steps[scnt].expect_step_id = hep.expect_step_id,
    immunizations->series[ecnt].steps[scnt].expect_step_name = hep.expect_step_name, immunizations->
    series[ecnt].steps[scnt].step_meaning = hep.step_meaning, immunizations->series[ecnt].steps[scnt]
    .valid_recommend_start_age = hep.valid_recommend_start_age,
    immunizations->series[ecnt].steps[scnt].valid_recommend_end_age = hep.valid_recommend_end_age,
    immunizations->series[ecnt].steps[scnt].min_age = hep.min_age, immunizations->series[ecnt].steps[
    scnt].min_interval_to_admin = hep.min_interval_to_admin,
    immunizations->series[ecnt].steps[scnt].min_interval_to_count = hep.min_interval_to_count,
    immunizations->series[ecnt].steps[scnt].recommended_interval = hep.recommended_interval,
    immunizations->series[ecnt].steps[scnt].max_interval_to_count = hep.max_interval_to_count,
    immunizations->series[ecnt].steps[scnt].start_time_of_year = hep.start_time_of_year,
    immunizations->series[ecnt].steps[scnt].end_time_of_year = hep.end_time_of_year, immunizations->
    series[ecnt].steps[scnt].due_duration = hep.due_duration,
    immunizations->series[ecnt].steps[scnt].near_due_duration = hep.near_due_duration, immunizations
    ->series[ecnt].steps[scnt].audience_flag = hep.audience_flag, immunizations->series[ecnt].steps[
    scnt].step_nbr = hep.step_nbr
   FOOT  he.expect_id
    row + 0
   FOOT  hep.expect_step_id
    row + 0
   WITH nocounter, time = 30, expand = 1
  ;end select
  FOR (idx = 1 TO size(immunizations->series,5))
    FOR (jdx = 1 TO size(immunizations->series[idx].steps,5))
     SET pos = locateval(locidx,1,size(reply->person[1].reminder,5),immunizations->series[idx].steps[
      jdx].expect_step_id,reply->person[1].reminder[locidx].step_id)
     IF (pos > 0)
      SET immunizations->series[idx].steps[jdx].recommend_due_dt_tm = reply->person[1].reminder[pos].
      recommend_due_dt_tm
     ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SET ecnt = 0
 SELECT INTO "NL:"
  FROM v500_event_set_code es,
   v500_event_set_explode ese,
   hm_expect_sat hes,
   hm_expect he,
   clinical_event ce,
   ce_event_note cen
  PLAN (es
   WHERE es.event_set_cd_disp_key="IMMUNIZATIONS")
   JOIN (ese
   WHERE ese.event_set_cd=es.event_set_cd)
   JOIN (hes
   WHERE hes.entry_id=ese.event_cd
    AND hes.active_ind=1
    AND hes.beg_effective_dt_tm < sysdate
    AND hes.end_effective_dt_tm > sysdate)
   JOIN (he
   WHERE he.expect_id=hes.expect_id
    AND he.active_ind=1
    AND he.beg_effective_dt_tm < sysdate
    AND he.end_effective_dt_tm > sysdate)
   JOIN (ce
   WHERE (ce.person_id=immunizations->person_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.event_cd=hes.entry_id
    AND ce.result_status_cd IN (c_auth_status_cd, c_modified_cd, c_altered_status_cd, c_notdone_cd)
    AND ce.event_class_cd != c_placeholder_cd)
   JOIN (cen
   WHERE cen.event_id=outerjoin(ce.event_id)
    AND cen.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND cen.note_type_cd=outerjoin(c_res_comment_cd))
  ORDER BY he.expect_id, ce.event_end_dt_tm, cen.event_id DESC
  HEAD he.expect_id
   ecnt = (ecnt+ 1), stat = alterlist(events->series,ecnt), events->series[ecnt].expect_id = he
   .expect_id,
   events->series[ecnt].expect_name = he.expect_name, events->series[ecnt].expect_meaning = he
   .expect_meaning, acnt = 0
  HEAD ce.clinical_event_id
   IF (cen.event_id=0)
    acnt = (acnt+ 1), stat = alterlist(events->series[ecnt].admins,acnt), events->series[ecnt].
    admins[acnt].clinical_event_id = ce.clinical_event_id,
    events->series[ecnt].admins[acnt].event_id = ce.event_id, events->series[ecnt].admins[acnt].
    admin_dt_tm = ce.event_end_dt_tm, events->series[ecnt].admins[acnt].performed_prsnl_id = ce
    .performed_prsnl_id,
    events->series[ecnt].admins[acnt].tag = ce.event_tag, events->series[ecnt].admins[acnt].dose = ce
    .result_val, events->series[ecnt].admins[acnt].dose_units_cd = ce.result_units_cd
   ENDIF
  FOOT  he.expect_id
   row + 0
  FOOT  ce.clinical_event_id
   row + 0
  WITH nocounter, time = 30
 ;end select
 IF (size(events->series,5) > 0)
  FOR (ecnt = 1 TO size(immunizations->series,5))
   SET pos = locateval(idx,1,size(events->series,5),immunizations->series[ecnt].expect_id,events->
    series[idx].expect_id)
   IF (pos > 0)
    SET immunizations->series[ecnt].admin_count = size(events->series[pos].admins,5)
    FOR (acnt = 1 TO size(events->series[pos].admins,5))
      IF (acnt <= size(immunizations->series[ecnt].steps,5))
       SET immunizations->series[ecnt].steps[acnt].admin_dt_tm = events->series[pos].admins[acnt].
       admin_dt_tm
       SET immunizations->series[ecnt].steps[acnt].clinical_event_id = events->series[pos].admins[
       acnt].clinical_event_id
       SET immunizations->series[ecnt].steps[acnt].event_id = events->series[pos].admins[acnt].
       event_id
      ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
 FOR (ecnt = 1 TO size(immunizations->series,5))
   IF ((immunizations->series[ecnt].max_age <= immunizations->age_in_days)
    AND (immunizations->series[ecnt].admin_count=0))
    SET immunizations->series[ecnt].expired_ind = 1
   ENDIF
 ENDFOR
#exit_script
 SET result->person_id = immunizations->person_id
 SET result->age_in_days = immunizations->age_in_days
 SET stat = alterlist(result->series,size(immunizations->series,5))
 FOR (ecnt = 1 TO size(immunizations->series,5))
   IF ((immunizations->series[ecnt].expired_ind=0))
    SET rcnt = (rcnt+ 1)
    SET result->series[rcnt].expect_series_id = immunizations->series[ecnt].expect_series_id
    SET result->series[rcnt].expect_series_name = immunizations->series[ecnt].expect_series_name
    SET result->series[rcnt].first_step_age = immunizations->series[ecnt].first_step_age
    SET result->series[rcnt].expect_id = immunizations->series[ecnt].expect_id
    SET result->series[rcnt].expect_name = immunizations->series[ecnt].expect_name
    SET result->series[rcnt].expect_meaning = immunizations->series[ecnt].expect_meaning
    SET result->series[rcnt].step_count = immunizations->series[ecnt].step_count
    SET result->series[rcnt].max_age = immunizations->series[ecnt].max_age
    SET stat = alterlist(result->series[rcnt].steps,size(immunizations->series[ecnt].steps,5))
    FOR (scnt = 1 TO size(immunizations->series[ecnt].steps,5))
      SET result->series[rcnt].steps[scnt].expect_step_id = immunizations->series[ecnt].steps[scnt].
      expect_step_id
      SET result->series[rcnt].steps[scnt].expect_step_name = immunizations->series[ecnt].steps[scnt]
      .expect_step_name
      SET result->series[rcnt].steps[scnt].step_meaning = immunizations->series[ecnt].steps[scnt].
      step_meaning
      SET result->series[rcnt].steps[scnt].valid_recommend_start_age = immunizations->series[ecnt].
      steps[scnt].valid_recommend_start_age
      SET result->series[rcnt].steps[scnt].valid_recommend_end_age = immunizations->series[ecnt].
      steps[scnt].valid_recommend_end_age
      SET result->series[rcnt].steps[scnt].min_age = immunizations->series[ecnt].steps[scnt].min_age
      SET result->series[rcnt].steps[scnt].min_interval_to_admin = immunizations->series[ecnt].steps[
      scnt].min_interval_to_admin
      SET result->series[rcnt].steps[scnt].min_interval_to_count = immunizations->series[ecnt].steps[
      scnt].min_interval_to_count
      SET result->series[rcnt].steps[scnt].recommended_interval = immunizations->series[ecnt].steps[
      scnt].recommended_interval
      SET result->series[rcnt].steps[scnt].max_interval_to_count = immunizations->series[ecnt].steps[
      scnt].max_interval_to_count
      SET result->series[rcnt].steps[scnt].start_time_of_year = immunizations->series[ecnt].steps[
      scnt].start_time_of_year
      SET result->series[rcnt].steps[scnt].end_time_of_year = immunizations->series[ecnt].steps[scnt]
      .end_time_of_year
      SET result->series[rcnt].steps[scnt].due_duration = immunizations->series[ecnt].steps[scnt].
      due_duration
      SET result->series[rcnt].steps[scnt].near_due_duration = immunizations->series[ecnt].steps[scnt
      ].near_due_duration
      SET result->series[rcnt].steps[scnt].audience_flag = immunizations->series[ecnt].steps[scnt].
      audience_flag
      SET result->series[rcnt].steps[scnt].clinical_event_id = immunizations->series[ecnt].steps[scnt
      ].clinical_event_id
      SET result->series[rcnt].steps[scnt].event_id = immunizations->series[ecnt].steps[scnt].
      event_id
      SET result->series[rcnt].steps[scnt].admin_dt_tm = immunizations->series[ecnt].steps[scnt].
      admin_dt_tm
      SET result->series[rcnt].steps[scnt].recommend_due_dt_tm = immunizations->series[ecnt].steps[
      scnt].recommend_due_dt_tm
      SET result->series[rcnt].steps[scnt].step_nbr = immunizations->series[ecnt].steps[scnt].
      step_nbr
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = alterlist(result->series,rcnt)
 CALL echorecord(result)
 SET json = cnvtrectojson(result)
 SELECT INTO value(moutputdevice)
  json
  FROM dummyt d
  WITH format, time = 30, separator = " "
 ;end select
 FREE RECORD expect_series
 FREE RECORD immunizations
 FREE RECORD events
 FREE RECORD result
 FREE RECORD reply
 RECORD reply(
   1 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
   1 large_text_qual[*]
     2 text_segment = vc
 ) WITH persistscript
END GO
