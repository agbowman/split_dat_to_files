CREATE PROGRAM bed_ens_cki_client_info:dba
 FREE SET reply
 RECORD reply(
   1 br_cki_client_info_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 IF ((request->action_flag=1))
  SET ierrcode = 0
  SET br_cki_client_info_id = 0.0
  SELECT INTO "nl:"
   y = seq(bedrock_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    br_cki_client_info_id = cnvtreal(y)
   WITH format, counter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM br_cki_client_info bcci
   SET bcci.br_cki_client_info_id = br_cki_client_info_id, bcci.client_id = request->client_id, bcci
    .data_type_id = request->data_type_id,
    bcci.lock_ind = request->lock_ind, bcci.export_ind = request->export_ind, bcci.load_dt_tm =
    cnvtdatetime(curdate,curtime),
    bcci.updt_cnt = 0, bcci.updt_dt_tm = cnvtdatetime(curdate,curtime), bcci.updt_id = reqinfo->
    updt_id,
    bcci.updt_task = reqinfo->updt_task, bcci.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  SET reply->br_cki_client_info_id = br_cki_client_info_id
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=2))
  SET ierrcode = 0
  UPDATE  FROM br_cki_client_info bcci
   SET bcci.lock_ind = request->lock_ind, bcci.export_ind = request->export_ind, bcci.updt_cnt = (
    bcci.updt_cnt+ 1),
    bcci.updt_dt_tm = cnvtdatetime(curdate,curtime), bcci.updt_id = reqinfo->updt_id, bcci.updt_task
     = reqinfo->updt_task,
    bcci.updt_applctx = reqinfo->updt_applctx
   PLAN (bcci
    WHERE (bcci.client_id=request->client_id)
     AND (bcci.data_type_id=request->data_type_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM br_cki_client_info bcci
   PLAN (bcci
    WHERE (bcci.client_id=request->client_id)
     AND (bcci.data_type_id=request->data_type_id))
   DETAIL
    reply->br_cki_client_info_id = bcci.br_cki_client_info_id
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
