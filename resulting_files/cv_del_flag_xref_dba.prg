CREATE PROGRAM cv_del_flag_xref:dba
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
 UPDATE  FROM cv_xref ref,
   (dummyt t  WITH seq = value(size(request->xref_rec,5)))
  SET ref.updt_dt_tm = cnvtdatetime(curdate,curtime), ref.updt_cnt = (ref.updt_cnt+ 1), ref.updt_id
    = reqinfo->updt_id,
   ref.updt_task = reqinfo->updt_task, ref.updt_applctx = reqinfo->updt_applctx, ref.active_status_cd
    = reqdata->active_status_cd,
   ref.updt_req = reqinfo->updt_req, ref.updt_app = reqinfo->updt_app, ref.active_ind = 0
  PLAN (t)
   JOIN (ref
   WHERE (ref.xref_id=request->xref_rec[t.seq].xref_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  GO TO xref_update_failed
 ENDIF
#xref_updt_failed
 SET reply->status_data.subeventstatus[1].operationname = "update"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cv_xref"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "del_flag_xref"
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
