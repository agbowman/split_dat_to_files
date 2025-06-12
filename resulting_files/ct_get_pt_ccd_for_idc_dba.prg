CREATE PROGRAM ct_get_pt_ccd_for_idc:dba
 RECORD ccd_service_request(
   1 person_id = f8
   1 encntr_id = f8
   1 report_template_id = f8
   1 archive_ind = i2
   1 provider_patient_reltn_cd = f8
   1 authorization_mode = i2
   1 begin_qual_date = dq8
   1 end_qual_date = dq8
 )
 RECORD ccd_service_reply(
   1 document = gvc
   1 handle = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ct_get_pref_request(
   1 pref_entry = vc
 )
 RECORD ct_get_pref_reply(
   1 pref_value = i4
   1 pref_values[*]
     2 values = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 DECLARE appid = i4 WITH protect, constant(3202004)
 DECLARE taskid = i4 WITH protect, constant(3202004)
 DECLARE reqid = i4 WITH protect, constant(1370052)
 DECLARE curr_date_time = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE begin_date_time = dq8 WITH protect
 DECLARE document_size = i4 WITH protect, noconstant(0)
 DECLARE document_status = c1 WITH protect, noconstant("")
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE status_cnt = i2 WITH protect, noconstant(0)
 DECLARE status_flag = c1 WITH protect, noconstant("S")
 DECLARE status_issue = vc WITH protect, noconstant("")
 DECLARE holdme = vc WITH protect
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hitem = i4 WITH protect, noconstant(0)
 DECLARE hrep = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 DECLARE hlist = i4 WITH protect, noconstant(0)
 DECLARE day_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"DAY"))
 DECLARE month_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"MONTH"))
 DECLARE year_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"YEAR"))
 DECLARE tmpconmed = vc WITH protect, noconstant("")
 DECLARE conmeddttm = dq8 WITH protect
 DECLARE tmpcondition = vc WITH protect, noconstant("")
 DECLARE conditiondttm = dq8 WITH protect
 DECLARE meddaydiff = i2 WITH protect, noconstant(0)
 DECLARE conddaydiff = i2 WITH protect, noconstant(0)
 SET ccd_service_request->person_id = request->person[1].person_id
 SET ct_get_pref_request->pref_entry = "idc_ccd_template"
 EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","CT_GET_PREF_REQUEST"), replace("REPLY",
  "CT_GET_PREF_REPLY")
 SET ccd_service_request->report_template_id = ct_get_pref_reply->pref_value
 SELECT INTO "nl"
  t.report_template_id
  FROM cr_report_template t
  WHERE (t.report_template_id=ccd_service_request->report_template_id)
 ;end select
 IF (curqual > 0
  AND (ccd_service_request->report_template_id != 0))
  CALL echo(build("Template id: ",ccd_service_request->report_template_id))
 ELSE
  SET status_issue = build("Invalid template id: ",ccd_service_request->report_template_id,
   " No further qualification.")
  SET status_flag = "Z"
  GO TO exit_script
 ENDIF
 CALL echorecord(ccd_service_request)
 IF ((request->con_med_unit_cd=month_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",M")
  SET conmeddttm = cnvtlookbehind(tmpconmed,curr_date_time)
 ELSEIF ((request->con_med_unit_cd=year_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",Y")
  SET conmeddttm = cnvtlookbehind(tmpconmed,curr_date_time)
 ELSEIF ((request->con_med_unit_cd=day_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",D")
  SET conmeddttm = cnvtlookbehind(tmpconmed,curr_date_time)
 ELSE
  SET conmeddttm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF (conmeddttm > 0)
  SET conmeddttm = datetimefind(conmeddttm,"D","E","B")
 ENDIF
 IF ((request->condition_unit_cd=month_cd))
  SET tmpcondition = concat(cnvtstring(request->condition_time),",M")
  SET conditiondttm = cnvtlookbehind(tmpcondition,curr_date_time)
 ELSEIF ((request->condition_unit_cd=year_cd))
  CALL echo("CONDITION IS YEAR YEAR YEAR")
  SET tmpcondition = concat(cnvtstring(request->condition_time),",Y")
  SET conditiondttm = cnvtlookbehind(tmpcondition,curr_date_time)
 ELSEIF ((request->condition_unit_cd=day_cd))
  SET tmpcondition = concat(cnvtstring(request->condition_time),",D")
  SET conditiondttm = cnvtlookbehind(tmpcondition,curr_date_time)
 ELSE
  SET conditiondttm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF (conditiondttm > 0)
  SET conditiondttm = datetimefind(conditiondttm,"D","E","B")
 ENDIF
 SET meddaydiff = datetimediff(curr_date_time,conmeddttm)
 SET conddaydiff = datetimediff(curr_date_time,conditiondttm)
 IF (meddaydiff > conddaydiff)
  SET begin_date_time = conmeddttm
 ELSE
  SET begin_date_time = conditiondttm
 ENDIF
 SET iret = uar_crmbeginapp(appid,happ)
 IF (iret=0)
  SET iret = uar_crmbegintask(happ,taskid,htask)
  IF (iret=0)
   SET iret = uar_crmbeginreq(htask,"",reqid,hstep)
   IF (iret=0)
    SET hreq = uar_crmgetrequest(hstep)
    CALL uar_srvsetdouble(hreq,"person_id",ccd_service_request->person_id)
    CALL uar_srvsetdouble(hreq,"report_template_id",ccd_service_request->report_template_id)
    CALL uar_srvsetshort(hreq,"authorization_mode",1)
    CALL uar_srvsetdate(hreq,"begin_qual_date",begin_date_time)
    CALL uar_srvsetdate(hreq,"end_qual_date",curr_date_time)
    SET iret = uar_crmperform(hstep)
    IF (iret != 0)
     SET status_flag = "F"
     SET status_issue = build("CRM perform failed:",build(iret))
     GO TO exit_script
    ELSE
     SET hrep = uar_crmgetreply(hstep)
     SET hstatus = uar_srvgetstruct(hrep,"status_data")
     SET document_status = trim(uar_srvgetstringptr(hstatus,"status"))
     IF (document_status="S")
      SET document_size = uar_srvgetasissize(hrep,"document")
      CALL echo(build("document_size is :",document_size))
      IF (document_size > 0)
       SET holdme = ""
       SET _stat = memrealloc(holdme,1,build("C",document_size))
       SET holdme = notrim(uar_srvgetasisptr(hrep,"document"))
       SET ccd_service_reply->document = notrim(holdme)
       CALL echo(ccd_service_reply->document)
      ELSE
       SET status_flag = "Z"
       SET status_issue = build("Document size is 0.")
       GO TO exit_script
      ENDIF
     ELSE
      CALL echo(build("Status is: ",document_status))
      SET status_cnt = uar_srvgetitemcount(hstatus,"subeventstatus")
      FOR (idx = 1 TO status_cnt)
        SET hlist = uar_srvgetitem(hstatus,"subeventstatus",idx)
        CALL echo(build("OperationName:_",uar_srvgetstring(hlist,"OperationStatus","",0)))
        CALL echo(build("TargetObjectName:_",uar_srvgetstring(hlist,"TargetObjectName","",0)))
        CALL echo(build("TargetObjectValue:_",uar_srvgetstring(hlist,"TargetObjectValue","",0)))
        SET status_flag = document_status
        SET status_issue = build(uar_srvgetstring(hlist,"TargetObjectValue","",0))
        GO TO exit_script
      ENDFOR
     ENDIF
    ENDIF
   ELSE
    SET status_flag = "F"
    SET status_issue = concat("Begin task unsuccessful: ",build(iret))
    GO TO exit_script
   ENDIF
  ELSE
   SET status_flag = "F"
   SET status_issue = concat("Unsuccessful begin task: ",build(iret))
   GO TO exit_script
  ENDIF
 ELSE
  SET status_flag = "F"
  SET status_issue = concat("Begin app failed with code: ",build(iret))
  GO TO exit_script
 ENDIF
#exit_script
 IF (status_flag="S")
  SET reply->status_data.status = status_flag
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = status_flag
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  SET reply->text = ccd_service_reply->document
  SET reply->text_type = "CCD"
 ELSE
  CALL echo(status_issue)
  SET reply->status_data.status = status_flag
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = status_flag
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = status_issue
 ENDIF
 CALL echo("Cleaning up handles...")
 IF (hstep > 0)
  CALL uar_crmendreq(hstep)
 ENDIF
 IF (htask > 0)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (happ > 0)
  CALL uar_crmendapp(happ)
 ENDIF
 SET last_mod = "000"
 SET mod_date = "December 10, 2009"
END GO
