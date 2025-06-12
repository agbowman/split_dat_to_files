CREATE PROGRAM cps_get_ord_cat:dba
 FREE SET reply
 RECORD reply(
   1 catalog_type_cd = f8
   1 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 SELECT INTO "nl:"
  oc.catalog_cd
  FROM order_catalog oc
  PLAN (oc
   WHERE (oc.catalog_cd=request->catalog_cd))
  DETAIL
   reply->catalog_type_cd = oc.catalog_type_cd, reply->cki = oc.cki
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
