CREATE PROGRAM dm_get_search_table_names:dba
 RECORD reply(
   1 qual[*]
     2 table_name = c100
     2 description = c400
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
 SELECT DISTINCT
  dtd.table_name, dtd.description
  FROM dm_tables_doc dtd,
   dm_user_tab_cols ut
  WHERE (dtd.data_model_section=request->data_model_section)
   AND dtd.table_name=ut.table_name
   AND dtd.table_name=patstring(request->search_string)
  ORDER BY dtd.table_name
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].table_name = dtd
   .table_name,
   reply->qual[index].description = dtd.description
  WITH nocounter
 ;end select
 CALL echo(build("*** Curqual=",curqual))
 SET reply->status_data.status = "S"
 COMMIT
END GO
