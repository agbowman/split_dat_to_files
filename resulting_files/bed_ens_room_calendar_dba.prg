CREATE PROGRAM bed_ens_room_calendar:dba
 FREE SET reply
 RECORD reply(
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
 DECLARE rad_cd = f8 WITH public, noconstant(0.0)
 DECLARE specimen_cd = f8 WITH public, noconstant(0.0)
 DECLARE active_cd = f8 WITH public, noconstant(0.0)
 DECLARE from_cd = f8 WITH public, noconstant(0.0)
 DECLARE to_cd = f8 WITH public, noconstant(0.0)
 DECLARE hold_calendar = vc
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=202
    AND cv.cdf_meaning="RAD"
    AND cv.active_ind=1)
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=2052
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   specimen_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=340
    AND cv.cdf_meaning="MINUTES"
    AND cv.active_ind=1)
  DETAIL
   from_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=340
    AND cv.cdf_meaning="YEARS"
    AND cv.active_ind=1)
  DETAIL
   to_cd = cv.code_value
  WITH nocounter
 ;end select
 RECORD temp(
   1 qual[*]
     2 room_cd = f8
     2 calendar_name = vc
     2 open_time = i4
     2 close_time = i4
     2 dow = i4
     2 calendar_seq = i4
     2 sequence = i4
     2 location_cd = f8
     2 priority_cd = f8
     2 specimen_type_cd = f8
     2 dispense_type_cd = f8
     2 age_from_units_cd = f8
     2 age_from_minutes = i4
     2 age_to_units_cd = f8
     2 age_to_minutes = i4
 )
 SET alldays_ind = 0
 SET cnt = 0
 FOR (x = 1 TO size(request->qual,5))
   IF ((request->qual[x].action_flag > 0))
    DELETE  FROM loc_resource_calendar l
     WHERE (l.service_resource_cd=request->qual[x].room_cd)
     WITH nocounter
    ;end delete
    DELETE  FROM loc_resource_r l
     WHERE (l.service_resource_cd=request->qual[x].room_cd)
     WITH nocounter
    ;end delete
    SET room_seq = 0
    FOR (y = 1 TO size(request->qual[x].cqual,5))
      IF ((hold_calendar != request->qual[x].cqual[y].calendar_name))
       SET room_seq = (room_seq+ 1)
       SET hold_calendar = request->qual[x].cqual[y].calendar_name
      ENDIF
      SET ierrcode = 0
      INSERT  FROM loc_resource_r l
       SET l.service_resource_cd = request->qual[x].room_cd, l.location_cd =
        IF ((request->qual[x].cqual[y].location_cd > 0)) request->qual[x].cqual[y].location_cd
        ELSE 0
        ENDIF
        , l.loc_resource_type_cd = rad_cd,
        l.sequence = room_seq, l.mm_vendor_customer_account_id = 0, l.group_sequence = room_seq,
        l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id,
        l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
       PLAN (l)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
      SET seq = - (1)
      IF ((request->qual[x].cqual[y].alldays_ind=1))
       SET alldays_ind = 1
       SET seq = (seq+ 1)
       SET cnt = (cnt+ 1)
       SET stat = alterlist(temp->qual,cnt)
       SET temp->qual[cnt].room_cd = request->qual[x].room_cd
       SET temp->qual[cnt].calendar_name = request->qual[x].cqual[y].calendar_name
       SET temp->qual[cnt].open_time = request->qual[x].cqual[y].open_time
       SET temp->qual[cnt].close_time = request->qual[x].cqual[y].close_time
       SET temp->qual[cnt].dow = 7
       SET temp->qual[cnt].calendar_seq = seq
       SET temp->qual[cnt].sequence = room_seq
       IF ((request->qual[x].cqual[y].location_cd > 0))
        SET temp->qual[cnt].location_cd = request->qual[x].cqual[y].location_cd
       ELSE
        SET temp->qual[cnt].location_cd = 0
       ENDIF
       IF ((request->qual[x].cqual[y].priority_cd > 0))
        SET temp->qual[cnt].priority_cd = request->qual[x].cqual[y].priority_cd
       ELSE
        SET temp->qual[cnt].priority_cd = 0
       ENDIF
       IF ((request->qual[x].cqual[y].specimen_type_cd > 0))
        SET temp->qual[cnt].specimen_type_cd = request->qual[x].cqual[y].specimen_type_cd
       ELSE
        SET temp->qual[cnt].specimen_type_cd = specimen_cd
       ENDIF
       IF ((request->qual[x].cqual[y].dispense_type_cd > 0))
        SET temp->qual[cnt].dispense_type_cd = request->qual[x].cqual[y].dispense_type_cd
       ELSE
        SET temp->qual[cnt].dispense_type_cd = 0
       ENDIF
       IF ((request->qual[x].cqual[y].age_from_units_cd > 0))
        SET temp->qual[cnt].age_from_units_cd = request->qual[x].cqual[y].age_from_units_cd
       ELSE
        SET temp->qual[cnt].age_from_units_cd = from_cd
       ENDIF
       IF ((request->qual[x].cqual[y].age_from_minutes > 0))
        SET temp->qual[cnt].age_from_minutes = request->qual[x].cqual[y].age_from_minutes
       ELSE
        SET temp->qual[cnt].age_from_minutes = 0
       ENDIF
       IF ((request->qual[x].cqual[y].age_to_units_cd > 0))
        SET temp->qual[cnt].age_to_units_cd = request->qual[x].cqual[y].age_to_units_cd
       ELSE
        SET temp->qual[cnt].age_to_units_cd = to_cd
       ENDIF
       IF ((request->qual[x].cqual[y].age_to_minutes > 0))
        SET temp->qual[cnt].age_to_minutes = request->qual[x].cqual[y].age_to_minutes
       ELSE
        SET temp->qual[cnt].age_to_minutes = 78840000
       ENDIF
      ELSE
       SET alldays_ind = 0
       IF ((request->qual[x].cqual[y].sunday_ind=1))
        SET seq = (seq+ 1)
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp->qual,cnt)
        SET temp->qual[cnt].room_cd = request->qual[x].room_cd
        SET temp->qual[cnt].calendar_name = request->qual[x].cqual[y].calendar_name
        SET temp->qual[cnt].open_time = request->qual[x].cqual[y].open_time
        SET temp->qual[cnt].close_time = request->qual[x].cqual[y].close_time
        SET temp->qual[cnt].dow = 0
        SET temp->qual[cnt].calendar_seq = seq
        SET temp->qual[cnt].sequence = room_seq
        IF ((request->qual[x].cqual[y].location_cd > 0))
         SET temp->qual[cnt].location_cd = request->qual[x].cqual[y].location_cd
        ELSE
         SET temp->qual[cnt].location_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].priority_cd > 0))
         SET temp->qual[cnt].priority_cd = request->qual[x].cqual[y].priority_cd
        ELSE
         SET temp->qual[cnt].priority_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].specimen_type_cd > 0))
         SET temp->qual[cnt].specimen_type_cd = request->qual[x].cqual[y].specimen_type_cd
        ELSE
         SET temp->qual[cnt].specimen_type_cd = specimen_cd
        ENDIF
        IF ((request->qual[x].cqual[y].dispense_type_cd > 0))
         SET temp->qual[cnt].dispense_type_cd = request->qual[x].cqual[y].dispense_type_cd
        ELSE
         SET temp->qual[cnt].dispense_type_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_units_cd > 0))
         SET temp->qual[cnt].age_from_units_cd = request->qual[x].cqual[y].age_from_units_cd
        ELSE
         SET temp->qual[cnt].age_from_units_cd = from_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_minutes > 0))
         SET temp->qual[cnt].age_from_minutes = request->qual[x].cqual[y].age_from_minutes
        ELSE
         SET temp->qual[cnt].age_from_minutes = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_units_cd > 0))
         SET temp->qual[cnt].age_to_units_cd = request->qual[x].cqual[y].age_to_units_cd
        ELSE
         SET temp->qual[cnt].age_to_units_cd = to_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_minutes > 0))
         SET temp->qual[cnt].age_to_minutes = request->qual[x].cqual[y].age_to_minutes
        ELSE
         SET temp->qual[cnt].age_to_minutes = 78840000
        ENDIF
       ENDIF
       IF ((request->qual[x].cqual[y].monday_ind=1))
        SET seq = (seq+ 1)
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp->qual,cnt)
        SET temp->qual[cnt].room_cd = request->qual[x].room_cd
        SET temp->qual[cnt].calendar_name = request->qual[x].cqual[y].calendar_name
        SET temp->qual[cnt].open_time = request->qual[x].cqual[y].open_time
        SET temp->qual[cnt].close_time = request->qual[x].cqual[y].close_time
        SET temp->qual[cnt].dow = 1
        SET temp->qual[cnt].calendar_seq = seq
        SET temp->qual[cnt].sequence = room_seq
        IF ((request->qual[x].cqual[y].location_cd > 0))
         SET temp->qual[cnt].location_cd = request->qual[x].cqual[y].location_cd
        ELSE
         SET temp->qual[cnt].location_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].priority_cd > 0))
         SET temp->qual[cnt].priority_cd = request->qual[x].cqual[y].priority_cd
        ELSE
         SET temp->qual[cnt].priority_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].specimen_type_cd > 0))
         SET temp->qual[cnt].specimen_type_cd = request->qual[x].cqual[y].specimen_type_cd
        ELSE
         SET temp->qual[cnt].specimen_type_cd = specimen_cd
        ENDIF
        IF ((request->qual[x].cqual[y].dispense_type_cd > 0))
         SET temp->qual[cnt].dispense_type_cd = request->qual[x].cqual[y].dispense_type_cd
        ELSE
         SET temp->qual[cnt].dispense_type_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_units_cd > 0))
         SET temp->qual[cnt].age_from_units_cd = request->qual[x].cqual[y].age_from_units_cd
        ELSE
         SET temp->qual[cnt].age_from_units_cd = from_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_minutes > 0))
         SET temp->qual[cnt].age_from_minutes = request->qual[x].cqual[y].age_from_minutes
        ELSE
         SET temp->qual[cnt].age_from_minutes = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_units_cd > 0))
         SET temp->qual[cnt].age_to_units_cd = request->qual[x].cqual[y].age_to_units_cd
        ELSE
         SET temp->qual[cnt].age_to_units_cd = to_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_minutes > 0))
         SET temp->qual[cnt].age_to_minutes = request->qual[x].cqual[y].age_to_minutes
        ELSE
         SET temp->qual[cnt].age_to_minutes = 78840000
        ENDIF
       ENDIF
       IF ((request->qual[x].cqual[y].tuesday_ind=1))
        SET seq = (seq+ 1)
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp->qual,cnt)
        SET temp->qual[cnt].room_cd = request->qual[x].room_cd
        SET temp->qual[cnt].calendar_name = request->qual[x].cqual[y].calendar_name
        SET temp->qual[cnt].open_time = request->qual[x].cqual[y].open_time
        SET temp->qual[cnt].close_time = request->qual[x].cqual[y].close_time
        SET temp->qual[cnt].dow = 2
        SET temp->qual[cnt].calendar_seq = seq
        SET temp->qual[cnt].sequence = room_seq
        IF ((request->qual[x].cqual[y].location_cd > 0))
         SET temp->qual[cnt].location_cd = request->qual[x].cqual[y].location_cd
        ELSE
         SET temp->qual[cnt].location_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].priority_cd > 0))
         SET temp->qual[cnt].priority_cd = request->qual[x].cqual[y].priority_cd
        ELSE
         SET temp->qual[cnt].priority_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].specimen_type_cd > 0))
         SET temp->qual[cnt].specimen_type_cd = request->qual[x].cqual[y].specimen_type_cd
        ELSE
         SET temp->qual[cnt].specimen_type_cd = specimen_cd
        ENDIF
        IF ((request->qual[x].cqual[y].dispense_type_cd > 0))
         SET temp->qual[cnt].dispense_type_cd = request->qual[x].cqual[y].dispense_type_cd
        ELSE
         SET temp->qual[cnt].dispense_type_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_units_cd > 0))
         SET temp->qual[cnt].age_from_units_cd = request->qual[x].cqual[y].age_from_units_cd
        ELSE
         SET temp->qual[cnt].age_from_units_cd = from_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_minutes > 0))
         SET temp->qual[cnt].age_from_minutes = request->qual[x].cqual[y].age_from_minutes
        ELSE
         SET temp->qual[cnt].age_from_minutes = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_units_cd > 0))
         SET temp->qual[cnt].age_to_units_cd = request->qual[x].cqual[y].age_to_units_cd
        ELSE
         SET temp->qual[cnt].age_to_units_cd = to_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_minutes > 0))
         SET temp->qual[cnt].age_to_minutes = request->qual[x].cqual[y].age_to_minutes
        ELSE
         SET temp->qual[cnt].age_to_minutes = 78840000
        ENDIF
       ENDIF
       IF ((request->qual[x].cqual[y].wednesday_ind=1))
        SET seq = (seq+ 1)
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp->qual,cnt)
        SET temp->qual[cnt].room_cd = request->qual[x].room_cd
        SET temp->qual[cnt].calendar_name = request->qual[x].cqual[y].calendar_name
        SET temp->qual[cnt].open_time = request->qual[x].cqual[y].open_time
        SET temp->qual[cnt].close_time = request->qual[x].cqual[y].close_time
        SET temp->qual[cnt].dow = 3
        SET temp->qual[cnt].calendar_seq = seq
        SET temp->qual[cnt].sequence = room_seq
        IF ((request->qual[x].cqual[y].location_cd > 0))
         SET temp->qual[cnt].location_cd = request->qual[x].cqual[y].location_cd
        ELSE
         SET temp->qual[cnt].location_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].priority_cd > 0))
         SET temp->qual[cnt].priority_cd = request->qual[x].cqual[y].priority_cd
        ELSE
         SET temp->qual[cnt].priority_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].specimen_type_cd > 0))
         SET temp->qual[cnt].specimen_type_cd = request->qual[x].cqual[y].specimen_type_cd
        ELSE
         SET temp->qual[cnt].specimen_type_cd = specimen_cd
        ENDIF
        IF ((request->qual[x].cqual[y].dispense_type_cd > 0))
         SET temp->qual[cnt].dispense_type_cd = request->qual[x].cqual[y].dispense_type_cd
        ELSE
         SET temp->qual[cnt].dispense_type_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_units_cd > 0))
         SET temp->qual[cnt].age_from_units_cd = request->qual[x].cqual[y].age_from_units_cd
        ELSE
         SET temp->qual[cnt].age_from_units_cd = from_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_minutes > 0))
         SET temp->qual[cnt].age_from_minutes = request->qual[x].cqual[y].age_from_minutes
        ELSE
         SET temp->qual[cnt].age_from_minutes = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_units_cd > 0))
         SET temp->qual[cnt].age_to_units_cd = request->qual[x].cqual[y].age_to_units_cd
        ELSE
         SET temp->qual[cnt].age_to_units_cd = to_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_minutes > 0))
         SET temp->qual[cnt].age_to_minutes = request->qual[x].cqual[y].age_to_minutes
        ELSE
         SET temp->qual[cnt].age_to_minutes = 78840000
        ENDIF
       ENDIF
       IF ((request->qual[x].cqual[y].thursday_ind=1))
        SET seq = (seq+ 1)
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp->qual,cnt)
        SET temp->qual[cnt].room_cd = request->qual[x].room_cd
        SET temp->qual[cnt].calendar_name = request->qual[x].cqual[y].calendar_name
        SET temp->qual[cnt].open_time = request->qual[x].cqual[y].open_time
        SET temp->qual[cnt].close_time = request->qual[x].cqual[y].close_time
        SET temp->qual[cnt].dow = 4
        SET temp->qual[cnt].calendar_seq = seq
        SET temp->qual[cnt].sequence = room_seq
        IF ((request->qual[x].cqual[y].location_cd > 0))
         SET temp->qual[cnt].location_cd = request->qual[x].cqual[y].location_cd
        ELSE
         SET temp->qual[cnt].location_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].priority_cd > 0))
         SET temp->qual[cnt].priority_cd = request->qual[x].cqual[y].priority_cd
        ELSE
         SET temp->qual[cnt].priority_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].specimen_type_cd > 0))
         SET temp->qual[cnt].specimen_type_cd = request->qual[x].cqual[y].specimen_type_cd
        ELSE
         SET temp->qual[cnt].specimen_type_cd = specimen_cd
        ENDIF
        IF ((request->qual[x].cqual[y].dispense_type_cd > 0))
         SET temp->qual[cnt].dispense_type_cd = request->qual[x].cqual[y].dispense_type_cd
        ELSE
         SET temp->qual[cnt].dispense_type_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_units_cd > 0))
         SET temp->qual[cnt].age_from_units_cd = request->qual[x].cqual[y].age_from_units_cd
        ELSE
         SET temp->qual[cnt].age_from_units_cd = from_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_minutes > 0))
         SET temp->qual[cnt].age_from_minutes = request->qual[x].cqual[y].age_from_minutes
        ELSE
         SET temp->qual[cnt].age_from_minutes = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_units_cd > 0))
         SET temp->qual[cnt].age_to_units_cd = request->qual[x].cqual[y].age_to_units_cd
        ELSE
         SET temp->qual[cnt].age_to_units_cd = to_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_minutes > 0))
         SET temp->qual[cnt].age_to_minutes = request->qual[x].cqual[y].age_to_minutes
        ELSE
         SET temp->qual[cnt].age_to_minutes = 78840000
        ENDIF
       ENDIF
       IF ((request->qual[x].cqual[y].friday_ind=1))
        SET seq = (seq+ 1)
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp->qual,cnt)
        SET temp->qual[cnt].room_cd = request->qual[x].room_cd
        SET temp->qual[cnt].calendar_name = request->qual[x].cqual[y].calendar_name
        SET temp->qual[cnt].open_time = request->qual[x].cqual[y].open_time
        SET temp->qual[cnt].close_time = request->qual[x].cqual[y].close_time
        SET temp->qual[cnt].dow = 5
        SET temp->qual[cnt].calendar_seq = seq
        SET temp->qual[cnt].sequence = room_seq
        IF ((request->qual[x].cqual[y].location_cd > 0))
         SET temp->qual[cnt].location_cd = request->qual[x].cqual[y].location_cd
        ELSE
         SET temp->qual[cnt].location_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].priority_cd > 0))
         SET temp->qual[cnt].priority_cd = request->qual[x].cqual[y].priority_cd
        ELSE
         SET temp->qual[cnt].priority_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].specimen_type_cd > 0))
         SET temp->qual[cnt].specimen_type_cd = request->qual[x].cqual[y].specimen_type_cd
        ELSE
         SET temp->qual[cnt].specimen_type_cd = specimen_cd
        ENDIF
        IF ((request->qual[x].cqual[y].dispense_type_cd > 0))
         SET temp->qual[cnt].dispense_type_cd = request->qual[x].cqual[y].dispense_type_cd
        ELSE
         SET temp->qual[cnt].dispense_type_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_units_cd > 0))
         SET temp->qual[cnt].age_from_units_cd = request->qual[x].cqual[y].age_from_units_cd
        ELSE
         SET temp->qual[cnt].age_from_units_cd = from_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_minutes > 0))
         SET temp->qual[cnt].age_from_minutes = request->qual[x].cqual[y].age_from_minutes
        ELSE
         SET temp->qual[cnt].age_from_minutes = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_units_cd > 0))
         SET temp->qual[cnt].age_to_units_cd = request->qual[x].cqual[y].age_to_units_cd
        ELSE
         SET temp->qual[cnt].age_to_units_cd = to_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_minutes > 0))
         SET temp->qual[cnt].age_to_minutes = request->qual[x].cqual[y].age_to_minutes
        ELSE
         SET temp->qual[cnt].age_to_minutes = 78840000
        ENDIF
       ENDIF
       IF ((request->qual[x].cqual[y].saturday_ind=1))
        SET seq = (seq+ 1)
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp->qual,cnt)
        SET temp->qual[cnt].room_cd = request->qual[x].room_cd
        SET temp->qual[cnt].calendar_name = request->qual[x].cqual[y].calendar_name
        SET temp->qual[cnt].open_time = request->qual[x].cqual[y].open_time
        SET temp->qual[cnt].close_time = request->qual[x].cqual[y].close_time
        SET temp->qual[cnt].dow = 6
        SET temp->qual[cnt].calendar_seq = seq
        SET temp->qual[cnt].sequence = room_seq
        IF ((request->qual[x].cqual[y].location_cd > 0))
         SET temp->qual[cnt].location_cd = request->qual[x].cqual[y].location_cd
        ELSE
         SET temp->qual[cnt].location_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].priority_cd > 0))
         SET temp->qual[cnt].priority_cd = request->qual[x].cqual[y].priority_cd
        ELSE
         SET temp->qual[cnt].priority_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].specimen_type_cd > 0))
         SET temp->qual[cnt].specimen_type_cd = request->qual[x].cqual[y].specimen_type_cd
        ELSE
         SET temp->qual[cnt].specimen_type_cd = specimen_cd
        ENDIF
        IF ((request->qual[x].cqual[y].dispense_type_cd > 0))
         SET temp->qual[cnt].dispense_type_cd = request->qual[x].cqual[y].dispense_type_cd
        ELSE
         SET temp->qual[cnt].dispense_type_cd = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_units_cd > 0))
         SET temp->qual[cnt].age_from_units_cd = request->qual[x].cqual[y].age_from_units_cd
        ELSE
         SET temp->qual[cnt].age_from_units_cd = from_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_from_minutes > 0))
         SET temp->qual[cnt].age_from_minutes = request->qual[x].cqual[y].age_from_minutes
        ELSE
         SET temp->qual[cnt].age_from_minutes = 0
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_units_cd > 0))
         SET temp->qual[cnt].age_to_units_cd = request->qual[x].cqual[y].age_to_units_cd
        ELSE
         SET temp->qual[cnt].age_to_units_cd = to_cd
        ENDIF
        IF ((request->qual[x].cqual[y].age_to_minutes > 0))
         SET temp->qual[cnt].age_to_minutes = request->qual[x].cqual[y].age_to_minutes
        ELSE
         SET temp->qual[cnt].age_to_minutes = 78840000
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF (size(temp->qual,5) > 0)
  SET ierrcode = 0
  INSERT  FROM loc_resource_calendar l,
    (dummyt d  WITH seq = value(size(temp->qual,5)))
   SET l.seq = 1, l.service_resource_cd = temp->qual[d.seq].room_cd, l.location_cd = temp->qual[d.seq
    ].location_cd,
    l.loc_resource_type_cd = rad_cd, l.calendar_seq = temp->qual[d.seq].calendar_seq, l.dow = temp->
    qual[d.seq].dow,
    l.avail_ind = 1, l.open_time = temp->qual[d.seq].open_time, l.close_time = temp->qual[d.seq].
    close_time,
    l.priority_cd = temp->qual[d.seq].priority_cd, l.description = temp->qual[d.seq].calendar_name, l
    .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
    l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), l.specimen_type_cd = temp->qual[d.seq].
    specimen_type_cd, l.dispense_type_cd = temp->qual[d.seq].dispense_type_cd,
    l.sequence = temp->qual[d.seq].sequence, l.active_ind = 1, l.active_status_cd = active_cd,
    l.active_status_dt_tm = cnvtdatetime(curdate,curtime), l.active_status_prsnl_id = reqinfo->
    updt_id, l.age_from_minutes = temp->qual[d.seq].age_from_minutes,
    l.age_to_minutes = temp->qual[d.seq].age_to_minutes, l.age_from_units_cd = temp->qual[d.seq].
    age_from_units_cd, l.age_to_units_cd = temp->qual[d.seq].age_to_units_cd,
    l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id,
    l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (l)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
