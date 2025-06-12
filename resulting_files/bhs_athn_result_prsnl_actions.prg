CREATE PROGRAM bhs_athn_result_prsnl_actions
 RECORD orequest(
   1 query_mode = i4
   1 query_mode_ind = i2
   1 event_id = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 dataset_uid = vc
   1 subtable_bit_map = i4
   1 subtable_bit_map_ind = i2
   1 valid_from_dt_tm = dq8
   1 valid_from_dt_tm_ind = i2
   1 decode_flag = i2
   1 ordering_provider_id = f8
   1 action_prsnl_id = f8
   1 event_id_list[*]
     2 event_id = f8
   1 action_type_cd_list[*]
     2 action_type_cd = f8
   1 src_event_id_ind = i2
   1 action_prsnl_group_id = f8
   1 query_mode2 = i4
   1 event_uuid = vc
 )
 RECORD t_record(
   1 event_cnt = i4
   1 events[*]
     2 event_id = f8
   1 action_cnt = i4
   1 actions[*]
     2 event_prsnl_action_id = vc
     2 action_type_disp = vc
     2 action_type_mean = vc
     2 action_type_value = vc
     2 action_dt_tm1 = dq8
     2 action_dt_tm = vc
     2 action_status_disp = vc
     2 action_status_mean = vc
     2 action_status_value = vc
     2 action_prsnl = vc
     2 action_prsnl_id = vc
     2 action_prsnl_ft = vc
     2 position_disp = vc
     2 position_mean = vc
     2 position_value = vc
     2 physician_ind = vc
     2 request_prsnl_id = vc
     2 request_comment = vc
     2 proxy_prsnl_id = vc
 )
 RECORD out_rec(
   1 event_prsnl[*]
     2 event_prsnl_action_id = vc
     2 action_type_disp = vc
     2 action_type_mean = vc
     2 action_type_value = vc
     2 action_dt_tm = vc
     2 action_status_disp = vc
     2 action_status_mean = vc
     2 action_status_value = vc
     2 action_prsnl = vc
     2 action_prsnl_id = vc
     2 action_prsnl_ft = vc
     2 position_disp = vc
     2 position_mean = vc
     2 position_value = vc
     2 physician_ind = vc
     2 request_prsnl_id = vc
     2 request_comment = vc
     2 proxy_prsnl_id = vc
 )
 DECLARE c_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",24,"C"))
 DECLARE r_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",24,"R"))
 DECLARE radiology_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"RADIOLOGY"))
 DECLARE grp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"GRP"))
 DECLARE event_id = f8
 SET event_id =  $2
 DECLARE reltn_type = f8
 DECLARE event_class_type = f8
 DECLARE done_ind = i2
 DECLARE cur_event_id = f8
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.event_id=event_id
    AND ce.valid_until_dt_tm > sysdate)
  HEAD REPORT
   t_record->event_cnt = 1, stat = alterlist(t_record->events,t_record->event_cnt), t_record->events[
   t_record->event_cnt].event_id = ce.event_id,
   reltn_type = ce.event_reltn_cd, event_class_type = ce.event_class_cd
  WITH nocounter, time = 30
 ;end select
 CALL echo(reltn_type)
 IF (event_class_type=radiology_cd)
  SELECT INTO "nl:"
   FROM ce_linked_result clr,
    clinical_event ce,
    clinical_event ce1
   PLAN (clr
    WHERE clr.event_id=event_id)
    JOIN (ce
    WHERE ce.event_id=clr.linked_event_id
     AND ce.valid_until_dt_tm > sysdate)
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id
     AND ce1.valid_until_dt_tm > sysdate)
   HEAD REPORT
    t_record->event_cnt = (t_record->event_cnt+ 1), stat = alterlist(t_record->events,t_record->
     event_cnt), t_record->events[t_record->event_cnt].event_id = ce.event_id,
    t_record->event_cnt = (t_record->event_cnt+ 1), stat = alterlist(t_record->events,t_record->
     event_cnt), t_record->events[t_record->event_cnt].event_id = ce1.event_id
   WITH nocounter, time = 30
  ;end select
  GO TO process_events
 ENDIF
 IF (reltn_type=c_cd)
  SET cur_event_id =  $2
  SET cnt = 0
  WHILE (done_ind=0
   AND cnt < 20)
   SET cnt = (cnt+ 1)
   SELECT INTO "nl:"
    FROM clinical_event ce,
     clinical_event ce1
    PLAN (ce
     WHERE ce.event_id=cur_event_id
      AND ce.valid_until_dt_tm > sysdate)
     JOIN (ce1
     WHERE ce1.event_id=ce.parent_event_id
      AND ce1.valid_until_dt_tm > sysdate)
    HEAD ce1.event_id
     cur_event_id = ce1.event_id
     IF (ce1.event_class_cd=grp_cd
      AND ce1.event_reltn_cd=r_cd)
      done_ind = 1, t_record->event_cnt = (t_record->event_cnt+ 1), stat = alterlist(t_record->events,
       t_record->event_cnt),
      t_record->events[t_record->event_cnt].event_id = ce1.event_id
     ENDIF
    WITH nocounter, time = 30
   ;end select
  ENDWHILE
  GO TO process_events
 ENDIF
#process_events
 FOR (i = 1 TO t_record->event_cnt)
   FREE RECORD oreply
   SET orequest->event_id = t_record->events[i].event_id
   SET orequest->query_mode = 1
   SET orequest->valid_from_dt_tm_ind = 1
   SET orequest->subtable_bit_map_ind = 1
   SET stat = tdbexecute(3200000,3200200,1000011,"REC",orequest,
    "REC",oreply)
   IF (size(oreply->rb_list.event_prsnl_list,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(oreply->rb_list.event_prsnl_list,5)),
      prsnl pr
     PLAN (d)
      JOIN (pr
      WHERE (pr.person_id=oreply->rb_list.event_prsnl_list[d.seq].action_prsnl_id))
     DETAIL
      t_record->action_cnt = (t_record->action_cnt+ 1), stat = alterlist(t_record->actions,t_record->
       action_cnt), a_cnt = t_record->action_cnt,
      t_record->actions[a_cnt].event_prsnl_action_id = cnvtstring(oreply->rb_list.event_prsnl_list[d
       .seq].event_prsnl_id), t_record->actions[a_cnt].action_type_disp = uar_get_code_display(oreply
       ->rb_list.event_prsnl_list[d.seq].action_type_cd), t_record->actions[a_cnt].action_type_mean
       = uar_get_code_meaning(oreply->rb_list.event_prsnl_list[d.seq].action_type_cd),
      t_record->actions[a_cnt].action_type_value = cnvtstring(oreply->rb_list.event_prsnl_list[d.seq]
       .action_type_cd), t_record->actions[a_cnt].action_dt_tm1 = oreply->rb_list.event_prsnl_list[d
      .seq].action_dt_tm, t_record->actions[a_cnt].action_dt_tm = datetimezoneformat(oreply->rb_list.
       event_prsnl_list[d.seq].action_dt_tm,oreply->rb_list.event_end_tz,"MM/dd/yyyy HH:mm:ss",
       curtimezonedef),
      t_record->actions[a_cnt].action_status_disp = uar_get_code_display(oreply->rb_list.
       event_prsnl_list[d.seq].action_status_cd), t_record->actions[a_cnt].action_status_mean =
      uar_get_code_meaning(oreply->rb_list.event_prsnl_list[d.seq].action_status_cd), t_record->
      actions[a_cnt].action_status_value = cnvtstring(oreply->rb_list.event_prsnl_list[d.seq].
       action_status_cd),
      t_record->actions[a_cnt].action_prsnl = pr.name_full_formatted, t_record->actions[a_cnt].
      action_prsnl_id = cnvtstring(pr.person_id), t_record->actions[a_cnt].action_prsnl_ft = oreply->
      rb_list.event_prsnl_list[d.seq].action_prsnl_ft,
      t_record->actions[a_cnt].position_disp = uar_get_code_display(pr.position_cd), t_record->
      actions[a_cnt].position_mean = uar_get_code_meaning(pr.position_cd), t_record->actions[a_cnt].
      position_value = cnvtstring(pr.position_cd),
      t_record->actions[a_cnt].physician_ind = cnvtstring(pr.physician_ind), t_record->actions[a_cnt]
      .request_prsnl_id = cnvtstring(oreply->rb_list.event_prsnl_list[d.seq].request_prsnl_id),
      t_record->actions[a_cnt].request_comment = oreply->rb_list.event_prsnl_list[d.seq].
      request_comment,
      t_record->actions[a_cnt].proxy_prsnl_id = cnvtstring(oreply->rb_list.event_prsnl_list[d.seq].
       proxy_prsnl_id)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  action_dt_tm = t_record->actions[d.seq].action_dt_tm1, action_type = t_record->actions[d.seq].
  action_type_disp, action_status = t_record->actions[d.seq].action_status_disp,
  action_prsnl = t_record->actions[d.seq].action_prsnl
  FROM (dummyt d  WITH seq = t_record->action_cnt)
  PLAN (d)
  ORDER BY action_dt_tm, action_type, action_status,
   action_prsnl
  HEAD REPORT
   a_cnt = 0
  HEAD action_type
   null
  HEAD action_status
   null
  HEAD action_prsnl
   IF (event_class_type=radiology_cd
    AND (t_record->actions[d.seq].action_type_disp="Order"))
    x = 1
   ELSE
    a_cnt = (a_cnt+ 1), stat = alterlist(out_rec->event_prsnl,a_cnt), out_rec->event_prsnl[a_cnt].
    event_prsnl_action_id = t_record->actions[d.seq].event_prsnl_action_id,
    out_rec->event_prsnl[a_cnt].action_type_disp = t_record->actions[d.seq].action_type_disp, out_rec
    ->event_prsnl[a_cnt].action_type_mean = t_record->actions[d.seq].action_type_mean, out_rec->
    event_prsnl[a_cnt].action_type_value = t_record->actions[d.seq].action_type_value,
    out_rec->event_prsnl[a_cnt].action_dt_tm = t_record->actions[d.seq].action_dt_tm, out_rec->
    event_prsnl[a_cnt].action_status_disp = t_record->actions[d.seq].action_status_disp, out_rec->
    event_prsnl[a_cnt].action_status_mean = t_record->actions[d.seq].action_status_mean,
    out_rec->event_prsnl[a_cnt].action_status_value = t_record->actions[d.seq].action_status_value,
    out_rec->event_prsnl[a_cnt].action_prsnl = t_record->actions[d.seq].action_prsnl, out_rec->
    event_prsnl[a_cnt].action_prsnl_id = t_record->actions[d.seq].action_prsnl_id,
    out_rec->event_prsnl[a_cnt].action_prsnl_ft = t_record->actions[d.seq].action_prsnl_ft, out_rec->
    event_prsnl[a_cnt].position_disp = t_record->actions[d.seq].position_disp, out_rec->event_prsnl[
    a_cnt].position_mean = t_record->actions[d.seq].position_mean,
    out_rec->event_prsnl[a_cnt].position_value = t_record->actions[d.seq].position_value, out_rec->
    event_prsnl[a_cnt].physician_ind = t_record->actions[d.seq].physician_ind, out_rec->event_prsnl[
    a_cnt].request_prsnl_id = t_record->actions[d.seq].request_prsnl_id,
    out_rec->event_prsnl[a_cnt].request_comment = t_record->actions[d.seq].request_comment, out_rec->
    event_prsnl[a_cnt].proxy_prsnl_id = t_record->actions[d.seq].proxy_prsnl_id
   ENDIF
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
