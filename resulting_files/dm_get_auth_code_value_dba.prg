CREATE PROGRAM dm_get_auth_code_value:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c100
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
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND (c.data_status_cd=request->auth_cd)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY c.display
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].code_value = c
   .code_value,
   reply->qual[index].display = c.display, reply->qual[index].description = c.description
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 COMMIT
END GO
