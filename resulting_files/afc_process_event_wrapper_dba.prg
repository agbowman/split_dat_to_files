CREATE PROGRAM afc_process_event_wrapper:dba
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
 SET reply->status_data.status = "F"
 DECLARE lhapp = i4 WITH noconstant(0)
 DECLARE lhtask = i4 WITH noconstant(0)
 DECLARE lhreq = i4 WITH noconstant(0)
 DECLARE lhrequest = i4 WITH noconstant(0)
 DECLARE lhprocesseventitem = i4 WITH noconstant(0)
 DECLARE lhchargeactitem = i4 WITH noconstant(0)
 DECLARE lhchargeitem = i4 WITH noconstant(0)
 DECLARE lprocesseventcount = i4 WITH noconstant(0)
 DECLARE lnumberofsetprocessevents = i4 WITH noconstant(0)
 DECLARE lnumberofprocesseventfailures = i4 WITH noconstant(0)
 DECLARE lchargeactcount = i4 WITH noconstant(0)
 DECLARE lnumberofsetchargeacts = i4 WITH noconstant(0)
 DECLARE lnumberofchargeactfailures = i4 WITH noconstant(0)
 DECLARE lchargeitemcount = i4 WITH noconstant(0)
 DECLARE lnumberofsetchargeitems = i4 WITH noconstant(0)
 DECLARE lnumberofchargeitemfailures = i4 WITH noconstant(0)
 DECLARE lstatus = i4 WITH noconstant(0)
 CALL uar_crmbeginapp(5000,lhapp)
 IF (lhapp <= 0)
  EXECUTE pft_log "afc_process_event_wrapper", build("Failure::lhApp Returned = ",lhapp), 0
  GO TO exitscript
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("Begin App = ",lhapp))
 CALL uar_crmbegintask(lhapp,951023,lhtask)
 IF (lhapp <= 0)
  EXECUTE pft_log "afc_process_event_wrapper", build("Failure::lhTask Returned = ",lhtask), 0
  GO TO exitscript
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("Begin Task = ",lhtask))
 CALL uar_crmbeginreq(lhtask,"cs_srvasync.cs_processevent",951021,lhreq)
 IF (lhreq <= 0)
  EXECUTE pft_log "afc_process_event_wrapper", build("Failure::lhReq Returned = ",lhreq), 0
  GO TO exitscript
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("Begin Req = ",lhreq))
 SET lhrequest = uar_crmgetrequest(lhreq)
 IF (lhrequest <= 0)
  EXECUTE pft_log "afc_process_event_wrapper", build("Failure::lhRequest Returned = ",lhrequest), 0
  GO TO exitscript
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("Get Req Struct = ",lhrequest))
 CALL uar_srvsetdouble(lhrequest,"process_type_cd",request->process_type_cd)
 CALL uar_srvsetshort(lhrequest,"charge_event_qual",request->charge_event_qual)
 FOR (lprocesseventcount = 1 TO size(request->process_event,5))
  SET lhprocesseventitem = uar_srvadditem(lhrequest,"process_event")
  IF (lhprocesseventitem > 0)
   CALL uar_srvsetdouble(lhprocesseventitem,"charge_event_id",request->process_event[
    lprocesseventcount].charge_event_id)
   SET lnumberofsetprocessevents = (lnumberofsetprocessevents+ 1)
   FOR (lchargeactcount = 1 TO size(request->process_event[lprocesseventcount].charge_acts,5))
    SET lhchargeactitem = uar_srvadditem(lhprocesseventitem,"charge_acts")
    IF (lhchargeactitem > 0)
     CALL uar_srvsetdouble(lhchargeactitem,"charge_event_act_id",request->process_event[
      lprocesseventcount].charge_acts[lchargeactcount].charge_event_act_id)
     CALL uar_srvsetshort(lhchargeactitem,"charge_item_qual",request->process_event[
      lprocesseventcount].charge_acts[lchargeactcount].charge_item_qual)
     SET lnumberofsetchargeacts = (lnumberofsetchargeacts+ 1)
    ELSE
     SET lnumberofchargeactfailures = (lnumberofchargeactfailures+ 1)
    ENDIF
   ENDFOR
   FOR (lchargeitemcount = 1 TO size(request->process_event[lprocesseventcount].charge_item,5))
    SET lhchargeitem = uar_srvadditem(lhprocesseventitem,"charge_item")
    IF (lhchargeitem > 0)
     SET lnumberofsetchargeitems = (lnumberofsetchargeitems+ 1)
     CALL uar_srvsetdouble(lhchargeitem,"charge_item_id",request->process_event[lprocesseventcount].
      charge_item[lchargeitemcount].charge_item_id)
    ELSE
     SET lnumberofchargeitemfailures = (lnumberofchargeitemfailures+ 1)
    ENDIF
   ENDFOR
  ELSE
   SET lnumberofprocesseventfailures = (lnumberofprocesseventfailures+ 1)
  ENDIF
 ENDFOR
 IF (lnumberofprocesseventfailures=0
  AND lnumberofchargeactfailures=0
  AND lnumberofchargeitemfailures=0)
  SET lstatus = uar_crmperform(lhreq)
  IF (lstatus=0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->subeventstatus[1].targetobjectname = "CrmPerform On 951201"
   SET reply->subeventstatus[1].targetobjectvalue = cnvtstring(lstatus)
  ENDIF
 ELSE
  CALL echo(build("lNumberOfProcessEventFailures = ",lnumberofprocesseventfailures))
  CALL echo(build("lNumberOfChargeActFailures = ",lnumberofchargeactfailures))
  CALL echo(build("lNumberOfChargeItemFailures = ",lnumberofchargeitemfailures))
 ENDIF
#exitscript
 CALL uar_crmendreq(lhreq)
 CALL uar_crmendtask(lhtask)
 CALL uar_crmendapp(lhapp)
 CALL echorecord(reply)
END GO
