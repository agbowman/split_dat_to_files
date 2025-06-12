CREATE PROGRAM dcp_upd_tasks:dba
 RECORD reply(
   1 task_failure_list[*]
     2 task_id = f8
     2 updt_cnt = i4
     2 updt_id = f8
     2 task_status_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD previous_task_info(
   1 task_list[*]
     2 task_status_cd = f8
     2 task_dt_tm = dq8
     2 task_status_reason_cd = f8
     2 reschedule_reason_cd = f8
     2 task_tz = i4
     2 scheduled_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_id = f8
     2 update_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE task_count = i4 WITH constant(size(request->task_list,5))
 SET stat = alterlist(previous_task_info->task_list,task_count)
 CALL echo(build("task_count:",task_count))
 DECLARE failures = i4 WITH noconstant(0)
 DECLARE errcode = i4 WITH protected, noconstant(1)
 DECLARE errmsg = c132 WITH protected, noconstant(fillstring(132," "))
 IF (task_count <= 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "An empty task_list was passed in the request"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(task_count)),
   task_activity ta
  PLAN (d)
   JOIN (ta
   WHERE (request->task_list[d.seq].task_id=ta.task_id)
    AND ta.active_ind=1)
  DETAIL
   IF ((ta.updt_cnt=request->task_list[d.seq].updt_cnt))
    previous_task_info->task_list[d.seq].update_ind = 1
   ENDIF
   previous_task_info->task_list[d.seq].task_status_cd = ta.task_status_cd, previous_task_info->
   task_list[d.seq].task_dt_tm = ta.task_dt_tm, previous_task_info->task_list[d.seq].
   task_status_reason_cd = ta.task_status_reason_cd,
   previous_task_info->task_list[d.seq].reschedule_reason_cd = ta.reschedule_reason_cd,
   previous_task_info->task_list[d.seq].task_tz = ta.task_tz, previous_task_info->task_list[d.seq].
   scheduled_dt_tm = ta.scheduled_dt_tm,
   previous_task_info->task_list[d.seq].updt_cnt = ta.updt_cnt, previous_task_info->task_list[d.seq].
   updt_id = ta.updt_id
  WITH nocounter, forupdatewait(ta)
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "TASK_ACTIVITY"
  SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(task_count)),
   task_activity ta
  SET ta.person_id = request->task_list[d.seq].person_id, ta.catalog_type_cd = request->task_list[d
   .seq].catalog_type_cd, ta.order_id = request->task_list[d.seq].order_id,
   ta.encntr_id = request->task_list[d.seq].encntr_id, ta.reference_task_id = request->task_list[d
   .seq].reference_task_id, ta.task_type_cd = request->task_list[d.seq].task_type_cd,
   ta.task_class_cd = request->task_list[d.seq].task_class_cd, ta.task_status_cd = request->
   task_list[d.seq].task_status_cd, ta.task_dt_tm = cnvtdatetime(request->task_list[d.seq].task_dt_tm
    ),
   ta.task_activity_cd = request->task_list[d.seq].task_activity_cd, ta.catalog_cd = request->
   task_list[d.seq].catalog_cd, ta.task_status_reason_cd = request->task_list[d.seq].
   task_status_reason_cd,
   ta.reschedule_ind = request->task_list[d.seq].reschedule_ind, ta.reschedule_reason_cd = request->
   task_list[d.seq].reschedule_reason_cd, ta.med_order_type_cd = request->task_list[d.seq].
   med_order_type_cd,
   ta.task_priority_cd = request->task_list[d.seq].task_priority_cd, ta.charted_by_agent_cd = request
   ->task_list[d.seq].charted_by_agent_cd, ta.charted_by_agent_identifier = request->task_list[d.seq]
   .charted_by_agent_identifier,
   ta.charting_context_reference = request->task_list[d.seq].charting_context_reference, ta
   .scheduled_dt_tm = cnvtdatetime(request->task_list[d.seq].scheduled_dt_tm), ta.result_set_id =
   request->task_list[d.seq].result_set_id,
   ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta.updt_id = reqinfo->updt_id, ta.updt_task =
   reqinfo->updt_task,
   ta.updt_cnt = (ta.updt_cnt+ 1), ta.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (previous_task_info->task_list[d.seq].update_ind=1))
   JOIN (ta
   WHERE (ta.task_id=request->task_list[d.seq].task_id)
    AND ta.active_ind=1)
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "UPDATE"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "TASK_ACTIVITY"
  SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 INSERT  FROM task_action tac,
   (dummyt d  WITH seq = value(task_count))
  SET tac.seq = 1, tac.task_id = request->task_list[d.seq].task_id, tac.task_action_seq = seq(
    carenet_seq,nextval),
   tac.task_status_cd = previous_task_info->task_list[d.seq].task_status_cd, tac.task_dt_tm =
   cnvtdatetime(previous_task_info->task_list[d.seq].task_dt_tm), tac.task_tz =
   IF ((previous_task_info->task_list[d.seq].task_dt_tm != 0)) previous_task_info->task_list[d.seq].
    task_tz
   ELSE 0
   ENDIF
   ,
   tac.task_status_reason_cd = previous_task_info->task_list[d.seq].task_status_reason_cd, tac
   .reschedule_reason_cd = previous_task_info->task_list[d.seq].reschedule_reason_cd, tac
   .scheduled_dt_tm = cnvtdatetime(previous_task_info->task_list[d.seq].scheduled_dt_tm),
   tac.updt_dt_tm = cnvtdatetime(curdate,curtime3), tac.updt_id = reqinfo->updt_id, tac.updt_task =
   reqinfo->updt_task,
   tac.updt_cnt = 0, tac.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (previous_task_info->task_list[d.seq].update_ind=1))
   JOIN (tac)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "INSERT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "TASK_ACTION"
  SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 IF (curqual != task_count)
  FOR (x = 1 TO task_count)
    IF ((previous_task_info->task_list[x].update_ind=0))
     SET failures = (failures+ 1)
     IF (failures > 0)
      SET stat = alterlist(reply->task_failure_list,failures)
     ENDIF
     SET reply->task_failure_list[failures].task_id = request->task_list[x].task_id
     SET reply->task_failure_list[failures].updt_cnt = previous_task_info->task_list[x].updt_cnt
     SET reply->task_failure_list[failures].updt_id = previous_task_info->task_list[x].updt_id
     SET reply->task_failure_list[failures].task_status_cd = previous_task_info->task_list[x].
     task_status_cd
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
 ELSEIF (failures != task_count)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
END GO
