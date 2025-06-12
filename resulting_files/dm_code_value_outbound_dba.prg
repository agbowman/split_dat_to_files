CREATE PROGRAM dm_code_value_outbound:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "f"
 UPDATE  FROM code_value_outbound cvo
  SET cvo.updt_dt_tm = cnvtdatetime(sysdate), cvo.updt_id = reqinfo->updt_id, cvo.updt_task = reqinfo
   ->updt_task,
   cvo.updt_cnt = (cvo.updt_cnt+ 1), cvo.updt_applctx = reqinfo->updt_applctx, cvo.alias = request->
   alias,
   cvo.code_set = request->code_set, cvo.contributor_source_cd = request->contributor_source_cd, cvo
   .alias_type_meaning = request->alias_type_meaning
  WHERE (cvo.code_value=request->code_value)
   AND (cvo.contributor_source_cd=request->contributor_source_cd)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM code_value_outbound cvo
   SET cvo.code_value = request->code_value, cvo.updt_dt_tm = cnvtdatetime(sysdate), cvo.updt_id =
    reqinfo->updt_id,
    cvo.updt_task = reqinfo->updt_task, cvo.updt_cnt = 0, cvo.updt_applctx = reqinfo->updt_applctx,
    cvo.alias = request->alias, cvo.code_set = request->code_set, cvo.contributor_source_cd = request
    ->contributor_source_cd,
    cvo.alias_type_meaning = request->alias_type_meaning
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
