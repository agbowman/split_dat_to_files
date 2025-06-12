CREATE PROGRAM dcp_upd_proxy:dba
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
 SET proxy_cnt = size(request->qual,5)
 FOR (x = 1 TO proxy_cnt)
  UPDATE  FROM proxy p
   SET p.active_ind = request->qual[x].active_ind, p.beg_effective_dt_tm = cnvtdatetime(request->
     qual[x].beg_effective_dt_tm), p.end_effective_dt_tm = cnvtdatetime(request->qual[x].
     end_effective_dt_tm),
    p.take_proxy_status_flag = request->qual[x].take_proxy_status_flag, p.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), p.updt_id = reqinfo->updt_id,
    p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
    .updt_cnt+ 1)
   PLAN (p
    WHERE (p.proxy_id=request->qual[x].proxy_id))
   WITH counter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "proxy table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
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
