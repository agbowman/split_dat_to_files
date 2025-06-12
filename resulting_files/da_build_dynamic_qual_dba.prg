CREATE PROGRAM da_build_dynamic_qual:dba
 RECORD reply(
   1 qual_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 CALL parser(concat(trim(request->val1,3)," go"))
 IF ((reply->qual_text != ""))
  SET reply->status_data.status = "S"
 ENDIF
END GO
