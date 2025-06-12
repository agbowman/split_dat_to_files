CREATE PROGRAM crmapp_authorize:dba
 DECLARE infodomain = vc WITH noconstant
 DECLARE infoname = vc WITH noconstant
 DECLARE infochar = vc WITH noconstant
 DECLARE urp_pos_location = i4 WITH noconstant
 DECLARE app_number_position = i4 WITH noconstant
 DECLARE app_number = vc WITH noconstant
 DECLARE appnum = i4 WITH noconstant
 DECLARE role_profile = vc WITH noconstant
 DECLARE info_char_size = i4 WITH noconstant(- (1))
 DECLARE last_comma_position = i4 WITH noconstant(- (1))
 DECLARE endofstring = i4 WITH noconstant(- (1))
 DECLARE appnumstring = vc WITH noconstant
 DECLARE appnumbersize = i4 WITH noconstant(- (1))
 DECLARE logusernotfound(null) = null
 DECLARE isactive = i4 WITH noconstant(0)
 DECLARE roleprofileposition = f8 WITH noconstant(0)
 DECLARE uar_sacgetuserroleprofiledetails() = i4 WITH image_lnx = "libsac.so", image_aix =
 "libsac.a(libsac.o)", uar = "SacGetUserRoleProfileDetails",
 persist
 SET reply->status_data.substatus = 0
 SET request->username = cnvtupper(request->username)
 SET prefcnt = 0
 SET ap_number_to_insert = size(request->paramlist,5)
 SET process_status = "F"
 SET user_active_ind = 0
 SET position_active_ind = 0
 SET role_active_ind = 0
 SET app_active_ind = 0
 SET cnt = 0
 CALL echo(concat("Login processing for user: ",request->username," for application: ",cnvtstring(
    request->application_number)))
 IF ((request->updt_applctx > 0))
  RECORD endappreq(
    1 applctx = i4
    1 status_code = i2
  )
  RECORD endapprep(
    1 status_data
      2 status = c1
  )
  SET endappreq->applctx = request->updt_applctx
  SET endappreq->status_code = 0
  EXECUTE crmapp_endapp "RDBMS" WITH replace(request,endappreq), replace(reply,endapprep)
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(authinfo)=0)
  CALL echo("authInfo not defined... define and default to legacy")
  RECORD authinfo(
    1 logontype = i4
    1 logonid = c80
  )
  SET authinfo->logontype = 0
 ENDIF
 CALL echorecord(authinfo)
 SET reply->reqinfo.updt_appid = request->application_number
 SET reply->reqinfo.client_node_name = request->client_node_name
 SET reply->clientreqinfo.updt_appid = request->application_number
 SET reply->clientreqinfo.log_level = request->log_level
 SET reply->clientreqinfo.device_address = request->device_address
 SET reply->clientreqinfo.device_location = request->device_location
 SET reply->clientreqinfo.username = request->username
 SET reply->request_log_level = request->request_log_level
 IF ((request->client_log_level > request->log_level))
  SET reply->clientreqinfo.log_level = request->client_log_level
 ENDIF
 IF (cnvtupper( $1)="NORDBMS")
  GO TO exit_script
 ENDIF
 IF ((reply->clientreqinfo.position_cd > 0))
  CALL echo("Using user information provided with security context")
  CALL echo(build("person_id:",reply->clientreqinfo.updt_id))
  CALL echo(build("position_cd:",reply->clientreqinfo.position_cd))
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM person p
   WHERE (p.person_id=reply->clientreqinfo.updt_id)
   DETAIL
    reply->clientreqinfo.person_name = p.name_full_formatted
   WITH nocounter
  ;end select
  SET process_status = "S"
  GO TO log_app_context
 ENDIF
 IF ((authinfo->logontype=1))
  CALL echo("Lookup user with the role profile code")
  SELECT INTO "nl:"
   prt.prsnl_id, prt.access_position_cd, p.name_full_formatted
   FROM prsnl_org_reltn_type prt,
    prsnl p,
    code_value cv
   WHERE prt.role_profile=trim(authinfo->logonid)
    AND p.person_id=prt.prsnl_id
    AND cv.code_value=prt.access_position_cd
   ORDER BY prt.active_ind
   DETAIL
    IF (((user_active_ind=0) OR (((position_active_ind=0) OR (role_active_ind=0)) )) )
     IF (prt.active_ind=1
      AND prt.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
      AND ((prt.end_effective_dt_tm=0) OR (prt.end_effective_dt_tm > cnvtdatetime(curdate,curtime)))
     )
      role_active_ind = 1
     ELSE
      role_active_ind = 0
     ENDIF
     IF (p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
      AND ((p.end_effective_dt_tm=0) OR (p.end_effective_dt_tm > cnvtdatetime(curdate,curtime))) )
      user_active_ind = 1
     ELSE
      user_active_ind = 0
     ENDIF
     IF (cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
      AND ((cv.end_effective_dt_tm=0) OR (cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime))) )
      position_active_ind = 1
     ELSE
      position_active_ind = 0
     ENDIF
     IF (user_active_ind=1
      AND position_active_ind=1
      AND role_active_ind=1)
      reply->clientreqinfo.person_name = p.name_full_formatted, reply->clientreqinfo.position_cd =
      prt.access_position_cd, reply->clientreqinfo.updt_id = prt.prsnl_id,
      reply->clientreqinfo.physician_ind = p.physician_ind, reply->clientreqinfo.email = p.email,
      reply->reqinfo.position_cd = prt.access_position_cd,
      reply->reqinfo.updt_id = prt.prsnl_id, isactive = 1
     ENDIF
    ENDIF
   FOOT REPORT
    IF (isactive=0)
     reply->clientreqinfo.person_name = p.name_full_formatted, reply->clientreqinfo.position_cd = prt
     .access_position_cd, reply->clientreqinfo.updt_id = prt.prsnl_id,
     reply->clientreqinfo.physician_ind = p.physician_ind, reply->clientreqinfo.email = p.email,
     reply->reqinfo.position_cd = prt.access_position_cd,
     reply->reqinfo.updt_id = prt.prsnl_id
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   IF (isactive=0)
    IF (((user_active_ind=0) OR (role_active_ind=0)) )
     SET reply->status_data.substatus = 51
     GO TO log_app_context
    ELSE
     IF (position_active_ind=0)
      SET reply->status_data.substatus = 58
      GO TO log_app_context
     ENDIF
    ENDIF
   ENDIF
  ELSE
   SELECT INTO "nl:"
    di.info_domain, di.info_name, di.info_char
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="REMOTE_USER"
    ORDER BY di.info_char
    DETAIL
     infodomain = di.info_domain, infoname = di.info_name, infochar = di.info_char
    WITH nocounter, maxqual(di,1)
   ;end select
   IF (curqual=0)
    CALL logusernotfound(null)
    GO TO log_app_context
   ENDIF
   SET info_char_size = size(infochar,1)
   IF (info_char_size=0)
    CALL logusernotfound(null)
    GO TO log_app_context
   ENDIF
   SET urp_pos_location = findstring(":",infochar,1)
   IF (urp_pos_location=0
    AND info_char_size > 0)
    SET role_profile = infochar
   ELSE
    IF (urp_pos_location=info_char_size)
     CALL logusernotfound(null)
     GO TO log_app_context
    ENDIF
    SET role_profile = substring(0,(urp_pos_location - 1),infochar)
    SET last_comma_position = findstring(",",infochar,1,1)
    SET endofstring = findstring(";",infochar,1,1)
    SET app_number_position = (urp_pos_location+ 1)
    IF (last_comma_position=0)
     SET app_number = substring((urp_pos_location+ 1),(endofstring - (urp_pos_location+ 1)),infochar)
     SET appnumbersize = size(app_number,1)
     SET appnum = cnvtint(app_number)
     IF (((appnumbersize <= 0) OR ((appnum != request->application_number))) )
      CALL logusernotfound(null)
      GO TO log_app_context
     ENDIF
    ELSE
     WHILE (urp_pos_location < info_char_size)
       SET app_number_position = findstring(",",infochar,(urp_pos_location+ 1),0)
       IF (app_number_position > 0)
        SET app_number = substring((urp_pos_location+ 1),(app_number_position - (urp_pos_location+ 1)
         ),infochar)
        SET urp_pos_location = app_number_position
       ELSE
        IF (endofstring > 0)
         SET app_number = substring((urp_pos_location+ 1),((info_char_size - 1) - urp_pos_location),
          infochar)
        ELSE
         SET app_number = substring((urp_pos_location+ 1),(info_char_size - urp_pos_location),
          infochar)
        ENDIF
        SET appnumbersize = size(app_number,1)
        SET appnum = cnvtint(app_number)
        IF (((appnumbersize <= 0) OR ((appnum != request->application_number))) )
         SET urp_pos_location = info_char_size
         CALL logusernotfound(null)
         GO TO log_app_context
        ENDIF
       ENDIF
       SET appnum = cnvtint(app_number)
       IF ((appnum=request->application_number))
        SET urp_pos_location = info_char_size
       ENDIF
     ENDWHILE
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    prt.prsnl_id, prt.access_position_cd, p.name_full_formatted
    FROM prsnl_org_reltn_type prt,
     prsnl p,
     code_value cv
    WHERE prt.role_profile=role_profile
     AND p.person_id=prt.prsnl_id
     AND cv.code_value=prt.access_position_cd
     AND prt.active_ind=1
    DETAIL
     reply->clientreqinfo.person_name = p.name_full_formatted, reply->clientreqinfo.position_cd = prt
     .access_position_cd, reply->clientreqinfo.updt_id = prt.prsnl_id,
     reply->clientreqinfo.physician_ind = p.physician_ind, reply->clientreqinfo.email = p.email,
     reply->reqinfo.position_cd = prt.access_position_cd,
     reply->reqinfo.updt_id = prt.prsnl_id
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    CALL logusernotfound(null)
    GO TO log_app_context
   ENDIF
  ENDIF
  SET process_status = "S"
  GO TO log_app_context
 ENDIF
 SELECT INTO "nl:"
  p.position_cd, p.log_level
  FROM prsnl p,
   code_value cv
  PLAN (p
   WHERE (p.username=request->username))
   JOIN (cv
   WHERE cv.code_value=p.position_cd)
  DETAIL
   IF (((user_active_ind=0) OR (position_active_ind=0)) )
    IF (p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ((p.end_effective_dt_tm=0) OR (p.end_effective_dt_tm > cnvtdatetime(curdate,curtime)))
     AND p.active_ind=1)
     user_active_ind = 1
    ELSE
     user_active_ind = 0
    ENDIF
    IF (cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND ((cv.end_effective_dt_tm=0) OR (cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime)))
     AND cv.active_ind=1)
     position_active_ind = 1
    ELSE
     position_active_ind = 0
    ENDIF
    reply->clientreqinfo.person_name = p.name_full_formatted, reply->clientreqinfo.updt_id = p
    .person_id, reply->clientreqinfo.physician_ind = p.physician_ind,
    reply->clientreqinfo.email = p.email, reply->reqinfo.updt_id = p.person_id, roleprofileposition
     = getclientpositioncode(p.person_id,p.position_cd),
    reply->clientreqinfo.position_cd = roleprofileposition, reply->reqinfo.position_cd =
    roleprofileposition
    IF ((p.log_level > reply->clientreqinfo.log_level))
     reply->clientreqinfo.log_level = p.log_level
    ENDIF
    IF ((request->log_access_ind=0)
     AND p.log_access_ind=1)
     request->log_access_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (user_active_ind=0)
   SET reply->status_data.substatus = 51
   GO TO log_app_context
  ELSE
   IF (position_active_ind=0)
    SET reply->status_data.substatus = 58
    GO TO log_app_context
   ENDIF
  ENDIF
 ELSE
  SET reply->status_data.substatus = 50
  SELECT INTO "nl:"
   p.position_cd
   FROM prsnl p
   DETAIL
    reply->clientreqinfo.person_name = "Person not found on PRSNL Table", reply->clientreqinfo.
    updt_id = p.person_id, reply->clientreqinfo.physician_ind = p.physician_ind,
    reply->clientreqinfo.email = p.email, reply->reqinfo.updt_id = p.person_id, roleprofileposition
     = getclientpositioncode(p.person_id,p.position_cd),
    reply->clientreqinfo.position_cd = roleprofileposition, reply->reqinfo.position_cd =
    roleprofileposition
   WITH nocounter, maxqual(p,1)
  ;end select
  GO TO log_app_context
 ENDIF
 SET process_status = "S"
#log_app_context
 IF ((request->log_access_ind != 2))
  SELECT INTO "nl:"
   y = seq(cpmapp_applctx,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->reqinfo.updt_applctx = cnvtint(y), reply->clientreqinfo.updt_applctx = cnvtint(y)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO number_error
  ENDIF
  IF (((process_status="F") OR ((request->log_access_ind=1))) )
   EXECUTE crmapp_authorize_context
   IF (process_status="F")
    GO TO select_error
   ENDIF
   SET reply->status_data.substatus = 0
  ENDIF
 ENDIF
 IF ((request->application_ini_ind=1))
  SELECT INTO "nl:"
   a.person_id
   FROM application_ini a
   WHERE (a.application_number=request->application_number)
    AND (a.person_id=reply->reqinfo.updt_id)
   HEAD REPORT
    sectionfound = 0, x = 0
   DETAIL
    prefcnt += 1, stat = alterlist(reply->apppreferences.qual,prefcnt)
    IF (a.person_id=0)
     sectionfound = 0
     FOR (x = 1 TO prefcnt)
       IF (trim(a.section)=trim(reply->apppreferences.qual[x].section))
        x = prefcnt, prefcnt -= 1, sectionfound = 1
       ENDIF
     ENDFOR
     IF (sectionfound=0)
      reply->apppreferences.qual[prefcnt].section = a.section, reply->apppreferences.qual[prefcnt].
      parameter_data = a.parameter_data, reply->apppreferences.qual[prefcnt].person_id = a.person_id
     ENDIF
    ELSE
     reply->apppreferences.qual[prefcnt].section = a.section, reply->apppreferences.qual[prefcnt].
     parameter_data = a.parameter_data, reply->apppreferences.qual[prefcnt].person_id = a.person_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 GO TO exit_script
#select_error
 CALL echo("SELECT ERROR")
 SET stat = alterlist(reply->status_data.subeventstatus,2)
 SET reply->status_data.subeventstatus[2].operationname = "SELECT"
 SET reply->status_data.subeventstatus[2].operationstatus = "F"
 SET reply->status_data.subeventstatus[2].targetobjectname = "TABLE JOIN"
 SET reply->status_data.subeventstatus[2].targetobjectvalue = "none qualified"
 CALL echo("Select error ended - exit script")
 GO TO exit_script
#number_error
 CALL echo("NUMBER ERROR")
 SET stat = alterlist(reply->status_data.subeventstatus,1)
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CONTEXT_ID"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to assign: cpmapp_applctx"
 SET reply->status_data.substatus = 56
 CALL echo("sequence cpm_seq could not be found")
 GO TO exit_script
#exit_script
 IF ((reply->status_data.substatus=0))
  SET reply->status_data.status = "S"
  CALL echo(build("Application Context:  ",reply->clientreqinfo.updt_applctx))
 ELSE
  SET reply->status_data.status = "F"
  SET reply->clientreqinfo.position_cd = 0
  SET reply->reqinfo.position_cd = 0
 ENDIF
 IF ((((reply->clientreqinfo.log_level > 0)) OR ((reply->status_data.status != "S"))) )
  CALL echo(build("Log Level:  ",reply->clientreqinfo.log_level))
  CALL echo(build("Status: ",reply->status_data.status))
  CALL echo(build("Sub Status: ",reply->status_data.substatus))
  CALL echo(concat("preference sections list count: ",cnvtstring(prefcnt)))
  CALL echo(concat("ClientReqInfo->position_cd: ",cnvtstring(reply->clientreqinfo.position_cd)))
  CALL echo(concat("ReqInfo->position_cd: ",cnvtstring(reply->reqinfo.position_cd)))
 ENDIF
 SUBROUTINE logusernotfound(null)
   SET reply->status_data.substatus = 50
   SET process_status = "F"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    ORDER BY p.person_id
    DETAIL
     reply->clientreqinfo.person_name = "Person not found on PRSNL or PRSNL_ORG_RELTN_TYPE Table",
     reply->reqinfo.updt_id = p.person_id
    WITH nocounter, maxqual(p,1)
   ;end select
 END ;Subroutine
 SUBROUTINE (getclientpositioncode(prsnlid=f8,positioncd=f8) =f8)
   DECLARE resultposition = f8 WITH noconstant(0)
   DECLARE hroleprofilehandle = i4 WITH noconstant(0)
   DECLARE roleprofileprsnlid = f8 WITH noconstant(0)
   SET resultposition = positioncd
   SET hroleprofilehandle = uar_sacgetuserroleprofiledetails()
   IF (hroleprofilehandle != 0)
    SET roleprofileprsnlid = uar_srvgetdouble(hroleprofilehandle,nullterm("personnel_id"))
    IF (roleprofileprsnlid=prsnlid)
     SET resultposition = uar_srvgetdouble(hroleprofilehandle,nullterm("position"))
    ENDIF
   ENDIF
   RETURN(resultposition)
 END ;Subroutine
END GO
