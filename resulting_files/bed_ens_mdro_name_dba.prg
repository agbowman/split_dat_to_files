CREATE PROGRAM bed_ens_mdro_name:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 mdro_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET serrmsg = fillstring(132," ")
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE mdro_id = f8
 SELECT INTO "nl:"
  j = seq(bedrock_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   mdro_id = cnvtreal(j)
  WITH format, counter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Error selecting new id for mdro name"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 INSERT  FROM br_mdro mn
  SET mn.br_mdro_id = mdro_id, mn.mdro_name = request->mdro_name, mn.mdro_name_key = cnvtupper(
    cnvtalphanum(request->mdro_name)),
   mn.updt_applctx = reqinfo->updt_applctx, mn.updt_cnt = 0, mn.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   mn.updt_id = reqinfo->updt_id, mn.updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Error inserting new mdro name"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET reply->mdro_id = mdro_id
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
