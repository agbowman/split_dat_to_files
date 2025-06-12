CREATE PROGRAM bed_rec_mdi_poc_run:dba
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
 SELECT INTO "nl:"
  FROM dm_purge_job j,
   dm_purge_template t,
   dm_purge_job_token jt,
   dm_purge_token pt,
   dm_purge_job_log l
  PLAN (j
   WHERE j.active_flag=1
    AND j.template_nbr=121)
   JOIN (t
   WHERE t.active_ind=1
    AND t.template_nbr=j.template_nbr)
   JOIN (jt
   WHERE jt.job_id=j.job_id)
   JOIN (pt
   WHERE pt.template_nbr=t.template_nbr)
   JOIN (l
   WHERE l.job_id=j.job_id
    AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
  DETAIL
   IF (l.purge_flag IN (1, 2))
    reply->run_status_flag = 1
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
