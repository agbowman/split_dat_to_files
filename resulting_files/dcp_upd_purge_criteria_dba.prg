CREATE PROGRAM dcp_upd_purge_criteria:dba
 RECORD reply(
   1 records_updated = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->task_type_code <= 0)
  AND (request->task_status_ind <= 0)
  AND (request->patient_status_ind <= 0)
  AND (request->purge_active_ind <= 0))
  GO TO exit_script
 ENDIF
 IF ((request->retention_days < 15))
  SET request->retention_days = 15
 ENDIF
 UPDATE  FROM tl_purge_criteria pc
  SET pc.tl_purge_description = request->purge_criteria_name, pc.task_type_cd =
   IF ((request->task_type_code > 0)) request->task_type_code
   ELSE null
   ENDIF
   , pc.task_status_flag =
   IF ((request->task_status_ind > 0)) request->task_status_flag
   ELSE null
   ENDIF
   ,
   pc.patient_status_flag =
   IF ((request->patient_status_ind > 0)) request->patient_status_flag
   ELSE null
   ENDIF
   , pc.purge_active_flag =
   IF ((request->purge_active_ind > 0)) request->purge_active_flag
   ELSE null
   ENDIF
   , pc.order_status_flag = null,
   pc.archive_ind = request->archive_ind, pc.retention_days = request->retention_days, pc.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_cnt = (pc.updt_cnt+ 1),
   pc.updt_applctx = reqinfo->updt_applctx
  WHERE (pc.tl_purge_id=request->purge_criteria_id)
  WITH nocounter
 ;end update
#exit_script
 SET reply->records_updated = curqual
 CALL echo(build("records updated=",reply->records_updated))
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "tl_purge_criteria table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
