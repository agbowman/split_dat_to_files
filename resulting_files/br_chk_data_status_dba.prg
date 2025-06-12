CREATE PROGRAM br_chk_data_status:dba
 FREE SET reply
 RECORD reply(
   1 data_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE del_proc_id = vc
 DECLARE preview_lock_pre = dq8
 SET preview_lock_pre = datetimeadd(sysdate,- (0.0104166666666666))
 SET del_proc_id = ""
 SET reply->data_flag = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM br_process b
  PLAN (b
   WHERE (b.to_client_id=request->br_client_id)
    AND b.operation="PREVIEW")
  DETAIL
   IF (b.process_dt_tm < cnvtdatetime(preview_lock_pre))
    del_proc_id = b.process_identifier
   ENDIF
  WITH nocounter
 ;end select
 IF (del_proc_id > " ")
  DELETE  FROM br_process b
   WHERE b.process_identifier=value(del_proc_id)
   WITH nocounter
  ;end delete
  IF (curqual < 1)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BR_PROCESS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = value(del_proc_id)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_chg_log d
  PLAN (d
   WHERE (d.target_env_id=request->br_client_id)
    AND d.log_type="REFCHG")
  DETAIL
   reply->data_flag = 1
  WITH nocounter, maxqual(d,1)
 ;end select
 IF ((reply->data_flag=1))
  SELECT INTO "nl:"
   FROM br_process b
   PLAN (b
    WHERE (b.to_client_id=request->br_client_id)
     AND b.operation="PREVIEW")
   DETAIL
    reply->data_flag = 2
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
