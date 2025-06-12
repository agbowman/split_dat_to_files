CREATE PROGRAM dcp_get_nc_ref_task:dba
 RECORD reply(
   1 reference_task_id = f8
   1 overdue_min = i4
   1 overdue_units = i4
   1 task_activity_cd = f8
   1 task_type_cd = f8
   1 retain_time = i4
   1 retain_units = i4
   1 reschedule_time = i4
   1 allpositions_ind = i2
   1 positions[*]
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE task_cnt = i4 WITH noconstant(0)
 DECLARE pos_cnt = i4 WITH noconstant(0)
 DECLARE nc_activity_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",6027,"CERSPECCLLCT"))
 SET reply->status_data.status = "Z"
 SELECT INTO "nl:"
  FROM order_task ot,
   order_task_position_xref otpx
  PLAN (ot
   WHERE ot.task_description_key="CERNER SPECIMEN COLLECT"
    AND ot.task_activity_cd=nc_activity_cd
    AND ot.active_ind=1)
   JOIN (otpx
   WHERE otpx.reference_task_id=outerjoin(ot.reference_task_id))
  HEAD ot.reference_task_id
   task_cnt = (task_cnt+ 1), pos_cnt = 0, reply->reference_task_id = ot.reference_task_id,
   reply->overdue_min = ot.overdue_min, reply->overdue_units = ot.overdue_units, reply->
   task_activity_cd = ot.task_activity_cd,
   reply->task_type_cd = ot.task_type_cd, reply->retain_time = ot.retain_time, reply->retain_units =
   ot.retain_units,
   reply->reschedule_time = ot.reschedule_time, reply->allpositions_ind = ot.allpositionchart_ind
  DETAIL
   IF (otpx.position_cd > 0)
    pos_cnt = (pos_cnt+ 1)
    IF (pos_cnt > size(reply->positions,5))
     stat = alterlist(reply->positions,(pos_cnt+ 5))
    ENDIF
    reply->positions[pos_cnt].position_cd = otpx.position_cd
   ENDIF
  FOOT  ot.reference_task_id
   IF (pos_cnt < size(reply->positions,5))
    stat = alterlist(reply->positions,pos_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (((task_cnt != 1) OR (pos_cnt=0
  AND (reply->allpositions_ind=0))) )
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
