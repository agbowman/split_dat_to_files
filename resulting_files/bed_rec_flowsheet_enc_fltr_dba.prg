CREATE PROGRAM bed_rec_flowsheet_enc_fltr:dba
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
 SET powerchart_found_good = 0
 SET surginet_found_good = 0
 SET firstnet_found_good = 0
 SET powerchart_found_bad = 0
 SET surginet_found_bad = 0
 SET firstnet_found_bad = 0
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   name_value_prefs nvp
  PLAN (dp
   WHERE dp.application_number IN (600005, 820000, 4250111)
    AND dp.comp_name="FLOWSHEET"
    AND dp.position_cd=0
    AND dp.prsnl_id=0
    AND dp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.pvc_name="FILTER_BY_SELECTED_ENCOUNTER"
    AND nvp.active_ind=1)
  DETAIL
   IF (dp.application_number=600005)
    IF (nvp.pvc_value="0")
     powerchart_found_good = 1
    ELSE
     powerchart_found_bad = 1
    ENDIF
   ELSEIF (dp.application_number=820000)
    IF (nvp.pvc_value="0")
     surginet_found_good = 1
    ELSE
     surginet_found_bad = 1
    ENDIF
   ELSEIF (dp.application_number=4250111)
    IF (nvp.pvc_value="0")
     firstnet_found_good = 1
    ELSE
     firstnet_found_bad = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (((powerchart_found_good=0) OR (((surginet_found_good=0) OR (((firstnet_found_good=0) OR (((
 powerchart_found_bad=1) OR (((surginet_found_bad=1) OR (firstnet_found_bad=1)) )) )) )) )) )
  SET reply->run_status_flag = 3
 ENDIF
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM detail_prefs dp,
    code_value cv,
    prsnl p,
    name_value_prefs nvp
   PLAN (dp
    WHERE dp.application_number IN (600005, 820000, 4250111)
     AND dp.comp_name="FLOWSHEET"
     AND dp.position_cd > 0
     AND dp.prsnl_id=0
     AND dp.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=dp.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=dp.position_cd
     AND p.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=dp.detail_prefs_id
     AND nvp.pvc_name="FILTER_BY_SELECTED_ENCOUNTER"
     AND nvp.active_ind=1)
   DETAIL
    IF (nvp.pvc_value != "0")
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
