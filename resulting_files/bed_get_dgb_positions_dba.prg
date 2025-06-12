CREATE PROGRAM bed_get_dgb_positions:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
     2 pvc_value = vc
     2 defined_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET tpos
 RECORD tpos(
   1 pos[*]
     2 code_value = f8
     2 display = vc
     2 pos_ind = i2
 )
 DECLARE vname = vc
 DECLARE vprefs = vc
 DECLARE cparse = vc
 DECLARE nparse = vc
 SET reply->status_data.status = "F"
 SET cparse = "c.code_set = 88 and c.active_ind = 1 "
 IF ((request->search_text > " "))
  IF ((request->search_type_flag="S"))
   SET cparse = concat(cparse," and c.display_key = '",trim(cnvtupper(cnvtalphanum(request->
       search_text))),"*'"," and c.display = '",
    request->search_text,"*'")
  ELSEIF ((request->search_type_flag="C"))
   SET cparse = concat(cparse," and c.display_key = '*",trim(cnvtupper(cnvtalphanum(request->
       search_text))),"*'"," and c.display = '*",
    request->search_text,"*'")
  ENDIF
 ENDIF
 SET nparse =
 "nvp.parent_entity_id = a.app_prefs_id and nvp.parent_entity_name = 'APP_PREFS' and nvp.active_ind = 1 "
 SET vprefs =
 "nvp.parent_entity_id = a.app_prefs_id and nvp.parent_entity_name = 'APP_PREFS' and nvp.active_ind = 1 "
 IF ((request->pvc_name > " "))
  SET nparse = concat(nparse," nvp.pvc_name = '",request->pvc_name,"'")
 ENDIF
 SET tcnt = 0
 IF ((request->message_center_ind=1))
  SET vname = "PVINBOX"
  SET vprefs = concat(vprefs,
   " and nvp.pvc_name in ('MSG_DB_ROWS','MSG_DB_COLS','MSG_DB_EVENT_STATUS','MSG_DB_CUSTOM_SCRIPT',",
   "'MSG_DB_PATIENT_PICTURE'",")")
  SET tpcnt = 0
  SELECT INTO "nl:"
   FROM code_value c,
    view_prefs v
   PLAN (c
    WHERE parser(cparse))
    JOIN (v
    WHERE v.position_cd IN (c.code_value, 0)
     AND (v.application_number=request->application_number)
     AND v.prsnl_id=0
     AND v.view_name="PVINBOX"
     AND v.frame_type="ORG"
     AND v.active_ind=1)
   ORDER BY c.code_value
   HEAD REPORT
    cnt = 0, tpcnt = 0, stat = alterlist(tpos->pos,100)
   HEAD c.code_value
    cnt = (cnt+ 1), tpcnt = (tpcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tpos->pos,(tpcnt+ 100)), cnt = 1
    ENDIF
    tpos->pos[tpcnt].code_value = c.code_value, tpos->pos[tpcnt].display = c.display
   DETAIL
    IF (v.position_cd > 0)
     tpos->pos[tpcnt].pos_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(tpos->pos,tpcnt)
   WITH nocounter
  ;end select
  IF (tpcnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tpcnt)),
    view_prefs v
   PLAN (d
    WHERE (tpos->pos[d.seq].pos_ind=0))
    JOIN (v
    WHERE (v.position_cd=tpos->pos[d.seq].code_value)
     AND (v.application_number=request->application_number)
     AND v.frame_type="ORG"
     AND v.prsnl_id=0
     AND v.active_ind=1)
   ORDER BY d.seq
   DETAIL
    tpos->pos[d.seq].pos_ind = 3
   WITH nocounter
  ;end select
  SET tcnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tpcnt))
   PLAN (d
    WHERE (tpos->pos[d.seq].pos_ind IN (0, 1)))
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(reply->positions,100)
   HEAD d.seq
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->positions,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->positions[tcnt].code_value = tpos->pos[d.seq].code_value, reply->positions[tcnt].display
     = tpos->pos[d.seq].display
   FOOT REPORT
    stat = alterlist(reply->positions,tcnt)
   WITH nocounter
  ;end select
 ELSE
  SET vname = "CHART"
  SET vprefs = concat(vprefs,
   " and nvp.pvc_name in ('CHT_DB_ROWS','CHT_DB_COLS','CHT_DB_EVENT_STATUS','CHT_DB_CUSTOM_SCRIPT',",
   "'CHT_DB_PATIENT_PICTURE'",")")
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE parser(cparse))
   ORDER BY c.code_value
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(reply->positions,100)
   HEAD c.code_value
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->positions,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->positions[tcnt].code_value = c.code_value, reply->positions[tcnt].display = c.display
   FOOT REPORT
    stat = alterlist(reply->positions,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   app_prefs a,
   name_value_prefs nvp,
   br_prefs b
  PLAN (d)
   JOIN (a
   WHERE (a.application_number=request->application_number)
    AND (a.position_cd=reply->positions[d.seq].code_value)
    AND a.prsnl_id=0
    AND a.active_ind=1)
   JOIN (nvp
   WHERE parser(nparse))
   JOIN (b
   WHERE b.pvc_name=nvp.pvc_name
    AND b.view_name=vname)
  ORDER BY d.seq
  HEAD d.seq
   reply->positions[d.seq].defined_ind = 1
   IF ((request->pvc_name > " "))
    reply->positions[d.seq].pvc_value = nvp.pvc_value
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->pvc_name IN ("", " ", null)))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    app_prefs a,
    name_value_prefs nvp
   PLAN (d
    WHERE (reply->positions[d.seq].defined_ind != 1))
    JOIN (a
    WHERE (a.application_number=request->application_number)
     AND (a.position_cd=reply->positions[d.seq].code_value)
     AND a.prsnl_id=0
     AND a.active_ind=1)
    JOIN (nvp
    WHERE parser(vprefs))
   ORDER BY d.seq
   HEAD d.seq
    reply->positions[d.seq].defined_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
