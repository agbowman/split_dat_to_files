CREATE PROGRAM bed_rec_disch_modify_prescript
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tempids(
   1 ids[*]
     2 position_cd = f8
     2 application_number = f8
   1 ords[*]
     2 position_cd = f8
     2 application_number = f8
 )
 SET reply->run_status_flag = 1
 SET tcnt = 0
 SET scnt = 0
 SET powerchart_eval = 0
 SET surginet_eval = 0
 SET firstnet_eval = 0
 SELECT INTO "nl:"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE ap.application_number IN (600005, 820000, 4250111)
    AND ap.position_cd=0
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.pvc_name="DSCH_MODIFY_ORDER"
    AND nvp.active_ind=1)
  DETAIL
   IF (ap.application_number=600005
    AND nvp.pvc_value="REJECT")
    powerchart_eval = 1
   ELSEIF (ap.application_number=820000
    AND nvp.pvc_value="REJECT")
    surginet_eval = 1
   ELSEIF (ap.application_number=4250111
    AND nvp.pvc_value="REJECT")
    firstnet_eval = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (powerchart_eval=1)
  SET powerchart_found = 0
  SELECT INTO "nl:"
   FROM app_prefs ap,
    name_value_prefs nvp
   PLAN (ap
    WHERE ap.application_number=600005
     AND ap.position_cd=0
     AND ap.prsnl_id=0
     AND ap.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name="DSCH_MODIFY_PRESCRIPTION"
     AND nvp.active_ind=1)
   DETAIL
    IF (nvp.pvc_value="ALLOW")
     powerchart_found = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (powerchart_found=0)
   SET reply->run_status_flag = 3
  ENDIF
  CALL echo(build("Powerchart",powerchart_found))
 ENDIF
 IF (firstnet_eval=1)
  SET firstnet_found = 0
  SELECT INTO "nl:"
   FROM app_prefs ap,
    name_value_prefs nvp
   PLAN (ap
    WHERE ap.application_number=4250111
     AND ap.position_cd=0
     AND ap.prsnl_id=0
     AND ap.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name="DSCH_MODIFY_PRESCRIPTION"
     AND nvp.active_ind=1)
   DETAIL
    IF (nvp.pvc_value="ALLOW")
     firstnet_found = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (firstnet_found=0)
   SET reply->run_status_flag = 3
  ENDIF
  CALL echo(build("Firstnet",firstnet_found))
 ENDIF
 IF (surginet_eval=1)
  SET surginet_found = 0
  SELECT INTO "nl:"
   FROM app_prefs ap,
    name_value_prefs nvp
   PLAN (ap
    WHERE ap.application_number=820000
     AND ap.position_cd=0
     AND ap.prsnl_id=0
     AND ap.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name="DSCH_MODIFY_PRESCRIPTION"
     AND nvp.active_ind=1)
   DETAIL
    IF (nvp.pvc_value="ALLOW")
     surginet_found = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (surginet_found=0)
   SET reply->run_status_flag = 3
  ENDIF
  CALL echo(build("Surginet",surginet_found))
 ENDIF
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM app_prefs ap,
    code_value cv,
    prsnl p,
    name_value_prefs nvp
   PLAN (ap
    WHERE ap.application_number IN (600005, 820000, 4250111)
     AND ap.position_cd > 0
     AND ap.prsnl_id=0
     AND ap.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ap.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=ap.position_cd
     AND p.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name="DSCH_MODIFY_ORDER"
     AND nvp.active_ind=1)
   HEAD ap.application_number
    temp_cnt = 0
   HEAD ap.position_cd
    IF (nvp.pvc_value="REJECT")
     tcnt = (tcnt+ 1), stat = alterlist(tempids->ids,tcnt), tempids->ids[tcnt].position_cd = ap
     .position_cd,
     tempids->ids[tcnt].application_number = ap.application_number
    ENDIF
    scnt = (scnt+ 1), stat = alterlist(tempids->ords,scnt), tempids->ords[scnt].position_cd = ap
    .position_cd,
    tempids->ords[scnt].application_number = ap.application_number
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = scnt),
    app_prefs ap,
    code_value cv,
    prsnl p,
    name_value_prefs nvp,
    dummyt d1
   PLAN (ap
    WHERE ap.application_number IN (600005, 820000, 4250111)
     AND ap.position_cd > 0
     AND ap.prsnl_id=0
     AND ap.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ap.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=ap.position_cd
     AND p.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name != "DSCH_MODIFY_ORDER"
     AND nvp.active_ind=1)
    JOIN (d1)
    JOIN (d
    WHERE (tempids->ords[d.seq].position_cd=ap.position_cd)
     AND (tempids->ords[d.seq].application_number=ap.application_number))
   HEAD ap.application_number
    temp_cnt = 0
   HEAD ap.position_cd
    CALL echo(build("position",ap.position_cd)),
    CALL echo(build("app",ap.application_number))
    IF (((ap.application_number=600005
     AND powerchart_eval=1) OR (((ap.application_number=820000
     AND surginet_eval=1) OR (ap.application_number=4250111
     AND firstnet_eval=1)) )) )
     tcnt = (tcnt+ 1), stat = alterlist(tempids->ids,tcnt), tempids->ids[tcnt].position_cd = ap
     .position_cd,
     tempids->ids[tcnt].application_number = ap.application_number
    ENDIF
   WITH nocounter, outerjoin = d1, dontexist
  ;end select
  IF (tcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tcnt),
     app_prefs ap,
     code_value cv,
     prsnl p,
     name_value_prefs nvp
    PLAN (d
     WHERE (tempids->ids[d.seq].position_cd > 0))
     JOIN (ap
     WHERE (ap.application_number=tempids->ids[d.seq].application_number)
      AND (ap.position_cd=tempids->ids[d.seq].position_cd)
      AND ap.prsnl_id=0
      AND ap.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=ap.position_cd
      AND cv.active_ind=1)
     JOIN (p
     WHERE p.position_cd=ap.position_cd
      AND p.active_ind=1)
     JOIN (nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND nvp.parent_entity_id=ap.app_prefs_id
      AND nvp.pvc_name="DSCH_MODIFY_PRESCRIPTION"
      AND nvp.active_ind=1)
    ORDER BY ap.application_number, cv.display, ap.position_cd
    HEAD ap.application_number
     temp_cnt = 0
    HEAD ap.position_cd
     IF (nvp.pvc_value != "ALLOW")
      reply->run_status_flag = 3
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
