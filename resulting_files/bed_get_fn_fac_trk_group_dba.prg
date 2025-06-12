CREATE PROGRAM bed_get_fn_fac_trk_group:dba
 FREE SET reply
 RECORD reply(
   1 tglist[*]
     2 track_group_code_value = f8
     2 track_group_display = vc
     2 track_group_description = vc
     2 track_group_meaning = vc
     2 loc_code_value = f8
     2 track_group_prefix = vc
     2 locations[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
  DETAIL
   facility_cd = cv.code_value
  WITH nocounter
 ;end select
 RECORD temp(
   1 qual[*]
     2 tg_cd = f8
     2 tg_disp = vc
     2 tg_desc = vc
     2 tg_mean = vc
     2 tg_prefix = vc
     2 facility_found = i2
     2 locations[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 mean = vc
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM track_group tg,
   code_value cv,
   br_name_value bnv,
   code_value cv1
  PLAN (tg
   WHERE tg.parent_value > 0
    AND tg.child_value=0
    AND tg.child_table="TRACK_ASSOC")
   JOIN (cv
   WHERE cv.code_value=tg.tracking_group_cd
    AND cv.code_set=16370)
   JOIN (bnv
   WHERE bnv.br_nv_key1=outerjoin("FNTRKGRP_PREFIX")
    AND bnv.br_name=outerjoin(cnvtstring(cv.code_value)))
   JOIN (cv1
   WHERE cv1.code_value=tg.parent_value
    AND cv1.active_ind=1)
  ORDER BY tg.tracking_group_cd
  HEAD tg.tracking_group_cd
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].tg_cd = tg.tracking_group_cd,
   temp->qual[cnt].tg_disp = cv.display, temp->qual[cnt].tg_desc = cv.description, temp->qual[cnt].
   tg_mean = cv.cdf_meaning,
   temp->qual[cnt].tg_prefix = bnv.br_value, temp->qual[cnt].facility_found = 0, lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(temp->qual[cnt].locations,lcnt), temp->qual[cnt].locations[lcnt
   ].code_value = tg.parent_value,
   temp->qual[cnt].locations[lcnt].display = cv1.display, temp->qual[cnt].locations[lcnt].description
    = cv1.description, temp->qual[cnt].locations[lcnt].mean = cv1.cdf_meaning
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   (dummyt d2  WITH seq = 1),
   location_group lg1,
   location_group lg2
  PLAN (d
   WHERE (temp->qual[d.seq].facility_found=0)
    AND maxrec(d2,size(temp->qual[d.seq].locations,5)))
   JOIN (d2)
   JOIN (lg1
   WHERE (lg1.child_loc_cd=temp->qual[d.seq].locations[d2.seq].code_value)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE (lg2.parent_loc_cd=request->facility_code_value)
    AND lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.location_group_type_cd=facility_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].facility_found = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   (dummyt d2  WITH seq = 1),
   location_group lg1,
   location_group lg2,
   location_group lg3
  PLAN (d
   WHERE (temp->qual[d.seq].facility_found=0)
    AND maxrec(d2,size(temp->qual[d.seq].locations,5)))
   JOIN (d2)
   JOIN (lg1
   WHERE (lg1.child_loc_cd=temp->qual[d.seq].locations[d2.seq].code_value)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (lg3
   WHERE (lg3.parent_loc_cd=request->facility_code_value)
    AND lg3.child_loc_cd=lg2.parent_loc_cd
    AND lg3.location_group_type_cd=facility_cd
    AND lg3.root_loc_cd=0
    AND lg3.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].facility_found = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   (dummyt d2  WITH seq = 1),
   location_group lg1,
   location_group lg2,
   location_group lg3,
   location_group lg4
  PLAN (d
   WHERE (temp->qual[d.seq].facility_found=0)
    AND maxrec(d2,size(temp->qual[d.seq].locations,5)))
   JOIN (d2)
   JOIN (lg1
   WHERE (lg1.child_loc_cd=temp->qual[d.seq].locations[d2.seq].code_value)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (lg3
   WHERE lg3.child_loc_cd=lg2.parent_loc_cd
    AND lg3.root_loc_cd=0
    AND lg3.active_ind=1)
   JOIN (lg4
   WHERE (lg4.parent_loc_cd=request->facility_code_value)
    AND lg4.child_loc_cd=lg3.parent_loc_cd
    AND lg4.location_group_type_cd=facility_cd
    AND lg4.root_loc_cd=0
    AND lg4.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].facility_found = 1
  WITH nocounter
 ;end select
 SET rcnt = 0
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].facility_found=1))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->tglist,rcnt)
    SET reply->tglist[rcnt].track_group_code_value = temp->qual[x].tg_cd
    SET reply->tglist[rcnt].track_group_display = temp->qual[x].tg_disp
    SET reply->tglist[rcnt].track_group_description = temp->qual[x].tg_desc
    SET reply->tglist[rcnt].track_group_meaning = temp->qual[x].tg_mean
    SET lcnt = size(temp->qual[x].locations,5)
    SET stat = alterlist(reply->tglist[rcnt].locations,lcnt)
    FOR (l = 1 TO lcnt)
      SET reply->tglist[rcnt].locations[l].code_value = temp->qual[x].locations[l].code_value
      SET reply->tglist[rcnt].locations[l].display = temp->qual[x].locations[l].display
      SET reply->tglist[rcnt].locations[l].description = temp->qual[x].locations[l].description
      SET reply->tglist[rcnt].locations[l].mean = temp->qual[x].locations[l].mean
    ENDFOR
    SET reply->tglist[rcnt].track_group_prefix = temp->qual[x].tg_prefix
   ENDIF
 ENDFOR
#exit_script
 IF (size(reply->tglist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
