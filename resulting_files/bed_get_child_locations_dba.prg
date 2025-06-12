CREATE PROGRAM bed_get_child_locations:dba
 FREE SET reply
 RECORD reply(
   01 child_locations[*]
     02 location_code_value = f8
     02 location_type_code_value = f8
     02 short_description = vc
     02 full_description = vc
     02 sequence = i4
     02 is_parent_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET lcnt = 0
 SELECT INTO "nl:"
  FROM location_group lg,
   location l,
   code_value cv
  PLAN (lg
   WHERE (lg.parent_loc_cd=request->location_code_value)
    AND lg.active_ind=1)
   JOIN (l
   WHERE l.location_cd=lg.child_loc_cd
    AND l.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=l.location_cd)
  HEAD REPORT
   lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(reply->child_locations,lcnt), reply->child_locations[lcnt].
   location_code_value = l.location_cd,
   reply->child_locations[lcnt].location_type_code_value = l.location_type_cd, reply->
   child_locations[lcnt].short_description = cv.display, reply->child_locations[lcnt].
   full_description = cv.description,
   reply->child_locations[lcnt].sequence = lg.sequence
  WITH nocounter
 ;end select
 FOR (x = 1 TO lcnt)
  SET reply->child_locations[x].is_parent_ind = 0
  SELECT INTO "nl:"
   FROM location_group lg
   PLAN (lg
    WHERE (lg.parent_loc_cd=reply->child_locations[x].location_code_value)
     AND lg.active_ind=1)
   DETAIL
    reply->child_locations[x].is_parent_ind = 1
   WITH nocounter, maxqual(lg,1)
  ;end select
 ENDFOR
#exit_script
 IF (lcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
