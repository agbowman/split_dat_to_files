CREATE PROGRAM bed_rec_cf_all_res_flow:dba
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
   detail_prefs dp,
   name_value_prefs nvp2,
   application a
  PLAN (dp
   WHERE dp.application_number IN (600005, 961000, 4250111, 610000, 820000)
    AND dp.active_ind=1
    AND dp.view_name="FLOWSHEET"
    AND dp.comp_name="FLOWSHEET"
    AND dp.person_id=0
    AND dp.position_cd=0)
   JOIN (nvp2
   WHERE nvp2.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp2.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp2.pvc_name=outerjoin("R_EVENT_SET_NAME"))
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_name="R_RETRIEVE_YEAR_LIMIT"
    AND nvp.active_ind=1
    AND cnvtint(trim(nvp.pvc_value)) > 3)
   JOIN (a
   WHERE a.application_number=dp.application_number
    AND a.active_ind=1)
  DETAIL
   IF (((nvp2.pvc_value IN ("", " ", null)
    AND nvp2.active_ind=1) OR (nvp2.name_value_prefs_id=0)) )
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=3))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   detail_prefs dp,
   name_value_prefs nvp2,
   prsnl p,
   application a
  PLAN (dp
   WHERE dp.application_number IN (600005, 961000, 4250111, 610000, 820000)
    AND dp.active_ind=1
    AND dp.view_name="FLOWSHEET"
    AND dp.comp_name="FLOWSHEET"
    AND dp.position_cd > 0)
   JOIN (nvp2
   WHERE nvp2.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp2.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp2.pvc_name=outerjoin("R_EVENT_SET_NAME"))
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_name="R_RETRIEVE_YEAR_LIMIT"
    AND nvp.active_ind=1
    AND cnvtint(trim(nvp.pvc_value)) > 3)
   JOIN (p
   WHERE p.position_cd=dp.position_cd
    AND p.active_ind=1)
   JOIN (a
   WHERE a.application_number=dp.application_number
    AND a.active_ind=1)
  DETAIL
   IF (((nvp2.pvc_value IN ("", " ", null)
    AND nvp2.active_ind=1) OR (nvp2.name_value_prefs_id=0)) )
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
