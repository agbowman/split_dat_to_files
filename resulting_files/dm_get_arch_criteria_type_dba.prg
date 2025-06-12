CREATE PROGRAM dm_get_arch_criteria_type:dba
 RECORD reply(
   1 qual[*]
     2 criteria_type_cd = f8
     2 criteria_type = c100
     2 column_number = vc
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
 SET count = 0
 SELECT INTO "nl:"
  cve.field_value, cve.code_value, cv.display
  FROM code_value cv,
   code_value_extension cve
  WHERE cv.code_set=18249
   AND cv.active_ind=1
   AND cv.code_value=cve.code_value
   AND cv.cdf_meaning="A*"
   AND cve.field_name="COLUMN_NUMBER"
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].criteria_type = cv
   .display,
   reply->qual[index].criteria_type_cd = cve.code_value, reply->qual[index].column_number = cve
   .field_value
  WITH nocounter
 ;end select
 IF (index > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
