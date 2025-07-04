CREATE PROGRAM dcp_readme_del_ptlistview:dba
 RECORD req(
   1 prsnl_id = f8
   1 viewname = vc
 )
 SET req->prsnl_id = 0
 SET req->viewname = "PTLISTVIEW"
 SET failed = "F"
 SET count1 = 0
 SET app_prefs_id[100] = 0
 SET detail_prefs_id[100] = 0
 SET view_prefs_id[100] = 0
 SET view_comp_prefs_id[100] = 0
 SET beg_prsnl_id = 0
 SET end_prsnl_id = 0
 IF ((req->viewname=""))
  GO TO exit_script
 ENDIF
 IF ((req->prsnl_id=0))
  SET beg_prsnl_id = 0
  SET end_prsnl_id = 999999999
 ELSE
  SET beg_prsnl_id = req->prsnl_id
  SET end_prsnl_id = req->prsnl_id
 ENDIF
 SELECT INTO "nl:"
  vp.*
  FROM view_prefs vp
  WHERE vp.prsnl_id > 0
   AND vp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(vp.view_name)=cnvtupper(req->viewname)
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
   AND cnvtupper(vp.view_name)=cnvtupper(req->viewname)
  WITH nocounter
 ;end delete
 SET count1 = 0
 SELECT INTO "nl:"
  vcp.*
  FROM view_comp_prefs vcp
  WHERE vcp.prsnl_id > 0
   AND vcp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(vcp.view_name)=cnvtupper(req->viewname)
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
   AND cnvtupper(vcp.view_name)=cnvtupper(req->viewname)
  WITH nocounter
 ;end delete
 SET count1 = 0
 SELECT INTO "nl:"
  dp.*
  FROM detail_prefs dp
  WHERE dp.prsnl_id > 0
   AND dp.prsnl_id BETWEEN beg_prsnl_id AND end_prsnl_id
   AND cnvtupper(dp.view_name)=cnvtupper(req->viewname)
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
   AND cnvtupper(dp.view_name)=cnvtupper(req->viewname)
  WITH nocounter
 ;end delete
#exit_script
 IF (failed="F")
  COMMIT
 ENDIF
END GO
