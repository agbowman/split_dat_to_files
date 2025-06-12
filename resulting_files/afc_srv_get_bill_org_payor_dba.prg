CREATE PROGRAM afc_srv_get_bill_org_payor:dba
 CALL echo(
  "##############################################################################################")
 RECORD reply(
   1 org_payor_qual = i2
   1 org_payor[*]
     2 org_payor_id = f8
     2 organization_id = f8
     2 bill_org_type_cd = f8
     2 bill_org_type_id = f8
     2 priority = i4
     2 research_acct_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 CALL echo(build("in organization_id: ",request->organization_id))
 IF ((request->research_acct_id > 0))
  CALL echo("Looking for research accounts org id")
  SELECT INTO "nl:"
   r.organization_id
   FROM research_account r
   WHERE (r.research_account_id=request->research_acct_id)
   DETAIL
    request->organization_id = r.organization_id
   WITH nocounter
  ;end select
  CALL echo(build("Found: ",request->organization_id))
 ENDIF
 SELECT INTO "nl:"
  b.org_payor_id, b.organization_id, b.bill_org_type_cd,
  b.bill_org_type_id, b.priority
  FROM bill_org_payor b
  WHERE (b.organization_id=request->organization_id)
   AND b.active_ind=1
  ORDER BY b.bill_org_type_cd
  DETAIL
   CALL echo(build("org_payor_id: ",b.org_payor_id),0),
   CALL echo(build("bill_org_type_id: ",b.bill_org_type_id),0),
   CALL echo(build("bill_org_type_cd: ",b.bill_org_type_cd)),
   count1 += 1, stat = alterlist(reply->org_payor,count1), reply->org_payor_qual = count1,
   reply->org_payor[count1].org_payor_id = b.org_payor_id, reply->org_payor[count1].organization_id
    = b.organization_id, reply->org_payor[count1].bill_org_type_cd = b.bill_org_type_cd,
   reply->org_payor[count1].bill_org_type_id = b.bill_org_type_id, reply->org_payor[count1].priority
    = b.priority, reply->org_payor[count1].research_acct_id = request->research_acct_id
  WITH nocounter
 ;end select
 SET reply->org_payor_qual = count1
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(
  "##############################################################################################")
END GO
