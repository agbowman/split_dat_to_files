CREATE PROGRAM atr_get_prev_of_atr:dba
 RECORD reply(
   1 atr_prev_count = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->atr_ind=0))
   FROM application x
   FOOT REPORT
    reply->atr_prev_count = count(x.application_number
     WHERE (x.application_number < request->start_number))
  ELSEIF ((request->atr_ind=1))
   FROM application_task x
   FOOT REPORT
    reply->atr_prev_count = count(x.task_number
     WHERE (x.task_number < request->start_number))
  ELSEIF ((request->atr_ind=2))
   FROM request x
   FOOT REPORT
    reply->atr_prev_count = count(x.request_number
     WHERE (x.request_number < request->start_number))
  ELSE
  ENDIF
  INTO "nl:"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
