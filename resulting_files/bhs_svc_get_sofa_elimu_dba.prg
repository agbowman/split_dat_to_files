CREATE PROGRAM bhs_svc_get_sofa_elimu:dba
 EXECUTE bhs_check_domain:dba
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_client_id = vc WITH protect, noconstant(" ")
 DECLARE ms_client_secret = vc WITH protect, noconstant(" ")
 DECLARE ms_api_key = vc WITH protect, noconstant(" ")
 DECLARE cpm_http_transaction = i4 WITH protect, constant(2000)
 DECLARE http_success = i4 WITH protect, constant(200)
 DECLARE hheader1 = i4 WITH protect, noconstant(0)
 DECLARE hheader2 = i4 WITH protect, noconstant(0)
 DECLARE hheader3 = i4 WITH protect, noconstant(0)
 DECLARE hheader4 = i4 WITH protect, noconstant(0)
 DECLARE hhttpmsg = i4 WITH protect, noconstant(0)
 DECLARE hhttpreq = i4 WITH protect, noconstant(0)
 DECLARE hhttprep = i4 WITH protect, noconstant(0)
 DECLARE nhttpstatus = i4 WITH protect, noconstant(0)
 DECLARE sresponse = vc WITH protect, noconstant("")
 DECLARE sserviceuri = vc WITH protect, noconstant("")
 DECLARE stxt1 = vc WITH protect, constant("<return>")
 DECLARE stxt2 = vc WITH protect, constant("</return>")
 CALL echo("bhs_svc_get_sofa_elimu")
 DECLARE geturi(null) = vc
 SET sserviceuri = trim(geturi(null))
 SET nhttpstatus = executehttpcall(2.0)
 SUBROUTINE (executehttpcall(spersonid=f8) =i4)
   CALL echo("******* In executeHttpCall  Sub *******")
   DECLARE sfirstpart = vc WITH protect, noconstant("")
   DECLARE ssecondpart = vc WITH protect, noconstant("")
   DECLARE srequest = vc WITH protect, noconstant("")
   SET sfirstpart =
'<?xml version="1.0"?>     <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"     xmlns:SOAP-ENC\
="http://schemas.xmlsoap.org/soap/encoding/"     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"     xmlns:xsd="http\
://www.w3.org/2001/XMLSchema"     xmlns:ord="http://orders.service.web.cerner.com/"><SOAP-ENV:Body><ord:getOrders>     <ar\
g0>\
'
   SET srequest = trim(m_request->s_json,3)
   CALL echo(build("Server Request:",srequest))
   CALL echo(build("Sending To: ",sserviceuri))
   SET hhttpmsg = uar_srvselectmessage(cpm_http_transaction)
   SET hhttpreq = uar_srvcreaterequest(hhttpmsg)
   SET hhttprep = uar_srvcreatereply(hhttpmsg)
   SET stat = uar_srvsetstringfixed(hhttpreq,"uri",sserviceuri,size(sserviceuri,1))
   SET stat = uar_srvsetstring(hhttpreq,"method","POST")
   SET stat = uar_srvsetasis(hhttpreq,"request_buffer",srequest,size(srequest,1))
   SET hheader1 = uar_srvgetstruct(hhttpreq,"header")
   SET stat = uar_srvsetstring(hheader1,"content_type","application/jason")
   IF (gl_bhs_prod_flag=0)
    SET ms_client_id = "9aab0e36-f282-472e-85a2-0f7aeded518d"
    SET ms_client_secret = "6lIJTMhILT9pgKpvaioOjlq6uo7uKFSt"
    SET ms_api_key = "QKB1W4Z430A2327NGBU2029AY98OY4XCAQR800TL"
   ELSE
    SET ms_client_id = "1c9444ea-1824-4e3d-bd27-4da73c9c8a18"
    SET ms_client_secret = "TIRIzEC9u7C1ST2OeS-L59uZRwMaOsCA"
    SET ms_api_key = "QKB1W4Z430A2327NGBU2029AY98OY4XCAQR800TL"
   ENDIF
   SET hheader2 = uar_srvadditem(hheader1,"custom_headers")
   SET stat = uar_srvsetstring(hheader2,"name","clientid")
   SET stat = uar_srvsetstring(hheader2,"value",value(ms_client_id))
   SET hheader3 = uar_srvadditem(hheader1,"custom_headers")
   SET stat = uar_srvsetstring(hheader3,"name","clientsecret")
   SET stat = uar_srvsetstring(hheader3,"value",value(ms_client_secret))
   SET hheader4 = uar_srvadditem(hheader1,"custom_headers")
   SET stat = uar_srvsetstring(hheader4,"name","x-api-key")
   SET stat = uar_srvsetstring(hheader4,"value",value(ms_api_key))
   CALL uar_oen_dump_object(hhttpreq)
   SET stat = uar_srvexecute(hhttpmsg,hhttpreq,hhttprep)
   SET nhttpstatus = uar_srvgetlong(hhttprep,"http_status_code")
   CALL echo(build("HTTP Status Code = ",nhttpstatus))
   IF (nhttpstatus != 200)
    CALL echo("Problem encountered calling web service")
    CALL cleansrvcall(1)
    RETURN(nhttpstatus)
   ENDIF
   IF (nhttpstatus=200)
    SET sresponse = gethttpresponsebody(hhttprep)
    CALL echo(concat("Unformatted Response ",sresponse))
    CALL uar_oen_dump_object(hhttprep)
    CALL cleansrvcall(1)
    RETURN(nhttpstatus)
   ENDIF
 END ;Subroutine
 SUBROUTINE gethttpresponsebody(hhttpresponsehandle)
   CALL echo("******* In getHttpResponseBody Sub *******")
   DECLARE nresponsesize = i4 WITH protect, noconstant(0)
   SET nresponsesize = uar_srvgetasissize(hhttpresponsehandle,"response_buffer")
   IF (nresponsesize > 0)
    RETURN(substring(1,nresponsesize,uar_srvgetasisptr(hhttpresponsehandle,"response_buffer")))
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE geturi(null)
  IF (gl_bhs_prod_flag=0)
   SET s_uri =
   "https://omnibus-stage.elimuinformatics.com/omnibus-api/api/v2/elimu/sapphire/calculator/sofa-calculator?user=23835986"
  ELSE
   SET s_uri =
   "https://omnibus.elimuinformatics.com/omnibus-api/api/v2/elimu/sapphire/calculator/sofa-calculator?user=23835986"
  ENDIF
  RETURN(s_uri)
 END ;Subroutine
 SUBROUTINE cleansrvcall(iidx18)
   CALL echo("******* In cleanSrvCall Sub *******")
   SET stat = uar_srvdestroyinstance(hhttpreq)
   SET ghhttpreq = 0
   SET stat = uar_srvdestroyinstance(hhttprep)
   SET ghhttprep = 0
   SET stat = uar_srvdestroymessage(hhttpmsg)
   SET ghhttpmsg = 0
 END ;Subroutine
#exit_script
END GO
