CREATE PROGRAM bed_rec_emar_lb_days:dba
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
  prev_admin_lookback = cnvtint(trim(nvp.pvc_value))
  FROM name_value_prefs nvp,
   detail_prefs dp,
   application a
  PLAN (nvp
   WHERE nvp.pvc_name="MAR_TASK_PREV_ADMIN_LOOKBACK"
    AND nvp.active_ind=1
    AND nvp.parent_entity_name="DETAIL_PREFS")
   JOIN (dp
   WHERE dp.detail_prefs_id=nvp.parent_entity_id
    AND dp.position_cd=0
    AND dp.prsnl_id=0)
   JOIN (a
   WHERE a.application_number=dp.application_number)
  DETAIL
   IF (((prev_admin_lookback < 1) OR (prev_admin_lookback > 5)) )
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  prev_admin_lookback = cnvtint(trim(nvp.pvc_value))
  FROM name_value_prefs nvp,
   detail_prefs dp,
   application a,
   code_value cv,
   prsnl p
  PLAN (nvp
   WHERE nvp.pvc_name="MAR_TASK_PREV_ADMIN_LOOKBACK"
    AND nvp.active_ind=1
    AND nvp.parent_entity_name="DETAIL_PREFS")
   JOIN (dp
   WHERE dp.detail_prefs_id=nvp.parent_entity_id
    AND dp.position_cd > 0)
   JOIN (a
   WHERE a.application_number=dp.application_number)
   JOIN (cv
   WHERE cv.code_value=dp.position_cd
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.active_ind=1
    AND p.position_cd=dp.position_cd)
  DETAIL
   IF (((prev_admin_lookback < 1) OR (prev_admin_lookback > 5)) )
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   prev_admin_lookback = cnvtint(trim(nvp.pvc_value))
   FROM name_value_prefs nvp,
    app_prefs ap
   PLAN (nvp
    WHERE nvp.pvc_name="MAR_TASK_PREV_ADMIN_LOOKBACK"
     AND nvp.active_ind=1
     AND nvp.parent_entity_name="APP_PREFS")
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.prsnl_id=0
     AND ap.position_cd=0
     AND ap.active_ind=1)
   DETAIL
    IF (((prev_admin_lookback < 1) OR (prev_admin_lookback > 5)) )
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   prev_admin_lookback = cnvtint(trim(nvp.pvc_value))
   FROM name_value_prefs nvp,
    app_prefs ap,
    code_value cv,
    prsnl p
   PLAN (nvp
    WHERE nvp.pvc_name="MAR_TASK_PREV_ADMIN_LOOKBACK"
     AND nvp.active_ind=1
     AND nvp.parent_entity_name="APP_PREFS")
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
    IF (((prev_admin_lookback < 1) OR (prev_admin_lookback > 5)) )
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
