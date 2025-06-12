CREATE PROGRAM cv_del_flag_response:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET updt_cnt = 0
 SET reply->status_data.status = "F"
 SET failed = "F"
 UPDATE  FROM cv_response resp,
   (dummyt t  WITH seq = value(size(request->response_rec,5)))
  SET resp.updt_dt_tm = cnvtdatetime(curdate,curtime), resp.updt_cnt = (resp.updt_cnt+ 1), resp
   .updt_id = reqinfo->updt_id,
   resp.updt_task = reqinfo->updt_task, resp.updt_applctx = reqinfo->updt_applctx, resp
   .active_status_cd = reqdata->active_status_cd,
   resp.updt_req = reqinfo->updt_req, resp.updt_app = reqinfo->updt_app, resp.active_ind = 0
  PLAN (t)
   JOIN (resp
   WHERE (resp.response_id=request->response_rec[t.seq].response_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  GO TO response_update_failed
 ENDIF
#response_updt_failed
 SET reply->status_data.subeventstatus[1].operationname = "update"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cv_response"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "del_flag_response"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
