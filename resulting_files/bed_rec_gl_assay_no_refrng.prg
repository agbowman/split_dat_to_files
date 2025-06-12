CREATE PROGRAM bed_rec_gl_assay_no_refrng
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
 DECLARE glb_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="GLB"
    AND cv.active_ind=1)
  DETAIL
   glb_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE alpha_cd = f8 WITH public, noconstant(0.0)
 DECLARE numeric_cd = f8 WITH public, noconstant(0.0)
 DECLARE calc_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning IN ("2", "3", "8")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="2")
    alpha_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="3")
    numeric_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="8")
    calc_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET reply->run_status_flag = 1
 SET total_assays = 0
 SELECT INTO "NL:"
  FROM discrete_task_assay dta,
   code_value cv,
   profile_task_r ptr,
   order_catalog oc,
   reference_range_factor rrf,
   dummyt d
  PLAN (dta
   WHERE dta.activity_type_cd=glb_cd
    AND dta.default_result_type_cd IN (alpha_cd, numeric_cd, calc_cd)
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.task_assay_cd
    AND cv.active_ind=1)
   JOIN (ptr
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND ptr.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.active_ind=1)
   JOIN (d)
   JOIN (rrf
   WHERE rrf.task_assay_cd=dta.task_assay_cd
    AND rrf.active_ind=1)
  ORDER BY cv.display
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter, outerjoin = d, dontexist
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
