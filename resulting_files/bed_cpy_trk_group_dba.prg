CREATE PROGRAM bed_cpy_trk_group:dba
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
 FREE SET reply
 RECORD reply(
   1 tr_list[*]
     2 short_desc = vc
     2 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET upd_event
 RECORD upd_event(
   1 elist[*]
     2 track_event_id = f8
     2 old_def_next_event_id = f8
     2 def_next_event_id = f8
 )
 FREE SET new_pp
 RECORD new_pp(
   1 plist[*]
     2 predefined_prefs_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET ecount = 0
 SET tot_ecount = 0
 SET ppcount = 0
 SET tot_ppcount = 0
 SET to_cnt = size(request->to_list,5)
 SET stat = alterlist(reply->tr_list,to_cnt)
 SET meaning = fillstring(12," ")
 SET from_group_display = fillstring(40," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE (cv.code_value=request->trk_group_code_value)
   AND cv.code_set=16370
  DETAIL
   meaning = cv.cdf_meaning, from_group_display = cv.display
  WITH nocounter
 ;end select
 SET rltn_code_value = 0.0
 SET form_code_value = 0.0
 SET depart_action_cd = 0.0
 SET depart_button_cd = 0.0
 SET depart_text_cd = 0.0
 SET depart_diag_cd = 0.0
 SET depart_summary_cd = 0.0
 SET depart_prefs_cd = 0.0
 SET long_text_cd = 0.0
 SET prv_role_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20500
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("DEFRELNROLE", "FORMASSOC", "DPT_ACTION", "DPT_BUTTON", "DPT_DIAG",
  "DPT_PREFS", "DPT_SUMMARY", "DPT_TEXT", "LONGTEXTREF", "PRVROLEASSOC")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "DEFRELNROLE":
     rltn_code_value = cv.code_value
    OF "FORMASSOC":
     form_code_value = cv.code_value
    OF "DPT_ACTION":
     depart_action_cd = cv.code_value
    OF "DPT_BUTTON":
     depart_button_cd = cv.code_value
    OF "DPT_DIAG":
     depart_diag_cd = cv.code_value
    OF "DPT_PREFS":
     depart_prefs_cd = cv.code_value
    OF "DPT_SUMMARY":
     depart_summary_cd = cv.code_value
    OF "DPT_TEXT":
     depart_text_cd = cv.code_value
    OF "LONGTEXTREF":
     long_text_cd = cv.code_value
    OF "PRVROLEASSOC":
     prv_role_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET prv_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.active_ind=1
   AND cv.cdf_meaning="PRVRELN"
  DETAIL
   prv_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET acuity_code_value = 0.0
 SET acuity_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.active_ind=1
   AND cv.cdf_meaning="ACUITY"
  DETAIL
   acuity_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET filter_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25631
   AND cv.cdf_meaning="TRACKGROUP"
   AND cv.active_ind=1
  DETAIL
   filter_type_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO to_cnt)
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 16370
   SET request_cv->cd_value_list[1].display = substring(1,40,request->to_list[x].short_desc)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->to_list[x].short_desc)
   SET request_cv->cd_value_list[1].definition = substring(1,100,request->to_list[x].short_desc)
   SET request_cv->cd_value_list[1].cdf_meaning = meaning
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET reply->tr_list[x].code_value = reply_cv->qual[1].code_value
    SET reply->tr_list[x].short_desc = request->to_list[x].short_desc
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(request->to_list[x].short_desc)," into cs 16370."
     )
    GO TO exit_script
   ENDIF
   INSERT  FROM code_value_extension
    (code_value, field_name, code_set,
    updt_applctx, updt_dt_tm, field_type,
    field_value, updt_cnt, updt_task)(SELECT
     reply->tr_list[x].code_value, cve.field_name, cve.code_set,
     reqinfo->updt_applctx, cnvtdatetime(curdate,curtime3), cve.field_type,
     cve.field_value, 0, reqinfo->updt_task
     FROM code_value_extension cve
     WHERE (cve.code_value=request->trk_group_code_value))
    WITH nocounter
   ;end insert
   INSERT  FROM track_group tg
    SET tg.parent_value = request->to_list[x].loc_code_value, tg.child_value = 0.0, tg
     .tracking_group_cd = reply->tr_list[x].code_value,
     tg.child_table = "TRACK_ASSOC", tg.tracking_rule = " ", tg.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     tg.updt_id = reqinfo->updt_id, tg.updt_task = reqinfo->updt_task, tg.updt_cnt = 0,
     tg.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   INSERT  FROM track_collection
    (track_collection_id, tracking_group_cd, description,
    display, collection_type_cd, active_ind,
    active_status_cd, active_status_dt_tm, active_status_prsnl_id,
    updt_applctx, updt_cnt, updt_dt_tm,
    updt_id, updt_task, color_num,
    sequence_num)(SELECT
     seq(tracking_seq,nextval), reply->tr_list[x].code_value, tc.description,
     tc.display, tc.collection_type_cd, tc.active_ind,
     tc.active_status_cd, cnvtdatetime(curdate,curtime3), tc.active_status_prsnl_id,
     reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, tc.color_num,
     tc.sequence_num
     FROM track_collection tc
     WHERE (tc.tracking_group_cd=request->trk_group_code_value)
      AND tc.active_ind=1)
    WITH nocounter
   ;end insert
   IF ((request->to_list[x].prefix > "  *"))
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "FNTRKGRP_PREFIX", bnv
      .br_name = cnvtstring(reply->tr_list[x].code_value),
      bnv.br_value = request->to_list[x].prefix, bnv.updt_id = reqinfo->updt_id, bnv.updt_task =
      reqinfo->updt_task,
      bnv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     SET error_flag = "F"
     SET error_msg = concat("Error adding tracking group prefix to br_name_value for ",cnvtstring(
       reply->tr_list[x].code_value),".")
     GO TO exit_script
    ENDIF
   ENDIF
   INSERT  FROM track_event
    (track_event_id, tracking_group_cd, active_ind,
    description, display, display_key,
    tracking_event_type_cd, normal_color, normal_icon,
    overdue_interval, overdue_color, overdue_icon,
    critical_interval, critical_color, critical_icon,
    def_request_loc_cd, def_begin_loc_cd, def_next_event_id,
    event_use_mean_cd, show_on_monitor_ind, auto_complete_ind,
    complete_on_exit_ind, event_priority_rank, final_transaction_ind,
    flex_location_cd, updt_dt_tm, updt_id,
    updt_task, updt_cnt, auto_start_ind,
    critical_blink_ind, overdue_blink_ind, clinic_event_cd,
    hide_event_ind, stage_cd, single_use_ind,
    sequence_num, request_icon_id, request_color_num,
    single_state_ind, start_color_num, complete_color_num,
    start_icon_id, complete_icon_id)(SELECT
     seq(reference_seq,nextval), reply->tr_list[x].code_value, te.active_ind,
     te.description, te.display, te.display_key,
     te.tracking_event_type_cd, te.normal_color, te.normal_icon,
     te.overdue_interval, te.overdue_color, te.overdue_icon,
     te.critical_interval, te.critical_color, te.critical_icon,
     te.def_request_loc_cd, te.def_begin_loc_cd, te.def_next_event_id,
     te.event_use_mean_cd, te.show_on_monitor_ind, te.auto_complete_ind,
     te.complete_on_exit_ind, te.event_priority_rank, te.final_transaction_ind,
     te.flex_location_cd, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
     reqinfo->updt_task, 0, te.auto_start_ind,
     te.critical_blink_ind, te.overdue_blink_ind, te.clinic_event_cd,
     te.hide_event_ind, te.stage_cd, te.single_use_ind,
     te.sequence_num, te.request_icon_id, te.request_color_num,
     te.single_state_ind, te.start_color_num, te.complete_color_num,
     te.start_icon_id, te.complete_icon_id
     FROM track_event te
     WHERE (te.tracking_group_cd=request->trk_group_code_value)
      AND te.active_ind=1
     ORDER BY te.track_event_id)
    WITH nocounter
   ;end insert
   INSERT  FROM track_collection_element
    (track_collection_element_id, track_collection_id, element_value,
    element_table, element_status_cd, updt_id,
    updt_dt_tm, updt_task, updt_cnt,
    sequence_num, active_ind, active_status_dt_tm,
    active_status_prsnl_id, updt_applctx, active_status_cd)(SELECT
     seq(tracking_seq,nextval), tc2.track_collection_id, te2.track_event_id,
     tce.element_table, tce.element_status_cd, reqinfo->updt_id,
     cnvtdatetime(curdate,curtime3), reqinfo->updt_task, 0,
     tce.sequence_num, tce.active_ind, cnvtdatetime(curdate,curtime3),
     tce.active_status_prsnl_id, reqinfo->updt_applctx, tce.active_status_cd
     FROM track_collection_element tce,
      track_collection tc,
      track_collection tc2,
      track_event te,
      track_event te2
     WHERE (tc.tracking_group_cd=request->trk_group_code_value)
      AND tc.active_ind=1
      AND tce.track_collection_id=tc.track_collection_id
      AND te.active_ind=1
      AND te.track_event_id=tce.element_value
      AND (tc2.tracking_group_cd=reply->tr_list[x].code_value)
      AND tc2.active_ind=1
      AND tc2.description=tc.description
      AND tc2.display=tc.display
      AND te2.active_ind=1
      AND (te2.tracking_group_cd=reply->tr_list[x].code_value)
      AND te2.description=te.description
      AND te2.display=te.display)
    WITH nocounter
   ;end insert
   SELECT INTO "NL:"
    FROM track_event te,
     track_event te2,
     track_event te3
    PLAN (te
     WHERE (te.tracking_group_cd=reply->tr_list[x].code_value)
      AND te.active_ind=1
      AND te.def_next_event_id > 0)
     JOIN (te2
     WHERE te2.active_ind=1
      AND te2.track_event_id=te.def_next_event_id)
     JOIN (te3
     WHERE (te3.tracking_group_cd=reply->tr_list[x].code_value)
      AND te3.active_ind=1
      AND te3.display=te2.display
      AND te3.description=te2.description)
    HEAD REPORT
     stat = alterlist(upd_event->elist,5), ecount = 0, tot_ecount = 0
    DETAIL
     ecount = (ecount+ 1), tot_ecount = (tot_ecount+ 1)
     IF (ecount > 5)
      stat = alterlist(upd_event->elist,(tot_ecount+ 5)), ecount = 1
     ENDIF
     upd_event->elist[tot_ecount].track_event_id = te.track_event_id, upd_event->elist[tot_ecount].
     old_def_next_event_id = te.def_next_event_id, upd_event->elist[tot_ecount].def_next_event_id =
     te3.track_event_id
    FOOT REPORT
     stat = alterlist(upd_event->elist,tot_ecount)
    WITH nocounter
   ;end select
   UPDATE  FROM track_event te,
     (dummyt d  WITH seq = tot_ecount)
    SET te.def_next_event_id = upd_event->elist[d.seq].def_next_event_id
    PLAN (d)
     JOIN (te
     WHERE (te.track_event_id=upd_event->elist[d.seq].track_event_id))
    WITH nocounter
   ;end update
   SET stat = alterlist(upd_event->elist,0)
   SELECT INTO "NL:"
    FROM track_event te,
     track_event te2,
     track_event te3,
     track_event te4,
     track_collection tc,
     track_collection_element tce,
     track_collection_element tce2
    PLAN (te
     WHERE (te.tracking_group_cd=reply->tr_list[x].code_value)
      AND te.active_ind=1
      AND te.def_next_event_id > 0)
     JOIN (te2
     WHERE (te2.tracking_group_cd=request->trk_group_code_value)
      AND te2.active_ind=1
      AND te2.def_next_event_id=te.def_next_event_id
      AND te2.description=te.description
      AND te2.display=te.display)
     JOIN (tce
     WHERE tce.track_collection_id=te2.def_next_event_id)
     JOIN (te3
     WHERE te3.track_event_id=tce.element_value)
     JOIN (te4
     WHERE (te4.tracking_group_cd=reply->tr_list[x].code_value)
      AND te4.description=te3.description
      AND te4.display=te3.display)
     JOIN (tc
     WHERE (tc.tracking_group_cd=reply->tr_list[x].code_value)
      AND tc.description=te.description
      AND tc.display=te.display)
     JOIN (tce2
     WHERE tce2.track_collection_id=tc.track_collection_id
      AND tce2.element_value=te4.track_event_id)
    HEAD REPORT
     stat = alterlist(upd_event->elist,5), ecount = 0, tot_ecount = 0
    DETAIL
     ecount = (ecount+ 1), tot_ecount = (tot_ecount+ 1)
     IF (ecount > 5)
      stat = alterlist(upd_event->elist,(tot_ecount+ 5)), ecount = 1
     ENDIF
     upd_event->elist[tot_ecount].track_event_id = te.track_event_id, upd_event->elist[tot_ecount].
     old_def_next_event_id = te.def_next_event_id, upd_event->elist[tot_ecount].def_next_event_id =
     tce2.track_collection_id
    FOOT REPORT
     stat = alterlist(upd_event->elist,tot_ecount)
    WITH nocounter
   ;end select
   UPDATE  FROM track_event te,
     (dummyt d  WITH seq = tot_ecount)
    SET te.def_next_event_id = upd_event->elist[d.seq].def_next_event_id
    PLAN (d)
     JOIN (te
     WHERE (te.track_event_id=upd_event->elist[d.seq].track_event_id))
    WITH nocounter
   ;end update
   SET stat = alterlist(upd_event->elist,0)
   INSERT  FROM code_value
    (code_value, code_set, active_ind,
    display, display_key, description,
    definition, active_type_cd, active_dt_tm,
    updt_dt_tm, updt_id, updt_task,
    updt_applctx, updt_cnt)(SELECT
     seq(reference_seq,nextval), 16589, 1,
     cv.display, cv.display_key, cv.description,
     request->to_list[x].short_desc, cv.active_type_cd, cnvtdatetime(curdate,curtime3),
     cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task,
     reqinfo->updt_applctx, 0
     FROM code_value cv
     WHERE cv.code_set=16589
      AND cv.definition=from_group_display
      AND cv.active_ind=1)
    WITH nocounter
   ;end insert
   INSERT  FROM track_reference
    (tracking_ref_id, tracking_group_cd, tracking_ref_type_cd,
    assoc_code_value, active_ind, description,
    display, display_key, ref_color,
    ref_icon, overdue_interval, overdue_color,
    overdue_icon, critical_interval, critical_color,
    critical_icon, default_ind, complete_ind,
    critical_blink_ind, overdue_blink_ind, updt_dt_tm,
    updt_id, updt_task, updt_cnt,
    updt_applctx)(SELECT
     seq(reference_seq,nextval), reply->tr_list[x].code_value, acuity_code_value,
     cv.code_value, 1, cv.description,
     cv.display, cv.display_key, tr.ref_color,
     tr.ref_icon, tr.overdue_interval, tr.overdue_color,
     tr.overdue_icon, tr.critical_interval, tr.critical_color,
     tr.critical_icon, tr.default_ind, tr.complete_ind,
     tr.critical_blink_ind, tr.overdue_blink_ind, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, 0,
     reqinfo->updt_applctx
     FROM code_value cv,
      track_reference tr
     WHERE (tr.tracking_group_cd=request->trk_group_code_value)
      AND tr.active_ind=1
      AND tr.tracking_ref_type_cd=acuity_code_value
      AND cv.code_set=16589
      AND cv.active_ind=1
      AND (cv.definition=request->to_list[x].short_desc)
      AND cv.display=tr.display)
    WITH nocounter
   ;end insert
   SET new_code_value_filter_id = 0.0
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_code_value_filter_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM code_value_filter cvf
    SET cvf.code_value_filter_id = new_code_value_filter_id, cvf.code_set = 16589, cvf.filter_type_cd
      = filter_type_cd,
     cvf.filter_ind = 0, cvf.parent_entity_name1 = "CODE_VALUE", cvf.flex1_id = reply->tr_list[x].
     code_value,
     cvf.updt_id = reqinfo->updt_id, cvf.updt_cnt = 0, cvf.updt_dt_tm = cnvtdatetime(curdate,curtime3
      ),
     cvf.updt_task = reqinfo->updt_task, cvf.updt_applctx = reqinfo->updt_applctx, cvf.active_ind = 1,
     cvf.active_status_prsnl_id = reqinfo->updt_id, cvf.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), cvf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     cvf.end_effective_dt_tm = cnvtdatetime("31-dec-2100 23:59:59")
    WITH nocounter
   ;end insert
   INSERT  FROM code_value_filter_r
    (code_value_filter_id, code_value_cd, updt_dt_tm,
    updt_id, updt_task, updt_applctx,
    updt_cnt, active_ind, beg_effective_dt_tm,
    end_effective_dt_tm)(SELECT
     new_code_value_filter_id, cv.code_value, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0, 1, cnvtdatetime(curdate,curtime3),
     cnvtdatetime("31-DEC-2100 00:00:00")
     FROM code_value cv
     WHERE cv.code_set=16589
      AND (cv.definition=request->to_list[x].short_desc)
      AND cv.active_ind=1)
    WITH nocounter
   ;end insert
   INSERT  FROM code_value_group
    (parent_code_value, child_code_value, code_set,
    updt_dt_tm, updt_id, updt_task,
    updt_applctx, updt_cnt)(SELECT
     reply->tr_list[x].code_value, cv.code_value, 16589,
     cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task,
     reqinfo->updt_applctx, 0
     FROM code_value cv
     WHERE cv.code_set=16589
      AND (cv.definition=request->to_list[x].short_desc)
      AND cv.active_ind=1)
    WITH nocounter
   ;end insert
   INSERT  FROM track_reference
    (tracking_ref_id, tracking_group_cd, tracking_ref_type_cd,
    active_ind, assoc_code_value, ref_color,
    ref_icon, overdue_interval, overdue_color,
    overdue_icon, critical_interval, critical_color,
    critical_icon, default_ind, complete_ind,
    critical_blink_ind, overdue_blink_ind, description,
    display, display_key, updt_applctx,
    updt_cnt, updt_dt_tm, updt_id,
    updt_task)(SELECT
     seq(reference_seq,nextval), reply->tr_list[x].code_value, tr.tracking_ref_type_cd,
     tr.active_ind, te2.track_event_id, tr.ref_color,
     tr.ref_icon, tr.overdue_interval, tr.overdue_color,
     tr.overdue_icon, tr.critical_interval, tr.critical_color,
     tr.critical_icon, tr.default_ind, tr.complete_ind,
     tr.critical_blink_ind, tr.overdue_blink_ind, tr.description,
     tr.display, tr.display_key, reqinfo->updt_applctx,
     0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
     reqinfo->updt_task
     FROM track_reference tr,
      track_event te,
      track_event te2
     WHERE (tr.tracking_group_cd=request->trk_group_code_value)
      AND tr.tracking_ref_type_cd=prv_code_value
      AND tr.active_ind=1
      AND tr.assoc_code_value > 0
      AND te.track_event_id=tr.assoc_code_value
      AND te.active_ind=1
      AND te2.active_ind=1
      AND te2.display_key=te.display_key
      AND (te2.tracking_group_cd=reply->tr_list[x].code_value))
    WITH nocounter
   ;end insert
   INSERT  FROM track_reference
    (tracking_ref_id, tracking_group_cd, tracking_ref_type_cd,
    active_ind, assoc_code_value, ref_color,
    ref_icon, overdue_interval, overdue_color,
    overdue_icon, critical_interval, critical_color,
    critical_icon, default_ind, complete_ind,
    critical_blink_ind, overdue_blink_ind, description,
    display, display_key, updt_applctx,
    updt_cnt, updt_dt_tm, updt_id,
    updt_task)(SELECT
     seq(reference_seq,nextval), reply->tr_list[x].code_value, tr.tracking_ref_type_cd,
     tr.active_ind, tr.assoc_code_value, tr.ref_color,
     tr.ref_icon, tr.overdue_interval, tr.overdue_color,
     tr.overdue_icon, tr.critical_interval, tr.critical_color,
     tr.critical_icon, tr.default_ind, tr.complete_ind,
     tr.critical_blink_ind, tr.overdue_blink_ind, tr.description,
     tr.display, tr.display_key, reqinfo->updt_applctx,
     0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
     reqinfo->updt_task
     FROM track_reference tr
     WHERE (tr.tracking_group_cd=request->trk_group_code_value)
      AND tr.tracking_ref_type_cd=prv_code_value
      AND tr.active_ind=1
      AND tr.assoc_code_value=0)
    WITH nocounter
   ;end insert
   INSERT  FROM track_prefs
    (track_pref_id, comp_name, comp_name_unq,
    comp_pref, comp_type_cd, parent_pref_id,
    updt_applctx, updt_cnt, updt_dt_tm,
    updt_id, updt_task)(SELECT
     seq(tracking_seq,nextval), "Default Relation", concat(trim(cnvtstring(reply->tr_list[x].
        code_value)),";",trim(cnvtstring(tr2.tracking_ref_id))),
     "Role Cd", rltn_code_value, 0.0,
     reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task
     FROM track_prefs tp,
      track_reference tr,
      track_reference tr2
     WHERE (tr.tracking_group_cd=request->trk_group_code_value)
      AND tr.tracking_ref_type_cd=prv_code_value
      AND tr.active_ind=1
      AND tp.comp_name="Default Relation"
      AND tp.comp_type_cd=rltn_code_value
      AND tp.comp_pref="Role Cd"
      AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",trim(cnvtstring
       (tr.tracking_ref_id)))
      AND (tr2.tracking_group_cd=reply->tr_list[x].code_value)
      AND tr2.tracking_ref_type_cd=prv_code_value
      AND tr2.active_ind=1
      AND tr2.description=tr.description
      AND tr2.display=tr.display)
    WITH nocounter
   ;end insert
   INSERT  FROM track_comp_prefs
    (track_pref_comp_id, track_pref_id, sub_comp_name,
    sub_comp_pref, sub_comp_type_cd, updt_applctx,
    updt_cnt, updt_dt_tm, updt_id)(SELECT
     seq(tracking_seq,nextval), tp2.track_pref_id, "Default Relation",
     tcp.sub_comp_pref, rltn_code_value, reqinfo->updt_applctx,
     0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id
     FROM track_prefs tp,
      track_reference tr,
      track_reference tr2,
      track_prefs tp2,
      track_comp_prefs tcp
     WHERE (tr.tracking_group_cd=request->trk_group_code_value)
      AND tr.tracking_ref_type_cd=prv_code_value
      AND tr.active_ind=1
      AND tp.comp_name="Default Relation"
      AND tp.comp_type_cd=rltn_code_value
      AND tp.comp_pref="Role Cd"
      AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",trim(cnvtstring
       (tr.tracking_ref_id)))
      AND (tr2.tracking_group_cd=reply->tr_list[x].code_value)
      AND tr2.tracking_ref_type_cd=prv_code_value
      AND tr2.active_ind=1
      AND tr2.description=tr.description
      AND tr2.display=tr.display
      AND tp2.comp_name="Default Relation"
      AND tp2.comp_type_cd=rltn_code_value
      AND tp2.comp_pref="Role Cd"
      AND tp2.comp_name_unq=concat(trim(cnvtstring(reply->tr_list[x].code_value)),";",trim(cnvtstring
       (tr2.tracking_ref_id)))
      AND tcp.sub_comp_name="Default Relation"
      AND tcp.track_pref_id=tp.track_pref_id
      AND tcp.sub_comp_type_cd=rltn_code_value)
    WITH nocounter
   ;end insert
   INSERT  FROM track_prefs
    (track_pref_id, comp_name, comp_name_unq,
    comp_pref, comp_type_cd, parent_pref_id,
    updt_applctx, updt_cnt, updt_dt_tm,
    updt_id, updt_task)(SELECT
     seq(tracking_seq,nextval), tp.comp_name, replace(tp.comp_name_unq,cnvtstring(request->
       trk_group_code_value),cnvtstring(reply->tr_list[x].code_value)),
     replace(tp.comp_pref,cnvtstring(request->trk_group_code_value),cnvtstring(reply->tr_list[x].
       code_value)), tp.comp_type_cd, 0.0,
     reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task
     FROM track_prefs tp
     WHERE tp.comp_type_cd IN (depart_action_cd, depart_button_cd, depart_text_cd, depart_diag_cd,
     depart_prefs_cd,
     depart_summary_cd)
      AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",cnvtstring(tp
       .comp_type_cd)))
    WITH nocounter
   ;end insert
   INSERT  FROM track_comp_prefs
    (track_pref_comp_id, track_pref_id, sub_comp_name,
    sub_comp_pref, sub_comp_type_cd, updt_applctx,
    updt_cnt, updt_dt_tm, updt_id)(SELECT
     seq(tracking_seq,nextval), tp2.track_pref_id, tcp.sub_comp_name,
     tcp.sub_comp_pref, tcp.sub_comp_type_cd, reqinfo->updt_applctx,
     0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id
     FROM track_prefs tp,
      track_prefs tp2,
      track_comp_prefs tcp
     WHERE tp.comp_type_cd IN (depart_action_cd, depart_button_cd, depart_text_cd, depart_diag_cd,
     depart_prefs_cd,
     depart_summary_cd)
      AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",cnvtstring(tp
       .comp_type_cd))
      AND tp2.comp_type_cd=tp.comp_type_cd
      AND tp2.comp_name_unq=concat(trim(cnvtstring(reply->tr_list[x].code_value)),";",cnvtstring(tp2
       .comp_type_cd))
      AND tcp.track_pref_id=tp.track_pref_id)
    WITH nocounter
   ;end insert
   SELECT INTO "NL:"
    FROM track_prefs tp,
     track_comp_prefs tcp,
     long_text_reference lt
    PLAN (tp
     WHERE tp.comp_type_cd IN (depart_action_cd, depart_button_cd, depart_text_cd, depart_diag_cd,
     depart_prefs_cd,
     depart_summary_cd)
      AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",cnvtstring(tp
       .comp_type_cd)))
     JOIN (tcp
     WHERE tcp.track_pref_id=tp.track_pref_id
      AND tcp.sub_comp_type_cd=long_text_cd)
     JOIN (lt
     WHERE lt.active_ind=1
      AND lt.parent_entity_id=tcp.track_pref_comp_id
      AND lt.parent_entity_name="TRACK_COMP_PREFS")
    WITH nocounter
   ;end select
   IF (curqual > 0)
    INSERT  FROM long_text_reference
     (long_text_id, updt_cnt, updt_dt_tm,
     updt_id, updt_task, updt_applctx,
     active_ind, active_status_cd, active_status_dt_tm,
     active_status_prsnl_id, parent_entity_name, parent_entity_id,
     long_text)(SELECT
      seq(long_data_seq,nextval), 0, cnvtdatetime(curdate,curtime3),
      reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
      1, lt.active_status_cd, cnvtdatetime(curdate,curtime3),
      lt.active_status_prsnl_id, lt.parent_entity_name, tcp2.track_pref_comp_id,
      lt.long_text
      FROM track_prefs tp,
       track_prefs tp2,
       track_comp_prefs tcp,
       track_comp_prefs tcp2,
       long_text_reference lt
      WHERE tp.comp_type_cd IN (depart_action_cd, depart_button_cd, depart_text_cd, depart_diag_cd,
      depart_prefs_cd,
      depart_summary_cd)
       AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",cnvtstring(tp
        .comp_type_cd))
       AND tp2.comp_type_cd IN (depart_action_cd, depart_button_cd, depart_text_cd, depart_diag_cd,
      depart_prefs_cd,
      depart_summary_cd)
       AND tp2.comp_name_unq=concat(trim(cnvtstring(reply->tr_list[x].code_value)),";",cnvtstring(tp2
        .comp_type_cd))
       AND tcp.track_pref_id=tp.track_pref_id
       AND tcp.sub_comp_type_cd=long_text_cd
       AND tcp2.track_pref_id=tp2.track_pref_id
       AND tcp2.sub_comp_pref=tcp.sub_comp_pref
       AND lt.active_ind=1
       AND lt.parent_entity_id=tcp.track_pref_comp_id
       AND lt.parent_entity_name="TRACK_COMP_PREFS")
     WITH nocounter
    ;end insert
   ENDIF
   SET primary_doc_role = 0.0
   SET sec_doc_role = 0.0
   SET primary_nur_role = 0.0
   SET sec_nur_role = 0.0
   SET beg_pos = 0
   SET end_pos = 0
   SELECT INTO "NL:"
    FROM track_prefs tp
    PLAN (tp
     WHERE tp.comp_name="Doc/Nurse Assoc"
      AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",cnvtstring(
       prv_role_cd)))
    DETAIL
     beg_pos = 1, end_pos = findstring(";",tp.comp_pref,beg_pos), primary_doc_role = cnvtreal(
      substring(beg_pos,(end_pos - beg_pos),tp.comp_pref)),
     beg_pos = (end_pos+ 1), end_pos = findstring(";",tp.comp_pref,beg_pos), sec_doc_role = cnvtreal(
      substring(beg_pos,(end_pos - beg_pos),tp.comp_pref)),
     beg_pos = (end_pos+ 1), end_pos = findstring(";",tp.comp_pref,beg_pos), primary_nur_role =
     cnvtreal(substring(beg_pos,(end_pos - beg_pos),tp.comp_pref)),
     beg_pos = (end_pos+ 1), end_pos = size(tp.comp_pref,1), sec_nur_role = cnvtreal(substring(
       beg_pos,end_pos,tp.comp_pref))
    WITH nocounternocounter
   ;end select
   SET new_primary_doc_role = 0.0
   SET new_sec_doc_role = 0.0
   SET new_primary_nur_role = 0.0
   SET new_sec_nur_role = 0.0
   SELECT INTO "NL:"
    FROM track_reference tr,
     track_reference tr2
    PLAN (tr
     WHERE tr.tracking_ref_id IN (primary_doc_role, sec_doc_role, primary_nur_role, sec_nur_role)
      AND tr.active_ind=1)
     JOIN (tr2
     WHERE (tr2.tracking_group_cd=reply->tr_list[x].code_value)
      AND tr2.tracking_ref_type_cd=prv_code_value
      AND tr2.active_ind=1
      AND tr2.description=tr.description
      AND tr2.display=tr.display)
    DETAIL
     CASE (tr.tracking_ref_id)
      OF primary_doc_role:
       IF (primary_doc_role > 0)
        new_primary_doc_role = tr2.tracking_ref_id
       ENDIF
      OF sec_doc_role:
       IF (sec_doc_role > 0)
        new_sec_doc_role = tr2.tracking_ref_id
       ENDIF
      OF primary_nur_role:
       IF (primary_nur_role > 0)
        new_primary_nur_role = tr2.tracking_ref_id
       ENDIF
      OF sec_nur_role:
       IF (sec_nur_role > 0)
        new_sec_nur_role = tr2.tracking_ref_id
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   DECLARE new_comp_pref = vc
   SET new_comp_pref = concat(trim(cnvtstring(new_primary_doc_role)),";",trim(cnvtstring(
      new_sec_doc_role)),";",trim(cnvtstring(new_primary_nur_role)),
    ";",trim(cnvtstring(new_sec_nur_role)))
   INSERT  FROM track_prefs
    (track_pref_id, comp_name, comp_name_unq,
    comp_pref, comp_type_cd, parent_pref_id,
    updt_applctx, updt_cnt, updt_dt_tm,
    updt_id, updt_task)(SELECT
     seq(tracking_seq,nextval), tp.comp_name, replace(tp.comp_name_unq,cnvtstring(request->
       trk_group_code_value),cnvtstring(reply->tr_list[x].code_value)),
     trim(new_comp_pref), tp.comp_type_cd, 0.0,
     reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task
     FROM track_prefs tp
     WHERE tp.comp_name="Doc/Nurse Assoc"
      AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",cnvtstring(
       prv_role_cd)))
    WITH nocounter
   ;end insert
   INSERT  FROM track_comp_prefs
    (track_pref_comp_id, track_pref_id, sub_comp_name,
    sub_comp_pref, sub_comp_type_cd, updt_applctx,
    updt_cnt, updt_dt_tm, updt_id)(SELECT
     seq(tracking_seq,nextval), tp2.track_pref_id, tcp.sub_comp_name,
     trim(new_comp_pref), tcp.sub_comp_type_cd, reqinfo->updt_applctx,
     0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id
     FROM track_prefs tp,
      track_prefs tp2,
      track_comp_prefs tcp
     WHERE tp.comp_name="Doc/Nurse Assoc"
      AND tp.comp_name_unq=concat(trim(cnvtstring(request->trk_group_code_value)),";",cnvtstring(
       prv_role_cd))
      AND tp2.comp_name="Doc/Nurse Assoc"
      AND tp2.comp_name_unq=concat(trim(cnvtstring(reply->tr_list[x].code_value)),";",cnvtstring(
       prv_role_cd))
      AND tcp.track_pref_id=tp.track_pref_id)
    WITH nocounter
   ;end insert
   SET tp_parse = fillstring(300," ")
   SET tp_parse = concat("tp.comp_type_cd = ",cnvtstring(form_code_value)," and tp.comp_pref = '",
    trim(cnvtstring(request->trk_group_code_value)),"*'")
   INSERT  FROM track_prefs
    (track_pref_id, comp_name, comp_name_unq,
    comp_pref, comp_type_cd, parent_pref_id,
    updt_applctx, updt_cnt, updt_dt_tm,
    updt_id, updt_task)(SELECT
     seq(tracking_seq,nextval), request->to_list[x].short_desc, replace(tp.comp_name_unq,cnvtstring(
       request->trk_group_code_value),cnvtstring(reply->tr_list[x].code_value)),
     concat(trim(cnvtstring(reply->tr_list[x].code_value))), form_code_value, 0.0,
     reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task
     FROM track_prefs tp
     WHERE parser(tp_parse))
    WITH nocounter
   ;end insert
   SET tp_parse = fillstring(300," ")
   SET tp_parse = concat("tp.comp_type_cd = ",cnvtstring(form_code_value)," and tp.comp_pref ='",
    concat(trim(cnvtstring(request->trk_group_code_value)),"*'")," and tp2.comp_name = '",
    trim(request->to_list[x].short_desc),"' and "," tp2.comp_type_cd = ",cnvtstring(form_code_value),
    " and tp2.comp_pref = '",
    concat(trim(cnvtstring(reply->tr_list[x].code_value)),"*'"))
   INSERT  FROM track_comp_prefs
    (track_pref_comp_id, track_pref_id, sub_comp_name,
    sub_comp_pref, sub_comp_type_cd, updt_applctx,
    updt_cnt, updt_dt_tm, updt_id)(SELECT
     seq(tracking_seq,nextval), tp2.track_pref_id, tcp.sub_comp_name,
     tcp.sub_comp_pref, form_code_value, reqinfo->updt_applctx,
     0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id
     FROM track_prefs tp,
      track_prefs tp2,
      track_comp_prefs tcp
     WHERE parser(tp_parse)
      AND tp2.comp_name_unq=replace(tp.comp_name_unq,cnvtstring(request->trk_group_code_value),
      cnvtstring(reply->tr_list[x].code_value))
      AND tcp.sub_comp_name="Action Id*"
      AND tcp.track_pref_id=tp.track_pref_id
      AND tcp.sub_comp_type_cd=form_code_value)
    WITH nocounter
   ;end insert
   SET nvp_parse = fillstring(200," ")
   SET nvp_parse = concat("nvp.active_ind = 1 and nvp.parent_entity_name = 'PREDEFINED_PREFS' and ",
    "nvp.pvc_name = 'trackinggroup' and nvp.pvc_value = '",concat(trim(cnvtstring(request->
       trk_group_code_value))),"*' ")
   INSERT  FROM predefined_prefs
    (predefined_prefs_id, predefined_type_meaning, name,
    active_ind, updt_applctx, updt_cnt,
    updt_dt_tm, updt_id, updt_task)(SELECT
     seq(carenet_seq,nextval), pp.predefined_type_meaning, pp.name,
     1, reqinfo->updt_applctx, 0,
     cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task
     FROM predefined_prefs pp,
      name_value_prefs nvp,
      code_value cv
     WHERE parser(nvp_parse)
      AND cv.active_ind=1
      AND cv.code_set=18989
      AND pp.active_ind=1
      AND pp.predefined_prefs_id=nvp.parent_entity_id
      AND pp.predefined_type_meaning=cnvtstring(cv.code_value))
    WITH nocounter
   ;end insert
   SELECT INTO "NL:"
    FROM predefined_prefs pp,
     code_value cv
    PLAN (cv
     WHERE cv.active_ind=1
      AND cv.code_set=18989)
     JOIN (pp
     WHERE pp.active_ind=1
      AND pp.predefined_type_meaning=cnvtstring(cv.code_value)
      AND  NOT ( EXISTS (
     (SELECT
      nvp.parent_entity_id
      FROM name_value_prefs nvp
      WHERE nvp.active_ind=1
       AND nvp.parent_entity_name="PREDEFINED_PREFS"
       AND nvp.pvc_name="trackinggroup"
       AND nvp.parent_entity_id=pp.predefined_prefs_id))))
    HEAD REPORT
     stat = alterlist(new_pp->plist,15), ppcount = 0, tot_ppcount = 0
    HEAD pp.predefined_prefs_id
     ppcount = (ppcount+ 1), tot_ppcount = (tot_ppcount+ 1)
     IF (ppcount > 15)
      stat = alterlist(new_pp->plist,(tot_ppcount+ 15)), ppcount = 1
     ENDIF
     new_pp->plist[ppcount].predefined_prefs_id = pp.predefined_prefs_id
    FOOT REPORT
     stat = alterlist(new_pp->plist,tot_ppcount)
    WITH nocounter
   ;end select
   SET nvp_parse = fillstring(200," ")
   SET nvp_parse = concat("nvp.active_ind = 1 and nvp.parent_entity_name = 'PREDEFINED_PREFS' and ",
    "nvp.pvc_name = 'trackinggroup' and nvp.pvc_value = '",concat(trim(cnvtstring(request->
       trk_group_code_value))),"*' ")
   FOR (y = 1 TO tot_ppcount)
     INSERT  FROM name_value_prefs
      (name_value_prefs_id, parent_entity_name, parent_entity_id,
      pvc_name, pvc_value, active_ind,
      updt_applctx, updt_cnt, updt_dt_tm,
      updt_id, updt_task, merge_name,
      merge_id, sequence)(SELECT
       seq(carenet_seq,nextval), nvp.parent_entity_name, pp2.predefined_prefs_id,
       nvp.pvc_name, concat(trim(cnvtstring(reply->tr_list[x].code_value))), 1,
       reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id, reqinfo->updt_task, nvp.merge_name,
       nvp.merge_id, nvp.sequence
       FROM predefined_prefs pp,
        predefined_prefs pp2,
        name_value_prefs nvp,
        code_value cv
       WHERE parser(nvp_parse)
        AND cv.active_ind=1
        AND cv.code_set=18989
        AND pp.active_ind=1
        AND pp.predefined_prefs_id=nvp.parent_entity_id
        AND pp.predefined_type_meaning=cnvtstring(cv.code_value)
        AND pp2.active_ind=1
        AND pp2.predefined_type_meaning=cnvtstring(cv.code_value)
        AND pp2.name=pp.name
        AND (pp2.predefined_prefs_id=new_pp->plist[y].predefined_prefs_id))
      WITH nocounter
     ;end insert
   ENDFOR
   SET stat = alterlist(new_pp->plist,0)
   SET nvp2_parse = fillstring(200," ")
   SET nvp2_parse = concat("nvp2.active_ind = 1 and nvp.parent_entity_name = 'PREDEFINED_PREFS' and ",
    "nvp2.pvc_name = 'trackinggroup' and nvp2.pvc_value = '",concat(trim(cnvtstring(reply->tr_list[x]
       .code_value))),"*' ")
   SET nvp3_parse = fillstring(200," ")
   SET nvp3_parse = concat("nvp3.active_ind = 1 and nvp.parent_entity_name = 'PREDEFINED_PREFS' and ",
    "nvp3.pvc_name != 'trackinggroup' and ","nvp3.parent_entity_id = nvp.parent_entity_id")
   INSERT  FROM name_value_prefs
    (name_value_prefs_id, parent_entity_name, parent_entity_id,
    pvc_name, pvc_value, active_ind,
    updt_applctx, updt_cnt, updt_dt_tm,
    updt_id, updt_task, merge_name,
    merge_id, sequence)(SELECT
     seq(carenet_seq,nextval), nvp.parent_entity_name, nvp2.parent_entity_id,
     nvp3.pvc_name, nvp3.pvc_value, 1,
     reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, nvp.merge_name,
     nvp.merge_id, nvp.sequence
     FROM name_value_prefs nvp,
      name_value_prefs nvp2,
      name_value_prefs nvp3,
      predefined_prefs pp,
      predefined_prefs pp2,
      code_value cv
     WHERE parser(nvp_parse)
      AND cv.active_ind=1
      AND cv.code_set=18989
      AND pp.active_ind=1
      AND pp.predefined_prefs_id=nvp.parent_entity_id
      AND pp.predefined_type_meaning=cnvtstring(cv.code_value)
      AND parser(nvp2_parse)
      AND pp2.active_ind=1
      AND pp2.predefined_prefs_id=nvp2.parent_entity_id
      AND pp2.predefined_type_meaning=cnvtstring(cv.code_value)
      AND pp2.name=pp.name
      AND pp2.predefined_prefs_id != nvp.parent_entity_id
      AND parser(nvp3_parse))
    WITH nocounter
   ;end insert
   INSERT  FROM track_ord_event_reltn
    (track_event_id, cat_or_cattype_cd, track_group_cd,
    updt_id, updt_dt_tm, updt_task,
    updt_cnt, updt_applctx, association_type_cd)(SELECT
     te2.track_event_id, t.cat_or_cattype_cd, reply->tr_list[x].code_value,
     reqinfo->updt_id, cnvtdatetime(curdate,curtime3), reqinfo->updt_task,
     0, reqinfo->updt_applctx, t.association_type_cd
     FROM track_ord_event_reltn t,
      track_event te,
      track_event te2
     WHERE (t.track_group_cd=request->trk_group_code_value)
      AND te.active_ind=1
      AND te.track_event_id=t.track_event_id
      AND te2.active_ind=1
      AND (te2.tracking_group_cd=reply->tr_list[x].code_value)
      AND te2.description=te.description
      AND te2.display=te.display)
    WITH nocounter
   ;end insert
   INSERT  FROM track_ord_trigger
    (parent_cd, child_cd, track_group_cd,
    trigger_ind, updt_id, updt_dt_tm,
    updt_task, updt_cnt, updt_applctx)(SELECT
     t.parent_cd, t.child_cd, reply->tr_list[x].code_value,
     t.trigger_ind, reqinfo->updt_id, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_task, 0, reqinfo->updt_applctx
     FROM track_ord_trigger t
     WHERE (t.track_group_cd=request->trk_group_code_value))
    WITH nocounter
   ;end insert
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  CALL echo(error_msg)
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_CPY_TRK_GROUP","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
