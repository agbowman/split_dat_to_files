CREATE PROGRAM bed_rec_srvareaval_miss_area:dba
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
 SET not_in_srvarea_ind = 0
 SELECT INTO "nl:"
  FROM location l1,
   code_value cv,
   (dummyt d  WITH seq = 1),
   location_group lg,
   location l2
  PLAN (l1
   WHERE l1.location_type_cd IN (amb_cd, nu_cd, cslogin_cd)
    AND l1.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=l1.location_cd
    AND cv.active_ind=1)
   JOIN (d)
   JOIN (lg
   WHERE lg.child_loc_cd=l1.location_cd
    AND lg.location_group_type_cd=srvarea_cd
    AND lg.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg.parent_loc_cd
    AND l2.discipline_type_cd=lab_ct_cd
    AND l2.active_ind=1)
  DETAIL
   not_in_srvarea_ind = 1
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 IF (not_in_srvarea_ind=1)
  SET reply->run_status_flag = 3
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
