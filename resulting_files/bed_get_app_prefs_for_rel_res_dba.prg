CREATE PROGRAM bed_get_app_prefs_for_rel_res:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 applications[*]
      2 id = i4
      2 display = vc
      2 eligible_ind = i2
      2 config_ind = i2
      2 initial_load_value = vc
      2 addtl_load_value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 RECORD temp(
   1 applications[*]
     2 id = i4
     2 view_prefs_ind = i2
     2 view_comp_prefs_ind = i2
     2 detail_prefs_ind = i2
     2 chart_orders_ind = i2
     2 chart_orderpoe_ind = i2
     2 orders_orderpoe_ind = i2
     2 orders_ind = i2
 )
 SET stat = alterlist(temp->applications,4)
 SET temp->applications[1].id = 600005
 SET temp->applications[2].id = 820000
 SET temp->applications[3].id = 4250111
 SET temp->applications[4].id = 610000
 SET stat = alterlist(reply->applications,4)
 SET reply->applications[1].id = 600005
 SET reply->applications[2].id = 820000
 SET reply->applications[3].id = 4250111
 SET reply->applications[4].id = 610000
 SET reply->applications[1].display = "PowerChart"
 SET reply->applications[2].display = "SurgiNet"
 SET reply->applications[3].display = "FirstNet"
 SET reply->applications[4].display = "ICU"
 SELECT INTO "nl:"
  FROM view_prefs p
  WHERE p.application_number IN (600005, 820000, 4250111, 610000)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.frame_type="DPRESVIEW"
   AND p.view_name="DPRESULTVIEW"
   AND p.active_ind=1
  DETAIL
   IF (p.application_number=600005)
    temp->applications[1].view_prefs_ind = 1
   ELSEIF (p.application_number=820000)
    temp->applications[2].view_prefs_ind = 1
   ELSEIF (p.application_number=4250111)
    temp->applications[3].view_prefs_ind = 1
   ELSEIF (p.application_number=610000)
    temp->applications[4].view_prefs_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM view_comp_prefs p
  WHERE p.application_number IN (600005, 820000, 4250111, 610000)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.view_name="DPRESULTVIEW"
   AND p.comp_name="DETAILPANE"
   AND p.active_ind=1
  DETAIL
   IF (p.application_number=600005)
    temp->applications[1].view_comp_prefs_ind = 1
   ELSEIF (p.application_number=820000)
    temp->applications[2].view_comp_prefs_ind = 1
   ELSEIF (p.application_number=4250111)
    temp->applications[3].view_comp_prefs_ind = 1
   ELSEIF (p.application_number=610000)
    temp->applications[4].view_comp_prefs_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM detail_prefs p
  WHERE p.application_number IN (600005, 820000, 4250111, 610000)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.person_id=0
   AND p.view_name="DPRESULTVIEW"
   AND p.comp_name="DETAILPANE"
   AND p.active_ind=1
  DETAIL
   IF (p.application_number=600005)
    temp->applications[1].detail_prefs_ind = 1
   ELSEIF (p.application_number=820000)
    temp->applications[2].detail_prefs_ind = 1
   ELSEIF (p.application_number=4250111)
    temp->applications[3].detail_prefs_ind = 1
   ELSEIF (p.application_number=610000)
    temp->applications[4].detail_prefs_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM view_prefs p
  WHERE p.application_number IN (600005, 820000, 4250111, 610000)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.frame_type="CHART"
   AND p.view_name IN ("ORDERPOE", "ORDERS")
   AND p.active_ind=1
  DETAIL
   IF (p.application_number=600005)
    IF (p.view_name="ORDERPOE")
     temp->applications[1].chart_orderpoe_ind = 1
    ELSEIF (p.view_name="ORDERS")
     temp->applications[1].chart_orders_ind = 1
    ENDIF
   ELSEIF (p.application_number=820000)
    IF (p.view_name="ORDERPOE")
     temp->applications[2].chart_orderpoe_ind = 1
    ELSEIF (p.view_name="ORDERS")
     temp->applications[2].chart_orders_ind = 1
    ENDIF
   ELSEIF (p.application_number=4250111)
    IF (p.view_name="ORDERPOE")
     temp->applications[3].chart_orderpoe_ind = 1
    ELSEIF (p.view_name="ORDERS")
     temp->applications[3].chart_orders_ind = 1
    ENDIF
   ELSEIF (p.application_number=610000)
    IF (p.view_name="ORDERPOE")
     temp->applications[4].chart_orderpoe_ind = 1
    ELSEIF (p.view_name="ORDERS")
     temp->applications[4].chart_orders_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM view_prefs p
  WHERE p.application_number IN (600005, 820000, 4250111, 610000)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.frame_type="ORDERS"
   AND p.view_name="ORDERPOE"
   AND p.active_ind=1
  DETAIL
   IF (p.application_number=600005)
    temp->applications[1].orders_orderpoe_ind = 1
   ELSEIF (p.application_number=820000)
    temp->applications[2].orders_orderpoe_ind = 1
   ELSEIF (p.application_number=4250111)
    temp->applications[3].orders_orderpoe_ind = 1
   ELSEIF (p.application_number=610000)
    temp->applications[4].orders_orderpoe_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO 4)
  IF ((((temp->applications[x].chart_orderpoe_ind=1)) OR ((temp->applications[x].chart_orders_ind=1)
   AND (temp->applications[x].orders_orderpoe_ind=1))) )
   SET temp->applications[x].orders_ind = 1
  ENDIF
  IF ((temp->applications[x].view_prefs_ind=1)
   AND (temp->applications[x].view_comp_prefs_ind=1)
   AND (temp->applications[x].detail_prefs_ind=1)
   AND (temp->applications[x].orders_ind=1))
   SET reply->applications[x].eligible_ind = 1
  ENDIF
 ENDFOR
 SET reply->applications[1].config_ind = - (1)
 SET reply->applications[2].config_ind = - (1)
 SET reply->applications[3].config_ind = - (1)
 SET reply->applications[4].config_ind = - (1)
 SELECT INTO "nl:"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE ap.application_number IN (600005, 820000, 4250111, 610000)
    AND ap.position_cd=0
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND trim(nvp.pvc_name)="RELATED_RESULTS_CONFIG")
  DETAIL
   IF (ap.application_number=600005)
    IF (nvp.pvc_value="1")
     reply->applications[1].config_ind = 1
    ELSE
     reply->applications[1].config_ind = 0
    ENDIF
   ELSEIF (ap.application_number=820000)
    IF (nvp.pvc_value="1")
     reply->applications[2].config_ind = 1
    ELSE
     reply->applications[2].config_ind = 0
    ENDIF
   ELSEIF (ap.application_number=4250111)
    IF (nvp.pvc_value="1")
     reply->applications[3].config_ind = 1
    ELSE
     reply->applications[3].config_ind = 0
    ENDIF
   ELSEIF (ap.application_number=610000)
    IF (nvp.pvc_value="1")
     reply->applications[4].config_ind = 1
    ELSE
     reply->applications[4].config_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   name_value_prefs nvp
  PLAN (dp
   WHERE dp.application_number IN (600005, 820000, 4250111, 610000)
    AND dp.position_cd=0
    AND dp.prsnl_id=0
    AND dp.person_id=0
    AND dp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.parent_entity_id=dp.detail_prefs_id
    AND trim(nvp.pvc_name) IN ("RELATED_RESULTS_INITIAL_LOAD", "RELATED_RESULTS_ADDITIONAL_LOAD"))
  DETAIL
   IF (dp.application_number=600005)
    IF (nvp.pvc_name="RELATED_RESULTS_INITIAL_LOAD")
     reply->applications[1].initial_load_value = nvp.pvc_value
    ELSEIF (nvp.pvc_name="RELATED_RESULTS_ADDITIONAL_LOAD")
     reply->applications[1].addtl_load_value = nvp.pvc_value
    ENDIF
   ELSEIF (dp.application_number=820000)
    IF (nvp.pvc_name="RELATED_RESULTS_INITIAL_LOAD")
     reply->applications[2].initial_load_value = nvp.pvc_value
    ELSEIF (nvp.pvc_name="RELATED_RESULTS_ADDITIONAL_LOAD")
     reply->applications[2].addtl_load_value = nvp.pvc_value
    ENDIF
   ELSEIF (dp.application_number=4250111)
    IF (nvp.pvc_name="RELATED_RESULTS_INITIAL_LOAD")
     reply->applications[3].initial_load_value = nvp.pvc_value
    ELSEIF (nvp.pvc_name="RELATED_RESULTS_ADDITIONAL_LOAD")
     reply->applications[3].addtl_load_value = nvp.pvc_value
    ENDIF
   ELSEIF (dp.application_number=610000)
    IF (nvp.pvc_name="RELATED_RESULTS_INITIAL_LOAD")
     reply->applications[4].initial_load_value = nvp.pvc_value
    ELSEIF (nvp.pvc_name="RELATED_RESULTS_ADDITIONAL_LOAD")
     reply->applications[4].addtl_load_value = nvp.pvc_value
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
