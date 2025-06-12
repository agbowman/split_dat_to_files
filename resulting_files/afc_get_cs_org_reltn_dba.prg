CREATE PROGRAM afc_get_cs_org_reltn:dba
 RECORD reply(
   1 cs_org_reltn_qual = i4
   1 cs_org_reltn[*]
     2 cs_org_reltn_id = f8
     2 organization_id = f8
     2 cs_org_reltn_type_cd = f8
     2 key1_id = f8
     2 org_name = c200
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET count1 = 0
 SET stat = alterlist(reply->cs_org_reltn,10)
 SELECT INTO "nl:"
  FROM cs_org_reltn o,
   organization g
  PLAN (o
   WHERE (o.cs_org_reltn_type_cd=request->cs_org_reltn_type_cd)
    AND o.active_ind=1)
   JOIN (g
   WHERE g.organization_id=o.organization_id)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->cs_org_reltn,(count1+ 10))
   ENDIF
   reply->cs_org_reltn[count1].cs_org_reltn_id = o.cs_org_reltn_id, reply->cs_org_reltn[count1].
   organization_id = o.organization_id, reply->cs_org_reltn[count1].cs_org_reltn_type_cd = o
   .cs_org_reltn_type_cd,
   reply->cs_org_reltn[count1].key1_id = o.key1_id, reply->cs_org_reltn[count1].org_name = g.org_name,
   reply->cs_org_reltn[count1].active_ind = o.active_ind,
   CALL echo(build("cs_org_reltn_id: ",o.cs_org_reltn_id))
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->cs_org_reltn,count1)
 SET reply->cs_org_reltn_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CS_ORG_RELTN"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
