CREATE PROGRAM bed_rec_mlist_encntr_filter:dba
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
 SET powerchart_tab_exists = 0
 SET surginet_tab_exists = 0
 SET firstnet_tab_exists = 0
 DECLARE powerchart_pref_value = vc
 DECLARE surginet_pref_value = vc
 DECLARE firstnet_pref_value = vc
 SET powerchart_pref_value = " "
 SET surginet_pref_value = " "
 SET firstnet_pref_value = " "
 SELECT INTO "nl:"
  FROM app_prefs ap,
   name_value_prefs nvp,
   view_prefs vp
  PLAN (ap
   WHERE ap.application_number IN (600005, 820000, 4250111)
    AND ap.position_cd=0
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name=outerjoin("APP_PREFS")
    AND nvp.parent_entity_id=outerjoin(ap.app_prefs_id)
    AND nvp.pvc_name=outerjoin("MED_LIST_ENCNTR_FILTER")
    AND nvp.active_ind=outerjoin(1))
   JOIN (vp
   WHERE vp.application_number=outerjoin(ap.application_number)
    AND vp.position_cd=outerjoin(0)
    AND vp.prsnl_id=outerjoin(0)
    AND vp.active_ind=outerjoin(1)
    AND vp.frame_type=outerjoin("CHART")
    AND vp.view_name=outerjoin("ORDERMEDLIST"))
  DETAIL
   IF (ap.application_number=600005)
    IF (vp.view_prefs_id > 0)
     powerchart_tab_exists = 1
    ENDIF
    IF (nvp.name_value_prefs_id > 0)
     powerchart_pref_value = nvp.pvc_value
    ENDIF
   ELSEIF (ap.application_number=820000)
    IF (vp.view_prefs_id > 0)
     surginet_tab_exists = 1
    ENDIF
    IF (nvp.name_value_prefs_id > 0)
     surginet_pref_value = nvp.pvc_value
    ENDIF
   ELSEIF (ap.application_number=4250111)
    IF (vp.view_prefs_id > 0)
     firstnet_tab_exists = 1
    ENDIF
    IF (nvp.name_value_prefs_id > 0)
     firstnet_pref_value = nvp.pvc_value
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (((powerchart_tab_exists=1
  AND powerchart_pref_value != "ALL") OR (((surginet_tab_exists=1
  AND surginet_pref_value != "ALL") OR (firstnet_tab_exists=1
  AND firstnet_pref_value != "ALL")) )) )
  SET reply->run_status_flag = 3
  GO TO exit_script
 ENDIF
 SET fail_ind = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   prsnl p,
   app_prefs ap,
   name_value_prefs nvp,
   view_prefs vp
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.position_cd=cv.code_value
    AND p.active_ind=1)
   JOIN (ap
   WHERE ap.position_cd=outerjoin(cv.code_value)
    AND ap.prsnl_id=outerjoin(0)
    AND ap.active_ind=outerjoin(1))
   JOIN (nvp
   WHERE nvp.parent_entity_name=outerjoin("APP_PREFS")
    AND nvp.parent_entity_id=outerjoin(ap.app_prefs_id)
    AND nvp.pvc_name=outerjoin("MED_LIST_ENCNTR_FILTER")
    AND nvp.active_ind=outerjoin(1))
   JOIN (vp
   WHERE vp.application_number=outerjoin(ap.application_number)
    AND vp.position_cd=outerjoin(ap.position_cd)
    AND vp.prsnl_id=outerjoin(0)
    AND vp.active_ind=outerjoin(1)
    AND vp.frame_type=outerjoin("CHART")
    AND vp.view_name=outerjoin("ORDERMEDLIST"))
  ORDER BY cv.display, p.position_cd, ap.application_number
  HEAD p.position_cd
   pc = 0, sn = 0, fn = 0,
   powerchart_pos_tab_exists = 0, surginet_pos_tab_exists = 0, firstnet_pos_tab_exists = 0
  HEAD ap.application_number
   IF (ap.application_number=600005)
    pc = 1
   ELSEIF (ap.application_number=820000)
    sn = 1
   ELSEIF (ap.application_number=4250111)
    fn = 1
   ENDIF
   IF (ap.application_number IN (600005, 820000, 4250111))
    IF (vp.view_prefs_id > 0)
     IF (ap.application_number=600005)
      powerchart_pos_tab_exists = 1
      IF (((nvp.name_value_prefs_id > 0
       AND nvp.pvc_value != "ALL") OR (nvp.name_value_prefs_id=0
       AND powerchart_pref_value != "ALL")) )
       fail_ind = 1
      ENDIF
     ELSEIF (ap.application_number=820000)
      surginet_pos_tab_exists = 1
      IF (((nvp.name_value_prefs_id > 0
       AND nvp.pvc_value != "ALL") OR (nvp.name_value_prefs_id=0
       AND surginet_pref_value != "ALL")) )
       fail_ind = 1
      ENDIF
     ELSEIF (ap.application_number=4250111)
      firstnet_pos_tab_exists = 1
      IF (((nvp.name_value_prefs_id > 0
       AND nvp.pvc_value != "ALL") OR (nvp.name_value_prefs_id=0
       AND firstnet_pref_value != "ALL")) )
       fail_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  p.position_cd
   IF (fail_ind=1)
    reply->run_status_flag = 3
   ELSEIF (pc=0
    AND powerchart_pos_tab_exists=1
    AND powerchart_pref_value != "ALL")
    reply->run_status_flag = 3
   ELSEIF (sn=0
    AND surginet_pos_tab_exists=1
    AND surginet_pref_value != "ALL")
    reply->run_status_flag = 3
   ELSEIF (fn=0
    AND firstnet_pos_tab_exists=1
    AND firstnet_pref_value != "ALL")
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
