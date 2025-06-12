CREATE PROGRAM cpm_get_current_dt_tm:dba
 RECORD reply(
   1 current_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->current_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "S"
END GO
