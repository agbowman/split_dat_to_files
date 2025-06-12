CREATE PROGRAM bed_get_vvl_check_database:dba
 FREE SET reply
 RECORD reply(
   1 orders_ind = i2
   1 formulary_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pharm_ct = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharm_ct = cv.code_value
  WITH nocounter
 ;end select
 SET pharm_at = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharm_at = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  x = count(*)
  FROM order_catalog oc
  WHERE oc.catalog_type_cd=pharm_ct
   AND oc.activity_type_cd=pharm_at
   AND oc.active_ind=1
  HEAD REPORT
   IF (x > 0)
    reply->orders_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  y = count(*)
  FROM medication_definition m
  WHERE m.item_id > 0
  HEAD REPORT
   IF (y > 0)
    reply->formulary_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
