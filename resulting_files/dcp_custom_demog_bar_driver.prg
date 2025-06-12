CREATE PROGRAM dcp_custom_demog_bar_driver
 RECORD reply(
   1 custom_field[*]
     2 custom_field_index = i4
     2 custom_field_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE value(cnvtupper(trim(request->script_name)))
 SET script_version = "03/14/08 MS5566"
END GO
