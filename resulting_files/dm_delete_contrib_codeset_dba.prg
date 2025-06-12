CREATE PROGRAM dm_delete_contrib_codeset:dba
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
 DELETE  FROM code_value_alias cva
  WHERE (cva.code_set=request->code_set)
   AND (cva.contributor_source_cd=request->contributor_source_cd)
 ;end delete
 SET reply->status_data.status = "S"
 COMMIT
END GO
