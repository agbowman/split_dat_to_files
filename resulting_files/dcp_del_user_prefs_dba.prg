CREATE PROGRAM dcp_del_user_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET id_to_del = 0.0
 SET app_prefs_id[100] = 0.0
 SET detail_prefs_id[100] = 0.0
 SET view_prefs_id[100] = 0.0
 SET view_comp_prefs_id[100] = 0.0
 SET person = 0
 IF (prsnl_id > 0)
  SET person = 1
  SET id_to_del = request->prsnl_id
 ENDIF
 IF (position_cd > 0)
  SET person = 0
  SET id_to_del = request->position_cd
 ENDIF
 SELECT
  IF (person=1)
   WHERE ap.prsnl_id=id_to_del
  ELSE
   WHERE ap.position_cd=id_to_del
  ENDIF
  INTO "nl:"
  ap.app_prefs_id
  FROM app_prefs ap
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), app_prefs_id[count1] = ap.app_prefs_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO count1)
   DELETE  FROM name_value_prefs nvp
    WHERE (app_prefs_id[x]=nvp.parent_entity_id)
     AND nvp.parent_entity_name="APP_PREFS"
    WITH nocounter
   ;end delete
 ENDFOR
 IF (person=1)
  DELETE  FROM app_prefs ap
   WHERE ap.prsnl_id=id_to_del
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM app_prefs ap
   WHERE ap.position_cd=id_to_del
   WITH nocounter
  ;end delete
 ENDIF
 SELECT INTO "nl:"
  vp.*
  FROM view_prefs vp
  WHERE vp.prsnl_id=prsnl_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), view_prefs_id[count1] = vp.view_prefs_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO count1)
   DELETE  FROM name_value_prefs nvp
    WHERE (view_prefs_id[x]=nvp.parent_entity_id)
     AND nvp.parent_entity_name="VIEW_PREFS"
    WITH nocounter
   ;end delete
 ENDFOR
 IF (person=1)
  DELETE  FROM view_prefs vp
   WHERE vp.prsnl_id=id_to_del
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM view_prefs vp
   WHERE vp.position_cd=id_to_del
   WITH nocounter
  ;end delete
 ENDIF
 SELECT INTO "nl:"
  vcp.*
  FROM view_comp_prefs vcp
  WHERE vcp.prsnl_id=id_to_del
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), view_comp_prefs_id[count1] = vcp.view_comp_prefs_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO count1)
   DELETE  FROM name_value_prefs nvp
    WHERE (view_comp_prefs_id[x]=nvp.parent_entity_id)
     AND nvp.parent_entity_name="VIEW_COMP_PREFS"
    WITH nocounter
   ;end delete
 ENDFOR
 IF (person=1)
  DELETE  FROM view_comp_prefs vcp
   WHERE vcp.prsnl_id=id_to_del
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM view_comp_prefs vcp
   WHERE vcp.position_cd=id_to_del
   WITH nocounter
  ;end delete
 ENDIF
 SELECT INTO "nl:"
  dp.*
  FROM detail_prefs dp
  WHERE dp.prsnl_id=id_to_del
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), detail_prefs_id[count1] = dp.detail_prefs_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO count1)
   DELETE  FROM name_value_prefs nvp
    WHERE (detail_prefs_id[x]=nvp.parent_entity_id)
     AND nvp.parent_entity_name="DETAIL_PREFS"
    WITH nocounter
   ;end delete
 ENDFOR
 IF (person=1)
  DELETE  FROM detail_prefs dp
   WHERE dp.prsnl_id=id_to_del
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM detail_prefs dp
   WHERE dp.position_cd=id_to_del
   WITH nocounter
  ;end delete
 ENDIF
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
