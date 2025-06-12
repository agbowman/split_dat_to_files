CREATE PROGRAM dm_get_data_model:dba
 RECORD reply(
   1 qual[*]
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
 SELECT INTO "nl:"
  dms.data_model_section
  FROM dm_data_model_section dms
  ORDER BY dms.data_model_section
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].data_model_section =
   dms.data_model_section
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
