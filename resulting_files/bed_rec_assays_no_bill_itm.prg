CREATE PROGRAM bed_rec_assays_no_bill_itm
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET glb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="GLB"
    AND cv.active_ind=1)
  DETAIL
   glb_cd = cv.code_value
  WITH nocounter
 ;end select
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
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  desc = cnvtupper(dta.description)
  FROM discrete_task_assay dta,
   (dummyt d  WITH seq = 1),
   bill_item b
  PLAN (dta
   WHERE  NOT (dta.activity_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=106
     AND definition IN ("GENERAL LAB", "RADIOLOGY"))))
    AND dta.active_ind=1)
   JOIN (d)
   JOIN (b
   WHERE b.ext_child_reference_id=dta.task_assay_cd
    AND b.active_ind=1)
  ORDER BY desc
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter, outerjoin = d, dontexist
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
