CREATE PROGRAM dcp_upd_pw_variance:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cfailed = "F"
 SELECT INTO "nl:"
  FROM pw_variance_reltn pvr
  WHERE (pvr.pw_variance_reltn_id=request->pw_variance_reltn_id)
  WITH forupdate(pvr), nocounter
 ;end select
 IF (curqual=0)
  GO TO pvr_get_failed
 ENDIF
 UPDATE  FROM pw_variance_reltn pvr
  SET pvr.active_ind = 0, pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pvr.updt_id = reqinfo->
   updt_id,
   pvr.updt_task = reqinfo->updt_task, pvr.updt_cnt = (pvr.updt_cnt+ 1), pvr.updt_applctx = reqinfo->
   updt_applctx
  WHERE (pvr.pw_variance_reltn_id=request->pw_variance_reltn_id)
 ;end update
 IF (curqual=0)
  GO TO pvr_upd_failed
 ENDIF
 GO TO exit_script
#pvr_get_failed
 SET reply->status_data.subeventstatus[1].operationname = "pvr get"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pvr get"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_variance_reltn"
 SET cfailed = "T"
 GO TO exit_script
#pvr_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "pvr upd"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "pvr upd"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_upd_pw_variance_reltn"
 SET cfailed = "T"
 GO TO exit_script
#exit_script
 IF (cfailed="T")
  ROLLBACK
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
