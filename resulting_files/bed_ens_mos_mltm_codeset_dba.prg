CREATE PROGRAM bed_ens_mos_mltm_codeset:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_size = size(request->values,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_med_ordsent_map b,
   (dummyt d  WITH seq = value(req_size))
  SET b.br_med_ordsent_map_id = seq(bedrock_seq,nextval), b.codeset = request->values[d.seq].codeset,
   b.field_value = cnvtupper(request->values[d.seq].mltm_display),
   b.parent_entity_name = "CODE_VALUE", b.parent_entity_id = request->values[d.seq].mill_code, b
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->values[d.seq].action_flag=1))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT STATEMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM br_med_ordsent_map b,
   (dummyt d  WITH seq = value(req_size))
  SET b.parent_entity_name = "CODE_VALUE", b.parent_entity_id = request->values[d.seq].mill_code, b
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->values[d.seq].action_flag=2))
   JOIN (b
   WHERE (b.codeset=request->values[d.seq].codeset)
    AND b.field_value=cnvtupper(request->values[d.seq].mltm_display))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE STATEMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM br_med_ordsent_map b,
   (dummyt d  WITH seq = value(req_size))
  SET b.seq = 1
  PLAN (d
   WHERE (request->values[d.seq].action_flag=3))
   JOIN (b
   WHERE (b.codeset=request->values[d.seq].codeset)
    AND b.field_value=cnvtupper(request->values[d.seq].mltm_display))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DELETE STATEMENT"
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
