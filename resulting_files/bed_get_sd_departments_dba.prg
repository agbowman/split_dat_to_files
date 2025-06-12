CREATE PROGRAM bed_get_sd_departments:dba
 FREE SET reply
 RECORD reply(
   1 departments[*]
     2 code_value = f8
     2 display = vc
     2 has_appt_ind = i2
     2 has_orders_ind = i2
     2 dept_type
       3 dept_type_id = f8
       3 display = vc
     2 meaning = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fac_code_value = 0.0
 SET building_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("FACILITY", "BUILDING")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="FACILITY")
    fac_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="BUILDING")
    building_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE dept_parse = vc
 SET nurse_ind = 0
 SET dept_parse = " cv.cdf_meaning IN ( 'NURSEUNIT' "
 FOR (x = 1 TO size(request->dept_meanings,5))
  IF ((request->dept_meanings[x].meaning="NURSEUNIT"))
   SET nurse_ind = 1
  ENDIF
  SET dept_parse = concat(dept_parse,", '",request->dept_meanings[x].meaning,"'")
 ENDFOR
 SET dept_parse = concat(dept_parse," ) ")
 DECLARE facility_parse = vc
 IF (size(request->facilities,5) > 0)
  SET facility_parse = build("lg1.parent_loc_cd in ( ",request->facilities[1].code_value)
  FOR (x = 2 TO size(request->facilities,5))
    SET facility_parse = build(facility_parse,", ",request->facilities[x].code_value)
  ENDFOR
  SET facility_parse = concat(facility_parse," ) ")
 ELSE
  SET facility_parse = "1=1"
 ENDIF
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM location_group lg1,
   location_group lg2,
   code_value cv,
   br_sched_dept bsd,
   sch_appt_loc sal
  PLAN (lg1
   WHERE ((lg1.root_loc_cd+ 0)=0)
    AND lg1.location_group_type_cd=fac_code_value
    AND ((lg1.active_ind+ 0)=1)
    AND parser(facility_parse))
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND ((lg2.root_loc_cd+ 0)=0)
    AND ((lg2.location_group_type_cd+ 0)=building_code_value)
    AND ((lg2.active_ind+ 0)=1))
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND parser(dept_parse)
    AND cv.active_ind=1)
   JOIN (bsd
   WHERE bsd.location_cd=outerjoin(lg2.child_loc_cd))
   JOIN (sal
   WHERE sal.location_cd=outerjoin(lg2.child_loc_cd))
  ORDER BY lg2.child_loc_cd
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->departments,100)
  HEAD lg2.child_loc_cd
   IF (nurse_ind=1)
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->departments,(tot_cnt+ 100)), cnt = 1
    ENDIF
    reply->departments[tot_cnt].code_value = lg2.child_loc_cd, reply->departments[tot_cnt].display =
    cv.display, reply->departments[tot_cnt].dept_type.dept_type_id = bsd.dept_type_id,
    reply->departments[tot_cnt].meaning = cv.cdf_meaning, reply->departments[tot_cnt].description =
    cv.description
    IF (sal.location_cd > 0)
     reply->departments[tot_cnt].has_appt_ind = 1
    ENDIF
   ELSE
    IF (((cv.cdf_meaning != "NURSEUNIT") OR (((cv.cdf_meaning="NURSEUNIT"
     AND bsd.location_cd > 0) OR (cv.cdf_meaning="NURSEUNIT"
     AND sal.location_cd > 0)) )) )
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(reply->departments,(tot_cnt+ 100)), cnt = 1
     ENDIF
     reply->departments[tot_cnt].code_value = lg2.child_loc_cd, reply->departments[tot_cnt].display
      = cv.display, reply->departments[tot_cnt].dept_type.dept_type_id = bsd.dept_type_id,
     reply->departments[tot_cnt].meaning = cv.cdf_meaning, reply->departments[tot_cnt].description =
     cv.description
     IF (sal.location_cd > 0)
      reply->departments[tot_cnt].has_appt_ind = 1
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->departments,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    br_sched_dept_type bsdt
   PLAN (d
    WHERE (reply->departments[d.seq].dept_type.dept_type_id > 0))
    JOIN (bsdt
    WHERE (bsdt.dept_type_id=reply->departments[d.seq].dept_type.dept_type_id))
   ORDER BY d.seq
   DETAIL
    reply->departments[d.seq].dept_type.display = bsdt.dept_type_display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    br_sched_dept_ord_r bsdor
   PLAN (d)
    JOIN (bsdor
    WHERE (bsdor.location_cd=reply->departments[d.seq].code_value))
   ORDER BY d.seq
   HEAD d.seq
    reply->departments[d.seq].has_orders_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
