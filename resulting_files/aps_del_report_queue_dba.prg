CREATE PROGRAM aps_del_report_queue:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failures = 0
 DELETE  FROM report_queue_r r
  WHERE (r.report_queue_cd=request->report_queue_cd)
  WITH nocounter
 ;end delete
 DELETE  FROM code_value c
  WHERE (c.code_value=request->report_queue_cd)
   AND c.code_set=1319
  WITH nocounter
 ;end delete
 IF (curqual=0)
  GO TO check_error
 ELSE
  COMMIT
 ENDIF
 GO TO exit_script
#check_error
 SET failures = (failures+ 1)
 SET reply->status_data.subeventstatus[failures].operationstatus = "F"
 SET reply->status_data.subeventstatus[failures].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[failures].targetobjectvalue = "REPORT_QUEUE"
 ROLLBACK
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
