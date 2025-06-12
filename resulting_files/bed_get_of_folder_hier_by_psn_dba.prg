CREATE PROGRAM bed_get_of_folder_hier_by_psn:dba
 FREE SET reply
 RECORD reply(
   1 flist[*]
     2 folder_id = f8
     2 folder_name = vc
     2 easyscript_seq = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 IF ((request->component_flag=1))
  SET folder_cnt = 0
  SET detail_prefs_id = 0.0
  SELECT INTO "NL:"
   FROM detail_prefs dp,
    name_value_prefs nvp
   PLAN (dp
    WHERE (dp.application_number=request->application_number)
     AND (dp.position_cd=request->position_code_value)
     AND dp.prsnl_id=0.0
     AND dp.person_id=0.0
     AND dp.view_name="EASYSCRIPT"
     AND dp.view_seq=0
     AND dp.comp_name="EASYSCRIPT"
     AND dp.comp_seq=0
     AND dp.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.parent_entity_id=dp.detail_prefs_id
     AND nvp.pvc_name="ES_TAB_COUNT_3"
     AND nvp.active_ind=1)
   DETAIL
    folder_cnt = cnvtint(nvp.pvc_value), detail_prefs_id = dp.detail_prefs_id
   WITH nocounter
  ;end select
  IF (folder_cnt > 0)
   FOR (f = 1 TO folder_cnt)
    SET folder_name = concat("ES_TAB_ID_3_",cnvtstring(f))
    SELECT INTO "NL:"
     FROM name_value_prefs nvp,
      alt_sel_cat a
     PLAN (nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=detail_prefs_id
       AND nvp.pvc_name=folder_name
       AND nvp.active_ind=1)
      JOIN (a
      WHERE a.alt_sel_category_id=cnvtreal(nvp.pvc_value))
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->flist,fcnt), reply->flist[fcnt].folder_id = a
      .alt_sel_category_id,
      reply->flist[fcnt].folder_name = a.short_description, reply->flist[fcnt].easyscript_seq =
      cnvtint(substring(13,2,nvp.pvc_name))
     WITH nocounter
    ;end select
   ENDFOR
  ENDIF
 ELSEIF ((request->component_flag=2))
  SET stat = alterlist(reply->flist,2)
  SELECT INTO "NL:"
   FROM app_prefs ap,
    name_value_prefs nvp,
    alt_sel_cat a
   PLAN (ap
    WHERE (ap.application_number=request->application_number)
     AND (ap.position_cd=request->position_code_value)
     AND ap.prsnl_id=0.0
     AND ap.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name IN ("INPT_CATALOG_BROWSER_HOME", "INPT_CATALOG_BROWSER_ROOT")
     AND nvp.pvc_value > " "
     AND nvp.active_ind=1)
    JOIN (a
    WHERE a.alt_sel_category_id=cnvtreal(nvp.pvc_value))
   ORDER BY a.short_description
   DETAIL
    IF (nvp.pvc_name="INPT_CATALOG_BROWSER_HOME")
     reply->flist[1].folder_id = a.alt_sel_category_id, reply->flist[1].folder_name = a
     .short_description
    ELSEIF (nvp.pvc_name="INPT_CATALOG_BROWSER_ROOT")
     reply->flist[2].folder_id = a.alt_sel_category_id, reply->flist[2].folder_name = a
     .short_description
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->component_flag=1)
  AND fcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
