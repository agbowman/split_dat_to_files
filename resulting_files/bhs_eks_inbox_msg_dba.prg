CREATE PROGRAM bhs_eks_inbox_msg:dba
 DECLARE patname = vc
 SET personid = trigger_personid
 SET encntrid = trigger_encntrid
 SET pid = 0
 SET retval = 100
 SET log_message = cnvtstring(link_clineventid)
 DECLARE msg = vc
 SELECT INTO "nl:"
  FROM clinical_event ce,
   person p
  PLAN (ce
   WHERE (ce.clinical_event_id=request->clin_detail_list[1].clinical_event_id))
   JOIN (p
   WHERE p.person_id=ce.person_id)
  HEAD REPORT
   pid = ce.performed_prsnl_id, patname = p.name_full_formatted
  FOOT REPORT
   log_message = build("_patient:",patname,"_pid:",pid)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("performed prsnl identified")
  CALL echo(build("msg send to mailbox:",pid))
  IF (( $1="flu"))
   SET msg = build2("Egg or Vaccine Allergy: Patient ",patname,
    " has a documented Egg or Influenza Vaccine",
    " allergy and the Influenza vaccine is contraindicated.",
    "  Therefore an order for the vaccine was not created.",
    "  Please modify the immunization contraindicated section on the admit assessment.")
   SET retval = 100
   SET log_message = build(log_message,"_",msg)
  ENDIF
  IF (( $1="Pneumo"))
   SET msg = build2("Egg or Vaccine Allergy: Patient ",patname,
    " has a documented Egg or Pneumococcal",
    " Vaccine allergy and the Pneumococcal vaccine is contraindicated.",
    "  Therefore an order for the vaccine was not created.",
    "  Please modify the immunization contraindicated section on the admit assessment.")
   SET retval = 100
   SET log_message = build(log_message,"_",msg)
  ENDIF
  IF (( $1="dupflu"))
   SET msg = build2("Patient ",patname,
    " The flu vaccine season for Baystate Health has not begun, or patient",
    " has documentation which shows they have already received the Influenza vaccine within",
    " the recommended timeframe.",
    " Therefore an order for the vaccine was not created.")
   SET retval = 100
   SET log_message = build(log_message,"_",msg)
  ENDIF
  IF (( $1="duppneumo"))
   SET msg = build2("Duplicated vaccine:Patient ",patname,
    " has documentation which shows they have already received",
    " the Pneumococcal vaccine within the recommended time frame.",
    " Therefore an order for the vaccine was not created.",
    "  Please modify the immunization contraindicated section on the admit assessment.")
   SET retval = 100
   SET log_message = build(log_message,"_",msg)
  ENDIF
  IF (( $1="h1n1"))
   SET msg = build2("Egg or Vaccine Allergy: ",patname,
    " has a documented egg allergy or allergy to the H1N1 vaccine and",
    " the H1N1 vaccine is contraindicated.  Therefore an order for the vaccine was not created.  Please modify",
    " the immunization contraindicated section on the admit assessment. ")
   SET retval = 100
   SET log_message = build(log_message,"_",msg)
  ENDIF
  IF (( $1="duph1n1"))
   SET msg = build2("Duplicated vaccine administration: ",patname,
    " has documentation which shows they have already received",
    " the H1N1 vaccine within the recommended time frame. Therefore an order for the vaccine was not created.",
    "  Please modify the immunization contraindicated section on the admit assessment.")
   SET retval = 100
   SET log_message = build(log_message,"_",msg)
  ENDIF
  CALL echo("Send in box messages")
  RECORD inboxrequest(
    1 person_id = f8
    1 encntr_id = f8
    1 stat_ind = i2
    1 task_type_cd = f8
    1 task_type_meaning = c12
    1 reference_task_id = f8
    1 task_dt_tm = dq8
    1 task_activity_meaning = c12
    1 msg_text = c32768
    1 msg_subject_cd = f8
    1 msg_subject = c255
    1 confidential_ind = i2
    1 read_ind = i2
    1 delivery_ind = i2
    1 event_id = f8
    1 event_class_meaning = c12
    1 assign_prsnl_list[*]
      2 assign_prsnl_id = f8
    1 task_status_meaning = c12
  )
  RECORD inboxreply(
    1 task_status = c1
    1 task_id = f8
    1 assign_prsnl_list[*]
      2 assign_prsnl_id = f8
      2 encntr_sec_ind = i2
    1 status_data
      2 status = c1
      2 substatus = i2
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = c100
  )
  DECLARE req = i4
  DECLARE happ = i4
  DECLARE htask = i4
  DECLARE hreq = i4
  DECLARE hreply = i4
  DECLARE crmstatus = i4
  SET ecrmok = 0
  SET null = 0
  IF (validate(recdate,"Y")="Y"
   AND validate(recdate,"N")="N")
   RECORD recdate(
     1 datetime = dq8
   )
  ENDIF
  SUBROUTINE srvrequest(taskhandle,reqno)
    SET htask = taskhandle
    SET req = reqno
    SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
    IF (crmstatus != ecrmok)
     CALL echo("Invalid CrmBeginReq return status")
    ELSEIF (hreq=null)
     CALL echo("Invalid hReq handle")
    ELSE
     SET request_handle = hreq
     SET hinboxrequest = uar_crmgetrequest(hreq)
     IF (hinboxrequest=null)
      CALL echo("Invalid request handle return from CrmGetRequest")
     ELSE
      SET stat = uar_srvsetdouble(hinboxrequest,"PERSON_ID",inboxrequest->person_id)
      SET stat = uar_srvsetdouble(hinboxrequest,"ENCNTR_ID",inboxrequest->encntr_id)
      SET stat = uar_srvsetshort(hinboxrequest,"STAT_IND",cnvtint(inboxrequest->stat_ind))
      SET stat = uar_srvsetdouble(hinboxrequest,"TASK_TYPE_CD",inboxrequest->task_type_cd)
      SET stat = uar_srvsetstring(hinboxrequest,"TASK_TYPE_MEANING",nullterm(inboxrequest->
        task_type_meaning))
      SET stat = uar_srvsetdouble(hinboxrequest,"REFERENCE_TASK_ID",inboxrequest->reference_task_id)
      SET recdate->datetime = inboxrequest->task_dt_tm
      SET stat = uar_srvsetdate2(hinboxrequest,"TASK_DT_TM",recdate)
      SET stat = uar_srvsetstring(hinboxrequest,"TASK_ACTIVITY_MEANING",nullterm(inboxrequest->
        task_activity_meaning))
      SET stat = uar_srvsetstring(hinboxrequest,"MSG_TEXT",nullterm(inboxrequest->msg_text))
      SET stat = uar_srvsetdouble(hinboxrequest,"MSG_SUBJECT_CD",inboxrequest->msg_subject_cd)
      SET stat = uar_srvsetstring(hinboxrequest,"MSG_SUBJECT",nullterm(inboxrequest->msg_subject))
      SET stat = uar_srvsetshort(hinboxrequest,"CONFIDENTIAL_IND",cnvtint(inboxrequest->
        confidential_ind))
      SET stat = uar_srvsetshort(hinboxrequest,"READ_IND",cnvtint(inboxrequest->read_ind))
      SET stat = uar_srvsetshort(hinboxrequest,"DELIVERY_IND",cnvtint(inboxrequest->delivery_ind))
      SET stat = uar_srvsetdouble(hinboxrequest,"EVENT_ID",inboxrequest->event_id)
      SET stat = uar_srvsetstring(hinboxrequest,"EVENT_CLASS_MEANING",nullterm(inboxrequest->
        event_class_meaning))
      FOR (ndx1 = 1 TO size(inboxrequest->assign_prsnl_list,5))
       SET hassign_prsnl_list = uar_srvadditem(hinboxrequest,"ASSIGN_PRSNL_LIST")
       IF (hassign_prsnl_list=null)
        CALL echo("ASSIGN_PRSNL_LIST","Invalid handle")
       ELSE
        SET stat = uar_srvsetdouble(hassign_prsnl_list,"ASSIGN_PRSNL_ID",inboxrequest->
         assign_prsnl_list[ndx1].assign_prsnl_id)
       ENDIF
      ENDFOR
      SET stat = uar_srvsetstring(hinboxrequest,"TASK_STATUS_MEANING",nullterm(inboxrequest->
        task_status_meaning))
     ENDIF
    ENDIF
    IF (crmstatus=ecrmok)
     CALL echo(concat("**** Begin perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
        "dd-mmm-yyyy;;d")," ",
       format(curtime,"hh:mm:ss.cc;3;m")))
     SET crmstatus = uar_crmperform(hreq)
     CALL echo(concat("**** End perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
        "dd-mmm-yyyy;;d")," ",
       format(curtime,"hh:mm:ss.cc;3;m")))
     IF (crmstatus != ecrmok)
      CALL echo("Invalid CrmPerform return status")
     ENDIF
    ELSE
     CALL echo("CrmPerform not executed do to begin request error")
    ENDIF
  END ;Subroutine
  SUBROUTINE srvreply(taskhandle,reqno)
    DECLARE item_cnt = i4 WITH protect
    SET htask = taskhandle
    SET req = reqno
    IF (crmstatus=ecrmok)
     SET hinboxreply = uar_crmgetreply(hreq)
     IF (hinboxreply=null)
      CALL echo("Invalid handle from CrmGetReply")
     ELSE
      CALL echo("Retrieving reply message")
      SET inboxreply->task_status = uar_srvgetstringptr(hinboxreply,"TASK_STATUS")
      SET inboxreply->task_id = uar_srvgetdouble(hinboxreply,"TASK_ID")
      SET item_cnt = uar_srvgetitemcount(hinboxreply,"ASSIGN_PRSNL_LIST")
      SET stat = alterlist(inboxreply->assign_prsnl_list,item_cnt)
      FOR (ndx1 = 1 TO item_cnt)
       SET hassign_prsnl_list = uar_srvgetitem(hinboxreply,"ASSIGN_PRSNL_LIST",(ndx1 - 1))
       IF (hassign_prsnl_list=null)
        CALL echo("Invalid handle return from SrvGetItem for hASSIGN_PRSNL_LIST")
       ELSE
        SET inboxreply->assign_prsnl_list[ndx1].assign_prsnl_id = uar_srvgetdouble(hassign_prsnl_list,
         "ASSIGN_PRSNL_ID")
        SET inboxreply->assign_prsnl_list[ndx1].encntr_sec_ind = uar_srvgetshort(hassign_prsnl_list,
         "ENCNTR_SEC_IND")
       ENDIF
      ENDFOR
      SET hstatus_data = uar_srvgetstruct(hinboxreply,"STATUS_DATA")
      IF (hstatus_data=null)
       CALL echo("Invalid handle")
      ELSE
       SET inboxreply->status_data.status = uar_srvgetstringptr(hstatus_data,"STATUS")
       SET inboxreply->status_data.substatus = uar_srvgetshort(hstatus_data,"SUBSTATUS")
       SET item_cnt = uar_srvgetitemcount(hstatus_data,"SUBEVENTSTATUS")
       SET stat = alterlist(inboxreply->status_data.subeventstatus,item_cnt)
       FOR (ndx2 = 1 TO item_cnt)
        SET hsubeventstatus = uar_srvgetitem(hstatus_data,"SUBEVENTSTATUS",(ndx2 - 1))
        IF (hsubeventstatus=null)
         CALL echo("Invalid handle return from SrvGetItem for hSUBEVENTSTATUS")
        ELSE
         SET inboxreply->status_data.subeventstatus[ndx2].operationname = uar_srvgetstringptr(
          hsubeventstatus,"OPERATIONNAME")
         SET inboxreply->status_data.subeventstatus[ndx2].operationstatus = uar_srvgetstringptr(
          hsubeventstatus,"OPERATIONSTATUS")
         SET inboxreply->status_data.subeventstatus[ndx2].targetobjectname = uar_srvgetstringptr(
          hsubeventstatus,"TARGETOBJECTNAME")
         SET inboxreply->status_data.subeventstatus[ndx2].targetobjectvalue = uar_srvgetstringptr(
          hsubeventstatus,"TARGETOBJECTVALUE")
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ELSE
     CALL echo("Could not retrieve reply due to CrmBegin request error")
    ENDIF
    CALL echo("Ending CRM Request")
    CALL uar_crmendreq(hreq)
  END ;Subroutine
  SET inboxrequest->person_id = personid
  SET inboxrequest->encntr_id = encntrid
  SET inboxrequest->stat_ind = 1
  SET inboxrequest->task_type_cd = 0
  SET inboxrequest->task_type_meaning = "PHONE MSG"
  SET inboxrequest->reference_task_id = 0
  SET inboxrequest->task_dt_tm = cnvtdatetime(curdate,curtime3)
  SET inboxrequest->task_activity_meaning = "comp pers"
  SET inboxrequest->msg_text = fillstring(3100," ")
  SET inboxrequest->msg_text = msg
  SET inboxrequest->msg_subject_cd = 0
  IF (( $1 IN ("flu", "Pneumo")))
   SET inboxrequest->msg_subject = "Egg or Vaccine Allergy Alert"
  ELSEIF (( $1 IN ("dupflu", "duppneumo")))
   SET inboxrequest->msg_subject = "Duplicated vaccine Alert"
  ENDIF
  SET inboxrequest->confidential_ind = 0
  SET inboxrequest->read_ind = 0
  SET inboxrequest->delivery_ind = 0
  SET inboxrequest->event_id = 0
  SET inboxrequest->event_class_meaning = " "
  SET inboxrequest->task_status_meaning = " "
  SET lcnt = 1
  SET stat = alterlist(inboxrequest->assign_prsnl_list,lcnt)
  SET inboxrequest->assign_prsnl_list[1].assign_prsnl_id = pid
  SET reqc = 967102
  SET happc = 0
  SET appc = 3055000
  SET taskc = 3202004
  SET htaskc = 0
  SET hreqc = 0
  SET stat = uar_crmbeginapp(appc,happc)
  SET stat = uar_crmbegintask(happc,taskc,htaskc)
  CALL echo(build("beginReq",stat))
  CALL srvrequest(htaskc,reqc)
  CALL srvreply(htaskc,reqc)
  CALL echorecord(inboxrequest)
  CALL echorecord(inboxreply)
 ENDIF
 SET log_message = build("clinicaleventid:",link_clineventid,"-",msg)
END GO
