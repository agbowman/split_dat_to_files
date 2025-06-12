CREATE PROGRAM bed_get_sn_inv_loc_parents:dba
 FREE SET reply
 RECORD reply(
   1 views[*]
     2 code_value = f8
     2 display = vc
     2 facility
       3 code_value = f8
       3 display = vc
       3 meaning = vc
     2 building
       3 code_value = f8
       3 display = vc
       3 meaning = vc
     2 surgery_area
       3 code_value = f8
       3 display = vc
       3 meaning = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_root
 RECORD temp_root(
   1 roots[*]
     2 root_cd = f8
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SET facility_code_value = 0.0
 SET building_code_value = 0.0
 SET surgery_code_value = 0.0
 SET view_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="FACILITY"
   AND cv.code_set=222
   AND cv.active_ind=1
  DETAIL
   facility_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="BUILDING"
   AND cv.code_set=222
   AND cv.active_ind=1
  DETAIL
   building_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="ANCILSURG"
   AND cv.code_set=222
   AND cv.active_ind=1
  DETAIL
   surgery_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="INVVIEW"
   AND cv.code_set=222
   AND cv.active_ind=1
  DETAIL
   view_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM location_group lg,
   code_value cv,
   location_group lg2
  PLAN (lg
   WHERE (lg.child_loc_cd=request->inv_location_code_value)
    AND lg.location_group_type_cd IN (surgery_code_value, building_code_value, facility_code_value)
    AND lg.root_loc_cd > 0
    AND lg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg.parent_loc_cd
    AND cv.active_ind=1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg.root_loc_cd
    AND lg2.location_group_type_cd=view_code_value
    AND lg2.active_ind=1)
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->views,100),
   stat = alterlist(temp_root->roots,100)
  DETAIL
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->views,(cnt+ 100)), stat = alterlist(temp_root->roots,(cnt+ 100)),
    list_cnt = 1
   ENDIF
   temp_root->roots[cnt].root_cd = lg.root_loc_cd
   IF (lg.location_group_type_cd=facility_code_value)
    reply->views[cnt].facility.code_value = cv.code_value, reply->views[cnt].facility.display = cv
    .display, reply->views[cnt].facility.meaning = cv.cdf_meaning
   ELSEIF (lg.location_group_type_cd=building_code_value)
    reply->views[cnt].building.code_value = cv.code_value, reply->views[cnt].building.display = cv
    .display, reply->views[cnt].building.meaning = cv.cdf_meaning
   ELSEIF (lg.location_group_type_cd=surgery_code_value)
    reply->views[cnt].surgery_area.code_value = cv.code_value, reply->views[cnt].surgery_area.display
     = cv.display, reply->views[cnt].surgery_area.meaning = cv.cdf_meaning
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->views,cnt), stat = alterlist(temp_root->roots,cnt)
  WITH nocoutner
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    location_group lg,
    code_value cv
   PLAN (d
    WHERE (reply->views[d.seq].surgery_area.code_value > 0))
    JOIN (lg
    WHERE (lg.child_loc_cd=reply->views[d.seq].surgery_area.code_value)
     AND lg.location_group_type_cd=building_code_value
     AND (lg.root_loc_cd=temp_root->roots[d.seq].root_cd))
    JOIN (cv
    WHERE cv.code_value=lg.parent_loc_cd
     AND cv.active_ind=1)
   DETAIL
    reply->views[d.seq].building.code_value = cv.code_value, reply->views[d.seq].building.display =
    cv.display, reply->views[d.seq].building.meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    location_group lg,
    code_value cv
   PLAN (d
    WHERE (reply->views[d.seq].building.code_value > 0))
    JOIN (lg
    WHERE (lg.child_loc_cd=reply->views[d.seq].building.code_value)
     AND lg.location_group_type_cd=facility_code_value
     AND (lg.root_loc_cd=temp_root->roots[d.seq].root_cd))
    JOIN (cv
    WHERE cv.code_value=lg.parent_loc_cd
     AND cv.active_ind=1)
   DETAIL
    reply->views[d.seq].facility.code_value = cv.code_value, reply->views[d.seq].facility.display =
    cv.display, reply->views[d.seq].facility.meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    location_group lg,
    code_value cv
   PLAN (d
    WHERE (reply->views[d.seq].facility.code_value > 0))
    JOIN (lg
    WHERE (lg.child_loc_cd=reply->views[d.seq].facility.code_value)
     AND lg.location_group_type_cd=view_code_value
     AND (lg.root_loc_cd=temp_root->roots[d.seq].root_cd))
    JOIN (cv
    WHERE cv.code_value=lg.parent_loc_cd
     AND cv.active_ind=1)
   DETAIL
    reply->views[d.seq].code_value = cv.code_value, reply->views[d.seq].display = cv.display, reply->
    views[d.seq].meaning = cv.cdf_meaning
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
