CREATE PROGRAM device_disassociation:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Tenant:" = "",
  "URL:" = "",
  "AUTH:" = "",
  "ENCNTRURN:" = "",
  "USERNAME:" = ""
  WITH outdev, tenant, url,
  auth, encntrurn, username
 DECLARE uar_srvgetasis(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_axp =
 "srvrtl", image_aix = "libsrv.a(libsrv.o)", uar = "SrvGetAsIs",
 persist
 DECLARE dencntrid = f8 WITH protect, constant(link_encntrid)
 DECLARE sencounterid = vc WITH protect, noconstant("")
 DECLARE surlwithencntr = vc WITH protect, noconstant("")
 DECLARE surl = vc WITH protect
 DECLARE stenant = vc WITH protect
 DECLARE sauth = vc WITH protect
 DECLARE sencntrurn = vc WITH protect
 DECLARE susername = vc WITH protect
 DECLARE srequestbody = vc WITH protect
 DECLARE sresponsebody = vc WITH protect
 DECLARE iassociationlist = i4 WITH protect
 DECLARE sgeturl = vc WITH protect
 DECLARE spurgeableboolean = vc WITH protect
 DECLARE cpm_http_transaction = i4 WITH constant(2000)
 SET surl =  $URL
 SET stenant =  $TENANT
 SET sauth =  $AUTH
 SET sencntrurn =  $ENCNTRURN
 SET susername =  $USERNAME
 SET srequestbody = ""
 SET sresponsebody = ""
 SET sencounterid = concat(sencntrurn,cnvtstring(dencntrid))
 SET surlwithencntr = concat("?encounterIds=",sencounterid)
 SET sgeturl = concat(surl,surlwithencntr)
 CALL echo(sgeturl)
 IF (validate(execmsgrtl,999)=999)
  EXECUTE msgrtl
 ENDIF
 DECLARE msgview_handle = i4 WITH noconstant(0)
 DECLARE emsglvl_debug = i4 WITH protect, constant(4)
 SET msgview_handle = uar_msgopen("device_disassociation_dbg")
 CALL uar_msgsetlevel(msgview_handle,emsglvl_debug)
 CALL httpurlcall(sgeturl,"GET",stenant,sauth,srequestbody,
  sresponsebody,retval)
 IF (retval=0)
  CALL echo("Exiting script, GET device association call failed!")
  RETURN
 ENDIF
 SET json = concat('{"associationdata":',substring(0,(textlen(sresponsebody) - 1),sresponsebody),
  ',"username":"',susername,'"',
  "}}")
 SET stat = cnvtjsontorec(json,0,0,0,1)
 CALL echorecord(associationdata)
 DECLARE iassociationssize = i4 WITH protect, noconstant(size(associationdata->associations,5))
 FOR (associationindex = 1 TO iassociationssize)
   IF ((associationdata->associations[associationindex].endtime=0))
    CALL echo(concat("Removing Association: ",associationdata->associations[associationindex].id))
    SET associationdata->associations[associationindex].endtime = timestampdiff(cnvtdatetimeutc(
      cnvtdatetime(sysdate)),cnvtdatetimeutc("01-JAN-1970"))
    IF (trim(cnvtstring(associationdata->associations[associationindex].purgeable))="1")
     SET spurgeableboolean = "true"
    ELSE
     SET spurgeableboolean = "false"
    ENDIF
    SET srequestbody = concat('{"associations":[{','"id":"',associationdata->associations[
     associationindex].id,'",','"deviceId":"',
     associationdata->associations[associationindex].deviceid,'",','"patientId":"',associationdata->
     associations[associationindex].patientid,'",',
     '"encounterId":"',associationdata->associations[associationindex].encounterid,'",',
     '"startTime":',cnvtstring(associationdata->associations[associationindex].starttime,20,0),
     ",",'"endTime":"',concat(trim(cnvtstring(associationdata->associations[associationindex].endtime,
        20,0)),"000"),'",','"purgeable":"',
     spurgeableboolean,'",','"versionNumber":"',trim(cnvtstring(associationdata->associations[
       associationindex].versionnumber)),'"',
     '}],"username":"',susername,'"',"}")
    CALL echo(concat("Association Body: ",srequestbody))
    CALL httpurlcall(sgeturl,"PUT",stenant,sauth,srequestbody,
     sresponsebody,retval)
    CALL echo(sresponsebody)
   ENDIF
 ENDFOR
 SUBROUTINE (httpurlcall(sgeturl=vc,smethod=vc,stenant=vc,sauth=vc,susername=vc,sresponsebody=vc(ref),
  retval=vc(ref)) =null WITH protect)
   CALL echo(concat("Calling Web Service Endpoint: ",sgeturl))
   CALL msgwrite(build("Calling Web Service Endpoint: (",sgeturl,")"))
   DECLARE istat = i4 WITH protect
   DECLARE ihttpstatus = i4 WITH protect
   DECLARE ihttpmsg = i4 WITH protect
   DECLARE ihttpmsgrequest = i4 WITH protect
   DECLARE ihttpmsgreply = i4 WITH protect
   DECLARE iheader = i4 WITH protect
   DECLARE iitem = i4 WITH protect
   DECLARE iresponsesize = i4 WITH protect
   SET istat = memalloc(response,1,"C1")
   SET ihttpmsg = uar_srvselectmessage(cpm_http_transaction)
   SET ihttpmsgrequest = uar_srvcreaterequest(ihttpmsg)
   SET ihttpmsgreply = uar_srvcreatereply(ihttpmsg)
   SET istat = uar_srvsetstringfixed(ihttpmsgrequest,"uri",sgeturl,size(sgeturl,1))
   SET istat = uar_srvsetstring(ihttpmsgrequest,"Method",nullterm(smethod))
   IF (size(srequestbody,1) > 0)
    SET stat = uar_srvsetasis(ihttpmsgrequest,"request_buffer",nullterm(srequestbody),size(
      srequestbody,1))
   ENDIF
   SET hheader = uar_srvgetstruct(ihttpmsgrequest,"header")
   IF (smethod="PUT")
    SET stat = uar_srvsetstring(hheader,"content_type","application/json")
   ELSE
    SET stat = uar_srvsetstring(hheader,"content_type","application/x-www-form-urlencoded")
   ENDIF
   IF (size(sauth,1) > 0)
    SET hitem = uar_srvadditem(hheader,"custom_headers")
    SET stat = uar_srvsetstring(hitem,"name","Authorization")
    SET stat = uar_srvsetstring(hitem,"value",nullterm(sauth))
   ENDIF
   IF (size(stenant,1) > 0)
    SET htenant = uar_srvadditem(hheader,"custom_headers")
    SET stat = uar_srvsetstring(htenant,"name","Tenant-Short-Name")
    SET stat = uar_srvsetstring(htenant,"value",nullterm(stenant))
   ENDIF
   SET stat = uar_srvexecute(ihttpmsg,ihttpmsgrequest,ihttpmsgreply)
   CALL echo(concat("HTTP Status Code: ",cnvtstring(uar_srvgetlong(ihttpmsgreply,"http_status_code"))
     ))
   CALL echo(concat("HTTP Status: ",uar_srvgetstringptr(ihttpmsgreply,"http_status")))
   CALL echo(concat("Content Type: ",uar_srvgetstringptr(ihttpmsgreply,"content_type")))
   CALL echo(concat("Response URI: ",uar_srvgetstringptr(ihttpmsgreply,"response_uri")))
   IF (uar_srvgetlong(ihttpmsgreply,"http_status_code")=200)
    CALL echo("Call Succeeded")
    CALL msgwrite("Call Succeeded")
    SET retval = 100
   ELSE
    CALL echo(concat("Call Failed with Response code: ",cnvtstring(uar_srvgetlong(ihttpmsgreply,
        "http_status_code"))))
    CALL msgwrite(build("Call Failed with Response code: ",cnvtstring(uar_srvgetlong(ihttpmsgreply,
        "http_status_code"))))
    SET retval = 0
    SET istat = memfree(response)
    RETURN
   ENDIF
   SET sresponsebody = uar_srvgetasisptr(ihttpmsgreply,"response_buffer")
   SET responsesize = uar_srvgetasissize(ihttpmsgreply,"response_buffer")
   SET stat = memrealloc(response,responsesize,"C1")
   CALL uar_srvgetasis(ihttpmsgreply,"response_buffer",response,responsesize)
   SET sresponsebody = notrim(substring(1,responsesize,response))
   SET stat = uar_srvdestroyinstance(ihttpmsgrequest)
   SET stat = uar_srvdestroyinstance(ihttpmsgreply)
   SET istat = memfree(response)
 END ;Subroutine
 SUBROUTINE (msgwrite(logmsg=vc) =i2)
   CALL uar_msgwrite(msgview_handle,0,nullterm("ibus"),emsglvl_debug,nullterm(logmsg))
 END ;Subroutine
END GO
