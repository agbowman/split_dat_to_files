CREATE PROGRAM dm_get_patient_type:dba
 RECORD reply(
   1 qual[*]
     2 display_key = vc
     2 active_ind = i2
     2 code_value = f8
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
  cv.display_key, cv.active_ind, cv.code_value
  FROM code_value cv
  WHERE cv.code_set=71
  ORDER BY cv.display_key
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].display_key = cv
   .display_key,
   reply->qual[index].active_ind = cv.active_ind, reply->qual[index].code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (index > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
