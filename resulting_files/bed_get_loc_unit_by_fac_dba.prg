CREATE PROGRAM bed_get_loc_unit_by_fac:dba
 FREE SET reply
 RECORD reply(
   1 fac_list[*]
     2 code_value = f8
     2 display = vc
     2 prefix = vc
     2 buildings[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 units[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
         4 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_fac_cnt = size(request->fac_list,5)
 SET stat = alterlist(reply->fac_list,20)
 SET fac_cnt = 0
 SET fac_tot_cnt = 0
 SET bld_cnt = 0
 SET bld_tot_cnt = 0
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="FACILITY"
  DETAIL
   facility_cd = c.code_value
  WITH nocounter
 ;end select
 IF (req_fac_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = req_fac_cnt),
    location_group lg,
    location_group lg2,
    location l,
    code_value cv,
    code_value cv2
   PLAN (d)
    JOIN (lg
    WHERE (lg.parent_loc_cd=request->fac_list[d.seq].code_value)
     AND lg.active_ind=1
     AND lg.root_loc_cd=0)
    JOIN (cv2
    WHERE (cv2.code_value=request->fac_list[d.seq].code_value))
    JOIN (lg2
    WHERE lg2.parent_loc_cd=lg.child_loc_cd
     AND lg2.active_ind=1
     AND lg2.root_loc_cd=0)
    JOIN (l
    WHERE l.location_cd=lg2.child_loc_cd
     AND l.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     tg.tracking_group_cd
     FROM track_group tg
     WHERE tg.child_table="TRACK_ASSOC"
      AND tg.parent_value=l.location_cd))))
    JOIN (cv
    WHERE cv.code_value=l.location_cd
     AND cv.cdf_meaning="AMBULATORY")
   ORDER BY d.seq, cv2.display_key, lg.child_loc_cd,
    cv.display_key
   HEAD d.seq
    fac_cnt = (fac_cnt+ 1), fac_tot_cnt = (fac_tot_cnt+ 1)
    IF (fac_cnt > 20)
     stat = alterlist(reply->fac_list,(fac_tot_cnt+ 20)), fac_cnt = 1
    ENDIF
    reply->fac_list[fac_tot_cnt].code_value = request->fac_list[d.seq].code_value, reply->fac_list[
    fac_tot_cnt].display = cv2.display, bld_cnt = 0,
    bld_tot_cnt = 0, stat = alterlist(reply->fac_list[fac_tot_cnt].buildings,10)
   HEAD lg.child_loc_cd
    bld_cnt = (bld_cnt+ 1), bld_tot_cnt = (bld_tot_cnt+ 1)
    IF (bld_cnt > 10)
     stat = alterlist(reply->fac_list[fac_tot_cnt].buildings,(bld_tot_cnt+ 10)), bld_cnt = 1
    ENDIF
    reply->fac_list[fac_tot_cnt].buildings[bld_tot_cnt].code_value = lg.child_loc_cd, cnt = 0,
    tot_cnt = 0,
    stat = alterlist(reply->fac_list[fac_tot_cnt].buildings[bld_tot_cnt].units,10)
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->fac_list[fac_tot_cnt].buildings[bld_tot_cnt].units,(tot_cnt+ 10)), cnt
      = 1
    ENDIF
    reply->fac_list[fac_tot_cnt].buildings[bld_tot_cnt].units[tot_cnt].code_value = l.location_cd,
    reply->fac_list[fac_tot_cnt].buildings[bld_tot_cnt].units[tot_cnt].display = cv.display, reply->
    fac_list[fac_tot_cnt].buildings[bld_tot_cnt].units[tot_cnt].description = cv.description,
    reply->fac_list[fac_tot_cnt].buildings[bld_tot_cnt].units[tot_cnt].mean = cv.cdf_meaning
   FOOT  lg.child_loc_cd
    stat = alterlist(reply->fac_list[fac_tot_cnt].buildings[bld_tot_cnt].units,tot_cnt)
   FOOT  d.seq
    stat = alterlist(reply->fac_list[fac_tot_cnt].buildings,bld_tot_cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->fac_list,fac_tot_cnt)
 FOR (i = 1 TO fac_tot_cnt)
  SET bcnt = size(reply->fac_list[i].buildings,5)
  IF (bcnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = bcnt),
     code_value cv
    PLAN (d)
     JOIN (cv
     WHERE (cv.code_value=reply->fac_list[i].buildings[d.seq].code_value))
    DETAIL
     reply->fac_list[i].buildings[d.seq].display = cv.display, reply->fac_list[i].buildings[d.seq].
     description = cv.description
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 IF (fac_tot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = fac_tot_cnt),
    location l,
    organization o,
    br_organization b
   PLAN (d)
    JOIN (l
    WHERE (l.location_cd=reply->fac_list[d.seq].code_value)
     AND l.location_type_cd=facility_cd)
    JOIN (o
    WHERE o.organization_id=l.organization_id)
    JOIN (b
    WHERE b.organization_id=l.organization_id)
   DETAIL
    reply->fac_list[d.seq].prefix = b.br_prefix
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (fac_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
