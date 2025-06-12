CREATE PROGRAM bed_get_fn_rooms_by_edarea:dba
 FREE SET reply
 RECORD reply(
   1 rooms[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_name_value b,
   code_value c
  PLAN (b
   WHERE b.br_nv_key1="EDAREAROOMRELTN"
    AND cnvtreal(b.br_name)=area_id)
   JOIN (c
   WHERE c.code_value=cnvtreal(b.br_value)
    AND c.active_ind=1)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->rooms,cnt), reply->rooms[cnt].code_value = c.code_value,
   reply->rooms[cnt].display = c.display
  WITH nocounter
 ;end select
#exit_script
 IF (size(reply->rooms,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
