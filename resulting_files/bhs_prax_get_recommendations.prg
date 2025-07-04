CREATE PROGRAM bhs_prax_get_recommendations
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE ldx = i4 WITH protect, noconstant(0)
 DECLARE mdx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE applicationid = i4 WITH protect, constant(600005)
 DECLARE taskid = i4 WITH protect, constant(966310)
 DECLARE requestid = i4 WITH protect, noconstant(0)
 FREE RECORD result
 RECORD result(
   1 reminder[*]
     2 recommendation_id = f8
     2 expect_sched_id = f8
     2 expect_series_id = f8
     2 expect_step_id = f8
     2 expect_id = f8
     2 expect_name = vc
     2 expect_ftdesc = vc
     2 due_dt_tm = dq8
     2 priority = vc
     2 frequency_value = i4
     2 frequency_unit_cd = f8
     2 frequency_unit_disp = vc
     2 status_flag = i2
     2 comment = vc
     2 satisfier[*]
       3 expect_sat_id = f8
       3 expect_sat_name = vc
       3 entry_type_cd = f8
       3 entry_type_disp = vc
       3 parent_entity_id = f8
       3 parent_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req966307
 RECORD req966307(
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
     2 use_birth_dt_tm = dq8
     2 use_problems = i2
     2 problems[*]
       3 nomenclature_id = f8
       3 life_cycle_status_cd = f8
       3 organization_id = f8
     2 use_diagnoses = i2
     2 diagnosis[*]
       3 nomenclature_id = f8
       3 diag_type_cd = f8
       3 organization_id = f8
     2 use_procedures = i2
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
 FREE RECORD rep966307
 RECORD rep966307(
   1 person[*]
     2 person_id = f8
     2 long_blob_id = f8
     2 qualify_until_dt_tm = dq8
     2 reminder[*]
       3 schedule_id = f8
       3 series_id = f8
       3 expectation_id = f8
       3 step_id = f8
       3 status_flag = i2
       3 effective_start_dt_tm = dq8
       3 valid_start_dt_tm = dq8
       3 valid_end_dt_tm = dq8
       3 recommend_start_age = i4
       3 recommend_end_age = i4
       3 recommend_due_dt_tm = dq8
       3 over_due_dt_tm = dq8
       3 latest_postponed_dt_tm = dq8
       3 alternate_exp_available = i2
       3 last_sat_dt_tm = dq8
       3 last_sat_prsnl_id = f8
       3 last_sat_prsnl_name = vc
       3 last_sat_comment = vc
       3 last_sat_organization_id = f8
       3 encounter_id = f8
       3 frequency_value = i4
       3 frequency_unit_cd = f8
       3 has_frequency_modification = i2
       3 has_due_date_modification = i2
       3 system_frequency_value = i4
       3 system_frequency_unit_cd = f8
       3 recommendation_id = f8
       3 expectation_ftdesc = vc
       3 has_expectation_modification = i2
       3 near_due_dt_tm = dq8
       3 expectation_name = vc
     2 hmrecord[*]
       3 modifier_id = f8
       3 modifier_type_cd = f8
       3 modifier_type_mean = vc
       3 clinical_event_id = f8
       3 order_id = f8
       3 procedure_id = f8
       3 schedule_id = f8
       3 series_id = f8
       3 expectation_id = f8
       3 step_id = f8
       3 status_flag = i2
       3 modifier_dt_tm = dq8
       3 next_due_dt_tm = dq8
       3 recorded_dt_tm = dq8
       3 recorded_for_prsnl_id = f8
       3 recorded_for_prsnl_name = vc
       3 reason_cd = f8
       3 reason_disp = vc
       3 comment = vc
       3 created_prsnl_id = f8
       3 created_prsnl_name = vc
       3 organization_id = f8
       3 encounter_id = f8
       3 status_ind = i2
       3 recommendation_id = f8
       3 recommendation_action_id = f8
       3 expectation_ftdesc = vc
       3 adr[*]
         4 reltn_entity_id = f8
         4 reltn_entity_all_ind = i2
       3 appointment_id = f8
       3 expectation_name = vc
     2 schedule_reltn[*]
       3 schedule_id = f8
       3 mode_flag = i2
     2 series[*]
       3 series_mean = vc
       3 sched_mean = vc
       3 qualify_flag = i2
       3 explanation = vc
   1 person_org_sec_on = i2
   1 valid_as_of = dq8
   1 coherency_active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req966302
 RECORD req966302(
   1 last_load_dt_tm = dq8
 ) WITH protect
 FREE RECORD rep966302
 RECORD rep966302(
   1 load_dt_tm = dq8
   1 sched[*]
     2 expect_sched_id = f8
     2 expect_sched_name = vc
     2 expect_sched_meaning = vc
     2 expect_sched_type_flag = i2
     2 expect_sched_loc_cd = f8
     2 expect_sched_loc_disp = vc
     2 expect_sched_loc_mean = vc
     2 on_time_start_age = i4
     2 sched_level_flag = i2
     2 series[*]
       3 expect_series_id = f8
       3 expect_series_name = vc
       3 series_meaning = vc
       3 priority_meaning = vc
       3 priority_disp = vc
       3 priority_seq = i4
       3 rule_associated_ind = i2
       3 first_step_age = i4
       3 expect[*]
         4 expect_id = f8
         4 expect_name = vc
         4 expect_meaning = vc
         4 step_count = i4
         4 inverval_only_ind = i2
         4 seq_nbr = i4
         4 max_age = i4
         4 frequency_value = i4
         4 frequency_unit_cd = f8
         4 expect_count_hist_ind = i2
         4 step[*]
           5 expect_step_id = f8
           5 expect_step_name = vc
           5 step_meaning = vc
           5 valid_recommend_start_age = i4
           5 valid_recommend_end_age = i4
           5 step_nbr = i4
           5 max_interval_to_count = i4
           5 min_interval_to_count = i4
           5 min_interval_to_admin = i4
           5 recommended_interval = i4
           5 min_age = i4
           5 skip_age = i4
           5 due_duration = i4
           5 audience_flag = i4
           5 start_time_of_year = i4
           5 end_time_of_year = i4
           5 near_due_duration = i4
         4 satisfier[*]
           5 expect_sat_id = f8
           5 expect_sat_name = vc
           5 satisfier_meaning = vc
           5 parent_type_flag = i2
           5 parent_nbr = f8
           5 parent_value = vc
           5 seq_nbr = i4
           5 entry_type_cd = f8
           5 entry_type_disp = vc
           5 entry_type_mean = vc
           5 entry_nbr = f8
           5 entry_value = vc
           5 pending_duration = i4
           5 satisfied_duration = i4
           5 nomenclature_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req966337
 RECORD req966337(
   1 recommendation_id = f8
   1 recommendations[*]
     2 recommendation_id = f8
 ) WITH protect
 FREE RECORD rep966337
 RECORD rep966337(
   1 recommendation_actions[*]
     2 action_dt_tm = dq8
     2 action_flag = i2
     2 due_dt_tm = dq8
     2 long_text_id = f8
     2 on_behalf_of_prsnl_id = f8
     2 reason_cd = f8
     2 recommendation_action_id = f8
     2 recommendation_id = f8
     2 record_number = i4
     2 satisfaction_id = f8
     2 satisfaction_source = c30
     2 frequency_value = i4
     2 frequency_unit_cd = f8
     2 expectation_ftdesc = vc
     2 long_text = c32000
     2 prev_frequency_value = i4
     2 prev_frequency_unit_cd = f8
     2 prev_due_dt_tm = dq8
     2 satisfaction_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID...EXITING")
  GO TO exit_script
 ELSEIF (textlen( $4) <= 0.0)
  CALL echo("INVALID FROM DATE...EXITING")
  GO TO exit_script
 ELSEIF (textlen( $5) <= 0.0)
  CALL echo("INVALID TO DATE...EXITING")
  GO TO exit_script
 ELSEIF (( $6 <= 0.0))
  CALL echo("INVALID FACILITY CODE...EXITING")
  GO TO exit_script
 ENDIF
 SET requestid = 966302
 CALL echo(build("TDBEXECUTE FOR ",requestid))
 SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req966302,
  "REC",rep966302,1)
 IF (stat > 0)
  SET errcode = error(errmsg,1)
  CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
    errmsg))
  GO TO exit_script
 ENDIF
 CALL echorecord(rep966302)
 DECLARE reminder_cnt = i4 WITH protect, noconstant(0)
 SET requestid = 966307
 SET req966307->eval_start_dt_tm = cnvtdatetime( $4)
 SET req966307->eval_end_dt_tm = cnvtdatetime( $5)
 SET req966307->location_cd =  $6
 SET req966307->prsnl_id =  $3
 SET stat = alterlist(req966307->person,1)
 SET req966307->person[1].person_id =  $2
 SET req966307->allow_recommendation_server_ind = 1
 CALL echorecord(req966307)
 CALL echo(build("TDBEXECUTE FOR ",requestid))
 SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req966307,
  "REC",rep966307,1)
 IF (stat > 0)
  SET errcode = error(errmsg,1)
  CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
    errmsg))
  GO TO exit_script
 ENDIF
 CALL echorecord(rep966307)
 IF ((rep966307->status_data.status="S")
  AND size(rep966307->person,5) > 0)
  SET reminder_cnt = size(rep966307->person[1].reminder,5)
  SET stat = alterlist(result->reminder,reminder_cnt)
  FOR (idx = 1 TO reminder_cnt)
    SET result->reminder[idx].recommendation_id = rep966307->person[1].reminder[idx].
    recommendation_id
    SET result->reminder[idx].expect_sched_id = rep966307->person[1].reminder[idx].schedule_id
    SET result->reminder[idx].expect_series_id = rep966307->person[1].reminder[idx].series_id
    SET result->reminder[idx].expect_step_id = rep966307->person[1].reminder[idx].step_id
    SET result->reminder[idx].expect_id = rep966307->person[1].reminder[idx].expectation_id
    SET result->reminder[idx].expect_ftdesc = rep966307->person[1].reminder[idx].expectation_ftdesc
    SET result->reminder[idx].due_dt_tm = rep966307->person[1].reminder[idx].recommend_due_dt_tm
    SET result->reminder[idx].expect_series_id = rep966307->person[1].reminder[idx].series_id
    SET result->reminder[idx].frequency_value = rep966307->person[1].reminder[idx].frequency_value
    SET result->reminder[idx].frequency_unit_cd = rep966307->person[1].reminder[idx].
    frequency_unit_cd
    SET result->reminder[idx].frequency_unit_disp = uar_get_code_display(result->reminder[idx].
     frequency_unit_cd)
    SET result->reminder[idx].status_flag = rep966307->person[1].reminder[idx].status_flag
  ENDFOR
 ENDIF
 SET result->status_data.status = rep966307->status_data.status
 DECLARE satisfier_cnt = i4 WITH protect, noconstant(0)
 FOR (idx = 1 TO reminder_cnt)
  SET jdx = locateval(locidx,1,size(rep966302->sched,5),result->reminder[idx].expect_sched_id,
   rep966302->sched[locidx].expect_sched_id)
  IF (jdx > 0)
   SET kdx = locateval(locidx,1,size(rep966302->sched[jdx].series,5),result->reminder[idx].
    expect_series_id,rep966302->sched[jdx].series[locidx].expect_series_id)
   IF (kdx > 0)
    SET result->reminder[idx].priority = rep966302->sched[jdx].series[kdx].priority_meaning
    SET ldx = locateval(locidx,1,size(rep966302->sched[jdx].series[kdx].expect,5),result->reminder[
     idx].expect_id,rep966302->sched[jdx].series[kdx].expect[locidx].expect_id)
    IF (ldx > 0)
     SET result->reminder[idx].expect_name = rep966302->sched[jdx].series[kdx].expect[ldx].
     expect_name
     SET stat = alterlist(result->reminder[idx].satisfier,size(rep966302->sched[jdx].series[kdx].
       expect[ldx].satisfier,5))
     SET satisfier_cnt = 0
     FOR (mdx = 1 TO size(rep966302->sched[jdx].series[kdx].expect[ldx].satisfier,5))
       IF ((rep966302->sched[jdx].series[kdx].expect[ldx].satisfier[mdx].entry_type_cd > 0))
        SET satisfier_cnt = (satisfier_cnt+ 1)
        SET result->reminder[idx].satisfier[satisfier_cnt].expect_sat_id = rep966302->sched[jdx].
        series[kdx].expect[ldx].satisfier[mdx].expect_sat_id
        SET result->reminder[idx].satisfier[satisfier_cnt].expect_sat_name = rep966302->sched[jdx].
        series[kdx].expect[ldx].satisfier[mdx].expect_sat_name
        SET result->reminder[idx].satisfier[satisfier_cnt].entry_type_cd = rep966302->sched[jdx].
        series[kdx].expect[ldx].satisfier[mdx].entry_type_cd
        SET result->reminder[idx].satisfier[satisfier_cnt].entry_type_disp = rep966302->sched[jdx].
        series[kdx].expect[ldx].satisfier[mdx].entry_type_disp
        SET result->reminder[idx].satisfier[satisfier_cnt].parent_entity_id = rep966302->sched[jdx].
        series[kdx].expect[ldx].satisfier[mdx].parent_nbr
        SET result->reminder[idx].satisfier[satisfier_cnt].parent_value = rep966302->sched[jdx].
        series[kdx].expect[ldx].satisfier[mdx].parent_value
       ENDIF
     ENDFOR
     SET stat = alterlist(result->reminder[idx].satisfier,satisfier_cnt)
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 IF (reminder_cnt > 0)
  SET requestid = 966337
  SET stat = alterlist(req966337->recommendations,reminder_cnt)
  FOR (idx = 1 TO reminder_cnt)
    SET req966337->recommendations[idx].recommendation_id = result->reminder[idx].recommendation_id
  ENDFOR
  CALL echorecord(req966337)
  CALL echo(build("TDBEXECUTE FOR ",requestid))
  SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req966337,
   "REC",rep966337,1)
  IF (stat > 0)
   SET errcode = error(errmsg,1)
   CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
     errmsg))
   GO TO exit_script
  ENDIF
  CALL echorecord(rep966337)
  IF ((rep966337->status_data.status="S"))
   FOR (idx = 1 TO reminder_cnt)
    SET pos = locateval(locidx,1,size(rep966337->recommendation_actions,5),result->reminder[idx].
     recommendation_id,rep966337->recommendation_actions[locidx].recommendation_id,
     16,rep966337->recommendation_actions[locidx].action_flag)
    IF (pos > 0)
     SET result->reminder[idx].comment = rep966337->recommendation_actions[pos].long_text
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  DECLARE v20 = vc WITH protect, noconstant("")
  DECLARE v21 = vc WITH protect, noconstant("")
  DECLARE v22 = vc WITH protect, noconstant("")
  DECLARE v23 = vc WITH protect, noconstant("")
  DECLARE v24 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM (dummyt d  WITH seq = value(1))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1
   DETAIL
    col + 1, "<Recommendations>", row + 1
    FOR (idx = 1 TO reminder_cnt)
      col + 1, "<Recommendation>", row + 1,
      v1 = build("<RecommendationId>",cnvtint(result->reminder[idx].recommendation_id),
       "</RecommendationId>"), col + 1, v1,
      row + 1, v2 = build("<ExpectId>",cnvtint(result->reminder[idx].expect_id),"</ExpectId>"), col
       + 1,
      v2, row + 1, v3 = build("<ExpectationName>",evaluate(trim(result->reminder[idx].expect_ftdesc,3
         ),"",trim(result->reminder[idx].expect_name,3),trim(result->reminder[idx].expect_ftdesc,3)),
       "</ExpectationName>"),
      col + 1, v3, row + 1,
      v4 = build("<FreeTextIndicator>",evaluate(trim(result->reminder[idx].expect_ftdesc,3),"","NO",
        "YES"),"</FreeTextIndicator>"), col + 1, v4,
      row + 1, v5 = build("<DueDate>",format(result->reminder[idx].due_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"
        ),"</DueDate>"), col + 1,
      v5, row + 1, v6 = build("<UpdatedDate>",trim(""),"</UpdatedDate>"),
      col + 1, v6, row + 1,
      v7 = build("<ExpectSeriesId>",cnvtint(result->reminder[idx].expect_series_id),
       "</ExpectSeriesId>"), col + 1, v7,
      row + 1, v8 = build("<Priority>",result->reminder[idx].priority,"</Priority>"), col + 1,
      v8, row + 1, v9 = build("<FrequencyValue>",result->reminder[idx].frequency_value,
       "</FrequencyValue>"),
      col + 1, v9, row + 1,
      v10 = build("<FrequencyUnitCD>",cnvtint(result->reminder[idx].frequency_unit_cd),
       "</FrequencyUnitCD>"), col + 1, v10,
      row + 1, v11 = build("<FrequencyUnit>",result->reminder[idx].frequency_unit_disp,
       "</FrequencyUnit>"), col + 1,
      v11, row + 1, v12 = build("<StatusFlag>",result->reminder[idx].status_flag,"</StatusFlag>"),
      col + 1, v12, row + 1,
      v13 = build("<Status>",evaluate(result->reminder[idx].status_flag,0,"Due",1,"Postponed",
        2,"Refused","Unknown"),"</Status>"), col + 1, v13,
      row + 1, v14 = build("<ApproxDueDate>",trim(""),"</ApproxDueDate>"), col + 1,
      v14, row + 1, v15 = build("<RecommendationActionId>",trim(""),"</RecommendationActionId>"),
      col + 1, v15, row + 1,
      v16 = build("<Action>",trim(""),"</Action>"), col + 1, v16,
      row + 1, v17 = build("<ActionDate>",trim(""),"</ActionDate>"), col + 1,
      v17, row + 1, v18 = build("<Comments>",trim(result->reminder[idx].comment,3),"</Comments>"),
      col + 1, v18, row + 1,
      col + 1, "<Expectations>", row + 1
      FOR (jdx = 1 TO size(result->reminder[idx].satisfier,5))
        col + 1, "<Expectation>", row + 1,
        v19 = build("<ExpectSatId>",cnvtint(result->reminder[idx].satisfier[jdx].expect_sat_id),
         "</ExpectSatId>"), col + 1, v19,
        row + 1, v20 = build("<SatisfyTypeCD>",cnvtint(result->reminder[idx].satisfier[jdx].
          entry_type_cd),"</SatisfyTypeCD>"), col + 1,
        v20, row + 1, v21 = build("<SatisfyType>",result->reminder[idx].satisfier[jdx].
         entry_type_disp,"</SatisfyType>"),
        col + 1, v21, row + 1,
        v22 = build("<ExpectSatName>",result->reminder[idx].satisfier[jdx].expect_sat_name,
         "</ExpectSatName>"), col + 1, v22,
        row + 1, v23 = build("<ExpectSatParentEntityId>",result->reminder[idx].satisfier[jdx].
         parent_entity_id,"</ExpectSatParentEntityId>"), col + 1,
        v23, row + 1, v24 = build("<ExpectSatParentValue>",result->reminder[idx].satisfier[jdx].
         parent_value,"</ExpectSatParentValue>"),
        col + 1, v24, row + 1,
        col + 1, "</Expectation>", row + 1
      ENDFOR
      col + 1, "</Expectations>", row + 1,
      col + 1, "</Recommendation>", row + 1
    ENDFOR
    col + 1, "</Recommendations>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req966307
 FREE RECORD rep966307
 FREE RECORD req966302
 FREE RECORD rep966302
 FREE RECORD req966337
 FREE RECORD rep966337
END GO
