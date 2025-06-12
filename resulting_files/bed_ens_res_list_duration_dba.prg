CREATE PROGRAM bed_ens_res_list_duration:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET res_role_code = 0
 SET pat_ind = 0
 SET req_list_cnt = size(request->resource_lists,5)
 FOR (x = 1 TO req_list_cnt)
   SET req_set_cnt = size(request->resource_lists[x].resource_sets,5)
   FOR (y = 1 TO req_set_cnt)
     SET req_res_cnt = size(request->resource_lists[x].resource_sets[y].resources,5)
     SET pat_ind = 0
     SELECT INTO "nl:"
      FROM sch_list_role s
      PLAN (s
       WHERE (s.res_list_id=request->resource_lists[x].res_list_id)
        AND (s.list_role_id=request->resource_lists[x].resource_sets[y].res_set_id)
        AND s.role_meaning="PATIENT")
      DETAIL
       pat_ind = 1
      WITH nocounter
     ;end select
     FOR (z = 1 TO req_res_cnt)
      SET req_slot_cnt = size(request->resource_lists[x].resource_sets[y].resources[z].slot_types,5)
      FOR (a = 1 TO req_slot_cnt)
        DECLARE dur_unit_mean = vc
        SELECT INTO "nl:"
         FROM code_value cv
         WHERE (cv.code_value=request->resource_lists[x].resource_sets[y].resources[z].slot_types[a].
         duration_unit_code_value)
          AND cv.active_ind=1
         DETAIL
          dur_unit_mean = cv.cdf_meaning
         WITH nocounter
        ;end select
        DECLARE off_unit_mean = vc
        SELECT INTO "nl:"
         FROM code_value cv
         WHERE (cv.code_value=request->resource_lists[x].resource_sets[y].resources[z].slot_types[a].
         offset_unit_code_value)
          AND cv.active_ind=1
         DETAIL
          off_unit_mean = cv.cdf_meaning
         WITH nocounter
        ;end select
        IF (pat_ind=0)
         DECLARE set_unit_mean = vc
         SELECT INTO "nl:"
          FROM code_value cv
          WHERE (cv.code_value=request->resource_lists[x].resource_sets[y].resources[z].slot_types[a]
          .setup_unit_code_value)
           AND cv.active_ind=1
          DETAIL
           set_unit_mean = cv.cdf_meaning
          WITH nocounter
         ;end select
         DECLARE clean_unit_mean = vc
         SELECT INTO "nl:"
          FROM code_value cv
          WHERE (cv.code_value=request->resource_lists[x].resource_sets[y].resources[z].slot_types[a]
          .cleanup_unit_code_value)
           AND cv.active_ind=1
          DETAIL
           clean_unit_mean = cv.cdf_meaning
          WITH nocounter
         ;end select
         UPDATE  FROM sch_list_slot s
          SET s.setup_units = request->resource_lists[x].resource_sets[y].resources[z].slot_types[a].
           setup_duration, s.setup_units_cd = request->resource_lists[x].resource_sets[y].resources[z
           ].slot_types[a].setup_unit_code_value, s.setup_units_meaning = set_unit_mean,
           s.duration_role_id = request->resource_lists[x].resource_sets[y].resources[z].slot_types[a
           ].inherit_duration_from_id, s.duration_units = request->resource_lists[x].resource_sets[y]
           .resources[z].slot_types[a].duration, s.duration_units_cd = request->resource_lists[x].
           resource_sets[y].resources[z].slot_types[a].duration_unit_code_value,
           s.duration_units_meaning = dur_unit_mean, s.cleanup_units = request->resource_lists[x].
           resource_sets[y].resources[z].slot_types[a].cleanup_duration, s.cleanup_units_cd = request
           ->resource_lists[x].resource_sets[y].resources[z].slot_types[a].cleanup_unit_code_value,
           s.cleanup_units_meaning = clean_unit_mean, s.offset_role_id = request->resource_lists[x].
           resource_sets[y].resources[z].slot_types[a].offset_from_id, s.offset_beg_units = request->
           resource_lists[x].resource_sets[y].resources[z].slot_types[a].offset,
           s.offset_beg_units_cd = request->resource_lists[x].resource_sets[y].resources[z].
           slot_types[a].offset_unit_code_value, s.offset_beg_units_meaning = off_unit_mean, s
           .offset_end_units = request->resource_lists[x].resource_sets[y].resources[z].slot_types[a]
           .offset,
           s.offset_end_units_cd = request->resource_lists[x].resource_sets[y].resources[z].
           slot_types[a].offset_unit_code_value, s.offset_end_units_meaning = off_unit_mean, s
           .display_seq = request->resource_lists[x].resource_sets[y].resources[z].slot_types[a].
           slot_type_seq,
           s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task
            = reqinfo->updt_task,
           s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
          WHERE (s.list_role_id=request->resource_lists[x].resource_sets[y].res_set_id)
           AND (s.resource_cd=request->resource_lists[x].resource_sets[y].resources[z].
          sch_resource_code_value)
           AND (s.slot_type_id=request->resource_lists[x].resource_sets[y].resources[z].slot_types[a]
          .slot_type_id)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update resource: ",trim(cnvtstring(request->
             resource_lists[x].resource_sets[y].resources[z].sch_resource_code_value)),
           " resource on sch_list_slot.")
          GO TO exit_script
         ENDIF
        ELSE
         DECLARE arr_unit_mean = vc
         SELECT INTO "nl:"
          FROM code_value cv
          WHERE (cv.code_value=request->resource_lists[x].resource_sets[y].resources[z].slot_types[a]
          .arrival_unit_code_value)
           AND cv.active_ind=1
          DETAIL
           arr_unit_mean = cv.cdf_meaning
          WITH nocounter
         ;end select
         DECLARE rec_unit_mean = vc
         SELECT INTO "nl:"
          FROM code_value cv
          WHERE (cv.code_value=request->resource_lists[x].resource_sets[y].resources[z].slot_types[a]
          .recovery_unit_code_value)
           AND cv.active_ind=1
          DETAIL
           rec_unit_mean = cv.cdf_meaning
          WITH nocounter
         ;end select
         UPDATE  FROM sch_list_slot s
          SET s.setup_units = request->resource_lists[x].resource_sets[y].resources[z].slot_types[a].
           arrival_duration, s.setup_units_cd = request->resource_lists[x].resource_sets[y].
           resources[z].slot_types[a].arrival_unit_code_value, s.setup_units_meaning = set_unit_mean,
           s.duration_role_id = request->resource_lists[x].resource_sets[y].resources[z].slot_types[a
           ].inherit_duration_from_id, s.duration_units = request->resource_lists[x].resource_sets[y]
           .resources[z].slot_types[a].duration, s.duration_units_cd = request->resource_lists[x].
           resource_sets[y].resources[z].slot_types[a].duration_unit_code_value,
           s.duration_units_meaning = dur_unit_mean, s.cleanup_units = request->resource_lists[x].
           resource_sets[y].resources[z].slot_types[a].recovery_duration, s.cleanup_units_cd =
           request->resource_lists[x].resource_sets[y].resources[z].slot_types[a].
           recovery_unit_code_value,
           s.cleanup_units_meaning = clean_unit_mean, s.offset_role_id = request->resource_lists[x].
           resource_sets[y].resources[z].slot_types[a].offset_from_id, s.offset_beg_units = request->
           resource_lists[x].resource_sets[y].resources[z].slot_types[a].offset,
           s.offset_beg_units_cd = request->resource_lists[x].resource_sets[y].resources[z].
           slot_types[a].offset_unit_code_value, s.offset_beg_units_meaning = off_unit_mean, s
           .offset_end_units = request->resource_lists[x].resource_sets[y].resources[z].slot_types[a]
           .offset,
           s.offset_end_units_cd = request->resource_lists[x].resource_sets[y].resources[z].
           slot_types[a].offset_unit_code_value, s.offset_end_units_meaning = off_unit_mean, s
           .display_seq = request->resource_lists[x].resource_sets[y].resources[z].slot_types[a].
           slot_type_seq,
           s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task
            = reqinfo->updt_task,
           s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1)
          WHERE (s.list_role_id=request->resource_lists[x].resource_sets[y].res_set_id)
           AND (s.resource_cd=request->resource_lists[x].resource_sets[y].resources[z].
          sch_resource_code_value)
           AND (s.slot_type_id=request->resource_lists[x].resource_sets[y].resources[z].slot_types[a]
          .slot_type_id)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to update resource: ",trim(cnvtstring(request->
             resource_lists[x].resource_sets[y].resources[z].sch_resource_code_value)),
           " resource on sch_list_slot.")
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
     ENDFOR
   ENDFOR
   SET appt_cnt = 0
   SET appt_cnt = size(request->resource_lists[x].appointment_types,5)
   FOR (a = 1 TO appt_cnt)
    UPDATE  FROM sch_appt_loc a
     SET a.res_list_id = request->resource_lists[x].res_list_id, a.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), a.updt_id = reqinfo->updt_id,
      a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
      .updt_cnt+ 1)
     WHERE (a.appt_type_cd=request->resource_lists[x].appointment_types[a].appt_type_code_value)
      AND (a.location_cd=request->resource_lists[x].appointment_types[a].dept_code_value)
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to associate resource list: ",trim(cnvtstring(request->
        resource_lists[x].res_list_id))," to appointment type: ",trim(cnvtstring(request->
        resource_lists[x].appointment_types[a].appt_type_code_value))," on sch_appt_loc.")
     GO TO exit_script
    ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
