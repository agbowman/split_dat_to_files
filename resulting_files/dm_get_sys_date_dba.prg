CREATE PROGRAM dm_get_sys_date:dba
 RECORD reply(
   1 schema_date1 = vc
   1 schema_date2 = vc
   1 schema_date3 = vc
   1 schema_date4 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET schema_date = cnvtdatetime(curdate,curtime3)
 SET reply->schema_date1 = format(schema_date,"dd-mmm-yyyy hh:mm;;D")
 SET reply->schema_date2 = format(schema_date,"mm/dd/yy hh:mm;;D")
 SET reply->schema_date3 = format(schema_date,"yyyymmddhhmmss;;D")
 SET reply->schema_date4 = format(schema_date,"dd-mmm-yyyy hh:mm:ss;;D")
 SET reply->status_data.status = "S"
END GO
