CREATE PROGRAM bed_get_locs_for_meanful_use:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 buildings[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 units[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
         4 mean = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 FREE SET valid_facs
 RECORD valid_facs(
   1 facs[*]
     2 code_value = f8
 )
 SET fac_cd = 0.0
 SET bldg_cd = 0.0
 SET nurse_cd = 0.0
 SET amb_cd = 0.0
 SET surg_cd = 0.0
 SET pharm_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("FACILITY", "BUILDING", "NURSEUNIT", "AMBULATORY", "ANCILSURG",
  "PHARM")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="FACILITY")
    fac_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BUILDING")
    bldg_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="NURSEUNIT")
    nurse_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="AMBULATORY")
    amb_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ANCILSURG")
    surg_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PHARM")
    pharm_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE fac_name_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_string) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtupper(request->search_string)),"*")
  ELSE
   SET search_string = concat("*",trim(cnvtupper(request->search_string)),"*")
  ENDIF
  IF ((request->search_field=1))
   SET fac_name_parse = concat("cnvtupper(cv3.display) = '",search_string,"'")
  ELSE
   SET fac_name_parse = concat("cnvtupper(cv3.description) = '",search_string,"'")
  ENDIF
 ELSE
  SET search_string = "*"
  IF ((request->search_field=1))
   SET fac_name_parse = concat("cnvtupper(cv3.display) = '",search_string,"'")
  ELSE
   SET fac_name_parse = concat("cnvtupper(cv3.description) = '",search_string,"'")
  ENDIF
 ENDIF
 SET valid_fac_cnt = 0
 IF ((request->only_locs_without_ccn_ind=1))
  SELECT INTO "nl:"
   FROM location l,
    code_value cv1,
    location_group lg1,
    code_value cv2,
    location_group lg2,
    code_value cv3
   PLAN (l
    WHERE l.location_type_cd IN (nurse_cd, amb_cd, surg_cd, pharm_cd)
     AND l.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=l.location_cd
     AND cv1.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     b.location_cd
     FROM br_ccn_loc_reltn b
     WHERE b.location_cd=l.location_cd
      AND b.active_ind=1
      AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)))))
    JOIN (lg1
    WHERE lg1.child_loc_cd=l.location_cd
     AND lg1.location_group_type_cd=bldg_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=lg1.parent_loc_cd
     AND cv2.active_ind=1)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg1.parent_loc_cd
     AND lg2.location_group_type_cd=fac_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1)
    JOIN (cv3
    WHERE cv3.code_value=lg2.parent_loc_cd
     AND cv3.active_ind=1
     AND parser(fac_name_parse))
   DETAIL
    found_ind = 0, start = 1, num = 0
    IF (valid_fac_cnt > 0)
     found_ind = locateval(num,start,valid_fac_cnt,cv3.code_value,valid_facs->facs[num].code_value)
    ENDIF
    IF (found_ind=0)
     valid_fac_cnt = (valid_fac_cnt+ 1), stat = alterlist(valid_facs->facs,valid_fac_cnt), valid_facs
     ->facs[valid_fac_cnt].code_value = cv3.code_value
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM location l,
    code_value cv1,
    location_group lg1,
    code_value cv2,
    location_group lg2,
    code_value cv3
   PLAN (l
    WHERE l.location_type_cd IN (nurse_cd, amb_cd, surg_cd, pharm_cd)
     AND l.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=l.location_cd
     AND cv1.active_ind=1)
    JOIN (lg1
    WHERE lg1.child_loc_cd=l.location_cd
     AND lg1.location_group_type_cd=bldg_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=lg1.parent_loc_cd
     AND cv2.active_ind=1)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg1.parent_loc_cd
     AND lg2.location_group_type_cd=fac_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1)
    JOIN (cv3
    WHERE cv3.code_value=lg2.parent_loc_cd
     AND cv3.active_ind=1
     AND parser(fac_name_parse))
   DETAIL
    found_ind = 0, start = 1, num = 0
    IF (valid_fac_cnt > 0)
     found_ind = locateval(num,start,valid_fac_cnt,cv3.code_value,valid_facs->facs[num].code_value)
    ENDIF
    IF (found_ind=0)
     valid_fac_cnt = (valid_fac_cnt+ 1), stat = alterlist(valid_facs->facs,valid_fac_cnt), valid_facs
     ->facs[valid_fac_cnt].code_value = cv3.code_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->max_reply > 0)
  AND (valid_fac_cnt > request->max_reply))
  SET reply->too_many_results_ind = 1
  GO TO exit_script
 ENDIF
 IF (valid_fac_cnt > 0)
  SET fcnt = 0
  IF ((request->only_locs_without_ccn_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = valid_fac_cnt),
     location_group lg1,
     code_value cv1,
     location_group lg2,
     code_value cv2,
     location l,
     code_value cv3
    PLAN (d)
     JOIN (lg1
     WHERE (lg1.parent_loc_cd=valid_facs->facs[d.seq].code_value)
      AND lg1.location_group_type_cd=fac_cd
      AND lg1.root_loc_cd=0
      AND lg1.active_ind=1)
     JOIN (cv1
     WHERE cv1.code_value=lg1.parent_loc_cd
      AND cv1.active_ind=1)
     JOIN (lg2
     WHERE lg2.parent_loc_cd=lg1.child_loc_cd
      AND lg2.location_group_type_cd=bldg_cd
      AND lg2.root_loc_cd=0
      AND lg2.active_ind=1)
     JOIN (cv2
     WHERE cv2.code_value=lg2.parent_loc_cd
      AND cv2.active_ind=1)
     JOIN (l
     WHERE l.location_cd=lg2.child_loc_cd
      AND l.location_type_cd IN (nurse_cd, amb_cd, surg_cd, pharm_cd)
      AND l.active_ind=1)
     JOIN (cv3
     WHERE cv3.code_value=l.location_cd
      AND cv3.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      b.location_cd
      FROM br_ccn_loc_reltn b
      WHERE b.location_cd=l.location_cd
       AND b.active_ind=1
       AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)))))
    ORDER BY cv1.code_value, cv2.code_value, cv3.code_value
    HEAD cv1.code_value
     fcnt = (fcnt+ 1), stat = alterlist(reply->facilities,fcnt), reply->facilities[fcnt].code_value
      = cv1.code_value,
     reply->facilities[fcnt].display = cv1.display, reply->facilities[fcnt].description = cv1
     .description, bcnt = 0
    HEAD cv2.code_value
     bcnt = (bcnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings,bcnt), reply->facilities[
     fcnt].buildings[bcnt].code_value = cv2.code_value,
     reply->facilities[fcnt].buildings[bcnt].display = cv2.display, reply->facilities[fcnt].
     buildings[bcnt].description = cv2.description, ucnt = 0
    HEAD cv3.code_value
     ucnt = (ucnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings[bcnt].units,ucnt), reply->
     facilities[fcnt].buildings[bcnt].units[ucnt].code_value = cv3.code_value,
     reply->facilities[fcnt].buildings[bcnt].units[ucnt].display = cv3.display, reply->facilities[
     fcnt].buildings[bcnt].units[ucnt].description = cv3.description, reply->facilities[fcnt].
     buildings[bcnt].units[ucnt].mean = cv3.cdf_meaning
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = valid_fac_cnt),
     location_group lg1,
     code_value cv1,
     location_group lg2,
     code_value cv2,
     location l,
     code_value cv3
    PLAN (d)
     JOIN (lg1
     WHERE (lg1.parent_loc_cd=valid_facs->facs[d.seq].code_value)
      AND lg1.location_group_type_cd=fac_cd
      AND lg1.root_loc_cd=0
      AND lg1.active_ind=1)
     JOIN (cv1
     WHERE cv1.code_value=lg1.parent_loc_cd
      AND cv1.active_ind=1)
     JOIN (lg2
     WHERE lg2.parent_loc_cd=lg1.child_loc_cd
      AND lg2.location_group_type_cd=bldg_cd
      AND lg2.root_loc_cd=0
      AND lg2.active_ind=1)
     JOIN (cv2
     WHERE cv2.code_value=lg2.parent_loc_cd
      AND cv2.active_ind=1)
     JOIN (l
     WHERE l.location_cd=lg2.child_loc_cd
      AND l.location_type_cd IN (nurse_cd, amb_cd, surg_cd, pharm_cd)
      AND l.active_ind=1)
     JOIN (cv3
     WHERE cv3.code_value=l.location_cd
      AND cv3.active_ind=1)
    ORDER BY cv1.code_value, cv2.code_value, cv3.code_value
    HEAD cv1.code_value
     fcnt = (fcnt+ 1), stat = alterlist(reply->facilities,fcnt), reply->facilities[fcnt].code_value
      = cv1.code_value,
     reply->facilities[fcnt].display = cv1.display, reply->facilities[fcnt].description = cv1
     .description, bcnt = 0
    HEAD cv2.code_value
     bcnt = (bcnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings,bcnt), reply->facilities[
     fcnt].buildings[bcnt].code_value = cv2.code_value,
     reply->facilities[fcnt].buildings[bcnt].display = cv2.display, reply->facilities[fcnt].
     buildings[bcnt].description = cv2.description, ucnt = 0
    HEAD cv3.code_value
     ucnt = (ucnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings[bcnt].units,ucnt), reply->
     facilities[fcnt].buildings[bcnt].units[ucnt].code_value = cv3.code_value,
     reply->facilities[fcnt].buildings[bcnt].units[ucnt].display = cv3.display, reply->facilities[
     fcnt].buildings[bcnt].units[ucnt].description = cv3.description, reply->facilities[fcnt].
     buildings[bcnt].units[ucnt].mean = cv3.cdf_meaning
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
