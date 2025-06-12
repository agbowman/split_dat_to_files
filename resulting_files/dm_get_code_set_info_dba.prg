CREATE PROGRAM dm_get_code_set_info:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
     2 cdf_meaning = c100
     2 cki = c100
     2 description = c100
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
 SELECT DISTINCT INTO "nl:"
  cv.code_value, cv.display, cv.cdf_meaning,
  cv.description, cki
  FROM code_value cv
  WHERE (cv.code_set=request->code_set)
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY cv.display
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].code_value = cv
   .code_value,
   reply->qual[index].display = cv.display, reply->qual[index].cdf_meaning = cv.cdf_meaning, reply->
   qual[index].cki = cv.cki,
   reply->qual[index].description = cv.description
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
