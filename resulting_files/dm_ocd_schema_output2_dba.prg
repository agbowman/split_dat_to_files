CREATE PROGRAM dm_ocd_schema_output2:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET afd_nbr = request->ocd_number
 EXECUTE dm_ocd_output_file2
 SET reply->status_data.status = "S"
END GO
