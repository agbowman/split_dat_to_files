CREATE PROGRAM dm_get_child_tables:dba
 RECORD reply(
   1 qual[*]
     2 child_table_name = c100
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
  ducc.table_name
  FROM dm_user_cons_columns ducc
  WHERE (parent_table_name=request->table_name)
   AND constraint_type="R"
  ORDER BY ducc.table_name
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].child_table_name =
   ducc.table_name
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
