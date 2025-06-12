CREATE PROGRAM bed_ens_onc_token_element:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = 0
 SET req_cnt = size(request->reltns,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM onc_token_element_r o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.onc_token_element_r_id = seq(tracking_seq,nextval), o.staging_token_cd = request->reltns[d
   .seq].staging_token_code_value, o.doc_set_ref_id = request->reltns[d.seq].doc_set_ref_id,
   o.doc_set_element_id = request->reltns[d.seq].doc_set_element_id, o.updt_applctx = reqinfo->
   updt_applctx, o.updt_cnt = 0,
   o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo
   ->updt_task
  PLAN (d
   WHERE (request->reltns[d.seq].action_flag=1))
   JOIN (o)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on insert onc_token_element_r")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM onc_token_element_r o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.staging_token_cd = request->reltns[d.seq].staging_token_code_value, o.doc_set_ref_id =
   request->reltns[d.seq].doc_set_ref_id, o.doc_set_element_id = request->reltns[d.seq].
   doc_set_element_id,
   o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (request->reltns[d.seq].action_flag=2))
   JOIN (o
   WHERE (o.onc_token_element_r_id=request->reltns[d.seq].onc_token_element_r_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on update onc_token_element_r")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM onc_token_element_r o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.seq = 1
  PLAN (d
   WHERE (request->reltns[d.seq].action_flag=3))
   JOIN (o
   WHERE (o.onc_token_element_r_id=request->reltns[d.seq].onc_token_element_r_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on delete onc_token_element_r")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
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
