CREATE PROGRAM bed_get_ps_conversations:dba
 FREE SET reply
 RECORD reply(
   1 conversations[*]
     2 task_number = i4
     2 description = vc
     2 reviewed_ind = i2
     2 applications[*]
       3 number = i4
       3 description = vc
       3 reviewed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pos_cd = 0
 IF (validate(request->position_code_value))
  SET pos_cd = request->position_code_value
 ENDIF
 DECLARE pos_parse = vc
 SET pos_parse = "p.position_cd = 0"
 IF (pos_cd > 0)
  SET pos_parse = "p.position_cd = pos_cd"
 ENDIF
 SET ccnt = 0
 SELECT INTO "nl:"
  FROM pm_flx_conversation p,
   br_name_value b
  PLAN (p
   WHERE p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (b
   WHERE b.br_nv_key1="PERSON_SEARCH_CONVERSATION_FLAG"
    AND b.br_name=cnvtstring(p.action))
  ORDER BY p.description
  HEAD p.description
   ccnt = (ccnt+ 1), stat = alterlist(reply->conversations,ccnt), reply->conversations[ccnt].
   task_number = p.task,
   reply->conversations[ccnt].description = p.description
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (ccnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    pm_sch_setup p
   PLAN (d)
    JOIN (p
    WHERE (p.task_number=reply->conversations[d.seq].task_number)
     AND p.person_id=0
     AND parser(pos_parse))
   ORDER BY d.seq
   HEAD d.seq
    reply->conversations[d.seq].reviewed_ind = 1
   WITH nocounter
  ;end select
  SET acnt = 0
  SET appcnt = 0
  RECORD app(
    1 qual[*]
      2 number = i4
      2 desc = vc
      2 match_ind = i2
  )
  SELECT INTO "nl:"
   FROM br_name_value b1,
    br_name_value b2
   PLAN (b1
    WHERE b1.br_nv_key1="PERSON_SEARCH"
     AND b1.br_name="APPLICATION")
    JOIN (b2
    WHERE b2.br_nv_key1="PERSON_SEARCH_APPLICATION_FLAG"
     AND b2.br_name=b1.br_value)
   DETAIL
    appcnt = (appcnt+ 1), stat = alterlist(app->qual,appcnt), app->qual[appcnt].number = cnvtint(b1
     .br_value)
   WITH nocounter
  ;end select
  IF (appcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(appcnt)),
     br_name_value b
    PLAN (d)
     JOIN (b
     WHERE b.br_nv_key1="APPLICATION_NAME"
      AND b.br_name=cnvtstring(app->qual[d.seq].number))
    ORDER BY b.br_value
    HEAD b.br_value
     app->qual[d.seq].desc = b.br_value, app->qual[d.seq].match_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(appcnt)),
     application a
    PLAN (d)
     JOIN (a
     WHERE (a.application_number=app->qual[d.seq].number)
      AND a.active_ind=1
      AND (app->qual[d.seq].match_ind=0))
    ORDER BY a.description
    HEAD a.description
     app->qual[d.seq].desc = a.description, app->qual[d.seq].match_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  FOR (x = 1 TO ccnt)
    SET acnt = 0
    FOR (y = 1 TO appcnt)
      IF ((app->qual[y].match_ind=1))
       SET acnt = (acnt+ 1)
       SET stat = alterlist(reply->conversations[x].applications,acnt)
       SET reply->conversations[x].applications[acnt].number = app->qual[y].number
       SET reply->conversations[x].applications[acnt].description = app->qual[y].desc
      ENDIF
    ENDFOR
    IF (acnt > 0)
     IF (pos_cd > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(acnt)),
        pm_sch_setup p
       PLAN (d)
        JOIN (p
        WHERE (p.application_number=reply->conversations[x].applications[d.seq].number)
         AND ((p.task_number+ 0)=reply->conversations[x].task_number)
         AND ((p.person_id+ 0)=0)
         AND ((p.position_cd+ 0)=pos_cd))
       ORDER BY d.seq
       HEAD d.seq
        reply->conversations[x].applications[d.seq].reviewed_ind = 1
       WITH nocounter
      ;end select
     ELSE
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(acnt)),
        pm_sch_setup p
       PLAN (d)
        JOIN (p
        WHERE (p.application_number=reply->conversations[x].applications[d.seq].number)
         AND ((p.task_number+ 0)=reply->conversations[x].task_number)
         AND ((p.person_id+ 0)=0)
         AND ((p.position_cd+ 0)=0))
       ORDER BY d.seq
       HEAD d.seq
        reply->conversations[x].applications[d.seq].reviewed_ind = 1
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (ccnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
