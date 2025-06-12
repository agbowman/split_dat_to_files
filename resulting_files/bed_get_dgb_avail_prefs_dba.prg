CREATE PROGRAM bed_get_dgb_avail_prefs:dba
 FREE SET reply
 RECORD reply(
   1 prefs[*]
     2 pvc_name = vc
     2 name = vc
     2 code_level = vc
     2 pvc_value = vc
     2 app_level_ind = i2
     2 pref_id = f8
     2 default_value = vc
     2 child_prefs[*]
       3 pvc_name = vc
       3 default_value = vc
       3 type_flag = i4
       3 pvc_value = vc
       3 app_level_ind = i2
       3 pref_id = f8
       3 position_level_ind = i2
     2 position_level_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE vname = vc
 SET reply->status_data.status = "F"
 IF ((request->chart_ind=1))
  SET vname = "CHART"
 ENDIF
 IF ((request->message_center_ind=1))
  SET vname = "PVINBOX"
 ENDIF
 IF ((request->prsnl_id > 0)
  AND (request->position_code_value=0))
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE (p.person_id=request->prsnl_id)
    AND p.active_ind=1
   DETAIL
    request->position_code_value = p.position_cd
   WITH nocounter
  ;end select
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM br_prefs b,
   br_prefs b2
  PLAN (b
   WHERE b.parent_prefs_id=0
    AND b.view_name=vname)
   JOIN (b2
   WHERE b2.parent_prefs_id=b.br_prefs_id)
  ORDER BY b.br_prefs_id, b2.br_prefs_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->prefs,100)
  HEAD b.br_prefs_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->prefs,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->prefs[tcnt].pvc_name = b.pvc_name, reply->prefs[tcnt].name = b.br_name, reply->prefs[tcnt].
   code_level = b.code_level,
   reply->prefs[tcnt].default_value = b.default_value, ccnt = 0, ctcnt = 0,
   stat = alterlist(reply->prefs[tcnt].child_prefs,100)
  HEAD b2.br_prefs_id
   ccnt = (ccnt+ 1), ctcnt = (ctcnt+ 1)
   IF (ccnt > 100)
    stat = alterlist(reply->prefs[tcnt].child_prefs,(ctcnt+ 100)), ccnt = 1
   ENDIF
   reply->prefs[tcnt].child_prefs[ctcnt].pvc_name = b2.pvc_name, reply->prefs[tcnt].child_prefs[ctcnt
   ].type_flag = b2.type_flag, reply->prefs[tcnt].child_prefs[ctcnt].default_value = b2.default_value
  FOOT  b.br_prefs_id
   stat = alterlist(reply->prefs[tcnt].child_prefs,ctcnt)
  FOOT REPORT
   stat = alterlist(reply->prefs,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    app_prefs a,
    name_value_prefs nvp
   PLAN (d)
    JOIN (a
    WHERE (a.application_number=request->application_number)
     AND a.position_cd IN (request->position_code_value, 0, null)
     AND a.prsnl_id IN (request->prsnl_id, 0, null)
     AND a.active_ind=1)
    JOIN (nvp
    WHERE (trim(nvp.pvc_name)=reply->prefs[d.seq].pvc_name)
     AND nvp.parent_entity_id=a.app_prefs_id
     AND nvp.parent_entity_name="APP_PREFS"
     AND nvp.active_ind=1)
   ORDER BY d.seq, a.position_cd, a.prsnl_id
   HEAD d.seq
    found = 0
   DETAIL
    IF (found=0)
     reply->prefs[d.seq].pvc_value = nvp.pvc_value, reply->prefs[d.seq].pref_id = nvp
     .name_value_prefs_id
     IF (a.position_cd IN (0, null)
      AND a.prsnl_id IN (0, null))
      reply->prefs[d.seq].app_level_ind = 1
     ELSEIF (a.position_cd > 0
      AND a.prsnl_id IN (0, null))
      reply->prefs[d.seq].app_level_ind = 0, reply->prefs[d.seq].position_level_ind = 1
     ENDIF
    ELSEIF ((((reply->prefs[d.seq].app_level_ind=1)) OR ((reply->prefs[d.seq].position_level_ind=1)
    )) )
     IF (a.prsnl_id > 0)
      reply->prefs[d.seq].app_level_ind = 0, reply->prefs[d.seq].position_level_ind = 0
     ELSEIF (a.position_cd > 0)
      reply->prefs[d.seq].app_level_ind = 0, reply->prefs[d.seq].position_level_ind = 1
     ENDIF
     reply->prefs[d.seq].pvc_value = nvp.pvc_value, reply->prefs[d.seq].pref_id = nvp
     .name_value_prefs_id
    ENDIF
    found = 1
   WITH nocounter
  ;end select
  FOR (x = 1 TO tcnt)
   SET csize = size(reply->prefs[x].child_prefs,5)
   IF (csize > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(csize)),
      app_prefs a,
      name_value_prefs nvp
     PLAN (d)
      JOIN (a
      WHERE (a.application_number=request->application_number)
       AND a.position_cd IN (request->position_code_value, 0, null)
       AND a.prsnl_id IN (request->prsnl_id, 0, null)
       AND a.active_ind=1)
      JOIN (nvp
      WHERE (trim(nvp.pvc_name)=reply->prefs[x].child_prefs[d.seq].pvc_name)
       AND nvp.parent_entity_id=a.app_prefs_id
       AND nvp.parent_entity_name="APP_PREFS"
       AND nvp.active_ind=1)
     ORDER BY d.seq, a.position_cd, a.prsnl_id
     HEAD d.seq
      loaded_ind = 0
     DETAIL
      IF (loaded_ind=0)
       reply->prefs[x].child_prefs[d.seq].pref_id = nvp.name_value_prefs_id, reply->prefs[x].
       child_prefs[d.seq].pvc_value = nvp.pvc_value
       IF (a.position_cd IN (0, null)
        AND a.prsnl_id IN (0, null))
        reply->prefs[x].child_prefs[d.seq].app_level_ind = 1
       ELSEIF (a.position_cd > 0
        AND a.prsnl_id IN (0, null))
        reply->prefs[x].child_prefs[d.seq].app_level_ind = 0, reply->prefs[x].child_prefs[d.seq].
        position_level_ind = 1
       ENDIF
       loaded_ind = 1
      ELSE
       IF ((((reply->prefs[x].child_prefs[d.seq].app_level_ind=1)) OR ((reply->prefs[x].child_prefs[d
       .seq].position_level_ind=1))) )
        IF (a.prsnl_id > 0)
         reply->prefs[x].child_prefs[d.seq].app_level_ind = 0, reply->prefs[x].child_prefs[d.seq].
         position_level_ind = 0
        ELSEIF (a.position_cd > 0)
         reply->prefs[x].child_prefs[d.seq].app_level_ind = 0, reply->prefs[x].child_prefs[d.seq].
         position_level_ind = 1
        ENDIF
        reply->prefs[x].child_prefs[d.seq].pvc_value = nvp.pvc_value, reply->prefs[x].child_prefs[d
        .seq].pref_id = nvp.name_value_prefs_id
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
