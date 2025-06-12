CREATE PROGRAM cps_get_prsnl_name:dba
 RECORD reply(
   1 person_qual = i4
   1 person[*]
     2 person_id = f8
     2 active_ind = i2
     2 name_full_formatted = vc
     2 physician_ind = i2
     2 prsnl_type_cd = f8
     2 prsnl_type_disp = vc
     2 prsnl_type_mean = vc
     2 position_cd = f8
     2 position_disp = vc
     2 position_mean = vc
     2 name_last = vc
     2 name_first = vc
     2 username = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->person,10)
 SET reply->person_qual = 0
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "NL:"
  p.person_id
  FROM prsnl p,
   (dummyt d  WITH seq = value(size(request->person,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (p
   WHERE (request->person[d.seq].person_id=p.person_id))
  DETAIL
   count1 = (count1+ 1)
   IF (size(reply->person,5) <= count1)
    stat = alterlist(reply->person,(count1+ 10))
   ENDIF
   reply->person[count1].person_id = p.person_id, reply->person[count1].active_ind = p.active_ind,
   reply->person[count1].name_full_formatted = p.name_full_formatted,
   reply->person[count1].physician_ind = p.physician_ind, reply->person[count1].prsnl_type_cd = p
   .prsnl_type_cd, reply->person[count1].position_cd = p.position_cd,
   reply->person[count1].name_last = p.name_last, reply->person[count1].name_first = p.name_first,
   reply->person[count1].username = p.username
  FOOT REPORT
   stat = alterlist(reply->person,count1), reply->person_qual = count1
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "001 01/31/01 SF3151"
END GO
