CREATE PROGRAM bed_rec_pharm_recalc:dba
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
 SELECT INTO "nl:"
  FROM dm_prefs dp,
   application a
  PLAN (dp
   WHERE dp.pref_name="DOSECONVERSION"
    AND dp.pref_nbr=1)
   JOIN (a
   WHERE a.application_number=dp.application_nbr
    AND a.active_ind=1)
  DETAIL
   reply->run_status_flag = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
