CREATE PROGRAM dm_get_code_set:dba
 RECORD reply(
   1 qual[*]
     2 code_set = f8
     2 display = c100
     2 description = c100
     2 no_combine_ind = f8
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
  cvs.display, cvs.description, dcs.no_combine_ind
  FROM code_value_set cvs,
   dm_code_set_local dcs
  WHERE cvs.code_set > 0
   AND  NOT (cvs.code_set IN (72, 220))
   AND cvs.code_set=dcs.code_set
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].code_set = cvs
   .code_set,
   reply->qual[index].display = cvs.display, reply->qual[index].description = cvs.description, reply
   ->qual[index].no_combine_ind = dcs.no_combine_ind
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
