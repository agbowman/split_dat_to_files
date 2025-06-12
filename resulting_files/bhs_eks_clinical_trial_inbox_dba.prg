CREATE PROGRAM bhs_eks_clinical_trial_inbox:dba
 PROMPT
  "personid" = "",
  "encntrid" = ""
  WITH personid, encntrid
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE patacttype = vc WITH noconstant(" ")
 DECLARE attdphyid = f8 WITH noconstant(0.0)
 DECLARE irb = vc WITH noconstant(" ")
 DECLARE alert = i4 WITH noconstant(0)
 DECLARE timealertfail = i4 WITH noconstant(0)
 DECLARE attdname = vc WITH noconstant(" ")
 DECLARE patientexpired = i4 WITH noconstant(0)
 DECLARE trialcnt = i4 WITH noconstant(0)
 DECLARE d = vc WITH noconstant(" ")
 DECLARE tempval = vc WITH protect, noconstant("")
 DECLARE msgpriority = i4 WITH noconstant(5)
 DECLARE sendto = vc WITH noconstant(" ")
 DECLARE msgsubject = vc WITH noconstant(" ")
 DECLARE msg = vc WITH noconstant(" ")
 DECLARE msgcls = vc WITH constant("IPM.NOTE")
 DECLARE sender = vc WITH constant("Discern_Expert@bhs.org")
 DECLARE attenddoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC")), protect
 DECLARE cmrn = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN")), protect
 DECLARE expiredobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV")), protect
 DECLARE expireddaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY")),
 protect
 DECLARE expiredip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP")), protect
 DECLARE expiredes = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES")), protect
 SET tab = fillstring(6,char(32))
 RECORD pattrialinfo(
   1 qual[*]
     2 emailpharmacy = i4
     2 patientname = vc
     2 patientlocation = vc
     2 patientnurseunit = vc
     2 patientroom = vc
     2 patientcmrn = vc
     2 irb = vc
     2 trialemailaccounts = vc
     2 trialtitle = vc
     2 specialinstructions = vc
     2 trialpiname = vc
     2 trialcontactinfo = vc
     2 trialmedication = vc
 )
 RECORD email(
   1 trial[*]
     2 qual[*]
       3 account = vc
 )
 CALL echo(expiredes)
 SET retval = 0
 IF (validate(trigger_personid) > 0)
  SET person_id = trigger_personid
  SET encntr_id = trigger_encntrid
 ELSE
  SET person_id =  $PERSONID
  SET encntr_id =  $ENCNTRID
 ENDIF
 CALL echo(person_id)
 CALL echo(encntr_id)
 SET log_message = build("encntr_id=",encntr_id)
 IF (validate(trigger_personid) > 0)
  IF ((request->o_reg_dt_tm != request->n_reg_dt_tm))
   IF ((request->o_reg_dt_tm IN (null, 0)))
    SET patacttype = "admit"
   ENDIF
  ELSEIF ( NOT ((request->n_disch_dt_tm IN (null, 0)))
   AND (request->o_disch_dt_tm IN (null, 0)))
   SET patacttype = "discharge"
  ELSEIF ((request->n_location_cd != request->o_location_cd))
   SET patacttype = "transfer"
  ENDIF
  IF (textlen(patacttype) <= 0)
   SET log_message = build(log_message,"Patient encounter action did not qualify")
   SET retval = 0
   GO TO exit_script
  ENDIF
 ELSE
  SET patacttype = "admit"
 ENDIF
 SET log_message = build(log_message,"_patActionType=",patacttype)
 SELECT INTO "NL:"
  FROM bhs_clinical_trial_person bp,
   bhs_clinical_trial b,
   person p,
   prsnl pl,
   person_alias pa,
   bhs_clinical_trial_meds bm,
   encntr_loc_hist elh,
   encounter e,
   order_catalog oc,
   dummyt d
  PLAN (bp
   WHERE bp.person_id=person_id
    AND bp.active_ind=1)
   JOIN (b
   WHERE b.irb_number=bp.irb_number
    AND b.active_ind=1)
   JOIN (p
   WHERE p.person_id=bp.person_id)
   JOIN (pl
   WHERE pl.person_id=b.pi_id)
   JOIN (e
   WHERE e.encntr_id=encntr_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(cmrn))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (bm
   WHERE (bm.irb_number= Outerjoin(bp.irb_number))
    AND (bm.active_ind= Outerjoin(1)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(bm.catalog_cd))
    AND (oc.active_ind= Outerjoin(1)) )
   JOIN (d)
   JOIN (elh
   WHERE (elh.encntr_id= Outerjoin(encntr_id))
    AND (elh.active_ind= Outerjoin(1))
    AND elh.encntr_loc_hist_id IN (
   (SELECT
    max(elh1.encntr_loc_hist_id)
    FROM encntr_loc_hist elh1
    WHERE elh1.encntr_id=encntr_id)))
  ORDER BY b.irb_number, oc.primary_mnemonic
  HEAD bp.irb_number
   trialcnt += 1, stat = alterlist(pattrialinfo->qual,trialcnt), log_message = build(log_message,
    "_trial_found_"),
   CALL echo("detail")
   IF (datetimecmp(datetimeadd(cnvtdatetime(bp.email_notify_start_dt_tm),bp.email_notify_length),
    cnvtdatetime(curdate,235959)) > 0)
    log_message = build(log_message,"_Trial qualified_"),
    CALL echo("Alert timeframe qualified"), alert = 1
    IF (e.encntr_type_cd IN (expiredobv, expireddaystay, expiredip, expiredes)
     AND patacttype="discharge")
     patientexpired = 1
    ENDIF
    pattrialinfo->qual[trialcnt].emailpharmacy = b.pharmacy_notify_ind, pattrialinfo->qual[trialcnt].
    patientname = concat(trim(p.name_first,3)," ",trim(p.name_last,3))
    IF ((request->n_loc_nurse_unit_cd > 0)
     AND (request->n_loc_building_cd > 0))
     pattrialinfo->qual[trialcnt].patientlocation = trim(uar_get_code_display(request->
       n_loc_building_cd),3), pattrialinfo->qual[trialcnt].patientnurseunit = trim(
      uar_get_code_display(request->n_loc_nurse_unit_cd),3), pattrialinfo->qual[trialcnt].patientroom
      = concat(trim(uar_get_code_display(request->n_loc_room_cd),3),"-",trim(uar_get_code_display(elh
        .loc_bed_cd),3))
    ELSE
     pattrialinfo->qual[trialcnt].patientlocation = trim(uar_get_code_display(elh.loc_building_cd),3),
     pattrialinfo->qual[trialcnt].patientnurseunit = trim(uar_get_code_display(elh.loc_nurse_unit_cd),
      3), pattrialinfo->qual[trialcnt].patientroom = concat(trim(uar_get_code_display(elh.loc_room_cd
        ),3),"-",trim(uar_get_code_display(elh.loc_bed_cd),3))
    ENDIF
    pattrialinfo->qual[trialcnt].patientcmrn = trim(pa.alias,3), pattrialinfo->qual[trialcnt].irb = b
    .irb_number, pattrialinfo->qual[trialcnt].trialemailaccounts = b.email_address,
    pattrialinfo->qual[trialcnt].trialtitle = b.title, pattrialinfo->qual[trialcnt].
    specialinstructions = trim(b.instructions,3), pattrialinfo->qual[trialcnt].specialinstructions =
    replace(pattrialinfo->qual[trialcnt].specialinstructions,":"," "),
    pattrialinfo->qual[trialcnt].trialpiname = concat(trim(pl.name_first,3)," ",trim(pl.name_last,3)),
    pattrialinfo->qual[trialcnt].trialcontactinfo = concat(pattrialinfo->qual[trialcnt].trialpiname,
     char(10),tab,"Phone: ",trim(b.phone_number,3),
     IF (textlen(trim(b.pager_number,3)) > 0) concat(char(10),tab,"Pager: ",trim(b.pager_number,3))
     ELSE ""
     ENDIF
     ,char(10),tab,"Email: ",trim(b.email_address,3))
   ELSE
    log_message = build(log_message,"_trial did not qualify for times_"), timealertfail = 1
   ENDIF
  HEAD oc.catalog_cd
   IF (oc.catalog_cd > 0)
    pattrialinfo->qual[trialcnt].trialmedication = concat(pattrialinfo->qual[trialcnt].
     trialmedication,trim(oc.primary_mnemonic,3),char(10))
   ENDIF
  WITH nocounter, outjoin = d
 ;end select
 IF (alert <= 0)
  SET log_message = concat(log_message,"Patient is NOT on an active clinical trial",
   "timeQualifyFailed(1=true)",trim(cnvtstring(timealertfail),3)," ",
   build2("enID:",encntr_id,"_pID",person_id,"__",
    patacttype,irb,"_",attdphyid))
  SET retval = 0
  GO TO exit_script
 ELSE
  SET log_message = build(log_message,"_patient did qualify_")
 ENDIF
 SELECT INTO "NL:"
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE epr.encntr_id=encntr_id
    AND epr.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm
    AND epr.encntr_prsnl_r_cd=attenddoc)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   attdphyid = epr.prsnl_person_id, attdname = concat(trim(p.name_first,3)," ",trim(p.name_last,3))
  WITH nocounter
 ;end select
 SET stat = alterlist(email->trial,trialcnt)
 SET log_message = build(log_message,"_startSendingEmails_")
 FOR (tcnt = 1 TO trialcnt)
   SET x = 0
   SET log_message = build(log_message,"_emails_")
   WHILE (x < 10
    AND x != 10)
     SET x += 1
     SET d = pattrialinfo->qual[tcnt].trialemailaccounts
     IF (findstring(",",d) > 0)
      SET d = concat(d,",")
      SET d = replace(d,",,",",")
      SET tempval = trim(piece(d,",",x,"1",0),3)
     ELSEIF (findstring(";",d) > 0)
      SET d = concat(d,";")
      SET d = replace(d,";;",";")
      SET tempval = trim(piece(d,";",x,"1",0),3)
     ELSE
      SET tempval = "1"
     ENDIF
     IF (tempval="1"
      AND x=1)
      SET stat = alterlist(email->trial[tcnt].qual,x)
      SET email->trial[tcnt].qual[x].account = trim(pattrialinfo->qual[tcnt].trialemailaccounts,3)
     ELSEIF (textlen(tempval) > 1
      AND ((tempval != "1") OR (tempval="1"
      AND x=1)) )
      SET stat = alterlist(email->trial[tcnt].qual,x)
      SET email->trial[tcnt].qual[x].account = tempval
     ELSE
      SET x = 100
     ENDIF
   ENDWHILE
   CALL echorecord(email)
   SET msgsubject = "Clinical Trial Alert"
   SET msg = concat("Trial: ",trim(pattrialinfo->qual[tcnt].trialtitle,3),char(10),char(10),
    "The clinical trial patient ",
    pattrialinfo->qual[tcnt].patientname," (CMRN:",pattrialinfo->qual[tcnt].patientcmrn,
    IF (patacttype="admit") ") has been admitted to:"
    ELSEIF (patacttype="discharge")
     IF (patientexpired=0) ") has been discharged from:"
     ELSE ") has expired."
     ENDIF
    ELSEIF (patacttype="transfer") ") has been transferred to:"
    ENDIF
    ,char(10),
    char(10),"Location: ",pattrialinfo->qual[tcnt].patientlocation,char(10),"Nurse Unit: ",
    pattrialinfo->qual[tcnt].patientnurseunit,char(10),"Room: ",pattrialinfo->qual[tcnt].patientroom,
    char(10),
    char(10),"Attending physician: ",trim(attdname),char(10),char(10),
    "Trial information",char(10),"---------------------------",char(10),tab,
    "contact: ",pattrialinfo->qual[tcnt].trialcontactinfo,
    IF (textlen(trim(pattrialinfo->qual[tcnt].specialinstructions,3)) > 0) concat(char(10),char(10),
      "Special Instructions:",char(10),tab,
      trim(pattrialinfo->qual[tcnt].specialinstructions,3))
    ELSE char(10)
    ENDIF
    ,
    IF (textlen(pattrialinfo->qual[tcnt].trialmedication) > 0) concat(char(10),char(10),
      "Drugs deemed contraindicated for this trial",char(10),
      "-------------------------------------------",
      char(10),pattrialinfo->qual[tcnt].trialmedication)
    ELSE char(10)
    ENDIF
    )
   DECLARE tempemailnames = vc WITH noconstant(" ")
   SET log_message = build(log_message,"_StartingToSendingEmails_")
   FOR (x = 1 TO size(email->trial[tcnt].qual,5))
     SET sendto = replace(cnvtlower(email->trial[tcnt].qual[x].account),"baystatehealth.org",
      "bhs.org")
     SET tempemailnames = concat(tempemailnames,",",sendto)
     CALL uar_send_mail(nullterm(sendto),nullterm(msgsubject),nullterm(msg),sender,msgpriority,
      msgcls)
     CALL echo(concat("Email sent to: ",sendto))
     SET log_message = build(log_message,"_email Sent To_",sendto,"_")
   ENDFOR
   IF ((pattrialinfo->qual[trialcnt].emailpharmacy=1))
    SET sendto = "gerald.korona@bhs.org"
    CALL uar_send_mail(nullterm(check(sendto)),nullterm(msgsubject),nullterm(msg),sender,msgpriority,
     msgcls)
    CALL echo("pharmacy email")
    CALL echo(concat("Email sent to: ",sendto))
    SET tempemailnames = concat(tempemailnames," ","pharmacy")
    SET sendto = "scott.gray@bhs.org"
    CALL uar_send_mail(nullterm(check(sendto)),nullterm(msgsubject),nullterm(msg),sender,msgpriority,
     msgcls)
    CALL echo("pharmacy email")
    CALL echo(concat("Email sent to: ",sendto))
    SET tempemailnames = concat(tempemailnames," ","pharmacy")
    SET log_message = build(log_message,"_Email sent topharm: ",sendto,"_")
   ENDIF
   CALL echo("*********************phyEmail***********************")
   CALL echo(msg)
   CALL echo("***************************************************")
   SET msg = concat(tempemailnames,char(10),msg)
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
         SET inboxreply->assign_prsnl_list[ndx1].assign_prsnl_id = uar_srvgetdouble(
          hassign_prsnl_list,"ASSIGN_PRSNL_ID")
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
   SET msgsubject = "Clinical Trial Alert"
   SET pattrialinfo->qual[tcnt].trialcontactinfo = replace(pattrialinfo->qual[tcnt].trialcontactinfo,
    ":",tab)
   SET msg = value(concat(concat(
      "You are receiving this notification because you are listed in CIS as this patient's",
      " attending physician"),char(10),char(10),"The clinical trial patient ",pattrialinfo->qual[tcnt
     ].patientname,
     " (CMRN ",pattrialinfo->qual[tcnt].patientcmrn,
     IF (patacttype="admit") ") has been admitted to "
     ELSEIF (patacttype="discharge")
      IF (patientexpired=0) ") has been discharged from "
      ELSE ") has expired."
      ENDIF
     ELSEIF (patacttype="transfer") ") has been transferred to "
     ENDIF
     ,char(10),char(10),
     "Location   ",tab,pattrialinfo->qual[tcnt].patientlocation,char(10),"Nurse Unit",
     tab,pattrialinfo->qual[tcnt].patientnurseunit,char(10),"Room       ",tab,
     pattrialinfo->qual[tcnt].patientroom,char(10),char(10),concat(
      "This patient is participating in the following clinical trial. Please contact ",pattrialinfo->
      qual[tcnt].trialpiname," for further information."),char(10),
     char(10),"Trial - ",trim(pattrialinfo->qual[tcnt].trialtitle,3),char(10),char(10),
     "Contact information",char(10),tab,pattrialinfo->qual[tcnt].trialcontactinfo,
     IF (textlen(trim(pattrialinfo->qual[tcnt].specialinstructions,3)) > 0) concat(char(10),char(10),
       "Special Instructions ",char(10),tab,
       trim(pattrialinfo->qual[tcnt].specialinstructions,3))
     ELSE char(10)
     ENDIF
     ,
     IF (textlen(pattrialinfo->qual[tcnt].trialmedication) > 0) concat(char(10),char(10),
       "Drugs deemed contraindicated for this trial",char(10),
       "-------------------------------------------",
       char(10),pattrialinfo->qual[tcnt].trialmedication)
     ELSE char(10)
     ENDIF
     ))
   CALL echo(msg)
   SET inboxrequest->person_id = person_id
   SET inboxrequest->encntr_id = encntr_id
   SET inboxrequest->stat_ind = 1
   SET inboxrequest->task_type_cd = 0
   SET inboxrequest->task_type_meaning = "PHONE MSG"
   SET inboxrequest->reference_task_id = 0
   SET inboxrequest->task_dt_tm = cnvtdatetime(sysdate)
   SET inboxrequest->task_activity_meaning = "comp pers"
   SET inboxrequest->msg_text = fillstring(3100," ")
   SET inboxrequest->msg_text = msg
   SET inboxrequest->msg_subject_cd = 0
   SET inboxrequest->msg_subject = msgsubject
   SET inboxrequest->confidential_ind = 0
   SET inboxrequest->read_ind = 0
   SET inboxrequest->delivery_ind = 0
   SET inboxrequest->event_id = 0
   SET inboxrequest->event_class_meaning = " "
   SET inboxrequest->task_status_meaning = " "
   SET stat = alterlist(inboxrequest->assign_prsnl_list,1)
   SET inboxrequest->assign_prsnl_list[1].assign_prsnl_id = attdphyid
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
 ENDFOR
 SET retval = 100
 SET log_message = build(log_message,"done sending emails")
#exit_script
 SET log_message = build(log_message,"newloc_",uar_get_code_display(request->n_location_cd),"oldloc_",
  uar_get_code_display(request->0_location_cd),
  "newNurse_",uar_get_code_display(request->n_loc_nurse_unit_cd),"newNurse_",uar_get_code_display(
   request->o_loc_nurse_unit_cd),"newRoom_",
  uar_get_code_display(request->n_loc_room_cd),"oldRoom_",uar_get_code_display(request->o_loc_room_cd
   ),"newroom_",uar_get_code_display(request->o_loc_bed_cd),
  "oldRoom_",uar_get_code_display(request->o_loc_bed_cd))
 CALL echo(log_message)
END GO
