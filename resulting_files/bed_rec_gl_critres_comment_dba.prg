CREATE PROGRAM bed_rec_gl_critres_comment:dba
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
  FROM dm_prefs dp
  PLAN (dp
   WHERE dp.pref_domain="PATHNET GLB"
    AND dp.pref_section="RESULTENTRY"
    AND dp.pref_name="ReqCommForCriticalFlag")
  DETAIL
   IF (dp.pref_nbr=1)
    reply->run_status_flag = 1
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
