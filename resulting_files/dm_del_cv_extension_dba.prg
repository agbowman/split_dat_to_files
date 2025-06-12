CREATE PROGRAM dm_del_cv_extension:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET failures = 0
 SET number_to_del = size(request->qual,5)
 DELETE  FROM code_value_extension c,
   (dummyt d  WITH seq = value(number_to_del))
  SET c.seq = 1
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->code_set)
    AND (c.field_name=request->qual[d.seq].field_name)
    AND (c.code_value=request->qual[d.seq].code_value))
  WITH nocounter
 ;end delete
 COMMIT
 SET reply->status_data.status = "S"
END GO
