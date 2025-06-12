CREATE PROGRAM bed_rec_pc_pl_bkmrk:dba
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
  FROM name_value_prefs np,
   app_prefs ap,
   application a
  PLAN (np
   WHERE np.parent_entity_name="APP_PREFS"
    AND np.pvc_name="BOOKMARK_EXCLUDE"
    AND np.active_ind=1)
   JOIN (ap
   WHERE ap.app_prefs_id=np.parent_entity_id
    AND ap.application_number=600005
    AND ap.position_cd=0
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (a
   WHERE a.application_number=ap.application_number
    AND a.active_ind=1)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM name_value_prefs np,
    app_prefs ap,
    code_value cv,
    prsnl p,
    application a
   PLAN (np
    WHERE np.parent_entity_name="APP_PREFS"
     AND np.pvc_name="BOOKMARK_EXCLUDE"
     AND np.active_ind=1)
    JOIN (ap
    WHERE ap.app_prefs_id=np.parent_entity_id
     AND ap.application_number=600005
     AND ap.position_cd > 0
     AND ap.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ap.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=ap.position_cd
     AND p.active_ind=1)
    JOIN (a
    WHERE a.application_number=ap.application_number
     AND a.active_ind=1)
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
