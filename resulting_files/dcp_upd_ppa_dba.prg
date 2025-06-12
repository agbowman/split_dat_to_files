CREATE PROGRAM dcp_upd_ppa:dba
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
 UPDATE  FROM person_prsnl_activity p
  SET p.ppa_comment = request->ppa_comment, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id
    = reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt
   + 1)
  PLAN (p
   WHERE (p.ppa_id=request->ppa_id))
  WITH counter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "ppa table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 CALL echo(build("ppa_id :",p.ppa_id))
 CALL echo(build("ppa_comment:",p.ppa_comment))
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("status: ",reply->status_data.status))
END GO
