CREATE PROGRAM bed_get_sn_check_virtual_views:dba
 FREE SET reply
 RECORD reply(
   1 virtual_views_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET surgery_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="SURGERY"
  DETAIL
   surgery_cd = cv.code_value
  WITH nocounter
 ;end select
 SET reply->virtual_views_exist_ind = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (oc
   WHERE oc.catalog_type_cd=surgery_cd
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1)
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ofr.facility_cd > 0)
  DETAIL
   reply->virtual_views_exist_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
