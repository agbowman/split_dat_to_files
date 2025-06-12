CREATE PROGRAM bed_rec_ops_ap_batch_rep:dba
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
 SET reply->run_status_flag = 3
 SET act_code = 0.0
 SET act_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET comp_code = 0.0
 SET comp_code = uar_get_code_by("MEANING",460,"COMPLETE")
 SELECT INTO "nl:"
  FROM ops_job_step ojs,
   ops_schedule_job_step ocjs
  PLAN (ojs
   WHERE ojs.request_number=200296
    AND ojs.active_ind=1)
   JOIN (ocjs
   WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id
    AND ocjs.status_cd=comp_code
    AND ocjs.active_ind=1
    AND ocjs.beg_effective_dt_tm > cnvtdatetime((curdate - 1),0))
  DETAIL
   hrs = datetimediff(cnvtdatetime(curdate,curtime3),ocjs.end_effective_dt_tm,3)
   IF (hrs <= 1)
    reply->run_status_flag = 1
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
