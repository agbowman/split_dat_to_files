CREATE PROGRAM bed_get_rad_orderable_info:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 primary_mnemonic = vc
     2 completed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
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
 SET date_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.display_key="DATEANDTIME"
    AND cv.active_ind=1)
  DETAIL
   date_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((request->multi_segment_ind=0))
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
   ORDER BY oc.primary_mnemonic
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].code_value = oc
    .catalog_cd,
    reply->orderables[cnt].primary_mnemonic = oc.primary_mnemonic
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM br_exam_segment_info b,
    order_catalog oc
   PLAN (b)
    JOIN (oc
    WHERE oc.catalog_cd=b.catalog_cd
     AND  NOT (oc.orderable_type_flag IN (2, 6))
     AND oc.active_ind=1)
   ORDER BY b.primary_mnemonic
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].code_value = b
    .catalog_cd,
    reply->orderables[cnt].primary_mnemonic = oc.primary_mnemonic
   WITH nocounter
  ;end select
 ENDIF
 IF (size(reply->orderables,5) > 0)
  IF ((request->multi_segment_ind=0))
   SELECT INTO "nl:"
    ptr.catalog_cd, d.seq
    FROM (dummyt d  WITH seq = value(size(reply->orderables,5))),
     profile_task_r ptr,
     discrete_task_assay dta
    PLAN (d)
     JOIN (ptr
     WHERE (ptr.catalog_cd=reply->orderables[d.seq].code_value)
      AND ptr.active_ind=1)
     JOIN (dta
     WHERE dta.task_assay_cd=ptr.task_assay_cd
      AND dta.activity_type_cd=rad_cd
      AND dta.default_result_type_cd=date_cd
      AND dta.active_ind=1)
    GROUP BY ptr.catalog_cd
    HAVING count(*)=1
    DETAIL
     reply->orderables[d.seq].completed_ind = 1
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reply->orderables,5))),
     profile_task_r ptr,
     discrete_task_assay dta
    PLAN (d)
     JOIN (ptr
     WHERE (ptr.catalog_cd=reply->orderables[d.seq].code_value)
      AND ptr.active_ind=1)
     JOIN (dta
     WHERE dta.task_assay_cd=ptr.task_assay_cd
      AND dta.activity_type_cd=rad_cd
      AND dta.default_result_type_cd=date_cd
      AND dta.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     reply->orderables[d.seq].completed_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (size(reply->orderables,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
