CREATE PROGRAM cps_get_person_name:dba
 RECORD reply(
   1 person_qual = i4
   1 person[0]
     2 person_id = f8
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET kcount = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.person_id, p.name_full_formatted
  FROM person p,
   (dummyt d  WITH seq = value(request->person_qual))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=request->person[d.seq].person_id))
  DETAIL
   kcount = (kcount+ 1)
   IF (mod(kcount,10)=1)
    stat = alter(reply->person,(kcount+ 10))
   ENDIF
   reply->person[kcount].person_id = p.person_id, reply->person[kcount].name_full_formatted = p
   .name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alter(reply->person,kcount)
 IF (curqual=1)
  SET reply->status_data.status = "S"
  SET reply->person_qual = kcount
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
