CREATE PROGRAM bed_rec_gl_ords_ops:dba
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
  FROM code_value cv,
   ops_schedule_param op,
   ops_job_step ojs,
   ops_schedule_job_step ocjs
  PLAN (cv
   WHERE cv.code_set=2065
    AND cv.active_ind=1)
   JOIN (op
   WHERE cnvtupper(op.batch_selection)=concat("REPORT_ONLY=[N],TEMPLATE_NAME=[",cnvtupper(cv.display),
    "]")
    AND op.active_ind=1)
   JOIN (ojs
   WHERE ojs.ops_job_step_id=op.ops_job_step_id
    AND ojs.batch_selection_ind=1
    AND ojs.request_number=265260
    AND ojs.active_ind=1
    AND ojs.active_status_cd=act_code)
   JOIN (ocjs
   WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id
    AND ocjs.status_cd=comp_code
    AND ocjs.active_ind=1
    AND ocjs.beg_effective_dt_tm > cnvtdatetime((curdate - 1),0))
  DETAIL
   reply->run_status_flag = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
