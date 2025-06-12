CREATE PROGRAM bed_rec_srvareaval_multi_area:dba
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
 SET reply->run_status_flag = 1
 SET lab_ct_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="GENERAL LAB"
   AND cv.active_ind=1
  DETAIL
   lab_ct_cd = cv.code_value
  WITH nocounter
 ;end select
 SET nu_cd = 0.0
 SET amb_cd = 0.0
 SET cslogin_cd = 0.0
 SET srvarea_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY", "CSLOGIN", "SRVAREA")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="NURSEUNIT")
    nu_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="AMBULATORY")
    amb_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CSLOGIN")
    cslogin_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SRVAREA")
    srvarea_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET multiple_srvarea_ind = 0
 SELECT INTO "nl:"
  FROM location l1,
   code_value cv,
   location_group lg1,
   location l2
  PLAN (l1
   WHERE l1.location_type_cd IN (amb_cd, nu_cd, cslogin_cd)
    AND l1.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=l1.location_cd
    AND cv.active_ind=1)
   JOIN (lg1
   WHERE lg1.child_loc_cd=l1.location_cd
    AND lg1.location_group_type_cd=srvarea_cd
    AND lg1.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg1.parent_loc_cd
    AND l2.discipline_type_cd=lab_ct_cd
    AND l2.active_ind=1)
  ORDER BY l1.location_cd
  HEAD l1.location_cd
   srvarea_cnt = 0
  DETAIL
   srvarea_cnt = (srvarea_cnt+ 1)
  FOOT  l1.location_cd
   IF (srvarea_cnt > 1)
    multiple_srvarea_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (multiple_srvarea_ind=1)
  SET reply->run_status_flag = 3
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
