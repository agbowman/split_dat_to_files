CREATE PROGRAM dcp_add_prsnl_notify_ppr:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 INSERT  FROM prsnl_notify_ppr pnp
  SET pnp.prsnl_notify_id = request->prsnl_notify_id, pnp.ppr_cd = request->ppr_cd, pnp.ppr_flag =
   request->ppr_flag,
   pnp.updt_dt_tm = cnvtdatetime(curdate,curtime), pnp.updt_id = reqinfo->updt_id, pnp.updt_task =
   reqinfo->updt_task,
   pnp.updt_applctx = reqinfo->updt_applctx, pnp.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_notify_ppr table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
