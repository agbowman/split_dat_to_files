CREATE PROGRAM clip_oauth_wrapper:dba
 FREE RECORD reply
 RECORD reply(
   1 o_auth
     2 header = vc
     2 status_data
       3 status = i4
       3 success_ind = i2
   1 response_body = vc
   1 status_code = c50
   1 status_description = vc
 )
 DECLARE oauthsuccessind = i2 WITH protect, noconstant(0)
 DECLARE successind = i2 WITH protect, noconstant(0)
 DECLARE makeoauthcall(null) = i2 WITH protect
 DECLARE populateoauthheader(null) = i2 WITH protect
 CALL makeoauthcall(null)
 CALL echorecord(reply)
 SUBROUTINE makeoauthcall(null)
   SET oauthsuccessind = populateoauthheader(reply)
   DECLARE soauthheader = vc WITH private, constant(reply->o_auth.header)
   IF (oauthsuccessind=0)
    RETURN(oauthsuccessind)
   ENDIF
   EXECUTE srvuri
   DECLARE huri = i4 WITH private, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE hrequestbuffer = i4 WITH private, noconstant(0)
   DECLARE hresponsebuffer = i4 WITH private, noconstant(0)
   DECLARE hprop = i4 WITH private, noconstant(0)
   DECLARE hoauthprop = i4 WITH private, noconstant(0)
   DECLARE hresp = i4 WITH private, noconstant(0)
   DECLARE hrespprops = i4 WITH private, noconstant(0)
   DECLARE actual = i4 WITH private, noconstant(0)
   DECLARE lpos = i4 WITH private, noconstant(0)
   DECLARE respbuffersize = i4 WITH private, noconstant(0)
   DECLARE respbuffer = c524288 WITH private
   DECLARE read_buffer_size = i4 WITH private, constant(524288)
   DECLARE respstatuscode = c50 WITH private
   DECLARE respstatusdescription = c50 WITH private
   SET huri = uar_srv_geturiparts(value(request->uri))
   SET hreq = uar_srv_createwebrequest(huri)
   SET hprop = uar_srv_createproplist()
   SET hoauthprop = uar_srv_createproplist()
   SET hrequestbuffer = uar_srv_creatememorybuffer(3,0,0,0,0,
    0)
   SET stat = uar_srv_setbufferpos(hrequestbuffer,0,0,lpos)
   SET stat = uar_srv_setpropstring(hprop,"method",nullterm(request->method))
   IF (size(request->request_body_json) > 0)
    SET stat = uar_srv_writebuffer(hrequestbuffer,request->request_body_json,size(request->
      request_body_json),actual)
   ENDIF
   SET stat = uar_srv_setpropstring(hprop,"accept","*/*")
   SET stat = uar_srv_setpropstring(hprop,"contenttype","application/json")
   SET stat = uar_srv_setpropstring(hoauthprop,"Authorization",nullterm(soauthheader))
   SET stat = uar_srv_setprophandle(hprop,"customHeaders",hoauthprop,1)
   SET stat = uar_srv_setprophandle(hprop,"reqBuffer",hrequestbuffer,1)
   SET stat = uar_srv_setwebrequestprops(hreq,hprop)
   SET hresponsebuffer = uar_srv_creatememorybuffer(3,0,0,0,0,
    0)
   SET hresp = uar_srv_getwebresponse(hreq,hresponsebuffer)
   SET hrespprops = uar_srv_getwebresponseprops(hresp)
   SET stat = uar_srv_getpropstring(hrespprops,"statusCode",respstatuscode,50)
   SET stat = uar_srv_getpropstring(hrespprops,"statusDesc",respstatusdescription,50)
   SET stat = uar_srv_getmemorybuffersize(hresponsebuffer,respbuffersize)
   SET stat = uar_srv_setbufferpos(hresponsebuffer,0,0,lpos)
   SET stat = uar_srv_readbuffer(hresponsebuffer,respbuffer,read_buffer_size,actual)
   SET reply->response_body = respbuffer
   SET reply->status_code = respstatuscode
   SET reply->status_description = respstatusdescription
   SET status = uar_srv_closehandle(huri)
   SET status = uar_srv_closehandle(hreq)
   SET status = uar_srv_closehandle(hrequestbuffer)
   SET status = uar_srv_closehandle(hresponsebuffer)
   SET status = uar_srv_closehandle(hprop)
   SET status = uar_srv_closehandle(hoauthprop)
   SET status = uar_srv_closehandle(hrespprops)
   SET status = uar_srv_closehandle(hresp)
   RETURN(oauthsuccessind)
 END ;Subroutine
 SUBROUTINE populateoauthheader(null)
   DECLARE oauth_message_number = i4 WITH private, constant(99999131)
   DECLARE oauth_message = i4 WITH private, constant(uar_srvselectmessage(oauth_message_number))
   DECLARE oauth_request = i4 WITH private, constant(uar_srvcreaterequest(oauth_message))
   DECLARE oauth_response = i4 WITH private, constant(uar_srvcreatereply(oauth_message))
   DECLARE oauthstatus = i4 WITH private, noconstant(0)
   SET stat = uar_srvexecute(oauth_message,oauth_request,oauth_response)
   SET oauthstatus = uar_srvgetstruct(oauth_response,"status")
   SET reply->o_auth.status_data.status = oauthstatus
   SET successind = uar_srvgetshort(oauthstatus,"success_ind")
   SET reply->o_auth.status_data.success_ind = successind
   DECLARE ccldate = dq8 WITH private, noconstant(0)
   DECLARE epochdatestart = f8 WITH private, noconstant(0.0)
   DECLARE epochdatecurrent = f8 WITH private, noconstant(0.0)
   DECLARE epochdate = i4 WITH private, noconstant(0)
   SET ccldate = cnvtdatetime(sysdate)
   SET epochdatestart = (cnvtdatetime("01-JAN-1970")/ 10000000)
   SET epochdatecurrent = (ccldate/ 10000000)
   SET epochdate = (epochdatecurrent - epochdatestart)
   DECLARE oauthresponse = i4 WITH private, noconstant(0)
   DECLARE oauthtoken = vc WITH private, noconstant("")
   DECLARE oauthtokensecret = vc WITH private, noconstant("")
   DECLARE oauthconsumerkey = vc WITH private, noconstant("")
   DECLARE oauthaccessorsecret = vc WITH private, noconstant("")
   DECLARE oauthnonce = vc WITH private, noconstant("")
   DECLARE oauthtimestamp = vc WITH private, noconstant("")
   DECLARE oauthsignature = vc WITH private, noconstant("")
   DECLARE oauthheader = vc WITH private, noconstant("")
   DECLARE oauth_version = vc WITH private, constant("1.0")
   DECLARE oauth_signature_method = vc WITH private, constant("PLAINTEXT")
   SET oauthresponse = uar_srvgetstruct(oauth_response,"oauth_access_token")
   SET oauthtoken = uar_srvgetstringptr(oauthresponse,"oauth_token")
   SET oauthtokensecret = uar_srvgetstringptr(oauthresponse,"oauth_token_secret")
   SET oauthconsumerkey = uar_srvgetstringptr(oauthresponse,"oauth_consumer_key")
   SET oauthaccessorsecret = uar_srvgetstringptr(oauthresponse,"oauth_accessor_secret")
   SET oauthnonce = uar_srvgetstringptr(oauthresponse,"oauth_nonce")
   SET oauthtimestamp = trim(cnvtstring(epochdate),3)
   SET oauthnonce = trim(format((epochdatecurrent * epochdatestart),build(fillstring(31,"#"),";T(1)")
     ),3)
   SET oauthsignature = concat(oauthaccessorsecret,"%26",oauthtokensecret)
   SET oauthheader = concat('OAuth oauth_token="',oauthtoken,'", oauth_version="',oauth_version,
    '", oauth_consumer_key="',
    oauthconsumerkey,'", oauth_signature_method="',oauth_signature_method,'", oauth_signature="',
    oauthsignature,
    '", oauth_timestamp="',oauthtimestamp,'", oauth_nonce="',oauthnonce,'"')
   SET reply->o_auth.header = oauthheader
   RETURN(successind)
 END ;Subroutine
END GO
