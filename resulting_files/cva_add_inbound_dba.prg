CREATE PROGRAM cva_add_inbound:dba
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
 SET number_total = size(request->qual,5)
 SET failed = "F"
 INSERT  FROM code_value_alias a,
   (dummyt d  WITH seq = value(number_total))
  SET a.code_set = request->qual[d.seq].code_set, a.contributor_source_cd = request->qual[d.seq].
   contributor_source_cd, a.alias = request->qual[d.seq].alias,
   a.code_value = request->qual[d.seq].code_value, a.alias_type_meaning = request->qual[d.seq].
   alias_type_meaning, a.updt_dt_tm = cnvtdatetime(sysdate),
   a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
   updt_applctx,
   a.updt_cnt = 0
  PLAN (d)
   JOIN (a)
  WITH nocounter
 ;end insert
 IF (curqual <= 0
  AND number_total > 0)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="F")
  COMMIT
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
