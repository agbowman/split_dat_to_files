CREATE PROGRAM bed_ens_meanful_use_enc_info:dba
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
 SET ecnt = size(request->encounter_types,5)
 IF (ecnt > 0)
  DELETE  FROM br_name_value b,
    (dummyt d  WITH seq = value(ecnt))
   SET b.seq = 1
   PLAN (d
    WHERE (request->encounter_types[d.seq].action_flag=3))
    JOIN (b
    WHERE b.br_nv_key1="MEANFULUSEENCTYPE"
     AND b.br_value=cnvtstring(request->encounter_types[d.seq].code_value))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error deleting encounter type from br_name_value table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM br_name_value b,
    (dummyt d  WITH seq = ecnt)
   SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "MEANFULUSEENCTYPE", b.br_value
     = cnvtstring(request->encounter_types[d.seq].code_value),
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (request->encounter_types[d.seq].action_flag=1))
    JOIN (b)
   WITH nocounter
  ;end insert
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error inserting encounter type into br_name_value table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ecnt = size(request->encounter_relations,5)
 IF (ecnt > 0)
  DELETE  FROM br_name_value b,
    (dummyt d  WITH seq = value(ecnt))
   SET b.seq = 1
   PLAN (d
    WHERE (request->encounter_relations[d.seq].action_flag=3))
    JOIN (b
    WHERE b.br_nv_key1="MEANFULUSEENCRELTN"
     AND b.br_value=cnvtstring(request->encounter_relations[d.seq].code_value))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error deleting encounter relation from br_name_value table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM br_name_value b,
    (dummyt d  WITH seq = ecnt)
   SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "MEANFULUSEENCRELTN", b.br_value
     = cnvtstring(request->encounter_relations[d.seq].code_value),
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (request->encounter_relations[d.seq].action_flag=1))
    JOIN (b)
   WITH nocounter
  ;end insert
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error inserting encounter relation into br_name_value table"
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
