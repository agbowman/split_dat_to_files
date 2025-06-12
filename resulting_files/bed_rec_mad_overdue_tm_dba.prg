CREATE PROGRAM bed_rec_mad_overdue_tm:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM order_task ot
  PLAN (ot
   WHERE ot.overdue_units=1
    AND ot.overdue_min > 60
    AND ot.active_ind=1
    AND ot.cernertask_flag=0)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM order_task ot
   PLAN (ot
    WHERE ot.overdue_units=2
     AND ot.overdue_min > 1
     AND ot.active_ind=1
     AND ot.cernertask_flag=0)
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM order_task ot
   PLAN (ot
    WHERE ot.overdue_min=0
     AND ot.active_ind=1
     AND ot.cernertask_flag=0)
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
