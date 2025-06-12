CREATE PROGRAM bed_get_available_viewpoints:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 viewpoints[*]
      2 viewpoint_name = vc
      2 viewpoint_name_key = vc
      2 mp_viewpoint_id = f8
      2 active_ind = i2
      2 mpages[*]
        3 category_name = vc
        3 br_datamart_category_id = f8
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i8
      2 total_items = i8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE viewcount = i4 WITH noconstant(0), protect
 DECLARE mpagecount = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SELECT INTO "nl:"
  FROM mp_viewpoint v
  ORDER BY v.viewpoint_name
  DETAIL
   viewcount = (viewcount+ 1), stat = alterlist(reply->viewpoints,viewcount), reply->viewpoints[
   viewcount].viewpoint_name = v.viewpoint_name,
   reply->viewpoints[viewcount].viewpoint_name_key = v.viewpoint_name_key, reply->viewpoints[
   viewcount].mp_viewpoint_id = v.mp_viewpoint_id, reply->viewpoints[viewcount].active_ind = v
   .active_ind
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Error reading mp_viewpoint table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_datamart_category bdc,
   mp_viewpoint_reltn vr,
   (dummyt d  WITH seq = value(size(reply->viewpoints,5)))
  PLAN (d)
   JOIN (vr
   WHERE (vr.mp_viewpoint_id=reply->viewpoints[d.seq].mp_viewpoint_id))
   JOIN (bdc
   WHERE bdc.br_datamart_category_id=vr.br_datamart_category_id)
  ORDER BY vr.mp_viewpoint_id, vr.view_seq
  HEAD vr.mp_viewpoint_id
   mpagecount = 0
  DETAIL
   mpagecount = (mpagecount+ 1), stat = alterlist(reply->viewpoints[d.seq].mpages,mpagecount), reply
   ->viewpoints[d.seq].mpages[mpagecount].br_datamart_category_id = bdc.br_datamart_category_id,
   reply->viewpoints[d.seq].mpages[mpagecount].category_name = bdc.category_name
  WITH nocounter
 ;end select
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Error joining/reading br_datamart_category, mp_viewpoint_reltn tables"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
