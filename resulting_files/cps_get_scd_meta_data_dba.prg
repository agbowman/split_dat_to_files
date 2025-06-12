CREATE PROGRAM cps_get_scd_meta_data:dba
 RECORD reply(
   1 notes[*]
     2 scd_story_id = f8
     2 event_id = f8
     2 encntr_id = f8
     2 update_lock_user_id = f8
     2 update_lock_dt_tm = dq8
     2 result_status_cd = f8
     2 result_status_mean = vc
     2 result_status_disp = vc
     2 author_id = f8
     2 event_end_dt_tm = dq8
     2 event_end_tz = i4
     2 event_title_text = vc
     2 story_completion_status_cd = f8
     2 story_completion_status_mean = vc
     2 story_completion_status_disp = vc
     2 patient_id = f8
     2 event_cd = f8
     2 story_type_cd = f8
     2 story_type_mean = vc
     2 entry_mode_cd = f8
     2 action_providers[*]
       3 id = f8
       3 type_cd = f8
       3 action_provider_date = dq8
       3 action_provider_tz = i4
       3 provider_id = f8
       3 provider_name = vc
       3 status_cd = f8
       3 pool_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 )
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
 DECLARE scd_db_query_type_name = i4 WITH public, constant(1)
 DECLARE scd_db_query_type_nomen = i4 WITH public, constant(2)
 DECLARE scd_db_query_type_concept = i4 WITH public, constant(3)
 DECLARE scd_db_active = i4 WITH public, constant(1)
 DECLARE scd_db_inactive = i4 WITH public, constant(0)
 DECLARE scd_db_true = i4 WITH public, constant(1)
 DECLARE scd_db_false = i4 WITH public, constant(0)
 DECLARE scd_db_update_lock_lock = i4 WITH public, constant(1)
 DECLARE scd_db_update_lock_override = i4 WITH public, constant(2)
 DECLARE scd_db_update_lock_read_only = i4 WITH public, constant(3)
 DECLARE scd_db_action_type_add = c3 WITH public, constant("ADD")
 DECLARE scd_db_action_type_delete = c3 WITH public, constant("DEL")
 DECLARE scd_db_action_type_update = c3 WITH public, constant("UPD")
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt = (reply->cps_error.cnt+ 1)
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE id_idx = i4 WITH protect, noconstant(0)
 DECLARE reply_size = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH protect, constant(5)
 DECLARE datestring = vc WITH constant("31-DEC-2100 00:00:00")
 DECLARE cur_story_size = i4 WITH protect, constant(size(request->stories,5))
 DECLARE loop_story_count = i4 WITH protect, constant(ceil((cnvtreal(cur_story_size)/ expand_size)))
 DECLARE new_story_size = i4 WITH protect, constant((loop_story_count * expand_size))
 DECLARE cur_event_size = i4 WITH protect, constant(size(request->events,5))
 DECLARE cur_note = i4 WITH protect, noconstant(0)
 DECLARE ap_count = i4 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 IF (cur_story_size=0
  AND cur_event_size=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No IDs In Request",cps_insuf_data_msg,0,
   0,0)
  SET failed = 1
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->notes,(cur_story_size+ cur_event_size))
 IF (cur_story_size != 0)
  IF (cur_story_size != new_story_size)
   SET stat = alterlist(request->stories,new_story_size)
   FOR (id_idx = (cur_story_size+ 1) TO new_story_size)
     SET request->stories[id_idx].scd_story_id = 0.0
   ENDFOR
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_story_count)),
    scd_story s,
    clinical_event ce
   PLAN (d
    WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
    JOIN (s
    WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),s.scd_story_id,request->
     stories[expand_idx].scd_story_id))
    JOIN (ce
    WHERE ce.event_id=s.event_id
     AND ((ce.clinical_event_id=0.0) OR (ce.valid_until_dt_tm=cnvtdatetime(datestring))) )
   DETAIL
    IF (s.scd_story_id != 0.0)
     reply_size = (reply_size+ 1), reply->notes[reply_size].scd_story_id = s.scd_story_id, reply->
     notes[reply_size].event_id = s.event_id,
     reply->notes[reply_size].update_lock_user_id = s.update_lock_user_id, reply->notes[reply_size].
     update_lock_dt_tm = s.update_lock_dt_tm
     IF (ce.event_id != 0.0)
      reply->notes[reply_size].encntr_id = ce.encntr_id, reply->notes[reply_size].event_end_dt_tm =
      ce.event_end_dt_tm, reply->notes[reply_size].event_end_tz = ce.event_end_tz,
      reply->notes[reply_size].event_title_text = ce.event_title_text, reply->notes[reply_size].
      result_status_cd = ce.result_status_cd, reply->notes[reply_size].result_status_mean =
      uar_get_code_meaning(ce.result_status_cd),
      reply->notes[reply_size].result_status_disp = uar_get_code_display(ce.result_status_cd), reply
      ->notes[reply_size].event_cd = ce.event_cd
     ENDIF
     reply->notes[reply_size].author_id = s.author_id, reply->notes[reply_size].
     story_completion_status_cd = s.story_completion_status_cd, reply->notes[reply_size].
     story_completion_status_mean = uar_get_code_meaning(s.story_completion_status_cd),
     reply->notes[reply_size].story_completion_status_disp = uar_get_code_display(s
      .story_completion_status_cd), reply->notes[reply_size].patient_id = s.person_id, reply->notes[
     reply_size].story_type_cd = s.story_type_cd,
     reply->notes[reply_size].story_type_mean = uar_get_code_meaning(s.story_type_cd), reply->notes[
     reply_size].entry_mode_cd = s.entry_mode_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cur_event_size != 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cur_event_size)),
    scd_story s,
    clinical_event ce
   PLAN (d)
    JOIN (s
    WHERE (s.event_id=request->events[d.seq].event_id))
    JOIN (ce
    WHERE ce.event_id=s.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime(datestring))
   DETAIL
    IF (s.event_id != 0.0)
     reply_size = (reply_size+ 1), reply->notes[reply_size].scd_story_id = s.scd_story_id, reply->
     notes[reply_size].event_id = s.event_id,
     reply->notes[reply_size].encntr_id = ce.encntr_id, reply->notes[reply_size].update_lock_user_id
      = s.update_lock_user_id, reply->notes[reply_size].update_lock_dt_tm = s.update_lock_dt_tm,
     reply->notes[reply_size].event_end_dt_tm = ce.event_end_dt_tm, reply->notes[reply_size].
     event_end_tz = ce.event_end_tz, reply->notes[reply_size].event_title_text = ce.event_title_text,
     reply->notes[reply_size].result_status_cd = ce.result_status_cd, reply->notes[reply_size].
     result_status_mean = uar_get_code_meaning(ce.result_status_cd), reply->notes[reply_size].
     result_status_disp = uar_get_code_display(ce.result_status_cd),
     reply->notes[reply_size].event_cd = ce.event_cd, reply->notes[reply_size].author_id = s
     .author_id, reply->notes[reply_size].story_completion_status_cd = s.story_completion_status_cd,
     reply->notes[reply_size].story_completion_status_mean = uar_get_code_meaning(s
      .story_completion_status_cd), reply->notes[reply_size].story_completion_status_disp =
     uar_get_code_display(s.story_completion_status_cd), reply->notes[reply_size].patient_id = s
     .person_id,
     reply->notes[reply_size].story_type_cd = s.story_type_cd, reply->notes[reply_size].
     story_type_mean = uar_get_code_meaning(s.story_type_cd), reply->notes[reply_size].entry_mode_cd
      = s.entry_mode_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->notes,reply_size)
 SET expand_idx = 0
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep
  PLAN (cep
   WHERE expand(expand_idx,0,reply_size,cep.event_id,reply->notes[expand_idx].event_id)
    AND cep.valid_until_dt_tm=cnvtdatetime(datestring)
    AND cep.event_id != 0.0)
  ORDER BY cep.event_id
  DETAIL
   ap_count = (ap_count+ 1)
   FOR (cur_note = 1 TO reply_size BY 1)
     IF ((reply->notes[cur_note].event_id=cep.event_id))
      IF (ap_count > size(reply->notes[cur_note].action_providers,5))
       stat = alterlist(reply->notes[cur_note].action_providers,(ap_count+ 5))
      ENDIF
      reply->notes[cur_note].action_providers[ap_count].id = cep.event_prsnl_id, reply->notes[
      cur_note].action_providers[ap_count].type_cd = cep.action_type_cd, reply->notes[cur_note].
      action_providers[ap_count].action_provider_date = cep.action_dt_tm,
      reply->notes[cur_note].action_providers[ap_count].action_provider_tz = cep.action_tz, reply->
      notes[cur_note].action_providers[ap_count].provider_id = cep.action_prsnl_id, reply->notes[
      cur_note].action_providers[ap_count].provider_name = cep.action_prsnl_ft,
      reply->notes[cur_note].action_providers[ap_count].status_cd = cep.action_status_cd, reply->
      notes[cur_note].action_providers[ap_count].pool_id = cep.action_prsnl_group_id, stat =
      alterlist(reply->notes[cur_note].action_providers,ap_count)
     ENDIF
   ENDFOR
  FOOT  cep.event_id
   ap_count = 0
  WITH nocounter, expand = 1
 ;end select
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
