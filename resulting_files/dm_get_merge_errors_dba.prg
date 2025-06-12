CREATE PROGRAM dm_get_merge_errors:dba
 RECORD reply(
   1 qual[*]
     2 error_number = i4
     2 table_name = vc
     2 error_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  a.error_num, a.error_msg, a.table_name
  FROM dm_merge_error a
  WHERE (a.merge_id=request->merge_id)
  ORDER BY a.error_seq
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].error_number = a.error_num,
   reply->qual[cnt].error_message = a.error_msg, reply->qual[cnt].table_name = a.table_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
