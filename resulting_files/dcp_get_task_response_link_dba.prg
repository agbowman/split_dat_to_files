CREATE PROGRAM dcp_get_task_response_link:dba
 RECORD reply(
   1 qual[*]
     2 order_task_response_id = f8
     2 reference_task_id = f8
     2 response_task_id = f8
     2 task_description = vc
     2 route_cd = f8
     2 response_minutes = i4
     2 task_type_mean = vc
     2 qualification_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4
 SET reply->status_data.status = "F"
 SET count = 0
 IF ((request->reference_task_id > 0))
  SELECT INTO "nl:"
   otr.reference_task_id
   FROM order_task_response otr,
    order_task ot
   PLAN (otr
    WHERE (otr.reference_task_id=request->reference_task_id))
    JOIN (ot
    WHERE ot.reference_task_id=otr.response_task_id)
   DETAIL
    count = (count+ 1)
    IF (count > size(reply->qual,5))
     stat = alterlist(reply->qual,(count+ 2))
    ENDIF
    reply->qual[count].order_task_response_id = otr.order_task_response_id, reply->qual[count].
    reference_task_id = otr.reference_task_id, reply->qual[count].response_task_id = otr
    .response_task_id,
    reply->qual[count].task_description = ot.task_description, reply->qual[count].route_cd = otr
    .route_cd, reply->qual[count].response_minutes = otr.response_minutes,
    reply->qual[count].task_type_mean = uar_get_code_meaning(ot.task_type_cd), reply->qual[count].
    qualification_flag = otr.qualification_flag
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,count)
  CALL echorecord(reply)
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  IF ((request->response_task_id > 0))
   SELECT INTO "nl:"
    ot.response_task_id
    FROM order_task_response otr,
     order_task ot
    PLAN (otr
     WHERE (otr.response_task_id=request->response_task_id))
     JOIN (ot
     WHERE ot.reference_task_id=otr.reference_task_id)
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->qual,5))
      stat = alterlist(reply->qual,(count+ 2))
     ENDIF
     reply->qual[count].order_task_response_id = otr.order_task_response_id, reply->qual[count].
     reference_task_id = otr.reference_task_id, reply->qual[count].task_description = ot
     .task_description,
     reply->qual[count].route_cd = otr.route_cd, reply->qual[count].response_minutes = otr
     .response_minutes, reply->qual[count].task_type_mean = uar_get_code_meaning(ot.task_type_cd),
     reply->qual[count].qualification_flag = otr.qualification_flag
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->qual,count)
   IF (curqual=0)
    SET reply->status_data.status = "Z"
   ENDIF
  ENDIF
 ENDIF
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSEIF (count=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
