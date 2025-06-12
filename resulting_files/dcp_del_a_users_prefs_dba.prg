CREATE PROGRAM dcp_del_a_users_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.name_value_prefs_id > 0
   AND nvp.parent_entity_name="APP_PREFS"
   AND nvp.parent_entity_id IN (
  (SELECT
   ap.app_prefs_id
   FROM app_prefs ap
   WHERE (ap.application_number=request->app_number)
    AND (ap.prsnl_id=request->prsnl_id)))
 ;end delete
 DELETE  FROM app_prefs ap
  WHERE ap.app_prefs_id > 0
   AND (ap.application_number=request->app_number)
   AND (ap.prsnl_id=request->prsnl_id)
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.name_value_prefs_id > 0
   AND nvp.parent_entity_name="VIEW_PREFS"
   AND nvp.parent_entity_id IN (
  (SELECT
   vp.view_prefs_id
   FROM view_prefs vp
   WHERE (vp.application_number=request->app_number)
    AND (vp.prsnl_id=request->prsnl_id)))
 ;end delete
 DELETE  FROM view_prefs vp
  WHERE vp.view_prefs_id > 0
   AND (vp.application_number=request->app_number)
   AND (vp.prsnl_id=request->prsnl_id)
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.name_value_prefs_id > 0
   AND nvp.parent_entity_name="VIEW_COMP_PREFS"
   AND nvp.parent_entity_id IN (
  (SELECT
   vcp.view_comp_prefs_id
   FROM view_comp_prefs vcp
   WHERE (vcp.application_number=request->app_number)
    AND (vcp.prsnl_id=request->prsnl_id)))
 ;end delete
 DELETE  FROM view_comp_prefs vcp
  WHERE vcp.view_comp_prefs_id > 0
   AND (vcp.application_number=request->app_number)
   AND (vcp.prsnl_id=request->prsnl_id)
  WITH nocounter
 ;end delete
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.name_value_prefs_id > 0
   AND nvp.parent_entity_name="DETAIL_PREFS"
   AND nvp.parent_entity_id IN (
  (SELECT
   dp.detail_prefs_id
   FROM detail_prefs dp
   WHERE (dp.application_number=request->app_number)
    AND (dp.prsnl_id=request->prsnl_id)))
 ;end delete
 DELETE  FROM detail_prefs dp
  WHERE dp.detail_prefs_id > 0
   AND (dp.application_number=request->app_number)
   AND (dp.prsnl_id=request->prsnl_id)
  WITH nocounter
 ;end delete
#exit_script
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
END GO
