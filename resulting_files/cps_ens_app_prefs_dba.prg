CREATE PROGRAM cps_ens_app_prefs:dba
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
 SET reply->status_data.status = "F"
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
 SET app_prefs_id = 0.0
 SET pref_id = 0.0
 FOR (i = 1 TO request->qual_knt)
   IF ((request->qual[i].app_prefs_id > 0))
    FOR (j = 1 TO request->qual[i].pref_qual)
     SELECT
      IF ((request->qual[i].pref[j].pref_id > 0))
       PLAN (nvp
        WHERE (nvp.name_value_prefs_id=request->qual[i].pref[j].pref_id))
      ELSE
       PLAN (nvp
        WHERE (nvp.parent_entity_id=request->qual[i].app_prefs_id)
         AND nvp.parent_entity_name="APP_PREFS"
         AND (nvp.pvc_name=request->qual[i].pref[j].pref_name)
         AND nvp.active_ind=1)
      ENDIF
      INTO "nl:"
      FROM name_value_prefs nvp
      HEAD REPORT
       pref_id = nvp.name_value_prefs_id
      WITH nocounter, forupdate(nvp)
     ;end select
     IF (curqual < 1)
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = lock_error
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "LOCK"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ELSE
       INSERT  FROM name_value_prefs nvp
        SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS",
         nvp.parent_entity_id = request->qual[i].app_prefs_id,
         nvp.pvc_name = request->qual[i].pref[j].pref_name, nvp.pvc_value = request->qual[i].pref[j].
         pref_value, nvp.sequence = request->qual[i].pref[j].sequence,
         nvp.merge_id = request->qual[i].pref[j].merge_id, nvp.merge_name = request->qual[i].pref[j].
         merge_name, nvp.active_ind = request->qual[i].pref[j].active_ind,
         nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
         reqinfo->updt_task,
         nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = insert_error
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "INSERT"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSE
      UPDATE  FROM name_value_prefs nvp
       SET nvp.pvc_name = request->qual[i].pref[j].pref_name, nvp.pvc_value = request->qual[i].pref[j
        ].pref_value, nvp.sequence = request->qual[i].pref[j].sequence,
        nvp.merge_id = request->qual[i].pref[j].merge_id, nvp.merge_name = request->qual[i].pref[j].
        merge_name, nvp.active_ind = request->qual[i].pref[j].active_ind,
        nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
        reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1)
       PLAN (nvp
        WHERE nvp.name_value_prefs_id=pref_id)
       WITH nocounter
      ;end update
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
    ENDFOR
   ELSE
    SELECT INTO "nl:"
     FROM app_prefs ap
     PLAN (ap
      WHERE (ap.prsnl_id=request->qual[i].prsnl_id)
       AND (ap.position_cd=request->qual[i].position_cd)
       AND (ap.application_number=request->qual[i].app_number)
       AND ap.active_ind=1)
     HEAD REPORT
      app_prefs_id = ap.app_prefs_id
     WITH nocounter
    ;end select
    IF (curqual < 1)
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "SELECT"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ELSE
      SELECT INTO "nl:"
       temp_value = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        app_prefs_id = cnvtreal(temp_value)
       WITH format, nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = gen_nbr_error
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "CARENET_SEQ"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
      INSERT  FROM app_prefs ap
       SET ap.app_prefs_id = app_prefs_id, ap.application_number = request->qual[i].app_number, ap
        .position_cd = request->qual[i].position_cd,
        ap.prsnl_id = request->qual[i].prsnl_id, ap.active_ind = 1, ap.updt_dt_tm = cnvtdatetime(
         sysdate),
        ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
        updt_applctx,
        ap.updt_cnt = 0
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = insert_error
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "INSERT"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
      INSERT  FROM name_value_prefs nvp,
        (dummyt d  WITH seq = value(request->qual[i].pref_qual))
       SET nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp.parent_entity_id =
        app_prefs_id, nvp.parent_entity_name = "APP_PREFS",
        nvp.pvc_name = request->qual[i].pref[d.seq].pref_name, nvp.pvc_value = request->qual[i].pref[
        d.seq].pref_value, nvp.sequence = request->qual[i].pref[d.seq].sequence,
        nvp.merge_id = request->qual[i].pref[d.seq].merge_id, nvp.merge_name = request->qual[i].pref[
        d.seq].merge_name, nvp.active_ind = request->qual[i].pref[d.seq].active_ind,
        nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
        reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
       PLAN (d
        WHERE d.seq > 0)
        JOIN (nvp
        WHERE 0=0)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = insert_error
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "INSERT"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
    ELSE
     FOR (j = 1 TO request->qual[i].pref_qual)
      SELECT
       IF ((request->qual[i].pref[j].pref_id > 0))
        PLAN (nvp
         WHERE (nvp.name_value_prefs_id=request->qual[i].pref[j].pref_id)
          AND nvp.parent_entity_id=app_prefs_id
          AND nvp.parent_entity_name="APP_PREFS"
          AND nvp.active_ind=1)
       ELSE
        PLAN (nvp
         WHERE nvp.parent_entity_id=app_prefs_id
          AND nvp.parent_entity_name="APP_PREFS"
          AND (nvp.pvc_name=request->qual[i].pref[j].pref_name)
          AND nvp.active_ind=1)
       ENDIF
       INTO "nl:"
       FROM name_value_prefs nvp
       HEAD REPORT
        pref_id = nvp.name_value_prefs_id
       WITH nocounter, forupdate(nvp)
      ;end select
      IF (curqual < 1)
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = lock_error
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "LOCK"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ELSE
        INSERT  FROM name_value_prefs nvp
         SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS",
          nvp.parent_entity_id = app_prefs_id,
          nvp.pvc_name = request->qual[i].pref[j].pref_name, nvp.pvc_value = request->qual[i].pref[j]
          .pref_value, nvp.sequence = request->qual[i].pref[j].sequence,
          nvp.merge_id = request->qual[i].pref[j].merge_id, nvp.merge_name = request->qual[i].pref[j]
          .merge_name, nvp.active_ind = request->qual[i].pref[j].active_ind,
          nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
          reqinfo->updt_task,
          nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = insert_error
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "INSERT"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSE
       UPDATE  FROM name_value_prefs nvp
        SET nvp.pvc_name = request->qual[i].pref[j].pref_name, nvp.pvc_value = request->qual[i].pref[
         j].pref_value, nvp.sequence = request->qual[i].pref[j].sequence,
         nvp.merge_id = request->qual[i].pref[j].merge_id, nvp.merge_name = request->qual[i].pref[j].
         merge_name, nvp.active_ind = request->qual[i].pref[j].active_ind,
         nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
         reqinfo->updt_task,
         nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+ 1)
        PLAN (nvp
         WHERE nvp.name_value_prefs_id=pref_id)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = update_error
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reqinfo->commit_ind = false
 ENDIF
 SET cps_script_version = "002 11/21/03 SF3151"
END GO
