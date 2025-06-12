CREATE PROGRAM bed_get_ps_applications:dba
 FREE SET reply
 RECORD reply(
   1 applications[*]
     2 number = i4
     2 description = vc
     2 reviewed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET acnt = 0
 RECORD app(
   1 qual[*]
     2 number = i4
     2 desc = vc
     2 match_ind = i2
 )
 SET pos_cd = 0
 IF (validate(request->position_code_value))
  SET pos_cd = request->position_code_value
 ENDIF
 SET cnt = 0
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
   cnt = (cnt+ 1), stat = alterlist(app->qual,cnt), app->qual[cnt].number = cnvtint(b1.br_value)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
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
   FROM (dummyt d  WITH seq = value(cnt)),
    application a
   PLAN (d)
    JOIN (a
    WHERE (a.application_number=app->qual[d.seq].number)
     AND a.active_ind=1
     AND (app->qual[d.seq].match_ind=0))
   ORDER BY a.description
   HEAD a.description
    app->qual[d.seq].desc = a.description, app->qual[d.seq].match_ind = 1
   WITH nocounter, skipbedrock = 1
  ;end select
  SET acnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt))
   PLAN (d)
   ORDER BY d.seq
   HEAD d.seq
    IF ((app->qual[d.seq].match_ind=1))
     acnt = (acnt+ 1), stat = alterlist(reply->applications,acnt), reply->applications[acnt].number
      = app->qual[d.seq].number,
     reply->applications[acnt].description = app->qual[d.seq].desc
    ENDIF
   WITH nocounter
  ;end select
  IF (acnt > 0)
   IF (pos_cd > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acnt)),
      pm_sch_setup p
     PLAN (d)
      JOIN (p
      WHERE (p.application_number=reply->applications[d.seq].number)
       AND p.task_number=0
       AND p.person_id=0
       AND p.position_cd=pos_cd)
     ORDER BY d.seq
     HEAD d.seq
      reply->applications[d.seq].reviewed_ind = 1
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acnt)),
      pm_sch_setup p
     PLAN (d)
      JOIN (p
      WHERE (p.application_number=reply->applications[d.seq].number)
       AND p.task_number=0
       AND p.person_id=0
       AND p.position_cd=0)
     ORDER BY d.seq
     HEAD d.seq
      reply->applications[d.seq].reviewed_ind = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (acnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
