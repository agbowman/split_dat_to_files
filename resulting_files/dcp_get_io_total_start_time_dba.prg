CREATE PROGRAM dcp_get_io_total_start_time:dba
 DECLARE rowidx = i4 WITH protect, noconstant(0)
 DECLARE replyidx = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 encntr_id = f8
     2 total_start_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM io_total_start_time iotst
  WHERE ((iotst.active_ind+ 0)=1)
   AND expand(rowidx,1,size(request->qual,5),iotst.event_cd,request->qual[rowidx].event_cd,
   iotst.encntr_id,request->qual[rowidx].encntr_id)
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   replyidx = (replyidx+ 1)
   IF (replyidx > size(reply->qual,5))
    stat = alterlist(reply->qual,(replyidx+ 11))
   ENDIF
   reply->qual[replyidx].event_cd = iotst.event_cd, reply->qual[replyidx].encntr_id = iotst.encntr_id,
   reply->qual[replyidx].total_start_dt_tm = iotst.total_start_dt_tm
  FOOT REPORT
   stat = alterlist(reply->qual,replyidx)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat("Select - ",errmsg)
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "Zero qual in Select"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Success"
 ENDIF
 SET modify = nopredeclare
 SET last_mod = "000"
 SET mod_date = "05/08/2006"
END GO
