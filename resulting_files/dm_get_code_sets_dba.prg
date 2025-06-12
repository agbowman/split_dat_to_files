CREATE PROGRAM dm_get_code_sets:dba
 RECORD reply(
   1 list[*]
     2 code_set = f8
     2 display = c40
     2 description = c60
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
  cvs.code_set, cvs.display
  FROM code_value_set cvs,
   dm_code_set_local dcs
  WHERE dcs.code_set=cvs.code_set
   AND dcs.crmimpexp_ind=1
  DETAIL
   index = (index+ 1), stat = alterlist(reply->list,index), reply->list[index].code_set = cvs
   .code_set,
   reply->list[index].display = cvs.display
  WITH nocounter
 ;end select
 IF (index > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
