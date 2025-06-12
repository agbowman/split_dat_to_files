CREATE PROGRAM bed_ens_cki_client:dba
 FREE SET reply
 RECORD reply(
   1 client_id = f8
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
  SET client_id = 0.0
  SELECT INTO "nl:"
   y = seq(bedrock_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    client_id = cnvtreal(y)
   WITH format, counter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM br_cki_client bcc
   SET bcc.client_id = client_id, bcc.client_name = request->client_name, bcc.client_mnemonic =
    request->client_mnemonic,
    bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(curdate,curtime), bcc.updt_id = reqinfo->updt_id,
    bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  SET reply->client_id = client_id
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=2))
  SET ierrcode = 0
  UPDATE  FROM br_cki_client bcc
   SET bcc.client_name = request->client_name, bcc.client_mnemonic = request->client_mnemonic, bcc
    .updt_cnt = (bcc.updt_cnt+ 1),
    bcc.updt_dt_tm = cnvtdatetime(curdate,curtime), bcc.updt_id = reqinfo->updt_id, bcc.updt_task =
    reqinfo->updt_task,
    bcc.updt_applctx = reqinfo->updt_applctx
   PLAN (bcc
    WHERE (bcc.client_id=request->client_id))
   WITH nocounter
  ;end update
  SET reply->client_id = request->client_id
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=3))
  DELETE  FROM br_cki_client bcc
   WHERE (bcc.client_id=request->client_id)
   WITH nocounter
  ;end delete
  SET reply->client_id = request->client_id
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
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
