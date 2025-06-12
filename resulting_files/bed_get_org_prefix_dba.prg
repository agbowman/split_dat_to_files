CREATE PROGRAM bed_get_org_prefix:dba
 FREE SET reply
 RECORD reply(
   1 org_prefixes[*]
     2 prefix = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ocnt = 0
 SET ocnt = size(request->organizations,5)
 SET stat = alterlist(reply->org_prefixes,ocnt)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = ocnt),
   br_organization b
  PLAN (d)
   JOIN (b
   WHERE (b.organization_id=request->organizations[d.seq].id))
  DETAIL
   reply->org_prefixes[d.seq].prefix = b.br_prefix
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
