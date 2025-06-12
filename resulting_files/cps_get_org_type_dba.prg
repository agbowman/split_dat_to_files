CREATE PROGRAM cps_get_org_type:dba
 RECORD reply(
   1 organization_qual = i4
   1 organization[*]
     2 org_name = vc
     2 org_id = f8
     2 org_type = c12
     2 org_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 SET count1 = 1
 SET reply->organization_qual = 0
 SET stat = alterlist(reply->organization,10)
 SELECT INTO "nl:"
  o.organization_id
  FROM organization o,
   org_type_reltn o2,
   code_value c,
   (dummyt d  WITH seq = value(request->org_type_qual))
  PLAN (d)
   JOIN (c
   WHERE c.code_set=278
    AND (c.cdf_meaning=request->org_type[d.seq].organization_type))
   JOIN (o2
   WHERE o2.org_type_cd=c.code_value)
   JOIN (o
   WHERE o.organization_id=o2.organization_id
    AND o.active_ind=1)
  ORDER BY o.organization_id
  HEAD o.organization_id
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->organization,(count1+ 9))
   ENDIF
   reply->organization[count1].org_name = o.org_name, reply->organization[count1].org_id = o
   .organization_id, reply->organization[count1].org_type = c.cdf_meaning,
   reply->organization[count1].org_type_cd = o2.org_type_cd, count1 += 1
  DETAIL
   x = 1
  FOOT REPORT
   stat = alterlist(reply->organization,count1), reply->organization_qual = count1
  WITH check, nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
