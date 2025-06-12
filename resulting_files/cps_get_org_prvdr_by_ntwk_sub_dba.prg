CREATE PROGRAM cps_get_org_prvdr_by_ntwk_sub:dba
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  FROM org_ntwk_prvdr p,
   organization n
  PLAN (p
   WHERE  $1
    AND  $2
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (n
   WHERE p.organization_id=n.organization_id)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1,
   CALL echo(build("count is",count1)),
   CALL echo(build("org_id is",p.organization_id))
   IF (mod(count1,100)=1)
    stat = alterlist(reply->org_ntwk_prvdr,(count1+ 100)), stat = alterlist(reply->organization,(
     count1+ 100))
   ENDIF
   reply->org_ntwk_prvdr[count1].org_ntwk_prvdr_id = p.org_ntwk_prvdr_id, reply->org_ntwk_prvdr[
   count1].updt_cnt = p.updt_cnt, reply->org_ntwk_prvdr[count1].organization_id = p.organization_id,
   reply->org_ntwk_prvdr[count1].network_id = p.network_id, reply->org_ntwk_prvdr[count1].
   specialty_cd = p.specialty_cd, reply->organization[count1].organization_id = n.organization_id,
   reply->organization[count1].org_name = n.org_name, reply->organization[count1].org_name_key = n
   .org_name_key, reply->organization[count1].federal_tax_id_nbr = n.federal_tax_id_nbr,
   reply->organization[count1].org_status_cd = n.org_status_cd, reply->organization[count1].
   org_class_cd = n.org_class_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORG_NTWK_PRVDR"
 ELSE
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->org_ntwk_prvdr,count1)
  SET stat = alterlist(reply->organization,count1)
 ENDIF
 CALL echo("Count is")
 CALL echo(count1)
 CALL echo("Script terminating")
#9999_end
END GO
