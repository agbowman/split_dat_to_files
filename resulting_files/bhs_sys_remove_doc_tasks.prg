CREATE PROGRAM bhs_sys_remove_doc_tasks
 FREE RECORD work
 RECORD work(
   1 total_tp_cnt = i4
   1 total_ap_cnt = i4
   1 total_ac_cnt = i4
   1 total_tp_process_1_cnt = i4
   1 total_tp_process_2_cnt = i4
   1 total_tp_process_3_cnt = i4
   1 total_ap_process_1_cnt = i4
   1 total_ap_process_2_cnt = i4
   1 total_ap_process_3_cnt = i4
   1 total_error_cnt = i4
   1 e_cnt = i4
   1 events[*]
     2 event_id = f8
     2 auth_ind = i2
     2 result_status_cd = f8
     2 tp_process_1_cnt = i4
     2 tp_process_2_cnt = i4
     2 tp_process_3_cnt = i4
     2 ap_process_1_cnt = i4
     2 ap_process_2_cnt = i4
     2 ap_process_3_cnt = i4
     2 error_cnt = i4
     2 tp_cnt = i4
     2 tasks_pending[*]
       3 task_id = f8
       3 taa_id = f8
       3 assign_prsnl_id = f8
       3 create_dt_tm = dq8
       3 taa_complete_ind = i2
       3 ap_slot = i4
       3 process_ind = i2
       3 updt_status = i2
     2 ap_cnt = i4
     2 actions_pending[*]
       3 cep_id = f8
       3 action_prsnl_id = f8
       3 action_status_cd = f8
       3 request_dt_tm = dq8
       3 valid_from_dt_tm = dq8
       3 tp_slot = i4
       3 process_ind = i2
       3 updt_status = i2
     2 ac_cnt = i4
     2 actions_completed[*]
       3 cep_id = f8
       3 action_prsnl_id = f8
       3 action_status_cd = f8
       3 action_dt_tm = dq8
       3 valid_from_dt_tm = dq8
 )
 FREE RECORD log_rec
 RECORD log_rec(
   1 r_cnt = i4
   1 rows[*]
     2 insert_dt_tm = dq8
     2 duration_secs = f8
     2 short_desc = vc
     2 full_desc = vc
 )
 DECLARE cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs21_sign_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE cs25_blob_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE cs25_long_blob_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"LONG_BLOB"))
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cs48_deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"DELETED"))
 DECLARE cs53_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE cs53_mdoc_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE cs79_deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"DELETED"))
 DECLARE cs79_onhold_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"ONHOLD"))
 DECLARE cs79_opened_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"OPENED"))
 DECLARE cs79_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE cs89_powerchart_cd = f8 WITH constant(uar_get_code_by("MEANING",89,"POWERCHART"))
 DECLARE cs103_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE cs103_deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"DELETED"))
 DECLARE cs103_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"PENDING"))
 DECLARE cs103_refused_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"REFUSED"))
 DECLARE cs103_requested_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"REQUESTED"))
 DECLARE cs6026_endorse_cd = f8 WITH constant(uar_get_code_by("MEANING",6026,"ENDORSE"))
 DECLARE cs6027_saved_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",6027,"SAVED DOC"))
 DECLARE beg_dt_tm = vc WITH noconstant(format(cnvtdatetime((curdate - 1),curtime3),";;Q"))
 DECLARE end_dt_tm = vc WITH noconstant(format(cnvtdatetime(curdate,curtime3),";;Q"))
 DECLARE testing_ind = i2 WITH constant(0)
 DECLARE log_file = vc WITH constant(build2("bhs_sys_remove_doc_tasks_",format(curdate,"YYYYMMDD;;D"),
   ".log"))
 DECLARE first_run = i2 WITH noconstant(1)
 DECLARE log_exists = i2 WITH noconstant(0)
 DECLARE add_to_log_rec(log_action=vc,log_msg=vc) = null
 SUBROUTINE add_to_log_rec(log_action,log_msg)
   SET log_rec->r_cnt = (log_rec->r_cnt+ 1)
   SET stat = alterlist(log_rec->rows,log_rec->r_cnt)
   SET log_rec->rows[log_rec->r_cnt].insert_dt_tm = sysdate
   SET log_rec->rows[log_rec->r_cnt].short_desc = trim(substring(1,100,log_action))
   SET log_rec->rows[log_rec->r_cnt].full_desc = trim(substring(1,3000,log_msg))
   IF ((log_rec->r_cnt=1))
    SET log_rec->rows[1].duration_secs = datetimediff(sysdate,log_rec->rows[1].insert_dt_tm,5)
   ELSE
    SET log_rec->rows[log_rec->r_cnt].duration_secs = datetimediff(sysdate,log_rec->rows[(log_rec->
     r_cnt - 1)].insert_dt_tm,5)
   ENDIF
 END ;Subroutine
 CALL add_to_log_rec("BEG PROGRAM",build2("Begin ",curprog))
 SELECT INTO "NL:"
  FROM task_activity ta,
   clinical_event ce,
   task_activity_assignment taa,
   task_activity ta2
  PLAN (ta
   WHERE ta.task_type_cd=cs6026_endorse_cd
    AND ta.task_status_cd IN (cs79_onhold_cd, cs79_opened_cd, cs79_pending_cd)
    AND ta.event_class_cd IN (cs53_doc_cd, cs53_mdoc_cd)
    AND ((ta.task_activity_cd+ 0)=cs6027_saved_doc_cd)
    AND ta.task_create_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND ta.msg_sender_id=0.00
    AND ta.active_status_prsnl_id=1.00
    AND ta.location_cd <= 0.00
    AND ta.reference_task_id <= 0.00
    AND ta.active_ind=1)
   JOIN (ce
   WHERE ta.event_id=ce.parent_event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.record_status_cd=cs48_active_cd
    AND ce.contributor_system_cd=cs89_powerchart_cd
    AND  EXISTS (
   (SELECT
    cbr.event_id
    FROM ce_blob_result cbr
    WHERE ce.event_id=cbr.event_id
     AND cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND cbr.storage_cd IN (cs25_long_blob_cd, cs25_blob_cd))))
   JOIN (ta2
   WHERE ta.event_id=ta2.event_id
    AND ta2.task_type_cd=cs6026_endorse_cd
    AND ta2.task_status_cd IN (cs79_onhold_cd, cs79_opened_cd, cs79_pending_cd)
    AND ta2.event_class_cd IN (cs53_doc_cd, cs53_mdoc_cd)
    AND ((ta2.task_activity_cd+ 0)=cs6027_saved_doc_cd)
    AND ta2.msg_sender_id=0.00
    AND ta2.active_status_prsnl_id=1.00
    AND ta2.location_cd <= 0.00
    AND ta2.reference_task_id <= 0.00
    AND ta2.active_ind=1)
   JOIN (taa
   WHERE ta2.task_id=taa.task_id
    AND taa.end_eff_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY ta2.event_id, ta2.task_create_dt_tm, ta2.task_id
  HEAD REPORT
   e_cnt = 0, tp_cnt = 0, sp_cnt = 0
  HEAD ta2.event_id
   e_cnt = (work->e_cnt+ 1), stat = alterlist(work->events,e_cnt), work->e_cnt = e_cnt,
   work->events[e_cnt].event_id = ta2.event_id, work->events[e_cnt].result_status_cd = ce
   .result_status_cd
   IF (uar_get_code_display(ce.result_status_cd)="INERROR")
    work->events[e_cnt].auth_ind = - (1)
   ELSEIF (ce.result_status_cd IN (cs8_auth_cd, cs8_modified_cd, cs8_altered_cd))
    work->events[e_cnt].auth_ind = 1
   ENDIF
   tp_cnt = 0, sp_cnt = 0
  HEAD ta2.task_id
   tp_cnt = (work->events[e_cnt].tp_cnt+ 1), stat = alterlist(work->events[e_cnt].tasks_pending,
    tp_cnt), work->events[e_cnt].tp_cnt = tp_cnt,
   work->events[e_cnt].tasks_pending[tp_cnt].task_id = ta2.task_id, work->events[e_cnt].
   tasks_pending[tp_cnt].taa_id = taa.task_activity_assign_id, work->events[e_cnt].tasks_pending[
   tp_cnt].assign_prsnl_id = taa.assign_prsnl_id,
   work->events[e_cnt].tasks_pending[tp_cnt].create_dt_tm = ta2.task_create_dt_tm
   IF ( NOT (taa.task_status_cd IN (cs79_onhold_cd, cs79_opened_cd, cs79_pending_cd)))
    work->events[e_cnt].tasks_pending[tp_cnt].taa_complete_ind = 1
   ENDIF
   IF ((work->events[e_cnt].auth_ind < 0))
    work->events[e_cnt].tasks_pending[tp_cnt].process_ind = 1
   ENDIF
  FOOT  ta2.event_id
   work->total_tp_cnt = (work->total_tp_cnt+ tp_cnt)
  WITH nocounter
 ;end select
 CALL add_to_log_rec("END TASK_ACTIVITY SELECT",build2("Completed select of TASK_ACTIVITY table|",
   "Found ",trim(build2(work->e_cnt),3)," task(s) for ",trim(build2(work->total_tp_cnt),3),
   " event(s)"))
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   ce_event_prsnl cep
  PLAN (d
   WHERE (work->events[d.seq].auth_ind >= 0))
   JOIN (cep
   WHERE (work->events[d.seq].event_id=cep.event_id)
    AND cep.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ((cep.request_prsnl_id <= 1.00) OR (cep.request_prsnl_id=cep.action_prsnl_id))
    AND cep.action_type_cd=cs21_sign_cd
    AND cep.action_status_cd IN (cs103_requested_cd, cs103_pending_cd, cs103_refused_cd,
   cs103_completed_cd))
  ORDER BY cep.event_id
  HEAD REPORT
   new_entry_ind = 1, ap_cnt = 0, ac_cnt = 0,
   tmp_slot = 0, tmp_ap_slot = 0
  HEAD cep.event_id
   new_entry_ind = 1, ap_cnt = 0, ac_cnt = 0,
   tmp_slot = 0, tmp_ap_slot = 0
  DETAIL
   new_entry_ind = 1
   IF (cep.action_status_cd IN (cs103_requested_cd, cs103_pending_cd))
    ap_cnt = (work->events[d.seq].ap_cnt+ 1), stat = alterlist(work->events[d.seq].actions_pending,
     ap_cnt), work->events[d.seq].ap_cnt = ap_cnt,
    work->events[d.seq].actions_pending[ap_cnt].cep_id = cep.ce_event_prsnl_id, work->events[d.seq].
    actions_pending[ap_cnt].action_prsnl_id = cep.action_prsnl_id, work->events[d.seq].
    actions_pending[ap_cnt].action_status_cd = cep.action_status_cd,
    work->events[d.seq].actions_pending[ap_cnt].request_dt_tm = cep.request_dt_tm, work->events[d.seq
    ].actions_pending[ap_cnt].valid_from_dt_tm = cep.valid_from_dt_tm, tmp_slot = work->events[d.seq]
    .tp_cnt
    WHILE (tmp_slot > 0)
     IF ((work->events[d.seq].tasks_pending[tmp_slot].assign_prsnl_id=cep.action_prsnl_id)
      AND (work->events[d.seq].tasks_pending[tmp_slot].ap_slot=0))
      work->events[d.seq].tasks_pending[tmp_slot].ap_slot = ap_cnt, work->events[d.seq].
      actions_pending[ap_cnt].tp_slot = tmp_slot, tmp_slot = 0
     ENDIF
     ,tmp_slot = (tmp_slot - 1)
    ENDWHILE
   ELSE
    work->events[d.seq].auth_ind = 1
    FOR (ac = 1 TO work->events[d.seq].ac_cnt)
      IF ((cep.action_prsnl_id=work->events[d.seq].actions_completed[ac].action_prsnl_id)
       AND (cep.action_status_cd=work->events[d.seq].actions_completed[ac].action_status_cd))
       new_entry_ind = 0
       IF (cep.action_dt_tm != null
        AND (cep.action_dt_tm <= work->events[d.seq].actions_completed[ac].action_dt_tm))
        work->events[d.seq].actions_completed[ac].cep_id = cep.ce_event_prsnl_id, work->events[d.seq]
        .actions_completed[ac].action_dt_tm = cep.action_dt_tm
       ENDIF
      ENDIF
    ENDFOR
    IF (new_entry_ind=1)
     ac_cnt = (work->events[d.seq].ac_cnt+ 1), stat = alterlist(work->events[d.seq].actions_completed,
      ac_cnt), work->events[d.seq].ac_cnt = ac_cnt,
     work->events[d.seq].actions_completed[ac_cnt].cep_id = cep.ce_event_prsnl_id, work->events[d.seq
     ].actions_completed[ac_cnt].action_prsnl_id = cep.action_prsnl_id, work->events[d.seq].
     actions_completed[ac_cnt].action_status_cd = cep.action_status_cd,
     work->events[d.seq].actions_completed[ac_cnt].action_dt_tm = cep.action_dt_tm, work->events[d
     .seq].actions_completed[ac_cnt].valid_from_dt_tm = cep.valid_from_dt_tm
    ENDIF
   ENDIF
  FOOT  cep.event_id
   work->total_ap_cnt = (work->total_ap_cnt+ ap_cnt), work->total_ac_cnt = (work->total_ac_cnt+
   ac_cnt)
   FOR (tp = 1 TO work->events[d.seq].tp_cnt)
     IF ((work->events[d.seq].tasks_pending[tp].ap_slot=0))
      work->events[d.seq].tasks_pending[tp].process_ind = 1, work->events[d.seq].tp_process_1_cnt = (
      work->events[d.seq].tp_process_1_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (ap = 1 TO work->events[d.seq].ap_cnt)
     IF ((work->events[d.seq].actions_pending[ap].tp_slot=0))
      work->events[d.seq].actions_pending[ap].process_ind = 1, work->events[d.seq].ap_process_1_cnt
       = (work->events[d.seq].ap_process_1_cnt+ 1)
     ENDIF
   ENDFOR
   IF ((work->events[d.seq].auth_ind != 0))
    FOR (ap = 1 TO work->events[d.seq].ap_cnt)
      IF ((work->events[d.seq].actions_pending[ap].process_ind=0))
       work->events[d.seq].actions_pending[ap].process_ind = 2, work->events[d.seq].ap_process_2_cnt
        = (work->events[d.seq].ap_process_2_cnt+ 1), work->events[d.seq].tasks_pending[work->events[d
       .seq].actions_pending[ap].tp_slot].process_ind = 2,
       work->events[d.seq].tp_process_2_cnt = (work->events[d.seq].tp_process_2_cnt+ 1)
      ENDIF
    ENDFOR
   ELSE
    tmp_ap_slot = 0, tmp_slot = work->events[d.seq].ap_cnt
    WHILE (tmp_ap_slot=0)
     IF (tmp_slot <= 0)
      tmp_ap_slot = - (1)
     ELSEIF ((work->events[d.seq].actions_pending[tmp_slot].process_ind=0))
      tmp_ap_slot = tmp_slot
     ENDIF
     ,tmp_slot = (tmp_slot - 1)
    ENDWHILE
    IF (tmp_ap_slot > 1)
     FOR (ap = 1 TO (tmp_ap_slot - 1))
       IF ((work->events[d.seq].actions_pending[ap].process_ind=0))
        work->events[d.seq].actions_pending[ap].process_ind = 3, work->events[d.seq].ap_process_3_cnt
         = (work->events[d.seq].ap_process_3_cnt+ 1), work->events[d.seq].tasks_pending[work->events[
        d.seq].actions_pending[ap].tp_slot].process_ind = 3,
        work->events[d.seq].tp_process_3_cnt = (work->events[d.seq].tp_process_3_cnt+ 1)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   work->total_tp_process_1_cnt = (work->total_tp_process_1_cnt+ work->events[d.seq].tp_process_1_cnt
   ), work->total_ap_process_1_cnt = (work->total_ap_process_1_cnt+ work->events[d.seq].
   ap_process_1_cnt), work->total_tp_process_2_cnt = (work->total_tp_process_2_cnt+ work->events[d
   .seq].tp_process_2_cnt),
   work->total_ap_process_2_cnt = (work->total_ap_process_2_cnt+ work->events[d.seq].ap_process_2_cnt
   ), work->total_tp_process_3_cnt = (work->total_tp_process_3_cnt+ work->events[d.seq].
   tp_process_3_cnt), work->total_ap_process_3_cnt = (work->total_ap_process_3_cnt+ work->events[d
   .seq].ap_process_3_cnt)
  WITH nocounter
 ;end select
 CALL add_to_log_rec("END CE_EVENT_PRSNL SELECT",build2("Completed select of CE_EVENT_PRSNL table|",
   "Found ",trim(build2(work->total_ap_cnt),3)," pending/in process action(s)|",trim(build2(((work->
     total_tp_process_1_cnt+ work->total_tp_process_2_cnt)+ work->total_tp_process_3_cnt)),3),
   " pending task(s) to delete & ",trim(build2(((work->total_ap_process_1_cnt+ work->
     total_ap_process_2_cnt)+ work->total_ap_process_3_cnt)),3)," pending action(s) to delete"))
 DECLARE update_taa_row(event_slot=i4,task_slot=i4) = null
 DECLARE update_ta_row(event_slot=i4,task_slot=i4) = null
 DECLARE update_cep_row(event_slot=i4,task_slot=i4) = null
 SUBROUTINE update_taa_row(event_slot,task_slot)
  UPDATE  FROM task_activity_assignment taa
   SET taa.task_status_cd = cs79_deleted_cd, taa.end_eff_dt_tm = sysdate
   WHERE (taa.task_activity_assign_id=work->events[event_slot].tasks_pending[task_slot].taa_id)
   WITH nocounter, status(work->events[event_slot].tasks_pending[task_slot].updt_status)
  ;end update
  IF (testing_ind=1)
   IF ((work->events[event_slot].tasks_pending[task_slot].updt_status != 1))
    CALL add_to_log_rec("    TESTING - TAA UPDATE UNSUCCESSFUL",build2("TASK_ACTIVITY_ASSIGNMENT (",
      trim(build2(work->events[event_slot].tasks_pending[task_slot].taa_id),3),")",
      " update error. Changes rolled back due to testing mode."))
    SET work->events[event_slot].tasks_pending[task_slot].updt_status = - (1)
   ELSE
    CALL add_to_log_rec("    TESTING - TAA UPDATE SUCCESSFUL",build2("TASK_ACTIVITY_ASSIGNMENT (",
      trim(build2(work->events[event_slot].tasks_pending[task_slot].taa_id),3),")",
      " update statement successful. Changes rolled back due to testing mode."))
   ENDIF
  ELSE
   IF ((work->events[event_slot].tasks_pending[task_slot].updt_status != 1))
    CALL add_to_log_rec("    TAA UPDATE UNSUCCESSFUL",build2("TASK_ACTIVITY_ASSIGNMENT (",trim(build2
       (work->events[event_slot].tasks_pending[task_slot].taa_id),3),")",
      " update error. Changes rolled back."))
    SET work->events[event_slot].tasks_pending[task_slot].updt_status = - (1)
   ELSE
    CALL add_to_log_rec("    TAA UPDATE SUCCESSFUL",build2("TASK_ACTIVITY_ASSIGNMENT (",trim(build2(
        work->events[event_slot].tasks_pending[task_slot].taa_id),3),")",
      " update statement successful."))
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE update_ta_row(event_slot,task_slot)
  UPDATE  FROM task_activity ta
   SET ta.task_status_cd = cs79_deleted_cd, ta.active_ind = 0, ta.active_status_cd = cs48_deleted_cd,
    ta.updt_dt_tm = sysdate
   WHERE (ta.task_id=work->events[event_slot].tasks_pending[task_slot].task_id)
   WITH nocounter, status(work->events[event_slot].tasks_pending[task_slot].updt_status)
  ;end update
  IF (testing_ind=1)
   IF ((work->events[event_slot].tasks_pending[task_slot].updt_status != 1))
    CALL add_to_log_rec("    TESTING - TA UPDATE UNSUCCESSFUL",build2("TASK_ACTIVITY (",trim(build2(
        work->events[event_slot].tasks_pending[task_slot].task_id),3),")",
      " update error. Changes rolled back due to testing mode."))
    SET work->events[event_slot].tasks_pending[task_slot].updt_status = - (1)
   ELSE
    CALL add_to_log_rec("    TESTING - TA UPDATE SUCCESSFUL",build2("TASK_ACTIVITY (",trim(build2(
        work->events[event_slot].tasks_pending[task_slot].task_id),3),")",
      " update statement successful. Changes rolled back due to testing mode."))
   ENDIF
  ELSE
   IF ((work->events[event_slot].tasks_pending[task_slot].updt_status != 1))
    CALL add_to_log_rec("    TA UPDATE UNSUCCESSFUL",build2("TASK_ACTIVITY (",trim(build2(work->
        events[event_slot].tasks_pending[task_slot].task_id),3),")",
      " update error. Changes rolled back."))
    SET work->events[event_slot].tasks_pending[task_slot].updt_status = - (1)
   ELSE
    CALL add_to_log_rec("    TA UPDATE SUCCESSFUL",build2("TASK_ACTIVITY (",trim(build2(work->events[
        event_slot].tasks_pending[task_slot].task_id),3),")"," update statement successful."))
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE update_cep_row(event_slot,action_slot)
  UPDATE  FROM ce_event_prsnl cep
   SET cep.action_status_cd = cs103_deleted_cd, cep.valid_until_dt_tm = sysdate, cep.system_comment
     = "Action Deleted by BHS_SYS_REMOVE_DOC_TASKS",
    cep.updt_dt_tm = sysdate
   WHERE (cep.ce_event_prsnl_id=work->events[event_slot].actions_pending[action_slot].cep_id)
   WITH nocounter, status(work->events[event_slot].actions_pending[action_slot].updt_status)
  ;end update
  IF (testing_ind=1)
   IF ((work->events[event_slot].actions_pending[action_slot].updt_status != 1))
    CALL add_to_log_rec("    TESTING - CEP UPDATE UNSUCCESSFUL",build2("CE_EVENT_PRSNL (",trim(build2
       (work->events[event_slot].actions_pending[action_slot].cep_id),3),")",
      " update error. Changes rolled back due to testing mode."))
    SET work->events[event_slot].actions_pending[action_slot].updt_status = - (1)
   ELSE
    CALL add_to_log_rec("    TESTING - CEP UPDATE SUCCESSFUL",build2("CE_EVENT_PRSNL (",trim(build2(
        work->events[event_slot].actions_pending[action_slot].cep_id),3),")",
      " update statement successful. Changes rolled back due to testing mode."))
   ENDIF
  ELSE
   IF ((work->events[event_slot].actions_pending[action_slot].updt_status != 1))
    CALL add_to_log_rec("    CEP UPDATE UNSUCCESSFUL",build2("CE_EVENT_PRSNL (",trim(build2(work->
        events[event_slot].actions_pending[action_slot].cep_id),3),")",
      " update error.  Changes rolled back."))
    SET work->events[event_slot].actions_pending[action_slot].updt_status = - (1)
   ELSE
    CALL add_to_log_rec("    CEP UPDATE SUCCESSFUL",build2("CE_EVENT_PRSNL (",trim(build2(work->
        events[event_slot].actions_pending[action_slot].cep_id),3),")",
      " update statement successful."))
   ENDIF
  ENDIF
 END ;Subroutine
 DECLARE tmp_log = vc
 IF (((((((work->total_tp_process_1_cnt+ work->total_ap_process_1_cnt)+ work->total_tp_process_2_cnt)
 + work->total_ap_process_2_cnt)+ work->total_tp_process_3_cnt)+ work->total_ap_process_3_cnt) > 0))
  FOR (e = 1 TO work->e_cnt)
   IF (((((((work->events[e].tp_process_1_cnt+ work->events[e].ap_process_1_cnt)+ work->events[e].
   tp_process_2_cnt)+ work->events[e].ap_process_2_cnt)+ work->events[e].tp_process_3_cnt)+ work->
   events[e].ap_process_3_cnt) > 0))
    SET tmp_log = " "
    IF ((work->events[e].tp_process_1_cnt > 0))
     IF (tmp_log > " ")
      SET tmp_log = build2(trim(build2(work->events[e].tp_process_1_cnt),3),
       " task(s) without a action")
     ELSE
      SET tmp_log = build2(tmp_log,", ",trim(build2(work->events[e].tp_process_1_cnt),3),
       " task(s) without a action")
     ENDIF
    ENDIF
    IF ((work->events[e].ap_process_1_cnt > 0))
     IF (tmp_log > " ")
      SET tmp_log = build2(tmp_log,", ",trim(build2(work->events[e].ap_process_1_cnt),3),
       " action(s) without a task")
     ELSE
      SET tmp_log = build2(trim(build2(work->events[e].ap_process_1_cnt),3),
       " action(s) without a task")
     ENDIF
    ENDIF
    IF ((work->events[e].ap_process_2_cnt > 0))
     IF (tmp_log > " ")
      SET tmp_log = build2(tmp_log,", ",trim(build2(work->events[e].ap_process_2_cnt),3),
       " task(s)/action(s) for in errored or signed documents")
     ELSE
      SET tmp_log = build2(trim(build2(work->events[e].ap_process_2_cnt),3),
       " task(s)/action(s) for in errored or signed documents")
     ENDIF
    ENDIF
    IF ((work->events[e].ap_process_3_cnt > 0))
     IF (tmp_log > " ")
      SET tmp_log = build2(tmp_log,", ",trim(build2(work->events[e].ap_process_3_cnt),3),
       " task(s)/action(s) for documents with newer sign requests")
     ELSE
      SET tmp_log = build2(trim(build2(work->events[e].ap_process_3_cnt),3),
       " task(s)/action(s) for documents with newer sign requests")
     ENDIF
    ENDIF
    CALL add_to_log_rec("  BEG PROCESSING EVENT",build2("Processing Event_ID ",trim(build2(work->
        events[e].event_id),3)," (",tmp_log,")"))
    IF ((work->events[e].tp_process_1_cnt > 0))
     FOR (tp = 1 TO work->events[e].tp_cnt)
       IF ((work->events[e].tasks_pending[tp].process_ind=1))
        CALL update_taa_row(e,tp)
        IF ((work->events[e].tasks_pending[tp].updt_status=1))
         CALL update_ta_row(e,tp)
         IF ((work->events[e].tasks_pending[tp].updt_status != 1))
          ROLLBACK
         ELSE
          COMMIT
         ENDIF
        ELSE
         ROLLBACK
         IF (testing_ind=1)
          CALL add_to_log_rec("    TESTING - TA UPDATE UNSUCCESSFUL",
           "TASK_ACTIVITY update not done due to TASK_ACTIVITY_ASSIGNMENT error.")
         ELSE
          CALL add_to_log_rec("    TA UPDATE UNSUCCESSFUL",
           "TASK_ACTIVITY update not done due to TASK_ACTIVITY_ASSIGNMENT error.")
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF ((((((work->events[e].ap_process_1_cnt+ work->events[e].tp_process_2_cnt)+ work->events[e].
    ap_process_2_cnt)+ work->events[e].tp_process_3_cnt)+ work->events[e].ap_process_3_cnt) >= 0))
     FOR (ap = 1 TO work->events[e].ap_cnt)
       IF ((work->events[e].actions_pending[ap].process_ind=1))
        CALL update_cep_row(e,ap)
        IF ((work->events[e].actions_pending[ap].updt_status != 1))
         ROLLBACK
        ELSE
         COMMIT
        ENDIF
       ELSEIF ((work->events[e].actions_pending[ap].process_ind IN (2, 3)))
        CALL update_taa_row(e,work->events[e].actions_pending[ap].tp_slot)
        IF ((work->events[e].tasks_pending[work->events[e].actions_pending[ap].tp_slot].updt_status
         != 1))
         ROLLBACK
         IF (testing_ind=1)
          CALL add_to_log_rec("    TESTING - TA UPDATE UNSUCCESSFUL",
           "TASK_ACTIVITY update not done due to TASK_ACTIVITY_ASSIGNMENT error.")
          CALL add_to_log_rec("    TESTING - CEP UPDATE UNSUCCESSFUL",
           "CE_EVENT_PRSNL update not done due to TASK_ACTIVITY_ASSIGNMENT error.")
         ELSE
          CALL add_to_log_rec("    TA UPDATE UNSUCCESSFUL",
           "TASK_ACTIVITY update not done due to TASK_ACTIVITY_ASSIGNMENT error.")
          CALL add_to_log_rec("    TESTING - CEP UPDATE UNSUCCESSFUL",
           "CE_EVENT_PRSNL update not done due to TASK_ACTIVITY_ASSIGNMENT error.")
         ENDIF
        ELSE
         CALL update_ta_row(e,work->events[e].actions_pending[ap].tp_slot)
         IF ((work->events[e].tasks_pending[work->events[e].actions_pending[ap].tp_slot].updt_status
          != 1))
          ROLLBACK
          IF (testing_ind=1)
           CALL add_to_log_rec("    TESTING - CEP UPDATE UNSUCCESSFUL",
            "CE_EVENT_PRSNL update not done due to TASK_ACTIVITY error.")
          ELSE
           CALL add_to_log_rec("    CEP UPDATE UNSUCCESSFUL",
            "CE_EVENT_PRSNL update not done due to TASK_ACTIVITY error.")
          ENDIF
         ELSE
          CALL update_cep_row(e,ap)
          IF ((work->events[e].actions_pending[ap].updt_status != 1))
           ROLLBACK
           IF (testing_ind=1)
            CALL add_to_log_rec("    TESTING - CEP UPDATE UNSUCCESSFUL",
             "CE_EVENT_PRSNL update not done due to TASK_ACTIVITY error.")
           ELSE
            CALL add_to_log_rec("    TA UPDATE UNSUCCESSFUL",
             "CE_EVENT_PRSNL update not done due to TASK_ACTIVITY error.")
           ENDIF
          ELSE
           COMMIT
          ENDIF
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   SET work->total_error_cnt = (work->total_error_cnt+ work->events[e].error_cnt)
  ENDFOR
 ENDIF
 SET tmp_log = " "
 SET tmp_log = cost(3)
 CALL add_to_log_rec("END PROGRAM",tmp_log)
 SET log_exists = findfile(log_file)
 SELECT INTO value(log_file)
  FROM dummyt d
  HEAD REPORT
   IF (log_exists=0)
    col 0, "LOG_DT_TM", col 25,
    "DURATION", col 39, "ACTION",
    col 141, "MESSAGE"
   ENDIF
  DETAIL
   FOR (r = 1 TO log_rec->r_cnt)
     row + 1, col 0,
     CALL print(format(log_rec->rows[r].insert_dt_tm,";;Q")),
     col 25,
     CALL print(format(log_rec->rows[r].duration_secs,"#######.####")), col 39,
     CALL print(substring(1,100,log_rec->rows[r].short_desc)), col 141,
     CALL print(trim(log_rec->rows[r].full_desc,3))
   ENDFOR
  WITH append, maxcol = 32000, maxrow = 1,
   formfeed = none, format = variable
 ;end select
 CALL echorecord(work,"remove_doc_tasks.rs")
#exit_script
END GO
