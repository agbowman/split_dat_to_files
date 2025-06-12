CREATE PROGRAM bhs_eks_behav_id:dba
 PROMPT
  "patient type (1 = ED Care Plan, 2 = Security Alert, 3 = Medical Alert)" = 0
  WITH pat_type_ind
 DECLARE mf_person_id = f8 WITH protect, noconstant(trigger_personid)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_behav_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_curuser_id = f8 WITH protect, noconstant(reqinfo->updt_id)
 CALL echo(build2("curuserid: ",mf_curuser_id))
 DECLARE ml_pat_type = i4 WITH protect, noconstant(0)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(trigger_encntrid)
 DECLARE retval = i4 WITH public, noconstant(0)
 DECLARE log_message = vc WITH public, noconstant("")
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
 IF (trim(cnvtlower( $PAT_TYPE_IND),3)="bhs_syn_behav_id_pat_type_behav")
  SET ml_pat_type = 1
 ELSEIF (trim(cnvtlower( $PAT_TYPE_IND),3)="bhs_syn_behav_id_pat_type_security")
  SET ml_pat_type = 2
 ELSEIF (trim(cnvtlower( $PAT_TYPE_IND),3)="bhs_syn_behav_id_pat_type_medical")
  SET ml_pat_type = 3
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_pat_behav_ident b,
   person p
  PLAN (b
   WHERE b.person_id=mf_person_id
    AND b.active_ind=1
    AND b.end_effective_dt_tm > sysdate
    AND b.pat_type_flag=ml_pat_type)
   JOIN (p
   WHERE p.person_id=b.person_id)
  ORDER BY b.person_id
  HEAD b.person_id
   IF (ml_pat_type=1)
    ms_tmp = concat("This patient has an ED Care Plan currently in place.",char(13),
     "The Care Plan is as follows- ",char(13),"Patient name- ",
     trim(p.name_full_formatted),char(13),"Rationale",char(13),"  Effective Date of Care Plan- ",
     trim(format(b.beg_effective_dt_tm,"mm/dd/yy;;d")),char(13),"  Due for Review- ",trim(format(b
       .review_dt_tm,"mm/dd/yy;;d")),char(13),
     "  Reason for Care Plan- ",char(13))
    IF (size(trim(b.reason)) > 0)
     ms_tmp = concat(ms_tmp,"    ",trim(replace(b.reason,"|",concat(char(13),"    "),0)),char(13))
    ENDIF
    ms_tmp = concat(ms_tmp,"  Rationale- ",trim(b.rationale),char(13),"  Clinical Contact- ",
     char(13))
    IF (size(trim(b.clinical_contact)) > 0)
     ms_tmp = concat(ms_tmp,"    ",trim(replace(b.clinical_contact,"|",concat(char(13),"    "),0)),
      char(13))
    ENDIF
    ms_tmp = concat(ms_tmp,"Interventions",char(13),"  ",trim(b.intervention),
     char(13),"Goals & Outcomes",char(13),"  ",trim(b.goal),
     char(13),"Approval",char(13))
    IF (size(trim(b.approval)) > 0)
     ms_tmp = concat(ms_tmp,"  ",trim(replace(b.approval,"|",concat(char(13),"  "),0)),char(13))
    ENDIF
    ms_tmp = concat(ms_tmp,char(13),char(13),"This Care Plan has been reviewed and approved by the",
     char(13),
     "High Frequency Utilization Committee",char(13),
     "Any concerns regarding this Care Plan should be",char(13),
     "forwarded to the Emergency Department Chair.")
   ELSEIF (ml_pat_type=2)
    ms_tmp = concat("This patient has a Security Alert currently in place.",char(13),
     "The Security Alert is as follows- ",char(13),"Patient name- ",
     trim(p.name_full_formatted),char(13),"  Effective Date of Care Plan- ",trim(format(b
       .beg_effective_dt_tm,"mm/dd/yy;;d")),char(13),
     "  Due for Review- ",trim(format(b.review_dt_tm,"mm/dd/yy;;d")),char(13),"  Reason for Alert- ",
     char(13))
    IF (size(trim(b.reason)) > 0)
     ms_tmp = concat(ms_tmp,"    ",trim(replace(b.reason,"|",concat(char(13),"    "),0)),char(13))
    ENDIF
    ms_tmp = concat(ms_tmp,"  Location of Incident- ",char(13))
    IF (size(trim(b.location)) > 0)
     ms_tmp = concat(ms_tmp,"    ",trim(replace(b.location,"|",concat(char(13),"    "),0)),char(13))
    ENDIF
    ms_tmp = concat(ms_tmp,"  Interventions- ",char(13),"  ",trim(b.intervention),
     char(13))
   ELSEIF (ml_pat_type=3)
    ms_tmp = concat("This patient has a Medical Alert currently in place.",char(13),
     "The Medical Alert is as follows- ",char(13),"Patient name- ",
     trim(p.name_full_formatted),char(13),"  Effective Date of Care Plan- ",trim(format(b
       .beg_effective_dt_tm,"mm/dd/yy;;d")),char(13),
     "  Due for Review- ",trim(format(b.review_dt_tm,"mm/dd/yy;;d")),char(13),"  Clinical Contact- ",
     char(13))
    IF (size(trim(b.clinical_contact)) > 0)
     ms_tmp = concat(ms_tmp,"    ",trim(replace(b.clinical_contact,"|",concat(char(13),"    "),0)),
      char(13))
    ENDIF
    ms_tmp = concat(ms_tmp,"  Interventions- ",char(13),"  ",trim(b.intervention),
     char(13))
   ENDIF
   mf_behav_id = b.bhs_pat_behav_ident_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET log_message = concat("person_id: ",trim(cnvtstring(mf_person_id)),
   "; exists; bhs_pat_behav_ident_id: ",trim(cnvtstring(mf_behav_id)))
  SET log_misc1 = ms_tmp
  CALL echo("sending inbox message")
  SET inboxrequest->person_id = mf_person_id
  SET inboxrequest->stat_ind = 1
  SET inboxrequest->task_type_cd = 0
  SET inboxrequest->task_type_meaning = "PHONE MSG"
  SET inboxrequest->reference_task_id = 0
  SET inboxrequest->task_dt_tm = sysdate
  SET inboxrequest->task_activity_meaning = "comp pers"
  SET inboxrequest->msg_text = fillstring(3100," ")
  SET inboxrequest->msg_text = replace(log_misc1,char(13),char(10))
  SET inboxrequest->msg_subject_cd = 0
  IF (ml_pat_type=1)
   SET inboxrequest->msg_subject = "ED Care Plan"
  ELSEIF (ml_pat_type=2)
   SET inboxrequest->msg_subject = "Security Alert"
  ELSEIF (ml_pat_type=3)
   SET inboxrequest->msg_subject = "Medical Alert"
  ENDIF
  SET inboxrequest->confidential_ind = 0
  SET inboxrequest->read_ind = 0
  SET inboxrequest->delivery_ind = 0
  SET inboxrequest->event_id = 0
  SET inboxrequest->event_class_meaning = " "
  SET inboxrequest->task_status_meaning = " "
  SET stat = alterlist(inboxrequest->assign_prsnl_list,1)
  SET inboxrequest->assign_prsnl_list[1].assign_prsnl_id = mf_curuser_id
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
  SET retval = 100
 ELSE
  SET log_message = concat("person_id: ",trim(cnvtstring(mf_person_id)),"; no match found")
  GO TO exit_script
 ENDIF
#exit_script
 CALL echo(log_message)
END GO
