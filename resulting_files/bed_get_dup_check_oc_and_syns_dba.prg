CREATE PROGRAM bed_get_dup_check_oc_and_syns:dba
 FREE SET reply
 RECORD reply(
   1 duplicate_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->duplicate_ind = 0
 IF ((request->dup_check_type=1))
  SELECT INTO "NL:"
   FROM order_catalog oc
   WHERE cnvtupper(oc.description)=cnvtupper(request->dup_check_string)
    AND (((oc.catalog_cd != request->catalog_cd)) OR ((request->catalog_cd=0)))
   DETAIL
    reply->duplicate_ind = 1
   WITH nocounter
  ;end select
 ELSEIF ((request->dup_check_type=2))
  SELECT INTO "NL:"
   FROM order_catalog_synonym ocs
   WHERE ocs.mnemonic_key_cap=cnvtupper(request->dup_check_string)
    AND (((ocs.catalog_cd != request->catalog_cd)) OR ((request->catalog_cd=0)))
   DETAIL
    reply->duplicate_ind = 1
   WITH nocounter
  ;end select
 ELSEIF ((request->dup_check_type=3))
  SET lab_type_cd = 0.0
  SET rad_type_cd = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning IN ("GENERAL LAB", "RADIOLOGY")
    AND cv.active_ind=1
   DETAIL
    IF (cv.cdf_meaning="GENERAL LAB")
     lab_type_cd = cv.code_value
    ELSEIF (cv.cdf_meaning="RADIOLOGY")
     rad_type_cd = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM order_catalog oc
   WHERE cnvtupper(oc.dept_display_name)=cnvtupper(request->dup_check_string)
    AND (((oc.catalog_cd != request->catalog_cd)) OR ((request->catalog_cd=0)))
    AND oc.catalog_type_cd IN (lab_type_cd, rad_type_cd)
   DETAIL
    reply->duplicate_ind = 1
   WITH nocounter
  ;end select
  IF ((reply->duplicate_ind=0))
   SELECT INTO "NL:"
    FROM service_directory sd,
     order_catalog oc
    PLAN (sd
     WHERE cnvtupper(sd.short_description)=cnvtupper(request->dup_check_string)
      AND (((sd.catalog_cd != request->catalog_cd)) OR ((request->catalog_cd=0))) )
     JOIN (oc
     WHERE oc.catalog_cd=sd.catalog_cd
      AND oc.catalog_type_cd IN (lab_type_cd, rad_type_cd))
    DETAIL
     reply->duplicate_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
