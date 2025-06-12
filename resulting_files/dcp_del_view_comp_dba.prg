CREATE PROGRAM dcp_del_view_comp:dba
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
 SET app_nbr = 0
 SET psn_cd = 0.0
 SET prsnl_id = 0.0
 SET view_name = "            "
 SET view_seq = 0
 SET comp_name = "            "
 SET comp_seq = 0
 SET parent_entity_name = "                     "
 SET parent_entity_id[500] = 0.0
 SET count1 = 0
 SELECT INTO "nl:"
  vcp.*
  FROM view_comp_prefs vcp
  WHERE (vcp.view_comp_prefs_id=request->view_comp_prefs_id)
  DETAIL
   app_nbr = vcp.application_number, psn_cd = vcp.position_cd, prsnl_id = vcp.prsnl_id,
   view_name = vcp.view_name, view_seq = vcp.view_seq, comp_name = vcp.comp_name,
   comp_seq = vcp.comp_seq
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_program
 ENDIF
#del_detail_prefs
 SELECT INTO "nl:"
  dp.detail_prefs_id
  FROM detail_prefs dp
  WHERE dp.application_number=app_nbr
   AND dp.position_cd=psn_cd
   AND dp.prsnl_id=prsnl_id
   AND dp.view_name=view_name
   AND dp.view_seq=view_seq
   AND dp.comp_name=comp_name
   AND dp.comp_seq=comp_seq
  HEAD REPORT
   parent_entity_name = "DETAIL_PREFS"
  DETAIL
   count1 = (count1+ 1), parent_entity_id[count1] = dp.detail_prefs_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO del_view_comp_prefs
 ENDIF
 FOR (x = 1 TO count1)
  DELETE  FROM name_value_prefs nvp
   WHERE nvp.parent_entity_name=parent_entity_name
    AND (nvp.parent_entity_id=parent_entity_id[x])
   WITH nocounter
  ;end delete
  DELETE  FROM detail_prefs dp
   WHERE (dp.detail_prefs_id=parent_entity_id[x])
   WITH nocounter
  ;end delete
 ENDFOR
#del_view_comp_prefs
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.parent_entity_name="VIEW_COMP_PREFS"
   AND (nvp.parent_entity_id=request->view_comp_prefs_id)
  WITH nocounter
 ;end delete
 DELETE  FROM view_comp_prefs vcp
  WHERE (vcp.view_comp_prefs_id=request->view_comp_prefs_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL echo(build("script failed  ",curqual))
  SET reply->status_data.subeventstatus[1].targetobjectname = "view_comp_prefs table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET failed = "T"
 ENDIF
#exit_program
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
