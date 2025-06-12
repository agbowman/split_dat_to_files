CREATE PROGRAM bed_get_fn_tab_by_col_view:dba
 FREE SET reply
 RECORD reply(
   1 tabs[*]
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_nvp
 RECORD temp_nvp(
   1 plist[*]
     2 parent_entity_id = f8
 )
 FREE SET temp_vp
 RECORD temp_vp(
   1 vlist[*]
     2 view_prefs_id = f8
 )
 SET reply->status_data.status = "F"
 SET tab_count = 0
 SET tot_count = 0
 SET pcount = 0
 SET tot_pcount = 0
 DECLARE list_type = vc
 DECLARE search_string = vc
 SET search_string = build('"',trim(request->list_type),"*",trim(cnvtstring(request->column_view_id,
    20,0)),"*",
  trim(cnvtstring(request->trk_group_code_value,20,0)),'*"')
 DECLARE nvp_parser = vc
 SET nvp_parser = concat('nvp.active_ind = 1 and nvp.pvc_name = "TABINFO" and ',
  'nvp.parent_entity_name = "DETAIL_PREFS" and ',"(nvp.pvc_value = ",trim(search_string),")")
 SELECT INTO "NL:"
  FROM name_value_prefs nvp
  PLAN (nvp
   WHERE parser(nvp_parser))
  HEAD REPORT
   stat = alterlist(temp_nvp->plist,50)
  DETAIL
   pcount = (pcount+ 1), tot_pcount = (tot_pcount+ 1)
   IF (pcount > 50)
    stat = alterlist(temp_nvp->plist,(tot_pcount+ 50)), pcount = 1
   ENDIF
   temp_nvp->plist[tot_pcount].parent_entity_id = nvp.parent_entity_id
  FOOT REPORT
   stat = alterlist(temp_nvp->plist,tot_pcount)
  WITH nocounter
 ;end select
 SET stat = alterlist(temp_vp->vlist,tot_pcount)
 IF (tot_pcount > 0)
  SELECT INTO "NL:"
   FROM detail_prefs dp,
    view_prefs vp,
    (dummyt d  WITH seq = tot_pcount)
   PLAN (d
    WHERE (temp_nvp->plist[d.seq].parent_entity_id > 0))
    JOIN (dp
    WHERE (dp.detail_prefs_id=temp_nvp->plist[d.seq].parent_entity_id)
     AND dp.active_ind=1
     AND dp.application_number=4250111
     AND dp.prsnl_id=0.0
     AND dp.person_id=0.0
     AND dp.view_name="TRKLISTVIEW"
     AND dp.comp_name="CUSTOM"
     AND dp.comp_seq=1)
    JOIN (vp
    WHERE vp.application_number=4250111
     AND vp.position_cd=dp.position_cd
     AND vp.view_seq=dp.view_seq
     AND vp.active_ind=1
     AND vp.frame_type="TRACKLIST"
     AND vp.view_name="TRKLISTVIEW"
     AND vp.view_seq=dp.view_seq
     AND vp.position_cd=dp.position_cd)
   DETAIL
    tab_count = (tab_count+ 1), temp_vp->vlist[tab_count].view_prefs_id = vp.view_prefs_id
   FOOT REPORT
    stat = alterlist(temp_vp->vlist,tab_count)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->tabs,tab_count)
 IF (tab_count > 0)
  SELECT INTO "NL:"
   FROM name_value_prefs nvp,
    (dummyt d  WITH seq = tab_count)
   PLAN (d
    WHERE (temp_vp->vlist[d.seq].view_prefs_id > 0))
    JOIN (nvp
    WHERE nvp.active_ind=1
     AND nvp.pvc_name="VIEW_CAPTION"
     AND (nvp.parent_entity_id=temp_vp->vlist[d.seq].view_prefs_id))
   ORDER BY nvp.pvc_value
   HEAD nvp.pvc_value
    tot_count = (tot_count+ 1), reply->tabs[tot_count].name = nvp.pvc_value
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->tabs,tot_count)
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
