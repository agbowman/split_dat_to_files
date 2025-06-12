CREATE PROGRAM bed_get_locations_by_type:dba
 FREE SET reply
 RECORD reply(
   01 locations[*]
     02 location_code_value = f8
     02 short_description = vc
     02 sequence = i4
     02 par_loc_short_description = vc
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
  FROM location l
  PLAN (l
   WHERE (l.location_type_cd=request->location_type_code_value)
    AND l.active_ind=1)
  ORDER BY l.location_cd
  HEAD REPORT
   lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(reply->locations,lcnt), reply->locations[lcnt].
   location_code_value = l.location_cd
  WITH nocounter
 ;end select
 FOR (x = 1 TO lcnt)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value=reply->locations[x].location_code_value))
   DETAIL
    reply->locations[x].short_description = cv.display
    IF (cv.cdf_meaning="FACILITY")
     reply->locations[x].sequence = cv.collation_seq
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM location_group lg,
    code_value cv
   PLAN (lg
    WHERE (lg.child_loc_cd=reply->locations[x].location_code_value)
     AND lg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=lg.parent_loc_cd)
   DETAIL
    reply->locations[x].par_loc_short_description = cv.display
   WITH nocounter
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
