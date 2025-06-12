CREATE PROGRAM bbd_get_org_phone:dba
 RECORD reply(
   1 phone_num = vc
   1 contact = vc
   1 extension = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET phone_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET code_cnt = 1
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,phone_cd)
 SELECT INTO "nl:"
  p.phone_num, p.contact, p.extension
  FROM phone p
  WHERE (p.parent_entity_id=request->organization_id)
   AND p.parent_entity_name="ORGANIZATION"
   AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
   AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
   AND p.active_ind=1
   AND p.phone_type_cd=phone_cd
  DETAIL
   reply->phone_num = p.phone_num, reply->contact = p.contact, reply->extension = p.extension
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
