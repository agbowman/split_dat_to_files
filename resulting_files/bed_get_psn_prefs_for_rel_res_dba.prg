CREATE PROGRAM bed_get_psn_prefs_for_rel_res:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 positions[*]
      2 code_value = f8
      2 display = vc
      2 eligible_ind = i2
      2 config_ind = i2
      2 initial_load_value = vc
      2 addtl_load_value = vc
    1 too_many_results_ind = i2
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
   1 positions[*]
     2 code_value = f8
     2 display = vc
     2 any_view_prefs_ind = i2
     2 view_prefs_ind = i2
     2 view_comp_prefs_ind = i2
     2 detail_prefs_ind = i2
     2 chart_orders_ind = i2
     2 chart_orderpoe_ind = i2
     2 orders_orderpoe_ind = i2
     2 orders_ind = i2
     2 eligible_ind = i2
     2 config_exists = i2
     2 config_value = vc
     2 initial_load_exists = i2
     2 initial_load_value = vc
     2 addtl_load_exists = i2
     2 addtl_load_value = vc
 )
 DECLARE cv_parse = vc
 SET cv_parse = "cv.active_ind = 1 and cv.code_set = 88"
 IF ((request->search_string > " "))
  IF (cnvtupper(request->search_type_flag)="C")
   SET cv_parse = build(cv_parse," and cnvtupper(cv.display) = '*",cnvtupper(request->search_string),
    "*'")
  ELSE
   SET cv_parse = build(cv_parse," and cnvtupper(cv.display) = '",cnvtupper(request->search_string),
    "*'")
  ENDIF
 ENDIF
 SET cnt = 0
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE parser(cv_parse)
  ORDER BY cv.display
  HEAD REPORT
   cnt = 10, pcnt = 0, stat = alterlist(temp->positions,cnt)
  DETAIL
   cnt = (cnt+ 1), pcnt = (pcnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(temp->positions,(pcnt+ 10))
   ENDIF
   temp->positions[pcnt].code_value = cv.code_value, temp->positions[pcnt].display = cv.display
  FOOT REPORT
   stat = alterlist(temp->positions,pcnt)
  WITH nocounter
 ;end select
 IF (pcnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->max_reply > 0)
  AND (pcnt > request->max_reply))
  SET reply->too_many_results_ind = 1
  GO TO exit_script
 ENDIF
 SET app_view_prefs_ind = 0
 SET app_view_comp_prefs_ind = 0
 SET app_detail_prefs_ind = 0
 SET app_chart_orders_ind = 0
 SET app_chart_orderpoe_ind = 0
 SET app_orders_orderpoe_ind = 0
 SET app_orders_ind = 0
 SELECT INTO "nl:"
  FROM view_prefs p
  WHERE (p.application_number=request->application_id)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.frame_type="DPRESVIEW"
   AND p.view_name="DPRESULTVIEW"
   AND p.active_ind=1
  DETAIL
   app_view_prefs_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM view_comp_prefs p
  WHERE (p.application_number=request->application_id)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.view_name="DPRESULTVIEW"
   AND p.comp_name="DETAILPANE"
   AND p.active_ind=1
  DETAIL
   app_view_comp_prefs_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM detail_prefs p
  WHERE (p.application_number=request->application_id)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.person_id=0
   AND p.view_name="DPRESULTVIEW"
   AND p.comp_name="DETAILPANE"
   AND p.active_ind=1
  DETAIL
   app_detail_prefs_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM view_prefs p
  WHERE (p.application_number=request->application_id)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.frame_type="CHART"
   AND p.view_name IN ("ORDERPOE", "ORDERS")
   AND p.active_ind=1
  DETAIL
   IF (p.view_name="ORDERPOE")
    app_chart_orderpoe_ind = 1
   ELSEIF (p.view_name="ORDERS")
    app_chart_orders_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM view_prefs p
  WHERE (p.application_number=request->application_id)
   AND p.position_cd=0
   AND p.prsnl_id=0
   AND p.frame_type="ORDERS"
   AND p.view_name="ORDERPOE"
   AND p.active_ind=1
  DETAIL
   app_orders_orderpoe_ind = 1
  WITH nocounter
 ;end select
 IF (((app_chart_orderpoe_ind=1) OR (app_chart_orders_ind=1
  AND app_orders_orderpoe_ind=1)) )
  SET app_orders_ind = 1
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt),
   view_prefs p
  PLAN (d)
   JOIN (p
   WHERE (p.application_number=request->application_id)
    AND (p.position_cd=temp->positions[d.seq].code_value)
    AND p.prsnl_id=0
    AND p.active_ind=1)
  DETAIL
   temp->positions[d.seq].any_view_prefs_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt),
   view_prefs p
  PLAN (d)
   JOIN (p
   WHERE (p.application_number=request->application_id)
    AND (p.position_cd=temp->positions[d.seq].code_value)
    AND p.prsnl_id=0
    AND p.frame_type="DPRESVIEW"
    AND p.view_name="DPRESULTVIEW"
    AND p.active_ind=1)
  DETAIL
   temp->positions[d.seq].view_prefs_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt),
   view_comp_prefs p
  PLAN (d)
   JOIN (p
   WHERE (p.application_number=request->application_id)
    AND (p.position_cd=temp->positions[d.seq].code_value)
    AND p.prsnl_id=0
    AND p.view_name="DPRESULTVIEW"
    AND p.comp_name="DETAILPANE"
    AND p.active_ind=1)
  DETAIL
   temp->positions[d.seq].view_comp_prefs_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt),
   detail_prefs p
  PLAN (d)
   JOIN (p
   WHERE (p.application_number=request->application_id)
    AND (p.position_cd=temp->positions[d.seq].code_value)
    AND p.prsnl_id=0
    AND p.person_id=0
    AND p.view_name="DPRESULTVIEW"
    AND p.comp_name="DETAILPANE"
    AND p.active_ind=1)
  DETAIL
   temp->positions[d.seq].detail_prefs_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt),
   view_prefs p
  PLAN (d)
   JOIN (p
   WHERE (p.application_number=request->application_id)
    AND (p.position_cd=temp->positions[d.seq].code_value)
    AND p.prsnl_id=0
    AND p.frame_type="CHART"
    AND p.view_name IN ("ORDERPOE", "ORDERS")
    AND p.active_ind=1)
  DETAIL
   IF (p.view_name="ORDERPOE")
    temp->positions[d.seq].chart_orderpoe_ind = 1
   ELSEIF (p.view_name="ORDERS")
    temp->positions[d.seq].chart_orders_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt),
   view_prefs p
  PLAN (d)
   JOIN (p
   WHERE (p.application_number=request->application_id)
    AND (p.position_cd=temp->positions[d.seq].code_value)
    AND p.prsnl_id=0
    AND p.frame_type="ORDERS"
    AND p.view_name="ORDERPOE"
    AND p.active_ind=1)
  DETAIL
   temp->positions[d.seq].orders_orderpoe_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt)
  PLAN (d)
  DETAIL
   IF ((temp->positions[d.seq].any_view_prefs_ind=1))
    IF ((((temp->positions[d.seq].chart_orderpoe_ind=1)) OR ((temp->positions[d.seq].chart_orders_ind
    =1)
     AND (temp->positions[d.seq].orders_orderpoe_ind=1))) )
     temp->positions[d.seq].orders_ind = 1
    ENDIF
    IF ((temp->positions[d.seq].view_prefs_ind=1)
     AND (temp->positions[d.seq].view_comp_prefs_ind=1)
     AND (temp->positions[d.seq].orders_ind=1)
     AND (((temp->positions[d.seq].detail_prefs_ind=1)) OR (app_detail_prefs_ind=1)) )
     temp->positions[d.seq].eligible_ind = 1
    ENDIF
   ELSE
    IF (app_view_prefs_ind=1
     AND app_view_comp_prefs_ind=1
     AND app_orders_ind=1
     AND (((temp->positions[d.seq].detail_prefs_ind=1)) OR (app_detail_prefs_ind=1)) )
     temp->positions[d.seq].eligible_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt),
   app_prefs ap,
   name_value_prefs nvp
  PLAN (d
   WHERE (temp->positions[d.seq].eligible_ind=1))
   JOIN (ap
   WHERE (ap.application_number=request->application_id)
    AND (ap.position_cd=temp->positions[d.seq].code_value)
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND trim(nvp.pvc_name)="RELATED_RESULTS_CONFIG")
  DETAIL
   temp->positions[d.seq].config_exists = 1, temp->positions[d.seq].config_value = nvp.pvc_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt),
   detail_prefs dp,
   name_value_prefs nvp
  PLAN (d)
   JOIN (dp
   WHERE (dp.application_number=request->application_id)
    AND (dp.position_cd=temp->positions[d.seq].code_value)
    AND dp.view_name="DPRESULTVIEW"
    AND dp.comp_name="DETAILPANE"
    AND dp.prsnl_id=0
    AND dp.person_id=0
    AND dp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.parent_entity_id=dp.detail_prefs_id
    AND trim(nvp.pvc_name) IN ("RELATED_RESULTS_INITIAL_LOAD", "RELATED_RESULTS_ADDITIONAL_LOAD"))
  DETAIL
   IF (nvp.pvc_name="RELATED_RESULTS_INITIAL_LOAD")
    temp->positions[d.seq].initial_load_exists = 1, temp->positions[d.seq].initial_load_value = nvp
    .pvc_value
   ENDIF
   IF (nvp.pvc_name="RELATED_RESULTS_ADDITIONAL_LOAD")
    temp->positions[d.seq].addtl_load_exists = 1, temp->positions[d.seq].addtl_load_value = nvp
    .pvc_value
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->positions,pcnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pcnt)
  PLAN (d)
  DETAIL
   reply->positions[d.seq].code_value = temp->positions[d.seq].code_value, reply->positions[d.seq].
   display = temp->positions[d.seq].display, reply->positions[d.seq].eligible_ind = temp->positions[d
   .seq].eligible_ind
   IF ((temp->positions[d.seq].config_exists=1))
    IF ((temp->positions[d.seq].config_value="1"))
     reply->positions[d.seq].config_ind = 1
    ELSE
     reply->positions[d.seq].config_ind = 0
    ENDIF
   ELSE
    reply->positions[d.seq].config_ind = - (1)
   ENDIF
   IF ((temp->positions[d.seq].initial_load_exists=1))
    reply->positions[d.seq].initial_load_value = temp->positions[d.seq].initial_load_value
   ENDIF
   IF ((temp->positions[d.seq].addtl_load_exists=1))
    reply->positions[d.seq].addtl_load_value = temp->positions[d.seq].addtl_load_value
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
