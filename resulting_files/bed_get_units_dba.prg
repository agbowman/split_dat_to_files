CREATE PROGRAM bed_get_units:dba
 FREE SET reply
 RECORD reply(
   1 units[*]
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
 SET field_value = 0
 SET cnt = 0
 SELECT INTO "nl:"
  FROM code_value c,
   code_value_extension e
  PLAN (c
   WHERE c.code_set=54
    AND c.active_ind=1)
   JOIN (e
   WHERE e.code_value=c.code_value
    AND e.field_name="PHARM_UNIT"
    AND e.code_set=54)
  ORDER BY c.display
  DETAIL
   field_value = cnvtint(e.field_value)
   IF (band(field_value,request->unit_type_flag) > 0)
    cnt = (cnt+ 1), stat = alterlist(reply->units,cnt), reply->units[cnt].code_value = c.code_value,
    reply->units[cnt].display = c.display
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
END GO
