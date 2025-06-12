CREATE PROGRAM dm_get_model_child_tables:dba
 RECORD reply(
   1 check = i4
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
  dd.table_name
  FROM dm_tables_doc d,
   dm_tables_doc d1,
   dm_user_cons_columns dd
  PLAN (dd
   WHERE (dd.parent_table_name=request->table_name)
    AND dd.constraint_type="R")
   JOIN (d
   WHERE d.table_name=dd.table_name)
   JOIN (d1
   WHERE (d1.data_model_section=request->data_model_section)
    AND d1.data_model_section=d.data_model_section)
  ORDER BY dd.table_name
  DETAIL
   IF (dd.table_name="")
    reply->check = 0
   ELSE
    reply->check = 1
   ENDIF
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].child_table_name = dd
   .table_name
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
