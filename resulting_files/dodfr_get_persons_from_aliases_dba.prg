CREATE PROGRAM dodfr_get_persons_from_aliases:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 status_cd = f8
     2 alias = vc
     2 person_alias_type_cd = f8
     2 gender_cd = f8
     2 birthdate = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i2 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM person p,
   person_alias pa,
   (dummyt d  WITH seq = size(request->qual,5))
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_alias_type_cd=request->qual[d.seq].person_alias_type_cd)
    AND (pa.alias=request->qual[d.seq].alias)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pa.person_id)
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->qual,5))
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].person_id = pa.person_id, reply->qual[count].status_cd = pa.data_status_cd,
   reply->qual[count].alias = pa.alias,
   reply->qual[count].person_alias_type_cd = pa.person_alias_type_cd, reply->qual[count].gender_cd =
   p.sex_cd, reply->qual[count].birthdate = p.birth_dt_tm
  WITH nocounter
 ;end select
 SET reply->status_data.status = "Z"
 SET stat = alterlist(reply->qual,count)
END GO
