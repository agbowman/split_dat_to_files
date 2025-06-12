CREATE PROGRAM ch_get_chart_request_date:dba
 RECORD reply(
   1 qual[*]
     2 dist_run_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT DISTINCT INTO "nl:"
  cr.dist_run_dt_tm
  FROM chart_request cr
  WHERE cr.request_type=4
   AND (cr.distribution_id=request->distribution_id)
   AND 0=datetimecmp(cr.dist_run_dt_tm,cnvtdatetime(curdate,curtime3))
   AND cr.active_ind=1
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->qual,(count+ 10))
   ENDIF
   reply->qual[count].dist_run_dt_tm = cr.dist_run_dt_tm
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
