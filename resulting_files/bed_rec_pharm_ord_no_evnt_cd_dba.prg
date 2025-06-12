CREATE PROGRAM bed_rec_pharm_ord_no_evnt_cd:dba
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
 SET cpharm = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   cpharm = cv.code_value
  WITH nocounter
 ;end select
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value_event_r cver,
   dummyt d
  PLAN (oc
   WHERE oc.catalog_type_cd=cpharm
    AND oc.orderable_type_flag IN (0, 1, 10)
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
