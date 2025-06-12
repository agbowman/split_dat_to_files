CREATE PROGRAM bed_get_fac_with_amb:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 display = vc
     2 code_value = f8
     2 description = vc
     2 buildings[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
       3 units[*]
         4 code_value = f8
         4 display = vc
         4 mean = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 RECORD temp(
   1 flist[*]
     2 fac_display = vc
     2 fac_code_value = f8
     2 fac_desc = vc
     2 with_amb_ind = i2
     2 buildings[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
       3 units[*]
         4 code_value = f8
         4 display = vc
         4 mean = vc
 )
 SET reply->status_data.status = "F"
 SET max_cnt = 0
 IF (validate(request->max_reply))
  SET max_cnt = request->max_reply
 ENDIF
 SET facs_in_request = 0
 IF (validate(request->facilities))
  SET facs_in_request = size(request->facilities,5)
 ENDIF
 IF (facs_in_request=0)
  SET wcard = "*"
  DECLARE fac_name_parse = vc
  DECLARE search_string = vc
  IF (trim(request->search_txt) > " ")
   IF ((request->search_type_flag="S"))
    SET search_string = concat(trim(cnvtalphanum(cnvtupper(request->search_txt))),wcard)
   ELSE
    SET search_string = concat(wcard,trim(cnvtalphanum(cnvtupper(request->search_txt))),wcard)
   ENDIF
   SET fac_name_parse = concat("cnvtupper(cv.display_key) = '",search_string,"'")
  ELSE
   SET search_string = wcard
   SET fac_name_parse = concat("cnvtupper(cv.display_key) = '",search_string,"'")
  ENDIF
 ENDIF
 DECLARE error_msg = vc
 SET fac_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="FACILITY")
  ORDER BY cv.code_value
  HEAD cv.code_value
   fac_cd = cv.code_value
  WITH nocounter
 ;end select
 SET bld_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="BUILDING")
  ORDER BY cv.code_value
  HEAD cv.code_value
   bld_cd = cv.code_value
  WITH nocounter
 ;end select
 SET amb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="AMBULATORY")
  ORDER BY cv.code_value
  HEAD cv.code_value
   amb_cd = cv.code_value
  WITH nocounter
 ;end select
 SET fcnt = 0
 SET rcnt = 0
 IF (facs_in_request=0)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND parser(fac_name_parse)
     AND cv.active_ind=1)
   ORDER BY cv.display_key
   HEAD REPORT
    fcnt = 0
   DETAIL
    fcnt = (fcnt+ 1), stat = alterlist(temp->flist,fcnt), temp->flist[fcnt].fac_code_value = cv
    .code_value,
    temp->flist[fcnt].fac_display = cv.display, temp->flist[fcnt].fac_desc = cv.description, temp->
    flist[fcnt].with_amb_ind = 0
   WITH nocounter
  ;end select
  IF (fcnt=0)
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = facs_in_request),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=request->facilities[d.seq].code_value))
   ORDER BY cv.display_key
   DETAIL
    fcnt = (fcnt+ 1), stat = alterlist(temp->flist,fcnt), temp->flist[fcnt].fac_code_value = cv
    .code_value,
    temp->flist[fcnt].fac_display = cv.display, temp->flist[fcnt].fac_desc = cv.description, temp->
    flist[fcnt].with_amb_ind = 0
   WITH nocounter
  ;end select
 ENDIF
 SET alter_ind = 0
 SET only_wo_trk_grp_ind = 0
 IF (validate(request->only_return_wo_trk_grp_ind))
  IF ((request->only_return_wo_trk_grp_ind=1))
   SET only_wo_trk_grp_ind = 1
  ENDIF
 ENDIF
 IF (only_wo_trk_grp_ind=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = fcnt),
    location_group lg1,
    location_group lg2,
    location l,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (lg1
    WHERE (lg1.parent_loc_cd=temp->flist[d.seq].fac_code_value)
     AND lg1.location_group_type_cd=fac_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1)
    JOIN (lg2
    WHERE lg2.parent_loc_cd=lg1.child_loc_cd
     AND lg2.location_group_type_cd=bld_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1)
    JOIN (l
    WHERE l.location_cd=lg2.child_loc_cd
     AND l.location_type_cd=amb_cd
     AND l.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     tg.tracking_group_cd
     FROM track_group tg
     WHERE tg.child_table="TRACK_ASSOC"
      AND tg.parent_value=l.location_cd))))
    JOIN (cv1
    WHERE cv1.code_value=lg2.parent_loc_cd
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=l.location_cd
     AND cv2.active_ind=1)
   ORDER BY d.seq, lg2.parent_loc_cd
   HEAD d.seq
    bcnt = 0
   HEAD lg2.parent_loc_cd
    bcnt = (bcnt+ 1), stat = alterlist(temp->flist[d.seq].buildings,bcnt), temp->flist[d.seq].
    buildings[bcnt].code_value = lg2.parent_loc_cd,
    temp->flist[d.seq].buildings[bcnt].display = cv1.display, temp->flist[d.seq].buildings[bcnt].mean
     = cv1.cdf_meaning, ucnt = 0
   DETAIL
    ucnt = (ucnt+ 1), stat = alterlist(temp->flist[d.seq].buildings[bcnt].units,ucnt), temp->flist[d
    .seq].buildings[bcnt].units[ucnt].code_value = l.location_cd,
    temp->flist[d.seq].buildings[bcnt].units[ucnt].display = cv2.display, temp->flist[d.seq].
    buildings[bcnt].units[ucnt].mean = cv2.cdf_meaning, temp->flist[d.seq].with_amb_ind = 1,
    alter_ind = 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = fcnt),
    location_group lg1,
    location_group lg2,
    location l
   PLAN (d)
    JOIN (lg1
    WHERE (lg1.parent_loc_cd=temp->flist[d.seq].fac_code_value)
     AND lg1.location_group_type_cd=fac_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1)
    JOIN (lg2
    WHERE lg2.parent_loc_cd=lg1.child_loc_cd
     AND lg2.location_group_type_cd=bld_cd
     AND lg2.root_loc_cd=0
     AND lg2.active_ind=1)
    JOIN (l
    WHERE l.location_cd=lg2.child_loc_cd
     AND l.location_type_cd=amb_cd
     AND l.active_ind=1)
   DETAIL
    temp->flist[d.seq].with_amb_ind = 1, alter_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (alter_ind=1)
  SET stat = alterlist(reply->facilities,fcnt)
 ENDIF
 SET rcnt = 0
 FOR (x = 1 TO fcnt)
   IF ((temp->flist[x].with_amb_ind=1))
    SET rcnt = (rcnt+ 1)
    SET reply->facilities[rcnt].code_value = temp->flist[x].fac_code_value
    SET reply->facilities[rcnt].display = temp->flist[x].fac_display
    SET reply->facilities[rcnt].description = temp->flist[x].fac_desc
    SET bcnt = size(temp->flist[x].buildings,5)
    SET stat = alterlist(reply->facilities[rcnt].buildings,bcnt)
    FOR (b = 1 TO bcnt)
      SET reply->facilities[rcnt].buildings[b].code_value = temp->flist[x].buildings[b].code_value
      SET reply->facilities[rcnt].buildings[b].display = temp->flist[x].buildings[b].display
      SET reply->facilities[rcnt].buildings[b].mean = temp->flist[x].buildings[b].mean
      SET ucnt = size(temp->flist[x].buildings[b].units,5)
      SET stat = alterlist(reply->facilities[rcnt].buildings[b].units,ucnt)
      FOR (u = 1 TO ucnt)
        SET reply->facilities[rcnt].buildings[b].units[u].code_value = temp->flist[x].buildings[b].
        units[u].code_value
        SET reply->facilities[rcnt].buildings[b].units[u].display = temp->flist[x].buildings[b].
        units[u].display
        SET reply->facilities[rcnt].buildings[b].units[u].mean = temp->flist[x].buildings[b].units[u]
        .mean
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 IF (rcnt > 0)
  SET stat = alterlist(reply->facilities,rcnt)
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF (max_cnt > 0
  AND rcnt > max_cnt)
  SET stat = alterlist(reply->facilities,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->error_msg = error_msg
 CALL echorecord(reply)
END GO
