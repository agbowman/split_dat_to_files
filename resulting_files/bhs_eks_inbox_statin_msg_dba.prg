CREATE PROGRAM bhs_eks_inbox_statin_msg:dba
 DECLARE mf_niacinsimvastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NIACINSIMVASTATIN")), protect
 DECLARE mf_pravastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PRAVASTATIN")),
 protect
 DECLARE mf_ezetimibesimvastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "EZETIMIBESIMVASTATIN")), protect
 DECLARE mf_amlodipineatorvastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEATORVASTATIN")), protect
 DECLARE mf_simvastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"SIMVASTATIN")),
 protect
 DECLARE mf_rosuvastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"ROSUVASTATIN")),
 protect
 DECLARE mf_pitavastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PITAVASTATIN")),
 protect
 DECLARE mf_lovastatinniacin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "LOVASTATINNIACIN")), protect
 DECLARE mf_lovastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"LOVASTATIN")),
 protect
 DECLARE mf_fluvastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"FLUVASTATIN")),
 protect
 DECLARE mf_atorvastatin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"ATORVASTATIN")),
 protect
 DECLARE mf_ordered_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_astsgot_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ASTSGOT")), protect
 DECLARE mf_altsgpt_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ALTSGPT")), protect
 DECLARE mf_primarycarephysician_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "PRIMARYCAREPHYSICIAN")), protect
 DECLARE mf_ordermd = f8 WITH protect
 DECLARE mf_pcpmd = f8 WITH protect
 DECLARE mf_order_action_type = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER")), protect
 DECLARE mn_found = i2 WITH protect, noconstant(0)
 DECLARE ms_msg = vc WITH protect, noconstant(" ")
 DECLARE ms_med = vc WITH protect, noconstant(" ")
 DECLARE ms_alt = vc WITH protect, noconstant(" ")
 DECLARE ms_ast = vc WITH protect, noconstant(" ")
 DECLARE mf_altered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_personid = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntrid = f8 WITH protect, noconstant(0.0)
 DECLARE mf_orderid = f8 WITH protect, noconstant(0.0)
 SET mf_encntrid = trigger_encntrid
 SET mf_personid = trigger_personid
 SET mf_orderid = trigger_orderid
 SET retval = 100
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   prsnl p
  PLAN (o
   WHERE o.encntr_id=mf_encntrid
    AND o.catalog_cd IN (mf_niacinsimvastatin_var, mf_pravastatin_var, mf_ezetimibesimvastatin_var,
   mf_amlodipineatorvastatin_var, mf_simvastatin_var,
   mf_rosuvastatin_var, mf_pitavastatin_var, mf_lovastatinniacin_var, mf_lovastatin_var,
   mf_fluvastatin_var,
   mf_atorvastatin_var)
    AND o.template_order_id=0
    AND o.order_status_cd=mf_ordered_var
    AND o.orig_ord_as_flag IN (1, 3))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_order_action_type
    AND oa.action_sequence=1)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
  DETAIL
   mf_ordermd = oa.order_provider_id, ms_med = trim(uar_get_code_display(o.catalog_cd)), mn_found = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=mf_encntrid
    AND ce.event_cd IN (mf_altsgpt_var, mf_astsgot_var)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_altered, mf_modified, mf_auth)
    AND ce.event_tag != "In Error")
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd=mf_altsgpt_var)
    ms_alt = concat(" ALT Result ",trim(ce.result_val)," ",format(ce.event_end_dt_tm,
      "mm/dd/yyyy hh.mm")," ")
   ELSEIF (ce.event_cd=mf_astsgot_var)
    ms_ast = concat("  AST Result ",trim(ce.result_val)," ",format(ce.event_end_dt_tm,
      "mm/dd/yyyy hh.mm")," ")
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("ALT = ",ms_alt))
 CALL echo(build("AST = ",ms_ast))
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr
  PLAN (epr
   WHERE epr.encntr_id=mf_encntrid
    AND epr.encntr_prsnl_r_cd=mf_primarycarephysician_var)
  DETAIL
   mf_pcpmd = epr.prsnl_person_id
  WITH nocounter
 ;end select
 IF (mn_found=1
  AND mf_ordermd != mf_pcpmd)
  SET retval = 100
  CALL echo(build("dr ordermd = ",mf_ordermd))
  SET ms_msg = build2("New LFTS are > 3x the upper limit of normal.",ms_alt,ms_ast,
   ". The patient has an active order for ",ms_med,
   ". Please consider lowering the dose or discontinuing use of this medication",
   " and contacting a clinical pharmacist for further advice and information.")
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
  SET inboxrequest->person_id = mf_personid
  SET inboxrequest->encntr_id = mf_encntrid
  SET inboxrequest->stat_ind = 1
  SET inboxrequest->task_type_cd = 0
  SET inboxrequest->task_type_meaning = "PHONE MSG"
  SET inboxrequest->reference_task_id = 0
  SET inboxrequest->task_dt_tm = cnvtdatetime(curdate,curtime3)
  SET inboxrequest->task_activity_meaning = "comp pers"
  SET inboxrequest->msg_text = fillstring(3100," ")
  SET inboxrequest->msg_text = ms_msg
  SET inboxrequest->msg_subject_cd = 0
  SET inboxrequest->msg_subject = "Statin order with Abnormal LFTs"
  SET inboxrequest->confidential_ind = 0
  SET inboxrequest->read_ind = 0
  SET inboxrequest->delivery_ind = 0
  SET inboxrequest->event_id = 0
  SET inboxrequest->event_class_meaning = " "
  SET inboxrequest->task_status_meaning = " "
  SET lcnt = 1
  SET stat = alterlist(inboxrequest->assign_prsnl_list,lcnt)
  SET inboxrequest->assign_prsnl_list[1].assign_prsnl_id = mf_ordermd
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
  SET log_message = build("order id found order action - ",mf_orderid,", message sent to ",mf_ordermd
   )
 ELSE
  SET retval = 0
  SET log_message = build("order id not in order action - ",mf_orderid)
 ENDIF
END GO
