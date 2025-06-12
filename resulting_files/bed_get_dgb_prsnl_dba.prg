CREATE PROGRAM bed_get_dgb_prsnl:dba
 FREE SET reply
 RECORD reply(
   1 prsnl[*]
     2 prsnl_id = f8
     2 name_full_formatted = vc
     2 position_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET tprsnl
 RECORD tprsnl(
   1 prsnl[*]
     2 prsnl_id = f8
     2 pos_code_value = f8
 )
 DECLARE vname = vc
 DECLARE vprefs = vc
 DECLARE pparse = vc
 SET reply->status_data.status = "F"
 SET vprefs =
 "nvp.parent_entity_id = a.app_prefs_id and nvp.parent_entity_name = 'APP_PREFS' and nvp.active_ind = 1 "
 IF ((request->message_center_ind=1))
  SET vname = "PVINBOX"
  SET vprefs = concat(vprefs,
   " and nvp.pvc_name in ('MSG_DB_ROWS','MSG_DB_COLS','MSG_DB_EVENT_STATUS','MSG_DB_CUSTOM_SCRIPT',",
   "'MSG_DB_PATIENT_PICTURE'",")")
 ELSE
  SET vname = "CHART"
  SET vprefs = concat(vprefs,
   " and nvp.pvc_name in ('CHT_DB_ROWS','CHT_DB_COLS','CHT_DB_EVENT_STATUS','CHT_DB_CUSTOM_SCRIPT',",
   "'CHT_DB_PATIENT_PICTURE'",")")
 ENDIF
 SET pparse = "p.active_ind = 1 "
 IF ((request->username > " "))
  SET pparse = concat(pparse," and cnvtupper(p.username) = '",cnvtupper(request->username),"*' ")
 ENDIF
 IF ((request->first_name > " "))
  SET pparse = concat(pparse," and cnvtupper(p.name_first) = '",cnvtupper(request->first_name),"*' ")
 ENDIF
 IF ((request->last_name > " "))
  SET pparse = concat(pparse," and cnvtupper(p.name_last) = '",cnvtupper(request->last_name),"*' ")
 ENDIF
 IF ((request->position_code_value > 0))
  SET pparse = concat(pparse," and p.position_cd = request->position_code_value ")
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM prsnl p,
   app_prefs a,
   name_value_prefs nvp,
   br_prefs b
  PLAN (p
   WHERE parser(pparse))
   JOIN (a
   WHERE (a.application_number=request->application_number)
    AND a.position_cd=0
    AND a.prsnl_id=p.person_id
    AND a.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=a.app_prefs_id
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.active_ind=1)
   JOIN (b
   WHERE b.pvc_name=nvp.pvc_name
    AND b.view_name=vname)
  ORDER BY p.person_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(tprsnl->prsnl,100)
  HEAD p.person_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(tprsnl->prsnl,(tcnt+ 100)), cnt = 1
   ENDIF
   tprsnl->prsnl[tcnt].prsnl_id = p.person_id, tprsnl->prsnl[tcnt].pos_code_value = p.position_cd
  FOOT REPORT
   stat = alterlist(tprsnl->prsnl,tcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p,
   app_prefs a,
   name_value_prefs nvp
  PLAN (p
   WHERE parser(pparse))
   JOIN (a
   WHERE (a.application_number=request->application_number)
    AND a.position_cd=0
    AND a.prsnl_id=p.person_id
    AND a.active_ind=1)
   JOIN (nvp
   WHERE parser(vprefs))
  ORDER BY p.person_id
  HEAD REPORT
   cnt = 0, stat = alterlist(tprsnl->prsnl,(tcnt+ 100))
  HEAD p.person_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(tprsnl->prsnl,(tcnt+ 100)), cnt = 1
   ENDIF
   tprsnl->prsnl[tcnt].prsnl_id = p.person_id, tprsnl->prsnl[tcnt].pos_code_value = p.position_cd
  FOOT REPORT
   stat = alterlist(tprsnl->prsnl,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    prsnl p
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=tprsnl->prsnl[d.seq].prsnl_id))
   ORDER BY p.person_id
   HEAD REPORT
    cnt = 0, pcnt = 0, stat = alterlist(reply->prsnl,100)
   HEAD p.person_id
    cnt = (cnt+ 1), pcnt = (pcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->prsnl,(pcnt+ 100)), cnt = 1
    ENDIF
    reply->prsnl[pcnt].prsnl_id = p.person_id, reply->prsnl[pcnt].name_full_formatted = p
    .name_full_formatted, reply->prsnl[pcnt].position_code_value = tprsnl->prsnl[d.seq].
    pos_code_value
   FOOT REPORT
    stat = alterlist(reply->prsnl,pcnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
