CREATE PROGRAM dm_get_columns_info:dba
 RECORD reply(
   1 qual[*]
     2 column_name = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET index = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  utc.column_name
  FROM user_tab_columns utc
  WHERE (table_name=request->table_name)
  ORDER BY utc.column_name
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].column_name = utc
   .column_name
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
