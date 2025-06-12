CREATE PROGRAM dcp_del_viewname_prefs:dba
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
 SET app_prefs_id[100] = 0.0
 SET detail_prefs_id[100] = 0.0
 SET view_prefs_id[100] = 0.0
 SET view_comp_prefs_id[100] = 0.0
 SET beg_prsnl_id = 0.0
 SET end_prsnl_id = 0.0
 IF ((request->viewname=""))
  GO TO exit_script
 ENDIF
 IF ((request->prsnl_id=0))
  SET beg_prsnl_id = 0
  SET end_prsnl_id = 999999999
 ELSE
  SET beg_prsnl_id = request->prsnl_id
  SET end_prsnl_id = request->prsnl_id
 ENDIF
 SELECT INTO "nl:"
  vp.*
  FROM view_prefs vp
  WHERE vp.prsnl_id > 0
   AND vp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(vp.view_name)=cnvtupper(request->viewname)
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
 DELETE  FROM view_prefs vp
  WHERE vp.prsnl_id > 0
   AND vp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(vp.view_name)=cnvtupper(request->viewname)
  WITH nocounter
 ;end delete
 SET count1 = 0
 SELECT INTO "nl:"
  vcp.*
  FROM view_comp_prefs vcp
  WHERE vcp.prsnl_id > 0
   AND vcp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(vcp.view_name)=cnvtupper(request->viewname)
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
 DELETE  FROM view_comp_prefs vcp
  WHERE vcp.prsnl_id > 0
   AND vcp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(vcp.view_name)=cnvtupper(request->viewname)
  WITH nocounter
 ;end delete
 SET count1 = 0
 SELECT INTO "nl:"
  dp.*
  FROM detail_prefs dp
  WHERE dp.prsnl_id > 0
   AND dp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(dp.view_name)=cnvtupper(request->viewname)
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
 DELETE  FROM detail_prefs dp
  WHERE dp.prsnl_id > 0
   AND dp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(dp.view_name)=cnvtupper(request->viewname)
  WITH nocounter
 ;end delete
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
