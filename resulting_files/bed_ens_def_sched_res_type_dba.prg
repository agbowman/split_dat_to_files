CREATE PROGRAM bed_ens_def_sched_res_type:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET rcnt = size(request->resources,5)
 IF (rcnt > 0)
  INSERT  FROM br_name_value b,
    (dummyt d  WITH seq = value(rcnt))
   SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "SCHRESGROUPRES", b.br_name =
    cnvtstring(request->resources[d.seq].code_value),
    b.br_value = cnvtstring(request->resources[d.seq].type_id), b.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), b.updt_id = reqinfo->updt_id,
    b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
   PLAN (d
    WHERE (request->resources[d.seq].action_flag=1))
    JOIN (b)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error inserting into br_name_value table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  UPDATE  FROM br_name_value b,
    (dummyt d  WITH seq = value(rcnt))
   SET b.br_value = cnvtstring(request->resources[d.seq].type_id), b.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), b.updt_id = reqinfo->updt_id,
    b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
    .updt_cnt+ 1)
   PLAN (d
    WHERE (request->resources[d.seq].action_flag=2))
    JOIN (b
    WHERE b.br_nv_key1="SCHRESGROUPRES"
     AND b.br_name=cnvtstring(request->resources[d.seq].code_value))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error updating into br_name_value table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM br_name_value b,
    (dummyt d  WITH seq = value(rcnt))
   SET b.seq = 1
   PLAN (d
    WHERE (request->resources[d.seq].action_flag=3))
    JOIN (b
    WHERE b.br_name=cnvtstring(request->resources[d.seq].code_value))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error deleting from br_name_value table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
