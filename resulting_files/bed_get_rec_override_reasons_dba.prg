CREATE PROGRAM bed_get_rec_override_reasons:dba
 FREE SET reply
 RECORD reply(
   1 reasons[*]
     2 id = f8
     2 meaning = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="DIAGNOSTICOVREASON"
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->reasons,rcnt), reply->reasons[rcnt].id = b
   .br_name_value_id,
   reply->reasons[rcnt].meaning = b.br_name, reply->reasons[rcnt].description = b.br_value
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
