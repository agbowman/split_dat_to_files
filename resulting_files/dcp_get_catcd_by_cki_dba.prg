CREATE PROGRAM dcp_get_catcd_by_cki:dba
 RECORD reply(
   1 cnt = i4
   1 qual[*]
     2 catalog_cd = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SET nbr_to_get = cnvtint(size(request->qual,5))
 SELECT INTO "nl:"
  FROM order_catalog oc,
   (dummyt d  WITH seq = value(nbr_to_get))
  PLAN (d)
   JOIN (oc
   WHERE oc.cki=trim(request->qual[d.seq].cki))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].catalog_cd = oc.catalog_cd, reply->qual[cnt].cki = oc.cki
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->cnt = cnt
 ENDIF
 SET stat = alterlist(reply->qual,cnt)
END GO
