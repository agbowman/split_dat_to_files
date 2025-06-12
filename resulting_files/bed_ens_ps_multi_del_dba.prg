CREATE PROGRAM bed_ens_ps_multi_del:dba
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
 FREE SET tqual
 RECORD tqual(
   1 tqual[*]
     2 id = f8
 )
 FREE SET tqual2
 RECORD tqual2(
   1 tqual2[*]
     2 id = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET tcnt = 0
 IF ((request->delete_all_prsnl=1))
  SELECT INTO "nl:"
   FROM pm_sch_setup p
   PLAN (p
    WHERE p.person_id > 0)
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(tqual->tqual,100)
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
    ENDIF
    tqual->tqual[tcnt].id = p.setup_id
   FOOT REPORT
    stat = alterlist(tqual->tqual,tcnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM pm_pref_setup p
   PLAN (p
    WHERE p.person_prsnl_id > 0)
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(tqual2->tqual2,100)
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
    ENDIF
    tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
   FOOT REPORT
    stat = alterlist(tqual2->tqual2,tcnt)
   WITH nocounter
  ;end select
  SET ierrcode = 0
  DELETE  FROM pm_sch_setup p
   SET p.seq = 1
   PLAN (p
    WHERE p.person_id > 0)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 1")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM pm_sch_preferences p
   SET p.seq = 1
   PLAN (p
    WHERE p.person_id > 0)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 2")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM pm_pref_setup p
   SET p.seq = 1
   PLAN (p
    WHERE p.person_prsnl_id > 0)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 3")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->delete_all_position=1))
  SELECT INTO "nl:"
   FROM pm_sch_setup p
   PLAN (p
    WHERE p.position_cd > 0)
   HEAD REPORT
    cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
    ENDIF
    tqual->tqual[tcnt].id = p.setup_id
   FOOT REPORT
    stat = alterlist(tqual->tqual,tcnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM pm_pref_setup p
   PLAN (p
    WHERE p.position_cd > 0)
   HEAD REPORT
    cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
    ENDIF
    tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
   FOOT REPORT
    stat = alterlist(tqual2->tqual2,tcnt)
   WITH nocounter
  ;end select
  SET ierrcode = 0
  DELETE  FROM pm_sch_setup p
   SET p.seq = 1
   PLAN (p
    WHERE p.position_cd > 0)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 4")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM pm_pref_setup p
   SET p.seq = 1
   PLAN (p
    WHERE p.position_cd > 0)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 5")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET prsnl_cnt = size(request->prsnl_list,5)
 FOR (x = 1 TO prsnl_cnt)
   SET app_cnt = size(request->prsnl_list[x].apps,5)
   IF (app_cnt > 0)
    SELECT INTO "nl:"
     FROM pm_sch_setup p,
      (dummyt d  WITH seq = value(app_cnt))
     PLAN (d)
      JOIN (p
      WHERE (p.person_id=request->prsnl_list[x].person_id)
       AND (p.application_number=request->prsnl_list[x].apps[d.seq].number)
       AND p.task_number=0)
     HEAD REPORT
      cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
      ENDIF
      tqual->tqual[tcnt].id = p.setup_id
     FOOT REPORT
      stat = alterlist(tqual->tqual,tcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM pm_pref_setup p,
      (dummyt d  WITH seq = value(app_cnt))
     PLAN (d)
      JOIN (p
      WHERE (p.person_prsnl_id=request->prsnl_list[x].person_id)
       AND (p.application_number=request->prsnl_list[x].apps[d.seq].number)
       AND p.task_number=0)
     ORDER BY d.seq
     HEAD REPORT
      cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
      ENDIF
      tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
     FOOT REPORT
      stat = alterlist(tqual2->tqual2,tcnt)
     WITH nocounter
    ;end select
    SET ierrcode = 0
    DELETE  FROM pm_sch_setup p,
      (dummyt d  WITH seq = value(app_cnt))
     SET p.seq = 1
     PLAN (d)
      JOIN (p
      WHERE (p.person_id=request->prsnl_list[x].person_id)
       AND (p.application_number=request->prsnl_list[x].apps[d.seq].number)
       AND p.task_number=0)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 6")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM pm_sch_preferences p,
      (dummyt d  WITH seq = value(app_cnt))
     SET p.seq = 1
     PLAN (d)
      JOIN (p
      WHERE (p.person_id=request->prsnl_list[x].person_id)
       AND (p.application_number=request->prsnl_list[x].apps[d.seq].number)
       AND p.task_number=0)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 7")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM pm_pref_setup p,
      (dummyt d  WITH seq = value(app_cnt))
     SET p.seq = 1
     PLAN (d)
      JOIN (p
      WHERE (p.person_prsnl_id=request->prsnl_list[x].person_id)
       AND (p.application_number=request->prsnl_list[x].apps[d.seq].number)
       AND p.task_number=0)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 8")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET task_cnt = 0
   IF (validate(request->prsnl_list[x].task))
    SET task_cnt = size(request->prsnl_list[x].task,5)
   ENDIF
   FOR (y = 1 TO task_cnt)
    SET tapp_cnt = size(request->prsnl_list[x].task[y].apps,5)
    IF (tapp_cnt > 0)
     SELECT INTO "nl:"
      FROM pm_sch_setup p,
       (dummyt d  WITH seq = value(tapp_cnt))
      PLAN (d)
       JOIN (p
       WHERE (p.person_id=request->prsnl_list[x].person_id)
        AND (p.application_number=request->prsnl_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      HEAD REPORT
       cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
      DETAIL
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
       ENDIF
       tqual->tqual[tcnt].id = p.setup_id
      FOOT REPORT
       stat = alterlist(tqual->tqual,tcnt)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM pm_pref_setup p,
       (dummyt d  WITH seq = value(tapp_cnt))
      PLAN (d)
       JOIN (p
       WHERE (p.person_prsnl_id=request->prsnl_list[x].person_id)
        AND (p.application_number=request->prsnl_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      ORDER BY d.seq
      HEAD REPORT
       cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
      DETAIL
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
       ENDIF
       tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
      FOOT REPORT
       stat = alterlist(tqual2->tqual2,tcnt)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     DELETE  FROM pm_sch_setup p,
       (dummyt d  WITH seq = value(tapp_cnt))
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.person_id=request->prsnl_list[x].person_id)
        AND (p.application_number=request->prsnl_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 9")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM pm_sch_preferences p,
       (dummyt d  WITH seq = value(tapp_cnt))
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.person_id=request->prsnl_list[x].person_id)
        AND (p.application_number=request->prsnl_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 10")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM pm_pref_setup p,
       (dummyt d  WITH seq = value(tapp_cnt))
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.person_prsnl_id=request->prsnl_list[x].person_id)
        AND (p.application_number=request->prsnl_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 11")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM pm_sch_setup p
      PLAN (p
       WHERE (p.person_id=request->prsnl_list[x].person_id)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      HEAD REPORT
       cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
      DETAIL
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
       ENDIF
       tqual->tqual[tcnt].id = p.setup_id
      FOOT REPORT
       stat = alterlist(tqual->tqual,tcnt)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM pm_pref_setup p
      PLAN (p
       WHERE (p.person_prsnl_id=request->prsnl_list[x].person_id)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      HEAD REPORT
       cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
      DETAIL
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
       ENDIF
       tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
      FOOT REPORT
       stat = alterlist(tqual2->tqual2,tcnt)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     DELETE  FROM pm_sch_setup p
      SET p.seq = 1
      PLAN (p
       WHERE (p.person_id=request->prsnl_list[x].person_id)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 9")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM pm_sch_preferences p
      SET p.seq = 1
      PLAN (p
       WHERE (p.person_id=request->prsnl_list[x].person_id)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 10")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM pm_pref_setup p
      SET p.seq = 1
      PLAN (p
       WHERE (p.person_prsnl_id=request->prsnl_list[x].person_id)
        AND (p.task_number=request->prsnl_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 11")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDFOR
   IF (task_cnt=0
    AND app_cnt=0)
    SELECT INTO "nl:"
     FROM pm_sch_setup p
     PLAN (p
      WHERE (p.person_id=request->prsnl_list[x].person_id))
     HEAD REPORT
      cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
      ENDIF
      tqual->tqual[tcnt].id = p.setup_id
     FOOT REPORT
      stat = alterlist(tqual->tqual,tcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM pm_pref_setup p
     PLAN (p
      WHERE (p.person_prsnl_id=request->prsnl_list[x].person_id))
     HEAD REPORT
      cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
      ENDIF
      tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
     FOOT REPORT
      stat = alterlist(tqual2->tqual2,tcnt)
     WITH nocounter
    ;end select
    SET ierrcode = 0
    DELETE  FROM pm_sch_setup p
     WHERE (p.person_id=request->prsnl_list[x].person_id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 6")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM pm_sch_preferences p
     WHERE (p.person_id=request->prsnl_list[x].person_id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 7")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM pm_pref_setup p
     WHERE (p.person_prsnl_id=request->prsnl_list[x].person_id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 8")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET pos_cnt = size(request->position_list,5)
 FOR (x = 1 TO pos_cnt)
   SET app_cnt = size(request->position_list[x].apps,5)
   IF (app_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(app_cnt)),
      pm_sch_setup p
     PLAN (d)
      JOIN (p
      WHERE (p.position_cd=request->position_list[x].position_code_value)
       AND (p.application_number=request->position_list[x].apps[d.seq].number)
       AND p.task_number=0)
     ORDER BY d.seq
     HEAD REPORT
      cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
      ENDIF
      tqual->tqual[tcnt].id = p.setup_id
     FOOT REPORT
      stat = alterlist(tqual->tqual,tcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(app_cnt)),
      pm_pref_setup p
     PLAN (d)
      JOIN (p
      WHERE (p.position_cd=request->position_list[x].position_code_value)
       AND (p.application_number=request->position_list[x].apps[d.seq].number)
       AND p.task_number=0)
     ORDER BY d.seq
     HEAD REPORT
      cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
      ENDIF
      tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
     FOOT REPORT
      stat = alterlist(tqual2->tqual2,tcnt)
     WITH nocounter
    ;end select
    SET ierrcode = 0
    DELETE  FROM pm_sch_setup p,
      (dummyt d  WITH seq = value(app_cnt))
     SET p.seq = 1
     PLAN (d)
      JOIN (p
      WHERE (p.position_cd=request->position_list[x].position_code_value)
       AND (p.application_number=request->position_list[x].apps[d.seq].number)
       AND p.task_number=0)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 12")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM pm_pref_setup p,
      (dummyt d  WITH seq = value(app_cnt))
     SET p.seq = 1
     PLAN (d)
      JOIN (p
      WHERE (p.position_cd=request->position_list[x].position_code_value)
       AND (p.application_number=request->position_list[x].apps[d.seq].number)
       AND p.task_number=0)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 13")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET task_cnt = 0
   IF (validate(request->position_list[x].task))
    SET task_cnt = size(request->position_list[x].task,5)
   ENDIF
   FOR (y = 1 TO task_cnt)
    SET tapp_cnt = size(request->position_list[x].task[y].apps,5)
    IF (tapp_cnt > 0)
     SELECT INTO "nl:"
      FROM pm_sch_setup p,
       (dummyt d  WITH seq = value(tapp_cnt))
      PLAN (d)
       JOIN (p
       WHERE (p.position_cd=request->position_list[x].position_code_value)
        AND (p.application_number=request->position_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->position_list[x].task[y].number))
      HEAD REPORT
       cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
      DETAIL
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
       ENDIF
       tqual->tqual[tcnt].id = p.setup_id
      FOOT REPORT
       stat = alterlist(tqual->tqual,tcnt)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM pm_pref_setup p,
       (dummyt d  WITH seq = value(tapp_cnt))
      PLAN (d)
       JOIN (p
       WHERE (p.position_cd=request->position_list[x].position_code_value)
        AND (p.application_number=request->position_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->position_list[x].task[y].number))
      ORDER BY d.seq
      HEAD REPORT
       cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
      DETAIL
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
       ENDIF
       tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
      FOOT REPORT
       stat = alterlist(tqual2->tqual2,tcnt)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     DELETE  FROM pm_sch_setup p,
       (dummyt d  WITH seq = value(tapp_cnt))
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.position_cd=request->position_list[x].position_code_value)
        AND (p.application_number=request->position_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->position_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 14")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM pm_pref_setup p,
       (dummyt d  WITH seq = value(tapp_cnt))
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.position_cd=request->position_list[x].position_code_value)
        AND (p.application_number=request->position_list[x].task[y].apps[d.seq].number)
        AND (p.task_number=request->position_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 15")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM pm_sch_setup p
      PLAN (p
       WHERE (p.position_cd=request->position_list[x].position_code_value)
        AND (p.task_number=request->position_list[x].task[y].number))
      HEAD REPORT
       cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
      DETAIL
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
       ENDIF
       tqual->tqual[tcnt].id = p.setup_id
      FOOT REPORT
       stat = alterlist(tqual->tqual,tcnt)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM pm_pref_setup p
      PLAN (p
       WHERE (p.position_cd=request->position_list[x].position_code_value)
        AND (p.task_number=request->position_list[x].task[y].number))
      HEAD REPORT
       cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
      DETAIL
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
       ENDIF
       tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
      FOOT REPORT
       stat = alterlist(tqual2->tqual2,tcnt)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     DELETE  FROM pm_sch_setup p
      SET p.seq = 1
      PLAN (p
       WHERE (p.position_cd=request->position_list[x].position_code_value)
        AND (p.task_number=request->position_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 14")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     DELETE  FROM pm_pref_setup p
      SET p.seq = 1
      PLAN (p
       WHERE (p.position_cd=request->position_list[x].position_code_value)
        AND (p.task_number=request->position_list[x].task[y].number))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 15")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDFOR
   IF (task_cnt=0
    AND app_cnt=0)
    SELECT INTO "nl:"
     FROM pm_sch_setup p
     PLAN (p
      WHERE (p.position_cd=request->position_list[x].position_code_value))
     HEAD REPORT
      cnt = 0, tcnt = size(tqual->tqual,5), stat = alterlist(tqual->tqual,(tcnt+ 100))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(tqual->tqual,(tcnt+ 100)), cnt = 1
      ENDIF
      tqual->tqual[tcnt].id = p.setup_id
     FOOT REPORT
      stat = alterlist(tqual->tqual,tcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM pm_pref_setup p
     PLAN (p
      WHERE (p.position_cd=request->position_list[x].position_code_value))
     HEAD REPORT
      cnt = 0, tcnt = size(tqual2->tqual2,5), stat = alterlist(tqual2->tqual2,(tcnt+ 100))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(tqual2->tqual2,(tcnt+ 100)), cnt = 1
      ENDIF
      tqual2->tqual2[tcnt].id = p.pm_pref_setup_id
     FOOT REPORT
      stat = alterlist(tqual2->tqual2,tcnt)
     WITH nocounter
    ;end select
    SET ierrcode = 0
    DELETE  FROM pm_sch_setup p
     WHERE (p.position_cd=request->position_list[x].position_code_value)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 12")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM pm_pref_setup p
     WHERE (p.position_cd=request->position_list[x].position_code_value)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 13")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET tcnt = size(tqual->tqual,5)
 IF (tcnt > 0)
  SET ierrcode = 0
  DELETE  FROM pm_sch_limit p,
    (dummyt d  WITH seq = value(tcnt))
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (p.setup_id=tqual->tqual[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 16")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM pm_sch_filter p,
    (dummyt d  WITH seq = value(tcnt))
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (p.setup_id=tqual->tqual[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 17")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM pm_sch_result p,
    (dummyt d  WITH seq = value(tcnt))
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (p.setup_id=tqual->tqual[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 18")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = size(tqual2->tqual2,5)
 IF (tcnt > 0)
  SET ierrcode = 0
  DELETE  FROM pm_pref p,
    (dummyt d  WITH seq = value(tcnt))
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (p.pm_pref_setup_id=tqual2->tqual2[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("DELETE 19")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
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
