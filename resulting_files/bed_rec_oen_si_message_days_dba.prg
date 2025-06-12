CREATE PROGRAM bed_rec_oen_si_message_days:dba
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
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM dm_purge_job j,
   dm_purge_template t,
   dm_purge_job_token jt,
   dm_purge_token pt
  PLAN (j
   WHERE j.template_nbr=10069
    AND j.active_flag=1)
   JOIN (t
   WHERE t.template_nbr=j.template_nbr
    AND t.active_ind=1)
   JOIN (jt
   WHERE jt.job_id=j.job_id
    AND jt.token_str="DAYSTOKEEP")
   JOIN (pt
   WHERE pt.template_nbr=t.template_nbr
    AND pt.token_str="DAYSTOKEEP")
  DETAIL
   IF (cnvtint(trim(jt.value)) > 7)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->run_status_flag = 3
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
