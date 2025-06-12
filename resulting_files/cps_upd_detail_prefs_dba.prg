CREATE PROGRAM cps_upd_detail_prefs:dba
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
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET reply->status_data.status = "F"
 SET dvar = 0
 SET app_num = 0
 SET pos_cd = 0.0
 SET prsnl_id = 0.0
 IF ((request->app_qual > 0))
  SET ierrcode = 0
  CALL update_app_level(dvar)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->position_qual > 0))
  SET ierrcode = 0
  CALL update_pos_level(dvar)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->prsnl_qual > 0))
  SET ierrcode = 0
  CALL update_prsnl_level(dvar)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE update_app_level(lvar)
   FOR (i = 1 TO request->app_qual)
     SET app_num = request->app[i].app_number
     SET pos_cd = 0.0
     SET prsnl_id = 0.0
     IF ((request->app[i].group_qual > 0))
      FOR (j = 1 TO request->app[i].group_qual)
       SET detail_id = 0.0
       IF ((request->app[i].group[j].group_id > 0))
        SET detail_id = request->app[i].group[j].group_id
        FOR (k = 1 TO request->app[i].group[j].pref_qual)
          SET pref_id = 0.0
          SELECT
           IF ((request->app[i].group[j].pref[k].pref_id > 0))
            PLAN (nvp
             WHERE (nvp.name_value_prefs_id=request->app[i].group[j].pref[k].pref_id))
           ELSE
            PLAN (nvp
             WHERE nvp.parent_entity_id=detail_id
              AND nvp.parent_entity_name="DETAIL_PREFS"
              AND (trim(nvp.pvc_name)=request->app[i].group[j].pref[k].pref_name))
           ENDIF
           INTO "nl:"
           FROM name_value_prefs nvp
           HEAD REPORT
            pref_id = nvp.name_value_prefs_id
           WITH nocounter, forupdate(nvp)
          ;end select
          IF (curqual > 0)
           UPDATE  FROM name_value_prefs nvp
            SET nvp.pvc_name = request->app[i].group[j].pref[k].pref_name, nvp.pvc_value = request->
             app[i].group[j].pref[k].pref_value, nvp.sequence = request->app[i].group[j].pref[k].
             sequence,
             nvp.merge_id = request->app[i].group[j].pref[k].merge_id, nvp.merge_name = request->app[
             i].group[j].pref[k].merge_name, nvp.active_ind = request->app[i].group[j].pref[k].
             active_ind,
             nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
             reqinfo->updt_task,
             nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1)
            PLAN (nvp
             WHERE nvp.name_value_prefs_id=pref_id)
            WITH nocounter
           ;end update
          ELSE
           INSERT  FROM name_value_prefs nvp
            SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
             "DETAIL_PREFS", nvp.parent_entity_id = detail_id,
             nvp.pvc_name = request->app[i].group[j].pref[k].pref_name, nvp.pvc_value = request->app[
             i].group[j].pref[k].pref_value, nvp.sequence = request->app[i].group[j].pref[k].sequence,
             nvp.merge_id = request->app[i].group[j].pref[k].merge_id, nvp.merge_name = request->app[
             i].group[j].pref[k].merge_name, nvp.active_ind = request->app[i].group[j].pref[k].
             active_ind,
             nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
             reqinfo->updt_task,
             nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
            WITH nocounter
           ;end insert
          ENDIF
        ENDFOR
       ELSE
        SELECT INTO "nl:"
         FROM detail_prefs dp
         PLAN (dp
          WHERE dp.prsnl_id=0
           AND dp.position_cd=0
           AND dp.application_number=app_num
           AND (dp.view_name=request->app[i].group[j].view_name)
           AND (dp.view_seq=request->app[i].group[j].view_seq)
           AND (dp.comp_name=request->app[i].group[j].comp_name)
           AND (dp.comp_seq=request->app[i].group[j].comp_seq)
           AND dp.active_ind > 0)
         HEAD REPORT
          detail_id = dp.detail_prefs_id
         WITH nocounter
        ;end select
        IF (curqual < 1)
         SELECT INTO "nl:"
          temp_value = seq(carenet_seq,nextval)
          FROM dual
          DETAIL
           detail_id = cnvtreal(temp_value)
          WITH format, nocounter
         ;end select
         INSERT  FROM detail_prefs dp
          SET dp.detail_prefs_id = detail_id, dp.application_number = app_num, dp.position_cd =
           pos_cd,
           dp.prsnl_id = prsnl_id, dp.person_id = 0.0, dp.view_name = request->app[i].group[j].
           view_name,
           dp.view_seq = request->app[i].group[j].view_seq, dp.comp_name = request->app[i].group[j].
           comp_name, dp.comp_seq = request->app[i].group[j].comp_seq,
           dp.active_ind = 1, dp.updt_dt_tm = cnvtdatetime(sysdate), dp.updt_id = reqinfo->updt_id,
           dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_cnt =
           0
          WITH nocounter
         ;end insert
         IF ((request->app[i].group[j].pref_qual > 0))
          INSERT  FROM name_value_prefs nvp,
            (dummyt d  WITH seq = value(request->app[i].group[j].pref_qual))
           SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp
            .parent_entity_name = "DETAIL_PREFS",
            nvp.parent_entity_id = detail_id, nvp.pvc_name = request->app[i].group[j].pref[d.seq].
            pref_name, nvp.pvc_value = request->app[i].group[j].pref[d.seq].pref_value,
            nvp.sequence = request->app[i].group[j].pref[d.seq].sequence, nvp.merge_id = request->
            app[i].group[j].pref[d.seq].merge_id, nvp.merge_name = request->app[i].group[j].pref[d
            .seq].merge_name,
            nvp.active_ind = request->app[i].group[j].pref[d.seq].active_ind, nvp.updt_dt_tm =
            cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id,
            nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp
            .updt_cnt = 0
           PLAN (d
            WHERE d.seq > 0)
            JOIN (nvp
            WHERE 0=0)
          ;end insert
         ENDIF
        ELSE
         FOR (k = 1 TO request->app[i].group[j].pref_qual)
           SET pref_id = 0.0
           SELECT
            IF ((request->app[i].group[j].pref[k].pref_id > 0))
             PLAN (nvp
              WHERE (nvp.name_value_prefs_id=request->app[i].group[j].pref[k].pref_id))
            ELSE
             PLAN (nvp
              WHERE nvp.parent_entity_id=detail_id
               AND nvp.parent_entity_name="DETAIL_PREFS"
               AND (trim(nvp.pvc_name)=request->app[i].group[j].pref[k].pref_name))
            ENDIF
            INTO "nl:"
            FROM name_value_prefs nvp
            HEAD REPORT
             pref_id = nvp.name_value_prefs_id
            WITH nocounter, forupdate(nvp)
           ;end select
           IF (curqual > 0)
            UPDATE  FROM name_value_prefs nvp
             SET nvp.pvc_name = request->app[i].group[j].pref[k].pref_name, nvp.pvc_value = request->
              app[i].group[j].pref[k].pref_value, nvp.sequence = request->app[i].group[j].pref[k].
              sequence,
              nvp.merge_id = request->app[i].group[j].pref[k].merge_id, nvp.merge_name = request->
              app[i].group[j].pref[k].merge_name, nvp.active_ind = request->app[i].group[j].pref[k].
              active_ind,
              nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
               = reqinfo->updt_task,
              nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1)
             PLAN (nvp
              WHERE nvp.name_value_prefs_id=pref_id)
             WITH nocounter
            ;end update
           ELSE
            INSERT  FROM name_value_prefs nvp
             SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
              "DETAIL_PREFS", nvp.parent_entity_id = detail_id,
              nvp.pvc_name = request->app[i].group[j].pref[k].pref_name, nvp.pvc_value = request->
              app[i].group[j].pref[k].pref_value, nvp.sequence = request->app[i].group[j].pref[k].
              sequence,
              nvp.merge_id = request->app[i].group[j].pref[k].merge_id, nvp.merge_name = request->
              app[i].group[j].pref[k].merge_name, nvp.active_ind = request->app[i].group[j].pref[k].
              active_ind,
              nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
               = reqinfo->updt_task,
              nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
             WITH nocounter
            ;end insert
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE update_pos_level(lvar)
   FOR (i = 1 TO request->position_qual)
     SET app_num = request->position[i].app_number
     SET pos_cd = request->position[i].position_cd
     SET prsnl_id = 0.0
     IF ((request->position[i].group_qual > 0))
      FOR (j = 1 TO request->position[i].group_qual)
       SET detail_id = 0.0
       IF ((request->position[i].group[j].group_id > 0))
        SET detail_id = request->position[i].group[j].group_id
        FOR (k = 1 TO request->position[i].group[j].pref_qual)
          SET pref_id = 0.0
          SELECT
           IF ((request->position[i].group[j].pref[k].pref_id > 0))
            PLAN (nvp
             WHERE (nvp.name_value_prefs_id=request->position[i].group[j].pref[k].pref_id))
           ELSE
            PLAN (nvp
             WHERE nvp.parent_entity_id=detail_id
              AND nvp.parent_entity_name="DETAIL_PREFS"
              AND (trim(nvp.pvc_name)=request->position[i].group[j].pref[k].pref_name))
           ENDIF
           INTO "nl:"
           FROM name_value_prefs nvp
           HEAD REPORT
            pref_id = nvp.name_value_prefs_id
           WITH nocounter, forupdate(nvp)
          ;end select
          IF (curqual > 0)
           UPDATE  FROM name_value_prefs nvp
            SET nvp.pvc_name = request->position[i].group[j].pref[k].pref_name, nvp.pvc_value =
             request->position[i].group[j].pref[k].pref_value, nvp.sequence = request->position[i].
             group[j].pref[k].sequence,
             nvp.merge_id = request->position[i].group[j].pref[k].merge_id, nvp.merge_name = request
             ->position[i].group[j].pref[k].merge_name, nvp.active_ind = request->position[i].group[j
             ].pref[k].active_ind,
             nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
             reqinfo->updt_task,
             nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1)
            PLAN (nvp
             WHERE nvp.name_value_prefs_id=pref_id)
            WITH nocounter
           ;end update
          ELSE
           INSERT  FROM name_value_prefs nvp
            SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
             "DETAIL_PREFS", nvp.parent_entity_id = detail_id,
             nvp.pvc_name = request->position[i].group[j].pref[k].pref_name, nvp.pvc_value = request
             ->position[i].group[j].pref[k].pref_value, nvp.sequence = request->position[i].group[j].
             pref[k].sequence,
             nvp.merge_id = request->position[i].group[j].pref[k].merge_id, nvp.merge_name = request
             ->position[i].group[j].pref[k].merge_name, nvp.active_ind = request->position[i].group[j
             ].pref[k].active_ind,
             nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
             reqinfo->updt_task,
             nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
            WITH nocounter
           ;end insert
          ENDIF
        ENDFOR
       ELSE
        SELECT INTO "nl:"
         FROM detail_prefs dp
         PLAN (dp
          WHERE dp.prsnl_id=0
           AND dp.position_cd=pos_cd
           AND dp.application_number=app_num
           AND (dp.view_name=request->position[i].group[j].view_name)
           AND (dp.view_seq=request->position[i].group[j].view_seq)
           AND (dp.comp_name=request->position[i].group[j].comp_name)
           AND (dp.comp_seq=request->position[i].group[j].comp_seq)
           AND dp.active_ind > 0)
         HEAD REPORT
          detail_id = dp.detail_prefs_id
         WITH nocounter
        ;end select
        IF (curqual < 1)
         SELECT INTO "nl:"
          temp_value = seq(carenet_seq,nextval)
          FROM dual
          DETAIL
           detail_id = cnvtreal(temp_value)
          WITH format, nocounter
         ;end select
         INSERT  FROM detail_prefs dp
          SET dp.detail_prefs_id = detail_id, dp.application_number = app_num, dp.position_cd =
           pos_cd,
           dp.prsnl_id = prsnl_id, dp.person_id = 0.0, dp.view_name = request->position[i].group[j].
           view_name,
           dp.view_seq = request->position[i].group[j].view_seq, dp.comp_name = request->position[i].
           group[j].comp_name, dp.comp_seq = request->position[i].group[j].comp_seq,
           dp.active_ind = 1, dp.updt_dt_tm = cnvtdatetime(sysdate), dp.updt_id = reqinfo->updt_id,
           dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_cnt =
           0
          WITH nocounter
         ;end insert
         IF ((request->position[i].group[j].pref_qual > 0))
          INSERT  FROM name_value_prefs nvp,
            (dummyt d  WITH seq = value(request->position[i].group[j].pref_qual))
           SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp
            .parent_entity_name = "DETAIL_PREFS",
            nvp.parent_entity_id = detail_id, nvp.pvc_name = request->position[i].group[j].pref[d.seq
            ].pref_name, nvp.pvc_value = request->position[i].group[j].pref[d.seq].pref_value,
            nvp.sequence = request->position[i].group[j].pref[d.seq].sequence, nvp.merge_id = request
            ->position[i].group[j].pref[d.seq].merge_id, nvp.merge_name = request->position[i].group[
            j].pref[d.seq].merge_name,
            nvp.active_ind = request->position[i].group[j].pref[d.seq].active_ind, nvp.updt_dt_tm =
            cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id,
            nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp
            .updt_cnt = 0
           PLAN (d
            WHERE d.seq > 0)
            JOIN (nvp
            WHERE 0=0)
          ;end insert
         ENDIF
        ELSE
         FOR (k = 1 TO request->position[i].group[j].pref_qual)
           SET pref_id = 0.0
           SELECT
            IF ((request->position[i].group[j].pref[k].pref_id > 0))
             PLAN (nvp
              WHERE (nvp.name_value_prefs_id=request->position[i].group[j].pref[k].pref_id))
            ELSE
             PLAN (nvp
              WHERE nvp.parent_entity_id=detail_id
               AND nvp.parent_entity_name="DETAIL_PREFS"
               AND (trim(nvp.pvc_name)=request->position[i].group[j].pref[k].pref_name))
            ENDIF
            INTO "nl:"
            FROM name_value_prefs nvp
            HEAD REPORT
             pref_id = nvp.name_value_prefs_id
            WITH nocounter, forupdate(nvp)
           ;end select
           IF (curqual > 0)
            UPDATE  FROM name_value_prefs nvp
             SET nvp.pvc_name = request->position[i].group[j].pref[k].pref_name, nvp.pvc_value =
              request->position[i].group[j].pref[k].pref_value, nvp.sequence = request->position[i].
              group[j].pref[k].sequence,
              nvp.merge_id = request->position[i].group[j].pref[k].merge_id, nvp.merge_name = request
              ->position[i].group[j].pref[k].merge_name, nvp.active_ind = request->position[i].group[
              j].pref[k].active_ind,
              nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
               = reqinfo->updt_task,
              nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1)
             PLAN (nvp
              WHERE nvp.name_value_prefs_id=pref_id)
             WITH nocounter
            ;end update
           ELSE
            INSERT  FROM name_value_prefs nvp
             SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
              "DETAIL_PREFS", nvp.parent_entity_id = detail_id,
              nvp.pvc_name = request->position[i].group[j].pref[k].pref_name, nvp.pvc_value = request
              ->position[i].group[j].pref[k].pref_value, nvp.sequence = request->position[i].group[j]
              .pref[k].sequence,
              nvp.merge_id = request->position[i].group[j].pref[k].merge_id, nvp.merge_name = request
              ->position[i].group[j].pref[k].merge_name, nvp.active_ind = request->position[i].group[
              j].pref[k].active_ind,
              nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
               = reqinfo->updt_task,
              nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
             WITH nocounter
            ;end insert
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE update_prsnl_level(lvar)
   FOR (i = 1 TO request->prsnl_qual)
     SET app_num = request->prsnl[i].app_number
     SET pos_cd = 0.0
     SET prsnl_id = request->prsnl[i].prsnl_id
     IF ((request->prsnl[i].group_qual > 0))
      FOR (j = 1 TO request->prsnl[i].group_qual)
       SET detail_id = 0.0
       IF ((request->prsnl[i].group[j].group_id > 0))
        SET detail_id = request->prsnl[i].group[j].group_id
        FOR (k = 1 TO request->prsnl[i].group[j].pref_qual)
          SET pref_id = 0.0
          SELECT
           IF ((request->prsnl[i].group[j].pref[k].pref_id > 0))
            PLAN (nvp
             WHERE (nvp.name_value_prefs_id=request->prsnl[i].group[j].pref[k].pref_id))
           ELSE
            PLAN (nvp
             WHERE nvp.parent_entity_id=detail_id
              AND nvp.parent_entity_name="DETAIL_PREFS"
              AND (trim(nvp.pvc_name)=request->prsnl[i].group[j].pref[k].pref_name))
           ENDIF
           INTO "nl:"
           FROM name_value_prefs nvp
           HEAD REPORT
            pref_id = nvp.name_value_prefs_id
           WITH nocounter, forupdate(nvp)
          ;end select
          IF (curqual > 0)
           UPDATE  FROM name_value_prefs nvp
            SET nvp.pvc_name = request->prsnl[i].group[j].pref[k].pref_name, nvp.pvc_value = request
             ->prsnl[i].group[j].pref[k].pref_value, nvp.sequence = request->prsnl[i].group[j].pref[k
             ].sequence,
             nvp.merge_id = request->prsnl[i].group[j].pref[k].merge_id, nvp.merge_name = request->
             prsnl[i].group[j].pref[k].merge_name, nvp.active_ind = request->prsnl[i].group[j].pref[k
             ].active_ind,
             nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
             reqinfo->updt_task,
             nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1)
            PLAN (nvp
             WHERE nvp.name_value_prefs_id=pref_id)
            WITH nocounter
           ;end update
          ELSE
           INSERT  FROM name_value_prefs nvp
            SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
             "DETAIL_PREFS", nvp.parent_entity_id = detail_id,
             nvp.pvc_name = request->prsnl[i].group[j].pref[k].pref_name, nvp.pvc_value = request->
             prsnl[i].group[j].pref[k].pref_value, nvp.sequence = request->prsnl[i].group[j].pref[k].
             sequence,
             nvp.merge_id = request->prsnl[i].group[j].pref[k].merge_id, nvp.merge_name = request->
             prsnl[i].group[j].pref[k].merge_name, nvp.active_ind = request->prsnl[i].group[j].pref[k
             ].active_ind,
             nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
             reqinfo->updt_task,
             nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
            WITH nocounter
           ;end insert
          ENDIF
        ENDFOR
       ELSE
        SELECT INTO "nl:"
         FROM detail_prefs dp
         PLAN (dp
          WHERE dp.prsnl_id=prsnl_id
           AND dp.position_cd=0
           AND dp.application_number=app_num
           AND (dp.view_name=request->prsnl[i].group[j].view_name)
           AND (dp.view_seq=request->prsnl[i].group[j].view_seq)
           AND (dp.comp_name=request->prsnl[i].group[j].comp_name)
           AND (dp.comp_seq=request->prsnl[i].group[j].comp_seq)
           AND dp.active_ind > 0)
         HEAD REPORT
          detail_id = dp.detail_prefs_id
         WITH nocounter
        ;end select
        IF (curqual < 1)
         SELECT INTO "nl:"
          temp_value = seq(carenet_seq,nextval)
          FROM dual
          DETAIL
           detail_id = cnvtreal(temp_value)
          WITH format, nocounter
         ;end select
         INSERT  FROM detail_prefs dp
          SET dp.detail_prefs_id = detail_id, dp.application_number = app_num, dp.position_cd =
           pos_cd,
           dp.prsnl_id = prsnl_id, dp.person_id = 0.0, dp.view_name = request->prsnl[i].group[j].
           view_name,
           dp.view_seq = request->prsnl[i].group[j].view_seq, dp.comp_name = request->prsnl[i].group[
           j].comp_name, dp.comp_seq = request->prsnl[i].group[j].comp_seq,
           dp.active_ind = 1, dp.updt_dt_tm = cnvtdatetime(sysdate), dp.updt_id = reqinfo->updt_id,
           dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_cnt =
           0
          WITH nocounter
         ;end insert
         IF ((request->prsnl[i].group[j].pref_qual > 0))
          INSERT  FROM name_value_prefs nvp,
            (dummyt d  WITH seq = value(request->prsnl[i].group[j].pref_qual))
           SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp
            .parent_entity_name = "DETAIL_PREFS",
            nvp.parent_entity_id = detail_id, nvp.pvc_name = request->prsnl[i].group[j].pref[d.seq].
            pref_name, nvp.pvc_value = request->prsnl[i].group[j].pref[d.seq].pref_value,
            nvp.sequence = request->prsnl[i].group[j].pref[d.seq].sequence, nvp.merge_id = request->
            prsnl[i].group[j].pref[d.seq].merge_id, nvp.merge_name = request->prsnl[i].group[j].pref[
            d.seq].merge_name,
            nvp.active_ind = request->prsnl[i].group[j].pref[d.seq].active_ind, nvp.updt_dt_tm =
            cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id,
            nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp
            .updt_cnt = 0
           PLAN (d
            WHERE d.seq > 0)
            JOIN (nvp
            WHERE 0=0)
          ;end insert
         ENDIF
        ELSE
         FOR (k = 1 TO request->prsnl[i].group[j].pref_qual)
           SET pref_id = 0.0
           SELECT
            IF ((request->prsnl[i].group[j].pref[k].pref_id > 0))
             PLAN (nvp
              WHERE (nvp.name_value_prefs_id=request->prsnl[i].group[j].pref[k].pref_id))
            ELSE
             PLAN (nvp
              WHERE nvp.parent_entity_id=detail_id
               AND nvp.parent_entity_name="DETAIL_PREFS"
               AND (trim(nvp.pvc_name)=request->prsnl[i].group[j].pref[k].pref_name))
            ENDIF
            INTO "nl:"
            FROM name_value_prefs nvp
            HEAD REPORT
             pref_id = nvp.name_value_prefs_id
            WITH nocounter, forupdate(nvp)
           ;end select
           IF (curqual > 0)
            UPDATE  FROM name_value_prefs nvp
             SET nvp.pvc_name = request->prsnl[i].group[j].pref[k].pref_name, nvp.pvc_value = request
              ->prsnl[i].group[j].pref[k].pref_value, nvp.sequence = request->prsnl[i].group[j].pref[
              k].sequence,
              nvp.merge_id = request->prsnl[i].group[j].pref[k].merge_id, nvp.merge_name = request->
              prsnl[i].group[j].pref[k].merge_name, nvp.active_ind = request->prsnl[i].group[j].pref[
              k].active_ind,
              nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
               = reqinfo->updt_task,
              nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1)
             PLAN (nvp
              WHERE nvp.name_value_prefs_id=pref_id)
             WITH nocounter
            ;end update
           ELSE
            INSERT  FROM name_value_prefs nvp
             SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
              "DETAIL_PREFS", nvp.parent_entity_id = detail_id,
              nvp.pvc_name = request->prsnl[i].group[j].pref[k].pref_name, nvp.pvc_value = request->
              prsnl[i].group[j].pref[k].pref_value, nvp.sequence = request->prsnl[i].group[j].pref[k]
              .sequence,
              nvp.merge_id = request->prsnl[i].group[j].pref[k].merge_id, nvp.merge_name = request->
              prsnl[i].group[j].pref[k].merge_name, nvp.active_ind = request->prsnl[i].group[j].pref[
              k].active_ind,
              nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
               = reqinfo->updt_task,
              nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
             WITH nocounter
            ;end insert
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF (failed != false)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
