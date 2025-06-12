CREATE PROGRAM bed_get_of_positions_list:dba
 FREE SET reply
 RECORD reply(
   1 plist[*]
     2 position_code_value = f8
     2 position_display = c40
     2 folders_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET tpos
 RECORD tpos(
   1 pos[*]
     2 code_value = f8
     2 disp = vc
     2 load_ind = i2
 )
 SET category_id = 0.0
 SELECT INTO "NL:"
  FROM br_position_category bpc
  WHERE (bpc.step_cat_mean=
  IF ((request->application_number=600005)) "ACUTE"
  ELSEIF ((request->application_number=961000)) "PCO"
  ELSEIF ((request->application_number=4250111)) "FIRSTNET"
  ENDIF
  )
  DETAIL
   category_id = bpc.category_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->plist,20)
 SET pcnt = 0
 SET alterlist_pcnt = 0
 SET tpcnt = 0
 IF ((request->component_flag=1))
  SELECT INTO "NL:"
   FROM br_position_cat_comp bpcc,
    code_value cv,
    detail_prefs dp,
    name_value_prefs nvp,
    alt_sel_cat a
   PLAN (bpcc
    WHERE bpcc.category_id=category_id)
    JOIN (cv
    WHERE cv.code_value=bpcc.position_cd
     AND cv.active_ind=1)
    JOIN (dp
    WHERE dp.application_number=outerjoin(request->application_number)
     AND dp.position_cd=outerjoin(cv.code_value)
     AND dp.prsnl_id=outerjoin(0.0)
     AND dp.person_id=outerjoin(0.0)
     AND dp.view_name=outerjoin("EASYSCRIPT")
     AND dp.view_seq=outerjoin(0)
     AND dp.comp_name=outerjoin("EASYSCRIPT")
     AND dp.comp_seq=outerjoin(0)
     AND dp.active_ind=outerjoin(1))
    JOIN (nvp
    WHERE nvp.parent_entity_name=outerjoin("DETAIL_PREFS")
     AND nvp.parent_entity_id=outerjoin(dp.detail_prefs_id)
     AND nvp.pvc_name=outerjoin("ES_TAB_ID_3_*")
     AND nvp.active_ind=outerjoin(1))
    JOIN (a
    WHERE a.alt_sel_category_id=outerjoin(cnvtreal(nvp.pvc_value)))
   ORDER BY cv.display, cv.code_value, nvp.parent_entity_id
   HEAD cv.code_value
    alterlist_pcnt = (alterlist_pcnt+ 1)
    IF (alterlist_pcnt > 20)
     stat = alterlist(reply->plist,(pcnt+ 20)), alterlist_pcnt = 1
    ENDIF
    pcnt = (pcnt+ 1), reply->plist[pcnt].position_code_value = cv.code_value, reply->plist[pcnt].
    position_display = cv.display,
    reply->plist[pcnt].folders_ind = 0
   HEAD a.alt_sel_category_id
    IF (a.alt_sel_category_id > 0)
     reply->plist[pcnt].folders_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->component_flag=2))
  SET tpcnt = 0
  SELECT INTO "NL:"
   FROM br_position_cat_comp bpcc,
    code_value cv
   PLAN (bpcc
    WHERE bpcc.category_id=category_id)
    JOIN (cv
    WHERE cv.code_value=bpcc.position_cd
     AND cv.active_ind=1)
   ORDER BY cv.display
   HEAD REPORT
    tpcnt = 0, alterlist_pcnt = 0, stat = alterlist(tpos->pos,100)
   HEAD cv.code_value
    tpcnt = (tpcnt+ 1), alterlist_pcnt = (alterlist_pcnt+ 1)
    IF (alterlist_pcnt > 100)
     stat = alterlist(tpos->pos,(tpcnt+ 100)), alterlist_pcnt = 1
    ENDIF
    tpos->pos[tpcnt].code_value = cv.code_value, tpos->pos[tpcnt].disp = cv.display
   FOOT REPORT
    stat = alterlist(tpos->pos,tpcnt)
   WITH nocounter
  ;end select
  SET app_level_ind = 0
  SELECT INTO "nl:"
   FROM view_prefs v
   PLAN (v
    WHERE (v.application_number=request->application_number)
     AND v.position_cd IN (0, null)
     AND v.prsnl_id IN (0, null)
     AND v.active_ind=1
     AND v.view_name IN ("ORDERPOE", "ORDERS"))
   HEAD REPORT
    app_level_ind = 1
   WITH nocounter
  ;end select
  IF (tpcnt > 0)
   IF (app_level_ind=1)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tpcnt)),
      dummyt d1,
      view_prefs v
     PLAN (d)
      JOIN (d1)
      JOIN (v
      WHERE (v.application_number=request->application_number)
       AND (v.position_cd=tpos->pos[d.seq].code_value)
       AND v.prsnl_id IN (0, null)
       AND v.active_ind=1)
     HEAD d.seq
      IF (v.view_prefs_id=0)
       tpos->pos[d.seq].load_ind = 1
      ENDIF
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tpcnt)),
     view_prefs v
    PLAN (d
     WHERE (tpos->pos[d.seq].load_ind=0))
     JOIN (v
     WHERE (v.application_number=request->application_number)
      AND (v.position_cd=tpos->pos[d.seq].code_value)
      AND v.prsnl_id IN (0, null)
      AND v.view_name IN ("ORDERPOE", "ORDERS")
      AND v.active_ind=1)
    HEAD d.seq
     tpos->pos[d.seq].load_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(tpcnt)),
     code_value cv,
     app_prefs ap,
     name_value_prefs nvp,
     alt_sel_cat a
    PLAN (d
     WHERE (tpos->pos[d.seq].load_ind=1))
     JOIN (cv
     WHERE (cv.code_value=tpos->pos[d.seq].code_value)
      AND cv.active_ind=1)
     JOIN (ap
     WHERE ap.application_number=outerjoin(request->application_number)
      AND ap.position_cd=outerjoin(cv.code_value)
      AND ap.prsnl_id=outerjoin(0.0)
      AND ap.active_ind=outerjoin(1))
     JOIN (nvp
     WHERE nvp.parent_entity_name=outerjoin("APP_PREFS")
      AND nvp.parent_entity_id=outerjoin(ap.app_prefs_id)
      AND nvp.pvc_name=outerjoin("INPT_CATALOG_BROWSER_*")
      AND nvp.pvc_value != outerjoin(" ")
      AND nvp.active_ind=outerjoin(1))
     JOIN (a
     WHERE a.alt_sel_category_id=outerjoin(cnvtreal(nvp.pvc_value)))
    ORDER BY d.seq
    HEAD REPORT
     pcnt = 0, alterlist_pcnt = 0, stat = alterlist(reply->plist,100)
    HEAD d.seq
     alterlist_pcnt = (alterlist_pcnt+ 1)
     IF (alterlist_pcnt > 100)
      stat = alterlist(reply->plist,(pcnt+ 100)), alterlist_pcnt = 1
     ENDIF
     pcnt = (pcnt+ 1), reply->plist[pcnt].position_code_value = tpos->pos[d.seq].code_value, reply->
     plist[pcnt].position_display = tpos->pos[d.seq].disp,
     reply->plist[pcnt].folders_ind = 0
    HEAD a.alt_sel_category_id
     IF (a.alt_sel_category_id > 0
      AND nvp.pvc_value > " ")
      reply->plist[pcnt].folders_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->plist,pcnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET stat = alterlist(reply->plist,pcnt)
 IF (pcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
