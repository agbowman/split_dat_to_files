CREATE PROGRAM bed_rec_mic_ord_evnt_cd_assoc:dba
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
 DECLARE microat_cd = f8 WITH public, noconstant(0.0)
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
    AND cv.cdf_meaning="MICROBIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   microat_cd = cv.code_value
  WITH nocounter
 ;end select
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value_event_r cver,
   dummyt d
  PLAN (oc
   WHERE oc.catalog_type_cd=genlab
    AND oc.activity_type_cd=microat_cd
    AND oc.orderable_type_flag IN (0, 1, 5, 10)
    AND oc.active_ind=1)
   JOIN (d)
   JOIN (cver
   WHERE cver.parent_cd=oc.catalog_cd)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter, outerjoin = d, dontexist
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
