CREATE PROGRAM dm_get_allcolumn_attributes:dba
 RECORD reply(
   1 qual[*]
     2 table_name = c100
     2 sequence_name = c100
     2 code_set = f8
     2 description = c100
     2 definition = c100
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
  dcd.table_name, dcd.sequence_name, dcd.code_set,
  dcd.description, dcd.definition, dcd.column_name
  FROM dm_columns_doc dcd
  WHERE (dcd.table_name=request->table_name)
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].table_name = dcd
   .table_name,
   reply->qual[index].sequence_name = dcd.sequence_name, reply->qual[index].code_set = dcd.code_set,
   reply->qual[index].description = dcd.description,
   reply->qual[index].definition = dcd.definition, reply->qual[index].column_name = dcd.column_name
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
