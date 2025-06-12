CREATE PROGRAM cdi_upd_work_queue_action_keys:dba
 SET modify = predeclare
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE queue_cnt = i4 WITH noconstant(0), protect
 DECLARE queue_idx = i4 WITH noconstant(0), protect
 DECLARE upd_cnt = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_upd_work_queue_action_keys"
 SET queue_cnt = value(size(request->queue_qual,5))
 IF (queue_cnt <= 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REQUEST WAS EMPTY"
  GO TO exit_script
 ENDIF
 UPDATE  FROM cdi_work_queue q
  SET q.reg_action_keys_txt = request->reg_action_keys_txt, q.updt_cnt = (q.updt_cnt+ 1), q
   .updt_dt_tm = cnvtdatetime(sysdate),
   q.updt_task = reqinfo->updt_task, q.updt_id = reqinfo->updt_id, q.updt_applctx = reqinfo->
   updt_applctx
  WHERE expand(queue_idx,1,queue_cnt,q.work_queue_cd,request->queue_qual[queue_idx].work_queue_cd)
  WITH nocounter
 ;end update
 SET upd_cnt = curqual
 IF (upd_cnt < queue_cnt)
  SET ecode = 0
  SET emsg = fillstring(200," ")
  SET ecode = error(emsg,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_WORK_QUEUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
