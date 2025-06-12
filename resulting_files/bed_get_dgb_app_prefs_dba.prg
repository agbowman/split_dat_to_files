CREATE PROGRAM bed_get_dgb_app_prefs:dba
 FREE SET reply
 RECORD reply(
   1 levels[*]
     2 application_number = i4
     2 position_code_value = f8
     2 prsnl_id = f8
     2 pvc_name = vc
     2 pvc_value = vc
     2 pref_id = f8
     2 app_level_ind = i2
     2 position_level_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE aparse = vc
 SET req_cnt = size(request->levels,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->levels,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET pos_remove = 0
   SET reply->levels[x].application_number = request->levels[x].application_number
   SET reply->levels[x].position_code_value = request->levels[x].position_code_value
   SET reply->levels[x].prsnl_id = request->levels[x].prsnl_id
   SET reply->levels[x].pvc_name = request->levels[x].pvc_name
   IF ((reply->levels[x].prsnl_id > 0)
    AND (reply->levels[x].position_code_value=0))
    SET pos_remove = 1
    SELECT INTO "nl:"
     FROM prsnl p
     WHERE (p.person_id=reply->levels[x].prsnl_id)
      AND p.active_ind=1
     DETAIL
      reply->levels[x].position_code_value = p.position_cd
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM app_prefs a,
     name_value_prefs nvp
    PLAN (a
     WHERE (a.application_number=reply->levels[x].application_number)
      AND (a.position_cd=reply->levels[x].position_code_value)
      AND (a.prsnl_id=reply->levels[x].prsnl_id)
      AND a.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_id=a.app_prefs_id
      AND nvp.parent_entity_name="APP_PREFS"
      AND (trim(nvp.pvc_name)=reply->levels[x].pvc_name)
      AND nvp.active_ind=1)
    DETAIL
     reply->levels[x].pvc_value = nvp.pvc_value, reply->levels[x].pref_id = nvp.name_value_prefs_id
     IF (a.position_cd > 0
      AND a.prsnl_id=0)
      reply->levels[x].position_level_ind = 1
     ELSEIF (a.application_number > 0
      AND a.position_cd=0
      AND a.prsnl_id=0)
      reply->levels[x].app_level_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0
    AND (((reply->levels[x].position_code_value > 0)) OR ((reply->levels[x].prsnl_id > 0))) )
    SET aparse = build("a.application_number = ",reply->levels[x].application_number,
     " and a.prsnl_id = 0 and a.active_ind = 1 ")
    IF ((reply->levels[x].prsnl_id > 0))
     SET aparse = build(aparse," and a.position_cd =",reply->levels[x].position_code_value)
    ELSE
     SET aparse = build(aparse," and a.position_cd = 0")
    ENDIF
    SELECT INTO "nl:"
     FROM app_prefs a,
      name_value_prefs nvp
     PLAN (a
      WHERE parser(aparse))
      JOIN (nvp
      WHERE nvp.parent_entity_id=a.app_prefs_id
       AND nvp.parent_entity_name="APP_PREFS"
       AND (trim(nvp.pvc_name)=reply->levels[x].pvc_name)
       AND nvp.active_ind=1)
     DETAIL
      reply->levels[x].pvc_value = nvp.pvc_value, reply->levels[x].pref_id = nvp.name_value_prefs_id
      IF (a.position_cd > 0)
       reply->levels[x].position_level_ind = 1
      ELSE
       reply->levels[x].app_level_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0
     AND (reply->levels[x].position_code_value > 0)
     AND (reply->levels[x].prsnl_id > 0))
     SELECT INTO "nl:"
      FROM app_prefs a,
       name_value_prefs nvp
      PLAN (a
       WHERE (a.application_number=reply->levels[x].application_number)
        AND a.position_cd=0
        AND a.prsnl_id=0
        AND a.active_ind=1)
       JOIN (nvp
       WHERE nvp.parent_entity_id=a.app_prefs_id
        AND nvp.parent_entity_name="APP_PREFS"
        AND (trim(nvp.pvc_name)=reply->levels[x].pvc_name)
        AND nvp.active_ind=1)
      DETAIL
       reply->levels[x].pvc_value = nvp.pvc_value, reply->levels[x].pref_id = nvp.name_value_prefs_id,
       reply->levels[x].app_level_ind = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (pos_remove=1)
    SET reply->levels[x].position_code_value = 0
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
