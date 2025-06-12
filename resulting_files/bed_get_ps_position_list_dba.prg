CREATE PROGRAM bed_get_ps_position_list:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 position_list[*]
      2 position_code_value = f8
      2 display = vc
      2 apps[*]
        3 number = i4
        3 description = vc
      2 defined_ind = i2
      2 task[*]
        3 number = i4
        3 description = vc
        3 apps[*]
          4 number = i4
          4 description = vc
        3 no_conversation_ind = i2
        3 style_flag = i2
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE pos_parse = vc
 SET pos_parse = "c.code_set = 88 and c.active_ind = 1"
 IF ((request->search_string > " "))
  IF (cnvtupper(request->search_type_flag)="S")
   SET pos_parse = concat(pos_parse," and c.display_key = '",trim(cnvtupper(cnvtalphanum(request->
       search_string))),"*' and cnvtupper(c.display) = '",trim(cnvtupper(request->search_string)),
    "*'")
  ELSEIF (cnvtupper(request->search_type_flag)="C")
   SET pos_parse = concat(pos_parse," and c.display_key = '*",trim(cnvtupper(cnvtalphanum(request->
       search_string))),"*' and cnvtupper(c.display) = '*",trim(cnvtupper(request->search_string)),
    "*'")
  ENDIF
 ENDIF
 IF ((request->position_code_value > 0))
  SET pos_parse = build(pos_parse," and c.code_value = ",request->position_code_value)
 ENDIF
 SET load_all = 0
 IF (validate(request->load_all_ind))
  IF ((request->load_all_ind=1))
   SET load_all = 1
  ENDIF
 ENDIF
 SET un_def = 0
 IF (validate(request->undefined_ind))
  IF ((request->undefined_ind=1))
   SET un_def = 1
  ENDIF
 ENDIF
 IF (load_all=1)
  SET pcnt = 0
  SET max_cnt = request->max_reply
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE parser(pos_parse))
   ORDER BY c.display_key
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->position_list,pcnt), reply->position_list[pcnt].
    position_code_value = c.code_value,
    reply->position_list[pcnt].display = c.display
   WITH nocounter
  ;end select
  IF (pcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(pcnt)),
     pm_sch_setup p
    PLAN (d)
     JOIN (p
     WHERE (p.position_cd=reply->position_list[d.seq].position_code_value))
    ORDER BY d.seq
    HEAD d.seq
     reply->position_list[d.seq].defined_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  IF (pcnt > max_cnt)
   SET stat = alterlist(reply->position_list,0)
   SET reply->too_many_results_ind = 1
  ENDIF
 ELSEIF (un_def=1)
  SET pcnt = 0
  SET max_cnt = request->max_reply
  SELECT INTO "nl:"
   FROM code_value c,
    dummyt d,
    pm_sch_setup p
   PLAN (c
    WHERE parser(pos_parse))
    JOIN (d)
    JOIN (p
    WHERE p.position_cd=c.code_value)
   ORDER BY c.display_key
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->position_list,pcnt), reply->position_list[pcnt].
    position_code_value = c.code_value,
    reply->position_list[pcnt].display = c.display
   WITH nocounter, outerjoin = d, dontexist
  ;end select
  IF (pcnt > max_cnt)
   SET stat = alterlist(reply->position_list,0)
   SET reply->too_many_results_ind = 1
  ENDIF
 ELSE
  SET tcnt = 0
  SET overall_cnt = 0
  SET task_cnt = 0
  SET overall_stop_index = request->max_reply
  SELECT INTO "nl:"
   FROM pm_sch_setup ps,
    code_value c,
    application a
   PLAN (c
    WHERE parser(pos_parse))
    JOIN (ps
    WHERE ps.position_cd=c.code_value)
    JOIN (a
    WHERE a.application_number=ps.application_number
     AND a.active_ind=1)
   ORDER BY c.display_key, c.display, c.code_value,
    ps.task_number, a.application_number
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(reply->position_list,100)
   HEAD c.code_value
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->position_list,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->position_list[tcnt].position_code_value = c.code_value, reply->position_list[tcnt].display
     = c.display, reply->position_list[tcnt].defined_ind = 1,
    pcnt = 0, ptcnt = 0, tncnt = 0,
    ncnt = 0, stat = alterlist(reply->position_list[tcnt].apps,100), stat = alterlist(reply->
     position_list[tcnt].task,100)
   HEAD ps.task_number
    IF (ps.task_number > 0)
     ncnt = (ncnt+ 1), tncnt = (tncnt+ 1)
     IF (ncnt > 100)
      stat = alterlist(reply->position_list[tcnt].task,(tncnt+ 100)), ncnt = 1
     ENDIF
     reply->position_list[tcnt].task[tncnt].number = ps.task_number, reply->position_list[tcnt].task[
     tncnt].style_flag = ps.style_flag
    ENDIF
   HEAD a.application_number
    IF (ps.task_number=0)
     pcnt = (pcnt+ 1), ptcnt = (ptcnt+ 1)
     IF (pcnt > 100)
      stat = alterlist(reply->position_list[tcnt].apps,(ptcnt+ 100)), pcnt = 1
     ENDIF
     reply->position_list[tcnt].apps[ptcnt].number = a.application_number, reply->position_list[tcnt]
     .apps[ptcnt].description = a.description
    ENDIF
   FOOT  c.code_value
    overall_cnt = (overall_cnt+ ptcnt), overall_cnt = (overall_cnt+ 1), stat = alterlist(reply->
     position_list[tcnt].apps,ptcnt),
    stat = alterlist(reply->position_list[tcnt].task,tncnt)
    IF ((overall_cnt > request->max_reply)
     AND (overall_stop_index=request->max_reply))
     overall_stop_index = (tcnt - 1)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->position_list,tcnt)
   WITH nocounter
  ;end select
  IF (tcnt > 0)
   FOR (x = 1 TO tcnt)
    SET task_cnt = size(reply->position_list[x].task,5)
    IF (task_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(task_cnt)),
       pm_flx_conversation p,
       application ap,
       pm_sch_setup ps
      PLAN (d)
       JOIN (ps
       WHERE (ps.task_number=reply->position_list[x].task[d.seq].number)
        AND (ps.position_cd=reply->position_list[x].position_code_value))
       JOIN (p
       WHERE p.task=ps.task_number
        AND p.active_ind=1)
       JOIN (ap
       WHERE ap.application_number=ps.application_number)
      ORDER BY p.description, ap.description
      HEAD p.description
       acnt = 0, reply->position_list[x].task[d.seq].description = p.description
      HEAD ap.application_number
       acnt = (acnt+ 1), stat = alterlist(reply->position_list[x].task[d.seq].apps,acnt), reply->
       position_list[x].task[d.seq].apps[acnt].number = ap.application_number,
       reply->position_list[x].task[d.seq].apps[acnt].description = ap.description
      WITH nocounter
     ;end select
     FOR (y = 0 TO task_cnt)
       DECLARE app_description = vc WITH protect
       SELECT INTO "nl:"
        FROM application ap,
         pm_sch_setup ps
        WHERE (ps.task_number=reply->position_list[x].task[y].number)
         AND (ps.position_cd=reply->position_list[x].position_code_value)
         AND ap.application_number=ps.application_number
        DETAIL
         app_description = ap.description
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM pm_flx_conversation p,
         pm_sch_setup ps
        PLAN (ps
         WHERE (ps.task_number=reply->position_list[x].task[y].number)
          AND (ps.position_cd=reply->position_list[x].position_code_value))
         JOIN (p
         WHERE p.task=ps.task_number
          AND p.active_ind=1)
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET reply->position_list[x].task[y].description = trim(app_description,3)
        SET reply->position_list[x].task[y].no_conversation_ind = 1
       ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
  IF ((overall_cnt > request->max_reply)
   AND (request->max_reply > 0))
   SET stat = alterlist(reply->position_list,0)
   SET reply->too_many_results_ind = 1
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
