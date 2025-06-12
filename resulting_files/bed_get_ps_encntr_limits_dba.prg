CREATE PROGRAM bed_get_ps_encntr_limits:dba
 FREE SET reply
 RECORD reply(
   1 limit_encntr_ind = i2
   1 max_encntr = i4
   1 discharge_ind = i2
   1 departure_ind = i2
   1 days = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pos_cd = 0
 IF (validate(request->position_code_value))
  SET pos_cd = request->position_code_value
 ENDIF
 SELECT INTO "nl:"
  FROM pm_sch_setup p,
   pm_sch_limit l
  PLAN (p
   WHERE (p.application_number=request->application_number)
    AND (p.task_number=request->task_number)
    AND p.person_id=0
    AND p.position_cd=pos_cd)
   JOIN (l
   WHERE l.setup_id=outerjoin(p.setup_id))
  DETAIL
   reply->limit_encntr_ind = p.limit_ind, reply->max_encntr = p.max_encntr
   IF (l.date_flag=1)
    reply->discharge_ind = 1
   ELSEIF (l.date_flag=2)
    reply->departure_ind = 1
   ENDIF
   reply->days = l.num_days
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
