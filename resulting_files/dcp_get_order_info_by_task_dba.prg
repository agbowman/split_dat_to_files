CREATE PROGRAM dcp_get_order_info_by_task:dba
 RECORD reply(
   1 task_list[*]
     2 task_id = f8
     2 order_id = f8
     2 order_comment_ind = i2
     2 order_status_cd = f8
     2 template_order_id = f8
     2 stop_type_cd = f8
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 comment_type_mask = i4
     2 hna_mnemonic = vc
     2 order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 additive_cnt = i4
     2 order_detail_display_line = vc
     2 activity_type_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 need_rx_verify_ind = i2
     2 orderable_type_flag = i2
     2 need_nurse_review_ind = i2
     2 freq_type_flag = i2
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 template_order_flag = i2
     2 med_order_type_cd = f8
     2 order_comment_text = vc
     2 parent_order_status_cd = f8
     2 parent_need_rx_verify_ind = i2
     2 parent_need_nurse_review_ind = i2
     2 parent_freq_type_flag = i2
     2 parent_stop_type_cd = f8
     2 parent_current_start_dt_tm = dq8
     2 parent_current_start_tz = i4
     2 parent_projected_stop_dt_tm = dq8
     2 parent_projected_stop_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE task_total = i2 WITH constant(cnvtint(size(request->task_list,5)))
 SET stat = alterlist(reply->task_list,task_total)
 DECLARE admin_note_mask = i4 WITH constant(128)
 DECLARE mar_note_mask = i4 WITH constant(2)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(task_total)),
   orders o,
   orders o1
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->task_list[d.seq].order_id)
    AND o.active_ind=1)
   JOIN (o1
   WHERE o1.order_id=o.template_order_id)
  DETAIL
   reply->task_list[d.seq].task_id = request->task_list[d.seq].task_id, reply->task_list[d.seq].
   order_id = request->task_list[d.seq].order_id, reply->task_list[d.seq].order_comment_ind = o
   .order_comment_ind,
   reply->task_list[d.seq].order_status_cd = o.order_status_cd, reply->task_list[d.seq].
   template_order_id = o.template_order_id, reply->task_list[d.seq].stop_type_cd = o.stop_type_cd,
   reply->task_list[d.seq].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->task_list[d.seq].
   projected_stop_tz = o.projected_stop_tz, reply->task_list[d.seq].hna_mnemonic = o
   .hna_order_mnemonic,
   reply->task_list[d.seq].order_mnemonic = o.order_mnemonic, reply->task_list[d.seq].
   ordered_as_mnemonic = o.ordered_as_mnemonic, reply->task_list[d.seq].activity_type_cd = o
   .activity_type_cd,
   reply->task_list[d.seq].ref_text_mask = o.ref_text_mask, reply->task_list[d.seq].cki = o.cki,
   reply->task_list[d.seq].need_rx_verify_ind = o.need_rx_verify_ind,
   reply->task_list[d.seq].orderable_type_flag = o.orderable_type_flag, reply->task_list[d.seq].
   need_nurse_review_ind = o.need_nurse_review_ind, reply->task_list[d.seq].freq_type_flag = o
   .freq_type_flag,
   reply->task_list[d.seq].current_start_dt_tm = o.current_start_dt_tm, reply->task_list[d.seq].
   current_start_tz = o.current_start_tz, reply->task_list[d.seq].template_order_flag = o
   .template_order_flag,
   reply->task_list[d.seq].med_order_type_cd = o.med_order_type_cd
   IF (trim(o.clinical_display_line) > " ")
    reply->task_list[d.seq].order_detail_display_line = o.clinical_display_line
   ELSE
    reply->task_list[d.seq].order_detail_display_line = o.order_detail_display_line
   ENDIF
   IF (o.template_order_id > 0)
    reply->task_list[d.seq].parent_order_status_cd = o1.order_status_cd, reply->task_list[d.seq].
    parent_need_rx_verify_ind = o1.need_rx_verify_ind, reply->task_list[d.seq].
    parent_need_nurse_review_ind = o1.need_nurse_review_ind,
    reply->task_list[d.seq].parent_freq_type_flag = o1.freq_type_flag, reply->task_list[d.seq].
    parent_stop_type_cd = o1.stop_type_cd, reply->task_list[d.seq].parent_current_start_dt_tm = o1
    .current_start_dt_tm,
    reply->task_list[d.seq].parent_current_start_tz = o1.current_start_tz, reply->task_list[d.seq].
    parent_projected_stop_dt_tm = o1.projected_stop_dt_tm, reply->task_list[d.seq].
    parent_projected_stop_tz = o1.projected_stop_tz,
    comment_type_mask_temp = o.comment_type_mask, comment_type_mask_temp = bor(comment_type_mask_temp,
     band(o1.comment_type_mask,admin_note_mask)), comment_type_mask_temp = bor(comment_type_mask_temp,
     band(o1.comment_type_mask,mar_note_mask)),
    reply->task_list[d.seq].comment_type_mask = comment_type_mask_temp
   ELSE
    reply->task_list[d.seq].comment_type_mask = o.comment_type_mask
   ENDIF
  WITH nocounter
 ;end select
 DECLARE order_comment_mask = i4 WITH constant(1)
 DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(task_total)),
   order_comment oc,
   long_text lt
  PLAN (d
   WHERE band(reply->task_list[d.seq].comment_type_mask,order_comment_mask)=order_comment_mask)
   JOIN (oc
   WHERE (oc.order_id=reply->task_list[d.seq].order_id)
    AND (oc.action_sequence=
   (SELECT
    max(oc2.action_sequence)
    FROM order_comment oc2
    WHERE oc2.order_id=oc.order_id
     AND oc2.comment_type_cd=order_comment_cd))
    AND oc.comment_type_cd=order_comment_cd)
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
  DETAIL
   reply->task_list[d.seq].order_comment_text = lt.long_text
  WITH nocounter
 ;end select
 DECLARE additive_ing_type_flag = i4 WITH constant(3)
 DECLARE ivpb_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(task_total)),
   order_ingredient oi
  PLAN (d
   WHERE (reply->task_list[d.seq].med_order_type_cd=ivpb_type_cd))
   JOIN (oi
   WHERE (oi.order_id=reply->task_list[d.seq].order_id)
    AND (oi.action_sequence=
   (SELECT
    max(oi2.action_sequence)
    FROM order_ingredient oi2
    WHERE oi2.order_id=oi.order_id))
    AND oi.ingredient_type_flag=additive_ing_type_flag)
  DETAIL
   reply->task_list[d.seq].additive_cnt = (reply->task_list[d.seq].additive_cnt+ 1)
  WITH nocounter
 ;end select
#exit_script
 IF (task_total=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
