CREATE PROGRAM bed_get_thera_class_units:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 buildings[*]
      2 building_code_value = f8
      2 building_display = vc
      2 building_seq = i4
      2 units[*]
        3 unit_code_value = f8
        3 unit_display = vc
        3 unit_seq = i4
        3 type_code_value = f8
        3 type_mean = vc
        3 type_display = vc
        3 defined_ind = i2
        3 thera_classes[*]
          4 id = f8
          4 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE fac_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE build_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE ucnt = i4 WITH protect, noconstant(0)
 DECLARE tucnt = i4 WITH protect, noconstant(0)
 DECLARE clcnt = i4 WITH protect, noconstant(0)
 DECLARE cltcnt = i4 WITH protect, noconstant(0)
 IF ((request->facility_code_value=0.0))
  CALL bederror("Facility not provided.")
 ENDIF
 SET fac_type_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SET build_type_cd = uar_get_code_by("MEANING",222,"BUILDING")
 SELECT INTO "nl:"
  FROM location_group lg1,
   location l1,
   code_value cv1,
   location_group lg2,
   location l2,
   code_value cv2,
   code_value cv3
  PLAN (lg1
   WHERE (lg1.parent_loc_cd=request->facility_code_value)
    AND lg1.location_group_type_cd=fac_type_cd
    AND lg1.active_ind=1
    AND lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (l1
   WHERE l1.location_cd=lg1.child_loc_cd
    AND l1.active_ind=1
    AND l1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cv1
   WHERE cv1.code_value=lg1.child_loc_cd
    AND cv1.active_ind=1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=cv1.code_value
    AND lg2.location_group_type_cd=build_type_cd
    AND lg2.active_ind=1
    AND lg2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (l2
   WHERE l2.location_cd=lg2.child_loc_cd
    AND l2.active_ind=1
    AND l2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cv2
   WHERE cv2.code_value=lg2.child_loc_cd
    AND cv2.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=l2.location_type_cd
    AND cv3.active_ind=1)
  ORDER BY lg1.sequence, cv1.code_value, lg2.sequence,
   cv2.code_value
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->buildings,10)
  HEAD cv1.code_value
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(reply->buildings,(tcnt+ 10))
   ENDIF
   reply->buildings[tcnt].building_code_value = cv1.code_value, reply->buildings[tcnt].
   building_display = cv1.display, reply->buildings[tcnt].building_seq = lg1.sequence,
   ucnt = 0, tucnt = 0, stat = alterlist(reply->buildings[tcnt].units,10)
  HEAD cv2.code_value
   ucnt = (ucnt+ 1), tucnt = (tucnt+ 1)
   IF (ucnt > 10)
    ucnt = 1, stat = alterlist(reply->buildings[tcnt].units,(tucnt+ 10))
   ENDIF
   reply->buildings[tcnt].units[tucnt].unit_code_value = cv2.code_value, reply->buildings[tcnt].
   units[tucnt].unit_display = cv2.display, reply->buildings[tcnt].units[tucnt].unit_seq = lg2
   .sequence,
   reply->buildings[tcnt].units[tucnt].type_code_value = cv3.code_value, reply->buildings[tcnt].
   units[tucnt].type_display = cv3.display, reply->buildings[tcnt].units[tucnt].type_mean = cv3
   .cdf_meaning
  FOOT  cv1.code_value
   stat = alterlist(reply->buildings[tcnt].units,tucnt)
  FOOT REPORT
   stat = alterlist(reply->buildings,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting units.")
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   (dummyt d2  WITH seq = 1),
   location l,
   cms_critical_location cl,
   cms_critical_category c,
   mltm_drug_categories m
  PLAN (d
   WHERE maxrec(d2,size(reply->buildings[d.seq].units,5)))
   JOIN (d2)
   JOIN (l
   WHERE (l.location_cd=request->facility_code_value))
   JOIN (cl
   WHERE cl.organization_id=l.organization_id
    AND (cl.location_cd=reply->buildings[d.seq].units[d2.seq].unit_code_value))
   JOIN (c
   WHERE c.cms_critical_location_id=outerjoin(cl.cms_critical_location_id))
   JOIN (m
   WHERE m.multum_category_id=outerjoin(c.multum_category_id))
  ORDER BY d.seq, d2.seq
  HEAD d.seq
   clcnt = 0, cltcnt = 0
  HEAD d2.seq
   reply->buildings[d.seq].units[d2.seq].defined_ind = 1, clcnt = 0, cltcnt = 0,
   stat = alterlist(reply->buildings[d.seq].units[d2.seq].thera_classes,10)
  DETAIL
   IF (m.multum_category_id > 0)
    clcnt = (clcnt+ 1), cltcnt = (cltcnt+ 1)
    IF (clcnt > 10)
     clcnt = 1, stat = alterlist(reply->buildings[d.seq].units[d2.seq].thera_classes,(cltcnt+ 10))
    ENDIF
    reply->buildings[d.seq].units[d2.seq].thera_classes[cltcnt].id = m.multum_category_id, reply->
    buildings[d.seq].units[d2.seq].thera_classes[cltcnt].name = m.category_name
   ENDIF
  FOOT  d2.seq
   stat = alterlist(reply->buildings[d.seq].units[d2.seq].thera_classes,cltcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
