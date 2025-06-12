CREATE PROGRAM bed_get_pal_views:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
     2 locations[*]
       3 code_value = f8
       3 formatted_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pcnt = 0
 SET lcnt = 0
 DECLARE building_cd = f8
 DECLARE unit_cd = f8
 DECLARE amb_cd = f8
 DECLARE room_cd = f8
 SET building_cd = uar_get_code_by("MEANING",222,"BUILDING")
 SET unit_cd = uar_get_code_by("MEANING",222,"NURSEUNIT")
 SET amb_cd = uar_get_code_by("MEANING",222,"AMBULATORY")
 SET room_cd = uar_get_code_by("MEANING",222,"ROOM")
 SET facility_type_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="FACILITY"
  DETAIL
   facility_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pip p,
   code_value cv
  PLAN (p
   WHERE p.position_cd > 0
    AND p.prsnl_id=0)
   JOIN (cv
   WHERE cv.code_value=p.position_cd
    AND cv.active_ind=1)
  ORDER BY cv.display, p.location_cd
  HEAD cv.display
   lcnt = 0, pcnt = (pcnt+ 1), stat = alterlist(reply->positions,pcnt),
   reply->positions[pcnt].code_value = cv.code_value, reply->positions[pcnt].display = cv.display
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(reply->positions[pcnt].locations,lcnt), reply->positions[pcnt].
   locations[lcnt].code_value = p.location_cd
  WITH nocounter
 ;end select
 IF (pcnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO pcnt)
  SET lcnt = size(reply->positions[x].locations,5)
  IF (lcnt > 0)
   FOR (y = 1 TO lcnt)
     IF ((reply->positions[x].locations[y].code_value > 0))
      SELECT INTO "nl:"
       FROM code_value c
       PLAN (c
        WHERE (c.code_value=reply->positions[x].locations[y].code_value)
         AND c.cdf_meaning="FACILITY")
       DETAIL
        reply->positions[x].locations[y].formatted_display = c.display
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET facility_found = 0
       SET child_cd = 0.0
       SELECT INTO "nl:"
        FROM location_group l,
         code_value c1,
         code_value c2
        PLAN (l
         WHERE (l.child_loc_cd=reply->positions[x].locations[y].code_value)
          AND l.location_group_type_cd IN (facility_type_cd, building_cd, unit_cd, amb_cd, room_cd)
          AND l.root_loc_cd=0
          AND l.active_ind=1)
         JOIN (c1
         WHERE c1.code_value=l.parent_loc_cd)
         JOIN (c2
         WHERE c2.code_value=l.child_loc_cd)
        DETAIL
         child_cd = l.parent_loc_cd, reply->positions[x].locations[y].formatted_display = concat(trim
          (c1.display),"/",trim(c2.display))
         IF (l.location_group_type_cd=facility_type_cd)
          facility_found = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (facility_found=0)
        SELECT INTO "nl:"
         FROM location_group l,
          code_value c
         PLAN (l
          WHERE l.child_loc_cd=child_cd
           AND l.location_group_type_cd IN (facility_type_cd, building_cd, unit_cd, amb_cd, room_cd)
           AND l.root_loc_cd=0
           AND l.active_ind=1)
          JOIN (c
          WHERE c.code_value=l.parent_loc_cd)
         DETAIL
          child_cd = l.parent_loc_cd, reply->positions[x].locations[y].formatted_display = concat(
           trim(c.display),"/",reply->positions[x].locations[y].formatted_display)
          IF (l.location_group_type_cd=facility_type_cd)
           facility_found = 1
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
       IF (facility_found=0)
        SELECT INTO "nl:"
         FROM location_group l,
          code_value c
         PLAN (l
          WHERE l.child_loc_cd=child_cd
           AND l.location_group_type_cd IN (facility_type_cd, building_cd, unit_cd, amb_cd, room_cd)
           AND l.root_loc_cd=0
           AND l.active_ind=1)
          JOIN (c
          WHERE c.code_value=l.parent_loc_cd)
         DETAIL
          child_cd = l.parent_loc_cd, reply->positions[x].locations[y].formatted_display = concat(
           trim(c.display),"/",reply->positions[x].locations[y].formatted_display)
          IF (l.location_group_type_cd=facility_type_cd)
           facility_found = 1
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
       IF (facility_found=0)
        SELECT INTO "nl:"
         FROM location_group l,
          code_value c
         PLAN (l
          WHERE l.child_loc_cd=child_cd
           AND l.location_group_type_cd IN (facility_type_cd, building_cd, unit_cd, amb_cd, room_cd)
           AND l.root_loc_cd=0
           AND l.active_ind=1)
          JOIN (c
          WHERE c.code_value=l.parent_loc_cd)
         DETAIL
          child_cd = l.parent_loc_cd, reply->positions[x].locations[y].formatted_display = concat(
           trim(c.display),"/",reply->positions[x].locations[y].formatted_display)
          IF (l.location_group_type_cd=facility_type_cd)
           facility_found = 1
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
       IF ((reply->positions[x].locations[y].formatted_display=""))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE (c.code_value=reply->positions[x].locations[y].code_value))
         DETAIL
          disp = ""
          IF (c.cdf_meaning="BUILDING")
           reply->positions[x].locations[y].formatted_display = concat("/",c.display)
          ELSEIF (c.cdf_meaning != "FACILITY")
           reply->positions[x].locations[y].formatted_display = concat("//",c.display)
          ELSE
           reply->positions[x].locations[y].formatted_display = c.display
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (pcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
