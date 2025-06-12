CREATE PROGRAM bed_get_pos_by_app_prefs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 positions[*]
      2 position_code_value = f8
      2 position_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE nvp_parse = vc WITH protect
 DECLARE search_ind = i2 WITH protect
 DECLARE global_pass_ind = i2 WITH protect
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 IF ((request->application=0))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Aplication = 0")
  GO TO exit_script
 ENDIF
 SET nvp_parse = concat(" n.parent_entity_id = outerjoin(a.app_prefs_id) and ",
  " n.parent_entity_name = outerjoin('APP_PREFS') and n.active_ind = outerjoin(1) ",
  " and trim(n.pvc_name) = outerjoin('",trim(request->pvc_name),"') ")
 IF ((request->pvc_name > " "))
  SET search_ind = 1
 ELSE
  IF ((request->pvc_value > " "))
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("No pvc_name")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->pvc_value > " "))
  SET search_ind = 2
 ENDIF
 SELECT INTO "nl:"
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE a.position_cd=0.0
    AND (a.application_number=request->application)
    AND a.prsnl_id=0.0
    AND a.active_ind=1)
   JOIN (n
   WHERE parser(nvp_parse))
  DETAIL
   IF (((n.name_value_prefs_id > 0
    AND ((search_ind=1) OR (search_ind=2
    AND (request->pvc_value=n.pvc_value))) ) OR (search_ind=0)) )
    global_pass_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c,
   app_prefs a,
   name_value_prefs n
  PLAN (c
   WHERE c.code_set=88
    AND c.active_ind=1)
   JOIN (a
   WHERE a.position_cd=outerjoin(c.code_value)
    AND a.application_number=outerjoin(request->application)
    AND a.prsnl_id=outerjoin(0.0)
    AND a.active_ind=outerjoin(1))
   JOIN (n
   WHERE parser(nvp_parse))
  ORDER BY c.code_value
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->positions,100)
  HEAD c.code_value
   IF (((((a.app_prefs_id=0) OR (n.name_value_prefs_id=0.0))
    AND global_pass_ind=1) OR (((n.name_value_prefs_id > 0
    AND ((search_ind=1) OR (search_ind=2
    AND (request->pvc_value=n.pvc_value))) ) OR (search_ind=0)) )) )
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->positions,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->positions[tcnt].position_code_value = c.code_value, reply->positions[tcnt].
    position_display = c.display
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->positions,tcnt)
  WITH nocounter
 ;end select
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
