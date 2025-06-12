CREATE PROGRAM dcp_del_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = vc WITH noconstant("F")
 DECLARE count1 = i2 WITH noconstant(0)
 DECLARE id_to_del = f8 WITH noconstant(0.0)
 DECLARE person = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET app_prefs_id[100] = 0.0
 SET detail_prefs_id[100] = 0.0
 SET view_prefs_id[100] = 0.0
 SET view_comp_prefs_id[100] = 0.0
 IF ((request->prsnl_id > 0))
  SET person = 1
  SET id_to_del = request->prsnl_id
 ELSEIF ((request->position_cd > 0))
  SET person = 0
  SET id_to_del = request->position_cd
 ELSE
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (person=1)
  SELECT INTO "nl:"
   FROM app_prefs ap
   WHERE ap.prsnl_id=id_to_del
    AND (ap.application_number=request->application_number)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), app_prefs_id[count1] = ap.app_prefs_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM app_prefs ap
   WHERE ap.position_cd=id_to_del
    AND (ap.application_number=request->application_number)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), app_prefs_id[count1] = ap.app_prefs_id
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = value(count1))
  SET nvp.seq = 1
  PLAN (d)
   JOIN (nvp
   WHERE (app_prefs_id[d.seq]=nvp.parent_entity_id)
    AND nvp.parent_entity_name="APP_PREFS")
  WITH nocounter
 ;end delete
 IF (person=1)
  DELETE  FROM app_prefs ap
   WHERE ap.prsnl_id=id_to_del
    AND (ap.application_number=request->application_number)
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM app_prefs ap
   WHERE ap.position_cd=id_to_del
    AND (ap.application_number=request->application_number)
   WITH nocounter
  ;end delete
 ENDIF
 IF (person=1)
  SELECT INTO "nl:"
   FROM view_prefs vp
   WHERE vp.prsnl_id=id_to_del
    AND (vp.application_number=request->application_number)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), view_prefs_id[count1] = vp.view_prefs_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM view_prefs vp
   WHERE vp.position_cd=id_to_del
    AND (vp.application_number=request->application_number)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), view_prefs_id[count1] = vp.view_prefs_id
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = value(count1))
  SET nvp.seq = 1
  PLAN (d)
   JOIN (nvp
   WHERE (view_prefs_id[d.seq]=nvp.parent_entity_id)
    AND nvp.parent_entity_name="VIEW_PREFS")
  WITH nocounter
 ;end delete
 IF (person=1)
  DELETE  FROM view_prefs vp
   WHERE vp.prsnl_id=id_to_del
    AND (vp.application_number=request->application_number)
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM view_prefs vp
   WHERE vp.position_cd=id_to_del
    AND (vp.application_number=request->application_number)
   WITH nocounter
  ;end delete
 ENDIF
 IF (person=1)
  SELECT INTO "nl:"
   FROM view_comp_prefs vcp
   WHERE vcp.prsnl_id=id_to_del
    AND (vcp.application_number=request->application_number)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), view_comp_prefs_id[count1] = vcp.view_comp_prefs_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM view_comp_prefs vcp
   WHERE vcp.position_cd=id_to_del
    AND (vcp.application_number=request->application_number)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), view_comp_prefs_id[count1] = vcp.view_comp_prefs_id
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = value(count1))
  SET nvp.seq = 1
  PLAN (d)
   JOIN (nvp
   WHERE (view_comp_prefs_id[d.seq]=nvp.parent_entity_id)
    AND nvp.parent_entity_name="VIEW_COMP_PREFS")
  WITH nocounter
 ;end delete
 IF (person=1)
  DELETE  FROM view_comp_prefs vcp
   WHERE vcp.prsnl_id=id_to_del
    AND (vcp.application_number=request->application_number)
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM view_comp_prefs vcp
   WHERE vcp.position_cd=id_to_del
    AND (vcp.application_number=request->application_number)
   WITH nocounter
  ;end delete
 ENDIF
 IF (person=1)
  SELECT INTO "nl:"
   FROM detail_prefs dp
   WHERE dp.prsnl_id=id_to_del
    AND (dp.application_number=request->application_number)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), detail_prefs_id[count1] = dp.detail_prefs_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM detail_prefs dp
   WHERE dp.position_cd=id_to_del
    AND (dp.application_number=request->application_number)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), detail_prefs_id[count1] = dp.detail_prefs_id
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = value(count1))
  SET nvp.seq = 1
  PLAN (d)
   JOIN (nvp
   WHERE (detail_prefs_id[d.seq]=nvp.parent_entity_id)
    AND nvp.parent_entity_name="DETAIL_PREFS")
  WITH nocounter
 ;end delete
 IF (person=1)
  DELETE  FROM detail_prefs dp
   WHERE dp.prsnl_id=id_to_del
    AND (dp.application_number=request->application_number)
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM detail_prefs dp
   WHERE dp.position_cd=id_to_del
    AND (dp.application_number=request->application_number)
   WITH nocounter
  ;end delete
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
