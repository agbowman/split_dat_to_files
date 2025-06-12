CREATE PROGRAM bed_rec_gl_ord_no_req_assay:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE genlab = f8 WITH public, noconstant(0.0)
 DECLARE glbat_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB"
    AND cv.active_ind=1)
  DETAIL
   genlab = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="GLB"
    AND cv.active_ind=1)
  DETAIL
   glbat_cd = cv.code_value
  WITH nocounter
 ;end select
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM order_catalog o,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (o
   WHERE o.catalog_type_cd=genlab
    AND o.activity_type_cd=glbat_cd
    AND o.orderable_type_flag IN (0, 1, 5, 10)
    AND o.bill_only_ind IN (0, null)
    AND o.active_ind=1
    AND o.catalog_cd > 0)
   JOIN (cv1
   WHERE cv1.code_value=o.catalog_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=o.activity_type_cd)
   JOIN (cv3
   WHERE cv3.code_value=o.activity_subtype_cd)
   JOIN (ptr
   WHERE ptr.catalog_cd=o.catalog_cd
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
  ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic), o.catalog_cd
  HEAD o.catalog_cd
   req_cnt = 0
  DETAIL
   IF (ptr.pending_ind=1)
    req_cnt = 1
   ENDIF
  FOOT  o.catalog_cd
   IF (req_cnt=0)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
