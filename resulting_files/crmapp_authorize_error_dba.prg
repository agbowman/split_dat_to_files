CREATE PROGRAM crmapp_authorize_error:dba
 IF (cnvtupper( $1)="NORDBMS")
  GO TO exit_point
 ENDIF
 IF ((reply->reqinfo.updt_id=0))
  CALL echo("User not found will select...")
  SET user_active_ind = 0
  SET position_active_ind = 0
  SELECT INTO "nl:"
   p.position_cd
   FROM prsnl p,
    code_value cv
   PLAN (p
    WHERE (p.username=request->username))
    JOIN (cv
    WHERE cv.code_value=p.position_cd)
   DETAIL
    IF (p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ((p.end_effective_dt_tm=0) OR (p.end_effective_dt_tm > cnvtdatetime(curdate,curtime)))
     AND p.active_ind=1)
     user_active_ind = 1
    ENDIF
    IF (cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ((cv.end_effective_dt_tm=0) OR (cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime)))
     AND cv.active_ind=1)
     position_active_ind = 1
    ELSE
     position_active_ind = 0
    ENDIF
    reply->clientreqinfo.person_name = p.name_full_formatted, reply->clientreqinfo.position_cd = p
    .position_cd, reply->clientreqinfo.updt_id = p.person_id,
    reply->clientreqinfo.username = p.username, reply->clientreqinfo.updt_appid = request->
    application_number, reply->clientreqinfo.physician_ind = p.physician_ind,
    reply->clientreqinfo.email = p.email, reply->reqinfo.position_cd = p.position_cd, reply->reqinfo.
    updt_id = p.person_id,
    reply->reqinfo.updt_appid = request->application_number
   WITH nocounter
  ;end select
  IF (curqual > 0)
   IF (user_active_ind=0)
    SET reply->status_data.substatus = 51
   ELSE
    IF (position_active_ind=0)
     SET reply->status_data.substatus = 58
    ENDIF
    IF ((reply->status_data.substatus=0))
     SET reply->status_data.substatus = 52
    ENDIF
   ENDIF
  ELSE
   SET reply->status_data.substatus = 50
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    DETAIL
     reply->clientreqinfo.person_name = "Person not found on PRSNL Table", reply->clientreqinfo.
     position_cd = p.position_cd, reply->clientreqinfo.updt_id = p.person_id,
     reply->clientreqinfo.username = request->username, reply->clientreqinfo.updt_appid = request->
     application_number, reply->clientreqinfo.physician_ind = p.physician_ind,
     reply->clientreqinfo.email = p.email, reply->reqinfo.position_cd = p.position_cd, reply->reqinfo
     .updt_id = p.person_id,
     reply->reqinfo.updt_appid = request->application_number
    WITH nocounter, maxqual(p,1)
   ;end select
  ENDIF
 ENDIF
 EXECUTE crmapp_authorize_context
#exit_script
 COMMIT
#exit_point
END GO
