CREATE PROGRAM cps_get_person_by_alias:dba
 RECORD reply(
   1 person_qual = i4
   1 person[*]
     2 person_id = f8
     2 name_last = c100
     2 name_middle = c100
     2 name_first = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET alias_type_cd_value = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=320
   AND (c.cdf_meaning=request->prsnl_alias_type_cdf)
  DETAIL
   alias_type_cd_value = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM prsnl_alias pa,
   person p
  PLAN (pa
   WHERE (pa.alias=request->alias)
    AND pa.prsnl_alias_type_cd=alias_type_cd_value
    AND pa.active_ind=1)
   JOIN (p
   WHERE pa.person_id=p.person_id)
  DETAIL
   count += 1, stat = alterlist(reply->person,count), reply->person[count].person_id = pa.person_id,
   reply->person[count].name_last = p.name_last, reply->person[count].name_middle = p.name_middle,
   reply->person[count].name_first = p.name_first
  WITH nocounter
 ;end select
 IF (count=0)
  SET reply->person_qual = 0
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->person_qual = count
  SET reply->status_data.status = "S"
 ENDIF
END GO
