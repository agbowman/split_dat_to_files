CREATE PROGRAM bsc_upd_immun_info:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 FREE RECORD rep_status
 RECORD rep_status(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE retval = i2 WITH protect, noconstant(0)
 DECLARE app_number = i4 WITH protect, noconstant(0)
 DECLARE app_handle = i4 WITH protect, noconstant(0)
 DECLARE task_number = i4 WITH protect, noconstant(0)
 DECLARE task_handle = i4 WITH protect, noconstant(0)
 DECLARE req_number = i4 WITH protect, noconstant(0)
 DECLARE req_handle = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hitem = i4 WITH protect, noconstant(0)
 DECLARE hitem1 = i4 WITH protect, noconstant(0)
 DECLARE hitem2 = i4 WITH protect, noconstant(0)
 DECLARE hstructitem = i4 WITH protect, noconstant(0)
 DECLARE istat = i4 WITH protect, noconstant(0)
 DECLARE lcount = i4 WITH protect, noconstant(0)
 DECLARE lcount2 = i4 WITH protect, noconstant(0)
 DECLARE eventid = f8 WITH protect, noconstant(0.0)
 DECLARE event_cd = f8 WITH protect, noconstant(0.0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 SET app_number = 600005
 SET app_handle = 0
 SET task_number = 600907
 SET task_handle = 0
 SET req_handle = 0
 SET hreq = 0
 SET hitem = 0
 SET hitem1 = 0
 SET hitem2 = 0
 DECLARE seteventidforimmunization(null) = i2
 DECLARE addimmunizations(null) = null
 DECLARE chartvaccinenotgiven(null) = null
 DECLARE updateimmunizations(null) = null
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
 IF ((request->modify_ind=0))
  SET retval = seteventidforimmunization(null)
  IF (retval=1)
   CALL endexecution(0,"SetEventIdForImmunization failed",build(
     "Failed to get event id as severity code is ",validate(event_rep->sb.severitycd,0)))
  ELSEIF (retval=2)
   CALL endexecution(0,"SetEventIdForImmunization failed",build(
     "Failed to get event id for reference number ",request->reference_nbr))
  ENDIF
  IF ((request->notgiven_ind=0))
   CALL addimmunizations(null)
  ELSE
   CALL chartvaccinenotgiven(null)
  ENDIF
 ELSE
  CALL updateimmunizations(null)
 ENDIF
 IF (debug_ind > 0)
  CALL echo(build("status: ",reply->status_data.status))
 ENDIF
 SUBROUTINE seteventidforimmunization(null)
   DECLARE found_value = i2 WITH noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE ivacccount = i4 WITH noconstant(0)
   DECLARE inotgivencount = i4 WITH noconstant(0)
   DECLARE icount = i4 WITH noconstant(0)
   IF (validate(event_rep,0))
    IF (debug_ind > 0)
     CALL echo("********Setting Event id for immunization********")
    ENDIF
    IF ((event_rep->sb.severitycd > 2))
     RETURN(1)
    ENDIF
    SET icount = size(event_rep->rb_list,5)
    FOR (i = 1 TO icount)
      IF (found_value=0
       AND (event_rep->rb_list[i].reference_nbr=request->reference_nbr))
       SET eventid = event_rep->rb_list[i].event_id
       SET event_cd = event_rep->rb_list[i].event_cd
       SET found_value = 1
      ENDIF
    ENDFOR
    SET ivacccount = size(request->vaccinations_to_chart,5)
    SET inotgivencount = size(request->vaccinations_not_given,5)
    IF (found_value=1
     AND ivacccount > 0)
     FOR (j = 1 TO ivacccount)
      SET request->vaccinations_to_chart[j].clinical_event_id = eventid
      RETURN(0)
     ENDFOR
    ELSEIF (found_value=1
     AND inotgivencount > 0)
     RETURN(0)
    ELSE
     IF (debug_ind > 0)
      CALL echo("********Failed to retrieve Event id for immunization********")
     ENDIF
     RETURN(2)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addimmunizations(null)
   IF (debug_ind > 0)
    CALL echo("********Call to Add Immunization service********")
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   SET req_number = 966920
   SET istat = uar_crmbeginapp(app_number,app_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the application",build("uar_crm_begin_app failed ",istat,"."))
   ENDIF
   SET istat = uar_crmbegintask(app_handle,task_number,task_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the task",build("uar_crm_begin_task failed ",istat,"."))
   ENDIF
   SET istat = uar_crmbeginreq(task_handle,"",req_number,req_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the request",build("uar_crm_begin_req failed ",istat,"."))
   ENDIF
   SET hreq = uar_crmgetrequest(req_handle)
   IF (hreq=0)
    CALL endexecution(0,"Get request handle",build("Failed to get request handle to ",req_number,".")
     )
   ENDIF
   SET istat = uar_srvsetdouble(hreq,"person_id",request->person_id)
   SET istat = uar_srvsetdouble(hreq,"organization_id",request->organization_id)
   SET lcount = size(request->vaccinations_to_chart,5)
   IF (lcount > 0)
    FOR (i = 1 TO lcount)
     SET hitem = uar_srvadditem(hreq,"vaccinations")
     IF (hitem > 0)
      SET hstructitem = uar_srvgetstruct(hitem,"vaccine")
      SET istat = uar_srvsetdouble(hstructitem,"event_cd",request->vaccinations_to_chart[i].vaccine.
       event_cd)
      SET istat = uar_srvsetdouble(hitem,"event_id",request->vaccinations_to_chart[i].
       clinical_event_id)
      SET istat = uar_srvsetdouble(hitem,"vfc_status_cd",request->vaccinations_to_chart[i].
       vfc_status_cd)
      SET lcount2 = size(request->vaccinations_to_chart[i].information_statements_given,5)
      FOR (j = 1 TO lcount2)
        SET hitem2 = uar_srvadditem(hitem,"information_statements_given")
        SET istat = uar_srvsetdouble(hitem2,"vis_cd",request->vaccinations_to_chart[i].
         information_statements_given[j].vis_cd)
        SET istat = uar_srvsetdate(hitem2,"given_on_dt_tm",cnvtdatetime(request->
          vaccinations_to_chart[i].information_statements_given[j].given_on_dt_tm))
        SET istat = uar_srvsetdate(hitem2,"published_dt_tm",cnvtdatetime(request->
          vaccinations_to_chart[i].information_statements_given[j].published_dt_tm))
      ENDFOR
      SET istat = uar_srvsetdouble(hitem,"funding_source_cd",request->vaccinations_to_chart[i].
       funding_source_cd)
      SET istat = uar_srvsetshort(hitem,"default_event_ind",request->vaccinations_to_chart[i].
       default_event_ind)
     ENDIF
    ENDFOR
   ENDIF
   IF (debug_ind > 0)
    CALL echorecord(request)
   ENDIF
   SET istat = uar_crmperform(req_handle)
   IF (debug_ind > 0)
    CALL echo(build("CRM Perform, req_handle:",req_handle))
    CALL echo(build("CRM Perform, Status:",istat))
   ENDIF
   SET hreply = uar_crmgetreply(req_handle)
   SET hstatusdata = uar_srvgetstruct(hreply,"status_data")
   IF (hstatusdata=0)
    CALL endexecution(0,"Status Data",build("Status data returned false,  ",req_number,"."))
   ELSE
    SET rep_status->status_data.status = uar_srvgetstringptr(hstatusdata,"status")
    IF (uar_srvgetstringptr(hstatusdata,"status")="F")
     IF (debug_ind > 0)
      CALL echo(build("hStatusData returned failure:",rep_status->status_data.status))
     ENDIF
     SET hsubeventstatus = uar_srvgetitem(hstatusdata,"subeventstatus",1)
     SET rep_status->status_data.subeventstatus[1].operationname = uar_srvgetstringptr(
      hsubeventstatus,"OperationName")
     SET rep_status->status_data.subeventstatus[1].operationstatus = uar_srvgetstringptr(
      hsubeventstatus,"OperationStatus")
     SET rep_status->status_data.subeventstatus[1].targetobjectname = uar_srvgetstringptr(
      hsubeventstatus,"TargetObjectName")
     SET rep_status->status_data.subeventstatus[1].targetobjectvalue = uar_srvgetstringptr(
      hsubeventstatus,"TargetObjectValue")
     IF (debug_ind > 0)
      CALL echorecord(rep_status)
     ENDIF
     CALL endexecution(0,rep_status->status_data.subeventstatus[1].targetobjectname,rep_status->
      status_data.subeventstatus[1].targetobjectvalue)
    ELSE
     CALL uar_crmendreq(req_handle)
     CALL uar_crmendtask(task_handle)
     CALL uar_crmendapp(app_handle)
     IF (debug_ind > 0)
      CALL echo("********Exiting AddImmunizations********")
     ENDIF
     CALL endexecution(1,"AddImmunizations",build("Call to AddImmunization service succeeded ",
       req_number,"."))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updateimmunizations(null)
   IF (debug_ind > 0)
    CALL echo("********Call to Update Immunization service********")
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   SET req_number = 966921
   SET istat = uar_crmbeginapp(app_number,app_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the application",build("uar_crm_begin_app failed ",istat,"."))
   ENDIF
   SET istat = uar_crmbegintask(app_handle,task_number,task_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the task",build("uar_crm_begin_task failed ",istat,"."))
   ENDIF
   SET istat = uar_crmbeginreq(task_handle,"",req_number,req_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the request",build("uar_crm_begin_req failed ",istat,"."))
   ENDIF
   SET hreq = uar_crmgetrequest(req_handle)
   IF (hreq=0)
    CALL endexecution(0,"Get request handle",build("Failed to get request handle to ",req_number,".")
     )
   ENDIF
   SET lcount = size(request->vaccinations_to_chart,5)
   IF (lcount > 0)
    FOR (i = 1 TO lcount)
     SET hitem = uar_srvadditem(hreq,"vaccinations")
     IF (hitem > 0)
      SET istat = uar_srvsetdouble(hitem,"event_id",request->vaccinations_to_chart[i].
       clinical_event_id)
      SET istat = uar_srvsetdouble(hitem,"vfc_status_cd",request->vaccinations_to_chart[i].
       vfc_status_cd)
      SET lcount2 = size(request->vaccinations_to_chart[i].information_statements_given,5)
      FOR (j = 1 TO lcount2)
        SET hitem2 = uar_srvadditem(hitem,"information_statements_given")
        SET istat = uar_srvsetdouble(hitem2,"vis_cd",request->vaccinations_to_chart[i].
         information_statements_given[j].vis_cd)
        SET istat = uar_srvsetdate(hitem2,"given_on_dt_tm",cnvtdatetime(request->
          vaccinations_to_chart[i].information_statements_given[j].given_on_dt_tm))
        SET istat = uar_srvsetdate(hitem2,"published_dt_tm",cnvtdatetime(request->
          vaccinations_to_chart[i].information_statements_given[j].published_dt_tm))
      ENDFOR
      SET istat = uar_srvsetdouble(hitem,"funding_source_cd",request->vaccinations_to_chart[i].
       funding_source_cd)
      SET istat = uar_srvsetshort(hitem,"default_event_ind",request->vaccinations_to_chart[i].
       default_event_ind)
      SET istat = uar_srvsetdouble(hitem,"person_id",request->person_id)
      SET istat = uar_srvsetdouble(hitem,"organization_id",request->organization_id)
     ENDIF
    ENDFOR
   ENDIF
   IF (debug_ind > 0)
    CALL echorecord(request)
   ENDIF
   SET istat = uar_crmperform(req_handle)
   IF (debug_ind > 0)
    CALL echo(build("CRM Perform, req_handle:",req_handle))
    CALL echo(build("CRM Perform, Status:",istat))
   ENDIF
   SET hreply = uar_crmgetreply(req_handle)
   SET hstatusdata = uar_srvgetstruct(hreply,"status_data")
   IF (hstatusdata=0)
    CALL endexecution(0,"Status Data",build("Status data returned false ",req_number,"."))
   ELSE
    SET rep_status->status_data.status = uar_srvgetstringptr(hstatusdata,"status")
    IF (uar_srvgetstringptr(hstatusdata,"status")="F")
     IF (debug_ind > 0)
      CALL echo(build("hStatusData returned failure:",rep_status->status_data.status))
     ENDIF
     SET hsubeventstatus = uar_srvgetitem(hstatusdata,"subeventstatus",1)
     SET rep_status->status_data.subeventstatus[1].operationname = uar_srvgetstringptr(
      hsubeventstatus,"OperationName")
     SET rep_status->status_data.subeventstatus[1].operationstatus = uar_srvgetstringptr(
      hsubeventstatus,"OperationStatus")
     SET rep_status->status_data.subeventstatus[1].targetobjectname = uar_srvgetstringptr(
      hsubeventstatus,"TargetObjectName")
     SET rep_status->status_data.subeventstatus[1].targetobjectvalue = uar_srvgetstringptr(
      hsubeventstatus,"TargetObjectValue")
     IF (debug_ind > 0)
      CALL echorecord(rep_status)
     ENDIF
     CALL endexecution(0,rep_status->status_data.subeventstatus[1].targetobjectname,rep_status->
      status_data.subeventstatus[1].targetobjectvalue)
    ELSE
     CALL uar_crmendreq(req_handle)
     CALL uar_crmendtask(task_handle)
     CALL uar_crmendapp(app_handle)
     IF (debug_ind > 0)
      CALL echo("********Exiting UpdateImmunizations********")
     ENDIF
     CALL endexecution(1,"UpdateImmunizations",build("Call to UpdateImmunization service succeeded ",
       req_number,"."))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chartvaccinenotgiven(null)
   IF (debug_ind > 0)
    CALL echo("********Call to ChartVaccinationsNotGiven Immunization service********")
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   SET req_number = 966922
   SET istat = uar_crmbeginapp(app_number,app_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the application",build("uar_crm_begin_app failed ",istat,"."))
   ENDIF
   SET istat = uar_crmbegintask(app_handle,task_number,task_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the task",build("uar_crm_begin_task failed ",istat,"."))
   ENDIF
   SET istat = uar_crmbeginreq(task_handle,"",req_number,req_handle)
   IF (istat != 0)
    CALL endexecution(0,"Begin the request",build("uar_crm_begin_req failed ",istat,"."))
   ENDIF
   SET hreq = uar_crmgetrequest(req_handle)
   IF (hreq=0)
    CALL endexecution(0,"Get request handle",build("Failed to get request handle to ",req_number,".")
     )
   ENDIF
   SET istat = uar_srvsetdouble(hreq,"person_id",request->person_id)
   SET istat = uar_srvsetdouble(hreq,"organization_id",request->organization_id)
   SET lcount = size(request->vaccinations_not_given,5)
   FOR (i = 1 TO lcount)
    SET hitem = uar_srvadditem(hreq,"vaccines_not_given")
    IF (hitem > 0)
     SET hstructitem = uar_srvgetstruct(hitem,"vaccine")
     SET istat = uar_srvsetdouble(hstructitem,"event_cd",event_cd)
     SET istat = uar_srvsetdouble(hitem,"event_id",eventid)
     SET istat = uar_srvsetdate(hitem,"charted_dt_tm",cnvtdatetime(request->vaccinations_not_given[i]
       .charted_dt_tm))
     SET istat = uar_srvsetdouble(hitem,"charted_personnel_id",request->vaccinations_not_given[i].
      charted_personnel_id)
     SET istat = uar_srvsetdouble(hitem,"reason_cd",request->vaccinations_not_given[i].reason_cd)
     SET istat = uar_srvsetstring(hitem,"comment",request->vaccinations_not_given[i].comment)
    ENDIF
   ENDFOR
   IF (debug_ind > 0)
    CALL echorecord(request)
   ENDIF
   SET istat = uar_crmperform(req_handle)
   IF (debug_ind > 0)
    CALL echo(build("CRM Perform, req_handle:",req_handle))
    CALL echo(build("CRM Perform, Status:",istat))
   ENDIF
   SET hreply = uar_crmgetreply(req_handle)
   SET hstatusdata = uar_srvgetstruct(hreply,"status_data")
   IF (hstatusdata=0)
    CALL endexecution(0,"Status Data",build("Status data returned false,  ",req_number,"."))
   ELSE
    SET rep_status->status_data.status = uar_srvgetstringptr(hstatusdata,"status")
    IF (uar_srvgetstringptr(hstatusdata,"status")="F")
     IF (debug_ind > 0)
      CALL echo(build("hStatusData returned failure:",rep_status->status_data.status))
     ENDIF
     SET hsubeventstatus = uar_srvgetitem(hstatusdata,"subeventstatus",1)
     SET rep_status->status_data.subeventstatus[1].operationname = uar_srvgetstringptr(
      hsubeventstatus,"OperationName")
     SET rep_status->status_data.subeventstatus[1].operationstatus = uar_srvgetstringptr(
      hsubeventstatus,"OperationStatus")
     SET rep_status->status_data.subeventstatus[1].targetobjectname = uar_srvgetstringptr(
      hsubeventstatus,"TargetObjectName")
     SET rep_status->status_data.subeventstatus[1].targetobjectvalue = uar_srvgetstringptr(
      hsubeventstatus,"TargetObjectValue")
     IF (debug_ind > 0)
      CALL echorecord(rep_status)
     ENDIF
     CALL endexecution(0,rep_status->status_data.subeventstatus[1].targetobjectname,rep_status->
      status_data.subeventstatus[1].targetobjectvalue)
    ELSE
     CALL uar_crmendreq(req_handle)
     CALL uar_crmendtask(task_handle)
     CALL uar_crmendapp(app_handle)
     IF (debug_ind > 0)
      CALL echo("********Exiting ChartVaccineNotGiven********")
     ENDIF
     CALL endexecution(1,"ChartVaccineNotGiven",build(
       "Call to ChartVaccineNotGiven service succeeded ",req_number,"."))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (endexecution(bscriptstatus=i2,stargetobjectname=vc,stargetobjectvalue=vc) =null)
   IF (debug_ind > 0)
    CALL echo("*************In End Execution***************")
   ENDIF
   IF (bscriptstatus > 0)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = 1
   ELSE
    SET reply->status_data.status = "F"
    SET reqinfo->commit_ind = 0
   ENDIF
   SET reply->status_data.subeventstatus.targetobjectname = stargetobjectname
   SET reply->status_data.subeventstatus.targetobjectvalue = stargetobjectvalue
   IF (debug_ind > 0)
    CALL echo(build("********Script Message: ",stargetobjectvalue))
   ENDIF
 END ;Subroutine
END GO
