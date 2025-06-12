CREATE PROGRAM afc_sync_cdm:dba
 DECLARE afc_sync_cdm = vc WITH constant("CHARGSRV-14226.006")
 CALL echo("Begin PFT_WEB_SERVICE_SUBS.INC, version [CHARGSRV-12940.003]")
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF ( NOT (validate(createbasicauthstring)))
  SUBROUTINE (createbasicauthstring(pusername=vc,ppassword=vc,prbasicauthstring=vc(ref)) =i2)
    CALL logmessage("createBasicAuthString","Entering...",log_debug)
    IF (pusername="")
     CALL logmessage("createBasicAuthString","User name must not be blank",log_error)
     RETURN(false)
    ENDIF
    IF (ppassword="")
     CALL logmessage("createBasicAuthString","password must not be blank",log_error)
     RETURN(false)
    ENDIF
    SET prbasicauthstring = concat("Basic ",base64encode(concat(pusername,":",ppassword)))
    CALL logmessage("createBasicAuthString","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(initializerequest)))
  SUBROUTINE (initializerequest(purl=vc,phttpmethod=vc,pmediatype=vc,prrequesthandle=i4(ref),
   prheadershandle=i4(ref),prcustomheadershandle=i4(ref)) =i2)
    CALL logmessage("initializeRequest","Entering...",log_debug)
    DECLARE huri = i4 WITH protect, noconstant(0)
    SET huri = uar_srv_geturiparts(nullterm(trim(purl)))
    IF (huri=0)
     CALL logmessage("initializeRequest",concat("Failed to parse URL: ",purl),log_error)
     RETURN(false)
    ENDIF
    SET prrequesthandle = uar_srv_createwebrequest(huri)
    IF (prrequesthandle=0)
     CALL logmessage("initializeRequest","Failed to create request",log_error)
     RETURN(false)
    ENDIF
    SET prheadershandle = uar_srv_createproplist()
    IF (prheadershandle=0)
     CALL logmessage("initializeRequest","Failed to create request headers",log_error)
     RETURN(false)
    ENDIF
    SET prcustomheadershandle = uar_srv_createproplist()
    IF (prcustomheadershandle=0)
     CALL logmessage("initializeRequest","Failed to create request custom headers",log_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_setpropstring(prheadershandle,"method",nullterm(trim(phttpmethod)))
    SET stat = uar_srv_setpropstring(prheadershandle,"accept",nullterm(trim(pmediatype)))
    SET stat = uar_srv_closehandle(huri)
    CALL logmessage("initializeRequest","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(executehttprequest)))
  SUBROUTINE (executehttprequest(prequesthandle=i4,pheadershandle=i4,pcustomheadershandle=i4,
   prstatuscode=i4(ref),prresponsebody=vc(ref)) =i2)
    CALL logmessage("executeHttpRequest","Entering...",log_debug)
    DECLARE hresponse = i4 WITH protect, noconstant(0)
    DECLARE hresponsebuffer = i4 WITH protect, noconstant(0)
    DECLARE responsebody = vc WITH protect
    DECLARE size = i4 WITH protect, noconstant(0)
    DECLARE pos = i4 WITH protect, noconstant(0)
    DECLARE actual = i4 WITH protect, noconstant(0)
    SET hresponsebuffer = uar_srv_creatememorybuffer(3,0,0,0,0,
     0)
    SET stat = uar_srv_setprophandle(pheadershandle,"customHeaders",pcustomheadershandle,1)
    SET stat = uar_srv_setwebrequestprops(prequesthandle,pheadershandle)
    SET hresponse = uar_srv_getwebresponse(prequesthandle,hresponsebuffer)
    IF (hresponse=0)
     CALL logmessage("executeHttpRequest","Failed to execute HTTP request",log_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_getmemorybuffersize(hresponsebuffer,size)
    IF (stat=0)
     CALL logmessage("executeHttpRequest","Failed to get buffer size for response body",log_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_setbufferpos(hresponsebuffer,0,0,pos)
    IF (stat=0)
     CALL logmessage("executeHttpRequest","Failed to set buffer position for response body",log_error
      )
     RETURN(false)
    ENDIF
    SET stat = memrealloc(responsebody,1,build("C",size))
    SET stat = uar_srv_readbuffer(hresponsebuffer,responsebody,size,actual)
    SET prresponsebody = trim(responsebody)
    IF (stat=0)
     CALL logmessage("executeHttpRequest","Failed to read buffer for response body",log_error)
     RETURN(false)
    ENDIF
    IF ( NOT (getstatuscode(hresponse,prstatuscode)))
     CALL logmessage("executeHttpRequest","Failed to retrieve status code",log_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_closehandle(hresponse)
    SET stat = uar_srv_closehandle(hresponsebuffer)
    CALL logmessage("executeHttpRequest","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getstatuscode)))
  SUBROUTINE (getstatuscode(presponsehandle=i4,prstatuscode=i4(ref)) =i2)
    CALL logmessage("getStatusCode","Entering...",log_debug)
    DECLARE hproperties = i4 WITH protect, noconstant(0)
    IF (presponsehandle=0)
     CALL logmessage("getStatusCode","Invalid handle",log_error)
     RETURN(false)
    ENDIF
    SET hproperties = uar_srv_getwebresponseprops(presponsehandle)
    IF (hproperties=0)
     CALL logmessage("getStatusCode","Failed to obtain handle to response properties",log_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_getpropint(hproperties,"statusCode",prstatuscode)
    IF (stat=0)
     CALL logmessage("getStatusCode","Failed to retrieve http status code",log_error)
     RETURN(false)
    ENDIF
    SET stat = uar_srv_closehandle(hproperties)
    CALL logmessage("getStatusCode","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(base64encode)))
  SUBROUTINE (base64encode(inputstring=vc) =vc)
    DECLARE s1 = vc WITH protect
    DECLARE encode = vc WITH protect
    DECLARE x = i4 WITH protect
    DECLARE y = i4 WITH protect
    DECLARE s1_len = i4 WITH protect
    DECLARE s1_size = i4 WITH protect
    DECLARE my64 = vc WITH protect
    SET my64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    SET s1 = inputstring
    SET s1_len = mod(size(trim(s1,3)),3)
    SET s1_size = size(trim(s1,3))
    SET s1_len = evaluate(s1_len,0,0,(3 - s1_len))
    SET s1 = concat(s1,fillstring(value(s1_len),""))
    FOR (x = 1 TO size(trim(s1,3)) BY 3)
     IF (((x+ 2) > s1_size))
      SET s1_len = mod(s1_size,3)
     ELSE
      SET s1_len = 3
     ENDIF
     FOR (y = 1 TO 4)
       CASE (y)
        OF 1:
         SET encode = concat(encode,substring(((ichar(substring(x,1,s1))/ 4)+ 1),1,my64))
        OF 2:
         SET encode = concat(encode,substring((bor((band(ichar(substring(x,1,s1)),3) * 16),(band(
             ichar(substring((x+ 1),1,s1)),240)/ 16))+ 1),1,my64))
        OF 3:
         IF (s1_len > 1)
          SET encode = concat(encode,substring((bor((band(ichar(substring((x+ 1),1,s1)),15) * 4),(
             band(ichar(substring((x+ 2),1,s1)),192)/ 64))+ 1),1,my64))
         ELSE
          SET encode = concat(encode,"=")
         ENDIF
        ELSE
         IF (s1_len > 2)
          SET encode = concat(encode,substring((band(ichar(substring((x+ 2),1,s1)),63)+ 1),1,my64))
         ELSE
          SET encode = concat(encode,"=")
         ENDIF
       ENDCASE
     ENDFOR
    ENDFOR
    RETURN(encode)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(getwebserviceurl)))
  SUBROUTINE (getwebserviceurl(servicecd=f8,servicepath=vc,prserviceurl=vc(ref),prfailreason=vc(ref)
   ) =i2)
    DECLARE rooturl = vc WITH protect, noconstant("")
    DECLARE rooturlendsslash = i4 WITH protect, noconstant(0)
    DECLARE rooturllen = i4 WITH protect, noconstant(0)
    DECLARE servicepathbeginsslash = i4 WITH protect, noconstant(0)
    DECLARE servicepathlen = i4 WITH protect, noconstant(0)
    DECLARE vservicepath = vc WITH protect, noconstant("")
    SELECT INTO "nl:"
     FROM code_value_extension cve
     PLAN (cve
      WHERE cve.code_value=servicecd
       AND cve.field_name="URL")
     DETAIL
      rooturl = trim(cve.field_value,3)
     WITH nocounter
    ;end select
    SET rooturllen = size(trim(rooturl,3),1)
    IF (rooturllen=0)
     SET prfailreason = build2("No URL configured for serviceCd=",servicecd)
     CALL logmessage(cursub,prfailreason,log_error)
     RETURN(false)
    ENDIF
    SET rooturlendsslash = findstring("/",rooturl,rooturllen,1)
    SET vservicepath = trim(servicepath,3)
    SET servicepathlen = size(trim(vservicepath,3),1)
    SET servicepathbeginsslash = findstring("/",vservicepath,1,0)
    IF (rooturlendsslash=0)
     IF (servicepathbeginsslash=0)
      SET prserviceurl = concat(rooturl,"/",vservicepath)
     ELSE
      SET prserviceurl = concat(rooturl,vservicepath)
     ENDIF
    ELSE
     IF (servicepathbeginsslash=0)
      SET prserviceurl = concat(rooturl,vservicepath)
     ELSE
      SET prserviceurl = concat(rooturl,substring(2,(servicepathlen - 1),vservicepath))
     ENDIF
    ENDIF
    IF (validate(debug,0) > 0)
     CALL echo(prserviceurl)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(createoauthstring)))
  SUBROUTINE (createoauthstring(proauthstring=vc(ref),prfailreason=vc(ref)) =i2)
    DECLARE oauthmsg = i4 WITH protect, noconstant(0)
    DECLARE oauthreq = i4 WITH protect, noconstant(0)
    DECLARE oauthrep = i4 WITH protect, noconstant(0)
    DECLARE oauthstatus = i4 WITH protect, noconstant(0)
    DECLARE oauthaccesstoken = i4 WITH protect, noconstant(0)
    DECLARE successind = i4 WITH noconstant(false)
    DECLARE oauthtoken = vc WITH protect, noconstant("")
    DECLARE oauthtokensecret = vc WITH protect, noconstant("")
    DECLARE oauthconsumerkey = vc WITH protect, noconstant("")
    DECLARE oauthaccessorsecret = vc WITH protect, noconstant("")
    DECLARE oauthheader = vc WITH protect, noconstant("")
    DECLARE req99999131 = i4 WITH protect, constant(99999131)
    DECLARE timestamp = f8 WITH protect, noconstant(0.0)
    DECLARE stat = i4 WITH protect, noconstant(0)
    SET oauthmsg = uar_srvselectmessage(req99999131)
    IF (oauthmsg=0)
     SET prfailreason = "Failed to generate oAuth"
     CALL logmessage(cursub,prfailreason,log_error)
     RETURN(false)
    ENDIF
    SET oauthreq = uar_srvcreaterequest(oauthmsg)
    SET oauthrep = uar_srvcreatereply(oauthmsg)
    SET stat = uar_srvexecute(oauthmsg,oauthreq,oauthrep)
    SET oauthstatus = uar_srvgetstruct(oauthrep,"status")
    SET successind = uar_srvgetshort(oauthstatus,"success_ind")
    IF (((stat != 0) OR (successind=false)) )
     SET prfailreason = "Token generation failed"
     CALL logmessage(cursub,prfailreason,log_error)
     RETURN(false)
    ENDIF
    SET oauthaccesstoken = uar_srvgetstruct(oauthrep,"oauth_access_token")
    IF (oauthaccesstoken=0.0)
     SET prfailreason = "Error retrieving handle for oauth_access_token of the srv struct"
     CALL logmessage(cursub,prfailreason,log_error)
     RETURN(false)
    ENDIF
    SET oauthtoken = uar_srvgetstringptr(oauthaccesstoken,"oauth_token")
    SET oauthtokensecret = uar_srvgetstringptr(oauthaccesstoken,"oauth_token_secret")
    SET oauthconsumerkey = uar_srvgetstringptr(oauthaccesstoken,"oauth_consumer_key")
    SET oauthaccessorsecret = uar_srvgetstringptr(oauthaccesstoken,"oauth_accessor_secret")
    IF (validate(debug,0) > 0)
     CALL echo(build2("oAuthToken:",oauthtoken))
     CALL echo(build2("oAuthToken:",uar_srvgetstringptr(oauthaccesstoken,"identity_token")))
     CALL echo(build2("oAuthTokenSecret:",oauthtokensecret))
     CALL echo(build2("oAuthConsumerKey:",oauthconsumerkey))
     CALL echo(build2("oAuthAccessorSecret:",oauthaccessorsecret))
    ENDIF
    SET oauthheader = concat('oauth oauth_token = "',oauthtoken,'"')
    SET oauthheader = concat(oauthheader,',oauth_consumer_key = "',oauthconsumerkey,'"')
    SET oauthheader = concat(oauthheader,',oauth_signature_method = "PLAINTEXT"')
    SET timestamp = datetimediff(cnvtdatetime(sysdate),cnvtdatetime("01-jan-1970 00:00:00"),5)
    SET oauthheader = concat(oauthheader,',oauth_timestamp = "',trim(cnvtstring(timestamp,3),5),'"')
    SET oauthheader = concat(oauthheader,',oauth_nonce = ""')
    SET oauthheader = concat(oauthheader,',oauth_version = "1.0"')
    SET oauthheader = concat(oauthheader,',oauth_signature = "',oauthaccessorsecret,"%26",
     oauthtokensecret,
     '"')
    IF (validate(debug,0) > 0)
     CALL echo(build2("oAuthHeader=",oauthheader))
    ENDIF
    SET proauthstring = oauthheader
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(go_to_exit_script)))
  DECLARE go_to_exit_script = i2 WITH constant(1)
 ENDIF
 IF ( NOT (validate(dont_go_to_exit_script)))
  DECLARE dont_go_to_exit_script = i2 WITH constant(0)
 ENDIF
 IF (validate(beginservice,char(128))=char(128))
  SUBROUTINE (beginservice(pversion=vc) =null)
   CALL logmessage("",concat("version:",pversion," :Begin Service"),log_debug)
   CALL setreplystatus("F","Begin Service")
  END ;Subroutine
 ENDIF
 IF (validate(exitservicesuccess,char(128))=char(128))
  SUBROUTINE (exitservicesuccess(pmessage=vc) =null)
    DECLARE errmsg = vc WITH noconstant(" ")
    DECLARE errcode = i2 WITH noconstant(1)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 080311))
     IF (curdomain IN ("SURROUND", "SOLUTION"))
      SET errmsg = fillstring(132," ")
      SET errcode = error(errmsg,1)
      IF (errcode != 0)
       CALL exitservicefailure(errmsg,true)
      ELSE
       CALL logmessage("","Exit Service - SUCCESS",log_debug)
       CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
       SET reqinfo->commit_ind = true
      ENDIF
     ELSE
      CALL logmessage("","Exit Service - SUCCESS",log_debug)
      CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
      SET reqinfo->commit_ind = true
     ENDIF
    ELSE
     CALL logmessage("","Exit Service - SUCCESS",log_debug)
     CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
     SET reqinfo->commit_ind = true
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicefailure,char(128))=char(128))
  SUBROUTINE (exitservicefailure(pmessage=vc,exitscriptind=i2) =null)
    CALL addtracemessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    CALL logmessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage),log_error)
    IF (validate(reply->failure_stack.failures))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = reply->failure_stack.failures[1].
     programname
     SET reply->status_data.subeventstatus[1].targetobjectname = reply->failure_stack.failures[1].
     routinename
     SET reply->status_data.subeventstatus[1].targetobjectvalue = reply->failure_stack.failures[1].
     message
    ELSE
     CALL setreplystatus("F",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    ENDIF
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicenodata,char(128))=char(128))
  SUBROUTINE (exitservicenodata(pmessage=vc,exitscriptind=i2) =null)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    CALL logmessage("","Exit Service - NO DATA",log_debug)
    CALL setreplystatus("Z",evaluate(pmessage,"","Exit Service - NO DATA",pmessage))
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplystatus,char(128))=char(128))
  SUBROUTINE (setreplystatus(pstatus=vc,pmessage=vc) =null)
    IF (validate(reply->status_data))
     SET reply->status_data.status = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(curprog)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addtracemessage,char(128))=char(128))
  SUBROUTINE (addtracemessage(proutinename=vc,pmessage=vc) =null)
   CALL logmessage(proutinename,pmessage,log_debug)
   IF (validate(reply->failure_stack))
    DECLARE failcnt = i4 WITH protect, noconstant((size(reply->failure_stack.failures,5)+ 1))
    SET stat = alterlist(reply->failure_stack.failures,failcnt)
    SET reply->failure_stack.failures[failcnt].programname = nullterm(curprog)
    SET reply->failure_stack.failures[failcnt].routinename = nullterm(proutinename)
    SET reply->failure_stack.failures[failcnt].message = nullterm(pmessage)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetail,char(128))=char(128))
  SUBROUTINE (addstatusdetail(pentityid=f8,pdetailflag=i4,pdetailmessage=vc) =null)
    IF (validate(reply->status_detail))
     DECLARE detailcnt = i4 WITH protect, noconstant((size(reply->status_detail.details,5)+ 1))
     SET stat = alterlist(reply->status_detail.details,detailcnt)
     SET reply->status_detail.details[detailcnt].entityid = pentityid
     SET reply->status_detail.details[detailcnt].detailflag = pdetailflag
     SET reply->status_detail.details[detailcnt].detailmessage = nullterm(pdetailmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copystatusdetails,char(128))=char(128))
  SUBROUTINE (copystatusdetails(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->status_detail)
     AND validate(prtorecord->status_detail))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->status_detail.details,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->status_detail.details,5))
     DECLARE fromparamidx = i4 WITH protect, noconstant(0)
     DECLARE toparamcnt = i4 WITH protect, noconstant(0)
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->status_detail.details,toidx)
       SET prtorecord->status_detail.details[toidx].entityid = pfromrecord->status_detail.details[
       fromidx].entityid
       SET prtorecord->status_detail.details[toidx].detailflag = pfromrecord->status_detail.details[
       fromidx].detailflag
       SET prtorecord->status_detail.details[toidx].detailmessage = pfromrecord->status_detail.
       details[fromidx].detailmessage
       SET toparamcnt = 0
       FOR (fromparamidx = 1 TO size(pfromrecord->status_detail.details[fromidx].parameters,5))
         SET toparamcnt += 1
         SET stat = alterlist(prtorecord->status_detail.details[toidx].parameters,toparamcnt)
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramname = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramname
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramvalue = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramvalue
       ENDFOR
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetailparam,char(128))=char(128))
  SUBROUTINE (addstatusdetailparam(pdetailidx=i4,pparamname=vc,pparamvalue=vc) =null)
    IF (validate(reply->status_detail))
     IF (validate(reply->status_detail.details[pdetailidx].parameters))
      DECLARE paramcnt = i4 WITH protect, noconstant((size(reply->status_detail.details[pdetailidx].
        parameters,5)+ 1))
      SET stat = alterlist(reply->status_detail.details[pdetailidx].parameters,paramcnt)
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramname = pparamname
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramvalue = pparamvalue
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copytracemessages,char(128))=char(128))
  SUBROUTINE (copytracemessages(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->failure_stack)
     AND validate(prtorecord->failure_stack))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->failure_stack.failures,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->failure_stack.failures,5))
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->failure_stack.failures,toidx)
       SET prtorecord->failure_stack.failures[toidx].programname = pfromrecord->failure_stack.
       failures[fromidx].programname
       SET prtorecord->failure_stack.failures[toidx].routinename = pfromrecord->failure_stack.
       failures[fromidx].routinename
       SET prtorecord->failure_stack.failures[toidx].message = pfromrecord->failure_stack.failures[
       fromidx].message
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 CALL echo("Begin PFT_LOGICAL_DOMAIN_SUBS.INC, version [714452.014 w/o 002,005,007,008,009,010]")
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 IF ( NOT (validate(profitlogicaldomaininfo)))
  RECORD profitlogicaldomaininfo(
    1 hasbeenset = i2
    1 logicaldomainid = f8
    1 logicaldomainsystemuserid = f8
  ) WITH persistscript
 ENDIF
 IF ( NOT (validate(ld_concept_batch_trans)))
  DECLARE ld_concept_batch_trans = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_event)))
  DECLARE ld_concept_pft_event = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_ruleset)))
  DECLARE ld_concept_pft_ruleset = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_queue_item_wf_hist)))
  DECLARE ld_concept_pft_queue_item_wf_hist = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_workflow)))
  DECLARE ld_concept_pft_workflow = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_entity_account)))
  DECLARE ld_entity_account = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(ld_entity_adjustment)))
  DECLARE ld_entity_adjustment = vc WITH protect, constant("ADJUSTMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_balance)))
  DECLARE ld_entity_balance = vc WITH protect, constant("BALANCE")
 ENDIF
 IF ( NOT (validate(ld_entity_charge)))
  DECLARE ld_entity_charge = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(ld_entity_claim)))
  DECLARE ld_entity_claim = vc WITH protect, constant("CLAIM")
 ENDIF
 IF ( NOT (validate(ld_entity_encounter)))
  DECLARE ld_entity_encounter = vc WITH protect, constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(ld_entity_invoice)))
  DECLARE ld_entity_invoice = vc WITH protect, constant("INVOICE")
 ENDIF
 IF ( NOT (validate(ld_entity_payment)))
  DECLARE ld_entity_payment = vc WITH protect, constant("PAYMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_person)))
  DECLARE ld_entity_person = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(ld_entity_pftencntr)))
  DECLARE ld_entity_pftencntr = vc WITH protect, constant("PFTENCNTR")
 ENDIF
 IF ( NOT (validate(ld_entity_statement)))
  DECLARE ld_entity_statement = vc WITH protect, constant("STATEMENT")
 ENDIF
 IF ( NOT (validate(getlogicaldomain)))
  SUBROUTINE (getlogicaldomain(concept=i4,logicaldomainid=f8(ref)) =i2)
    CALL logmessage("getLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     IF (((concept < ld_concept_minvalue) OR (concept > ld_concept_maxvalue)) )
      CALL logmessage("getLogicalDomain",build2("Invalid logical domain concept: ",concept),log_error
       )
      RETURN(false)
     ENDIF
     FREE RECORD acm_get_curr_logical_domain_req
     RECORD acm_get_curr_logical_domain_req(
       1 concept = i4
     )
     FREE RECORD acm_get_curr_logical_domain_rep
     RECORD acm_get_curr_logical_domain_rep(
       1 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     DECLARE currentuserid = f8 WITH protect, constant(reqinfo->updt_id)
     IF ((profitlogicaldomaininfo->hasbeenset=true))
      SET reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
     ENDIF
     SET acm_get_curr_logical_domain_req->concept = concept
     EXECUTE acm_get_curr_logical_domain
     SET reqinfo->updt_id = currentuserid
     IF ((acm_get_curr_logical_domain_rep->status_block.status_ind != true))
      CALL logmessage("getLogicalDomain","Failed to retrieve logical domain...",log_error)
      CALL echorecord(acm_get_curr_logical_domain_rep)
      RETURN(false)
     ENDIF
     SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
     CALL logmessage("getLogicalDomain",build2("Logical domain for concept [",trim(cnvtstring(concept
         )),"]: ",trim(cnvtstring(logicaldomainid))),log_debug)
     FREE RECORD acm_get_curr_logical_domain_req
     FREE RECORD acm_get_curr_logical_domain_rep
    ELSE
     SET logicaldomainid = 0.0
    ENDIF
    CALL logmessage("getLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getlogicaldomainforentitytype(pentityname=vc,prlogicaldomainid=f8(ref)) =i2)
   DECLARE entityconcept = i4 WITH protect, noconstant(0)
   CASE (pentityname)
    OF value(ld_entity_person,ld_entity_encounter,ld_entity_pftencntr):
     SET entityconcept = ld_concept_person
    OF value(ld_entity_claim,ld_entity_invoice,ld_entity_statement,ld_entity_adjustment,
    ld_entity_charge,
    ld_entity_payment,ld_entity_account,ld_entity_balance):
     SET entityconcept = ld_concept_organization
   ENDCASE
   RETURN(getlogicaldomain(entityconcept,prlogicaldomainid))
 END ;Subroutine
 IF ( NOT (validate(setlogicaldomain)))
  SUBROUTINE (setlogicaldomain(logicaldomainid=f8) =i2)
    CALL logmessage("setLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     SELECT INTO "nl:"
      FROM logical_domain ld
      WHERE ld.logical_domain_id=logicaldomainid
      DETAIL
       profitlogicaldomaininfo->logicaldomainsystemuserid = ld.system_user_id
      WITH nocounter
     ;end select
     SET profitlogicaldomaininfo->logicaldomainid = logicaldomainid
     SET profitlogicaldomaininfo->hasbeenset = true
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE (p.person_id=reqinfo->updt_id)
      DETAIL
       IF (p.logical_domain_id != logicaldomainid)
        reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
       ENDIF
      WITH nocounter
     ;end select
     IF (validate(debug,0))
      CALL echorecord(profitlogicaldomaininfo)
      CALL echo(build("reqinfo->updt_id:",reqinfo->updt_id))
     ENDIF
    ENDIF
    CALL logmessage("setLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(arelogicaldomainsinuse)))
  DECLARE arelogicaldomainsinuse(null) = i2
  SUBROUTINE arelogicaldomainsinuse(null)
    CALL logmessage("areLogicalDomainsInUse","Entering...",log_debug)
    DECLARE multiplelogicaldomainsdefined = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id > 0.0
      AND ld.active_ind=true
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET multiplelogicaldomainsdefined = true
    ENDIF
    CALL logmessage("areLogicalDomainsInUse",build2("Multiple logical domains ",evaluate(
       multiplelogicaldomainsdefined,true,"are","are not")," in use"),log_debug)
    CALL logmessage("areLogicalDomainsInUse","Exiting...",log_debug)
    RETURN(multiplelogicaldomainsdefined)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getparameterentityname(dparmcd=f8) =vc)
   DECLARE parammeaning = vc WITH private, constant(trim(uar_get_code_meaning(dparmcd)))
   DECLARE returnvalue = vc WITH private, noconstant("")
   SET returnvalue = evaluate(parammeaning,"BEID","BILLING_ENTITY","OPTIONALBEID","BILLING_ENTITY",
    "HP ID","HEALTH_PLAN","HP_LIST","HEALTH_PLAN","PRIMARYHP",
    "HEALTH_PLAN","PRIPAYORHPID","HEALTH_PLAN","SECPAYORHPID","HEALTH_PLAN",
    "TERPAYORHPID","HEALTH_PLAN","COLLAGENCY","ORGANIZATION","PAYORORGID",
    "ORGANIZATION","PRECOLAGENCY","ORGANIZATION","PRIPAYORORGI","ORGANIZATION",
    "SECPAYORORGI","ORGANIZATION","TERPAYORORGI","ORGANIZATION","PAYER_LIST",
    "ORGANIZATION","UNKNOWN")
   RETURN(returnvalue)
 END ;Subroutine
 SUBROUTINE (paramsarevalidfordomain(paramstruct=vc(ref),dlogicaldomainid=f8) =i2)
   DECLARE paramidx = i4 WITH private, noconstant(0)
   DECLARE paramentityname = vc WITH private, noconstant("")
   DECLARE paramvalue = f8 WITH protect, noconstant(0.0)
   DECLARE paramerror = i2 WITH protect, noconstant(false)
   FOR (paramidx = 1 TO paramstruct->lparams_qual)
     SET paramentityname = getparameterentityname(paramstruct->aparams[paramidx].dvalue_meaning)
     SET paramvalue = cnvtreal(paramstruct->aparams[paramidx].svalue)
     SET paramerror = true
     IF (paramentityname="BILLING_ENTITY")
      SELECT INTO "nl:"
       FROM billing_entity be,
        organization o
       PLAN (be
        WHERE be.billing_entity_id=paramvalue)
        JOIN (o
        WHERE o.organization_id=be.organization_id
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="HEALTH_PLAN")
      SELECT INTO "nl:"
       FROM health_plan hp
       PLAN (hp
        WHERE hp.health_plan_id=paramvalue
         AND hp.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="ORGANIZATION")
      SELECT INTO "nl:"
       FROM organization o
       PLAN (o
        WHERE o.organization_id=paramvalue
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSE
      SET paramerror = false
     ENDIF
     IF (paramerror)
      RETURN(false)
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 IF ( NOT (validate(getlogicaldomainsystemuser)))
  SUBROUTINE (getlogicaldomainsystemuser(logicaldomainid=f8(ref)) =f8)
    DECLARE systempersonnelid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id=logicaldomainid
     DETAIL
      systempersonnelid = ld.system_user_id
     WITH nocounter
    ;end select
    IF (systempersonnelid <= 0.0)
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE p.active_ind=true
       AND p.logical_domain_id=logicaldomainid
       AND p.username="SYSTEM"
      DETAIL
       systempersonnelid = p.person_id
      WITH nocounter
     ;end select
    ENDIF
    IF (systempersonnelid <= 0.0)
     CALL logmessage("getLogicalDomainSystemUser",
      "Failed to determine the default 'SYSTEM' personnel id",log_error)
     RETURN(0.0)
    ENDIF
    CALL logmessage("getLogicalDomainSystemUser","Exiting",log_debug)
    RETURN(systempersonnelid)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 charge_desc_master_qual = i4
    1 charge_desc_master[*]
      2 cdm_id = vc
      2 cdm_code = vc
      2 description = vc
      2 service_type = i2
      2 status_code = i2
      2 issue = vc
      2 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD servicerequestbody(
   1 cdms[*]
     2 cdm_id = vc
     2 cdm_code = vc
     2 description = vc
     2 service_type = vc
     2 logical_domain_id = f8
 ) WITH protect
 DECLARE jsonservicerequestbody = vc WITH protect, noconstant("")
 DECLARE failreason = vc WITH protect, noconstant("")
 DECLARE oauthheader = vc WITH protect, noconstant("")
 DECLARE issuccess = i2 WITH protect, noconstant(false)
 DECLARE serviceurl = vc WITH protect, noconstant("")
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hheadershandle = i4 WITH protect, noconstant(0)
 DECLARE hcustomheaderhandle = i4 WITH protect, noconstant(0)
 DECLARE hrequestbuffer = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE pmediatype = vc WITH protect, noconstant("application/json")
 DECLARE phttpmethod = vc WITH protect, noconstant("POST")
 DECLARE prjsonresponse = gvc WITH protect, noconstant("")
 DECLARE prhttpstatuscd = i4 WITH protect, noconstant(0)
 DECLARE isasync = i2 WITH protect, noconstant(false)
 DECLARE servicepath = vc WITH protect, noconstant("")
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE userlogicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE lduserid = f8 WITH protect, noconstant(0.0)
 DECLARE destination_name = vc WITH protect, constant(
  "com.cerner.xentp.rcs.{env}.private.serviceCatalog.Point2PointQ")
 DECLARE http_get = vc WITH protect, constant("GET")
 DECLARE statuscode_ok = c3 WITH protect, constant("200")
 DECLARE statuscode_created = c3 WITH protect, constant("201")
 DECLARE statuscode_bad_request = c3 WITH protect, constant("400")
 DECLARE statuscode_service_unavailable = c3 WITH protect, constant("503")
 DECLARE technical_service_type = i2 WITH protect, constant(1)
 DECLARE professional_service_type = i2 WITH protect, constant(2)
 DECLARE invalid_service_request_failure_reason = vc WITH protect, constant(
  "Invalid service request body")
 DECLARE i4status_bad_request = i4 WITH protect, constant(400)
 DECLARE i4status_service_unavailable = i4 WITH protect, constant(503)
 IF ( NOT (validate(cs4002709_rcc_gateway)))
  DECLARE cs4002709_rcc_gateway = f8 WITH protect, constant(getcodevalue(4002709,"RCC_GATEWAY",0))
 ENDIF
 CALL beginservice("CHARGSRV-14226.006")
 IF ( NOT (validaterequest(failreason)))
  IF (validate(debug,- (1)) > 0)
   CALL echo(build2("failReason=",failreason))
  ENDIF
  CALL updatetargetobjectofstatusdatainreply(statuscode_bad_request,failreason)
  CALL exitservicefailure(failreason,true)
 ENDIF
 CALL clonerequesttoreply(null)
 IF (size(servicerequestbody->cdms,5) <= 0)
  SET failreason = invalid_service_request_failure_reason
  CALL populatehttperrortoreply(i4status_bad_request)
  CALL updatetargetobjectofstatusdatainreply(statuscode_bad_request,failreason)
  CALL exitservicefailure(failreason,true)
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
 SET isasync = validate(request->asynctoggle,0)
 SET servicepath = evaluate(isasync,true,"/services/messaging/v1/messages",
  "/services/service-catalog/domain/services/service-catalog")
 IF (validate(debug,- (1)) > 0)
  CALL echo(build("isAsync=",isasync))
  CALL echo(build("CS4002709_RCC_GATEWAY=",cs4002709_rcc_gateway))
 ENDIF
 IF ( NOT (buildservicerequestbody(isasync,jsonservicerequestbody,failreason)))
  IF (validate(debug,- (1)) > 0)
   CALL echo(build2("failReason=",failreason))
  ENDIF
  CALL populatehttperrortoreply(i4status_bad_request)
  CALL updatetargetobjectofstatusdatainreply(statuscode_bad_request,failreason)
  CALL exitservicefailure(failreason,true)
 ENDIF
 IF (validate(debug,0) > 0)
  CALL echo(build2("serviceUrl=",serviceurl))
  IF (trim(cnvtupper(phttpmethod),3) != http_get)
   CALL echo(build2("jsonServiceRequestBody=",jsonservicerequestbody))
  ENDIF
 ENDIF
 IF ( NOT (getwebserviceurl(cs4002709_rcc_gateway,servicepath,serviceurl,failreason)))
  IF (validate(debug,- (1)) > 0)
   CALL echo(build2("failReason=",failreason))
  ENDIF
  CALL populatehttperrortoreply(i4status_service_unavailable)
  CALL updatetargetobjectofstatusdatainreply(statuscode_service_unavailable,failreason)
  CALL exitservicefailure(failreason,true)
 ENDIF
 SET lduserid = getlogicaldomainsystemuser(logicaldomainid)
 SET userlogicaldomainid = getlogicaldomainforcurrentuserincontext(null)
 IF (userlogicaldomainid != logicaldomainid)
  SET impersonatestatus = impersonatepersonnelinfo(lduserid)
  IF (impersonatestatus)
   IF ( NOT (createoauthstring(oauthheader,failreason)))
    IF (validate(debug,- (1)) > 0)
     CALL echo(build2("failReason=",failreason))
    ENDIF
    CALL populatehttperrortoreply(i4status_service_unavailable)
    CALL updatetargetobjectofstatusdatainreply(statuscode_service_unavailable,failreason)
    CALL exitservicefailure(failreason,true)
   ENDIF
  ELSE
   SET failreason = build2("Unable to impersonate the logical domain:",logicaldomainid)
   CALL populatehttperrortoreply(i4status_service_unavailable)
   CALL updatetargetobjectofstatusdatainreply(statuscode_service_unavailable,failreason)
   CALL exitservicefailure(failreason,true)
  ENDIF
 ELSE
  IF ( NOT (createoauthstring(oauthheader,failreason)))
   IF (validate(debug,- (1)) > 0)
    CALL echo(build2("failReason=",failreason))
   ENDIF
   CALL populatehttperrortoreply(i4status_service_unavailable)
   CALL updatetargetobjectofstatusdatainreply(statuscode_service_unavailable,failreason)
   CALL exitservicefailure(failreason,true)
  ENDIF
 ENDIF
 EXECUTE pft_srvuri
 IF ( NOT (initializerequest(serviceurl,phttpmethod,pmediatype,hrequest,hheadershandle,
  hcustomheaderhandle)))
  SET failreason = "Unable to initialize request"
  IF (validate(debug,- (1)) > 0)
   CALL echo(build2("failReason=",failreason))
  ENDIF
  CALL populatehttperrortoreply(i4status_service_unavailable)
  CALL updatetargetobjectofstatusdatainreply(statuscode_service_unavailable,failreason)
  CALL exitservicefailure(failreason,true)
 ENDIF
 IF (trim(cnvtupper(phttpmethod),3) != http_get)
  SET stat = uar_srv_setpropstring(hheadershandle,nullterm("contenttype"),nullterm(pmediatype))
  SET hrequestbuffer = uar_srv_creatememorybuffer(3,0,0,0,0,
   0)
  SET stat = uar_srv_setbufferpos(hrequestbuffer,0,0,pos)
  SET stat = uar_srv_writebuffer(hrequestbuffer,nullterm(jsonservicerequestbody),size(trim(
     jsonservicerequestbody,3)),0)
  SET stat = uar_srv_setprophandle(hheadershandle,"reqbuffer",hrequestbuffer,1)
 ENDIF
 SET stat = uar_srv_setpropstring(hcustomheaderhandle,"Tenant-Short-Name",nullterm(trim(curdomain,3))
  )
 SET stat = uar_srv_setpropstring(hcustomheaderhandle,"Authorization",nullterm(oauthheader))
 IF (validate(debug,0) > 0)
  CALL echorecord(reqinfo)
 ENDIF
 SET issuccess = executehttprequest(hrequest,hheadershandle,hcustomheaderhandle,prhttpstatuscd,
  prjsonresponse)
 SET stat = uar_srv_closehandle(hrequest)
 SET stat = uar_srv_closehandle(hheadershandle)
 SET stat = uar_srv_closehandle(hcustomheaderhandle)
 SET stat = uar_srv_closehandle(hrequestbuffer)
 IF (issuccess=false)
  SET failreason = "executeHttpRequest failed"
  IF (validate(debug,- (1)) > 0)
   CALL echo(build2("failReason=",failreason))
  ENDIF
  CALL populatehttperrortoreply(i4status_service_unavailable)
  CALL updatetargetobjectofstatusdatainreply(statuscode_service_unavailable,failreason)
  CALL exitservicefailure(failreason,true)
 ENDIF
 IF (validate(debug,0) > 0)
  CALL echo(build2("prHttpStatusCd=",prhttpstatuscd))
  CALL echo(build2("prJsonResponse=",prjsonresponse))
 ENDIF
 CALL deserializeserviceresponse(prjsonresponse,prhttpstatuscd)
 IF (((prhttpstatuscd=200) OR (prhttpstatuscd=201)) )
  CALL exitservicesuccess(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  CALL populatehttperrortoreply(prhttpstatuscd)
  CALL exitservicefailure(reply->status_data.subeventstatus[1].targetobjectvalue,true)
 ENDIF
 SUBROUTINE (validaterequest(prfailreason=vc(ref)) =i2)
   DECLARE isvalid = i2 WITH protect, noconstant(false)
   CALL logmessage(cursub,"Entering...",log_debug)
   IF (validate(debug,0) > 0)
    CALL echo(request)
   ENDIF
   IF ((( NOT (validate(request->charge_desc_master))) OR (size(request->charge_desc_master,5)=0)) )
    SET prfailreason = "charge_desc_master required"
   ELSEIF ((request->charge_desc_master_qual != size(request->charge_desc_master,5)))
    SET prfailreason = "charge_desc_master invalid"
   ELSE
    SET logicaldomainid = request->charge_desc_master[1].logical_domain_id
    SET isvalid = true
   ENDIF
   CALL logmessage(cursub,"Exiting...",log_debug)
   RETURN(isvalid)
 END ;Subroutine
 SUBROUTINE (buildservicerequestbody(isasync=i2,prjsonservicerequestbody=vc(ref),prfailreason=vc(ref)
  ) =i2)
   DECLARE isvalid = i2 WITH protect, noconstant(false)
   CALL logmessage(cursub,"Entering...",log_debug)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(servicerequestbody)
   ENDIF
   IF (isasync)
    RECORD asyncservicerequestbody(
      1 pubsub_ind = vc
      1 destination_name = vc
      1 payload = vc
    ) WITH protect
    SET asyncservicerequestbody->pubsub_ind = "false"
    SET asyncservicerequestbody->destination_name = destination_name
    SET asyncservicerequestbody->payload = cnvtrectojson(servicerequestbody,9)
    SET prjsonservicerequestbody = cnvtrectojson(asyncservicerequestbody,9)
   ELSE
    SET prjsonservicerequestbody = cnvtrectojson(servicerequestbody,9)
   ENDIF
   IF (size(trim(prjsonservicerequestbody,3),3) > 0)
    SET isvalid = true
   ELSE
    SET prfailreason = "failed to construct service request body"
   ENDIF
   CALL logmessage(cursub,"Exiting...",log_debug)
   RETURN(isvalid)
 END ;Subroutine
 SUBROUTINE (clonerequesttoreply(dummyvar=vc) =null)
   DECLARE issuereason = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(request->charge_desc_master,5))
    PLAN (d)
    HEAD REPORT
     stat = alterlist(reply->charge_desc_master,size(request->charge_desc_master,5))
    DETAIL
     reply->charge_desc_master[d.seq].cdm_id = request->charge_desc_master[d.seq].cdm_id, reply->
     charge_desc_master[d.seq].cdm_code = request->charge_desc_master[d.seq].cdm_code, reply->
     charge_desc_master[d.seq].description = request->charge_desc_master[d.seq].description,
     reply->charge_desc_master[d.seq].service_type = request->charge_desc_master[d.seq].service_type,
     issuereason = ""
     IF ( NOT (validaterequestitem(d.seq,issuereason)))
      reply->charge_desc_master[d.seq].status_code = cnvtint(statuscode_bad_request), reply->
      charge_desc_master[d.seq].issue = issuereason
     ELSE
      CALL populateservicerequestfromrequest(d.seq)
     ENDIF
    WITH nocounter
   ;end select
   SET reply->charge_desc_master_qual = size(request->charge_desc_master,5)
 END ;Subroutine
 SUBROUTINE (validaterequestitem(itemindex=i4,prfailreason=vc(ref)) =i2)
   CALL logmessage(cursub,"Entering...",log_debug)
   DECLARE isvalid = i2 WITH protect, noconstant(false)
   IF (size(trim(validate(request->charge_desc_master[itemindex].cdm_id,""),3))=0)
    SET prfailreason = "cdm_id required"
   ELSEIF (size(trim(validate(request->charge_desc_master[itemindex].cdm_code,""),3))=0)
    SET prfailreason = "cdm_code required"
   ELSEIF (size(trim(validate(request->charge_desc_master[itemindex].description,""),3))=0)
    SET prfailreason = "description required"
   ELSEIF ((((request->charge_desc_master[itemindex].service_type < technical_service_type)) OR ((
   request->charge_desc_master[itemindex].service_type > professional_service_type))) )
    SET prfailreason = "service_type invalid"
   ELSE
    SET isvalid = true
   ENDIF
   RETURN(isvalid)
 END ;Subroutine
 SUBROUTINE (populateservicerequestfromrequest(itemindex=i4) =null)
   CALL logmessage(cursub,"Entering...",log_debug)
   DECLARE nextidx = i4 WITH protect, noconstant((size(servicerequestbody->cdms,5)+ 1))
   SET stat = alterlist(servicerequestbody->cdms,nextidx)
   SET servicerequestbody->cdms[nextidx].cdm_id = request->charge_desc_master[itemindex].cdm_id
   SET servicerequestbody->cdms[nextidx].cdm_code = request->charge_desc_master[itemindex].cdm_code
   SET servicerequestbody->cdms[nextidx].description = request->charge_desc_master[itemindex].
   description
   IF ((request->charge_desc_master[itemindex].service_type=technical_service_type))
    SET servicerequestbody->cdms[nextidx].service_type = "TECH"
   ELSEIF ((request->charge_desc_master[itemindex].service_type=professional_service_type))
    SET servicerequestbody->cdms[nextidx].service_type = "PROF"
   ENDIF
   SET servicerequestbody->cdms[nextidx].logical_domain_id = request->charge_desc_master[itemindex].
   logical_domain_id
 END ;Subroutine
 SUBROUTINE (deserializeserviceresponse(prjsonresponsebody=vc(ref),prhttpstatuscd=i4) =null)
   CALL logmessage(cursub,"Entering...",log_debug)
   DECLARE jsonstr = vc WITH protect
   IF (prjsonresponsebody != null
    AND textlen(trim(prjsonresponsebody,3)) > 0)
    SET jsonstr = replace('{"root": REPLACE_ME}',"REPLACE_ME",prjsonresponsebody,1)
    SET stat = cnvtjsontorec(jsonstr)
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(root)
    ENDIF
    CALL populatereplyfromresponse(prhttpstatuscd)
   ELSE
    CALL populatehttperrortoreply(prhttpstatuscd)
    CALL updatetargetobjectofstatusdatainreply(build(prhttpstatuscd),null)
   ENDIF
 END ;Subroutine
 SUBROUTINE (populatereplyfromresponse(prhttpstatuscd=i4) =null)
  DECLARE failurereason = vc WITH protect, noconstant
  IF (validate(root->items)=1)
   IF (size(root->items,5) > 0)
    CALL updatecdmsinreply(null)
   ENDIF
   IF (isallitemsinreplyhasstatuscodeequals200(null))
    CALL updatetargetobjectofstatusdatainreply(statuscode_created,null)
   ELSE
    CALL updatetargetobjectofstatusdatainreply(statuscode_ok,null)
   ENDIF
  ELSEIF (validate(root->errors)=1)
   IF (size(root->errors,5) > 0)
    SET failurereason = build2(root->errors[1].errorcode," ",root->errors[1].message)
   ENDIF
   CALL populatehttperrortoreply(prhttpstatuscd)
   CALL updatetargetobjectofstatusdatainreply(build(prhttpstatuscd),failurereason)
  ELSEIF (validate(root->error)=1)
   SET failurereason = root->error
   CALL populatehttperrortoreply(prhttpstatuscd)
   CALL updatetargetobjectofstatusdatainreply(build(prhttpstatuscd),failurereason)
  ELSE
   SET failurereason = "Unknown"
   CALL populatehttperrortoreply(prhttpstatuscd)
   CALL updatetargetobjectofstatusdatainreply(build(prhttpstatuscd),failurereason)
  ENDIF
 END ;Subroutine
 SUBROUTINE (isallitemsinreplyhasstatuscodeequals200(dummyvar=vc) =i2)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SET pos = locateval(num,1,size(reply->charge_desc_master,5),"Not200",evaluate(reply->
     charge_desc_master[num].status_code,200,"200","Not200"))
   IF (pos > 0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (updatetargetobjectofstatusdatainreply(name=vc,value=vc) =null)
   CALL logmessage(cursub,"Entering... ",log_debug)
   SET reply->status_data.subeventstatus[1].targetobjectname = name
   IF (value != null)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = value
   ELSE
    SET reply->status_data.subeventstatus[1].targetobjectvalue = lookuphttpstatustext(prhttpstatuscd)
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatecdmsinreply(dummyvar=vc) =null)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE targetcdmid = vc WITH protect, noconstant
   FOR (index = 1 TO size(reply->charge_desc_master,5))
     SET targetcdmid = reply->charge_desc_master[index].cdm_id
     DECLARE num = i4 WITH protect, noconstant(0)
     DECLARE pos = i4 WITH protect, noconstant(0)
     SET pos = locateval(num,1,size(root->items,5),targetcdmid,root->items[num].cdmid)
     IF (pos > 0)
      SET reply->charge_desc_master[index].status_code = root->items[pos].statuscode
      SET reply->charge_desc_master[index].issue = validate(root->items[pos].errormessage,"")
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (lookuphttpstatustext(prhttpstatuscd=i4) =vc)
   CALL logmessage(cursub,"Entering... ",log_debug)
   DECLARE statustext = vc WITH protect, noconstant("")
   CASE (prhttpstatuscd)
    OF 200:
     SET statustext = "OK"
    OF 201:
     SET statustext = "Created"
    OF 400:
     SET statustext = "Bad Request"
    OF 401:
     SET statustext = "Unauthorized"
    OF 403:
     SET statustext = "Forbidden"
    OF 404:
     SET statustext = "Not Found"
    OF 500:
     SET statustext = "Internal Server Error"
    OF 501:
     SET statustext = "Not Implemented"
    OF 502:
     SET statustext = "Bad Gateway"
    OF 503:
     SET statustext = "Service Unavailable"
    ELSE
     SET statustext = "Unknown"
   ENDCASE
   RETURN(statustext)
 END ;Subroutine
 SUBROUTINE (populatehttperrortoreply(prhttpstatuscd=i4) =null)
   CALL logmessage(cursub,"Entering...",log_debug)
   DECLARE serrormessage = vc WITH protect, noconstant("")
   DECLARE shttperrortext = vc WITH protect, noconstant("")
   SET shttperrortext = lookuphttpstatustext(prhttpstatuscd)
   SET serrormessage = build2(prhttpstatuscd,"-",shttperrortext)
   FOR (index = 1 TO size(reply->charge_desc_master,5))
     IF (validate(reply->charge_desc_master[index].issue,"")="")
      SET reply->charge_desc_master[index].status_code = prhttpstatuscd
      SET reply->charge_desc_master[index].issue = validate(serrormessage,"")
     ENDIF
   ENDFOR
   CALL logmessage(cursub,"Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (getlogicaldomainforcurrentuserincontext(dummyvar=i2) =f8)
   DECLARE currentcontextuser = vc WITH protect, noconstant("")
   DECLARE userldid = f8 WITH protect, noconstant(0.0)
   DECLARE currentuserlen = i4 WITH private, noconstant((uar_secgetusernamelen()+ 1))
   SET stat = memalloc(currentuserincontext,1,build("C",currentuserlen))
   SET stat = uar_secgetusername(currentuserincontext,currentuserlen)
   SET currentcontextuser = nullterm(currentuserincontext)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.username=currentcontextuser
    DETAIL
     userldid = p.logical_domain_id
    WITH nocounter
   ;end select
   RETURN(userldid)
 END ;Subroutine
 SUBROUTINE (impersonatepersonnelinfo(logicaldomainuserid=f8) =i2)
   DECLARE setcntxt = i4 WITH protect, noconstant(0)
   DECLARE logicaldomainusername = vc WITH protect, noconstant("")
   DECLARE uar_secsetcontext(hctx=i4) = i2 WITH protect, noconstant(0)
   EXECUTE secrtl  WITH image_axp = "secrtl", image_aix = "libsec.a(libsec.o)", uar = "SecSetContext",
   persist
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=logicaldomainuserid
    DETAIL
     logicaldomainusername = p.username
    WITH nocounter
   ;end select
   SET setcntxt = uar_secimpersonate(nullterm(logicaldomainusername),nullterm(curdomain))
   DECLARE impersonateresultlen = i4 WITH private, noconstant((uar_secgetusernamelen()+ 1))
   SET stat = memalloc(impersonateusername,1,build("C",impersonateresultlen))
   SET stat = uar_secgetusername(impersonateusername,impersonateresultlen)
   IF (impersonateusername=logicaldomainusername)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
#exit_script
#end_program
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
END GO
