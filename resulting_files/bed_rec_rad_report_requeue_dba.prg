CREATE PROGRAM bed_rec_rad_report_requeue:dba
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->run_status_flag = 3
 SET comp_cd = 0.0
 SET comp_cd = uar_get_code_by("MEANING",460,"COMPLETE")
 SELECT INTO "nl:"
  FROM ops_job_step ojs,
   ops_task ot,
   ops_schedule_task ost
  PLAN (ojs
   WHERE ojs.request_number=480013)
   JOIN (ot
   WHERE (ot.ops_job_id=(ojs.ops_job_id+ 0)))
   JOIN (ost
   WHERE (ost.ops_task_id=(ot.ops_task_id+ 0))
    AND ((ost.status_cd+ 0)=comp_cd))
  ORDER BY ost.end_effective_dt_tm
  DETAIL
   hrs = datetimediff(cnvtdatetime(curdate,curtime3),ost.end_effective_dt_tm,3)
   IF (hrs <= 6)
    reply->run_status_flag = 1
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
