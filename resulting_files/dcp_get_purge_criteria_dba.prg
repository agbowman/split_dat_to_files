CREATE PROGRAM dcp_get_purge_criteria:dba
 RECORD reply(
   1 task_type_cd = f8
   1 task_type_ind = i2
   1 task_status_ind = i2
   1 task_status_flag = i2
   1 patient_status_ind = i2
   1 patient_status_flag = i2
   1 purge_active_ind = i2
   1 purge_active_flag = i2
   1 archive_ind = i2
   1 retention_days = i4
   1 tl_purge_id = f8
   1 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  task_status_null = nullind(pc.task_status_flag), patient_status_null = nullind(pc
   .patient_status_flag), purge_active_null = nullind(pc.purge_active_flag)
  FROM tl_purge_criteria pc
  WHERE (pc.tl_purge_id=request->purge_criteria_id)
   AND pc.active_ind=1
  DETAIL
   reply->task_type_cd = pc.task_type_cd
   IF (pc.task_type_cd != null
    AND pc.task_type_cd > 0)
    reply->task_type_ind = 1
   ELSE
    reply->task_type_ind = 0
   ENDIF
   task_status_flag = pc.task_status_flag, patient_status_flag = pc.patient_status_flag, reply->
   task_status_flag = pc.task_status_flag,
   reply->patient_status_flag = pc.patient_status_flag, reply->archive_ind = pc.archive_ind, reply->
   retention_days = pc.retention_days,
   reply->tl_purge_id = pc.tl_purge_id, purge_id = pc.tl_purge_id, reply->description = pc
   .tl_purge_description,
   reply->purge_active_flag = pc.purge_active_flag, reply->task_status_ind = (1 - task_status_null),
   reply->patient_status_ind = (1 - patient_status_null),
   reply->purge_active_ind = (1 - purge_active_null),
   CALL echo(build("task_status_null=",task_status_null)),
   CALL echo(build("reply->task_status_ind=",reply->task_status_ind)),
   CALL echo(build("patient_status_null=",patient_status_null)),
   CALL echo(build("reply->patient_status_ind=",reply->patient_status_ind)),
   CALL echo(build("purge_active_null=",purge_active_null)),
   CALL echo(build("reply->purge_active_ind=",reply->purge_active_ind))
  WITH nocounter
 ;end select
END GO
