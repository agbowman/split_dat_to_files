CREATE PROGRAM cps_add_order_task:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET task_id = 0
 SELECT INTO "nl:"
  nextseqnum = seq(carenet_seq,nextval)"#################;rp0"
  FROM dual
  DETAIL
   task_id = cnvtint(nextseqnum)
  WITH format
 ;end select
 IF (task_id=0.0)
  GO TO exit_script
 ENDIF
 INSERT  FROM task_activity ta
  SET ta.task_id = task_id, ta.order_id = request->order_id, ta.person_id = request->person_id,
   ta.task_type_cd = request->task_type_cd, ta.msg_sender_id = request->action_prsnl_id, ta.encntr_id
    = request->encntr_id,
   ta.task_activity_cd = request->task_activity_cd, ta.reference_task_id = request->reference_task_id,
   ta.task_status_cd = request->task_status_cd,
   ta.task_create_dt_tm = cnvtdatetime(curdate,curtime3), ta.active_ind = 1, ta.active_status_cd =
   reqdata->active_status_cd,
   ta.location_cd = request->location_cd
  WITH nocounter
 ;end insert
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = insert_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  GO TO exit_script
 ENDIF
 INSERT  FROM task_activity_assignment taa
  SET taa.task_activity_assign_id = cnvtint(seq(carenet_seq,nextval)), taa.task_id = task_id, taa
   .assign_prsnl_id = request->assign_prsnl_id,
   taa.active_ind = 1, taa.beg_eff_dt_tm = cnvtdatetime(curdate,curtime3), taa.end_eff_dt_tm =
   cnvtdatetime("31-Dec-2100"),
   taa.updt_dt_tm = cnvtdatetime(curdate,curtime3), taa.updt_id = reqinfo->updt_id, taa.updt_task =
   reqinfo->updt_task,
   taa.updt_cnt = 0, taa.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = insert_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY_ASSIGNMENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
