CREATE PROGRAM cv_del_flag_dataset:dba
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
 UPDATE  FROM cv_dataset data,
   (dummyt t  WITH seq = value(size(request->dataset_rec,5)))
  SET data.updt_dt_tm = cnvtdatetime(curdate,curtime), data.updt_cnt = (data.updt_cnt+ 1), data
   .updt_id = reqinfo->updt_id,
   data.updt_task = reqinfo->updt_task, data.updt_applctx = reqinfo->updt_applctx, data
   .active_status_cd = reqdata->active_status_cd,
   data.updt_req = reqinfo->updt_req, data.updt_app = reqinfo->updt_app, data.active_ind = 0
  PLAN (t)
   JOIN (data
   WHERE (data.dataset_id=request->dataset_rec[t.seq].dataset_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  GO TO dataset_update_failed
 ENDIF
#dataset_updt_failed
 SET reply->status_data.subeventstatus[1].operationname = "update"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cv_dataset"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "del_flag_dataset"
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
