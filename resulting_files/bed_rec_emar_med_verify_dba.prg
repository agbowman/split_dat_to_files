CREATE PROGRAM bed_rec_emar_med_verify:dba
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
  FROM name_value_prefs nvp,
   detail_prefs dp
  PLAN (nvp
   WHERE nvp.pvc_name="MED_VERIFY"
    AND nvp.active_ind=1
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_value IN ("0", "0-Not Required"))
   JOIN (dp
   WHERE dp.detail_prefs_id=nvp.parent_entity_id
    AND dp.prsnl_id=0
    AND dp.position_cd=0
    AND dp.active_ind=1)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    detail_prefs dp,
    code_value cv,
    prsnl p
   PLAN (nvp
    WHERE nvp.pvc_name="MED_VERIFY"
     AND nvp.active_ind=1
     AND nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.pvc_value IN ("0", "0-Not Required"))
    JOIN (dp
    WHERE dp.detail_prefs_id=nvp.parent_entity_id
     AND dp.position_cd > 0
     AND dp.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=dp.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=dp.position_cd
     AND p.active_ind=1)
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    app_prefs ap
   PLAN (nvp
    WHERE nvp.pvc_name="MED_VERIFY"
     AND nvp.active_ind=1
     AND nvp.parent_entity_name="APP_PREFS"
     AND nvp.pvc_value IN ("0", "0-Not Required"))
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.prsnl_id=0
     AND ap.position_cd=0
     AND ap.active_ind=1)
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    app_prefs ap,
    code_value cv,
    prsnl p
   PLAN (nvp
    WHERE nvp.pvc_name="MED_VERIFY"
     AND nvp.active_ind=1
     AND nvp.parent_entity_name="APP_PREFS"
     AND nvp.pvc_value IN ("0", "0-Not Required"))
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.position_cd > 0
     AND ap.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ap.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=ap.position_cd
     AND p.active_ind=1)
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
