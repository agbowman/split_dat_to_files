CREATE PROGRAM dm_imp_code_alias:dba
 RECORD reply(
   1 check = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 INSERT  FROM code_value_alias cva
  SET cva.code_set = request->code_set, cva.contributor_source_cd = request->contributor_source_cd,
   cva.alias = request->alias,
   cva.code_value = request->code_value, cva.primary_ind = 0, cva.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task, cva.updt_cnt = 0,
   cva.updt_applctx = reqinfo->updt_applctx, cva.alias_type_meaning = ""
  WITH nocounter
 ;end insert
 IF (curqual=1)
  SET reply->status_data.status = "S"
  SET reply->check = 0
 ELSE
  SET reply->check = 1
 ENDIF
 COMMIT
END GO
