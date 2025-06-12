CREATE PROGRAM dcp_upd_task_response_link:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE addcnt = i4
 DECLARE updcnt = i4
 DECLARE delcnt = i4
 DECLARE failed = c1
 DECLARE updatecnt = i4
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 SET reply->status_data.status = "F"
 SET updatecnt = 0
 SET failed = "F"
 SET addcnt = 0
 SET updcnt = 0
 SET delcnt = 0
 SET updcnt = size(request->upd_qual,5)
 IF (updcnt > 0)
  SELECT INTO "nl:"
   FROM order_task_response otr,
    (dummyt d  WITH seq = value(updcnt))
   PLAN (d)
    JOIN (otr
    WHERE (otr.order_task_response_id=request->upd_qual[d.seq].order_task_response_id))
   DETAIL
    updatecnt = (updatecnt+ 1)
   WITH nocounter, forupdate(otr)
  ;end select
  IF (curqual=0)
   SET zero_row = 1
   SET reply->status_data.targetobjectvalue =
   "Could not obtain a lock on the order_task_response table."
   GO TO exit_script
  ENDIF
  UPDATE  FROM order_task_response otr,
    (dummyt d  WITH seq = value(updcnt))
   SET otr.response_minutes = request->upd_qual[d.seq].response_minutes, otr.route_cd = request->
    upd_qual[d.seq].route_cd, otr.qualification_flag = request->upd_qual[d.seq].qualification_flag,
    otr.updt_id = reqinfo->updt_id, otr.updt_cnt = (otr.updt_cnt+ 1), otr.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    otr.updt_task = reqinfo->updt_task, otr.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (otr
    WHERE (otr.order_task_response_id=request->upd_qual[d.seq].order_task_response_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SET addcnt = size(request->add_qual,5)
 IF (addcnt > 0)
  INSERT  FROM order_task_response otr,
    (dummyt d  WITH seq = value(addcnt))
   SET otr.order_task_response_id = seq(carenet_seq,nextval), otr.reference_task_id = request->
    add_qual[d.seq].reference_task_id, otr.response_task_id = request->add_qual[d.seq].
    response_task_id,
    otr.response_minutes = request->add_qual[d.seq].response_minutes, otr.route_cd = request->
    add_qual[d.seq].route_cd, otr.qualification_flag = request->add_qual[d.seq].qualification_flag,
    otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr.updt_task =
    reqinfo->updt_task,
    otr.updt_applctx = reqinfo->updt_applctx, otr.updt_cnt = 0
   PLAN (d)
    JOIN (otr)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ELSE
   SET reqinfo->commit_ind = 1
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET delcnt = size(request->del_qual,5)
 IF (delcnt > 0)
  FOR (x = 1 TO delcnt)
   DELETE  FROM order_task_response otr
    WHERE (otr.order_task_response_id=request->del_qual[x].order_task_response_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.operationname = "Update"
  SET reply->status_data.operationstatus = "F"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.targetobjectname = "ScriptMessage"
  SET reply->status_data.targetobjectvalue = "Script fail"
 ELSEIF (failed="Z")
  SET reply->status_data.status = "Z"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "003 05/21/08"
END GO
