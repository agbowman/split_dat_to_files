CREATE PROGRAM dcp_get_task_response:dba
 RECORD reply(
   1 task_qual[*]
     2 reference_task_id = f8
     2 task_description = vc
     2 cdf_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE task_cnt = i4
 DECLARE response_type_cd = f8 WITH noconstant
 DECLARE temp_display = vc
 SET reply->status_data.status = "F"
 SET task_cnt = 0
 SET temp_display = fillstring(255," ")
 SET temp_display = build(cnvtupper(request->task_description),"*")
 SELECT INTO "nl:"
  ot.task_description
  FROM order_task ot,
   code_value cv
  PLAN (ot
   WHERE cnvtupper(ot.task_description)=patstring(temp_display))
   JOIN (cv
   WHERE ot.task_type_cd=cv.code_value
    AND cv.cdf_meaning="RESPONSE"
    AND cv.code_set=6026)
  ORDER BY ot.task_description DESC
  DETAIL
   task_cnt = (task_cnt+ 1)
   IF (task_cnt > size(reply->task_qual,5))
    stat = alterlist(reply->task_qual,(task_cnt+ 5))
   ENDIF
   reply->task_qual[task_cnt].reference_task_id = ot.reference_task_id, reply->task_qual[task_cnt].
   task_description = ot.task_description, reply->task_qual[task_cnt].cdf_meaning =
   uar_get_code_meaning(ot.task_type_cd)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->task_qual,task_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
