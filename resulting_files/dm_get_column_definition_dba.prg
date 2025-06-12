CREATE PROGRAM dm_get_column_definition:dba
 RECORD reply(
   1 qual[*]
     2 description = c100
     2 definition = c176
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
  t.description, t.definition
  FROM dm_tables_doc t,
   dm_columns_doc f,
   user_tables ut,
   user_tab_columns uc
  PLAN (ut
   WHERE (ut.table_name=request->table_name))
   JOIN (uc
   WHERE ut.table_name=uc.table_name)
   JOIN (t
   WHERE ut.table_name=t.table_name)
   JOIN (f
   WHERE ut.column_name=f.column_name
    AND uc.table_name=f.table_name)
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].description = t
   .description,
   reply->qual[index].definition = t.definition
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
