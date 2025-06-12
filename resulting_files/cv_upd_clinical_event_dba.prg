CREATE PROGRAM cv_upd_clinical_event:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE resultstatus = f8 WITH protect, noconstant(0.0)
 DECLARE childeventid = f8 WITH protect, noconstant(0.0)
 DECLARE eventcd = f8 WITH protect, noconstant(0.0)
 DECLARE orderid = f8 WITH protect, noconstant(0.0)
 DECLARE seqexamid = f8 WITH protect, noconstant(0.0)
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE encntrid = f8 WITH protect, noconstant(0.0)
 DECLARE dreportstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE refnbr = vc WITH protect, noconstant("")
 DECLARE grouprefnbr = vc WITH protect, noconstant("")
 DECLARE studyuid = c64 WITH protect, noconstant("")
 DECLARE contributorsyscd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",89,"POWERCHART"))
 DECLARE activecd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE applicationid = i4 WITH protect, constant(1000012)
 DECLARE taskid = i4 WITH protect, constant(1000012)
 DECLARE requestid = i4 WITH protect, constant(1000012)
 DECLARE status = c1 WITH protect, noconstant("T")
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hstce = i4 WITH protect, noconstant(0)
 DECLARE hbr = i4 WITH protect, noconstant(0)
 DECLARE iret = i4 WITH protect, noconstant(0)
 DECLARE hcetype = i4 WITH protect, noconstant(0)
 DECLARE hcestruct = i4 WITH protect, noconstant(0)
 DECLARE hdataset = i4 WITH protect, noconstant(0)
 DECLARE hce = i4 WITH protect, noconstant(0)
 DECLARE srvstat = i2 WITH protect, noconstant(0)
 DECLARE next_rad_code = f8 WITH public, noconstant(0.0)
 DECLARE storagecd = f8 WITH public, noconstant(0.0)
 DECLARE formatcd = f8 WITH public, noconstant(0.0)
 DECLARE successiontypecd = f8 WITH public, noconstant(0.0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE nviewprelimflowflag = i2 WITH protect, noconstant(0)
 DECLARE nviewholdflowflag = i2 WITH public, noconstant(1)
 DECLARE nviewrejectflowflag = i2 WITH public, noconstant(1)
 DECLARE drptstatusnew = f8 WITH public, constant(uar_get_code_by("MEANING",14202,"NEW"))
 DECLARE drptstatushold = f8 WITH public, constant(uar_get_code_by("MEANING",14202,"HOLD"))
 DECLARE drptstatusreject = f8 WITH public, constant(uar_get_code_by("MEANING",14202,"REJECT"))
 DECLARE drptstatusfinal = f8 WITH public, constant(uar_get_code_by("MEANING",14202,"FINAL"))
 DECLARE eventdocclasscd = f8 WITH public, noconstant(0.0)
 DECLARE rooteventid = f8 WITH public, noconstant(0.0)
 DECLARE carddiscp = f8 WITH public, noconstant(0.0)
 DECLARE ordtype = i2 WITH protect, noconstant(0)
 DECLARE updatecount = i4 WITH public, noconstant(0)
 DECLARE inerrorcd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
 SET storagecd = uar_get_code_by("MEANING",25,"DICOM_SIUID")
 SET formatcd = uar_get_code_by("MEANING",23,"ACRNEMA")
 SET successiontypecd = uar_get_code_by("MEANING",63,"INTERIM")
 SET eventdocclasscd = uar_get_code_by("MEANING",53,"DOC")
 SET carddiscp = uar_get_code_by("MEANING",255110,"CARD")
 SET reply->status_data.status = "F"
 SET studyuid = request->studyuid
 CALL logmessage(build("$$$$requestRefNbr: ",request->group_reference_nbr,"*"))
 CALL logmessage(build("$$$$requestorderID: ",request->order_id,"*"))
 CALL logmessage(build("$$$$requestpostIND: ",request->post_ind,"*"))
 IF ((request->group_reference_nbr != null))
  CALL logmessage("A reference number was given")
  IF ((request->history_ind=1))
   CALL logmessage("historical cardiology with a reference number")
   SELECT INTO "nl:"
    cvh.person_id
    FROM cv_proc_hx cvh,
     clinical_event ce1,
     ce_blob_result br,
     clinical_event ce2,
     (dummyt d2  WITH seq = 1)
    PLAN (ce1
     WHERE (ce1.reference_nbr=request->group_reference_nbr)
      AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (cvh
     WHERE cvh.person_id=ce1.person_id
      AND (cvh.reference_txt=request->group_reference_nbr)
      AND cvh.contributor_system_cd=ce1.contributor_system_cd)
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (ce2
     WHERE ce2.parent_event_id=ce1.event_id
      AND ce2.event_class_cd=eventdocclasscd
      AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (br
     WHERE br.event_id=ce2.event_id
      AND br.storage_cd=storagecd)
    DETAIL
     updatecount = ce1.updt_cnt, grouprefnbr = ce1.reference_nbr, resultstatus = ce1.result_status_cd,
     refnbr = ce2.reference_nbr, rooteventid = ce1.event_id, childeventid = ce2.event_id,
     eventcd = ce1.event_cd, contributorsyscd = ce1.contributor_system_cd
     IF (cvh.person_id != 0)
      orderid = cvh.order_id, personid = cvh.person_id, encntrid = cvh.encntr_id,
      ordtype = 3
     ELSE
      status = "F", reply->status_data.subeventstatus.operationname = "Query by reference number",
      reply->status_data.subeventstatus.targetobjectname = "CV_PROX_HX",
      reply->status_data.subeventstatus.targetobjectvalue = "Failed to find history data data",
      ordtype = 0
     ENDIF
    WITH nocounter, outerjoin = d2
   ;end select
  ELSE
   CALL logmessage("non-historical cardiology with a reference number")
   SELECT INTO "nl:"
    cp.order_id
    FROM clinical_event ce1,
     cv_proc cp,
     ce_blob_result br,
     clinical_event ce2,
     (dummyt d2  WITH seq = 1)
    PLAN (ce1
     WHERE (ce1.reference_nbr=request->group_reference_nbr)
      AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (cp
     WHERE (cp.order_id= Outerjoin(ce1.order_id))
      AND (cp.group_event_id= Outerjoin(ce1.event_id)) )
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (ce2
     WHERE ce2.parent_event_id=ce1.event_id
      AND ce2.event_class_cd=eventdocclasscd
      AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (br
     WHERE br.event_id=ce2.event_id
      AND br.storage_cd=storagecd)
    DETAIL
     grouprefnbr = ce1.reference_nbr, resultstatus = ce1.result_status_cd, refnbr = ce2.reference_nbr,
     rooteventid = ce1.event_id, childeventid = ce2.event_id, eventcd = ce1.event_cd,
     contributorsyscd = ce1.contributor_system_cd
     IF (cp.order_id != 0)
      orderid = cp.order_id, personid = cp.person_id, encntrid = cp.encntr_id,
      ordtype = 3
     ELSE
      status = "F", reply->status_data.subeventstatus.operationname = "Query by reference number",
      reply->status_data.subeventstatus.targetobjectname = "CV_PROC",
      reply->status_data.subeventstatus.targetobjectvalue =
      "Failed to find history data or procedure data", ordtype = 0
     ENDIF
    WITH nocounter, outerjoin = d2
   ;end select
  ENDIF
  CALL logmessage(build("****groupRefNbr: ",grouprefnbr,"*"))
  CALL logmessage(build("****orderID: ",orderid,"*"))
  CALL logmessage(build("****personID: ",personid,"*"))
  CALL logmessage(build("****encntrID: ",encntrid,"*"))
  CALL logmessage(build("****rootEventID: ",rooteventid,"*"))
  CALL logmessage(build("****childEventID: ",childeventid,"*"))
  CALL logmessage(build("****eventCd: ",eventcd,"*"))
  CALL logmessage(build("****studyUID: ",studyuid,"*"))
  CALL logmessage(build("****ordType: ",ordtype,"*"))
 ELSEIF ((request->order_id != 0))
  CALL logmessage("cadiology with order_ID")
  SELECT INTO "nl:"
   cp.order_id
   FROM cv_proc cp,
    ce_blob_result br,
    clinical_event ce3,
    (dummyt d2  WITH seq = 1),
    clinical_event ce4,
    (dummyt d3  WITH seq = 1)
   PLAN (cp
    WHERE (cp.order_id=request->order_id))
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (ce3
    WHERE ce3.order_id=cp.order_id
     AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND ce3.event_id=cp.group_event_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (ce4
    WHERE ce4.parent_event_id=ce3.event_id
     AND ce4.event_class_cd=eventdocclasscd
     AND ce4.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (br
    WHERE br.event_id=ce4.event_id
     AND br.storage_cd=storagecd)
   DETAIL
    updatecount = ce3.updt_cnt, grouprefnbr = ce3.reference_nbr, resultstatus = ce3.result_status_cd,
    refnbr = ce4.reference_nbr, rooteventid = ce3.event_id, childeventid = ce4.event_id,
    eventcd = ce3.event_cd, contributorsyscd = ce3.contributor_system_cd
    IF (cp.order_id != 0)
     orderid = cp.order_id, personid = cp.person_id, encntrid = cp.encntr_id,
     ordtype = 3
    ELSE
     status = "F", reply->status_data.subeventstatus.operationname = "Query by order id", reply->
     status_data.subeventstatus.targetobjectname = "CV_PROC",
     reply->status_data.subeventstatus.targetobjectvalue = "Failed to find procedure data", ordtype
      = 0
    ENDIF
   WITH nocounter, outerjoin = d2, outerjoin = d3
  ;end select
  CALL logmessage(build("----groupRefNbr: ",grouprefnbr,"*"))
  CALL logmessage(build("----orderID: ",orderid,"*"))
  CALL logmessage(build("----personID: ",personid,"*"))
  CALL logmessage(build("----encntrID: ",encntrid,"*"))
  CALL logmessage(build("----rootEventID: ",rooteventid,"*"))
  CALL logmessage(build("----childEventID: ",childeventid,"*"))
  CALL logmessage(build("----eventCd: ",eventcd,"*"))
  CALL logmessage(build("----studyUID: ",studyuid,"*"))
  CALL logmessage(build("----ordType: ",ordtype,"*"))
 ELSE
  SET status = "F"
  SET reply->status_data.subeventstatus.operationname = "Request is incorrectly"
  SET reply->status_data.subeventstatus.targetobjectname = "Request Structure"
  SET reply->status_data.subeventstatus.targetobjectvalue =
  "There are no group reference number or order id in the request"
  SET ordtype = 0
 ENDIF
 IF (grouprefnbr=null)
  SET status = "F"
  SET reply->status_data.subeventstatus.operationname = "No clinical event data"
  SET reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENT"
  SET reply->status_data.subeventstatus.targetobjectvalue =
  "Failed to find clinical event row with given data"
  SET ordtype = 0
 ENDIF
 IF (ordtype=0)
  GO TO exit_script
 ENDIF
 IF (((ordtype=1) OR (ordtype=2)) )
  IF (((refnbr="") OR (((refnbr=" ") OR (refnbr=grouprefnbr)) )) )
   EXECUTE rad_next_code
   SET refnbr = trim(concat("RAD",cnvtstring(next_rad_code)))
  ENDIF
 ELSEIF (ordtype=3)
  IF (((refnbr="") OR (((refnbr=" ") OR (refnbr=grouprefnbr)) )) )
   DECLARE nextseqnum = f8 WITH protected, noconstant(0.0)
   DECLARE nextval = f8 WITH public, noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnumber = seq(card_vas_seq,nextval)
    FROM dual
    DETAIL
     nextseqnum = nextseqnumber
    WITH nocounter
   ;end select
   SET refnbr = trim(concat("CARD",cnvtstring(nextseqnum)))
  ENDIF
 ENDIF
 IF ((request->post_ind=1))
  CALL logmessage("inserting pvw dataset")
  SET iret = uar_crmbeginapp(1000012,happ)
  IF (iret != 0)
   SET status = "F"
   SET reply->status_data.subeventstatus.operationname = "Start Application"
   SET reply->status_data.subeventstatus.targetobjectname = "PVW_DATASET"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Failed to start application 1000012"
   GO TO exit_script
  ENDIF
  SET iret = uar_crmbegintask(happ,4118000,htask)
  IF (iret != 0)
   SET status = "F"
   SET reply->status_data.subeventstatus.operationname = "Start Task"
   SET reply->status_data.subeventstatus.targetobjectname = "PVW_DATASET"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Failed to start Task 4118000"
   GO TO exit_script
  ENDIF
  SET iret = uar_crmbeginreq(htask,"",4112200,hstep)
  IF (iret != 0)
   SET status = "F"
   SET reply->status_data.subeventstatus.operationname = "Start Request"
   SET reply->status_data.subeventstatus.targetobjectname = "PVW_DATASET"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Failed to start Task 4112200"
   GO TO exit_script
  ENDIF
  SET hreq = uar_crmgetrequest(hstep)
  SET hdataset = uar_srvadditem(hreq,"datasetList")
  SET srvstat = uar_srvsetstring(hdataset,"study_ds_uid",nullterm(trim(studyuid)))
  SET srvstat = uar_srvsetdouble(hdataset,"person_id",personid)
  SET srvstat = uar_srvsetdouble(hdataset,"study_par_entity_id",rooteventid)
  SET srvstat = uar_srvsetdouble(hdataset,"archive_cd",555.00)
  SET srvstat = uar_srvsetdouble(hdataset,"archive_location_cd",777.00)
  SET srvstat = uar_srvsetstring(hdataset,"study_par_entity_name",nullterm("clinical_event"))
  SET srvstat = uar_srvsetstring(hdataset,"blob_handle",nullterm(trim(studyuid)))
  SET iret = uar_crmperform(hstep)
  IF (iret != 0)
   SET reply->status_data.subeventstatus.operationname = "Add data"
   SET reply->status_data.subeventstatus.targetobjectname = "PVW_DATASET"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Failed to Perform update to target"
   SET status = "F"
  ENDIF
  IF (hstep)
   CALL uar_crmendreq(hstep)
   SET hstep = 0
  ENDIF
  IF (htask)
   CALL uar_crmendtask(htask)
   SET htask = 0
  ENDIF
  IF (happ)
   CALL uar_crmendapp(happ)
   SET happ = 0
  ENDIF
  IF (ordtype=1)
   SELECT INTO "nl:"
    rsc.view_prelim_flow_flag
    FROM rad_sys_controls rsc
    WHERE rsc.service_resource_cd=0.0
    DETAIL
     nviewprelimflowflag = rsc.view_prelim_flow_flag, nviewholdflowflag = validate(rsc
      .view_onhold_flow_ind,1), nviewrejectflowflag = validate(rsc.view_rejected_flow_ind,1)
    WITH nocounter
   ;end select
  ELSE
   SET nviewprelimflowflag = 2
  ENDIF
 ENDIF
 IF (resultstatus=inerrorcd)
  CALL logmessage("PROC row is in inerror status. Skiping the 1000012 call.")
  SET status = "S"
  GO TO exit_script
 ELSE
  SET iret = uar_crmbeginapp(applicationid,happ)
  IF (iret != 0)
   SET status = "F"
   SET reply->status_data.subeventstatus.operationname = "Start Application"
   SET reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENT"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Failed to start App 1000012"
   GO TO exit_script
  ENDIF
  SET iret = uar_crmbegintask(happ,taskid,htask)
  IF (iret != 0)
   SET status = "F"
   SET reply->status_data.subeventstatus.operationname = "Start Task"
   SET reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENT"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Failed to start Task 1000012"
   GO TO exit_script
  ENDIF
  SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
  IF (iret != 0)
   SET status = "F"
   SET reply->status_data.subeventstatus.operationname = "Start Request"
   SET reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENT"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Failed to start Req 1000012"
   GO TO exit_script
  ENDIF
  IF ((request->post_ind=1))
   CALL logmessage("adding with post_ind = 1")
   SET hreq = uar_crmgetrequest(hstep)
   SET srvstat = uar_srvsetshort(hreq,"ensure_type",2)
   SET hstce = uar_srvgetstruct(hreq,"clin_event")
   SET srvstat = uar_srvsetlong(hstce,"updt_cnt",updatecount)
   SET srvstat = uar_srvsetdouble(hstce,"order_id",orderid)
   SET srvstat = uar_srvsetstring(hstce,"reference_nbr",nullterm(""))
   SET srvstat = uar_srvsetstring(hstce,"reference_nbr",nullterm(trim(grouprefnbr)))
   SET srvstat = uar_srvsetdouble(hstce,"person_id",personid)
   SET srvstat = uar_srvsetdouble(hstce,"encntr_id",encntrid)
   SET srvstat = uar_srvsetdouble(hstce,"result_status_cd",resultstatus)
   SET srvstat = uar_srvsetdouble(hstce,"contributor_system_cd",contributorsyscd)
   SET srvstat = uar_srvsetshort(hstce,"event_start_dt_tm_ind",1)
   SET srvstat = uar_srvsetshort(hstce,"event_end_dt_tm_ind",1)
   SET srvstat = uar_srvsetshort(hstce,"clinsig_updt_dt_tm_ind",0)
   SET srvstat = uar_srvsetshort(hstce,"clinsig_updt_dt_tm_flag",3)
   SET srvstat = uar_srvsetshort(hstce,"publish_flag_ind",0)
   IF (nviewprelimflowflag=2)
    SET srvstat = uar_srvsetshort(hstce,"publish_flag",1)
   ELSEIF (nviewprelimflowflag=0)
    IF (dreportstatuscd=drptstatusfinal)
     SET srvstat = uar_srvsetshort(hstce,"publish_flag",1)
    ELSE
     SET srvstat = uar_srvsetshort(hstce,"publish_flag",0)
    ENDIF
   ELSEIF (nviewprelimflowflag=1)
    IF (dreportstatuscd=drptstatushold)
     SET srvstat = uar_srvsetshort(hstce,"publish_flag",nviewholdflowflag)
    ELSEIF (dreportstatuscd=drptstatusreject)
     SET srvstat = uar_srvsetshort(hstce,"publish_flag",nviewrejectflowflag)
    ELSE
     SET srvstat = uar_srvsetshort(hstce,"publish_flag",1)
    ENDIF
   ENDIF
   SET srvstat = uar_srvsetshort(hstce,"authentic_flag_ind",1)
   SET srvstat = uar_srvsetshort(hstce,"view_level_ind",1)
   SET srvstat = uar_srvsetdouble(hstce,"event_cd",eventcd)
   SET srvstat = uar_srvsetdouble(hstce,"event_id",rooteventid)
   SET srvstat = uar_srvsetdouble(hstce,"record_status_cd",activecd)
   SET hcetype = uar_srvcreatetypefrom(hreq,"clin_event")
   SET hcestruct = uar_srvgetstruct(hreq,"clin_event")
   CALL uar_srvbinditemtype(hcestruct,"child_event_list",hcetype)
   IF (hcetype)
    CALL uar_srvdestroytype(hcetype)
    SET hcetype = 0
   ENDIF
   SET hce = uar_srvadditem(hcestruct,"child_event_list")
   SET srvstat = uar_srvsetstring(hce,"reference_nbr",nullterm(""))
   SET srvstat = uar_srvsetstring(hce,"reference_nbr",nullterm(trim(refnbr)))
   SET srvstat = uar_srvsetdouble(hce,"person_id",personid)
   SET srvstat = uar_srvsetdouble(hce,"encntr_id",encntrid)
   SET srvstat = uar_srvsetdouble(hce,"order_id",orderid)
   SET srvstat = uar_srvsetdouble(hce,"result_status_cd",resultstatus)
   SET srvstat = uar_srvsetdouble(hce,"contributor_system_cd",contributorsyscd)
   SET srvstat = uar_srvsetdouble(hce,"event_class_cd",eventdocclasscd)
   SET srvstat = uar_srvsetdouble(hce,"event_reltn_cd",uar_get_code_by("MEANING",24,"CHILD"))
   SET srvstat = uar_srvsetdouble(hce,"record_status_cd",activecd)
   SET srvstat = uar_srvsetdouble(hce,"inquire_security_cd",uar_get_code_by("MEANING",87,
     "ROUTCLINICAL"))
   SET srvstat = uar_srvsetdate(hce,"event_end_dt_tm",cnvtdatetime(sysdate))
   SET srvstat = uar_srvsetlong(hce,"view_level",0)
   IF (nviewprelimflowflag=2)
    SET srvstat = uar_srvsetshort(hce,"publish_flag",1)
   ELSEIF (nviewprelimflowflag=0)
    IF (dreportstatuscd=drptstatusfinal)
     SET srvstat = uar_srvsetshort(hce,"publish_flag",1)
    ELSE
     SET srvstat = uar_srvsetshort(hce,"publish_flag",0)
    ENDIF
   ELSEIF (nviewprelimflowflag=1)
    IF (dreportstatuscd=drptstatushold)
     SET srvstat = uar_srvsetshort(hce,"publish_flag",nviewholdflowflag)
    ELSEIF (dreportstatuscd=drptstatusreject)
     SET srvstat = uar_srvsetshort(hce,"publish_flag",nviewrejectflowflag)
    ELSE
     SET srvstat = uar_srvsetshort(hce,"publish_flag",1)
    ENDIF
   ENDIF
   SET srvstat = uar_srvsetshort(hce,"authentic_flag",1)
   SET srvstat = uar_srvsetdouble(hce,"parent_event_id",rooteventid)
   SET srvstat = uar_srvsetdouble(hce,"event_cd",eventcd)
   SET srvstat = uar_srvsetdate(hstce,"event_start_dt_tm",cnvtdatetime(sysdate))
   SET hbr = uar_srvadditem(hce,"blob_result")
   SET srvstat = uar_srvsetdouble(hbr,"succession_type_cd",successiontypecd)
   SET srvstat = uar_srvsetdouble(hbr,"storage_cd",storagecd)
   SET srvstat = uar_srvsetdouble(hbr,"format_cd",formatcd)
   SET srvstat = uar_srvsetdouble(hbr,"device_cd",0.0)
   SET srvstat = uar_srvsetstring(hbr,"blob_handle",nullterm(trim(studyuid)))
  ELSE
   SET hreq = uar_crmgetrequest(hstep)
   SET srvstat = uar_srvsetshort(hreq,"ensure_type",4)
   SET hstce = uar_srvgetstruct(hreq,"clin_event")
   SET srvstat = uar_srvsetdouble(hstce,"event_id",childeventid)
   CALL logmessage("deleting")
  ENDIF
  SET iret = uar_crmperform(hstep)
  IF (iret != 0)
   SET reply->status_data.subeventstatus.operationname = "Event Ensure"
   SET reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENT"
   SET reply->status_data.subeventstatus.targetobjectvalue =
   "Failed to Perform update to Clinical Event"
   SET status = "F"
  ENDIF
  IF (hstep)
   CALL uar_crmendreq(hstep)
   SET hstep = 0
  ENDIF
  IF (htask)
   CALL uar_crmendtask(htask)
   SET htask = 0
  ENDIF
  IF (happ)
   CALL uar_crmendapp(happ)
   SET happ = 0
  ENDIF
 ENDIF
#exit_script
 IF (status="F")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE (logmessage(message=vc) =i4)
   CALL echo(message)
 END ;Subroutine
END GO
