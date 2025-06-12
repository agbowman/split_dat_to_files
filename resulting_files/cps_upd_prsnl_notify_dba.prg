CREATE PROGRAM cps_upd_prsnl_notify:dba
 RECORD reply(
   1 prsnl_notify_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 UPDATE  FROM prsnl_notify pn
  SET pn.notify_flag = request->notify_flag
  WHERE (pn.prsnl_notify_id=request->prsnl_notify_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_notify table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->prsnl_notify_id = request->prsnl_notify_id
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
