CREATE PROGRAM bed_get_pharm_locs_by_fac:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 code_value = f8
     2 buildings[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 pharmacies[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
       3 nursing_units[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = size(request->facilities,5)
 SET stat = alterlist(reply->facilities,cnt)
 SET inpatient_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4500
   AND cv.cdf_meaning="INPATIENT"
   AND cv.active_ind=1
  DETAIL
   inpatient_code_value = cv.code_value
  WITH nocounter
 ;end select
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
 SET pharm_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharm_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt)
   PLAN (d)
   ORDER BY d.seq
   DETAIL
    reply->facilities[d.seq].code_value = request->facilities[d.seq].code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    location_group lg1,
    location_group lg2,
    code_value cv,
    code_value cv2,
    service_resource sr,
    serv_res_ext_pharm sp
   PLAN (d)
    JOIN (lg1
    WHERE (lg1.parent_loc_cd=reply->facilities[d.seq].code_value)
     AND ((lg1.root_loc_cd+ 0)=0)
     AND ((lg1.location_group_type_cd+ 0)=fac_code_value)
     AND ((lg1.active_ind+ 0)=1))
    JOIN (lg2
    WHERE lg2.parent_loc_cd=lg1.child_loc_cd
     AND ((lg2.root_loc_cd+ 0)=0)
     AND ((lg2.location_group_type_cd+ 0)=building_code_value)
     AND ((lg2.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=lg2.child_loc_cd
     AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY", "PHARM")
     AND cv.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=lg2.parent_loc_cd
     AND cv2.active_ind=1)
    JOIN (sr
    WHERE sr.location_cd=outerjoin(lg2.child_loc_cd)
     AND sr.pharmacy_type_cd=outerjoin(inpatient_code_value)
     AND sr.activity_type_cd=outerjoin(pharm_code_value)
     AND sr.active_ind=outerjoin(1))
    JOIN (sp
    WHERE sp.service_resource_cd=outerjoin(sr.service_resource_cd))
   ORDER BY d.seq, lg2.parent_loc_cd
   HEAD d.seq
    bcnt = 0, blist_cnt = 0, stat = alterlist(reply->facilities[d.seq].buildings,10)
   HEAD lg2.parent_loc_cd
    bcnt = (bcnt+ 1), blist_cnt = (blist_cnt+ 1)
    IF (blist_cnt > 10)
     stat = alterlist(reply->facilities[d.seq].buildings,(bcnt+ 10)), blist_cnt = 1
    ENDIF
    reply->facilities[d.seq].buildings[bcnt].code_value = lg2.parent_loc_cd, reply->facilities[d.seq]
    .buildings[bcnt].display = cv2.display, reply->facilities[d.seq].buildings[bcnt].description =
    cv2.description,
    pcnt = 0, ncnt = 0, plist_cnt = 0,
    nlist_cnt = 0, stat = alterlist(reply->facilities[d.seq].buildings[bcnt].pharmacies,10), stat =
    alterlist(reply->facilities[d.seq].buildings[bcnt].nursing_units,10)
   DETAIL
    IF (cv.cdf_meaning="PHARM"
     AND sp.floorstock_ind=0)
     pcnt = (pcnt+ 1), plist_cnt = (plist_cnt+ 1)
     IF (plist_cnt > 10)
      stat = alterlist(reply->facilities[d.seq].buildings[bcnt].pharmacies,(pcnt+ 10)), plist_cnt = 1
     ENDIF
     reply->facilities[d.seq].buildings[bcnt].pharmacies[pcnt].code_value = cv.code_value, reply->
     facilities[d.seq].buildings[bcnt].pharmacies[pcnt].display = cv.display, reply->facilities[d.seq
     ].buildings[bcnt].pharmacies[pcnt].description = cv.description
    ELSEIF (((cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")) OR (cv.cdf_meaning="PHARM"
     AND sp.floorstock_ind=1)) )
     ncnt = (ncnt+ 1), nlist_cnt = (nlist_cnt+ 1)
     IF (nlist_cnt > 10)
      stat = alterlist(reply->facilities[d.seq].buildings[bcnt].nursing_units,(ncnt+ 10)), nlist_cnt
       = 1
     ENDIF
     reply->facilities[d.seq].buildings[bcnt].nursing_units[ncnt].code_value = cv.code_value, reply->
     facilities[d.seq].buildings[bcnt].nursing_units[ncnt].display = cv.display, reply->facilities[d
     .seq].buildings[bcnt].nursing_units[ncnt].description = cv.description
    ENDIF
   FOOT  lg2.parent_loc_cd
    stat = alterlist(reply->facilities[d.seq].buildings[bcnt].pharmacies,pcnt), stat = alterlist(
     reply->facilities[d.seq].buildings[bcnt].nursing_units,ncnt)
   FOOT  d.seq
    stat = alterlist(reply->facilities[d.seq].buildings,bcnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
