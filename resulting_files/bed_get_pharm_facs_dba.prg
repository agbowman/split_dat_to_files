CREATE PROGRAM bed_get_pharm_facs:dba
 FREE SET reply
 RECORD reply(
   1 items[*]
     2 item_id = f8
     2 all_facilities_ind = i2
     2 reuse_ind = i2
     2 dispense_from_flag = i2
     2 facilities[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 buildings[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
         4 pharmacies[*]
           5 code_value = f8
           5 display = vc
           5 description = vc
         4 nursing_units[*]
           5 code_value = f8
           5 display = vc
           5 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_locs
 RECORD temp_locs(
   1 items[*]
     2 item_id = f8
     2 locs[*]
       3 loc_cd = f8
       3 loc_disp = vc
       3 loc_desc = vc
       3 loc_mean = vc
 )
 SET reply->status_data.status = "F"
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
 SET system_code_value = 0.0
 SET system_package_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning IN ("SYSTEM", "SYSPKGTYP")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="SYSTEM")
    system_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="SYSPKGTYP")
    system_package_code_value = cv.code_value
   ENDIF
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
 SET med_product_code_value = 0.0
 SET med_oe_defaults_code_value = 0.0
 SET orderable_code_value = 0.0
 SET med_dispense_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4063
   AND cv.cdf_meaning IN ("MEDPRODUCT", "OEDEF", "ORDERABLE", "DISPENSE")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="MEDPRODUCT")
    med_product_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="OEDEF")
    med_oe_defaults_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="ORDERABLE")
    orderable_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPENSE")
    med_dispense_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET brreq = size(request->items,5)
 IF (brreq=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->items,brreq)
 SET stat = alterlist(temp_locs->items,brreq)
 FOR (brx = 1 TO brreq)
  SET reply->items[brx].item_id = request->items[brx].item_id
  SET temp_locs->items[brx].item_id = request->items[brx].item_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(brreq)),
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   code_value cv,
   location l
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=reply->items[d.seq].item_id)
    AND mdf.flex_type_cd=system_package_code_value
    AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
    AND ((mdf.sequence+ 0)=0)
    AND ((mdf.med_def_flex_id+ 0) != 0)
    AND ((mdf.active_ind+ 0)=1))
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=orderable_code_value
    AND ((mfoi.parent_entity_name="CODE_VALUE"
    AND mfoi.parent_entity_id > 0) OR (mfoi.parent_entity_id=0)) )
   JOIN (cv
   WHERE cv.code_value=outerjoin(mfoi.parent_entity_id)
    AND cv.active_ind=outerjoin(1))
   JOIN (l
   WHERE l.location_cd=outerjoin(cv.code_value)
    AND l.location_type_cd=outerjoin(fac_code_value)
    AND l.active_ind=outerjoin(1))
  ORDER BY d.seq
  HEAD d.seq
   fcnt = 0, ftot_cnt = 0, stat = alterlist(reply->items[d.seq].facilities,10)
  DETAIL
   IF (mfoi.parent_entity_id=0)
    reply->items[d.seq].all_facilities_ind = 1
   ELSEIF (l.location_cd > 0)
    fcnt = (fcnt+ 1), ftot_cnt = (ftot_cnt+ 1)
    IF (fcnt > 10)
     stat = alterlist(reply->items[d.seq].facilities,(ftot_cnt+ 10)), fcnt = 1
    ENDIF
    reply->items[d.seq].facilities[ftot_cnt].code_value = cv.code_value, reply->items[d.seq].
    facilities[ftot_cnt].display = cv.display, reply->items[d.seq].facilities[ftot_cnt].description
     = cv.description
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->items[d.seq].facilities,ftot_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(brreq)),
   stored_at s,
   location_group lg1,
   location_group lg2,
   location l1,
   location l2,
   location l3,
   code_value cv,
   service_resource sr,
   serv_res_ext_pharm sp,
   code_value cv2,
   code_value cv3
  PLAN (d
   WHERE (reply->items[d.seq].all_facilities_ind=1))
   JOIN (s
   WHERE (s.item_id=reply->items[d.seq].item_id))
   JOIN (lg1
   WHERE lg1.child_loc_cd=s.location_cd
    AND ((lg1.location_group_type_cd+ 0)=building_code_value)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND ((lg2.location_group_type_cd+ 0)=fac_code_value)
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (l1
   WHERE l1.location_cd=lg1.child_loc_cd
    AND l1.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=l1.location_cd
    AND cv3.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg2.child_loc_cd
    AND l2.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=lg2.parent_loc_cd
    AND cv2.active_ind=1)
   JOIN (l3
   WHERE l3.location_cd=cv2.code_value
    AND l3.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND cv.active_ind=1)
   JOIN (sr
   WHERE sr.location_cd=outerjoin(lg1.child_loc_cd)
    AND sr.pharmacy_type_cd=outerjoin(inpatient_code_value)
    AND sr.activity_type_cd=outerjoin(pharm_code_value)
    AND sr.active_ind=outerjoin(1))
   JOIN (sp
   WHERE sp.service_resource_cd=outerjoin(sr.service_resource_cd))
  ORDER BY d.seq, lg2.parent_loc_cd, lg2.child_loc_cd
  HEAD d.seq
   fcnt = 0, ftcnt = 0, stat = alterlist(reply->items[d.seq].facilities,10)
  HEAD lg2.parent_loc_cd
   fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
   IF (fcnt > 10)
    stat = alterlist(reply->items[d.seq].facilities,(ftcnt+ 10)), fcnt = 1
   ENDIF
   reply->items[d.seq].facilities[ftcnt].code_value = lg2.parent_loc_cd, reply->items[d.seq].
   facilities[ftcnt].display = cv2.display, reply->items[d.seq].facilities[ftcnt].description = cv2
   .description,
   bcnt = 0, blcnt = 0, stat = alterlist(reply->items[d.seq].facilities[ftcnt].buildings,10)
  HEAD lg2.child_loc_cd
   bcnt = (bcnt+ 1), blcnt = (blcnt+ 1)
   IF (blcnt > 10)
    stat = alterlist(reply->items[d.seq].facilities[ftcnt].buildings,(bcnt+ 10)), blcnt = 1
   ENDIF
   reply->items[d.seq].facilities[ftcnt].buildings[bcnt].code_value = lg2.child_loc_cd, reply->items[
   d.seq].facilities[ftcnt].buildings[bcnt].display = cv.display, reply->items[d.seq].facilities[
   ftcnt].buildings[bcnt].description = cv.description,
   pcnt = 0, plcnt = 0, ncnt = 0,
   nlcnt = 0, stat = alterlist(reply->items[d.seq].facilities[ftcnt].buildings[bcnt].nursing_units,10
    ), stat = alterlist(reply->items[d.seq].facilities[ftcnt].buildings[bcnt].pharmacies,10)
  DETAIL
   IF (cv3.cdf_meaning="PHARM"
    AND sp.floorstock_ind=0)
    pcnt = (pcnt+ 1), plcnt = (plcnt+ 1)
    IF (plcnt > 10)
     stat = alterlist(reply->items[d.seq].facilities[ftcnt].buildings[bcnt].pharmacies,(pcnt+ 10)),
     plcnt = 1
    ENDIF
    reply->items[d.seq].facilities[ftcnt].buildings[bcnt].pharmacies[pcnt].code_value = lg1
    .child_loc_cd, reply->items[d.seq].facilities[ftcnt].buildings[bcnt].pharmacies[pcnt].display =
    cv3.display, reply->items[d.seq].facilities[ftcnt].buildings[bcnt].pharmacies[pcnt].description
     = cv.description
   ELSEIF (((cv3.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")) OR (cv3.cdf_meaning="PHARM"
    AND sp.floorstock_ind=1)) )
    ncnt = (ncnt+ 1), nlcnt = (nlcnt+ 1)
    IF (nlcnt > 10)
     stat = alterlist(reply->items[d.seq].facilities[ftcnt].buildings[bcnt].nursing_units,(ncnt+ 10)),
     nlcnt = 1
    ENDIF
    reply->items[d.seq].facilities[ftcnt].buildings[bcnt].nursing_units[ncnt].code_value = lg1
    .child_loc_cd, reply->items[d.seq].facilities[ftcnt].buildings[bcnt].nursing_units[ncnt].display
     = cv3.display, reply->items[d.seq].facilities[ftcnt].buildings[bcnt].nursing_units[ncnt].
    description = cv3.description
   ENDIF
  FOOT  lg2.child_loc_cd
   stat = alterlist(reply->items[d.seq].facilities[ftcnt].buildings[bcnt].pharmacies,pcnt), stat =
   alterlist(reply->items[d.seq].facilities[ftcnt].buildings[bcnt].nursing_units,ncnt)
  FOOT  lg2.parent_loc_cd
   stat = alterlist(reply->items[d.seq].facilities[ftcnt].buildings,bcnt)
  FOOT  d.seq
   stat = alterlist(reply->items[d.seq].facilities,ftcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(brreq)),
   (dummyt d2  WITH seq = 1),
   stored_at s,
   location_group lg1,
   location_group lg2,
   location l1,
   location l2,
   location l3,
   code_value cv,
   service_resource sr,
   serv_res_ext_pharm sp,
   code_value cv2
  PLAN (d
   WHERE maxrec(d2,size(reply->items[d.seq].facilities,5))
    AND (reply->items[d.seq].all_facilities_ind=0))
   JOIN (d2)
   JOIN (s
   WHERE (s.item_id=reply->items[d.seq].item_id))
   JOIN (lg1
   WHERE lg1.child_loc_cd=s.location_cd
    AND ((lg1.location_group_type_cd+ 0)=building_code_value)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND ((lg2.location_group_type_cd+ 0)=fac_code_value)
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1
    AND (lg2.parent_loc_cd=reply->items[d.seq].facilities[d2.seq].code_value))
   JOIN (l1
   WHERE l1.location_cd=lg1.child_loc_cd
    AND l1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=l1.location_cd
    AND cv2.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg2.child_loc_cd
    AND l2.active_ind=1)
   JOIN (l3
   WHERE l3.location_cd=lg2.parent_loc_cd
    AND l3.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND cv.active_ind=1)
   JOIN (sr
   WHERE sr.location_cd=outerjoin(lg1.child_loc_cd)
    AND sr.pharmacy_type_cd=outerjoin(inpatient_code_value)
    AND sr.activity_type_cd=outerjoin(pharm_code_value)
    AND sr.active_ind=outerjoin(1))
   JOIN (sp
   WHERE sp.service_resource_cd=outerjoin(sr.service_resource_cd))
  ORDER BY d.seq, d2.seq, lg2.child_loc_cd
  HEAD d.seq
   tempdcnt = 1
  HEAD d2.seq
   bcnt = 0, blcnt = 0, stat = alterlist(reply->items[d.seq].facilities[d2.seq].buildings,10)
  HEAD lg2.child_loc_cd
   bcnt = (bcnt+ 1), blcnt = (blcnt+ 1)
   IF (blcnt > 10)
    stat = alterlist(reply->items[d.seq].facilities[d2.seq].buildings,(bcnt+ 10)), blcnt = 1
   ENDIF
   reply->items[d.seq].facilities[d2.seq].buildings[bcnt].code_value = lg2.child_loc_cd, reply->
   items[d.seq].facilities[d2.seq].buildings[bcnt].display = cv.display, reply->items[d.seq].
   facilities[d2.seq].buildings[bcnt].description = cv.description,
   pcnt = 0, plcnt = 0, ncnt = 0,
   nlcnt = 0, stat = alterlist(reply->items[d.seq].facilities[d2.seq].buildings[bcnt].nursing_units,
    10), stat = alterlist(reply->items[d.seq].facilities[d2.seq].buildings[bcnt].pharmacies,10)
  DETAIL
   IF (cv2.cdf_meaning="PHARM"
    AND sp.floorstock_ind=0)
    pcnt = (pcnt+ 1), plcnt = (plcnt+ 1)
    IF (plcnt > 10)
     stat = alterlist(reply->items[d.seq].facilities[d2.seq].buildings[bcnt].pharmacies,(pcnt+ 10)),
     plcnt = 1
    ENDIF
    reply->items[d.seq].facilities[d2.seq].buildings[bcnt].pharmacies[pcnt].code_value = lg1
    .child_loc_cd, reply->items[d.seq].facilities[d2.seq].buildings[bcnt].pharmacies[pcnt].display =
    cv2.display, reply->items[d.seq].facilities[d2.seq].buildings[bcnt].pharmacies[pcnt].description
     = cv2.description
   ELSEIF (((cv2.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")) OR (cv2.cdf_meaning="PHARM"
    AND sp.floorstock_ind=1)) )
    ncnt = (ncnt+ 1), nlcnt = (nlcnt+ 1)
    IF (nlcnt > 10)
     stat = alterlist(reply->items[d.seq].facilities[d2.seq].buildings[bcnt].nursing_units,(ncnt+ 10)
      ), nlcnt = 1
    ENDIF
    reply->items[d.seq].facilities[d2.seq].buildings[bcnt].nursing_units[ncnt].code_value = lg1
    .child_loc_cd, reply->items[d.seq].facilities[d2.seq].buildings[bcnt].nursing_units[ncnt].display
     = cv2.display, reply->items[d.seq].facilities[d2.seq].buildings[bcnt].nursing_units[ncnt].
    description = cv2.description
   ENDIF
  FOOT  lg2.child_loc_cd
   stat = alterlist(reply->items[d.seq].facilities[d2.seq].buildings[bcnt].pharmacies,pcnt), stat =
   alterlist(reply->items[d.seq].facilities[d2.seq].buildings[bcnt].nursing_units,ncnt)
  FOOT  d2.seq
   stat = alterlist(reply->items[d.seq].facilities[d2.seq].buildings,bcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_dispense mdisp,
   (dummyt d  WITH seq = value(brreq))
  PLAN (d)
   JOIN (mdf
   WHERE (mdf.item_id=reply->items[d.seq].item_id)
    AND mdf.flex_type_cd=system_package_code_value
    AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
    AND ((mdf.sequence+ 0)=0)
    AND ((mdf.med_def_flex_id+ 0) != 0)
    AND ((mdf.active_ind+ 0)=1))
   JOIN (mfoi
   WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
    AND mfoi.flex_object_type_cd=med_dispense_code_value
    AND ((mfoi.parent_entity_id+ 0) != 0)
    AND ((mfoi.sequence+ 0)=1)
    AND ((mfoi.active_ind+ 0)=1))
   JOIN (mdisp
   WHERE (mdisp.med_dispense_id=(mfoi.parent_entity_id+ 0)))
  ORDER BY d.seq
  DETAIL
   reply->items[d.seq].reuse_ind = mdisp.reusable_ind, reply->items[d.seq].dispense_from_flag = mdisp
   .always_dispense_from_flag
  WITH nocounter
 ;end select
#exit_script
 IF (brreq > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
