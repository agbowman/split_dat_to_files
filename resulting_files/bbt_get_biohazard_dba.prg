CREATE PROGRAM bbt_get_biohazard:dba
 RECORD reply(
   1 qual[10]
     2 organization_id = f8
     2 org_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
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
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET org_type_cd = 0.0
 SET org_type_cd = get_code_value(278,"BIOHAZARD")
 IF (org_type_cd=0.0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "Z"
  SELECT INTO "nl:"
   otr.org_type_cd, org.organization_id, org.org_name
   FROM org_type_reltn otr,
    organization org
   PLAN (otr
    WHERE otr.org_type_cd=org_type_cd)
    JOIN (org
    WHERE org.organization_id=otr.organization_id)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alter(reply->qual,(count1+ 9))
    ENDIF
    reply->qual[count1].organization_id = org.organization_id, reply->qual[count1].org_name = org
    .org_name
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alter(reply->qual,count1)
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
