CREATE PROGRAM cw_upd_data_cache_async:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(commonreply,0)))
  FREE RECORD commonreply
  RECORD commonreply(
    1 enrolled_flag = i2
    1 new_connections = i4
    1 json = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 commonwell_eng_timers
      2 is_enrolled
        3 retrieve_jwt_token = i4
        3 call_find_patient_service = i4
        3 call_get_person_info_service = i4
        3 subroutine_completion_time = i4
      2 get_new_connections
        3 retrieve_jwt_token = i4
        3 call_find_patient_service = i4
        3 call_get_patient_network_links_service = i4
        3 subroutine_completion_time = i4
      2 get_enrollment_and_new_connections
        3 retrieve_jwt_token = i4
        3 call_find_patient_service = i4
        3 call_get_person_info_service = i4
        3 call_get_patient_network_links_service = i4
        3 subroutine_completion_time = i4
  )
 ENDIF
 FREE RECORD rlog
 RECORD rlog(
   1 cnt = i4
   1 messages[*]
     2 text = vc
 )
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE scriptcomplete = f8 WITH private, noconstant(curtime3)
 SET reply->status_data.status = "S"
 DECLARE error_msg = vc WITH protect
 DECLARE log_xml = vc WITH protect, noconstant(build("cw_upd_data_cache_async",format(cnvtdatetime(
     sysdate),"yyyymmddhhmmss;;d"),".xml"))
 DECLARE timeout_str = vc WITH protect, constant("timeout")
 DECLARE timeout_length = i4 WITH protect, constant(7)
 DECLARE action_flag = i2 WITH protect, constant(3)
 DECLARE retrieved_status_flag = i2 WITH protect, noconstant(1)
 DECLARE timeout_pos = i4 WITH protect, noconstant(0)
 DECLARE enrolled_ind = i2 WITH protect, noconstant(0)
 DECLARE new_connections_cnt = i4 WITH protect, noconstant(0)
 DECLARE data_cache_cnt = i4 WITH protect, noconstant(0)
 DECLARE organization_id = f8 WITH protect, noconstant(0.0)
 CALL addlogmessage("Begin: CW_UPD_DATA_CACHE_ASYNC")
 CALL log_message(build2("Begin -> CW_UPD_DATA_CACHE_ASYNC"),log_level_debug)
 IF ((request->person_id=0.0))
  CALL addlogmessage(build("--request->person_id = 0.0. Exit Script"))
  CALL log_message(build2("request->person_id = 0.0. Exit Script"),log_level_warning)
  GO TO exit_script
 ENDIF
 DECLARE getorganizationid = f8 WITH private, noconstant(curtime3)
 SELECT INTO "nl:"
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
   AND e.active_ind=1
  DETAIL
   organization_id = e.organization_id
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET reply->status_data.status = "F"
  CALL addlogmessage(build("--GetOrganizationId table select error: ",error_msg))
  CALL log_message(build2("GetOrganizationId table select error -> ",error_msg),log_level_error)
  GO TO exit_script
 ENDIF
 CALL addlogmessage(build("--Organization ID: ",organization_id))
 CALL log_message(build2("Organization ID -> ",organization_id),log_level_debug)
 CALL addlogmessage(build("GetOrganizationId -> ",build2(cnvtint((curtime3 - getorganizationid))),
   "0 ms"))
 CALL log_message(build2("GetOrganizationId -> ",build2(cnvtint((curtime3 - getorganizationid))),
   "0 ms "),log_level_debug)
 DECLARE addretrievingstatus = f8 WITH private, noconstant(curtime3)
 SELECT INTO "nl:"
  FROM cw_data_cache cwdc
  WHERE (cwdc.person_id=request->person_id)
   AND cwdc.organization_id=organization_id
   AND cwdc.active_ind=1
  WITH nocounter
 ;end select
 SET data_cache_cnt = curqual
 IF (data_cache_cnt > 1)
  CALL addlogmessage(build("--AddRetrievingStatus: table delete due to data_cache_cnt > 1: ",
    data_cache_cnt))
  CALL log_message(build2("AddRetrievingStatus: table delete due to data_cache_cnt > 1: ",
    data_cache_cnt),log_level_debug)
  DELETE  FROM cw_data_cache cwdc
   WHERE (cwdc.person_id=request->person_id)
    AND cwdc.organization_id=organization_id
    AND cwdc.active_ind=1
   WITH nocounter
  ;end delete
  IF (error(error_msg,1) != 0)
   SET reply->status_data.status = "F"
   CALL addlogmessage(build("--AddRetrievingStatus table delete error: ",error_msg))
   CALL log_message(build2("AddRetrievingStatus table delete error -> ",error_msg),log_level_error)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 IF (((data_cache_cnt=0) OR (data_cache_cnt > 1)) )
  INSERT  FROM cw_data_cache cwdc
   SET cwdc.cw_data_cache_id = seq(carenet_seq,nextval), cwdc.person_id = request->person_id, cwdc
    .organization_id = organization_id,
    cwdc.retrieved_status_flag = 1, cwdc.active_ind = 1, cwdc.updt_applctx = reqinfo->updt_applctx,
    cwdc.updt_dt_tm = cnvtdatetime(sysdate), cwdc.updt_cnt = 0, cwdc.updt_id = reqinfo->updt_id,
    cwdc.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (error(error_msg,1) != 0)
   SET reply->status_data.status = "F"
   CALL addlogmessage(build("--AddRetrievingStatus table insert error: ",error_msg))
   CALL log_message(build2("AddRetrievingStatus table insert error -> ",error_msg),log_level_error)
   ROLLBACK
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ELSE
  UPDATE  FROM cw_data_cache cwdc
   SET cwdc.retrieved_status_flag = 1, cwdc.updt_applctx = reqinfo->updt_applctx, cwdc.updt_dt_tm =
    cnvtdatetime(sysdate),
    cwdc.updt_cnt = (cwdc.updt_cnt+ 1), cwdc.updt_id = reqinfo->updt_id, cwdc.updt_task = reqinfo->
    updt_task
   WHERE (cwdc.person_id=request->person_id)
    AND cwdc.organization_id=organization_id
    AND cwdc.active_ind=1
   WITH nocounter
  ;end update
  IF (error(error_msg,1) != 0)
   SET reply->status_data.status = "F"
   CALL addlogmessage(build("--AddRetrievingStatus table update error: ",error_msg))
   CALL log_message(build2("AddRetrievingStatus table update error -> ",error_msg),log_level_error)
   ROLLBACK
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 CALL addlogmessage(build("AddRetrievingStatus: ",build2(cnvtint((curtime3 - addretrievingstatus))),
   "0 ms"))
 CALL log_message(build2("AddRetrievingStatus -> ",build2(cnvtint((curtime3 - addretrievingstatus))),
   "0 ms "),log_level_debug)
 DECLARE mp_pv_get_cw_status = f8 WITH private, noconstant(curtime3)
 EXECUTE mp_pv_get_cw_status "MINE", request->person_id, request->encntr_id,
 action_flag WITH replace(commonwellreply,commonreply)
 CALL addlogmessage(build("MP_PV_GET_CW_STATUS: ",build2(cnvtint((curtime3 - mp_pv_get_cw_status))),
   "0 ms"))
 CALL log_message(build2("MP_PV_GET_CW_STATUS -> ",build2(cnvtint((curtime3 - mp_pv_get_cw_status))),
   "0 ms "),log_level_debug)
 DECLARE setstatusflag = f8 WITH private, noconstant(curtime3)
 SET timeout_pos = findstring(timeout_str,commonreply->status_data.subeventstatus[1].
  targetobjectvalue)
 IF (timeout_pos > 0)
  IF (substring(timeout_pos,timeout_length,commonreply->status_data.subeventstatus[1].
   targetobjectvalue)=timeout_str)
   SET retrieved_status_flag = 3
   CALL addlogmessage("--TIMEOUT: mp_pv_get_cw_status")
   CALL addlogmessage(build2("--commonReply->status_data.status: ",commonreply->status_data.status))
   CALL addlogmessage(build2("--get_enrollment_and_new_connections: retrieve_jwt_token -> ",
     commonreply->commonwell_eng_timers.get_enrollment_and_new_connections.retrieve_jwt_token))
   CALL addlogmessage(build2("--get_enrollment_and_new_connections: call_find_patient_service -> ",
     commonreply->commonwell_eng_timers.get_enrollment_and_new_connections.call_find_patient_service)
    )
   CALL addlogmessage(build2("--get_enrollment_and_new_connections: call_get_person_info_service -> ",
     commonreply->commonwell_eng_timers.get_enrollment_and_new_connections.
     call_get_person_info_service))
   CALL addlogmessage(build2(
     "--get_enrollment_and_new_connections: call_get_patient_network_links_service -> ",commonreply->
     commonwell_eng_timers.get_enrollment_and_new_connections.call_get_patient_network_links_service)
    )
   CALL log_message(build2("TIMEOUT: mp_pv_get_cw_status"),log_level_warning)
   CALL log_message(build2("commonReply->status_data.status: ",commonreply->status_data.status),
    log_level_warning)
   CALL log_message(build2("get_enrollment_and_new_connections:retrieve_jwt_token -> ",commonreply->
     commonwell_eng_timers.get_enrollment_and_new_connections.retrieve_jwt_token),log_level_warning)
   CALL log_message(build2("get_enrollment_and_new_connections:call_find_patient_service -> ",
     commonreply->commonwell_eng_timers.get_enrollment_and_new_connections.call_find_patient_service),
    log_level_warning)
   CALL log_message(build2("get_enrollment_and_new_connections:call_get_person_info_service -> ",
     commonreply->commonwell_eng_timers.get_enrollment_and_new_connections.
     call_get_person_info_service),log_level_warning)
   CALL log_message(build2(
     "get_enrollment_and_new_connections:call_get_patient_network_links_service -> ",commonreply->
     commonwell_eng_timers.get_enrollment_and_new_connections.call_get_patient_network_links_service),
    log_level_warning)
  ENDIF
 ENDIF
 IF (retrieved_status_flag != 3)
  IF ((commonreply->status_data.status="S"))
   SET retrieved_status_flag = 2
   SET enrolled_ind = commonreply->enrolled_flag
   SET new_connections_cnt = commonreply->new_connections
  ELSE
   CALL addlogmessage(build("--SetStatusFlag: commonReply error status: ",commonreply->status_data.
     status))
   CALL log_message(build2("SetStatusFlag: commonReply error status: ",commonreply->status_data.
     status),log_level_warning)
   UPDATE  FROM cw_data_cache cwdc
    SET cwdc.retrieved_status_flag = 4, cwdc.retrieved_dt_tm = cnvtdatetime(sysdate), cwdc
     .updt_applctx = reqinfo->updt_applctx,
     cwdc.updt_dt_tm = cnvtdatetime(sysdate), cwdc.updt_cnt = (cwdc.updt_cnt+ 1), cwdc.updt_id =
     reqinfo->updt_id,
     cwdc.updt_task = reqinfo->updt_task
    WHERE (cwdc.person_id=request->person_id)
     AND cwdc.organization_id=organization_id
     AND cwdc.active_ind=1
    WITH nocounter
   ;end update
   COMMIT
   IF (error(error_msg,1) != 0)
    CALL addlogmessage(build("--SetStatusFlag table update error: ",error_msg))
    CALL log_message(build2("SetStatusFlag table update error -> ",error_msg),log_level_error)
   ELSE
    CALL addlogmessage("--SetStatusFlag table update to ERROR status successful")
    CALL log_message(build2("SetStatusFlag table update to ERROR status successful"),log_level_debug)
   ENDIF
   GO TO exit_script
  ENDIF
 ENDIF
 CALL addlogmessage(build("SetStatusFlag: ",build2(cnvtint((curtime3 - setstatusflag))),"0 ms"))
 CALL log_message(build2("SetStatusFlag -> ",build2(cnvtint((curtime3 - setstatusflag))),"0 ms "),
  log_level_debug)
 DECLARE updatedatacache = f8 WITH private, noconstant(curtime3)
 UPDATE  FROM cw_data_cache cwdc
  SET cwdc.enrolled_ind = enrolled_ind, cwdc.new_connections_cnt = new_connections_cnt, cwdc
   .retrieved_status_flag = retrieved_status_flag,
   cwdc.retrieved_dt_tm = cnvtdatetime(sysdate), cwdc.updt_applctx = reqinfo->updt_applctx, cwdc
   .updt_dt_tm = cnvtdatetime(sysdate),
   cwdc.updt_cnt = (cwdc.updt_cnt+ 1), cwdc.updt_id = reqinfo->updt_id, cwdc.updt_task = reqinfo->
   updt_task
  WHERE (cwdc.person_id=request->person_id)
   AND cwdc.organization_id=organization_id
   AND cwdc.active_ind=1
  WITH nocounter
 ;end update
 COMMIT
 IF (error(error_msg,1) != 0)
  SET reply->status_data.status = "F"
  CALL addlogmessage(build("--UpdateDataCache: table update failed: ",error_msg))
  CALL log_message(build2("UpdateDataCache: tab;e update failed -> ",error_msg),log_level_error)
  UPDATE  FROM cw_data_cache cwdc
   SET cwdc.retrieved_status_flag = 4, cwdc.retrieved_dt_tm = cnvtdatetime(sysdate), cwdc
    .updt_applctx = reqinfo->updt_applctx,
    cwdc.updt_dt_tm = cnvtdatetime(sysdate), cwdc.updt_cnt = (cwdc.updt_cnt+ 1), cwdc.updt_id =
    reqinfo->updt_id,
    cwdc.updt_task = reqinfo->updt_task
   WHERE (cwdc.person_id=request->person_id)
    AND cwdc.organization_id=organization_id
    AND cwdc.active_ind=1
   WITH nocounter
  ;end update
  COMMIT
  IF (error(error_msg,1) != 0)
   CALL addlogmessage(build("--UpdateDataCache: table update to ERROR status failed: ",error_msg))
   CALL log_message(build2("UpdateDataCache: table update to ERROR status failed -> ",error_msg),
    log_level_error)
   GO TO exit_script
  ELSE
   CALL addlogmessage("--UpdateDataCache table update to ERROR status successful")
   CALL log_message(build2("UpdateDataCache table update to ERROR status successful"),log_level_debug
    )
  ENDIF
  GO TO exit_script
 ENDIF
 CALL addlogmessage(build("UpdateDataCache: ",build2(cnvtint((curtime3 - updatedatacache))),"0 ms"))
 CALL log_message(build2("UpdateDataCache -> ",build2(cnvtint((curtime3 - updatedatacache))),"0 ms "),
  log_level_debug)
 SUBROUTINE (addlogmessage(_msg=vc) =null WITH protect)
   SET rlog->cnt += 1
   SET stat = alterlist(rlog->messages,rlog->cnt)
   SET rlog->messages[rlog->cnt].text = _msg
 END ;Subroutine
#exit_script
 CALL addlogmessage(build("ScriptComplete: ",build2(cnvtint((curtime3 - scriptcomplete))),"0 ms"))
 CALL log_message(build2("ScriptComplete -> ",build2(cnvtint((curtime3 - scriptcomplete))),"0 ms "),
  log_level_debug)
 IF (validate(debug_ind,0) > 0)
  CALL echoxml(rlog,log_xml,1)
  CALL echoxml(reply,log_xml,1)
  CALL echorecord(rlog)
  CALL echorecord(reply)
  CALL echo(build("Logged XML: ",log_xml))
 ENDIF
END GO
