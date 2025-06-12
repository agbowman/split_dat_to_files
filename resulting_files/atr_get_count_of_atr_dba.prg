CREATE PROGRAM atr_get_count_of_atr:dba
 RECORD reply(
   1 atr_cnt = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET atr_cnt = 0
 SELECT
  IF ((request->atr_ind=0))
   FROM application x
  ELSEIF ((request->atr_ind=1))
   FROM application_task x
  ELSEIF ((request->atr_ind=2))
   FROM request x
  ELSE
  ENDIF
  INTO "nl:"
  y = count(*)
  HEAD REPORT
   atr_cnt = y
  WITH nocounter
 ;end select
 SET reply->atr_cnt = atr_cnt
 IF (atr_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
