CREATE PROGRAM cw_get_enroll_status:dba
 FREE RECORD reply
 RECORD reply(
   1 enrolled_flag = i2
   1 new_connections_cnt = i4
   1 retrieved_status_flag = i2
   1 retrieved_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD data_cache
 RECORD data_cache(
   1 enrolled_flag = i2
   1 new_connections_cnt = i4
   1 retrieved_status_flag = i2
   1 retrieved_dt_tm = dq8
   1 updt_dt_tm = dq8
 )
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
 DECLARE log_xml = vc WITH protect, noconstant(build("cw_get_enroll_status",format(cnvtdatetime(
     sysdate),"yyyymmddhhmmss;;d"),".xml"))
 DECLARE app_num = i4 WITH protect, constant(600005)
 DECLARE task_num = i4 WITH protect, constant(600311)
 DECLARE req_num = i4 WITH protect, constant(600632)
 DECLARE data_refresh_ind = i4 WITH protect, noconstant(request->refresh_ind)
 DECLARE config_cache_expiration_hours = i4 WITH protect, noconstant(0)
 DECLARE cache_expiration_hours = i4 WITH protect, noconstant(24)
 DECLARE retrieved_cache_hours = i4 WITH protect, noconstant(0)
 DECLARE data_cache_empty_ind = i4 WITH protect, noconstant(0)
 DECLARE data_cache_expired_ind = i4 WITH protect, noconstant(0)
 DECLARE data_cache_timeout_ind = i4 WITH protect, noconstant(0)
 DECLARE data_cache_retrieving_minutes = i4 WITH protect, noconstant(0)
 DECLARE organization_id = f8 WITH protect, noconstant(0.0)
 CALL addlogmessage("Begin: CW_GET_ENROLL_STATUS")
 CALL log_message(build2("Begin -> CW_GET_ENROLL_STATUS"),log_level_debug)
 IF ((request->person_id=0.0))
  CALL addlogmessage(build("--request->person_id = 0.0. Exit Script"))
  CALL log_message(build2("request->person_id = 0.0. Exit Script"),log_level_warning)
  GO TO exit_script
 ENDIF
 CALL addlogmessage(build("--cw_get_enroll_status: request->refresh_ind = ",request->refresh_ind))
 CALL log_message(build2("cw_get_enroll_status: request->refresh_ind = ",request->refresh_ind),
  log_level_debug)
 IF (data_refresh_ind=0)
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
  DECLARE getdatacacheinfo = f8 WITH private, noconstant(curtime3)
  SELECT INTO "nl:"
   FROM cw_data_cache cwdc
   WHERE (cwdc.person_id=request->person_id)
    AND cwdc.organization_id=organization_id
    AND cwdc.active_ind=1
   ORDER BY cwdc.updt_dt_tm DESC
   HEAD REPORT
    data_cache->enrolled_flag = cwdc.enrolled_ind, data_cache->new_connections_cnt = cwdc
    .new_connections_cnt, data_cache->retrieved_status_flag = cwdc.retrieved_status_flag,
    data_cache->retrieved_dt_tm = cnvtdatetime(cwdc.retrieved_dt_tm), data_cache->updt_dt_tm =
    cnvtdatetime(cwdc.updt_dt_tm)
   WITH nocounter
  ;end select
  IF (error(error_msg,1) != 0)
   CALL addlogmessage(build("--GetDataCacheInfo table select error: ",error_msg))
   CALL log_message(build2("GetDataCacheInfo table select error -> ",error_msg),log_level_debug)
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((data_cache->retrieved_status_flag=1))
   SET reply->retrieved_status_flag = 1
   CALL addlogmessage("--data_cache->retrieved_status_flag = RETRIEVING")
   CALL log_message(build2("data_cache->retrieved_status_flag = RETRIEVING"),log_level_debug)
   SET data_cache_retrieving_minutes = abs(datetimediff(cnvtdatetime(sysdate),data_cache->updt_dt_tm,
     4))
   CALL addlogmessage(build("--data_cache_retrieving_minutes: ",data_cache_retrieving_minutes))
   CALL log_message(build2("data_cache_retrieving_minutes -> ",data_cache_retrieving_minutes),
    log_level_debug)
   IF (data_cache_retrieving_minutes >= 30)
    SET data_refresh_ind = 1
    CALL addlogmessage("--Refresh data: RETRIEVING status over 30 minutes")
    CALL log_message(build2("Refresh data: RETRIEVING status over 30 minutes"),log_level_debug)
   ELSE
    CALL addlogmessage("--RETRIEVING status -> Exit script")
    CALL log_message(build2("RETRIEVING status -> Exit script"),log_level_debug)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL addlogmessage(build("GetDataCacheInfo: ",build2(cnvtint((curtime3 - getdatacacheinfo))),"0 ms"
    ))
  CALL log_message(build2("GetDataCacheInfo -> ",build2(cnvtint((curtime3 - getdatacacheinfo))),
    "0 ms "),log_level_debug)
  IF (curqual=0)
   SET data_cache_empty_ind = 1
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
    CALL addlogmessage(build("--GetDataCacheInfo table insert error: ",error_msg))
    CALL log_message(build2("GetDataCacheInfo table insert error -> ",error_msg),log_level_error)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   CALL addlogmessage("--GetDataCacheData: Data cache empty")
   CALL log_message(build2("GetDataCacheData: Data cache empty"),log_level_debug)
  ELSE
   IF ((data_cache->retrieved_status_flag=3))
    SET data_cache_timeout_ind = 1
    CALL addlogmessage("--data_cache->retrieved_status_flag = TIMEOUT")
    CALL log_message(build2("data_cache->retrieved_status_flag = TIMEOUT"),log_level_debug)
   ELSE
    DECLARE getdatacacheexpiredind = f8 WITH private, noconstant(curtime3)
    EXECUTE mp_pv_commonwell_enrollment_c "MINE", 0.0, 0.0
    IF (validate(debug_ind,0) > 0)
     CALL echoxml(commonwellenrollmentconfig,log_xml,1)
     CALL echorecord(commonwellenrollmentconfig)
    ENDIF
    SET config_cache_expiration_hours = validate(commonwellenrollmentconfig->cache_expiration,0)
    IF (config_cache_expiration_hours > 0)
     IF (config_cache_expiration_hours > 48)
      SET cache_expiration_hours = 48
     ELSE
      SET cache_expiration_hours = config_cache_expiration_hours
     ENDIF
    ENDIF
    CALL addlogmessage(build("--cache_expiration_hours = ",cache_expiration_hours))
    CALL log_message(build2("cache_expiration_hours -> ",cache_expiration_hours),log_level_debug)
    SET retrieved_cache_hours = abs(datetimediff(cnvtdatetime(sysdate),data_cache->retrieved_dt_tm,3)
     )
    CALL addlogmessage(build("--retrieved_cache_hours = ",retrieved_cache_hours))
    CALL log_message(build2("retrieved_cache_hours -> ",retrieved_cache_hours),log_level_debug)
    IF (retrieved_cache_hours >= cache_expiration_hours)
     SET data_cache_expired_ind = 1
     CALL addlogmessage("--data_cache_expired_ind = 1")
     CALL log_message(build2("data_cache_expired_ind = 1"),log_level_debug)
    ENDIF
    CALL addlogmessage(build("GetDataCacheExpiredInd -> ",build2(cnvtint((curtime3 -
        getdatacacheexpiredind))),"0 ms"))
    CALL log_message(build2("GetDataCacheExpiredInd -> ",build2(cnvtint((curtime3 -
        getdatacacheexpiredind))),"0 ms "),log_level_debug)
    IF (data_cache_expired_ind=0)
     SET reply->enrolled_flag = data_cache->enrolled_flag
     SET reply->new_connections_cnt = data_cache->new_connections_cnt
     SET reply->retrieved_status_flag = data_cache->retrieved_status_flag
     SET reply->retrieved_dt_tm = cnvtdatetime(data_cache->retrieved_dt_tm)
     CALL addlogmessage("--Reply populated from table")
     CALL log_message(build2("Reply populated from table"),log_level_debug)
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (((data_refresh_ind=1) OR (((data_cache_empty_ind=1) OR (((data_cache_expired_ind=1) OR (
 data_cache_timeout_ind=1)) )) )) )
  DECLARE refreshdatacache = f8 WITH private, noconstant(curtime3)
  SET stat = tdbexecute(app_num,task_num,req_num,"REC",request,
   "REC",reply)
  IF (stat=0)
   IF (data_cache_timeout_ind=1)
    SET reply->retrieved_status_flag = 3
    CALL log_message(build2("RefreshDataCache: Data refreshed due to timout:"),log_level_debug)
   ELSE
    SET reply->retrieved_status_flag = 1
    CALL log_message(build2("RefreshDataCache: Data refreshed"),log_level_debug)
   ENDIF
  ELSE
   SET reply->retrieved_status_flag = 4
   CALL log_message(build2("RefreshDataCache: Data refreshed due to tdbexecute 600632 error"),
    log_level_debug)
  ENDIF
  CALL addlogmessage("--RefreshDataCache: Data refreshed")
  CALL log_message(build2("RefreshDataCache: Data refreshed"),log_level_debug)
  CALL addlogmessage(build("RefreshDataCache -> ",build2(cnvtint((curtime3 - refreshdatacache))),
    "0 ms"))
  CALL log_message(build2("RefreshDataCache -> ",build2(cnvtint((curtime3 - refreshdatacache))),
    "0 ms "),log_level_debug)
 ENDIF
 SUBROUTINE (addlogmessage(_msg=vc) =null WITH protect)
   SET rlog->cnt += 1
   SET stat = alterlist(rlog->messages,rlog->cnt)
   SET rlog->messages[rlog->cnt].text = _msg
 END ;Subroutine
#exit_script
 CALL addlogmessage(build("ScriptComplete -> ",build2(cnvtint((curtime3 - scriptcomplete))),"0 ms"))
 CALL log_message(build2("ScriptComplete -> ",build2(cnvtint((curtime3 - scriptcomplete))),"0 ms "),
  log_level_debug)
 IF (validate(debug_ind,0) > 0)
  CALL echoxml(reply,log_xml,1)
  CALL echoxml(rlog,log_xml,1)
  CALL echorecord(reply)
  CALL echorecord(rlog)
  CALL echo(build("Logged XML: ",log_xml))
 ENDIF
END GO
