CREATE PROGRAM dm_get_table_attributes:dba
 RECORD reply(
   1 qual[*]
     2 data_model_section = c100
     2 description = c130
     2 definition = c300
     2 reference_ind = i4
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
  dtd.data_model_section, dtd.description, dtd.definition,
  dtd.reference_ind
  FROM dm_tables_doc dtd
  WHERE (table_name=request->table_name)
  ORDER BY dtd.description
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].data_model_section =
   dtd.data_model_section,
   reply->qual[index].description = dtd.description, reply->qual[index].definition = dtd.definition,
   reply->qual[index].reference_ind = dtd.reference_ind
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
