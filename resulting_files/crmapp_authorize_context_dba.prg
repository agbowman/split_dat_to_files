CREATE PROGRAM crmapp_authorize_context:dba
 DECLARE app_ctx_id = i4
 SET app_ctx_id = 0
 IF ((reply->reqinfo.updt_applctx=0))
  SELECT INTO "nl:"
   y = seq(cpmapp_applctx,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->reqinfo.updt_applctx = cnvtint(y), reply->clientreqinfo.updt_applctx = cnvtint(y)
   WITH format, nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  y = seq(cpmapp_app_ctx_id,nextval)"#################;rp0"
  FROM dual
  DETAIL
   app_ctx_id = cnvtint(y)
  WITH format, nocounter
 ;end select
 CALL echo(build("Application Context -> User:",request->username,",App#:",request->
   application_number,",Ctx#:",
   reply->reqinfo.updt_applctx,",Stat:",reply->status_data.substatus))
 CALL echo(build("app_ctx_id: ",app_ctx_id))
 UPDATE  FROM application_context ac
  SET ac.app_ctx_id = app_ctx_id, ac.applctx = reply->reqinfo.updt_applctx, ac.application_number =
   request->application_number,
   ac.person_id = reply->reqinfo.updt_id, ac.name = trim(substring(1,100,reply->clientreqinfo.
     person_name)), ac.username = trim(substring(1,50,request->username)),
   ac.position_cd = reply->reqinfo.position_cd, ac.client_start_dt_tm = cnvtdatetime(request->
    start_dt_tm), ac.start_dt_tm = cnvtdatetime(sysdate),
   ac.end_dt_tm = null, ac.application_image = trim(substring(1,32,request->application_image)), ac
   .application_dir = trim(substring(1,100,request->application_dir)),
   ac.application_status = reply->status_data.substatus, ac.parms_flag = request->params_flag, ac
   .device_location = trim(substring(1,50,request->device_location)),
   ac.device_address = trim(substring(1,50,request->device_address)), ac.authorization_ind =
   IF ((reply->status_data.substatus=0)) 1
   ELSE 0
   ENDIF
   , ac.application_version = trim(substring(1,40,request->application_version)),
   ac.default_location = trim(substring(1,40,request->default_location)), ac.client_node_name = trim(
    substring(1,100,request->client_node_name)), ac.tcpip_address = trim(substring(1,40,request->
     tcpip_address)),
   ac.logdirectory = trim(substring(1,50,request->logdirectory)), ac.updt_applctx = reply->reqinfo.
   updt_applctx, ac.updt_dt_tm = cnvtdatetime(sysdate),
   ac.updt_id = reply->reqinfo.updt_id, ac.updt_cnt = 0, ac.updt_task = request->application_number,
   ac.client_tz = curtimezoneapp
  WHERE ac.app_ctx_id=app_ctx_id
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL echo("inserting application_context")
  INSERT  FROM application_context ac
   SET ac.app_ctx_id = app_ctx_id, ac.applctx = reply->reqinfo.updt_applctx, ac.application_number =
    request->application_number,
    ac.person_id = reply->reqinfo.updt_id, ac.name = trim(substring(1,100,reply->clientreqinfo.
      person_name)), ac.username = trim(substring(1,50,request->username)),
    ac.position_cd = reply->reqinfo.position_cd, ac.client_start_dt_tm = cnvtdatetime(request->
     start_dt_tm), ac.start_dt_tm = cnvtdatetime(sysdate),
    ac.application_image = trim(substring(1,32,request->application_image)), ac.application_dir =
    trim(substring(1,100,request->application_dir)), ac.application_status = reply->status_data.
    substatus,
    ac.parms_flag = request->params_flag, ac.device_location = trim(substring(1,50,request->
      device_location)), ac.device_address = trim(substring(1,50,request->device_address)),
    ac.authorization_ind =
    IF ((reply->status_data.substatus=0)) 1
    ELSE 0
    ENDIF
    , ac.application_version = trim(substring(1,40,request->application_version)), ac
    .default_location = trim(substring(1,40,request->default_location)),
    ac.client_node_name = trim(substring(1,100,request->client_node_name)), ac.tcpip_address = trim(
     substring(1,40,request->tcpip_address)), ac.logdirectory = trim(substring(1,50,request->
      logdirectory)),
    ac.updt_applctx = reply->reqinfo.updt_applctx, ac.updt_dt_tm = cnvtdatetime(sysdate), ac.updt_id
     = reply->reqinfo.updt_id,
    ac.updt_cnt = 0, ac.updt_task = request->application_number, ac.client_tz = curtimezoneapp
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO context_error
  ENDIF
 ENDIF
 IF (size(request->paramlist,5) > 0
  AND (request->paramlist[1].parameter > " "))
  CALL echo(build("parmlist:",size(request->paramlist,5)))
  DELETE  FROM application_parameter ap
   WHERE ap.app_ctx_id=app_ctx_id
   WITH nocounter
  ;end delete
  INSERT  FROM application_parameter ap,
    (dummyt d  WITH seq = value(size(request->paramlist,5)))
   SET ap.seq = 1, ap.app_ctx_id = app_ctx_id, ap.parameter = request->paramlist[d.seq].parameter,
    ap.value = request->paramlist[d.seq].value, ap.updt_applctx = reply->reqinfo.updt_applctx, ap
    .updt_id = reply->reqinfo.updt_id,
    ap.updt_cnt = 0, ap.updt_task = request->application_number
   PLAN (d)
    JOIN (ap)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO parm_error
  ENDIF
 ENDIF
 GO TO exit_script
#context_error
 CALL echo("CONTEXT ERROR")
 SET stat = alterlist(reply->status_data.subeventstatus,1)
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "APPLICATION_CONTEXT TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert"
 SET reply->status_data.substatus = 55
 CALL echo("application_context table: could not insert")
 GO TO exit_script
#parm_error
 CALL echo("PARAM ERROR")
 SET stat = alterlist(reply->status_data.subeventstatus,1)
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "APPLICATION_PARAMETER TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert"
 SET reply->status_data.substatus = 57
 CALL echo("Application_Parameter table: could not insert")
#exit_script
 COMMIT
END GO
