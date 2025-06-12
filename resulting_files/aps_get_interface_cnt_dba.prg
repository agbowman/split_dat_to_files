CREATE PROGRAM aps_get_interface_cnt:dba
 RECORD reply(
   1 interface_send_cnt = i2
   1 case_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET x = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "nl"
  p.case_id, p.updt_cnt
  FROM pathology_case p
  PLAN (p
   WHERE (p.case_id=request->case_id))
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), reply->interface_send_cnt = (p.interface_send_cnt+ 1), reply->case_id = p.case_id
  WITH nocounter, forupdatewait(p)
 ;end select
 IF (x=0)
  GO TO lock_failed
 ENDIF
 UPDATE  FROM pathology_case p
  SET p.interface_send_cnt = reply->interface_send_cnt, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   p.updt_id = reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt
   + 1)
  WHERE (p.case_id=reply->case_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  GO TO task_failed
 ENDIF
 GO TO exit_script
#lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
 SET failed = "T"
 GO TO exit_script
#task_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
END GO
