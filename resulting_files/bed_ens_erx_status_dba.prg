CREATE PROGRAM bed_ens_erx_status:dba
 IF ( NOT (validate(reply,0)))
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
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->prsnl_reltns,5)
 IF (req_cnt > 0)
  SET ierrcode = 0
  UPDATE  FROM eprescribe_detail e,
    (dummyt d  WITH seq = value(req_cnt))
   SET e.status_cd = request->prsnl_reltns[d.seq].status_code_value, e.error_cd = request->
    prsnl_reltns[d.seq].error_code_value, e.error_desc = substring(1,100,request->prsnl_reltns[d.seq]
     .error_desc),
    e.updt_id = reqinfo->updt_id, e.updt_cnt = (e.updt_cnt+ 1), e.updt_applctx = reqinfo->
    updt_applctx,
    e.updt_task = reqinfo->updt_task, e.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (e
    WHERE (e.message_ident=request->prsnl_reltns[d.seq].message_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Update eprescribe_detail rows."
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
