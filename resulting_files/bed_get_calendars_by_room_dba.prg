CREATE PROGRAM bed_get_calendars_by_room:dba
 FREE SET reply
 RECORD reply(
   1 calendars[*]
     2 name = vc
     2 open_time = i4
     2 close_time = i4
     2 sunday_ind = i2
     2 monday_ind = i2
     2 tuesday_ind = i2
     2 wednesday_ind = i2
     2 thursday_ind = i2
     2 friday_ind = i2
     2 saturday_ind = i2
     2 alldays_ind = i2
     2 service_areas[*]
       3 code_value = f8
       3 display = c40
       3 description = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET alterlist_ccnt = 0
 SET stat = alterlist(reply->calendars,20)
 SELECT INTO "NL:"
  FROM loc_resource_calendar lrc
  WHERE (lrc.service_resource_cd=request->exam_room_code_value)
   AND lrc.active_ind=1
  ORDER BY lrc.description
  HEAD lrc.description
   ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
   IF (alterlist_ccnt > 20)
    stat = alterlist(reply->calendars,(ccnt+ 20)), alterlist_ccnt = 1
   ENDIF
   reply->calendars[ccnt].name = lrc.description, reply->calendars[ccnt].open_time = lrc.open_time,
   reply->calendars[ccnt].close_time = lrc.close_time
  DETAIL
   IF (lrc.dow=7)
    reply->calendars[ccnt].alldays_ind = 1
   ELSEIF (lrc.dow=0)
    reply->calendars[ccnt].sunday_ind = 1
   ELSEIF (lrc.dow=1)
    reply->calendars[ccnt].monday_ind = 1
   ELSEIF (lrc.dow=2)
    reply->calendars[ccnt].tuesday_ind = 1
   ELSEIF (lrc.dow=3)
    reply->calendars[ccnt].wednesday_ind = 1
   ELSEIF (lrc.dow=4)
    reply->calendars[ccnt].thursday_ind = 1
   ELSEIF (lrc.dow=5)
    reply->calendars[ccnt].friday_ind = 1
   ELSEIF (lrc.dow=6)
    reply->calendars[ccnt].saturday_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->calendars,ccnt)
 FOR (c = 1 TO ccnt)
   SELECT INTO "NL:"
    FROM loc_resource_calendar lrc,
     code_value cv
    PLAN (lrc
     WHERE (lrc.service_resource_cd=request->exam_room_code_value)
      AND (lrc.description=reply->calendars[c].name)
      AND lrc.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=lrc.location_cd
      AND cv.active_ind=1)
    ORDER BY lrc.location_cd
    HEAD REPORT
     lcnt = 0
    HEAD lrc.location_cd
     lcnt = (lcnt+ 1), stat = alterlist(reply->calendars[c].service_areas,lcnt), reply->calendars[c].
     service_areas[lcnt].code_value = lrc.location_cd,
     reply->calendars[c].service_areas[lcnt].display = cv.display, reply->calendars[c].service_areas[
     lcnt].description = cv.description
    WITH nocounter
   ;end select
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
