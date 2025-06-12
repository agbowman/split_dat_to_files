CREATE PROGRAM bed_get_fn_cpy_pos_tabs:dba
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
 SET reply->status_data.status = "F"
 SET tcount = 0
 SET tot_tcount = 0
 SELECT DISTINCT INTO "NL:"
  nvp.pvc_value
  FROM name_value_prefs nvp,
   view_prefs vp
  PLAN (vp
   WHERE vp.active_ind=1
    AND vp.application_number=4250111
    AND vp.prsnl_id=0
    AND vp.frame_type="TRACKLIST"
    AND vp.view_name="TRKLISTVIEW"
    AND (vp.position_cd=request->position_code_value))
   JOIN (nvp
   WHERE nvp.active_ind=1
    AND nvp.pvc_name="VIEW_CAPTION"
    AND nvp.parent_entity_id=vp.view_prefs_id)
  ORDER BY nvp.pvc_value
  HEAD REPORT
   tcount = 0, tot_tcount = 0, stat = alterlist(reply->tabs,10)
  DETAIL
   tcount = (tcount+ 1), tot_tcount = (tot_tcount+ 1)
   IF (tcount > 10)
    stat = alterlist(reply->tabs,(tot_tcount+ 10)), tcount = 1
   ENDIF
   reply->tabs[tot_tcount].name = nvp.pvc_value
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
