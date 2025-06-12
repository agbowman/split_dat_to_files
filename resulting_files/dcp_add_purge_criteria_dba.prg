CREATE PROGRAM dcp_add_purge_criteria:dba
 RECORD reply(
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
 INSERT  FROM tl_purge_criteria pc
  SET pc.tl_purge_description = substring(1,100,request->description), pc.tl_purge_id = seq(
    carenet_seq,nextval), pc.task_type_cd =
   IF ((request->task_type_code > 0)) request->task_type_code
   ELSE null
   ENDIF
   ,
   pc.task_status_flag =
   IF ((request->task_status_ind > 0)) request->task_status_flag
   ELSE null
   ENDIF
   , pc.patient_status_flag =
   IF ((request->patient_status_ind > 0)) request->patient_status_flag
   ELSE null
   ENDIF
   , pc.purge_active_flag =
   IF ((request->purge_active_ind > 0)) request->purge_active_flag
   ELSE null
   ENDIF
   ,
   pc.order_status_flag = null, pc.archive_ind = request->archive_ind, pc.retention_days = request->
   retention_days,
   pc.active_ind = 1, pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_id = reqinfo->updt_id,
   pc.updt_task = reqinfo->updt_task, pc.updt_cnt = 0, pc.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
#exit_script
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "tl_purge_criteria table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_add_purge_criteria"
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
