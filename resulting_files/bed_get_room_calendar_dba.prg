CREATE PROGRAM bed_get_room_calendar:dba
 FREE SET reply
 RECORD reply(
   1 rqual[*]
     2 room_name = vc
     2 room_cd = f8
     2 modality_cd = f8
     2 modality_mean = vc
     2 cqual[*]
       3 calendar_name = vc
       3 open_time = i4
       3 close_time = i4
       3 sunday_ind = i2
       3 monday_ind = i2
       3 tuesday_ind = i2
       3 wednesday_ind = i2
       3 thursday_ind = i2
       3 friday_ind = i2
       3 saturday_ind = i2
       3 alldays_ind = i2
       3 priority_cd = f8
       3 specimen_type_cd = f8
       3 dispense_type_cd = f8
       3 age_from_units_cd = f8
       3 age_from_minutes = i4
       3 age_to_units_cd = f8
       3 age_to_minutes = i4
       3 lqual[*]
         4 location_cd = f8
         4 display = vc
         4 mean = vc
         4 discipline_type
           5 code_value = f8
           5 display = vc
           5 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 DECLARE radexamroom = f8 WITH public, noconstant(0.0)
 DECLARE radiology = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="RADEXAMROOM"
    AND cv.active_ind=1)
  DETAIL
   radexamroom = cv.code_value
  WITH nocounter
 ;end select
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM service_resource sr,
   resource_group rg,
   code_value cv,
   resource_group rg2,
   resource_group rg3,
   service_resource sr2,
   code_value cv2,
   loc_resource_calendar lrc
  PLAN (sr
   WHERE (sr.service_resource_cd=request->dept_cd)
    AND ((sr.active_ind+ 0)=1))
   JOIN (rg
   WHERE rg.parent_service_resource_cd=sr.service_resource_cd
    AND rg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=rg.child_service_resource_cd)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=rg.child_service_resource_cd
    AND rg2.active_ind=1)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
    AND rg3.active_ind=1)
   JOIN (sr2
   WHERE sr2.service_resource_cd=rg3.child_service_resource_cd
    AND ((sr2.service_resource_type_cd+ 0)=radexamroom)
    AND ((sr2.active_ind+ 0)=1))
   JOIN (cv2
   WHERE cv2.code_value=sr2.service_resource_cd)
   JOIN (lrc
   WHERE lrc.service_resource_cd=outerjoin(sr2.service_resource_cd)
    AND lrc.active_ind=outerjoin(1))
  ORDER BY rg.sequence, rg2.sequence, rg3.sequence,
   lrc.description, lrc.sequence
  HEAD REPORT
   rcnt = 0, ccnt = 0
  HEAD sr2.service_resource_cd
   ccnt = 0, rcnt = (rcnt+ 1), stat = alterlist(reply->rqual,rcnt),
   reply->rqual[rcnt].room_name = cv2.description, reply->rqual[rcnt].room_cd = sr2
   .service_resource_cd, reply->rqual[rcnt].modality_cd = rg.child_service_resource_cd,
   reply->rqual[rcnt].modality_mean = cv.display
  HEAD lrc.description
   IF (lrc.service_resource_cd > 0)
    ccnt = (ccnt+ 1), stat = alterlist(reply->rqual[rcnt].cqual,ccnt), reply->rqual[rcnt].cqual[ccnt]
    .calendar_name = lrc.description,
    reply->rqual[rcnt].cqual[ccnt].open_time = lrc.open_time, reply->rqual[rcnt].cqual[ccnt].
    close_time = lrc.close_time, reply->rqual[rcnt].cqual[ccnt].priority_cd = lrc.priority_cd,
    reply->rqual[rcnt].cqual[ccnt].specimen_type_cd = lrc.specimen_type_cd, reply->rqual[rcnt].cqual[
    ccnt].dispense_type_cd = lrc.dispense_type_cd, reply->rqual[rcnt].cqual[ccnt].age_from_units_cd
     = lrc.age_from_units_cd,
    reply->rqual[rcnt].cqual[ccnt].age_from_minutes = lrc.age_from_minutes, reply->rqual[rcnt].cqual[
    ccnt].age_to_units_cd = lrc.age_to_units_cd, reply->rqual[rcnt].cqual[ccnt].age_to_minutes = lrc
    .age_to_minutes
   ENDIF
  DETAIL
   IF (lrc.service_resource_cd > 0)
    IF (lrc.dow=7)
     reply->rqual[rcnt].cqual[ccnt].alldays_ind = 1
    ELSEIF (lrc.dow=0)
     reply->rqual[rcnt].cqual[ccnt].sunday_ind = 1
    ELSEIF (lrc.dow=1)
     reply->rqual[rcnt].cqual[ccnt].monday_ind = 1
    ELSEIF (lrc.dow=2)
     reply->rqual[rcnt].cqual[ccnt].tuesday_ind = 1
    ELSEIF (lrc.dow=3)
     reply->rqual[rcnt].cqual[ccnt].wednesday_ind = 1
    ELSEIF (lrc.dow=4)
     reply->rqual[rcnt].cqual[ccnt].thursday_ind = 1
    ELSEIF (lrc.dow=5)
     reply->rqual[rcnt].cqual[ccnt].friday_ind = 1
    ELSEIF (lrc.dow=6)
     reply->rqual[rcnt].cqual[ccnt].saturday_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(reply->rqual,5))
   FOR (y = 1 TO size(reply->rqual[x].cqual,5))
     SELECT INTO "nl:"
      FROM loc_resource_calendar l,
       code_value cv,
       location loc,
       code_value cv2
      PLAN (l
       WHERE (l.service_resource_cd=reply->rqual[x].room_cd)
        AND (l.description=reply->rqual[x].cqual[y].calendar_name))
       JOIN (cv
       WHERE cv.code_value=l.location_cd)
       JOIN (loc
       WHERE loc.location_cd=l.location_cd)
       JOIN (cv2
       WHERE cv2.code_value=loc.discipline_type_cd)
      ORDER BY l.location_cd
      HEAD REPORT
       lcnt = 0
      HEAD l.location_cd
       lcnt = (lcnt+ 1), stat = alterlist(reply->rqual[x].cqual[y].lqual,lcnt), reply->rqual[x].
       cqual[y].lqual[lcnt].location_cd = l.location_cd,
       reply->rqual[x].cqual[y].lqual[lcnt].display = cv.display, reply->rqual[x].cqual[y].lqual[lcnt
       ].mean = cv.cdf_meaning, reply->rqual[x].cqual[y].lqual[lcnt].discipline_type.code_value = cv2
       .code_value,
       reply->rqual[x].cqual[y].lqual[lcnt].discipline_type.display = cv2.display, reply->rqual[x].
       cqual[y].lqual[lcnt].discipline_type.mean = cv2.cdf_meaning
      WITH nocounter
     ;end select
   ENDFOR
 ENDFOR
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
