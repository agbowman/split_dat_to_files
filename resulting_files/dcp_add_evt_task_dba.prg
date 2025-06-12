CREATE PROGRAM dcp_add_evt_task:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET task_id = 0.0
 SELECT INTO "nl:"
  nextseqnum = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   task_id = nextseqnum
  WITH format
 ;end select
 IF (task_id=0.0)
  GO TO exit_script
 ENDIF
 INSERT  FROM task_activity ta
  SET ta.task_id = task_id, ta.person_id = request->person_id, ta.order_id = request->order_id,
   ta.encntr_id = request->encntr_id, ta.reference_task_id = request->reference_task_id, ta
   .task_type_cd = request->task_type_cd,
   ta.task_status_cd = request->task_status_cd, ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id =
   reqinfo->updt_id,
   ta.updt_task = reqinfo->updt_task, ta.updt_cnt = 0, ta.updt_applctx = reqinfo->updt_applctx,
   ta.event_id = request->event_id, ta.event_class_cd = request->event_class_cd, ta.task_activity_cd
    = request->task_activity_cd,
   ta.msg_subject = request->msg_subject, ta.task_create_dt_tm = cnvtdatetime(sysdate), ta.catalog_cd
    = 0,
   ta.active_ind = 1, ta.active_status_cd = reqdata->active_status_cd, ta.active_status_dt_tm =
   cnvtdatetime(sysdate),
   ta.active_status_prsnl_id = reqinfo->updt_id, ta.task_class_cd = 0, ta.msg_text_id = 0,
   ta.msg_sender_id = 0, ta.location_cd = 0, ta.catalog_type_cd = 0,
   ta.careset_id = 0, ta.med_order_type_cd = 0, ta.task_rtg_id = 0,
   ta.msg_subject_cd = 0, ta.reschedule_ind = 0, ta.reschedule_reason_cd = 0,
   ta.task_status_reason_cd = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 INSERT  FROM task_activity_assignment taa
  SET taa.task_activity_assign_id = seq(carenet_seq,nextval), taa.task_id = task_id, taa
   .assign_prsnl_id = request->assign_prsnl_id,
   taa.active_ind = 1, taa.beg_eff_dt_tm = cnvtdatetime(sysdate), taa.end_eff_dt_tm = cnvtdatetime(
    "31-Dec-2100"),
   taa.updt_dt_tm = cnvtdatetime(sysdate), taa.updt_id = reqinfo->updt_id, taa.updt_task = reqinfo->
   updt_task,
   taa.updt_cnt = 0, taa.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
