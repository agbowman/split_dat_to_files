CREATE PROGRAM bed_get_rad_seg_ind:dba
 FREE SET reply
 RECORD reply(
   1 multi_segment_ind = i2
   1 single_segment_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.activity_type_cd=rad_cd
    AND  NOT (oc.orderable_type_flag IN (2, 6))
    AND oc.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    b.catalog_cd
    FROM br_exam_segment_info b
    WHERE b.catalog_cd=oc.catalog_cd))))
  DETAIL
   reply->single_segment_ind = 1
  WITH nocounter, maxqual(oc,1)
 ;end select
 SELECT INTO "nl:"
  FROM br_exam_segment_info b,
   order_catalog oc
  PLAN (b)
   JOIN (oc
   WHERE oc.catalog_cd=b.catalog_cd
    AND  NOT (oc.orderable_type_flag IN (2, 6))
    AND oc.active_ind=1)
  DETAIL
   reply->multi_segment_ind = 1
  WITH nocounter, maxqual(b,1)
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
