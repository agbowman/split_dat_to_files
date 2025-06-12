CREATE PROGRAM bhs_athn_satisfied_recomm
 DECLARE sortresults(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
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
   1 hmrecord[*]
     2 recommendation_id = f8
     2 recommendation_action_id = f8
     2 modifier_id = f8
     2 modifier_type_cd = f8
     2 modifier_type_disp = vc
     2 expect_sched_id = f8
     2 expect_series_id = f8
     2 expect_series_name = vc
     2 expect_step_id = f8
     2 expect_step_name = vc
     2 expect_id = f8
     2 expect_name = vc
     2 expect_ftdesc = vc
     2 expect_name_disp = vc
     2 modifier_dt_tm = dq8
     2 next_due_dt_tm = dq8
     2 recorded_dt_tm = dq8
     2 recorded_for_prsnl_id = f8
     2 recorded_for_prsnl_name = vc
     2 reason_cd = f8
     2 reason_disp = vc
     2 comment = vc
     2 status_flag = i2
     2 status_text = vc
     2 clinical_event_id = f8
     2 satisfy_type = vc
     2 priority = vc
     2 recommend_due_dt_tm = dq8
     2 parent_action_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD result_seq
 RECORD result_seq(
   1 list[*]
     2 ref_idx = i4
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
     2 subeventstatus[1]
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
 DECLARE reccnt = i4 WITH protect, noconstant(0)
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
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
  SET now_year = cnvtint(format(now,"YYYY;;D"))
  SET now_month = cnvtint(format(now,"MM;;D"))
  SET now_day = cnvtint(format(now,"DD;;D"))
  SET stat = alterlist(result->hmrecord,size(rep966307->person[1].hmrecord,5))
  FOR (idx = 1 TO size(rep966307->person[1].hmrecord,5))
    IF (((( $7=1)) OR ((rep966307->person[1].hmrecord[idx].status_flag != 8)))
     AND (rep966307->person[1].hmrecord[idx].recorded_dt_tm <= now))
     SET reccnt += 1
     SET result->hmrecord[reccnt].recommendation_id = rep966307->person[1].hmrecord[idx].
     recommendation_id
     SET result->hmrecord[reccnt].recommendation_action_id = rep966307->person[1].hmrecord[idx].
     recommendation_action_id
     SET result->hmrecord[reccnt].modifier_id = rep966307->person[1].hmrecord[idx].modifier_id
     SET result->hmrecord[reccnt].modifier_type_cd = rep966307->person[1].hmrecord[idx].
     modifier_type_cd
     IF ((result->hmrecord[reccnt].modifier_type_cd > 0))
      SET result->hmrecord[reccnt].modifier_type_disp = uar_get_code_display(result->hmrecord[reccnt]
       .modifier_type_cd)
     ENDIF
     SET result->hmrecord[reccnt].expect_sched_id = rep966307->person[1].hmrecord[idx].schedule_id
     SET result->hmrecord[reccnt].expect_series_id = rep966307->person[1].hmrecord[idx].series_id
     SET result->hmrecord[reccnt].expect_id = rep966307->person[1].hmrecord[idx].expectation_id
     SET result->hmrecord[reccnt].expect_step_id = rep966307->person[1].hmrecord[idx].step_id
     SET result->hmrecord[reccnt].expect_ftdesc = rep966307->person[1].hmrecord[idx].
     expectation_ftdesc
     SET result->hmrecord[reccnt].status_flag = rep966307->person[1].hmrecord[idx].status_flag
     SET result->hmrecord[reccnt].status_text = evaluate(result->hmrecord[reccnt].status_flag,0,
      "Satisfied",1,"Postponed",
      4,"Canceled",5,"Other Satisfier",6,
      "Undone",7,"Refused",8,"System Canceled",
      "Unknown")
     SET result->hmrecord[reccnt].modifier_dt_tm = rep966307->person[1].hmrecord[idx].modifier_dt_tm
     SET result->hmrecord[reccnt].next_due_dt_tm = rep966307->person[1].hmrecord[idx].next_due_dt_tm
     SET result->hmrecord[reccnt].recorded_dt_tm = rep966307->person[1].hmrecord[idx].recorded_dt_tm
     SET result->hmrecord[reccnt].recorded_for_prsnl_id = rep966307->person[1].hmrecord[idx].
     recorded_for_prsnl_id
     SET result->hmrecord[reccnt].recorded_for_prsnl_name = rep966307->person[1].hmrecord[idx].
     recorded_for_prsnl_name
     SET result->hmrecord[reccnt].reason_cd = rep966307->person[1].hmrecord[idx].reason_cd
     IF ((result->hmrecord[reccnt].reason_cd > 0))
      SET result->hmrecord[reccnt].reason_disp = rep966307->person[1].hmrecord[idx].reason_disp
     ENDIF
     SET result->hmrecord[reccnt].comment = rep966307->person[1].hmrecord[idx].comment
     SET result->hmrecord[reccnt].clinical_event_id = rep966307->person[1].hmrecord[idx].
     clinical_event_id
     SET result->hmrecord[reccnt].satisfy_type = evaluate(result->hmrecord[reccnt].clinical_event_id,
      0.0,"Manual","Result")
     SET result->hmrecord[reccnt].priority = "Medium"
     SET pos = locateval(locidx,1,size(rep966307->person[1].reminder,5),rep966307->person[1].
      hmrecord[idx].recommendation_id,rep966307->person[1].reminder[locidx].recommendation_id)
     IF (pos > 0)
      SET result->hmrecord[reccnt].recommend_due_dt_tm = rep966307->person[1].reminder[pos].
      recommend_due_dt_tm
     ELSE
      SET result->hmrecord[reccnt].recommend_due_dt_tm = rep966307->person[1].hmrecord[idx].
      next_due_dt_tm
     ENDIF
    ENDIF
  ENDFOR
  SET stat = alterlist(result->hmrecord,reccnt)
 ENDIF
 SET result->status_data.status = rep966307->status_data.status
 FOR (idx = 1 TO reccnt)
  SET jdx = locateval(locidx,1,size(rep966302->sched,5),result->hmrecord[idx].expect_sched_id,
   rep966302->sched[locidx].expect_sched_id)
  IF (jdx > 0)
   SET kdx = locateval(locidx,1,size(rep966302->sched[jdx].series,5),result->hmrecord[idx].
    expect_series_id,rep966302->sched[jdx].series[locidx].expect_series_id)
   IF (kdx > 0)
    SET result->hmrecord[idx].expect_series_name = rep966302->sched[jdx].series[kdx].
    expect_series_name
    IF (textlen(trim(rep966302->sched[jdx].series[kdx].priority_disp,3)) > 0)
     SET result->hmrecord[idx].priority = rep966302->sched[jdx].series[kdx].priority_disp
    ENDIF
    SET ldx = locateval(locidx,1,size(rep966302->sched[jdx].series[kdx].expect,5),result->hmrecord[
     idx].expect_id,rep966302->sched[jdx].series[kdx].expect[locidx].expect_id)
    IF (ldx > 0)
     SET result->hmrecord[idx].expect_name = rep966302->sched[jdx].series[kdx].expect[ldx].
     expect_name
     SET mdx = locateval(locidx,1,size(rep966302->sched[jdx].series[kdx].expect[ldx].step,5),result->
      hmrecord[idx].expect_step_id,rep966302->sched[jdx].series[kdx].expect[ldx].step[locidx].
      expect_step_id)
     IF (mdx > 0)
      SET result->hmrecord[idx].expect_step_name = rep966302->sched[jdx].series[kdx].expect[ldx].
      step[mdx].expect_step_name
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 FOR (idx = 1 TO reccnt)
   SET result->hmrecord[idx].expect_name_disp = trim(evaluate(trim(result->hmrecord[idx].
      expect_ftdesc,3),"",evaluate(result->hmrecord[idx].expect_step_id,0.0,evaluate(result->
       hmrecord[idx].expect_id,0.0,result->hmrecord[idx].expect_series_name,result->hmrecord[idx].
       expect_name),result->hmrecord[idx].expect_step_name),result->hmrecord[idx].expect_ftdesc),3)
 ENDFOR
 DECLARE c_action_flag_undo_refusal = i2 WITH protect, constant(10)
 DECLARE c_action_flag_undo_cancellation = i2 WITH protect, constant(11)
 DECLARE c_action_flag_undo_satisfaction = i2 WITH protect, constant(12)
 DECLARE c_action_flag_undo_postpone = i2 WITH protect, constant(13)
 SELECT INTO "NL:"
  FROM hm_recommendation_action hra
  PLAN (hra
   WHERE expand(idx,1,reccnt,hra.recommendation_action_id,result->hmrecord[idx].
    recommendation_action_id))
  ORDER BY hra.recommendation_action_id
  HEAD hra.recommendation_action_id
   IF (((hra.action_flag=c_action_flag_undo_refusal) OR (((hra.action_flag=
   c_action_flag_undo_cancellation) OR (((hra.action_flag=c_action_flag_undo_satisfaction) OR (hra
   .action_flag=c_action_flag_undo_postpone)) )) ))
    AND hra.related_action_id > 0.0)
    pos = locateval(locidx,1,reccnt,hra.related_action_id,result->hmrecord[locidx].
     recommendation_action_id)
    IF (pos > 0)
     result->hmrecord[pos].parent_action_id = hra.recommendation_action_id
    ENDIF
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SET stat = sortresults(null)
 IF (stat=fail)
  GO TO exit_script
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
    FOR (idx = 1 TO size(result_seq->list,5))
      pos = result_seq->list[idx].ref_idx, col + 1, "<Recommendation>",
      row + 1, v1 = build("<RecommendationId>",cnvtint(result->hmrecord[pos].recommendation_id),
       "</RecommendationId>"), col + 1,
      v1, row + 1, v18 = build("<RecommendationActionId>",cnvtint(result->hmrecord[pos].
        recommendation_action_id),"</RecommendationActionId>"),
      col + 1, v18, row + 1,
      v19 = build("<ParentActionId>",cnvtint(result->hmrecord[pos].parent_action_id),
       "</ParentActionId>"), col + 1, v19,
      row + 1, v5 = build("<ExpectSeriesId>",cnvtint(result->hmrecord[pos].expect_series_id),
       "</ExpectSeriesId>"), col + 1,
      v5, row + 1, v2 = build("<ExpectId>",cnvtint(result->hmrecord[pos].expect_id),"</ExpectId>"),
      col + 1, v2, row + 1,
      v17 = build("<ExpectStepId>",cnvtint(result->hmrecord[pos].expect_step_id),"</ExpectStepId>"),
      col + 1, v17,
      row + 1, v3 = build("<ExpectationName>",trim(replace(replace(replace(replace(replace(result->
             hmrecord[pos].expect_name_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0
          ),'"',"&quot;",0),3),"</ExpectationName>"), col + 1,
      v3, row + 1, v4 = build("<FreeTextIndicator>",evaluate(trim(result->hmrecord[pos].expect_ftdesc,
         3),"","NO","YES"),"</FreeTextIndicator>"),
      col + 1, v4, row + 1,
      v6 = build("<StatusFlag>",result->hmrecord[pos].status_flag,"</StatusFlag>"), col + 1, v6,
      row + 1, v7 = build("<Status>",result->hmrecord[pos].status_text,"</Status>"), col + 1,
      v7, row + 1, v8 = build("<SatisfyType>",result->hmrecord[pos].satisfy_type,"</SatisfyType>"),
      col + 1, v8, row + 1,
      v9 = build("<AdminDate>",format(result->hmrecord[pos].modifier_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
       "</AdminDate>"), col + 1, v9,
      row + 1, v10 = build("<SatisfyReasonCd>",cnvtint(result->hmrecord[pos].reason_cd),
       "</SatisfyReasonCd>"), col + 1,
      v10, row + 1, v11 = build("<SatisfyReason>",trim(replace(replace(replace(replace(replace(result
             ->hmrecord[pos].reason_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
         '"',"&quot;",0),3),"</SatisfyReason>"),
      col + 1, v11, row + 1,
      v12 = build("<Priority>",trim(replace(replace(replace(replace(replace(result->hmrecord[pos].
             priority,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
       "</Priority>"), col + 1, v12,
      row + 1, v13 = build("<LastSatisfiedById>",cnvtint(result->hmrecord[pos].recorded_for_prsnl_id),
       "</LastSatisfiedById>"), col + 1,
      v13, row + 1, v14 = build("<LastSatisfiedBy>",trim(replace(replace(replace(replace(replace(
             result->hmrecord[pos].recorded_for_prsnl_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
          "'","&apos;",0),'"',"&quot;",0),3),"</LastSatisfiedBy>"),
      col + 1, v14, row + 1
      IF ((result->hmrecord[pos].next_due_dt_tm > 0.0))
       v15 = build("<ApproximateDate>",format(result->hmrecord[pos].next_due_dt_tm,
         "MM/DD/YYYY HH:MM:SS;;D"),"</ApproximateDate>")
      ELSE
       v15 = "<ApproximateDate></ApproximateDate>"
      ENDIF
      col + 1, v15, row + 1
      IF ((result->hmrecord[pos].next_due_dt_tm > 0.0))
       v20 = build("<ApproxDueDate>",format(result->hmrecord[pos].next_due_dt_tm,
         "MM/DD/YYYY HH:MM:SS;;D"),"</ApproxDueDate>")
      ELSE
       v20 = "<ApproxDueDate></ApproxDueDate>"
      ENDIF
      col + 1, v20, row + 1,
      v16 = build("<Comments>",trim(replace(replace(replace(replace(replace(result->hmrecord[pos].
             comment,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
       "</Comments>"), col + 1, v16,
      row + 1, col + 1, "</Recommendation>",
      row + 1
    ENDFOR
    col + 1, "</Recommendations>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD result_seq
 FREE RECORD req966307
 FREE RECORD rep966307
 FREE RECORD req966302
 FREE RECORD rep966302
 SUBROUTINE sortresults(null)
   DECLARE sortkey1 = vc WITH protect, noconstant("")
   DECLARE sortkey2 = dq8 WITH protect, noconstant(0.0)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   IF (size(result->hmrecord,5) > 0)
    SET stat = alterlist(result_seq->list,size(result->hmrecord,5))
    SELECT INTO "NL:"
     sortkey1 = concat(evaluate(trim(result->hmrecord[d.seq].expect_ftdesc,3),"",result->hmrecord[d
       .seq].expect_series_name,result->hmrecord[d.seq].expect_ftdesc),fillstring(100," ")), sortkey2
      = result->hmrecord[d.seq].modifier_dt_tm
     FROM (dummyt d  WITH seq = size(result->hmrecord,5))
     PLAN (d
      WHERE d.seq > 0)
     ORDER BY sortkey1, sortkey2 DESC
     DETAIL
      rcnt += 1, result_seq->list[rcnt].ref_idx = d.seq
     WITH nocounter, time = 30
    ;end select
   ENDIF
   CALL echorecord(result_seq)
   RETURN(success)
 END ;Subroutine
END GO
