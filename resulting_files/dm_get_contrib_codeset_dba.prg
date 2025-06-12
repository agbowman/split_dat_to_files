CREATE PROGRAM dm_get_contrib_codeset:dba
 RECORD reply(
   1 qual[*]
     2 code_set = f8
     2 contributor_source_cd = f8
     2 contributor_source_display = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET index = 0
 SELECT DISTINCT INTO "nl:"
  cva.code_set, cva.contributor_source_cd, cva.contributor_source_display
  FROM code_value_alias cva
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].code_set = cva
   .code_set,
   reply->qual[index].contributor_source_cd = cva.contributor_source_cd, reply->qual[index].
   contributor_source_display = cva.contributor_source_display
  WITH nocounter
 ;end select
 IF (index > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
