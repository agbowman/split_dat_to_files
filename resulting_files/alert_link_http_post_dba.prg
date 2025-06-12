CREATE PROGRAM alert_link_http_post:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Server 1:" = "",
  "Subject:" = "",
  "Message Text: " = "",
  "Priority:  " = "",
  "Server 2:" = ""
  WITH outdev, server_1, subject,
  message_text, priority, server_2
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
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
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
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
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
 SET log_program_name = "ALERT_LINK_HTTP_POST"
 DECLARE sendalert(null) = null WITH protect
 DECLARE executehttpcall(suri=vc,saction=vc) = i4 WITH protect
 DECLARE cleansrvcall(null) = null WITH protect
 DECLARE uar_xml_parsestring(xml=vc,filehandle=i4(ref)) = i4 WITH protect
 DECLARE uar_xml_closefile(filehandle=i4) = null WITH protect
 DECLARE uar_xml_getroot(filehandle=i4,nodehandle=i4(ref)) = i4 WITH protect
 DECLARE uar_xml_getchildcount(nodehandle=i4) = i4 WITH protect
 DECLARE uar_xml_getchildnode(nodehandle=i4,nodeno=i4,childnode=i4(ref)) = i4 WITH protect
 DECLARE uar_xml_getnodename(nodehandle=i4) = vc WITH protect
 DECLARE uar_xml_getnodecontent(nodehandle=i4) = vc WITH protect
 DECLARE uar_xml_getattributevalue(nodehandle=i4,attrname=vc) = vc WITH protect
 DECLARE cpm_http_transaction = i4 WITH constant(2000), protect
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE encntr_id = f8 WITH protect, constant(link_encntrid)
 DECLARE hhttpmsg = i4 WITH protect, noconstant(0)
 DECLARE hhttpreq = i4 WITH protect, noconstant(0)
 DECLARE hhttprep = i4 WITH protect, noconstant(0)
 DECLARE srequest = vc WITH protect, noconstant("")
 DECLARE suri = vc WITH protect, noconstant("")
 DECLARE sresponse = vc WITH protect, noconstant("")
 DECLARE pidencoded = vc WITH protect, noconstant("")
 DECLARE contenttype = vc WITH protect, noconstant("")
 DECLARE start_t = f8 WITH protect, noconstant(0.0)
 DECLARE end_t = f8 WITH protect, noconstant(0.0)
 DECLARE exec_t = f8 WITH protect, noconstant(0.0)
 DECLARE msgdate = vc WITH protect, noconstant("")
 SET msgdate = format(cnvtdatetime(sysdate),"yy:MM:dd:HH:mm:ss;;d")
 FREE RECORD locationcds
 RECORD locationcds(
   1 locations[*]
     2 location_cd = vc
     2 location_disp = vc
 )
 CALL log_message(concat("Begin script ALERT_LINK_HTTP_POST: ",log_program_name),log_level_debug)
 CALL sendalert(null)
 CALL log_message(concat("Exit script ALERT_LINK_HTTP_POST: ",log_program_name),log_level_debug)
 SUBROUTINE sendalert(null)
   CALL log_message("In sendAlert()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE server_1 = vc WITH private, constant(trim( $SERVER_1,3))
   DECLARE server_2 = vc WITH private, constant(trim( $SERVER_2,3))
   DECLARE server1failed = i1 WITH private, noconstant(0)
   DECLARE nhttpstatus = i4 WITH private, noconstant(0)
   CALL log_message(build("Server 1 : ", $SERVER_1),log_level_debug)
   CALL log_message(build("Subject : ", $SUBJECT),log_level_debug)
   CALL log_message(build("Message Text : ", $MESSAGE_TEXT),log_level_debug)
   CALL log_message(build("Priority : ", $PRIORITY),log_level_debug)
   CALL log_message(build("Server 2 : ", $SERVER_2),log_level_debug)
   IF (encntr_id > 0.0)
    SELECT DISTINCT INTO "nl:"
     FROM encntr_loc_hist elh
     WHERE elh.encntr_id=encntr_id
     ORDER BY elh.beg_effective_dt_tm DESC
     HEAD REPORT
      cnt_loc = 0
     DETAIL
      cnt_loc += 1, stat = alterlist(locationcds->locations,cnt_loc), locationcds->locations[cnt_loc]
      .location_cd = cnvtstring(elh.location_cd,25,1),
      locationcds->locations[cnt_loc].location_disp = uar_get_code_display(elh.location_cd)
     WITH nocounter, maxrec = 2
    ;end select
   ELSE
    CALL log_message("exiting sendAlert:ALERT_LINK_HTTP_POST, encounter id is 0",log_level_debug)
    GO TO end_main
   ENDIF
   IF (size(locationcds->locations,5)=0)
    CALL log_message(build(
      "exiting sendAlert:ALERT_LINK_HTTP_POST since there is no location found for encounter id => ",
      encntr_id),log_level_debug)
    GO TO end_main
   ENDIF
   FOR (i = 1 TO size(locationcds->locations,5))
     CALL log_message(build("Location CD : ",locationcds->locations[i].location_cd),log_level_debug)
     CALL log_message(build("Location Disp : ",locationcds->locations[i].location_disp),
      log_level_debug)
     CALL log_message(build("Current Dt Tm : ",msgdate),log_level_debug)
     SET srequest = concat("xmlmessage=", $MESSAGE_TEXT)
     SET srequest = replace(srequest,"@SUBJECT", $SUBJECT)
     SET srequest = replace(srequest,"@PRIORITY", $PRIORITY)
     SET srequest = replace(srequest,"@LOCATIONCD",locationcds->locations[i].location_cd)
     SET srequest = replace(srequest,"@LOCATIONDISP",locationcds->locations[i].location_disp)
     SET srequest = replace(srequest,"@CURRDATETIME",msgdate)
     CALL log_message(build("sRequest: ",srequest),log_level_debug)
     SET start_t = curtime3
     IF (server1failed=0)
      SET nhttpstatus = executehttpcall(server_1)
      SET end_t = curtime3
      SET exec_t = ((end_t - start_t)/ 100.0)
      SET log_message = build("----- AlertLink message Subj:  <", $SUBJECT,
       "> sent with HTTP Status Code = ",nhttpstatus," (",
       trim(format(exec_t,"###.##"))," s) -----")
      CALL log_message(build("log_message: ",log_message),log_level_debug)
      IF (nhttpstatus=200)
       SET sresponse = gethttpresponsebody(hhttprep)
       IF (textlen(sresponse) > 0)
        CALL log_message(build("sResponse for Server_1 : ",sresponse),log_level_debug)
       ELSE
        CALL log_message("Empty body returned from service.",log_level_debug)
       ENDIF
       SET retval = 100
      ELSE
       CALL log_message("HTTP call failed on Server_1.",log_level_debug)
       SET server1failed = 1
      ENDIF
     ENDIF
     IF (server1failed=1
      AND size(server_2,1) > 1)
      CALL log_message("Calling Server_2.....",log_level_debug)
      CALL cleansrvcall(null)
      SET start_t = curtime3
      SET nhttpstatus = executehttpcall(server_2)
      SET end_t = curtime3
      SET exec_t = ((end_t - start_t)/ 100.0)
      SET log_message = build("----- AlertLink message Subj:  <", $SUBJECT,
       "> send to server 2 with HTTP Status Code = ",nhttpstatus," (",
       trim(format(exec_t,"###.##"))," s) -----")
      CALL log_message(build("log_message: ",log_message),log_level_debug)
      IF (nhttpstatus=200)
       SET sresponse = gethttpresponsebody(hhttprep)
       IF (textlen(sresponse) > 0)
        CALL log_message(build("sResponse for Server_2 : ",sresponse),log_level_debug)
       ELSE
        CALL log_message("Empty body returned from service.",log_level_debug)
       ENDIF
       SET retval = 100
      ELSE
       CALL log_message("HTTP call failed on Server_2.",log_level_debug)
      ENDIF
     ENDIF
     CALL cleansrvcall(null)
   ENDFOR
   CALL log_message(build("exit sendAlert(), elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE executehttpcall(suri)
   CALL log_message("In executeHttpCall()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE nstatus = i4 WITH private, noconstant(0)
   CALL log_message(build("CPM_HTTP_TRANSACTION: ",cpm_http_transaction),log_level_debug)
   SET hhttpmsg = uar_srvselectmessage(cpm_http_transaction)
   SET hhttpreq = uar_srvcreaterequest(hhttpmsg)
   SET hhttprep = uar_srvcreatereply(hhttpmsg)
   CALL log_message(build("Msg = ",hhttpmsg,"   Req = ",hhttpreq,"   Rep = ",
     hhttprep),log_level_debug)
   CALL log_message(build("sURI = ",suri),log_level_debug)
   SET stat = uar_srvsetstringfixed(hhttpreq,"uri",suri,size(suri,1))
   SET stat = uar_srvsetstring(hhttpreq,"method","post")
   SET stat = uar_srvsetasis(hhttpreq,"request_buffer",srequest,size(srequest,1))
   SET stat = uar_srvexecute(hhttpmsg,hhttpreq,hhttprep)
   SET nstatus = uar_srvgetlong(hhttprep,"http_status_code")
   CALL cleansrvcall(null)
   RETURN(nstatus)
   CALL log_message(build("exit executeHttpCall(), elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (gethttpresponsebody(hhttpresponsehandle=i4) =vc WITH protect)
   CALL log_message("In getHttpResponseBody()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE nresponsesize = i4 WITH private, noconstant(0)
   SET nresponsesize = uar_srvgetasissize(hhttpresponsehandle,"response_buffer")
   IF (nresponsesize > 0)
    RETURN(substring(1,nresponsesize,uar_srvgetasisptr(hhttprep,"response_buffer")))
   ELSE
    RETURN("")
   ENDIF
   CALL log_message(build("exit getHttpResponseBody(), elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE cleansrvcall(null)
   CALL log_message("In getHttpResponseBody()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SET stat = uar_srvdestroyinstance(hhttpreq)
   SET hhttpreq = 0
   SET stat = uar_srvdestroyinstance(hhttprep)
   SET hhttprep = 0
   SET stat = uar_srvdestroymessage(hhttpmsg)
   SET hhttpmsg = 0
   CALL log_message(build("exit getHttpResponseBody(), elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#end_main
 IF (validate(debug_ind,0)=1)
  CALL echorecord(locationcds)
 ELSE
  FREE RECORD locationcds
 ENDIF
 CALL log_message(concat("exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
