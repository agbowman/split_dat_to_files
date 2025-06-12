CREATE PROGRAM dm_ins_upd_code_alias:dba
 RECORD reply(
   1 qual[*]
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET x = 0
 SET reply->status_data.status = "F"
 SET qual_size = size(request->qual,5)
 SET cur_updt_cnt = 0
 SET new_code_value = 0.00
 SET stat = alterlist(reply->qual,qual_size)
 SET cva_atm = fillstring(12," ")
#startloop
 FOR (x = 1 TO qual_size)
   SELECT INTO "nl:"
    cva.updt_cnt
    FROM code_value_alias cva
    WHERE (cva.code_value=request->qual[x].old_code_value)
     AND (cva.code_set=request->code_set)
     AND (cva.alias=request->qual[x].old_alias)
     AND (cva.contributor_source_cd=request->qual[x].old_contributor_source_cd)
    DETAIL
     cur_updt_cnt = cva.updt_cnt
    WITH nocounter, forupdate(cva)
   ;end select
   IF (curqual > 0)
    IF ((cur_updt_cnt != request->qual[x].updt_cnt))
     SET reply->qual[x].status = "A"
    ELSE
     UPDATE  FROM code_value_alias cva
      SET cva.code_value = request->qual[x].code_value, cva.alias = request->qual[x].alias, cva
       .alias_type_meaning = request->qual[x].alias_type_meaning,
       cva.contributor_source_cd = request->qual[x].contributor_source_cd, cva.updt_cnt = (cva
       .updt_cnt+ 1), cva.updt_task = reqinfo->updt_task,
       cva.updt_id = reqinfo->updt_id, cva.updt_applctx = reqinfo->updt_applctx, cva.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WHERE (cva.code_value=request->qual[x].old_code_value)
       AND (cva.code_set=request->code_set)
       AND (cva.alias=request->qual[x].old_alias)
       AND (cva.contributor_source_cd=request->qual[x].old_contributor_source_cd)
      WITH nocounter
     ;end update
     IF (curqual > 0)
      SET reply->qual[x].status = "S"
     ELSE
      SET reply->qual[x].status = "U"
     ENDIF
    ENDIF
   ELSE
    INSERT  FROM code_value_alias cva
     SET cva.code_value = request->qual[x].code_value, cva.code_set = request->code_set, cva.alias =
      request->qual[x].alias,
      cva.alias_type_meaning = request->qual[x].alias_type_meaning, cva.contributor_source_cd =
      request->qual[x].contributor_source_cd, cva.updt_cnt = 0,
      cva.updt_task = reqinfo->updt_task, cva.updt_id = reqinfo->updt_id, cva.updt_applctx = reqinfo
      ->updt_applctx,
      cva.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual > 0)
    SET reply->qual[x].status = "S"
   ELSE
    SET reply->qual[x].status = "I"
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
END GO
