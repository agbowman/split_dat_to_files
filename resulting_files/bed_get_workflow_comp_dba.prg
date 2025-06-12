CREATE PROGRAM bed_get_workflow_comp:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 comp_name = vc
     2 comp_seq = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
#enditnow
 SELECT INTO "nl:"
  FROM view_prefs vp,
   name_value_prefs nvp
  PLAN (vp
   WHERE vp.application_number=961000
    AND vp.frame_type IN ("CHART", "ORG")
    AND (vp.position_cd=request->position_code_value)
    AND vp.prsnl_id=0
    AND vp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=vp.view_prefs_id
    AND nvp.parent_entity_name="VIEW_PREFS"
    AND nvp.pvc_name="VIEW_CAPTION")
  ORDER BY nvp.pvc_value
  HEAD REPORT
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(reply->clist,ccnt), reply->clist[ccnt].comp_name = trim(nvp
    .pvc_value),
   reply->clist[ccnt].comp_seq = ccnt
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
