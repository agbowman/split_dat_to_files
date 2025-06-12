CREATE PROGRAM bed_rec_pc_unchart:dba
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
   detail_prefs dp,
   application a
  PLAN (np
   WHERE np.pvc_name="pvNotes.InErrorDocument"
    AND np.parent_entity_name="DETAIL_PREFS"
    AND np.pvc_value != "2"
    AND np.active_ind=1)
   JOIN (dp
   WHERE dp.detail_prefs_id=np.parent_entity_id
    AND dp.application_number=4250111
    AND dp.position_cd=0
    AND dp.prsnl_id=0
    AND dp.active_ind=1)
   JOIN (a
   WHERE a.application_number=dp.application_number
    AND a.active_ind=1)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM name_value_prefs np,
    detail_prefs dp,
    code_value cv,
    prsnl p,
    application a
   PLAN (np
    WHERE np.pvc_name="pvNotes.InErrorDocument"
     AND np.parent_entity_name="DETAIL_PREFS"
     AND np.pvc_value != "2"
     AND np.active_ind=1)
    JOIN (dp
    WHERE dp.detail_prefs_id=np.parent_entity_id
     AND dp.application_number=4250111
     AND dp.position_cd > 0
     AND dp.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=dp.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=cv.code_value
     AND p.active_ind=1)
    JOIN (a
    WHERE a.application_number=dp.application_number
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
