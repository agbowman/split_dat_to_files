CREATE PROGRAM bed_ens_sd_departments:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_types
 RECORD temp_types(
   1 acts[*]
     2 code_value = f8
   1 cats[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc
 SET error_flag = "N"
 FOR (w = 1 TO size(request->departments,5))
   SET update_ind = 0
   IF ((request->departments[w].action_flag=2))
    SELECT INTO "nl:"
     FROM br_sched_dept bsd
     WHERE (bsd.location_cd=request->departments[w].code_value)
     DETAIL
      update_ind = 1
     WITH nocounter
    ;end select
    IF (update_ind=0)
     INSERT  FROM br_sched_dept bsd
      SET bsd.location_cd = request->departments[w].code_value, bsd.dept_type_id = request->
       departments[w].dept_type_id, bsd.dept_prefix = request->departments[w].prefix,
       bsd.updt_id = reqinfo->updt_id, bsd.updt_dt_tm = cnvtdatetime(curdate,curtime3), bsd.updt_task
        = reqinfo->updt_task,
       bsd.updt_applctx = reqinfo->updt_applctx, bsd.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET reply->error_msg = concat("Could not insert department code_value:",trim(cnvtstring(request
         ->departments[x].code_value)))
      GO TO exit_script
     ENDIF
    ELSE
     UPDATE  FROM br_sched_dept bsd
      SET bsd.dept_type_id = request->departments[w].dept_type_id, bsd.dept_prefix = request->
       departments[w].prefix, bsd.updt_id = reqinfo->updt_id,
       bsd.updt_dt_tm = cnvtdatetime(curdate,curtime3), bsd.updt_task = reqinfo->updt_task, bsd
       .updt_applctx = reqinfo->updt_applctx,
       bsd.updt_cnt = (bsd.updt_cnt+ 1)
      WHERE (bsd.location_cd=request->departments[w].code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET reply->error_msg = concat("Could not update department code_value:",trim(cnvtstring(request
         ->departments[x].code_value)))
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->departments[w].action_flag=3))
    DELETE  FROM br_sched_dept_ord_r bsdor
     WHERE (bsdor.location_cd=request->departments[w].code_value)
     WITH nocounter
    ;end delete
    DELETE  FROM br_sched_dept bsd
     WHERE (bsd.location_cd=request->departments[w].code_value)
     WITH nocounter
    ;end delete
   ENDIF
   FOR (x = 1 TO size(request->departments[w].catalog_types,5))
     SET sub_insert_ind = 0
     SET act_insert_ind = 0
     SET cat_delete_ind = 0
     SET act_delete_ind = 0
     IF ((request->departments[w].catalog_types[x].action_flag=3))
      SET cat_delete_ind = 1
      SET act_delete_ind = 1
      DELETE  FROM br_sched_dept_ord_r bsdor
       WHERE (bsdor.location_cd=request->departments[w].code_value)
        AND (bsdor.catalog_type_cd=request->departments[w].catalog_types[x].code_value)
       WITH nocounter
      ;end delete
      IF (curqual=0)
       SET error_flag = "Y"
       SET reply->error_msg = concat("Could not delete catalog type for department code_value:",trim(
         cnvtstring(request->departments[x].code_value)))
       GO TO exit_script
      ENDIF
     ENDIF
     FOR (y = 1 TO size(request->departments[w].catalog_types[x].activity_types,5))
       IF ((request->departments[w].catalog_types[x].activity_types[y].action_flag=3)
        AND cat_delete_ind=0)
        SET act_delete_ind = 1
        DELETE  FROM br_sched_dept_ord_r bsdor
         WHERE (bsdor.location_cd=request->departments[w].code_value)
          AND (bsdor.activity_type_cd=request->departments[w].catalog_types[x].activity_types[y].
         code_value)
         WITH nocounter
        ;end delete
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Could not delete activity type for department code_value:",
          trim(cnvtstring(request->departments[x].code_value)))
         GO TO exit_script
        ENDIF
       ENDIF
       FOR (z = 1 TO size(request->departments[w].catalog_types[x].activity_types[y].
        sub_activity_types,5))
         IF ((request->departments[w].catalog_types[x].activity_types[y].sub_activity_types[z].
         action_flag=1))
          SET sub_insert_ind = 1
          DELETE  FROM br_sched_dept_ord_r bsdor
           WHERE (bsdor.location_cd=request->departments[w].code_value)
            AND (bsdor.catalog_type_cd=request->departments[w].catalog_types[x].code_value)
            AND (bsdor.activity_type_cd=request->departments[w].catalog_types[x].activity_types[y].
           code_value)
            AND bsdor.activity_subtype_cd=0
           WITH nocounter
          ;end delete
          INSERT  FROM br_sched_dept_ord_r bsdor
           SET bsdor.location_cd = request->departments[w].code_value, bsdor.catalog_type_cd =
            request->departments[w].catalog_types[x].code_value, bsdor.activity_type_cd = request->
            departments[w].catalog_types[x].activity_types[y].code_value,
            bsdor.activity_subtype_cd = request->departments[w].catalog_types[x].activity_types[y].
            sub_activity_types[z].code_value, bsdor.updt_id = reqinfo->updt_id, bsdor.updt_dt_tm =
            cnvtdatetime(curdate,curtime3),
            bsdor.updt_task = reqinfo->updt_task, bsdor.updt_applctx = reqinfo->updt_applctx, bsdor
            .updt_cnt = 0
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat(
            "Could not insert subactivity type for department code_value:",trim(cnvtstring(request->
              departments[x].code_value)))
           GO TO exit_script
          ENDIF
         ELSEIF ((request->departments[w].catalog_types[x].activity_types[y].sub_activity_types[z].
         action_flag=3)
          AND act_delete_ind=0)
          DELETE  FROM br_sched_dept_ord_r bsdor
           WHERE (bsdor.location_cd=request->departments[w].code_value)
            AND (bsdor.activity_subtype_cd=request->departments[w].catalog_types[x].activity_types[y]
           .sub_activity_types[z].code_value)
           WITH nocounter
          ;end delete
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat(
            "Could not delete subactivity type for department code_value:",trim(cnvtstring(request->
              departments[x].code_value)))
           GO TO exit_script
          ENDIF
         ENDIF
       ENDFOR
       IF ((request->departments[w].catalog_types[x].activity_types[y].action_flag=1))
        SET act_insert_ind = 1
        IF (sub_insert_ind=0)
         DELETE  FROM br_sched_dept_ord_r bsdor
          WHERE (bsdor.location_cd=request->departments[w].code_value)
           AND (bsdor.catalog_type_cd=request->departments[w].catalog_types[x].code_value)
           AND bsdor.activity_type_cd=0
          WITH nocounter
         ;end delete
         DELETE  FROM br_sched_dept_ord_r bsdor
          WHERE (bsdor.location_cd=request->departments[w].code_value)
           AND (bsdor.catalog_type_cd=request->departments[w].catalog_types[x].code_value)
           AND (bsdor.activity_type_cd=request->departments[w].catalog_types[x].activity_types[y].
          code_value)
          WITH nocounter
         ;end delete
         INSERT  FROM br_sched_dept_ord_r bsdor
          SET bsdor.location_cd = request->departments[w].code_value, bsdor.catalog_type_cd = request
           ->departments[w].catalog_types[x].code_value, bsdor.activity_type_cd = request->
           departments[w].catalog_types[x].activity_types[y].code_value,
           bsdor.activity_subtype_cd = 0, bsdor.updt_id = reqinfo->updt_id, bsdor.updt_dt_tm =
           cnvtdatetime(curdate,curtime3),
           bsdor.updt_task = reqinfo->updt_task, bsdor.updt_applctx = reqinfo->updt_applctx, bsdor
           .updt_cnt = 0
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Could not insert activity type for department code_value:",
           trim(cnvtstring(request->departments[x].code_value)))
          GO TO exit_script
         ENDIF
        ELSE
         SET row_exists = 0
         SELECT INTO "nl:"
          FROM br_sched_dept_ord_r bsdor
          WHERE (bsdor.location_cd=request->departments[w].code_value)
           AND (bsdor.catalog_type_cd=request->departments[w].catalog_types[x].code_value)
           AND (bsdor.activity_type_cd=request->departments[w].catalog_types[x].activity_types[y].
          code_value)
           AND bsdor.activity_subtype_cd=0
          DETAIL
           row_exists = 1
          WITH nocounter
         ;end select
         IF (row_exists=0)
          INSERT  FROM br_sched_dept_ord_r bsdor
           SET bsdor.location_cd = request->departments[w].code_value, bsdor.catalog_type_cd =
            request->departments[w].catalog_types[x].code_value, bsdor.activity_type_cd = request->
            departments[w].catalog_types[x].activity_types[y].code_value,
            bsdor.activity_subtype_cd = 0, bsdor.updt_id = reqinfo->updt_id, bsdor.updt_dt_tm =
            cnvtdatetime(curdate,curtime3),
            bsdor.updt_task = reqinfo->updt_task, bsdor.updt_applctx = reqinfo->updt_applctx, bsdor
            .updt_cnt = 0
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Could not insert activity type for department code_value:",
            trim(cnvtstring(request->departments[x].code_value)))
           GO TO exit_script
          ENDIF
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF ((request->departments[w].catalog_types[x].action_flag=1))
      IF (act_insert_ind=0)
       DELETE  FROM br_sched_dept_ord_r bsdor
        WHERE (bsdor.location_cd=request->departments[w].code_value)
         AND bsdor.catalog_type_cd=0
        WITH nocounter
       ;end delete
       DELETE  FROM br_sched_dept_ord_r bsdor
        WHERE (bsdor.location_cd=request->departments[w].code_value)
         AND (bsdor.catalog_type_cd=request->departments[w].catalog_types[x].code_value)
        WITH nocounter
       ;end delete
       INSERT  FROM br_sched_dept_ord_r bsdor
        SET bsdor.location_cd = request->departments[w].code_value, bsdor.catalog_type_cd = request->
         departments[w].catalog_types[x].code_value, bsdor.activity_type_cd = 0,
         bsdor.activity_subtype_cd = 0, bsdor.updt_id = reqinfo->updt_id, bsdor.updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         bsdor.updt_task = reqinfo->updt_task, bsdor.updt_applctx = reqinfo->updt_applctx, bsdor
         .updt_cnt = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Could not insert catalog type for department code_value:",trim
         (cnvtstring(request->departments[x].code_value)))
        GO TO exit_script
       ENDIF
      ELSE
       SET row_exists = 0
       SELECT INTO "nl:"
        FROM br_sched_dept_ord_r bsdor
        WHERE (bsdor.location_cd=request->departments[w].code_value)
         AND (bsdor.catalog_type_cd=request->departments[w].catalog_types[x].code_value)
         AND bsdor.activity_type_cd=0
         AND bsdor.activity_subtype_cd=0
        DETAIL
         row_exists = 1
        WITH nocounter
       ;end select
       IF (row_exists=0)
        INSERT  FROM br_sched_dept_ord_r bsdor
         SET bsdor.location_cd = request->departments[w].code_value, bsdor.catalog_type_cd = request
          ->departments[w].catalog_types[x].code_value, bsdor.activity_type_cd = 0,
          bsdor.activity_subtype_cd = 0, bsdor.updt_id = reqinfo->updt_id, bsdor.updt_dt_tm =
          cnvtdatetime(curdate,curtime3),
          bsdor.updt_task = reqinfo->updt_task, bsdor.updt_applctx = reqinfo->updt_applctx, bsdor
          .updt_cnt = 0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Could not insert catalog type for department code_value:",
          trim(cnvtstring(request->departments[x].code_value)))
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
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
