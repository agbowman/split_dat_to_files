CREATE PROGRAM dcp_del_timescales_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 IF ((request->time_scale_id > 0))
  DELETE  FROM time_scale ts
   WHERE (ts.time_scale_id=request->time_scale_id)
  ;end delete
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "Time_Scale Table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
