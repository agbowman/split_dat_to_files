CREATE PROGRAM cps_get_related_person:dba
 RECORD reply(
   1 person_qual = i4
   1 person[0]
     2 person_id = f8
     2 name_full_formatted = vc
     2 person_reltn_type_cd = f8
     2 person_reltn_type_disp = c40
     2 person_reltn_type_desc = c60
     2 person_reltn_type_mean = c12
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
  c.code_value, c.cdf_meaning, c.display,
  c.description, p.name_full_formatted, p.person_id
  FROM person p,
   code_value c,
   person_person_reltn r,
   (dummyt d1  WITH seq = value(request->person_person_reltn_qual))
  PLAN (d1)
   JOIN (r
   WHERE (r.person_id=request->person_person_reltn[d1.seq].person_id))
   JOIN (p
   WHERE p.person_id=r.person_id)
   JOIN (c
   WHERE (c.cdf_meaning=request->person_person_reltn[d1.seq].person_reltn_type_mean)
    AND c.code_value=r.person_reltn_type_cd)
  DETAIL
   kcount = (kcount+ 1)
   IF (mod(kcount,10)=1)
    stat = alter(reply->person,(kcount+ 10))
   ENDIF
   reply->person[kcount].person_id = r.person_id, reply->person[kcount].person_reltn_type_cd = r
   .person_reltn_type_cd, reply->person[kcount].name_full_formatted = p.name_full_formatted
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
