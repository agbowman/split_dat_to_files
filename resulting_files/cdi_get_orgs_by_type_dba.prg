CREATE PROGRAM cdi_get_orgs_by_type:dba
 RECORD reply(
   1 organizations[*]
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
 DECLARE count1 = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  o.org_name, o.organization_id
  FROM organization o,
   org_type_reltn r
  PLAN (r
   WHERE (r.org_type_cd=request->org_type_cd)
    AND r.active_ind=1)
   JOIN (o
   WHERE o.organization_id=r.organization_id
    AND o.active_ind=1)
  HEAD REPORT
   stat = alterlist(reply->organizations,10), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->organizations,(count1+ 9))
   ENDIF
   reply->organizations[count1].organization_id = o.organization_id, reply->organizations[count1].
   org_name = o.org_name
  FOOT REPORT
   stat = alterlist(reply->organizations,count1)
   IF (count1 > 0)
    reply->status_data.status = "S"
   ENDIF
 ;end select
END GO
