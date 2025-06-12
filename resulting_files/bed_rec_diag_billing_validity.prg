CREATE PROGRAM bed_rec_diag_billing_validity
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
 SET powerchart_found = 0
 SET surginet_found = 0
 SET firstnet_found = 0
 SELECT INTO "nl:"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE ap.application_number IN (600005, 820000, 4250111)
    AND ap.position_cd=0
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.pvc_name="DX_CHECK_BILLING_VALIDITY_ORM"
    AND nvp.active_ind=1)
  DETAIL
   IF (ap.application_number=600005
    AND nvp.pvc_value="1")
    powerchart_found = 1
   ELSEIF (ap.application_number=820000
    AND nvp.pvc_value="1")
    surginet_found = 1
   ELSEIF (ap.application_number=4250111
    AND nvp.pvc_value="1")
    firstnet_found = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((powerchart_found=0) OR (((surginet_found=0) OR (firstnet_found=0)) )) )
  SET reply->run_status_flag = 3
 ENDIF
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM app_prefs ap,
    code_value cv,
    prsnl p,
    name_value_prefs nvp
   PLAN (ap
    WHERE ap.application_number IN (600005, 820000, 4250111)
     AND ap.position_cd > 0
     AND ap.prsnl_id=0
     AND ap.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ap.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=ap.position_cd
     AND p.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name="DX_CHECK_BILLING_VALIDITY_ORM"
     AND nvp.active_ind=1)
   DETAIL
    IF (nvp.pvc_value != "1")
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
