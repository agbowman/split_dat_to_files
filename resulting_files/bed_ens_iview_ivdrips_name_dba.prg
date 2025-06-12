CREATE PROGRAM bed_ens_iview_ivdrips_name:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET vcnt = size(request->views,5)
 IF (vcnt > 0)
  UPDATE  FROM working_view_section ws,
    (dummyt d  WITH seq = value(vcnt))
   SET ws.display_name = request->ivdrips_section_name, ws.updt_id = reqinfo->updt_id, ws.updt_dt_tm
     = cnvtdatetime(curdate,curtime),
    ws.updt_task = reqinfo->updt_task, ws.updt_applctx = reqinfo->updt_applctx, ws.updt_cnt = (ws
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (ws
    WHERE (ws.working_view_id=request->views[d.seq].id)
     AND ws.section_type_flag=1)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating working_view_section table")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
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
