CREATE PROGRAM bed_get_fn_facility:dba
 FREE SET reply
 RECORD reply(
   1 flist[*]
     2 facility_code_value = f8
     2 facility_display = vc
     2 facility_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD loc(
   1 cnt = i2
   1 qual[*]
     2 cd = f8
 )
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 cd = f8
 )
 RECORD temp2(
   1 cnt = i2
   1 qual[*]
     2 cd = f8
 )
 RECORD bld(
   1 cnt = i2
   1 qual[*]
     2 cd = f8
 )
 SET reply->status_data.status = "F"
 SET wcard = "*"
 DECLARE fac_name_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_txt) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtalphanum(cnvtupper(request->search_txt))),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtalphanum(cnvtupper(request->search_txt))),wcard)
  ENDIF
  SET fac_name_parse = concat("cnvtupper(cv.description) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET fac_name_parse = concat("cnvtupper(cv.display_key) = '",search_string,"'")
 ENDIF
 SELECT INTO "nl:"
  FROM track_group tg,
   code_value cv
  PLAN (tg
   WHERE tg.parent_value > 0
    AND tg.child_value=0
    AND tg.child_table="TRACK_ASSOC")
   JOIN (cv
   WHERE cv.code_value=tg.tracking_group_cd
    AND cv.cdf_meaning="ER")
  ORDER BY tg.parent_value
  HEAD REPORT
   cnt = 0
  HEAD tg.parent_value
   cnt = (cnt+ 1), loc->cnt = cnt, stat = alterlist(loc->qual,cnt),
   loc->qual[cnt].cd = tg.parent_value
  WITH nocounter
 ;end select
 SET bcnt = 0
 IF ((loc->cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loc->cnt)),
    location_group lg,
    code_value cv
   PLAN (d)
    JOIN (lg
    WHERE (lg.child_loc_cd=loc->qual[d.seq].cd)
     AND lg.root_loc_cd=0
     AND lg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=lg.location_group_type_cd)
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cv.cdf_meaning="BUILDING")
     bcnt = (bcnt+ 1), bld->cnt = bcnt, stat = alterlist(bld->qual,bcnt),
     bld->qual[bcnt].cd = lg.parent_loc_cd
    ELSE
     cnt = (cnt+ 1), temp->cnt = cnt, stat = alterlist(temp->qual,cnt),
     temp->qual[cnt].cd = lg.parent_loc_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((temp->cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp->cnt)),
    location_group lg,
    code_value cv
   PLAN (d)
    JOIN (lg
    WHERE (lg.child_loc_cd=temp->qual[d.seq].cd)
     AND lg.root_loc_cd=0
     AND lg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=lg.location_group_type_cd)
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0
   HEAD d.seq
    IF (cv.cdf_meaning="BUILDING")
     bcnt = (bcnt+ 1), bld->cnt = bcnt, stat = alterlist(bld->qual,bcnt),
     bld->qual[bcnt].cd = lg.parent_loc_cd
    ELSE
     cnt = (cnt+ 1), temp2->cnt = cnt, stat = alterlist(temp2->qual,cnt),
     temp2->qual[cnt].cd = lg.parent_loc_cd
    ENDIF
   WITH nocounter
  ;end select
  IF ((temp2->cnt > 0))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(temp2->cnt)),
     location_group lg
    PLAN (d)
     JOIN (lg
     WHERE (lg.child_loc_cd=temp2->qual[d.seq].cd)
      AND lg.root_loc_cd=0
      AND lg.active_ind=1)
    ORDER BY d.seq
    HEAD REPORT
     cnt = 0
    HEAD d.seq
     bcnt = (bcnt+ 1), bld->cnt = bcnt, stat = alterlist(bld->qual,bcnt),
     bld->qual[bcnt].cd = lg.parent_loc_cd
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((bld->cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(bld->cnt)),
    location_group lg,
    code_value cv
   PLAN (d)
    JOIN (lg
    WHERE (lg.child_loc_cd=bld->qual[d.seq].cd)
     AND lg.root_loc_cd=0
     AND lg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=lg.parent_loc_cd
     AND parser(fac_name_parse)
     AND cv.active_ind=1)
   ORDER BY lg.parent_loc_cd
   HEAD REPORT
    cnt = 0
   HEAD lg.parent_loc_cd
    cnt = (cnt+ 1), stat = alterlist(reply->flist,cnt), reply->flist[cnt].facility_code_value = lg
    .parent_loc_cd,
    reply->flist[cnt].facility_display = cv.display, reply->flist[cnt].facility_description = cv
    .description
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (size(reply->flist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
