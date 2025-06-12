CREATE PROGRAM cps_get_org_by_name:dba
 RECORD reply(
   1 org_qual = i4
   1 org[*]
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
 SET partial_name = cnvtupper(build(request->org_partial_name,"*"))
 SELECT INTO "NL:"
  o.organization_id, o.org_name
  FROM organization o
  WHERE o.organization_id > 0
   AND o.active_ind=1
   AND cnvtupper(o.org_name)=patstring(partial_name)
  ORDER BY cnvtupper(o.org_name)
  DETAIL
   count += 1, stat = alterlist(reply->org,count), reply->org[count].org_name = o.org_name,
   reply->org[count].organization_id = o.organization_id
  WITH nocounter
 ;end select
 IF (count=0)
  SET reply->org_qual = 0
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->org_qual = count
  SET reply->status_data.status = "S"
 ENDIF
END GO
