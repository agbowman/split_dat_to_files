CREATE PROGRAM dm_get_parent_tables:dba
 RECORD reply(
   1 qual[*]
     2 parent_table_name = c100
     2 description = c500
     2 definition = c500
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
  ducc.parent_table_name, dtd2.description, dtd2.definition,
  dtd2.data_model_section
  FROM dm_user_cons_columns ducc,
   dm_tables_doc dtd2
  WHERE (ducc.table_name=request->table_name)
   AND ducc.constraint_type="R"
   AND dtd2.table_name=ducc.parent_table_name
  ORDER BY ducc.parent_table_name
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].parent_table_name =
   ducc.parent_table_name,
   reply->qual[index].data_model_section = dtd2.data_model_section, reply->qual[index].description =
   dtd2.description, reply->qual[index].definition = dtd2.definition
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
