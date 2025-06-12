CREATE PROGRAM codecache_excludeset:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 UPDATE  FROM code_value_set cs
  SET cs.cache_ind = request->cache_ind
  WHERE (cs.code_set=request->code_set)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
