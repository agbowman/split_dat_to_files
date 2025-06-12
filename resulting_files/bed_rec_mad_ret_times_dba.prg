CREATE PROGRAM bed_rec_mad_ret_times:dba
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
  FROM order_task ot,
   code_value cv
  PLAN (cv
   WHERE cv.code_set=6026
    AND cv.cdf_meaning IN ("IV", "MED")
    AND cv.active_ind=1)
   JOIN (ot
   WHERE ot.task_type_cd=cv.code_value
    AND ((ot.retain_time > 0) OR (ot.retain_units > 0))
    AND ot.active_ind=1)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
