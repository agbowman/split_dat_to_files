CREATE PROGRAM bed_rec_glb_elg_result:dba
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
  FROM dm_prefs dm
  PLAN (dm
   WHERE dm.pref_domain="PATHNET GLB"
    AND dm.pref_section="RESULTENTRY"
    AND dm.pref_name="AutoSelectEligibleResults")
  DETAIL
   IF (dm.pref_nbr != 1)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->run_status_flag = 3
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
