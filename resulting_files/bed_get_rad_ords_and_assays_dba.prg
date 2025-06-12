CREATE PROGRAM bed_get_rad_ords_and_assays:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 description = c60
     2 assays[*]
       3 code_value = f8
       3 display = c40
       3 description = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rad_cat_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="RADIOLOGY"
   AND cv.active_ind=1
  DETAIL
   rad_cat_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET rad_act_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="RADIOLOGY"
   AND cv.active_ind=1
  DETAIL
   rad_act_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET datetime_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=289
   AND cv.cdf_meaning="11"
   AND cv.active_ind=1
  DETAIL
   datetime_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE oc_parse = vc
 IF ((request->activity_subtype_code_value=0))
  SET oc_parse = concat(
   "oc.catalog_type_cd = rad_cat_type_cd and oc.activity_type_cd = rad_act_type_cd",
   " and oc.active_ind = 1")
 ELSE
  SET subtype = cnvtstring(request->activity_subtype_code_value)
  SET oc_parse = concat(
   "oc.catalog_type_cd = rad_cat_type_cd and oc.activity_type_cd = rad_act_type_cd",
   " and oc.activity_subtype_cd = ",subtype," and oc.active_ind = 1")
 ENDIF
 SET ocnt = 0
 SET alterlist_ocnt = 0
 SET stat = alterlist(reply->orderables,100)
 SELECT INTO "NL:"
  FROM order_catalog oc,
   profile_task_r ptr,
   discrete_task_assay dta,
   code_value cv
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.default_result_type_cd=datetime_cd
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.task_assay_cd
    AND cv.active_ind=1)
  ORDER BY oc.catalog_cd
  HEAD oc.catalog_cd
   ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
   IF (alterlist_ocnt > 100)
    stat = alterlist(reply->orderables,(ocnt+ 100)), alterlist_ocnt = 1
   ENDIF
   reply->orderables[ocnt].code_value = oc.catalog_cd, reply->orderables[ocnt].description = oc
   .description, acnt = 0,
   alterlist_acnt = 0, stat = alterlist(reply->orderables[ocnt].assays,10)
  DETAIL
   acnt = (acnt+ 1), alterlist_acnt = (alterlist_acnt+ 1)
   IF (alterlist_acnt > 10)
    stat = alterlist(reply->orderables,(acnt+ 10)), alterlist_acnt = 1
   ENDIF
   reply->orderables[ocnt].assays[acnt].code_value = cv.code_value, reply->orderables[ocnt].assays[
   acnt].display = cv.display, reply->orderables[ocnt].assays[acnt].description = cv.description
  FOOT  oc.catalog_cd
   stat = alterlist(reply->orderables[ocnt].assays,acnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->orderables,ocnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
