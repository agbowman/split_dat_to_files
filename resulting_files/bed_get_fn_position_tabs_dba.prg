CREATE PROGRAM bed_get_fn_position_tabs:dba
 FREE SET reply
 RECORD reply(
   1 tabs[*]
     2 name = vc
     2 list_type = vc
     2 sequence = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcount = 0
 SET tot_tcount = 0
 DECLARE nvp_dp_parser = vc
 IF ((request->trk_group_code_value > 0))
  DECLARE search_string = vc
  SET search_string = build('"*',trim(cnvtstring(request->trk_group_code_value,20,0)),'*"')
  SET nvp_dp_parser = concat(" nvp_dp.parent_entity_id = dp.detail_prefs_id and ",
   ' nvp_dp.active_ind = 1 and nvp_dp.pvc_name = "TABINFO" and ',
   ' nvp_dp.parent_entity_name = "DETAIL_PREFS" and '," nvp_dp.pvc_value = ",search_string)
 ELSE
  SET nvp_dp_parser = concat("nvp_dp.parent_entity_id = dp.detail_prefs_id and ",
   'nvp_dp.active_ind = 1 and nvp_dp.pvc_name = "TABINFO" and ',
   'nvp_dp.parent_entity_name = "DETAIL_PREFS" ')
 ENDIF
 DECLARE vp_parse = vc
 SET vp_parse = build(" vp.active_ind = 1 and vp.application_number = 4250111 and ",
  ' vp.prsnl_id = 0 and vp.frame_type = "TRACKLIST" and ',' vp.view_name = "TRKLISTVIEW" and ',
  " vp.position_cd = ",request->position_code_value)
 SELECT INTO "NL:"
  FROM name_value_prefs nvp,
   name_value_prefs nvp2,
   view_prefs vp,
   name_value_prefs nvp_dp,
   detail_prefs dp
  PLAN (vp
   WHERE parser(vp_parse))
   JOIN (nvp
   WHERE nvp.active_ind=1
    AND nvp.pvc_name="VIEW_CAPTION"
    AND nvp.parent_entity_id=vp.view_prefs_id)
   JOIN (nvp2
   WHERE nvp2.active_ind=1
    AND nvp2.pvc_name="DISPLAY_SEQ"
    AND nvp2.parent_entity_id=nvp.parent_entity_id)
   JOIN (dp
   WHERE dp.active_ind=1
    AND dp.application_number=4250111
    AND dp.position_cd=vp.position_cd
    AND dp.prsnl_id=0.0
    AND dp.person_id=0.0
    AND dp.view_name="TRKLISTVIEW"
    AND dp.comp_name="CUSTOM"
    AND dp.comp_seq=1
    AND dp.view_seq=vp.view_seq)
   JOIN (nvp_dp
   WHERE parser(nvp_dp_parser))
  ORDER BY nvp2.pvc_value
  HEAD REPORT
   stat = alterlist(reply->tabs,20), tcount = 0, tot_tcount = 0
  DETAIL
   found = 0, beg_pos = 1, end_pos = findstring(";",nvp_dp.pvc_value,beg_pos,0)
   FOR (i = 1 TO tot_tcount)
     IF ((reply->tabs[i].name=nvp.pvc_value)
      AND (reply->tabs[i].list_type=substring(beg_pos,(end_pos - beg_pos),nvp_dp.pvc_value))
      AND (reply->tabs[i].sequence=cnvtint(nvp2.pvc_value)))
      found = 1, i = tot_tcount
     ENDIF
   ENDFOR
   IF (found=0)
    tcount = (tcount+ 1), tot_tcount = (tot_tcount+ 1)
    IF (tcount > 20)
     stat = alterlist(reply->tabs,(tot_tcount+ 20)), tcount = 1
    ENDIF
    reply->tabs[tot_tcount].name = nvp.pvc_value, reply->tabs[tot_tcount].list_type = substring(
     beg_pos,(end_pos - beg_pos),nvp_dp.pvc_value), reply->tabs[tot_tcount].sequence = cnvtint(nvp2
     .pvc_value)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->tabs,tot_tcount)
  WITH nocounter
 ;end select
#exit_script
 IF (tot_tcount > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
