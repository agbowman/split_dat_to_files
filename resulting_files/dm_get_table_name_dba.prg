CREATE PROGRAM dm_get_table_name:dba
 RECORD reply(
   1 qual[*]
     2 table_name = c100
     2 description = c400
     2 definition = c400
     2 data_model_section = c100
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
  dtd.table_name, dtd.description, dtd.data_model_section,
  dtd.definition
  FROM dm_tables_doc dtd,
   dm_user_tab_cols ut
  WHERE dtd.table_name=ut.table_name
   AND (dtd.table_name=request->table_name)
  ORDER BY dtd.table_name
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].table_name = dtd
   .table_name,
   reply->qual[index].description = dtd.description, reply->qual[index].data_model_section = dtd
   .data_model_section, reply->qual[index].definition = dtd.definition
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
