CREATE PROGRAM bhs_sys_get_health_maint
 PROMPT
  "Enter PERSON_ID: " = 0.00,
  "Enter Schedule Type: " = 4,
  "Debug Mode: " = 0
  WITH pat_id, sched_type, debug_ind
 DECLARE debug_mode = i2
 IF (( $DEBUG_IND=1))
  SET debug_mode = 1
 ENDIF
 EXECUTE bhs_sys_exe_req_966403  $PAT_ID
 IF (size(hmd_reply->person,5) <= 0)
  CALL echo("Call to bhs_sys_exe_req_966403 failed.")
  GO TO exit_script
 ENDIF
 EXECUTE bhs_sys_exe_req_966302
 IF (size(hm_ref_reply->sched,5) <= 0)
  CALL echo("Call to bhs_sys_exe_req_966302 failed.")
  GO TO exit_script
 ENDIF
 RECORD tmp_reference(
   1 prsnl_ind = i2
   1 p_cnt = i4
   1 person[*]
     2 person_id = f8
     2 si_cnt = i4
     2 satisfied_items[*]
       3 hmd_reply_record_slot = i4
       3 recorded_prsnl_slot = i4
       3 created_prsnl_slot = i4
       3 hm_ref_sched_slot = i4
       3 hm_ref_series_slot = i4
       3 hm_ref_expect_slot = i4
       3 hm_ref_step_slot = i4
       3 hm_ref_satisfier_slot = i4
     2 pi_cnt = i4
     2 pending_items[*]
       3 hmd_reply_reminder_slot = i4
       3 last_sat_prsnl_slot = i4
       3 hm_ref_sched_slot = i4
       3 hm_ref_series_slot = i4
       3 hm_ref_expect_slot = i4
       3 hm_ref_step_slot = i4
       3 hm_ref_satisfier_slot = i4
     2 prsnl_cnt = i4
     2 prsnl[*]
       3 prsnl_id = f8
       3 name_full_formatted = vc
       3 type = vc
       3 item_slot = i4
 )
 DECLARE tmp_slot = i4
 DECLARE tmp_sched = i4
 DECLARE tmp_series = i4
 DECLARE tmp_expect = i4
 DECLARE tmp_step = i4
 SET tmp_reference->p_cnt = hmd_reply->p_cnt
 SET stat = alterlist(tmp_reference->person,tmp_reference->p_cnt)
 FOR (p = 1 TO hmd_reply->p_cnt)
   SET tmp_reference->person[p].person_id = hmd_reply->person[p].person_id
   SET tmp_reference->person[p].si_cnt = hmd_reply->person[p].rec_cnt
   SET stat = alterlist(tmp_reference->person[p].satisfied_items,tmp_reference->person[p].si_cnt)
   FOR (si = 1 TO tmp_reference->person[p].si_cnt)
     SET tmp_reference->person[p].satisfied_items[si].hmd_reply_record_slot = si
     IF ((hmd_reply->person[p].records[si].recorded_for_prsnl_id > 0.00))
      SET tmp_reference->prsnl_ind = 1
      SET tmp_reference->person[p].prsnl_cnt = (tmp_reference->person[p].prsnl_cnt+ 1)
      SET stat = alterlist(tmp_reference->person[p].prsnl,tmp_reference->person[p].prsnl_cnt)
      SET tmp_reference->person[p].satisfied_items[si].recorded_prsnl_slot = tmp_reference->person[p]
      .prsnl_cnt
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].prsnl_id = hmd_reply->
      person[p].records[si].recorded_for_prsnl_id
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].type = "RECORDED"
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].item_slot = si
     ENDIF
     IF ((hmd_reply->person[p].records[si].created_prsnl_id > 0.00))
      SET tmp_reference->prsnl_ind = 1
      SET tmp_reference->person[p].prsnl_cnt = (tmp_reference->person[p].prsnl_cnt+ 1)
      SET stat = alterlist(tmp_reference->person[p].prsnl,tmp_reference->person[p].prsnl_cnt)
      SET tmp_reference->person[p].satisfied_items[si].created_prsnl_slot = tmp_reference->person[p].
      prsnl_cnt
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].prsnl_id = hmd_reply->
      person[p].records[si].created_prsnl_id
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].type = "CREATED"
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].item_slot = si
     ENDIF
     FOR (x1 = 1 TO hm_ref_reply->sched_cnt)
       IF ((hm_ref_reply->sched[x1].expect_sched_id=hmd_reply->person[p].records[si].schedule_id))
        SET tmp_reference->person[p].satisfied_items[si].hm_ref_sched_slot = x1
        FOR (x2 = 1 TO hm_ref_reply->sched[x1].series_cnt)
          IF ((hm_ref_reply->sched[x1].series[x2].expect_series_id=hmd_reply->person[p].records[si].
          series_id))
           SET tmp_reference->person[p].satisfied_items[si].hm_ref_series_slot = x2
           FOR (x3 = 1 TO hm_ref_reply->sched[x1].series[x2].expect_cnt)
             IF ((hm_ref_reply->sched[x1].series[x2].expect[x3].expect_id=hmd_reply->person[p].
             records[si].expectation_id))
              SET tmp_reference->person[p].satisfied_items[si].hm_ref_expect_slot = x3
              FOR (x4 = 1 TO hm_ref_reply->sched[x1].series[x2].expect[x3].step_cnt)
                IF ((hm_ref_reply->sched[x1].series[x2].expect[x3].step[x4].expect_step_id=hmd_reply
                ->person[p].records[si].step_id))
                 SET tmp_reference->person[p].satisfied_items[si].hm_ref_step_slot = x4
                ENDIF
              ENDFOR
             ENDIF
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
   SET tmp_reference->person[p].pi_cnt = hmd_reply->person[p].rem_cnt
   SET stat = alterlist(tmp_reference->person[p].pending_items,tmp_reference->person[p].pi_cnt)
   FOR (pi = 1 TO tmp_reference->person[p].pi_cnt)
     SET tmp_reference->person[p].pending_items[pi].hmd_reply_reminder_slot = pi
     IF ((hmd_reply->person[p].reminders[pi].last_sat_prsnl_id > 0.00))
      SET tmp_reference->prsnl_ind = 1
      SET tmp_reference->person[p].prsnl_cnt = (tmp_reference->person[p].prsnl_cnt+ 1)
      SET stat = alterlist(tmp_reference->person[p].prsnl,tmp_reference->person[p].prsnl_cnt)
      SET tmp_reference->person[p].pending_items[pi].last_sat_prsnl_slot = tmp_reference->person[p].
      prsnl_cnt
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].prsnl_id = hmd_reply->
      person[p].reminders[pi].last_sat_prsnl_id
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].type = "LAST_SAT"
      SET tmp_reference->person[p].prsnl[tmp_reference->person[p].prsnl_cnt].item_slot = pi
     ENDIF
     FOR (x1 = 1 TO hm_ref_reply->sched_cnt)
       IF ((hm_ref_reply->sched[x1].expect_sched_id=hmd_reply->person[p].reminders[pi].schedule_id))
        SET tmp_reference->person[p].pending_items[pi].hm_ref_sched_slot = x1
        FOR (x2 = 1 TO hm_ref_reply->sched[x1].series_cnt)
          IF ((hm_ref_reply->sched[x1].series[x2].expect_series_id=hmd_reply->person[p].reminders[pi]
          .series_id))
           SET tmp_reference->person[p].pending_items[pi].hm_ref_series_slot = x2
           FOR (x3 = 1 TO hm_ref_reply->sched[x1].series[x2].expect_cnt)
             IF ((hm_ref_reply->sched[x1].series[x2].expect[x3].expect_id=hmd_reply->person[p].
             reminders[pi].expectation_id))
              SET tmp_reference->person[p].pending_items[pi].hm_ref_expect_slot = x3
              FOR (x4 = 1 TO hm_ref_reply->sched[x1].series[x2].expect[x3].step_cnt)
                IF ((hm_ref_reply->sched[x1].series[x2].expect[x3].step[x4].expect_step_id=hmd_reply
                ->person[p].reminders[pi].step_id))
                 SET tmp_reference->person[p].pending_items[pi].hm_ref_step_slot = x4
                ENDIF
              ENDFOR
             ENDIF
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 IF ((tmp_reference->prsnl_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(tmp_reference->p_cnt)),
    dummyt d2,
    prsnl pr
   PLAN (d1
    WHERE (tmp_reference->person[d1.seq].prsnl_cnt > 0)
     AND maxrec(d2,tmp_reference->person[d1.seq].prsnl_cnt))
    JOIN (d2)
    JOIN (pr
    WHERE (tmp_reference->person[d1.seq].prsnl[d2.seq].prsnl_id=pr.person_id))
   DETAIL
    tmp_reference->person[d1.seq].prsnl[d2.seq].name_full_formatted = trim(pr.name_full_formatted)
   WITH nocounter
  ;end select
 ENDIF
 RECORD bhs_health_maint(
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 birth_dt_tm = dq8
     2 satisfied_cnt = i4
     2 satisfied[*]
       3 schedule_id = f8
       3 schedule_desc = vc
       3 schedule_type = i2
       3 schedule_type_desc = vc
       3 series_id = f8
       3 series_desc = vc
       3 series_priority_desc = vc
       3 series_priority_seq = i4
       3 expect_id = f8
       3 expect_desc = vc
       3 step_id = f8
       3 step_desc = vc
       3 modifier_id = f8
       3 modifier_type = vc
       3 modifier_dt_tm = dq8
       3 recorded_dt_tm = dq8
       3 created_prsnl_id = f8
       3 created_prsnl_name = vc
       3 recorded_for_prsnl_id = f8
       3 recorded_for_prsnl_name = vc
       3 reason_cd = f8
       3 reason_desc = vc
       3 comment = vc
     2 pending_cnt = i4
     2 pending[*]
       3 schedule_id = f8
       3 schedule_desc = vc
       3 schedule_type = i2
       3 schedule_type_desc = vc
       3 series_id = f8
       3 series_desc = vc
       3 series_priority_desc = vc
       3 series_priority_seq = i4
       3 expect_id = f8
       3 expect_desc = vc
       3 step_id = f8
       3 step_desc = vc
       3 recommend_start_age = i4
       3 recommend_end_age = i4
       3 recommend_due_dt_tm = dq8
       3 overdue_dt_tm = dq8
       3 last_satisfied_dt_tm = dq8
       3 last_satisfied_prsnl_id = f8
       3 last_satisfied_prsnl_name = vc
       3 last_satisfied_comment = vc
 ) WITH persist
 DECLARE tmp_new_slot = i4
 DECLARE sched_type_ind = i4
 IF (( $SCHED_TYPE=1))
  SET sched_type_ind = 0
 ELSEIF (( $SCHED_TYPE=2))
  SET sched_type_ind = 1
 ELSEIF (( $SCHED_TYPE=3))
  SET sched_type_ind = 2
 ELSE
  SET sched_type_ind = - (1)
 ENDIF
 SET bhs_health_maint->person_cnt = tmp_reference->p_cnt
 SET stat = alterlist(bhs_health_maint->person,bhs_health_maint->person_cnt)
 FOR (p = 1 TO bhs_health_maint->person_cnt)
   SET bhs_health_maint->person[p].person_id = tmp_reference->person[p].person_id
   FOR (s = 1 TO tmp_reference->person[p].si_cnt)
     SET tmp_slot = tmp_reference->person[p].satisfied_items[s].hmd_reply_record_slot
     SET tmp_sched = tmp_reference->person[p].satisfied_items[s].hm_ref_sched_slot
     SET tmp_series = tmp_reference->person[p].satisfied_items[s].hm_ref_series_slot
     SET tmp_expect = tmp_reference->person[p].satisfied_items[s].hm_ref_expect_slot
     SET tmp_step = tmp_reference->person[p].satisfied_items[s].hm_ref_step_slot
     IF ((((sched_type_ind=- (1))) OR ((sched_type_ind=hm_ref_reply->sched[tmp_sched].
     expect_sched_type_flag))) )
      SET bhs_health_maint->person[p].satisfied_cnt = (bhs_health_maint->person[p].satisfied_cnt+ 1)
      SET stat = alterlist(bhs_health_maint->person[p].satisfied,bhs_health_maint->person[p].
       satisfied_cnt)
      SET tmp_new_slot = bhs_health_maint->person[p].satisfied_cnt
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].schedule_id = hm_ref_reply->sched[
      tmp_sched].expect_sched_id
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].schedule_desc = hm_ref_reply->sched[
      tmp_sched].expect_sched_name
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].schedule_type = hm_ref_reply->sched[
      tmp_sched].expect_sched_type_flag
      IF ((hm_ref_reply->sched[tmp_sched].expect_sched_type_flag=0))
       SET bhs_health_maint->person[p].satisfied[tmp_new_slot].schedule_type_desc =
       "Health Maintenance"
      ELSEIF ((hm_ref_reply->sched[tmp_sched].expect_sched_type_flag=1))
       SET bhs_health_maint->person[p].satisfied[tmp_new_slot].schedule_type_desc =
       "Child Immunizations"
      ELSEIF ((hm_ref_reply->sched[tmp_sched].expect_sched_type_flag=2))
       SET bhs_health_maint->person[p].satisfied[tmp_new_slot].schedule_type_desc =
       "Adult Immunizations"
      ELSE
       SET bhs_health_maint->person[p].satisfied[tmp_new_slot].schedule_type_desc = "Unknown"
      ENDIF
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].series_id = hm_ref_reply->sched[
      tmp_sched].series[tmp_series].expect_series_id
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].series_desc = hm_ref_reply->sched[
      tmp_sched].series[tmp_series].expect_series_name
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].series_priority_desc = hm_ref_reply->
      sched[tmp_sched].series[tmp_series].priority_disp
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].series_priority_seq = hm_ref_reply->
      sched[tmp_sched].series[tmp_series].priority_seq
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].expect_id = hm_ref_reply->sched[
      tmp_sched].series[tmp_series].expect[tmp_expect].expect_id
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].expect_desc = hm_ref_reply->sched[
      tmp_sched].series[tmp_series].expect[tmp_expect].expect_name
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].step_id = hm_ref_reply->sched[tmp_sched
      ].series[tmp_series].expect[tmp_expect].step[tmp_step].expect_step_id
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].step_desc = hm_ref_reply->sched[
      tmp_sched].series[tmp_series].expect[tmp_expect].step[tmp_step].expect_step_name
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].modifier_id = hmd_reply->person[p].
      records[tmp_slot].modifier_id
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].modifier_type = hmd_reply->person[p].
      records[tmp_slot].modifier_type_mean
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].modifier_dt_tm = hmd_reply->person[p].
      records[tmp_slot].modifier_dt_tm
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].recorded_dt_tm = hmd_reply->person[p].
      records[tmp_slot].recorded_dt_tm
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].created_prsnl_id = hmd_reply->person[p]
      .records[tmp_slot].created_prsnl_id
      IF ((tmp_reference->person[p].satisfied_items[s].created_prsnl_slot > 0))
       SET bhs_health_maint->person[p].satisfied[tmp_new_slot].created_prsnl_name = tmp_reference->
       person[p].prsnl[tmp_reference->person[p].satisfied_items[s].created_prsnl_slot].
       name_full_formatted
      ENDIF
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].recorded_for_prsnl_id = hmd_reply->
      person[p].records[tmp_slot].recorded_for_prsnl_id
      IF ((tmp_reference->person[p].satisfied_items[s].recorded_prsnl_slot > 0))
       SET bhs_health_maint->person[p].satisfied[tmp_new_slot].recorded_for_prsnl_name =
       tmp_reference->person[p].prsnl[tmp_reference->person[p].satisfied_items[s].recorded_prsnl_slot
       ].name_full_formatted
      ENDIF
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].reason_cd = hmd_reply->person[p].
      records[tmp_slot].reason_cd
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].reason_desc = hmd_reply->person[p].
      records[tmp_slot].reason_disp
      SET bhs_health_maint->person[p].satisfied[tmp_new_slot].comment = hmd_reply->person[p].records[
      tmp_slot].comment
     ENDIF
   ENDFOR
   FOR (x = 1 TO tmp_reference->person[p].pi_cnt)
     SET tmp_slot = tmp_reference->person[p].pending_items[x].hmd_reply_reminder_slot
     SET tmp_sched = tmp_reference->person[p].pending_items[x].hm_ref_sched_slot
     SET tmp_series = tmp_reference->person[p].pending_items[x].hm_ref_series_slot
     SET tmp_expect = tmp_reference->person[p].pending_items[x].hm_ref_expect_slot
     SET tmp_step = tmp_reference->person[p].pending_items[x].hm_ref_step_slot
     IF ((((sched_type_ind=- (1))) OR ((sched_type_ind=hm_ref_reply->sched[tmp_sched].
     expect_sched_type_flag))) )
      SET bhs_health_maint->person[p].pending_cnt = (bhs_health_maint->person[p].pending_cnt+ 1)
      SET stat = alterlist(bhs_health_maint->person[p].pending,bhs_health_maint->person[p].
       pending_cnt)
      SET tmp_new_slot = bhs_health_maint->person[p].pending_cnt
      SET bhs_health_maint->person[p].pending[tmp_new_slot].schedule_id = hm_ref_reply->sched[
      tmp_sched].expect_sched_id
      SET bhs_health_maint->person[p].pending[tmp_new_slot].schedule_desc = hm_ref_reply->sched[
      tmp_sched].expect_sched_name
      SET bhs_health_maint->person[p].pending[tmp_new_slot].schedule_type = hm_ref_reply->sched[
      tmp_sched].expect_sched_type_flag
      IF ((hm_ref_reply->sched[tmp_sched].expect_sched_type_flag=0))
       SET bhs_health_maint->person[p].pending[tmp_new_slot].schedule_type_desc =
       "Health Maintenance"
      ELSEIF ((hm_ref_reply->sched[tmp_sched].expect_sched_type_flag=1))
       SET bhs_health_maint->person[p].pending[tmp_new_slot].schedule_type_desc =
       "Child Immunizations"
      ELSEIF ((hm_ref_reply->sched[tmp_sched].expect_sched_type_flag=2))
       SET bhs_health_maint->person[p].pending[tmp_new_slot].schedule_type_desc =
       "Adult Immunizations"
      ELSE
       SET bhs_health_maint->person[p].pending[tmp_new_slot].schedule_type_desc = "Unknown"
      ENDIF
      SET bhs_health_maint->person[p].pending[tmp_new_slot].series_id = hm_ref_reply->sched[tmp_sched
      ].series[tmp_series].expect_series_id
      SET bhs_health_maint->person[p].pending[tmp_new_slot].series_desc = hm_ref_reply->sched[
      tmp_sched].series[tmp_series].expect_series_name
      SET bhs_health_maint->person[p].pending[tmp_new_slot].series_priority_desc = hm_ref_reply->
      sched[tmp_sched].series[tmp_series].priority_disp
      SET bhs_health_maint->person[p].pending[tmp_new_slot].series_priority_seq = hm_ref_reply->
      sched[tmp_sched].series[tmp_series].priority_seq
      SET bhs_health_maint->person[p].pending[tmp_new_slot].expect_id = hm_ref_reply->sched[tmp_sched
      ].series[tmp_series].expect[tmp_expect].expect_id
      SET bhs_health_maint->person[p].pending[tmp_new_slot].expect_desc = hm_ref_reply->sched[
      tmp_sched].series[tmp_series].expect[tmp_expect].expect_name
      SET bhs_health_maint->person[p].pending[tmp_new_slot].step_id = hm_ref_reply->sched[tmp_sched].
      series[tmp_series].expect[tmp_expect].step[tmp_step].expect_step_id
      SET bhs_health_maint->person[p].pending[tmp_new_slot].step_desc = hm_ref_reply->sched[tmp_sched
      ].series[tmp_series].expect[tmp_expect].step[tmp_step].expect_step_name
      SET bhs_health_maint->person[p].pending[tmp_new_slot].recommend_start_age = hmd_reply->person[p
      ].reminders[tmp_slot].recommend_start_age
      SET bhs_health_maint->person[p].pending[tmp_new_slot].recommend_end_age = hmd_reply->person[p].
      reminders[tmp_slot].recommend_end_age
      SET bhs_health_maint->person[p].pending[tmp_new_slot].recommend_due_dt_tm = hmd_reply->person[p
      ].reminders[tmp_slot].recommend_due_dt_tm
      SET bhs_health_maint->person[p].pending[tmp_new_slot].overdue_dt_tm = hmd_reply->person[p].
      reminders[tmp_slot].over_due_dt_tm
      SET bhs_health_maint->person[p].pending[tmp_new_slot].last_satisfied_dt_tm = hmd_reply->person[
      p].reminders[tmp_slot].last_sat_dt_tm
      SET bhs_health_maint->person[p].pending[tmp_new_slot].last_satisfied_prsnl_id = hmd_reply->
      person[p].reminders[tmp_slot].last_sat_prsnl_id
      IF ((tmp_reference->person[p].pending_items[x].last_sat_prsnl_slot > 0))
       SET bhs_health_maint->person[p].pending[tmp_new_slot].last_satisfied_prsnl_name =
       tmp_reference->person[p].prsnl[tmp_reference->person[p].pending_items[x].last_sat_prsnl_slot].
       name_full_formatted
      ENDIF
      SET bhs_health_maint->person[p].pending[tmp_new_slot].last_satisfied_comment = hmd_reply->
      person[p].reminders[tmp_slot].last_sat_comment
     ENDIF
   ENDFOR
 ENDFOR
 IF (validate(debug_mode,0)=1)
  CALL echorecord(tmp_reference)
 ENDIF
 FREE RECORD tmp_reference
 IF ((bhs_health_maint->person_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(bhs_health_maint->person_cnt)),
    person p
   PLAN (d
    WHERE (bhs_health_maint->person[d.seq].person_id > 0.00))
    JOIN (p
    WHERE (bhs_health_maint->person[d.seq].person_id=p.person_id))
   DETAIL
    bhs_health_maint->person[d.seq].name_full_formatted = trim(p.name_full_formatted),
    bhs_health_maint->person[d.seq].birth_dt_tm = p.birth_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(bhs_health_maint)
#exit_script
 CALL echo("Exiting Script")
END GO
