CREATE PROGRAM dcp_add_ord_tasks_cont:dba
 SET total_ref_to_add = 0
 SET total_ord_to_add = 0
 SET refs_to_add = 0
 SET max_refs = 0
 SET hold_ord_seq = 0
 SET ord_ref_cnt = 0
 RECORD qrec(
   1 q_list[*]
     2 ord_seq = i4
     2 ref_list[*]
       3 ref_seq = i4
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET orders_to_add = size(request->order_list,5)
 SET failures = 0
 SET successes = 0
 SET tot_records = 0
 SET current_instance_cnt = 0
 SET current_ref_cnt = 0
 DECLARE task_class_sch = f8 WITH constant(uar_get_code_by("MEANING",6025,"SCH"))
 FOR (i = 1 TO orders_to_add)
  SET refs_to_add = size(request->order_list[i].ref_list,5)
  IF (refs_to_add > max_refs)
   SET max_refs = refs_to_add
  ENDIF
 ENDFOR
 SET stat = alterlist(qrec->q_list,orders_to_add)
 IF (orders_to_add > 0
  AND max_refs > 0)
  SELECT INTO "nl:"
   ord_seq = q1.seq, ref_seq = q2.seq, loc_cd = request->order_list[q1.seq].location_cd,
   task_type_cd = request->order_list[q1.seq].ref_list[q2.seq].task_type_cd
   FROM (dummyt q1  WITH seq = value(orders_to_add)),
    (dummyt q2  WITH seq = value(max_refs)),
    dcp_entity_reltn der
   PLAN (q1)
    JOIN (q2
    WHERE q2.seq <= size(request->order_list[q1.seq].ref_list,5))
    JOIN (der
    WHERE der.entity_reltn_mean="TASK/LOC"
     AND (request->order_list[q1.seq].location_cd=der.entity2_id)
     AND (request->order_list[q1.seq].ref_list[q2.seq].task_type_cd=der.entity1_id)
     AND der.active_ind=1)
   DETAIL
    total_ref_to_add += 1
    IF (ord_seq != hold_ord_seq)
     ord_ref_cnt = 0, hold_ord_seq = ord_seq, total_ord_to_add += 1,
     qrec->q_list[total_ord_to_add].ord_seq = ord_seq
    ENDIF
    ord_ref_cnt += 1, stat = alterlist(qrec->q_list[total_ord_to_add].ref_list,ord_ref_cnt), qrec->
    q_list[total_ord_to_add].ref_list[ord_ref_cnt].ref_seq = ref_seq
   WITH nocounter, dontexist, outerjoin = q2
  ;end select
 ENDIF
 SET stat = alterlist(qrec->q_list,total_ord_to_add)
 SET stat = alterlist(reply->result.order_list,total_ord_to_add)
 FOR (z = 1 TO total_ord_to_add)
   SET x = qrec->q_list[z].ord_seq
   SET current_instance_cnt = size(request->order_list[x].instance_list,5)
   SET current_ref_cnt = size(qrec->q_list[z].ref_list,5)
   SET tot_records += (current_instance_cnt * current_ref_cnt)
   FOR (y = 1 TO current_instance_cnt)
     IF (current_ref_cnt > 0)
      INSERT  FROM task_activity ta,
        (dummyt d1  WITH seq = value(current_ref_cnt))
       SET ta.seq = 1, ta.task_id = seq(carenet_seq,nextval), ta.person_id = request->order_list[x].
        person_id,
        ta.linked_order_ind = request->order_list[x].linked_order_ind, ta.catalog_type_cd = request->
        order_list[x].catalog_type_cd, ta.continuous_ind = request->order_list[x].continuous_ind,
        ta.physician_order_ind = request->order_list[x].physician_order_ind, ta.task_priority_cd =
        request->order_list[x].task_priority_cd, ta.order_id = request->order_list[x].order_id,
        ta.location_cd = request->order_list[x].location_cd, ta.encntr_id = request->order_list[x].
        encntr_id, ta.task_class_cd = request->order_list[x].task_class_cd,
        ta.task_status_cd = request->order_list[x].task_status_cd, ta.careset_id = request->
        order_list[x].careset_id, ta.iv_ind = request->order_list[x].iv_ind,
        ta.tpn_ind = 0, ta.task_dt_tm = cnvtdatetime(request->order_list[x].instance_list[y].
         instance_dt_tm), ta.task_tz =
        IF ((request->order_list[x].instance_list[y].instance_dt_tm != 0)) request->order_list[x].
         task_tz
        ELSE 0
        ENDIF
        ,
        ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id = reqinfo->updt_id, ta.updt_task = reqinfo
        ->updt_task,
        ta.updt_cnt = 0, ta.updt_applctx = reqinfo->updt_applctx, ta.event_id = 0,
        ta.msg_text_id = 0, ta.msg_subject = null, ta.task_create_dt_tm = cnvtdatetime(sysdate),
        ta.confidential_ind = 0, ta.read_ind = 0, ta.delivery_ind = 0,
        ta.event_class_cd = 0, ta.msg_sender_id = 0, ta.catalog_cd = request->order_list[x].
        catalog_cd,
        ta.active_ind = 1, ta.active_status_cd = reqdata->active_status_cd, ta.active_status_dt_tm =
        cnvtdatetime(sysdate),
        ta.active_status_prsnl_id = reqinfo->updt_id, ta.reference_task_id = request->order_list[x].
        ref_list[qrec->q_list[z].ref_list[d1.seq].ref_seq].reference_task_id, ta.task_type_cd =
        request->order_list[x].ref_list[qrec->q_list[z].ref_list[d1.seq].ref_seq].task_type_cd,
        ta.task_activity_cd = request->order_list[x].ref_list[qrec->q_list[z].ref_list[d1.seq].
        ref_seq].task_activity_cd, ta.template_task_flag = 2, ta.med_order_type_cd = request->
        order_list[x].med_order_type_cd,
        ta.task_rtg_id = 0, ta.msg_subject_cd = 0, ta.reschedule_ind = 0,
        ta.reschedule_reason_cd = 0, ta.task_status_reason_cd = 0, ta.scheduled_dt_tm =
        IF ((request->order_list[x].task_class_cd=task_class_sch)) cnvtdatetime(request->order_list[x
          ].instance_list[y].instance_dt_tm)
        ENDIF
       PLAN (d1)
        JOIN (ta)
       WITH nocounter
      ;end insert
     ENDIF
     SET reply->result.order_list[z].order_id = request->order_list[x].order_id
     IF (curqual != current_ref_cnt)
      ROLLBACK
      SET failures += 1
      IF (y > 1)
       SET reply->result.order_list[z].success_inst_dt_tm = request->order_list[x].instance_list[(y
        - 1)].instance_dt_tm
       SET reply->result.order_list[z].fail_inst_dt_tm = request->order_list[x].instance_list[y].
       instance_dt_tm
      ELSE
       SET reply->result.order_list[z].success_inst_dt_tm = 0
       SET reply->result.order_list[z].fail_inst_dt_tm = 0
      ENDIF
      SET y = (current_instance_cnt+ 1)
     ELSE
      COMMIT
      SET successes += 1
      SET reply->result.order_list[z].success_inst_dt_tm = request->order_list[x].instance_list[y].
      instance_dt_tm
      SET reply->result.order_list[z].fail_inst_dt_tm = 0
     ENDIF
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 0
END GO
