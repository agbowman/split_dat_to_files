CREATE PROGRAM dcp_get_decode_info:dba
 RECORD reply(
   1 code_value_cd = f8
   1 code_value_disp = c40
   1 code_value_desc = c60
   1 code_value_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->code_value_cd = request->code_value
 CALL echo(build("code value:",reply->code_value_cd))
END GO
