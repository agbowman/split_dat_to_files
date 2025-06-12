CREATE PROGRAM bed_get_child_locs:dba
 FREE SET reply
 RECORD reply(
   1 parent_locations[*]
     2 code_value = f8
     2 child_locations[*]
       3 code_value = f8
       3 display = c40
       3 description = c60
       3 active_ind = i2
       3 type_code_value = f8
       3 type_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE string1 = vc
 DECLARE string2 = vc
 DECLARE string3 = vc
 DECLARE parse_types = vc
 DECLARE parse_parent = vc
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET sub_cnt = 0
 SET list_cnt = 0
 SET tot_cnt = 0
 SET cnt = size(request->parent_locations,5)
 SET stat = alterlist(reply->parent_locations,cnt)
 FOR (x = 1 TO cnt)
   SET sub_cnt = size(request->parent_locations[x].types,5)
   SET reply->parent_locations[x].code_value = request->parent_locations[x].code_value
   IF (sub_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = sub_cnt)
     PLAN (d)
     HEAD REPORT
      parse_types = " l.location_type_cd IN (", comma_flag = 0
     DETAIL
      IF (comma_flag=0)
       parse_types = build(parse_types,request->parent_locations[x].types[d.seq].code_value),
       comma_flag = 1
      ELSE
       parse_types = build(parse_types,",",request->parent_locations[x].types[d.seq].code_value)
      ENDIF
     FOOT REPORT
      IF ((request->include_inactives_ind=0))
       parse_types = concat(parse_types,") and l.location_cd = lg.child_loc_cd and l.active_ind = 1")
      ELSEIF ((request->include_inactives_ind=1))
       parse_types = concat(parse_types,") and l.location_cd = lg.child_loc_cd")
      ENDIF
     WITH nocounter
    ;end select
    IF ((request->include_inactives_ind=0))
     SET string1 = "lg.active_ind = 1"
     SET string2 = "l.active_ind = 1"
     SET string3 = "cv.code_value = lg.child_loc_cd and cv.active_ind = 1"
    ELSEIF ((request->include_inactives_ind=1))
     SET string1 = "lg.child_loc_cd > 0"
     SET string2 = "l.location_cd > 0"
     SET string3 = "cv.code_value = lg.child_loc_cd"
    ENDIF
    IF ((request->parent_locations[x].root_code_value > 0))
     SET parse_parent = concat("lg.root_loc_cd = request->parent_locations[x].root_code_value",
      " and lg.parent_loc_cd = request->parent_locations[x].code_value")
    ELSE
     SET parse_parent = "lg.parent_loc_cd = request->parent_locations[x].code_value"
    ENDIF
    SET list_cnt = 0
    SELECT INTO "nl:"
     FROM location_group lg,
      location l,
      code_value cv
     PLAN (lg
      WHERE parser(parse_parent)
       AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND lg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND parser(string1))
      JOIN (l
      WHERE l.location_cd=lg.child_loc_cd
       AND parser(parse_types)
       AND parser(string2))
      JOIN (cv
      WHERE parser(string3))
     ORDER BY lg.parent_loc_cd
     HEAD REPORT
      list_cnt = 0, tot_cnt = 0, stat = alterlist(reply->parent_locations[x].child_locations,10)
     DETAIL
      list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (tot_cnt > 10)
       stat = alterlist(reply->parent_locations[x].child_locations,(list_cnt+ 10)), tot_cnt = 1
      ENDIF
      reply->parent_locations[x].child_locations[list_cnt].code_value = lg.child_loc_cd, reply->
      parent_locations[x].child_locations[list_cnt].type_sequence = lg.sequence, reply->
      parent_locations[x].child_locations[list_cnt].type_code_value = l.location_type_cd,
      reply->parent_locations[x].child_locations[list_cnt].active_ind = cv.active_ind, reply->
      parent_locations[x].child_locations[list_cnt].description = cv.description, reply->
      parent_locations[x].child_locations[list_cnt].display = cv.display
     FOOT REPORT
      stat = alterlist(reply->parent_locations[x].child_locations,list_cnt)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
