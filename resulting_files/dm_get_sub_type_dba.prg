CREATE PROGRAM dm_get_sub_type:dba
 RECORD reply(
   1 qual[*]
     2 sub_type_code = f8
     2 sub_type_display = c100
     2 sub_type_description = vc
     2 sub_type_meaning = c100
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
  FROM code_value cv,
   code_value_group cvg
  PLAN (cvg
   WHERE (cvg.parent_code_value=request->code_value))
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value)
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].sub_type_code = cv
   .code_value,
   reply->qual[index].sub_type_display = cv.display, reply->qual[index].sub_type_description = cv
   .description, reply->qual[index].sub_type_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
