CREATE PROGRAM dm_get_column_attributes:dba
 RECORD reply(
   1 qual[*]
     2 column_name = c30
     2 table_name = c100
     2 code_set = f8
     2 data_type = c30
     2 description = c400
     2 definition = c500
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
 SELECT DISTINCT INTO "nl:"
  dcd.column_name, dcd.table_name, dcd.code_set,
  dcd.description, dcd.definition, utc.data_type
  FROM dm_columns_doc dcd,
   dm_user_tab_cols utc
  WHERE (dcd.table_name=request->table_name)
   AND dcd.column_name=utc.column_name
   AND dcd.table_name=utc.table_name
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].column_name = dcd
   .column_name,
   reply->qual[index].table_name = dcd.table_name, reply->qual[index].data_type = utc.data_type,
   reply->qual[index].code_set = dcd.code_set,
   reply->qual[index].description = dcd.description, reply->qual[index].definition = dcd.definition
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
