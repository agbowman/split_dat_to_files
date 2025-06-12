CREATE PROGRAM bed_ens_fn_events:dba
 FREE SET reply
 RECORD reply(
   1 grp_list[*]
     2 tracking_group_code_value = f8
     2 evt_list[*]
       3 track_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 RECORD trackcoll(
   1 ids[*]
     2 track_coll_id = f8
 )
 SET reply->status_data.status = "F"
 SET prov_rel_cd = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.cdf_meaning="PRVRELN"
  DETAIL
   prov_rel_cd = cv.code_value
  WITH nocounter
 ;end select
 SET evt_trigger_cd = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20320
   AND cv.cdf_meaning="EVT_TRIGGER"
  DETAIL
   evt_trigger_cd = cv.code_value
  WITH nocounter
 ;end select
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
  DETAIL
   IF (cv.cdf_meaning="ACTIVE")
    active_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INACTIVE")
    inactive_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET req_cnt = 0
 SET req_cnt = size(request->tglist,5)
 SET stat = alterlist(reply->grp_list,req_cnt)
 FOR (t = 1 TO req_cnt)
   SET reply->grp_list[t].tracking_group_code_value = request->tglist[t].tracking_group_code_value
   SET evt_cnt = 0
   SET evt_cnt = size(request->tglist[t].elist,5)
   SET stat = alterlist(reply->grp_list[t].evt_list,evt_cnt)
   FOR (e = 1 TO evt_cnt)
     SET pcnt = 0
     SET pcnt = size(request->tglist[t].elist[e].plist,5)
     SET ccnt = 0
     SET ccnt = size(request->tglist[t].elist[e].clist,5)
     IF ((request->tglist[t].elist[e].action_flag=1))
      SET track_coll_id = 0.0
      IF (ccnt > 0)
       SELECT INTO "nl:"
        z = seq(tracking_seq,nextval)
        FROM dual
        DETAIL
         track_coll_id = cnvtreal(z)
        WITH format, nocounter
       ;end select
       INSERT  FROM track_collection tc
        SET tc.track_collection_id = track_coll_id, tc.tracking_group_cd = request->tglist[t].
         tracking_group_code_value, tc.description = request->tglist[t].elist[e].event_name,
         tc.display = request->tglist[t].elist[e].event_name, tc.collection_type_cd = evt_trigger_cd,
         tc.active_ind = 1,
         tc.active_status_dt_tm = cnvtdatetime(curdate,curtime), tc.active_status_prsnl_id = 0.0, tc
         .active_status_cd = active_cd,
         tc.updt_id = reqinfo->updt_id, tc.updt_dt_tm = cnvtdatetime(curdate,curtime), tc.updt_task
          = reqinfo->updt_task,
         tc.updt_cnt = 0, tc.updt_applctx = reqinfo->updt_applctx, tc.color_num = 0,
         tc.sequence_num = 0
        WITH nocounter
       ;end insert
      ENDIF
      SET track_event_id = 0.0
      SELECT INTO "nl:"
       z = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        track_event_id = cnvtreal(z)
       WITH format, nocounter
      ;end select
      INSERT  FROM track_event te
       SET te.track_event_id = track_event_id, te.tracking_group_cd = request->tglist[t].
        tracking_group_code_value, te.active_ind = request->tglist[t].elist[e].active_ind,
        te.description = request->tglist[t].elist[e].event_name, te.display = request->tglist[t].
        elist[e].event_name, te.display_key = cnvtupper(cnvtalphanum(request->tglist[t].elist[e].
          event_name)),
        te.tracking_event_type_cd = request->tglist[t].elist[e].event_type_code_value, te
        .normal_color = "255,255,255", te.normal_icon = request->tglist[t].elist[e].normal_icon,
        te.overdue_interval = request->tglist[t].elist[e].time_to_overdue_secs, te.overdue_color =
        request->tglist[t].elist[e].overdue_color, te.overdue_icon = request->tglist[t].elist[e].
        overdue_icon,
        te.critical_interval = request->tglist[t].elist[e].time_to_critical_secs, te.critical_color
         = request->tglist[t].elist[e].critical_color, te.critical_icon = request->tglist[t].elist[e]
        .critical_icon,
        te.def_request_loc_cd = 0, te.def_begin_loc_cd = 0, te.def_next_event_id = track_coll_id,
        te.event_use_mean_cd = 0, te.show_on_monitor_ind = null, te.auto_complete_ind = request->
        tglist[t].elist[e].auto_complete_ind,
        te.complete_on_exit_ind = 0, te.event_priority_rank = null, te.final_transaction_ind = null,
        te.flex_location_cd = 0, te.updt_id = reqinfo->updt_id, te.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        te.updt_task = reqinfo->updt_task, te.updt_cnt = 0, te.updt_applctx = reqinfo->updt_applctx,
        te.auto_start_ind = request->tglist[t].elist[e].auto_start_ind, te.critical_blink_ind =
        request->tglist[t].elist[e].critical_ind, te.overdue_blink_ind = request->tglist[t].elist[e].
        overdue_ind,
        te.clinic_event_cd = 0, te.hide_event_ind = 0, te.stage_cd = 0,
        te.single_use_ind = 0, te.sequence_num = 0, te.request_icon_id = 0,
        te.request_color_num = 0, te.single_state_ind = 0, te.start_color_num = 0,
        te.complete_color_num = 0, te.start_icon_id = 0, te.complete_icon_id = 0
       WITH nocounter
      ;end insert
      SET reply->grp_list[t].evt_list[e].track_event_id = track_event_id
      IF (pcnt > 0)
       FOR (p = 1 TO pcnt)
         IF ((request->tglist[t].elist[e].plist[p].provider_display > " "))
          UPDATE  FROM track_reference tr
           SET tr.assoc_code_value = track_event_id
           WHERE (tr.tracking_group_cd=request->tglist[t].tracking_group_code_value)
            AND tr.tracking_ref_type_cd=prov_rel_cd
            AND tr.display_key=cnvtupper(cnvtalphanum(request->tglist[t].elist[e].plist[p].
             provider_display))
           WITH nocounter
          ;end update
         ENDIF
       ENDFOR
      ENDIF
     ELSEIF ((request->tglist[t].elist[e].action_flag=2))
      UPDATE  FROM track_reference tr
       SET tr.assoc_code_value = 0.0
       WHERE (tr.tracking_group_cd=request->tglist[t].tracking_group_code_value)
        AND tr.tracking_ref_type_cd=prov_rel_cd
        AND (tr.assoc_code_value=request->tglist[t].elist[e].track_event_id)
       WITH nocounter
      ;end update
      IF (pcnt > 0)
       FOR (p = 1 TO pcnt)
         IF ((request->tglist[t].elist[e].plist[p].provider_display > " "))
          UPDATE  FROM track_reference tr
           SET tr.assoc_code_value = request->tglist[t].elist[e].track_event_id
           WHERE (tr.tracking_group_cd=request->tglist[t].tracking_group_code_value)
            AND tr.tracking_ref_type_cd=prov_rel_cd
            AND tr.display_key=cnvtupper(cnvtalphanum(request->tglist[t].elist[e].plist[p].
             provider_display))
           WITH nocounter
          ;end update
         ENDIF
       ENDFOR
      ENDIF
      SET tcnt = 0
      SELECT INTO "nl:"
       FROM track_collection tc
       WHERE (tc.tracking_group_cd=request->tglist[t].tracking_group_code_value)
        AND (tc.description=request->tglist[t].elist[e].event_name)
       DETAIL
        tcnt = (tcnt+ 1), stat = alterlist(trackcoll->ids,tcnt), trackcoll->ids[tcnt].track_coll_id
         = tc.track_collection_id
       WITH nocounter
      ;end select
      IF (tcnt > 0)
       DELETE  FROM track_collection tc,
         (dummyt d  WITH seq = value(tcnt))
        SET tc.seq = 1
        PLAN (d)
         JOIN (tc
         WHERE (tc.track_collection_id=trackcoll->ids[d.seq].track_coll_id))
        WITH nocounter
       ;end delete
       DELETE  FROM track_collection_element tce,
         (dummyt d  WITH seq = value(tcnt))
        SET tce.seq = 1
        PLAN (d)
         JOIN (tce
         WHERE (tce.track_collection_id=trackcoll->ids[d.seq].track_coll_id)
          AND tce.element_table="TRACK_EVENT")
        WITH nocounter
       ;end delete
      ENDIF
      SET track_coll_id = 0.0
      IF (ccnt > 0)
       SELECT INTO "nl:"
        z = seq(tracking_seq,nextval)
        FROM dual
        DETAIL
         track_coll_id = cnvtreal(z)
        WITH format, nocounter
       ;end select
       INSERT  FROM track_collection tc
        SET tc.track_collection_id = track_coll_id, tc.tracking_group_cd = request->tglist[t].
         tracking_group_code_value, tc.description = request->tglist[t].elist[e].event_name,
         tc.display = request->tglist[t].elist[e].event_name, tc.collection_type_cd = evt_trigger_cd,
         tc.active_ind = 1,
         tc.active_status_dt_tm = cnvtdatetime(curdate,curtime), tc.active_status_prsnl_id = 0.0, tc
         .active_status_cd = active_cd,
         tc.updt_id = reqinfo->updt_id, tc.updt_dt_tm = cnvtdatetime(curdate,curtime), tc.updt_task
          = reqinfo->updt_task,
         tc.updt_cnt = 0, tc.updt_applctx = reqinfo->updt_applctx, tc.color_num = 0,
         tc.sequence_num = 0
        WITH nocounter
       ;end insert
      ENDIF
      UPDATE  FROM track_event te
       SET te.active_ind = request->tglist[t].elist[e].active_ind, te.description = request->tglist[t
        ].elist[e].event_name, te.display = request->tglist[t].elist[e].event_name,
        te.display_key = cnvtupper(cnvtalphanum(request->tglist[t].elist[e].event_name)), te
        .normal_icon = request->tglist[t].elist[e].normal_icon, te.overdue_interval = request->
        tglist[t].elist[e].time_to_overdue_secs,
        te.overdue_color = request->tglist[t].elist[e].overdue_color, te.overdue_icon = request->
        tglist[t].elist[e].overdue_icon, te.critical_interval = request->tglist[t].elist[e].
        time_to_critical_secs,
        te.critical_color = request->tglist[t].elist[e].critical_color, te.critical_icon = request->
        tglist[t].elist[e].critical_icon, te.critical_blink_ind = request->tglist[t].elist[e].
        critical_ind,
        te.overdue_blink_ind = request->tglist[t].elist[e].overdue_ind, te.auto_complete_ind =
        request->tglist[t].elist[e].auto_complete_ind, te.auto_start_ind = request->tglist[t].elist[e
        ].auto_start_ind,
        te.def_next_event_id = track_coll_id, te.tracking_event_type_cd = request->tglist[t].elist[e]
        .event_type_code_value, te.updt_id = reqinfo->updt_id,
        te.updt_dt_tm = cnvtdatetime(curdate,curtime), te.updt_task = reqinfo->updt_task, te.updt_cnt
         = (te.updt_cnt+ 1),
        te.updt_applctx = reqinfo->updt_applctx
       WHERE (te.track_event_id=request->tglist[t].elist[e].track_event_id)
        AND (te.tracking_group_cd=request->tglist[t].tracking_group_code_value)
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
   FOR (e = 1 TO evt_cnt)
     SET ccnt = 0
     SET ccnt = size(request->tglist[t].elist[e].clist,5)
     IF (ccnt > 0)
      SET track_coll_id = 0.0
      SELECT INTO "NL:"
       FROM track_collection tc
       WHERE (tc.tracking_group_cd=request->tglist[t].tracking_group_code_value)
        AND (tc.description=request->tglist[t].elist[e].event_name)
        AND (tc.display=request->tglist[t].elist[e].event_name)
        AND tc.collection_type_cd=evt_trigger_cd
        AND tc.active_ind=1
       DETAIL
        track_coll_id = tc.track_collection_id
       WITH nocounter
      ;end select
      FOR (c = 1 TO ccnt)
       IF ((request->tglist[t].elist[e].clist[c].track_event_id=0))
        SELECT INTO "NL:"
         FROM track_event te
         WHERE (te.display=request->tglist[t].elist[e].clist[c].event_name)
          AND (te.tracking_group_cd=request->tglist[t].tracking_group_code_value)
         DETAIL
          request->tglist[t].elist[e].clist[c].track_event_id = te.track_event_id
         WITH nocounter
        ;end select
       ENDIF
       INSERT  FROM track_collection_element tce
        SET tce.track_collection_element_id = seq(tracking_seq,nextval), tce.track_collection_id =
         track_coll_id, tce.element_value = request->tglist[t].elist[e].clist[c].track_event_id,
         tce.element_table = "TRACK_EVENT", tce.element_status_cd = 0, tce.updt_id = reqinfo->updt_id,
         tce.updt_dt_tm = cnvtdatetime(curdate,curtime), tce.updt_task = reqinfo->updt_task, tce
         .updt_cnt = 0,
         tce.updt_applctx = reqinfo->updt_applctx, tce.sequence_num = 0, tce.active_ind = 1,
         tce.active_status_dt_tm = cnvtdatetime(curdate,curtime), tce.active_status_prsnl_id = 0.0,
         tce.active_status_cd = active_cd
        WITH nocounter
       ;end insert
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
