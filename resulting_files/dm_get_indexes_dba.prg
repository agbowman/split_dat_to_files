CREATE PROGRAM dm_get_indexes:dba
 RECORD reply(
   1 qual[*]
     2 index_name = c100
     2 column_name = c100
     2 uniqueness = c100
     2 column_position = i4
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
  duic.index_name, duic.column_name, duic.uniqueness,
  duic.column_position
  FROM dm_user_ind_columns duic
  WHERE (duic.table_name=request->table_name)
  ORDER BY duic.index_name, duic.column_position
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].index_name = duic
   .index_name,
   reply->qual[index].column_name = duic.column_name, reply->qual[index].uniqueness = duic.uniqueness,
   reply->qual[index].column_position = duic.column_position
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
