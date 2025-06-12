CREATE PROGRAM dcp_add_ord_tasks:dba
 RECORD internal(
   1 order_list[*]
     2 ref_list[*]
       3 status = i2
 )
 RECORD qrec(
   1 q_list[*]
     2 ord_seq = i4
     2 ref_seq = i4
     2 status = i2
 )
 RECORD task_ids(
   1 qual_ids[*]
     2 task_id = f8
 )
 SET cfailed = "F"
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET orders_to_add = size(request->order_list,5)
 SET stat = alterlist(internal->order_list,orders_to_add)
 SET failures = 0
 SET max_refs = 0
 SET total_refs = 0
 SET total_to_add = 0
 DECLARE hsys = i4 WITH public, noconstant(0)
 DECLARE sysstat = i4 WITH public, noconstant(0)
 DECLARE ol_idx = i4 WITH public, noconstant(0)
 DECLARE tl_idx = i4 WITH public, noconstant(0)
 DECLARE qrect_idx = i4 WITH public, noconstant(1)
 DECLARE task_class_sch = f8 WITH constant(uar_get_code_by("MEANING",6025,"SCH"))
 FOR (i = 1 TO orders_to_add)
   SET refs_to_add = size(request->order_list[i].ref_list,5)
   SET total_refs += refs_to_add
   IF (refs_to_add > max_refs)
    SET max_refs = refs_to_add
   ENDIF
   SET stat = alterlist(internal->order_list[i].ref_list,refs_to_add)
 ENDFOR
 SET stat = alterlist(qrec->q_list,total_refs)
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
    total_to_add += 1, qrec->q_list[total_to_add].ord_seq = ord_seq, qrec->q_list[total_to_add].
    ref_seq = ref_seq,
    qrec->q_list[total_to_add].status = 0
   WITH nocounter, dontexist, outerjoin = q2
  ;end select
 ENDIF
 SET stat = alterlist(qrec->q_list,total_to_add)
 CALL uar_syscreatehandle(hsys,sysstat)
 FOR (ol_idx = 1 TO orders_to_add)
  SET tl_cnt = size(request->order_list[ol_idx].ref_list,5)
  FOR (tl_idx = 1 TO tl_cnt)
    IF (total_to_add > 0
     AND (ol_idx=qrec->q_list[qrect_idx].ord_seq)
     AND (tl_idx=qrec->q_list[qrect_idx].ref_seq))
     IF (qrect_idx < total_to_add)
      SET qrect_idx += 1
     ENDIF
    ELSE
     SET person_id = request->order_list[ol_idx].person_id
     SET location_cd = request->order_list[ol_idx].location_cd
     SET task_type_cd = request->order_list[ol_idx].ref_list[tl_idx].task_type_cd
     SET reference_task_id = request->order_list[ol_idx].ref_list[tl_idx].reference_task_id
     SET tempfirst = build("Person_Id=",person_id,", ","Location_Cd=",location_cd,
      ", ")
     SET tempsecond = build("Task_Type_Cd= ",task_type_cd,", ","Reference_Task_Id=",reference_task_id
      )
     SET tempfile = build(tempfirst,tempsecond)
     CALL uar_sysevent(hsys,4,"DCP_ADD_ORD_TASKS.PRG",nullterm(build("Task Creation Suppressed for:",
        tempfile)))
    ENDIF
  ENDFOR
 ENDFOR
 CALL uar_sysdestroyhandle(hsys)
 IF (total_to_add=0)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO total_to_add)
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    stat = alterlist(task_ids->qual_ids,i), task_ids->qual_ids[i].task_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   CALL echo("failed to assign a new task_id")
   SET failures = total_to_add
   GO TO exit_script
  ENDIF
 ENDFOR
 INSERT  FROM (dummyt d1  WITH seq = value(total_to_add)),
   task_activity ta
  SET ta.seq = 1, ta.task_id = task_ids->qual_ids[d1.seq].task_id, ta.person_id = request->
   order_list[qrec->q_list[d1.seq].ord_seq].person_id,
   ta.linked_order_ind = request->order_list[qrec->q_list[d1.seq].ord_seq].linked_order_ind, ta
   .catalog_type_cd = request->order_list[qrec->q_list[d1.seq].ord_seq].catalog_type_cd, ta
   .continuous_ind = request->order_list[qrec->q_list[d1.seq].ord_seq].continuous_ind,
   ta.physician_order_ind = request->order_list[qrec->q_list[d1.seq].ord_seq].physician_order_ind, ta
   .task_priority_cd = request->order_list[qrec->q_list[d1.seq].ord_seq].task_priority_cd, ta
   .order_id = request->order_list[qrec->q_list[d1.seq].ord_seq].order_id,
   ta.location_cd = request->order_list[qrec->q_list[d1.seq].ord_seq].location_cd, ta.encntr_id =
   request->order_list[qrec->q_list[d1.seq].ord_seq].encntr_id, ta.task_class_cd = request->
   order_list[qrec->q_list[d1.seq].ord_seq].task_class_cd,
   ta.task_status_cd = request->order_list[qrec->q_list[d1.seq].ord_seq].task_status_cd, ta
   .careset_id = request->order_list[qrec->q_list[d1.seq].ord_seq].careset_id, ta.iv_ind = request->
   order_list[qrec->q_list[d1.seq].ord_seq].iv_ind,
   ta.tpn_ind = 0, ta.task_dt_tm = cnvtdatetime(request->order_list[qrec->q_list[d1.seq].ord_seq].
    task_dt_tm), ta.task_tz =
   IF ((request->order_list[qrec->q_list[d1.seq].ord_seq].task_dt_tm != 0)) request->order_list[qrec
    ->q_list[d1.seq].ord_seq].task_tz
   ELSE 0
   ENDIF
   ,
   ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id = reqinfo->updt_id, ta.updt_task = reqinfo->
   updt_task,
   ta.updt_cnt = 0, ta.updt_applctx = reqinfo->updt_applctx, ta.event_id = 0,
   ta.msg_text_id = 0, ta.msg_subject = null, ta.task_create_dt_tm = cnvtdatetime(sysdate),
   ta.confidential_ind = 0, ta.read_ind = 0, ta.delivery_ind = 0,
   ta.event_class_cd = 0, ta.msg_sender_id = 0, ta.catalog_cd = request->order_list[qrec->q_list[d1
   .seq].ord_seq].catalog_cd,
   ta.active_ind = 1, ta.active_status_dt_tm = cnvtdatetime(sysdate), ta.active_status_prsnl_id =
   reqinfo->updt_id,
   ta.reference_task_id = request->order_list[qrec->q_list[d1.seq].ord_seq].ref_list[qrec->q_list[d1
   .seq].ref_seq].reference_task_id, ta.task_type_cd = request->order_list[qrec->q_list[d1.seq].
   ord_seq].ref_list[qrec->q_list[d1.seq].ref_seq].task_type_cd, ta.template_task_flag = 0,
   ta.task_activity_cd = request->order_list[qrec->q_list[d1.seq].ord_seq].ref_list[qrec->q_list[d1
   .seq].ref_seq].task_activity_cd, ta.med_order_type_cd = request->order_list[qrec->q_list[d1.seq].
   ord_seq].med_order_type_cd, ta.task_rtg_id = 0,
   ta.msg_subject_cd = 0, ta.reschedule_ind = 0, ta.reschedule_reason_cd = 0,
   ta.loc_bed_cd = request->order_list[qrec->q_list[d1.seq].ord_seq].loc_bed_cd, ta.loc_room_cd =
   request->order_list[qrec->q_list[d1.seq].ord_seq].loc_room_cd, ta.task_status_reason_cd = 0,
   ta.scheduled_dt_tm =
   IF ((request->order_list[qrec->q_list[d1.seq].ord_seq].task_class_cd=task_class_sch)) cnvtdatetime
    (request->order_list[qrec->q_list[d1.seq].ord_seq].task_dt_tm)
   ENDIF
  PLAN (d1)
   JOIN (ta)
  WITH nocounter, status(qrec->q_list[d1.seq].status)
 ;end insert
 SET cnt = 0
 FOR (x = 1 TO total_to_add)
   IF ((qrec->q_list[x].status != 0))
    SET cnt += 1
    SET stat = alterlist(reply->task_list,cnt)
    SET reply->task_list[x].task_id = task_ids->qual_ids[x].task_id
    SET reply->task_list[x].task_status_cd = request->order_list[qrec->q_list[x].ord_seq].
    task_status_cd
    SET reply->task_list[x].order_id = request->order_list[qrec->q_list[x].ord_seq].order_id
    SET reply->task_list[x].event_id = 0
    SET reply->task_list[x].reference_task_id = request->order_list[qrec->q_list[x].ord_seq].
    ref_list[qrec->q_list[x].ref_seq].reference_task_id
   ENDIF
 ENDFOR
 IF (curqual != total_to_add)
  FOR (x = 1 TO total_to_add)
    IF ((qrec->q_list[x].status=0))
     SET failures += 1
     SET stat = alterlist(reply->order_list,failures)
     SET reply->order_list[failures].order_id = request->order_list[qrec->q_list[x].ord_seq].order_id
     SET reply->order_list[failures].reference_task_id = request->order_list[qrec->q_list[x].ord_seq]
     .ref_list[qrec->q_list[x].ref_seq].reference_task_id
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != total_to_add)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
