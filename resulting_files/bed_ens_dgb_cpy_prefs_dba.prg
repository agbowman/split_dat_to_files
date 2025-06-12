CREATE PROGRAM bed_ens_dgb_cpy_prefs:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET tcpy
 RECORD tcpy(
   1 prefs[*]
     2 pref_name = vc
     2 pref_val = vc
     2 mname = vc
     2 mid = f8
     2 app_level_ind = i2
 )
 FREE SET treq
 RECORD treq(
   1 req[*]
     2 id = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->copy_from,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO req_cnt)
   SET stat = initrec(treq)
   SET stat = initrec(tcpy)
   SET ntcnt = 0
   SELECT INTO "nl:"
    FROM app_prefs a,
     name_value_prefs n,
     br_prefs b
    PLAN (a
     WHERE (a.application_number=request->copy_from[x].application_number)
      AND a.position_cd IN (request->copy_from[x].position_code_value, 0)
      AND a.prsnl_id=0
      AND a.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=a.app_prefs_id
      AND n.parent_entity_name="APP_PREFS")
     JOIN (b
     WHERE b.pvc_name=n.pvc_name
      AND (((request->copy_from[x].chart_ind=1)
      AND b.view_name="CHART") OR ((request->copy_from[x].mc_ind=1)
      AND b.view_name="PVINBOX")) )
    ORDER BY b.br_prefs_id
    HEAD REPORT
     ncnt = 0, ntcnt = 0, stat = alterlist(tcpy->prefs,100)
    HEAD b.br_prefs_id
     loaded_ind = 0
    DETAIL
     IF (loaded_ind=0)
      loaded_ind = 1, ncnt = (ncnt+ 1), ntcnt = (ntcnt+ 1)
      IF (ncnt > 100)
       stat = alterlist(tcpy->prefs,(ntcnt+ 100)), ncnt = 1
      ENDIF
      tcpy->prefs[ntcnt].pref_name = n.pvc_name, tcpy->prefs[ntcnt].pref_val = n.pvc_value, tcpy->
      prefs[ntcnt].mid = n.merge_id,
      tcpy->prefs[ntcnt].mname = n.merge_name
      IF (a.position_cd=0)
       tcpy->prefs[ntcnt].app_level_ind = 1
      ENDIF
     ELSEIF (a.position_cd > 0
      AND (tcpy->prefs[ntcnt].app_level_ind=1))
      tcpy->prefs[ntcnt].pref_name = n.pvc_name, tcpy->prefs[ntcnt].pref_val = n.pvc_value, tcpy->
      prefs[ntcnt].mid = n.merge_id,
      tcpy->prefs[ntcnt].mname = n.merge_name, tcpy->prefs[ntcnt].app_level_ind = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(tcpy->prefs,ntcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM app_prefs a,
     name_value_prefs n
    PLAN (a
     WHERE (a.application_number=request->copy_from[x].application_number)
      AND a.position_cd IN (request->copy_from[x].position_code_value, 0)
      AND a.prsnl_id=0
      AND a.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=a.app_prefs_id
      AND n.parent_entity_name="APP_PREFS"
      AND ((trim(n.pvc_name) IN ("CHT_DB_ROWS", "CHT_DB_COLS", "CHT_DB_EVENT_STATUS",
     "DB_ALLOW_CUSTOM", "CHT_DB_CUSTOM_SCRIPT",
     "DB_ALLOW_HIDE", "CHT_DB_PATIENT_PICTURE")
      AND (request->copy_from[x].chart_ind=1)) OR (trim(n.pvc_name) IN ("MSG_DB_ROWS", "MSG_DB_COLS",
     "MSG_DB_EVENT_STATUS", "MSG_DB_ALLOW_CUSTOM", "MSG_DB_CUSTOM_SCRIPT",
     "MSG_DB_PATIENT_PICTURE")
      AND (request->copy_from[x].mc_ind=1))) )
    ORDER BY n.pvc_name
    HEAD REPORT
     ncnt = 0, stat = alterlist(tcpy->prefs,(ntcnt+ 10))
    HEAD n.pvc_name
     loaded_ind = 0
    DETAIL
     IF (loaded_ind=0)
      loaded_ind = 1, ncnt = (ncnt+ 1), ntcnt = (ntcnt+ 1)
      IF (ncnt > 10)
       stat = alterlist(tcpy->prefs,(ntcnt+ 10)), ncnt = 1
      ENDIF
      tcpy->prefs[ntcnt].pref_name = n.pvc_name, tcpy->prefs[ntcnt].pref_val = n.pvc_value, tcpy->
      prefs[ntcnt].mid = n.merge_id,
      tcpy->prefs[ntcnt].mname = n.merge_name
      IF (a.position_cd=0)
       tcpy->prefs[ntcnt].app_level_ind = 1
      ENDIF
     ELSEIF (a.position_cd > 0
      AND (tcpy->prefs[ntcnt].app_level_ind=1))
      tcpy->prefs[ntcnt].pref_name = n.pvc_name, tcpy->prefs[ntcnt].pref_val = n.pvc_value, tcpy->
      prefs[ntcnt].mid = n.merge_id,
      tcpy->prefs[ntcnt].mname = n.merge_name, tcpy->prefs[ntcnt].app_level_ind = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(tcpy->prefs,ntcnt)
    WITH nocounter
   ;end select
   SET to_size = size(request->copy_from[x].copy_to,5)
   IF (to_size > 0
    AND ntcnt > 0)
    SET tcnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(to_size)),
      app_prefs a,
      name_value_prefs n,
      br_prefs b
     PLAN (d)
      JOIN (a
      WHERE (a.application_number=request->copy_from[x].copy_to[d.seq].application_number)
       AND (a.position_cd=request->copy_from[x].copy_to[d.seq].position_code_value)
       AND a.prsnl_id=0
       AND a.active_ind=1)
      JOIN (n
      WHERE n.parent_entity_id=a.app_prefs_id
       AND n.parent_entity_name="APP_PREFS")
      JOIN (b
      WHERE b.pvc_name=n.pvc_name
       AND (((request->copy_from[x].chart_ind=1)
       AND b.view_name="CHART") OR ((request->copy_from[x].mc_ind=1)
       AND b.view_name="PVINBOX")) )
     ORDER BY n.name_value_prefs_id
     HEAD REPORT
      cnt = 0, tcnt = 0, stat = alterlist(treq->req,100)
     HEAD n.name_value_prefs_id
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(treq->req,(tcnt+ 100)), cnt = 1
      ENDIF
      treq->req[tcnt].id = n.name_value_prefs_id
     FOOT REPORT
      stat = alterlist(treq->req,tcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(to_size)),
      app_prefs a,
      name_value_prefs n
     PLAN (d)
      JOIN (a
      WHERE (a.application_number=request->copy_from[x].copy_to[d.seq].application_number)
       AND (a.position_cd=request->copy_from[x].copy_to[d.seq].position_code_value)
       AND a.prsnl_id=0
       AND a.active_ind=1)
      JOIN (n
      WHERE n.parent_entity_id=a.app_prefs_id
       AND n.parent_entity_name="APP_PREFS"
       AND ((trim(n.pvc_name) IN ("CHT_DB_ROWS", "CHT_DB_COLS", "CHT_DB_EVENT_STATUS",
      "DB_ALLOW_CUSTOM", "CHT_DB_CUSTOM_SCRIPT",
      "DB_ALLOW_HIDE", "CHT_DB_PATIENT_PICTURE")
       AND (request->copy_from[x].chart_ind=1)) OR (trim(n.pvc_name) IN ("MSG_DB_ROWS", "MSG_DB_COLS",
      "MSG_DB_EVENT_STATUS", "MSG_DB_ALLOW_CUSTOM", "MSG_DB_CUSTOM_SCRIPT",
      "MSG_DB_PATIENT_PICTURE")
       AND (request->copy_from[x].mc_ind=1))) )
     ORDER BY n.name_value_prefs_id
     HEAD REPORT
      cnt = 0, stat = alterlist(treq->req,(tcnt+ 10))
     HEAD n.name_value_prefs_id
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 10)
       stat = alterlist(treq->req,(tcnt+ 10)), cnt = 1
      ENDIF
      treq->req[tcnt].id = n.name_value_prefs_id
     FOOT REPORT
      stat = alterlist(treq->req,tcnt)
     WITH nocounter
    ;end select
    IF (tcnt > 0)
     SET ierrcode = 0
     DELETE  FROM name_value_prefs n,
       (dummyt d  WITH seq = value(tcnt))
      SET n.seq = 1
      PLAN (d)
       JOIN (n
       WHERE (n.name_value_prefs_id=treq->req[d.seq].id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error on name_value_prefs delete")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
    FOR (y = 1 TO to_size)
      SET to_id = 0.0
      SELECT INTO "nl:"
       FROM app_prefs a
       PLAN (a
        WHERE (a.application_number=request->copy_from[x].copy_to[y].application_number)
         AND (a.position_cd=request->copy_from[x].copy_to[y].position_code_value)
         AND a.prsnl_id=0
         AND a.active_ind=1)
       ORDER BY a.prsnl_id DESC, a.position_cd DESC
       DETAIL
        to_id = a.app_prefs_id
       WITH nocounter
      ;end select
      IF (to_id=0)
       SELECT INTO "NL:"
        j = seq(carenet_seq,nextval)"##################;rp0"
        FROM dual du
        PLAN (du)
        DETAIL
         to_id = cnvtreal(j)
        WITH format, counter
       ;end select
       SET ierrcode = 0
       INSERT  FROM app_prefs a
        SET a.app_prefs_id = to_id, a.active_ind = 1, a.application_number = request->copy_from[x].
         copy_to[y].application_number,
         a.position_cd = request->copy_from[x].copy_to[y].position_code_value, a.prsnl_id = 0, a
         .updt_applctx = reqinfo->updt_applctx,
         a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
         a.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = concat(
         "Error on app_prefs insert")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
      SET ierrcode = 0
      INSERT  FROM name_value_prefs n,
        (dummyt d  WITH seq = value(ntcnt))
       SET n.name_value_prefs_id = seq(carenet_seq,nextval), n.active_ind = 1, n.merge_id = tcpy->
        prefs[d.seq].mid,
        n.merge_name = tcpy->prefs[d.seq].mname, n.parent_entity_id = to_id, n.parent_entity_name =
        "APP_PREFS",
        n.pvc_name = tcpy->prefs[d.seq].pref_name, n.pvc_value = tcpy->prefs[d.seq].pref_val, n
        .sequence = 0,
        n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task
       PLAN (d)
        JOIN (n)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error on name_value_prefs insert")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
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
 CALL echorecord(tcpy)
 CALL echorecord(treq)
END GO
