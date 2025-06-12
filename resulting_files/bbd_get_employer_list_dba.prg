CREATE PROGRAM bbd_get_employer_list:dba
 RECORD reply(
   1 qual[*]
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
 SET reply->status_data.status = "F"
 SET count = 0
 SET org_type_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 278
 SET code_cnt = 1
 SET cdf_meaning = "EMPLOYER"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,org_type_cd)
 SELECT INTO "nl:"
  org.organization_id, org.org_name
  FROM organization org,
   org_type_reltn otr
  PLAN (org
   WHERE org.organization_id > 0
    AND cnvtdatetime(curdate,curtime3) >= org.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= org.end_effective_dt_tm
    AND org.active_ind=1)
   JOIN (otr
   WHERE org.organization_id=otr.organization_id
    AND otr.org_type_cd=org_type_cd
    AND cnvtdatetime(curdate,curtime3) >= otr.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= otr.end_effective_dt_tm
    AND otr.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].organization_id = org
   .organization_id,
   reply->qual[count].org_name = org.org_name
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
