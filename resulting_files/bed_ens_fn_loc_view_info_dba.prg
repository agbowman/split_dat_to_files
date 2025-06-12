CREATE PROGRAM bed_ens_fn_loc_view_info:dba
 FREE SET reply
 RECORD reply(
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
 RECORD room(
   1 cnt = i2
   1 qual[*]
     2 cd = f8
 )
 DECLARE building_cd = f8 WITH noconstant(0.0), protect
 DECLARE root_cd = f8 WITH noconstant(0.0), protect
 DECLARE facility_type_cd = f8 WITH noconstant(0.0), protect
 DECLARE building_type_cd = f8 WITH noconstant(0.0), protect
 DECLARE unit_type_cd = f8 WITH noconstant(0.0), protect
 DECLARE room_type_cd = f8 WITH noconstant(0.0), protect
 DECLARE active_cd = f8 WITH noconstant(0.0), protect
 DECLARE inactive_cd = f8 WITH noconstant(0.0), protect
 DECLARE room_cd = f8 WITH noconstant(0.0), protect
 DECLARE bed_cd = f8 WITH noconstant(0.0), protect
 DECLARE view_cd = f8 WITH noconstant(0.0), protect
 DECLARE facility_cd = f8 WITH noconstant(0.0), protect
 DECLARE unit_cd = f8 WITH noconstant(0.0), protect
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="PTTRACKROOT"
  DETAIL
   root_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="FACILITY"
  DETAIL
   facility_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="BUILDING"
  DETAIL
   building_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(request->llist,5))
  IF ((request->llist[x].loc_type_flag=0))
   SET room_cd = request->llist[x].loc_code_value
  ELSEIF ((request->llist[x].loc_type_flag=1))
   SET bed_cd = request->llist[x].loc_code_value
   SELECT INTO "nl:"
    FROM location_group lg
    PLAN (lg
     WHERE lg.child_loc_cd=bed_cd
      AND lg.active_ind=1)
    DETAIL
     room_cd = lg.parent_loc_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    GO TO exit_script
   ENDIF
  ENDIF
  FOR (z = 1 TO size(request->llist[x].vlist,5))
    IF ((request->llist[x].vlist[z].action_flag=1))
     SET update_ind = 0
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE (lg.child_loc_cd=request->llist[x].loc_code_value)
        AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
        AND lg.active_ind=0)
      DETAIL
       update_ind = 1
      WITH nocounter
     ;end select
     SET unit_cd = 0.0
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE lg.child_loc_cd=room_cd
        AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
        AND lg.active_ind=1)
      DETAIL
       unit_cd = lg.parent_loc_cd
      WITH nocounter
     ;end select
     IF (unit_cd=0)
      SELECT INTO "nl:"
       FROM location_group lg
       PLAN (lg
        WHERE lg.child_loc_cd=room_cd
         AND lg.root_loc_cd=0
         AND lg.active_ind=1)
       DETAIL
        unit_cd = lg.parent_loc_cd
       WITH nocounter
      ;end select
      IF (curqual=0)
       GO TO exit_script
      ENDIF
      SET building_cd = 0.0
      SELECT INTO "nl:"
       FROM location_group lg
       PLAN (lg
        WHERE lg.child_loc_cd=unit_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
         AND lg.active_ind=1)
       DETAIL
        building_cd = lg.parent_loc_cd
       WITH nocounter
      ;end select
      IF (building_cd=0)
       SELECT INTO "nl:"
        FROM location_group lg
        PLAN (lg
         WHERE lg.child_loc_cd=unit_cd
          AND lg.location_group_type_cd=building_type_cd
          AND lg.root_loc_cd=0
          AND lg.active_ind=1)
        DETAIL
         building_cd = lg.parent_loc_cd
        WITH nocounter
       ;end select
       IF (curqual=0)
        GO TO exit_script
       ENDIF
       SET facility_cd = 0.0
       SELECT INTO "nl:"
        FROM location_group lg
        PLAN (lg
         WHERE lg.child_loc_cd=building_cd
          AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
          AND lg.active_ind=1)
        DETAIL
         facility_cd = lg.parent_loc_cd
        WITH nocounter
       ;end select
       IF (facility_cd=0)
        SELECT INTO "nl:"
         FROM location_group lg
         PLAN (lg
          WHERE lg.child_loc_cd=building_cd
           AND lg.location_group_type_cd=facility_type_cd
           AND lg.root_loc_cd=0
           AND lg.active_ind=1)
         DETAIL
          facility_cd = lg.parent_loc_cd
         WITH nocounter
        ;end select
        IF (curqual=0)
         GO TO exit_script
        ENDIF
        SET view_cd = 0
        SET view_seq = 0
        SELECT INTO "nl:"
         FROM location_group lg
         PLAN (lg
          WHERE lg.child_loc_cd=facility_cd
           AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
           AND lg.active_ind=1)
         DETAIL
          view_cd = lg.parent_loc_cd
         WITH nocounter
        ;end select
        IF (view_cd=0)
         SELECT INTO "nl:"
          FROM location_group lg
          PLAN (lg
           WHERE (lg.parent_loc_cd=request->llist[x].vlist[z].view_code_value)
            AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
            AND lg.active_ind=1)
          ORDER BY lg.sequence
          DETAIL
           view_cd = lg.parent_loc_cd, view_seq = lg.sequence
          WITH nocounter
         ;end select
         IF (curqual=0)
          SET view_cd = request->llist[x].vlist[z].view_code_value
         ENDIF
         SET update_view = 0
         SELECT INTO "nl:"
          FROM location_group lg
          PLAN (lg
           WHERE (lg.parent_loc_cd=request->llist[x].vlist[z].view_code_value)
            AND lg.child_loc_cd=facility_cd
            AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
            AND lg.active_ind=0)
          DETAIL
           update_view = 1
          WITH nocounter
         ;end select
         IF (update_view=1)
          SET ierrcode = 0
          UPDATE  FROM location_group lg
           SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
            cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
            lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime
            (curdate,curtime3),
            lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm =
            cnvtdatetime(curdate,curtime3),
            lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
           PLAN (lg
            WHERE lg.parent_loc_cd=view_cd
             AND lg.child_loc_cd=facility_cd
             AND lg.root_loc_cd=view_cd)
           WITH nocounter
          ;end update
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           GO TO exit_script
          ENDIF
         ELSE
          SET view_seq = (view_seq+ 2)
          SET ierrcode = 0
          INSERT  FROM location_group lg
           SET lg.parent_loc_cd = view_cd, lg.child_loc_cd = facility_cd, lg.location_group_type_cd
             = root_cd,
            lg.sequence = view_seq, lg.root_loc_cd = view_cd, lg.view_type_cd = 0,
            lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
            cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
            lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime
            (curdate,curtime3),
            lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0, lg.updt_dt_tm = cnvtdatetime(curdate,
             curtime3),
            lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
           PLAN (lg)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = "Y"
           GO TO exit_script
          ENDIF
         ENDIF
        ENDIF
        SET facility_seq = 0
        SELECT INTO "nl:"
         FROM location_group lg
         PLAN (lg
          WHERE lg.parent_loc_cd=facility_cd
           AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
           AND lg.active_ind=1)
         ORDER BY lg.sequence
         DETAIL
          facility_seq = lg.sequence
         WITH nocounter
        ;end select
        SET update_facility = 0
        SELECT INTO "nl:"
         FROM location_group lg
         PLAN (lg
          WHERE lg.parent_loc_cd=facility_cd
           AND lg.child_loc_cd=building_cd
           AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
           AND lg.active_ind=0)
         DETAIL
          update_facility = 1
         WITH nocounter
        ;end select
        IF (update_facility=1)
         SET ierrcode = 0
         UPDATE  FROM location_group lg
          SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
           cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
           lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
            curdate,curtime3),
           lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm =
           cnvtdatetime(curdate,curtime3),
           lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
          PLAN (lg
           WHERE lg.parent_loc_cd=facility_cd
            AND lg.child_loc_cd=building_cd
            AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
          WITH nocounter
         ;end update
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = "Y"
          GO TO exit_script
         ENDIF
        ELSE
         SET facility_seq = (facility_seq+ 2)
         SET ierrcode = 0
         INSERT  FROM location_group lg
          SET lg.parent_loc_cd = facility_cd, lg.child_loc_cd = building_cd, lg
           .location_group_type_cd = facility_type_cd,
           lg.sequence = facility_seq, lg.root_loc_cd = request->llist[x].vlist[z].view_code_value,
           lg.view_type_cd = 0,
           lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
           cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
           lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
            curdate,curtime3),
           lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0, lg.updt_dt_tm = cnvtdatetime(curdate,
            curtime3),
           lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
          PLAN (lg)
          WITH nocounter
         ;end insert
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = "Y"
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       SET building_seq = 0
       SELECT INTO "nl:"
        FROM location_group lg
        PLAN (lg
         WHERE lg.parent_loc_cd=building_cd
          AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
          AND lg.active_ind=1)
        ORDER BY lg.sequence
        DETAIL
         building_seq = lg.sequence
        WITH nocounter
       ;end select
       SET update_building = 0
       SELECT INTO "nl:"
        FROM location_group lg
        PLAN (lg
         WHERE lg.parent_loc_cd=building_cd
          AND lg.child_loc_cd=unit_cd
          AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
          AND lg.active_ind=0)
        DETAIL
         update_building = 1
        WITH nocounter
       ;end select
       IF (update_building=1)
        SET ierrcode = 0
        UPDATE  FROM location_group lg
         SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
          lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
           curdate,curtime3),
          lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime
          (curdate,curtime3),
          lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
         PLAN (lg
          WHERE lg.parent_loc_cd=building_cd
           AND lg.child_loc_cd=unit_cd
           AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         GO TO exit_script
        ENDIF
       ELSE
        SET building_seq = (building_seq+ 2)
        SET ierrcode = 0
        INSERT  FROM location_group lg
         SET lg.parent_loc_cd = building_cd, lg.child_loc_cd = unit_cd, lg.location_group_type_cd =
          building_type_cd,
          lg.sequence = building_seq, lg.root_loc_cd = request->llist[x].vlist[z].view_code_value, lg
          .view_type_cd = 0,
          lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
          lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
           curdate,curtime3),
          lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0, lg.updt_dt_tm = cnvtdatetime(curdate,
           curtime3),
          lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
         PLAN (lg)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      SELECT INTO "nl:"
       FROM code_value cv,
        code_value cv2
       PLAN (cv
        WHERE cv.code_value=unit_cd)
        JOIN (cv2
        WHERE cv2.code_set=222
         AND cv2.cdf_meaning=cv.cdf_meaning)
       DETAIL
        unit_type_cd = cv2.code_value
       WITH nocounter
      ;end select
      SET unit_seq = 0
      SELECT INTO "nl:"
       FROM location_group lg
       PLAN (lg
        WHERE lg.parent_loc_cd=unit_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
         AND lg.active_ind=1)
       ORDER BY lg.sequence
       DETAIL
        unit_seq = lg.sequence
       WITH nocounter
      ;end select
      SET update_unit = 0
      SELECT INTO "nl:"
       FROM location_group lg
       PLAN (lg
        WHERE lg.parent_loc_cd=unit_cd
         AND lg.child_loc_cd=room_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
         AND lg.active_ind=0)
       ORDER BY lg.sequence
       DETAIL
        update_unit = 1
       WITH nocounter
      ;end select
      IF (update_unit=1)
       SET ierrcode = 0
       UPDATE  FROM location_group lg
        SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
         lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
        PLAN (lg
         WHERE lg.parent_loc_cd=unit_cd
          AND lg.child_loc_cd=room_cd
          AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ELSE
       SET unit_seq = (unit_seq+ 2)
       SET ierrcode = 0
       INSERT  FROM location_group lg
        SET lg.parent_loc_cd = unit_cd, lg.child_loc_cd = room_cd, lg.location_group_type_cd =
         unit_type_cd,
         lg.sequence = unit_seq, lg.root_loc_cd = request->llist[x].vlist[z].view_code_value, lg
         .view_type_cd = 0,
         lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
         lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0, lg.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
        PLAN (lg)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
     IF ((request->llist[x].loc_type_flag=1))
      IF (update_ind=1)
       SET ierrcode = 0
       UPDATE  FROM location_group lg
        SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
         lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
        PLAN (lg
         WHERE lg.parent_loc_cd=room_cd
          AND lg.child_loc_cd=bed_cd
          AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ELSE
       SET room_seq = 0
       SELECT INTO "nl:"
        FROM location_group lg
        PLAN (lg
         WHERE lg.parent_loc_cd=room_cd
          AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
          AND lg.active_ind=1)
        ORDER BY lg.sequence
        DETAIL
         room_seq = lg.sequence
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM code_value cv,
         code_value cv2
        PLAN (cv
         WHERE cv.code_value=room_cd)
         JOIN (cv2
         WHERE cv2.code_set=222
          AND cv2.cdf_meaning=cv.cdf_meaning)
        DETAIL
         room_type_cd = cv2.code_value
        WITH nocounter
       ;end select
       SET room_seq = (room_seq+ 2)
       SET ierrcode = 0
       INSERT  FROM location_group lg
        SET lg.parent_loc_cd = room_cd, lg.child_loc_cd = bed_cd, lg.location_group_type_cd =
         room_type_cd,
         lg.sequence = room_seq, lg.root_loc_cd = request->llist[x].vlist[z].view_code_value, lg
         .view_type_cd = 0,
         lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
         lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0, lg.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
        PLAN (lg)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ELSEIF ((request->llist[x].vlist[z].action_flag=3))
     SET unit_cd = 0.0
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE lg.child_loc_cd=room_cd
        AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
        AND lg.active_ind=1)
      DETAIL
       unit_cd = lg.parent_loc_cd
      WITH nocounter
     ;end select
     SET building_cd = 0.0
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE lg.child_loc_cd=unit_cd
        AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
        AND lg.active_ind=1)
      DETAIL
       building_cd = lg.parent_loc_cd
      WITH nocounter
     ;end select
     SET facility_cd = 0.0
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE lg.child_loc_cd=building_cd
        AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
        AND lg.active_ind=1)
      DETAIL
       facility_cd = lg.parent_loc_cd
      WITH nocounter
     ;end select
     IF ((request->llist[x].loc_type_flag=0))
      SET ierrcode = 0
      UPDATE  FROM location_group lg
       SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime3), lg.active_status_prsnl_id = reqinfo->updt_id,
        lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
       PLAN (lg
        WHERE lg.parent_loc_cd=unit_cd
         AND lg.child_loc_cd=room_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF ((request->llist[x].loc_type_flag=1))
      SET ierrcode = 0
      UPDATE  FROM location_group lg
       SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime3), lg.active_status_prsnl_id = reqinfo->updt_id,
        lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
       PLAN (lg
        WHERE lg.parent_loc_cd=room_cd
         AND lg.child_loc_cd=bed_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
      SET room_exists = 0
      SELECT INTO "nl:"
       FROM location_group lg
       PLAN (lg
        WHERE lg.parent_loc_cd=room_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
         AND lg.active_ind=1)
       DETAIL
        room_exists = 1
       WITH nocounter
      ;end select
      IF (room_exists=0)
       SET ierrcode = 0
       UPDATE  FROM location_group lg
        SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
         cnvtdatetime(curdate,curtime3), lg.active_status_prsnl_id = reqinfo->updt_id,
         lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
        PLAN (lg
         WHERE lg.parent_loc_cd=unit_cd
          AND lg.child_loc_cd=room_cd
          AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
     SET unit_exists = 0
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE lg.parent_loc_cd=unit_cd
        AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
        AND lg.active_ind=1)
      DETAIL
       unit_exists = 1
      WITH nocounter
     ;end select
     IF (unit_exists=0)
      SET ierrcode = 0
      UPDATE  FROM location_group lg
       SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime3), lg.active_status_prsnl_id = reqinfo->updt_id,
        lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
       PLAN (lg
        WHERE lg.parent_loc_cd=building_cd
         AND lg.child_loc_cd=unit_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
     SET building_exists = 0
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE lg.parent_loc_cd=building_cd
        AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
        AND lg.active_ind=1)
      DETAIL
       building_exists = 1
      WITH nocounter
     ;end select
     IF (building_exists=0)
      SET ierrcode = 0
      UPDATE  FROM location_group lg
       SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime3), lg.active_status_prsnl_id = reqinfo->updt_id,
        lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
       PLAN (lg
        WHERE lg.parent_loc_cd=facility_cd
         AND lg.child_loc_cd=building_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
     SET facility_exists = 0
     SELECT INTO "nl:"
      FROM location_group lg
      PLAN (lg
       WHERE lg.parent_loc_cd=facility_cd
        AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value)
        AND lg.active_ind=1)
      DETAIL
       facility_exists = 1
      WITH nocounter
     ;end select
     IF (facility_exists=0)
      SET ierrcode = 0
      UPDATE  FROM location_group lg
       SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime3), lg.active_status_prsnl_id = reqinfo->updt_id,
        lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
       PLAN (lg
        WHERE (lg.parent_loc_cd=request->llist[x].vlist[z].view_code_value)
         AND lg.child_loc_cd=facility_cd
         AND (lg.root_loc_cd=request->llist[x].vlist[z].view_code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
