CREATE PROGRAM bbt_get_orgs_by_type:dba
 RECORD reply(
   1 qual[*]
     2 org_type_cd = f8
     2 cdf_meaning = c12
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
 SET org_type_code_set = 278
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET type_cnt = 0
 SET qual_cnt = 0
 SET type_cnt = size(request->typelist,5)
 SET stat = alterlist(request->typelist,type_cnt)
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(type_cnt))
  DETAIL
   request->typelist[d.seq].org_type_cd = get_code_value(org_type_code_set,request->typelist[d.seq].
    cdf_meaning)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  otr.org_type_cd, org.organization_id, org.org_name
  FROM (dummyt d  WITH seq = value(type_cnt)),
   org_type_reltn otr,
   organization org
  PLAN (d)
   JOIN (otr
   WHERE (otr.org_type_cd=request->typelist[d.seq].org_type_cd))
   JOIN (org
   WHERE org.organization_id=otr.organization_id)
  DETAIL
   IF ((request->typelist[d.seq].org_type_cd != null)
    AND (request->typelist[d.seq].org_type_cd > 0)
    AND otr.active_ind=1
    AND otr.organization_id != null
    AND otr.organization_id > 0
    AND org.active_ind=1)
    qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1)
     stat = alterlist(reply->qual,(qual_cnt+ 9))
    ENDIF
    reply->qual[qual_cnt].org_type_cd = otr.org_type_cd, reply->qual[qual_cnt].cdf_meaning = request
    ->typelist[d.seq].cdf_meaning, reply->qual[qual_cnt].organization_id = otr.organization_id,
    reply->qual[qual_cnt].org_name = org.org_name
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 SET count1 = (count1+ 1)
 IF (count1 != 1)
  SET stat = alter(reply->status_data.subeventstatus,count1)
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select organizations"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_orgs_by_type"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No organizations found for requested types/cdf_meanings"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "select organizations"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_orgs_by_type"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SUCCESS"
 ENDIF
END GO
