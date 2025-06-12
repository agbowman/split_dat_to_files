CREATE PROGRAM dcp_add_response_task:dba
 SET reply->status_data.status = "F"
 DECLARE new_task_id = f8 WITH noconstant(0.0)
 DECLARE new_reltn_id = f8 WITH noconstant(0.0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 IF ((request->task_id > 0.0))
  SET new_task_id = request->task_id
 ELSE
  SELECT INTO "nl:"
   id = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    new_task_id = id
   WITH nocounter
  ;end select
 ENDIF
 IF (new_task_id=0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "CARENET_SEQ"
  IF (error(errmsg,0))
   SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  id = seq(profile_seq,nextval)
  FROM dual
  DETAIL
   new_reltn_id = id
  WITH nocounter
 ;end select
 IF (new_reltn_id=0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "PROFILE_SEQ"
  IF (error(errmsg,0))
   SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  ENDIF
  GO TO exit_script
 ENDIF
 INSERT  FROM task_activity ta
  SET ta.task_id = new_task_id, ta.task_type_cd = request->task_type_cd, ta.task_class_cd = request->
   task_class_cd,
   ta.task_activity_cd = request->task_activity_cd, ta.task_status_cd = request->task_status_cd, ta
   .reference_task_id = request->reference_task_id,
   ta.person_id = request->person_id, ta.encntr_id = request->encntr_id, ta.loc_room_cd = request->
   loc_room_cd,
   ta.loc_bed_cd = request->loc_bed_cd, ta.location_cd = request->location_cd, ta.order_id = request
   ->order_id,
   ta.catalog_cd = request->catalog_cd, ta.catalog_type_cd = request->catalog_type_cd, ta
   .med_order_type_cd = request->med_order_type_cd,
   ta.task_dt_tm = cnvtdatetime(request->task_dt_tm), ta.scheduled_dt_tm = cnvtdatetime(request->
    scheduled_dt_tm), ta.task_create_dt_tm = cnvtdatetime(sysdate),
   ta.task_tz = request->task_tz, ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id = reqinfo->
   updt_id,
   ta.updt_task = reqinfo->updt_task, ta.updt_cnt = 0, ta.updt_applctx = reqinfo->updt_applctx,
   ta.active_ind = 1, ta.active_status_cd = reqdata->active_status_cd, ta.active_status_dt_tm =
   cnvtdatetime(sysdate),
   ta.active_status_prsnl_id = reqinfo->updt_id, ta.task_priority_cd = request->task_priority_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "INSERT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "TASK_ACTIVITY"
  IF (error(errmsg,0))
   SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  ENDIF
  GO TO exit_script
 ENDIF
 INSERT  FROM task_reltn tr
  SET tr.task_reltn_id = new_reltn_id, tr.task_id = new_task_id, tr.prereq_task_id = request->
   prereq_task_id,
   tr.display_order_id = request->order_id, tr.beg_effective_dt_tm = cnvtdatetime(sysdate), tr
   .updt_cnt = 0,
   tr.updt_dt_tm = cnvtdatetime(sysdate), tr.updt_id = reqinfo->updt_id, tr.updt_task = reqinfo->
   updt_task,
   tr.updt_applctx = reqinfo->updt_applctx, tr.active_ind = 1, tr.active_status_cd = reqdata->
   active_status_cd,
   tr.active_status_dt_tm = cnvtdatetime(sysdate), tr.active_status_prsnl_id = reqinfo->updt_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "INSERT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "TASK_RELTN"
  IF (error(errmsg,0))
   SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  ENDIF
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
