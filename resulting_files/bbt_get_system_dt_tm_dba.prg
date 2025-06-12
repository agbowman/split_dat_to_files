CREATE PROGRAM bbt_get_system_dt_tm:dba
 RECORD reply(
   1 system_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->system_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "S"
END GO
