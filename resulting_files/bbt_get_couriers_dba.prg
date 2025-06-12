CREATE PROGRAM bbt_get_couriers:dba
 RECORD reply(
   1 qual[0]
     2 person_id = f8
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET reply->status_data[1].status = "F"
 SET cnt = 0
 SET stat = alter(reply->qual,0)
 SET max = 0
 SET code_value = 0.0
 SET cdf_meaning = "             "
 SET cdf_meaning = "BLOODCOURIER"
 SET code_value = get_code_value(357,cdf_meaning)
 SELECT INTO "nl:"
  pg.prsnl_group_type_cd, pgr.person_id, p.person_id,
  p.name_full_formatted
  FROM prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p
  PLAN (pg
   WHERE pg.prsnl_group_type_cd=code_value
    AND pg.active_ind=1)
   JOIN (pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pg.active_ind=1)
   JOIN (p
   WHERE pgr.person_id=p.person_id)
  DETAIL
   IF (p.person_id > 0)
    cnt = (cnt+ 1)
    IF (cnt > max)
     max = cnt, stat = alter(reply->qual,max)
    ENDIF
    reply->qual[cnt].person_id = p.person_id, reply->qual[cnt].name_full_formatted = p
    .name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
