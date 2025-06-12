CREATE PROGRAM bed_rec_core_ret_cnt:dba
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
  FROM detail_prefs dp,
   name_value_prefs nvp1,
   name_value_prefs nvp3,
   name_value_prefs nvp4
  PLAN (dp
   WHERE dp.application_number IN (600005, 820000, 4250111, 961000)
    AND dp.view_name="FLOWSHEET"
    AND dp.comp_name="FLOWSHEET"
    AND dp.position_cd=0
    AND dp.prsnl_id=0
    AND dp.active_ind=1)
   JOIN (nvp3
   WHERE nvp3.parent_entity_name="DETAIL_PREFS"
    AND nvp3.parent_entity_id=dp.detail_prefs_id
    AND nvp3.pvc_name="R_RETRIEVE_TYPE"
    AND nvp3.pvc_value="2"
    AND nvp3.active_ind=1)
   JOIN (nvp4
   WHERE nvp4.parent_entity_name="DETAIL_PREFS"
    AND nvp4.parent_entity_id=dp.detail_prefs_id
    AND nvp4.pvc_name="R_RETRIEVE_CNT"
    AND nvp4.active_ind=1)
   JOIN (nvp1
   WHERE nvp1.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp1.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp1.pvc_name=outerjoin("DIRECT_CHARTING")
    AND nvp1.active_ind=outerjoin(1))
  DETAIL
   IF (((nvp1.name_value_prefs_id=0) OR (nvp1.name_value_prefs_id > 0
    AND nvp1.pvc_value="0")) )
    IF (isnumeric(nvp4.pvc_value)=0)
     reply->run_status_flag = 3
    ELSE
     IF (cnvtint(nvp4.pvc_value) > 100)
      reply->run_status_flag = 3
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=3))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   name_value_prefs nvp1,
   name_value_prefs nvp2,
   name_value_prefs nvp3,
   name_value_prefs nvp4,
   name_value_prefs nvp5,
   name_value_prefs nvp6
  PLAN (dp
   WHERE dp.application_number IN (600005, 820000, 4250111, 961000)
    AND dp.view_name="FLOWSHEET"
    AND dp.comp_name="FLOWSHEET"
    AND dp.position_cd=0
    AND dp.prsnl_id=0
    AND dp.active_ind=1)
   JOIN (nvp1
   WHERE nvp1.parent_entity_name="DETAIL_PREFS"
    AND nvp1.parent_entity_id=dp.detail_prefs_id
    AND nvp1.pvc_name="DIRECT_CHARTING"
    AND nvp1.pvc_value="1"
    AND nvp1.active_ind=1)
   JOIN (nvp2
   WHERE nvp2.parent_entity_name="DETAIL_PREFS"
    AND nvp2.parent_entity_id=dp.detail_prefs_id
    AND nvp2.pvc_name="C_EVENT_SET_NAME"
    AND nvp2.active_ind=1)
   JOIN (nvp3
   WHERE nvp3.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp3.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp3.pvc_name=outerjoin("C_RETRIEVE_TYPE")
    AND nvp3.pvc_value=outerjoin("2")
    AND nvp3.active_ind=outerjoin(1))
   JOIN (nvp4
   WHERE nvp4.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp4.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp4.pvc_name=outerjoin("C_RETRIEVE_CNT")
    AND nvp4.active_ind=outerjoin(1))
   JOIN (nvp5
   WHERE nvp5.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp5.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp5.pvc_name=outerjoin("R_RETRIEVE_TYPE")
    AND nvp5.pvc_value=outerjoin("2")
    AND nvp5.active_ind=outerjoin(1))
   JOIN (nvp6
   WHERE nvp6.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp6.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp6.pvc_name=outerjoin("R_RETRIEVE_CNT")
    AND nvp6.active_ind=outerjoin(1))
  DETAIL
   IF (nvp2.pvc_value > " ")
    IF (nvp3.name_value_prefs_id > 0
     AND nvp4.name_value_prefs_id > 0)
     IF (isnumeric(nvp4.pvc_value)=0)
      reply->run_status_flag = 3
     ELSE
      IF (cnvtint(nvp4.pvc_value) > 100)
       reply->run_status_flag = 3
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (nvp5.name_value_prefs_id > 0
     AND nvp6.name_value_prefs_id > 0)
     IF (isnumeric(nvp6.pvc_value)=0)
      reply->run_status_flag = 3
     ELSE
      IF (cnvtint(nvp6.pvc_value) > 100)
       reply->run_status_flag = 3
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=3))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   code_value cv,
   prsnl p,
   name_value_prefs nvp1,
   name_value_prefs nvp3,
   name_value_prefs nvp4
  PLAN (dp
   WHERE dp.application_number IN (600005, 820000, 4250111, 961000)
    AND dp.view_name="FLOWSHEET"
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
   JOIN (nvp3
   WHERE nvp3.parent_entity_name="DETAIL_PREFS"
    AND nvp3.parent_entity_id=dp.detail_prefs_id
    AND nvp3.pvc_name="R_RETRIEVE_TYPE"
    AND nvp3.pvc_value="2"
    AND nvp3.active_ind=1)
   JOIN (nvp4
   WHERE nvp4.parent_entity_name="DETAIL_PREFS"
    AND nvp4.parent_entity_id=dp.detail_prefs_id
    AND nvp4.pvc_name="R_RETRIEVE_CNT"
    AND nvp4.active_ind=1)
   JOIN (nvp1
   WHERE nvp1.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp1.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp1.pvc_name=outerjoin("DIRECT_CHARTING")
    AND nvp1.active_ind=outerjoin(1))
  DETAIL
   IF (((nvp1.name_value_prefs_id=0) OR (nvp1.name_value_prefs_id > 0
    AND nvp1.pvc_value="0")) )
    IF (isnumeric(nvp4.pvc_value)=0)
     reply->run_status_flag = 3
    ELSE
     IF (cnvtint(nvp4.pvc_value) > 100)
      reply->run_status_flag = 3
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   code_value cv,
   prsnl p,
   name_value_prefs nvp1,
   name_value_prefs nvp2,
   name_value_prefs nvp3,
   name_value_prefs nvp4,
   name_value_prefs nvp5,
   name_value_prefs nvp6
  PLAN (dp
   WHERE dp.application_number IN (600005, 820000, 4250111, 961000)
    AND dp.view_name="FLOWSHEET"
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
   JOIN (nvp1
   WHERE nvp1.parent_entity_name="DETAIL_PREFS"
    AND nvp1.parent_entity_id=dp.detail_prefs_id
    AND nvp1.pvc_name="DIRECT_CHARTING"
    AND nvp1.pvc_value="1"
    AND nvp1.active_ind=1)
   JOIN (nvp2
   WHERE nvp2.parent_entity_name="DETAIL_PREFS"
    AND nvp2.parent_entity_id=dp.detail_prefs_id
    AND nvp2.pvc_name="C_EVENT_SET_NAME"
    AND nvp2.active_ind=1)
   JOIN (nvp3
   WHERE nvp3.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp3.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp3.pvc_name=outerjoin("C_RETRIEVE_TYPE")
    AND nvp3.pvc_value=outerjoin("2")
    AND nvp3.active_ind=outerjoin(1))
   JOIN (nvp4
   WHERE nvp4.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp4.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp4.pvc_name=outerjoin("C_RETRIEVE_CNT")
    AND nvp4.active_ind=outerjoin(1))
   JOIN (nvp5
   WHERE nvp5.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp5.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp5.pvc_name=outerjoin("R_RETRIEVE_TYPE")
    AND nvp5.pvc_value=outerjoin("2")
    AND nvp5.active_ind=outerjoin(1))
   JOIN (nvp6
   WHERE nvp6.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp6.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND nvp6.pvc_name=outerjoin("R_RETRIEVE_CNT")
    AND nvp6.active_ind=outerjoin(1))
  DETAIL
   IF (nvp2.pvc_value > " ")
    IF (nvp3.name_value_prefs_id > 0
     AND nvp4.name_value_prefs_id > 0)
     IF (isnumeric(nvp4.pvc_value)=0)
      reply->run_status_flag = 3
     ELSE
      IF (cnvtint(nvp4.pvc_value) > 100)
       reply->run_status_flag = 3
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (nvp5.name_value_prefs_id > 0
     AND nvp6.name_value_prefs_id > 0)
     IF (isnumeric(nvp6.pvc_value)=0)
      reply->run_status_flag = 3
     ELSE
      IF (cnvtint(nvp6.pvc_value) > 100)
       reply->run_status_flag = 3
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=3))
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
