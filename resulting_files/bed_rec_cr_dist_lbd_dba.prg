CREATE PROGRAM bed_rec_cr_dist_lbd:dba
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
  FROM chart_distribution c
  PLAN (c
   WHERE c.active_ind=1
    AND ((c.absolute_lookback_ind=3
    AND ((c.absolute_qualification_days < 120) OR (c.absolute_qualification_days > 730)) ) OR (c
   .absolute_lookback_ind != 3)) )
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
