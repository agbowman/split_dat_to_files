CREATE PROGRAM dm_load_contribt_sour_cd:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c100
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
  cv.code_value, cv.display
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.active_ind=1
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].code_value = cv
   .code_value,
   reply->qual[index].display = cv.display
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
