CREATE PROGRAM bed_get_ordsent_facilities:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 code_value = f8
     2 display = vc
   1 all_facility_ind = i2
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
  FROM ocs_facility_r o,
   code_value c
  PLAN (o
   WHERE (o.synonym_id=request->synonym_id))
   JOIN (c
   WHERE c.code_value=o.facility_cd)
  ORDER BY c.display
  DETAIL
   IF (o.facility_cd=0)
    reply->all_facility_ind = 1
   ELSE
    cnt = (cnt+ 1), stat = alterlist(reply->facilities,cnt), reply->facilities[cnt].code_value = o
    .facility_cd,
    reply->facilities[cnt].display = c.display
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
END GO
