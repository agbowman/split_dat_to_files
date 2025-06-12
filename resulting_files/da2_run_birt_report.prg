CREATE PROGRAM da2_run_birt_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Report UUID" = "",
  "Organizations" = "",
  "Document Name" = "",
  "Document Type" = 102383433.00,
  "Runtime Parameters" = 0.0,
  "E-mail Addresses" = ""
  WITH outdev, report_uuid, organizations,
  documentname, document_type, runtime_params,
  emailaddresses
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD generatebirtdocumentrequest(
   1 document[1]
     2 report_uuid = vc
     2 document_name = vc
     2 organization[*]
       3 organization_id = f8
     2 document_type_cd = f8
     2 email_addresses[*]
       3 email_address = vc
 )
 RECORD generatebirtdocumentreply(
   1 successful_document[1]
     2 da_document_id = f8
   1 transaction_status[1]
     2 success_ind = i2
     2 debug_error_message = vc
   1 web_service_path = vc
 )
 RECORD tmporgs(
   1 organization[*]
     2 organization_id = f8
 )
 DECLARE _memory_reply_string = vc WITH public
 DECLARE ph = vc
 DECLARE doclink = vc
 DECLARE msg = vc
 DECLARE trans_msg = vc
 SET ph = concat("<html><head><meta name=",char(34),"discern",char(34)," content=",
  char(34),"MPAGES_SVC_EVENT",char(34),">")
 SET ph = concat(ph,"<meta http-equiv=",char(34),"Content-Type",char(34),
  " content=",char(34))
 SET ph = concat(ph,"text/html; charset\=iso-8859-1",char(34),"/><style type=",char(34),
  "text/css",char(34),">")
 SET ph = concat(ph,"table { font-family: ",char(34),"Calibri",char(34))
 SET ph = concat(ph,
  ", serif; }.tableHeader {color: rgb(0, 112, 346);font-size:14pt;font-weight:bolder;}.reportItem")
 SET ph = concat(ph,
  "{color: rgb(0, 85, 125); font-size: 10pt;}.reportItem:hover{background-color: rgb(248,251,136);}")
 SET ph = concat(ph,"</style><title>Generated DA2 Documents</title></head><body><table border=",char(
   34),"0",char(34))
 SET ph = concat(ph,"><tr><td class=",char(34),"tableHeader",char(34),
  " colspan=",char(34),"2",char(34),">")
 SET ph = concat(ph,
  "Generated DA2 Document</td></tr><tr><td><div><a href='javascript:MPAGES_SVC_EVENT(",char(34))
 IF (((( $DOCUMENT_TYPE=uar_get_code_by_cki("CKI.CODEVALUE!4101623642"))) OR (( $DOCUMENT_TYPE=0))) )
  SET doclink = "&&&frameset?__uuid=@@@&__documentid=###&__domain=+++"
 ELSE
  SET doclink = "&&&frameset?__uuid=@@@&__documentid=###&__format=^^^&__domain=+++"
 ENDIF
 SET ph = concat(ph,doclink,char(34),", ",char(34),
  char(34),")' class=",char(34),"reportItem",char(34),
  "><ul>")
 SET ph = concat(ph,"<li type=",char(34),"square",char(34),
  ">%%%</li></ul></a></div></td></tr>")
 SET ph = concat(ph,"</table></body></html>")
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",0.0)
 DECLARE runtimepromptsxml = gvc
 DECLARE vc_query_uuid = vc
 DECLARE vc_email_addresses = vc
 DECLARE vc_email_address = vc
 DECLARE vc_report_uuid = vc
 DECLARE vc_report_design = vc
 DECLARE vc_organizations = vc
 DECLARE vc_organization = vc
 DECLARE vc_docname = vc
 DECLARE vc_doctypecki = vc
 DECLARE i_doctypecodeval = f8
 DECLARE i_doctypecd = f8
 DECLARE vc_doctypecodecki = vc
 DECLARE vc_doctypedisplay = vc
 DECLARE i_fail = i4
 DECLARE vc_return_message = vc
 DECLARE vc_doclink_txt = vc
 DECLARE documentid = vc
 DECLARE documentsuccessind = i2
 DECLARE documentdebugerrormessage = vc
 DECLARE needtoendreq = i4
 DECLARE num = i4
 DECLARE num2 = i4
 DECLARE org_cnt = i4
 DECLARE org_security_enabled = i4
 DECLARE i_reportid = i4
 DECLARE i_orgstart = i4
 DECLARE i_orgcur = i4
 DECLARE inorgs = i4
 DECLARE i_runtimeparams = f8
 SET i_runtimeparams = 0.0
 SET i_report_id = 0
 SET vc_email_addresses = trim( $EMAILADDRESSES)
 SET vc_docname = trim( $DOCUMENTNAME)
 SET i_runtimeparams =  $RUNTIME_PARAMS
 SET i_doctypecodeval =  $DOCUMENT_TYPE
 SET vc_doctypedisplay = " "
 SET vc_doctypecodecki = " "
 SET i_doctypecd = 0
 SET i_fail = 0
 SET documentsuccessind = 0
 SET needtoendreq = 0
 SET num = 0
 SET num2 = 0
 SET org_cnt = 0
 SET org_security_enabled = 0
 SET i_orgstart = 1
 SET i_orgcur = 0
 SET vc_organizations = " "
 SET inorgs = 0
 SET generatebirtdocumentreply->transaction_status.success_ind = 0
 SET generatebirtdocumentreply->transaction_status.debug_error_message = ""
 SET generatebirtdocumentreply->successful_document.da_document_id = 0.0
 SET generatebirtdocumentreply->web_service_path = ""
 SET reply->status_data.status = "F"
 IF (((substring(1,1,reflect( $REPORT_UUID))="I") OR (substring(1,1,reflect( $REPORT_UUID))="F")) )
  SET i_report_id =  $REPORT_UUID
 ELSE
  SET vc_query_uuid =  $REPORT_UUID
 ENDIF
 SELECT
  di.info_number
  FROM dm_info di
  WHERE di.info_name="SEC_ORG_RELTN"
   AND di.info_domain="SECURITY"
  DETAIL
   org_security_enabled = di.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ltr.long_text
  FROM long_text_reference ltr
  WHERE ltr.long_text_id=i_runtimeparams
   AND ltr.parent_entity_name="DA_BATCH_REPORT"
   AND ltr.active_ind=1
  DETAIL
   runtimepromptsxml = ltr.long_text
  WITH nocounter
 ;end select
 IF (size(vc_query_uuid,1) > 0)
  SELECT
   *
   FROM da_report r,
    long_text_reference ltr
   PLAN (r
    WHERE r.report_uuid=vc_query_uuid)
    JOIN (ltr
    WHERE r.long_text_id=ltr.long_text_id)
   DETAIL
    vc_report_uuid = trim(r.report_uuid), vc_report_design = trim(ltr.long_text)
   WITH maxrec = 1
  ;end select
 ELSEIF (i_report_id > 0)
  SELECT
   *
   FROM da_report r,
    long_text_reference ltr
   PLAN (r
    WHERE r.da_report_id=i_report_id)
    JOIN (ltr
    WHERE r.long_text_id=ltr.long_text_id)
   DETAIL
    vc_report_uuid = trim(r.report_uuid), vc_report_design = trim(ltr.long_text)
   WITH maxrec = 1
  ;end select
 ELSE
  SET i_fail = 1
  SET vc_return_message = build(
   "Discern Analytics 2.0 document generation failed because an invalid report_uuid was passed in")
  GO TO exit_script
 ENDIF
 IF (org_security_enabled=1)
  DECLARE par = c20
  SET lnum = 0
  SET num = 3
  SET cnt = 0
  SET cnt2 = 0
  WHILE (num > 0)
   SET par = reflect(parameter(num,0))
   IF (par=" ")
    SET cnt = (num - 1)
    SET num = 0
   ELSE
    IF (substring(1,1,par)="L")
     CALL echo(build("$(",num,")",par))
     SET lnum = 1
     WHILE (lnum > 0)
      SET par = reflect(parameter(num,lnum))
      IF (par=" ")
       SET cnt2 = (lnum - 1)
       SET lnum = 0
      ELSE
       CALL echo(build("$(",num,".",lnum,")",
         par,"=",parameter(num,lnum)))
       SET vc_organization = build(parameter(num,lnum))
       SET lnum += 1
       SET inorgs += 1
       SET stat = alterlist(tmporgs->organization,inorgs)
       SET tmporgs->organization[inorgs].organization_id = cnvtint(vc_organization)
      ENDIF
     ENDWHILE
    ELSE
     CALL echo(build("$(",num,")",par,"=",
       parameter(num,lnum)))
     IF (build(parameter(num,lnum))="")
      SET i_fail = 1
      SET vc_return_message = build(
"Discern Analytics 2.0 document generation failed because organization security is enabled and no organizations were provid\
ed\
")
      GO TO exit_script
     ENDIF
     SET vc_organizations = build(vc_organizations,parameter(num,lnum))
     WHILE (i_orgstart <= size(vc_organizations,1))
       SET i_orgcur = findstring(";",vc_organizations,i_orgstart,0)
       IF (i_orgcur > 0)
        SET vc_organization = substring(i_orgstart,(i_orgcur - i_orgstart),vc_organizations)
        SET i_orgstart = (i_orgcur+ 1)
       ELSE
        SET vc_organization = substring(i_orgstart,((size(vc_organizations,1) - i_orgstart)+ 1),
         vc_organizations)
        SET i_orgstart = (size(vc_organizations,1)+ 1)
       ENDIF
       SET inorgs += 1
       SET stat = alterlist(tmporgs->organization,inorgs)
       SET tmporgs->organization[inorgs].organization_id = cnvtint(vc_organization)
     ENDWHILE
    ENDIF
    SET num = 0
   ENDIF
  ENDWHILE
  SELECT
   org_id = o.organization_id
   FROM organization o
   WHERE expand(num2,1,size(tmporgs->organization,5),o.organization_id,tmporgs->organization[num2].
    organization_id)
   DETAIL
    org_cnt += 1, stat = alterlist(generatebirtdocumentrequest->document[1].organization,org_cnt),
    generatebirtdocumentrequest->document[1].organization[org_cnt].organization_id = org_id
   WITH nocounter
  ;end select
 ELSE
  CALL echo("Org Security disabled so ignoring any organization_ids passed in")
 ENDIF
 SELECT
  cv.cki, cv.code_value
  FROM code_value cv
  WHERE cv.code_set=4002472
   AND cv.cdf_meaning="RPTDOC"
   AND cv.active_ind=1
   AND cv.code_value=i_doctypecodeval
  DETAIL
   vc_doctypecodecki = cv.cki, i_doctypecd = cv.code_value
  WITH nocounter
 ;end select
 IF (((i_doctypecd=uar_get_code_by_cki("CKI.CODEVALUE!4101623642")) OR (i_doctypecd=0)) )
  SET vc_doctypedisplay = "document"
 ELSEIF (vc_doctypecodecki="CKI.CODEVALUE!4101623638")
  SET vc_doctypedisplay = "html"
 ELSEIF (vc_doctypecodecki="CKI.CODEVALUE!4101623639")
  SET vc_doctypedisplay = "pdf"
 ELSEIF (vc_doctypecodecki="CKI.CODEVALUE!4104221604")
  SET vc_doctypedisplay = "ppt"
 ELSEIF (vc_doctypecodecki="CKI.CODEVALUE!4104221603")
  SET vc_doctypedisplay = "xls"
 ELSEIF (vc_doctypecodecki="CKI.CODEVALUE!4101623640")
  SET vc_doctypedisplay = "postscript"
 ELSE
  SET i_fail = 1
  SET vc_return_message =
  "Discern Analytics 2.0 document generation failed because an invalid document type was passed in"
  GO TO exit_script
 ENDIF
 CALL echo(build("vc_report_uuid:",vc_report_uuid," tmpOrgs->size:",size(tmporgs->organization,5),
   " org_cnt:",
   org_cnt,"doctype: ",vc_doctypedisplay))
 IF (size(vc_report_uuid,1) <= 0)
  SET i_fail = 1
  SET vc_return_message =
  "Discern Analytics 2.0 document generation failed because the report was not found"
  GO TO exit_script
 ELSEIF (size(vc_report_design,1) <= 0)
  SET i_fail = 1
  SET vc_return_message =
  "Discern Analytics 2.0 document generation failed because the report design was not found"
  GO TO exit_script
 ELSEIF (org_security_enabled=1
  AND size(tmporgs->organization,5) > 5)
  SET i_fail = 1
  SET vc_return_message =
  "Discern Analytics 2.0 document generation failed because more than 5 organizations where passed in"
  GO TO exit_script
 ELSEIF (org_security_enabled=1
  AND size(tmporgs->organization,5) != org_cnt)
  SET i_fail = 1
  SET vc_return_message =
  "Discern Analytics 2.0 document generation failed because an invalid organization_id was passed in"
  GO TO exit_script
 ENDIF
 IF (size(vc_email_addresses,1) > 0)
  SET i_sentcnt = 0
  SET i_start = 1
  SET i_cur = 0
  SET vc_address = ""
  WHILE (i_start < size(vc_email_addresses,1)
   AND i_sentcnt < 5)
    SET i_cur = findstring(";",vc_email_addresses,i_start,0)
    IF (i_cur > 0)
     SET vc_email_address = substring(i_start,(i_cur - i_start),vc_email_addresses)
     SET i_start = (i_cur+ 1)
    ELSE
     SET vc_email_address = substring(i_start,((size(vc_email_addresses,1) - i_start)+ 1),
      vc_email_addresses)
     SET i_start = size(vc_email_addresses,1)
    ENDIF
    SET i_sentcnt += 1
    SET stat = alterlist(generatebirtdocumentrequest->document[1].email_addresses,i_sentcnt)
    SET generatebirtdocumentrequest->document[1].email_addresses[i_sentcnt].email_address =
    vc_email_address
  ENDWHILE
 ENDIF
 IF (i_fail=0)
  DECLARE app = i4
  DECLARE task = i4
  DECLARE req = i4
  DECLARE happ = i4
  DECLARE htask = i4
  DECLARE hrequest = i4
  DECLARE hreq = i4
  DECLARE hreply = i4
  DECLARE hitem = i4
  DECLARE crmstatus = i4
  SET app = 4600
  SET task = 4801
  SET req = 5009501
  SET happ = 0
  SET htask = 0
  SET hrequest = 0
  SET hreq = 0
  SET hitem = 0
  SET ecrmok = 0
  SET nullvalue = 0
  CALL echo(concat("GENERATE DA2 DOCUMENT --- ",format(cnvtdatetime(sysdate),";;Q")),1,5)
  CALL echo(concat("App: ",build(app)," Task: ",build(task)," Req: ",
    build(req)),1,5)
  SET crmstatus = uar_crmbeginapp(app,happ)
  IF (((crmstatus != ecrmok) OR (happ=0)) )
   SET vc_return_message = "Failed return from uar_crmBeginApp"
   GO TO exit_script
  ELSE
   CALL echo("Good return from CrmBeginApp")
  ENDIF
  SET crmstatus = uar_crmbegintask(happ,task,htask)
  IF (((crmstatus != ecrmok) OR (htask=0)) )
   SET vc_return_message = "Failed return from uar_crmBeginTask"
   SET stat = uar_crmendapp(happ)
   GO TO exit_script
  ELSE
   CALL echo("Good return from CrmBeginTask")
  ENDIF
  SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
  IF (((crmstatus != ecrmok) OR (hreq=0)) )
   SET vc_return_message = concat("Begin request failed with status: ",build(crmstatus))
   SET stat = uar_crmendtask(htask)
   SET stat = uar_crmendapp(happ)
   GO TO exit_script
  ELSE
   CALL echo("Good return from CrmBeginReq")
  ENDIF
  CALL echo("Executing process phase",1,5)
  CALL echo(concat("Request->report_uuid: ",nullterm(vc_report_uuid)," Document Name: ",nullterm(
     vc_docname)," Document Type: ",
    build(i_doctypecd)))
  SET hrequest = uar_crmgetrequest(hreq)
  IF (hrequest=nullvalue)
   SET vc_return_message = concat("Invalid hRequest handle returned from CrmGetRequest")
   SET stat = uar_crmendreq(hreq)
   SET stat = uar_crmendtask(htask)
   SET stat = uar_crmendapp(happ)
   GO TO exit_script
  ELSE
   SET stat = uar_srvsetstring(hrequest,"report_uuid",nullterm(vc_report_uuid))
   IF (stat=nullvalue)
    SET vc_return_message = concat("Unable to set request data for report_uuid")
    SET stat = uar_crmendreq(hreq)
    SET stat = uar_crmendtask(htask)
    SET stat = uar_crmendapp(happ)
    GO TO exit_script
   ENDIF
   SET stat = uar_srvsetstring(hrequest,"document_name",nullterm(vc_docname))
   IF (stat=nullvalue)
    SET vc_return_message = concat("Unable to set request data for document_name")
    SET stat = uar_crmendreq(hreq)
    SET stat = uar_crmendtask(htask)
    SET stat = uar_crmendapp(happ)
    GO TO exit_script
   ENDIF
   SET stat = uar_srvsetdouble(hrequest,"document_type_cd",i_doctypecd)
   IF (stat=nullvalue)
    SET vc_return_message = concat("Unable to set request data for document_type_cd")
    SET stat = uar_crmendreq(hreq)
    SET stat = uar_crmendtask(htask)
    SET stat = uar_crmendapp(happ)
    GO TO exit_script
   ENDIF
   SET xmllength = size(runtimepromptsxml)
   IF (xmllength > 0)
    SET stat = uar_srvsetasis(hrequest,"runtime_prompts_xml",runtimepromptsxml,xmllength)
    IF (stat=nullvalue)
     SET vc_return_message = concat("Unable to set request data for runtime prompts xml")
     SET stat = uar_crmendreq(hreq)
     SET stat = uar_crmendtask(htask)
     SET stat = uar_crmendapp(happ)
     GO TO exit_script
    ELSE
     CALL echo(build("Applying runtime prompts for long_text_reference id=",i_runtimeparams))
    ENDIF
   ELSE
    CALL echo("Not applying any runtime prompts")
   ENDIF
   FOR (p = 1 TO size(generatebirtdocumentrequest->document[1].organization,5) BY 1)
     CALL echo(concat("Request->organization_id: ",cnvtstring(generatebirtdocumentrequest->document[1
        ].organization[p].organization_id)))
     SET hitem = uar_srvadditem(hrequest,"organizations")
     SET stat = uar_srvsetdouble(hitem,"organization_id",generatebirtdocumentrequest->document[1].
      organization[p].organization_id)
     IF (stat=nullvalue)
      SET vc_return_message = concat("Unable to set request data for organizations")
      SET stat = uar_crmendreq(hreq)
      SET stat = uar_crmendtask(htask)
      SET stat = uar_crmendapp(happ)
      GO TO exit_script
     ENDIF
   ENDFOR
   FOR (q = 1 TO size(generatebirtdocumentrequest->document[1].email_addresses,5) BY 1)
     CALL echo(concat("Request->email_address: ",generatebirtdocumentrequest->document[1].
       email_addresses[q].email_address))
     SET hitem = uar_srvadditem(hrequest,"email_addresses")
     SET stat = uar_srvsetstring(hitem,"email_address",nullterm(generatebirtdocumentrequest->
       document[1].email_addresses[q].email_address))
     IF (stat=nullvalue)
      SET vc_return_message = concat("Unable to set request data for e-mail addresses")
      SET stat = uar_crmendreq(hreq)
      SET stat = uar_crmendtask(htask)
      SET stat = uar_crmendapp(happ)
      GO TO exit_script
     ENDIF
   ENDFOR
  ENDIF
  CALL echo(concat("**** Begin perform request #",cnvtstring(req)," -GenerateBirtDocument @",format(
     curdate,"dd-mmm-yyyy;;d")," ",
    format(curtime3,"hh:mm:ss.cc;3;m")))
  SET crmstatus = uar_crmperform(hreq)
  CALL echo(concat("**** End perform request #",cnvtstring(req)," -GenerateBirtDocument @",format(
     curdate,"dd-mmm-yyyy;;d")," ",
    format(curtime3,"hh:mm:ss.cc;3;m")))
  IF (crmstatus != ecrmok)
   SET vc_return_message = concat("Invalid CrmPerform return status of ",cnvtstring(crmstatus))
   SET stat = uar_crmendreq(hreq)
   SET stat = uar_crmendtask(htask)
   SET stat = uar_crmendapp(happ)
   GO TO exit_script
  ELSE
   CALL echo(concat("Process successful. "),1,5)
   SET hreply = uar_crmgetreply(hreq)
   IF (hreply=nullvalue)
    SET vc_return_message = concat("Error in CrmGetReply, invalid handle returned.")
    SET stat = uar_crmendreq(hreq)
    SET stat = uar_crmendtask(htask)
    SET stat = uar_crmendapp(happ)
    GO TO exit_script
   ELSE
    CALL echo("Retrieving reply message...")
    SET generatebirtdocumentreply->web_service_path = uar_srvgetstringptr(hreply,"web_service_path")
    IF (substring(size(generatebirtdocumentreply->web_service_path,1),1,generatebirtdocumentreply->
     web_service_path) != "/")
     SET web_service_path = concat(generatebirtdocumentreply->web_service_path,"/")
     SET generatebirtdocumentreply->web_service_path = web_service_path
    ENDIF
    SET htransstat = uar_srvgetstruct(hreply,"transaction_status")
    IF (htransstat=null)
     SET vc_return_message = concat(
      "Error in CrmGetReply, invalid transaction_status handle returned.")
     SET stat = uar_crmendreq(hreq)
     SET stat = uar_crmendtask(htask)
     SET stat = uar_crmendapp(happ)
     GO TO exit_script
    ELSE
     SET generatebirtdocumentreply->transaction_status.success_ind = uar_srvgetshort(htransstat,
      "success_ind")
     SET generatebirtdocumentreply->transaction_status.debug_error_message = uar_srvgetstringptr(
      htransstat,"debug_error_message")
    ENDIF
    SET hsuccdoc = uar_srvgetstruct(hreply,"successful_document")
    IF (hsuccdoc=null)
     SET vc_return_message = concat(
      "Error in CrmGetReply, invalid successful_document handle returned.")
     SET stat = uar_crmendreq(hreq)
     SET stat = uar_crmendtask(htask)
     SET stat = uar_crmendapp(happ)
     GO TO exit_script
    ELSE
     SET generatebirtdocumentreply->successful_document.da_document_id = uar_srvgetdouble(hsuccdoc,
      "da_document_id")
    ENDIF
   ENDIF
  ENDIF
  CALL echo(concat(format(cnvtdatetime(sysdate),";;Q")),1,5)
  CALL echo(concat("Document Id is ",build(generatebirtdocumentreply->successful_document.
     da_document_id)))
  CALL echo(concat("Status from task server call is ",build(generatebirtdocumentreply->
     transaction_status.success_ind)))
  CALL echo(concat("Debug Error Message is: ",generatebirtdocumentreply->transaction_status.
    debug_error_message))
  CALL echo(concat("Web Service Path is: ",generatebirtdocumentreply->web_service_path))
  IF ((generatebirtdocumentreply->transaction_status.success_ind=0))
   SET vc_return_message = generatebirtdocumentreply->transaction_status.debug_error_message
  ENDIF
 ENDIF
#exit_script
 IF (i_fail=0
  AND (generatebirtdocumentreply->transaction_status.success_ind=1))
  SET trans_msg = uar_i18ngetmessage(i18nhandle,"KeyGet0",
   "Successfully generated Discern Analytics 2.0 document with da_document_id = ")
  SET msg = concat(trans_msg,build(generatebirtdocumentreply->successful_document.da_document_id))
  SET reply->status_data.status = "S"
  SET reply->ops_event = msg
  SELECT INTO "nl:"
   d.da_document_id, r.report_uuid, r.report_name,
   d.generated_dt_tm, d.valid_until_dt_tm, d.document_name
   FROM da_document d,
    da_report r
   PLAN (d
    WHERE (d.da_document_id=generatebirtdocumentreply->successful_document.da_document_id))
    JOIN (r
    WHERE d.da_report_id=r.da_report_id)
   DETAIL
    vc_doclink_txt = concat(r.report_name," - ",format(d.generated_dt_tm,";;Q"))
   WITH nocounter, separator = " ", format
  ;end select
  SET ph = replace(ph,"&&&",generatebirtdocumentreply->web_service_path,0)
  SET ph = replace(ph,"@@@",vc_report_uuid,0)
  SET ph = replace(ph,"###",build(cnvtint(generatebirtdocumentreply->successful_document.
     da_document_id)),0)
  SET ph = replace(ph,"+++",trim(curdomain),0)
  SET ph = replace(ph,"%%%",vc_doclink_txt,0)
  SET ph = replace(ph,"^^^",vc_doctypedisplay,0)
  SET doclink = replace(doclink,"&&&",generatebirtdocumentreply->web_service_path,0)
  SET doclink = replace(doclink,"@@@",vc_report_uuid,0)
  SET doclink = replace(doclink,"###",build(cnvtint(generatebirtdocumentreply->successful_document.
     da_document_id)),0)
  SET doclink = replace(doclink,"+++",trim(curdomain),0)
  SET doclink = replace(doclink,"^^^",vc_doctypedisplay,0)
  SET _memory_reply_string = ph
 ELSE
  CALL echo(vc_return_message)
  SET trans_msg = uar_i18ngetmessage(i18nhandle,"KeyGet0",
   "Failed to generate Discern Analytics 2.0 document with error message")
  SET msg = concat(trans_msg," ",char(34),vc_return_message,char(34),
   char(10),char(10))
  SET reply->ops_event = msg
  SET vc_email_subject = uar_i18ngetmessage(i18nhandle,"KeyGet9",
   "Discern Analytics 2.0 document failed to generate")
  SET vc_email_msg = msg
  IF (size(vc_report_uuid,1) > 0)
   SET trans_msg = uar_i18ngetmessage(i18nhandle,"KeyGet10","Report UUID:")
   SET msg = concat(trans_msg," ",vc_report_uuid,char(10),char(10))
   SET vc_email_msg = concat(vc_email_msg,msg)
  ENDIF
  SET trans_msg = uar_i18ngetmessage(i18nhandle,"KeyGet11","Domain:")
  SET msg = concat(trans_msg," ",curdomain,char(10),char(10))
  SET vc_email_msg = concat(vc_email_msg,msg)
  SELECT INTO  $OUTDEV
   error = reply->ops_event
   FROM dummyt
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
END GO
