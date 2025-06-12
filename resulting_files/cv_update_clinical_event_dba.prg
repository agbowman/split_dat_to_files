CREATE PROGRAM cv_update_clinical_event:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE resultstatus = f8 WITH protect, noconstant(0.0)
 DECLARE childeventid = f8 WITH protect, noconstant(0.0)
 DECLARE eventcd = f8 WITH protect, noconstant(0.0)
 DECLARE orderid = f8 WITH protect, noconstant(0.0)
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE encntrid = f8 WITH protect, noconstant(0.0)
 DECLARE dreportstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE refnbr = vc WITH protect, noconstant("")
 DECLARE grouprefnbr = vc WITH protect, noconstant("")
 DECLARE study_identifier = c64 WITH protect, noconstant("")
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
 DECLARE hce = i4 WITH protect, noconstant(0)
 DECLARE srvstat = i2 WITH protect, noconstant(0)
 DECLARE next_rad_code = f8 WITH public, noconstant(0.0)
 DECLARE storagecd = f8 WITH public, noconstant(0.0)
 DECLARE formatcd = f8 WITH public, noconstant(0.0)
 DECLARE successiontypecd = f8 WITH public, noconstant(0.0)
 DECLARE eventdocclasscd = f8 WITH public, noconstant(0.0)
 DECLARE rooteventid = f8 WITH public, noconstant(0.0)
 DECLARE ordtype = i2 WITH protect, noconstant(0)
 DECLARE updatecount = i4 WITH public, noconstant(0)
 DECLARE recordstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE recordtstatuscodevalue = f8 WITH public, noconstant(0.0)
 DECLARE resultstatuscd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE formatcdrtf = f8 WITH protect, noconstant(uar_get_code_by("MEANING",23,"RTF"))
 DECLARE storagecdblob = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE hblob = i4 WITH protect, noconstant(0)
 DECLARE compression_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE rtf_header = vc WITH constant(
  "{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Calibri;}{\f1\fswiss Calibri;}}\deflang2057\deflange2057")
 DECLARE wr = vc WITH constant(" \plain \f0 \fs24 \cb2 ")
 SET rtol = " \par "
 DECLARE rtf_footer = vc WITH constant("}")
 DECLARE rtf_text = vc
 SET storagecd = uar_get_code_by("MEANING",25,"MMF")
 SET formatcd = uar_get_code_by("MEANING",23,"PDF")
 SET successiontypecd = uar_get_code_by("MEANING",63,"INTERIM")
 SET eventdocclasscd = uar_get_code_by("MEANING",53,"DOC")
 SET recordstatuscodevalue = uar_get_code_by("MEANING",48,"DELETED")
 SET study_identifier = request->pdf_doc_identifier
 SET reply->status_data.status = "F"
 CALL logmessage(build("requestRefNbr: ",request->parent_event_id,"*"))
 CALL logmessage(build("requestpostIND: ",request->post_ind,"*"))
 IF ((request->parent_event_id != null))
  CALL logmessage("A parent event ID was given")
  SELECT INTO "nl:"
   ce1.order_id
   FROM clinical_event ce1,
    ce_blob_result br,
    clinical_event ce2,
    (dummyt d2  WITH seq = 1)
   PLAN (ce1
    WHERE (ce1.parent_event_id=request->parent_event_id)
     AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.event_class_cd=eventdocclasscd
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (br
    WHERE br.event_id=ce2.event_id)
   DETAIL
    grouprefnbr = ce1.reference_nbr, resultstatus = ce1.result_status_cd, refnbr = ce2.reference_nbr,
    rooteventid = ce1.event_id, childeventid = ce2.event_id, eventcd = ce1.event_cd,
    recordstatuscd = ce2.record_status_cd, contributorsyscd = ce1.contributor_system_cd
    IF (ce1.order_id != 0)
     orderid = ce1.order_id, personid = ce1.person_id, encntrid = ce1.encntr_id,
     ordtype = 1
    ELSE
     status = "F", reply->status_data.subeventstatus.operationname = "Query by reference number",
     reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENT",
     reply->status_data.subeventstatus.targetobjectvalue =
     "Failed to find the data for the given parent event ID", ordtype = 0
    ENDIF
   WITH nocounter, outerjoin = d2
  ;end select
  CALL logmessage(build("****groupRefNbr: ",grouprefnbr,"*"))
  CALL logmessage(build("****orderID: ",orderid,"*"))
  CALL logmessage(build("****personID: ",personid,"*"))
  CALL logmessage(build("****encntrID: ",encntrid,"*"))
  CALL logmessage(build("****rootEventID: ",rooteventid,"*"))
  CALL logmessage(build("****childEventID: ",childeventid,"*"))
  CALL logmessage(build("****eventCd: ",eventcd,"*"))
  CALL logmessage(build("****study_identifier: ",study_identifier,"*"))
  CALL logmessage(build("****ordType: ",ordtype,"*"))
  CALL logmessage(build("****recordStatusCD: ",recordstatuscd,"*"))
 ELSE
  SET status = "F"
  SET reply->status_data.subeventstatus.operationname = "Request is incorrect"
  SET reply->status_data.subeventstatus.targetobjectname = "Request Structure"
  SET reply->status_data.subeventstatus.targetobjectvalue =
  "There is no parent event ID number in the request"
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
 IF (ordtype=1)
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
  SET srvstat = uar_srvsetshort(hstce,"publish_flag",1)
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
  SET srvstat = uar_srvsetshort(hce,"publish_flag",1)
  SET srvstat = uar_srvsetshort(hce,"authentic_flag",1)
  SET srvstat = uar_srvsetdouble(hce,"parent_event_id",rooteventid)
  SET srvstat = uar_srvsetdouble(hce,"event_cd",eventcd)
  SET srvstat = uar_srvsetdate(hce,"event_start_dt_tm",cnvtdatetime(sysdate))
  IF (((childeventid=0) OR (recordstatuscd=recordstatuscodevalue)) )
   SET hbr = uar_srvadditem(hce,"blob_result")
   SET srvstat = uar_srvsetdouble(hbr,"succession_type_cd",successiontypecd)
   SET srvstat = uar_srvsetdouble(hbr,"storage_cd",storagecd)
   SET srvstat = uar_srvsetdouble(hbr,"format_cd",formatcd)
   SET srvstat = uar_srvsetdouble(hbr,"device_cd",0.0)
   SET srvstat = uar_srvsetstring(hbr,"blob_handle",nullterm(trim(study_identifier)))
  ENDIF
 ELSEIF ((request->post_ind=2))
  CALL logmessage("adding with post_ind = 2")
  SET rtf_text = concat(rtf_header,wr,"Interpretation",rtol)
  SET rtf_text = concat(rtf_text,wr,request->strconclusion,rtol,rtol,
   rtol,request->inerror_reason,rtol,rtf_footer)
  SET hreq = uar_crmgetrequest(hstep)
  SET srvstat = uar_srvsetshort(hreq,"ensure_type",2)
  SET hstce = uar_srvgetstruct(hreq,"clin_event")
  SET srvstat = uar_srvsetdouble(hstce,"order_id",orderid)
  SET srvstat = uar_srvsetstring(hstce,"reference_nbr",nullterm(""))
  SET srvstat = uar_srvsetstring(hstce,"reference_nbr",nullterm(trim(grouprefnbr)))
  SET srvstat = uar_srvsetdouble(hstce,"person_id",personid)
  SET srvstat = uar_srvsetdouble(hstce,"encntr_id",encntrid)
  SET srvstat = uar_srvsetdouble(hstce,"result_status_cd",resultstatuscd)
  SET srvstat = uar_srvsetdouble(hstce,"contributor_system_cd",contributorsyscd)
  SET srvstat = uar_srvsetshort(hstce,"event_start_dt_tm_ind",1)
  SET srvstat = uar_srvsetshort(hstce,"event_end_dt_tm_ind",1)
  SET srvstat = uar_srvsetshort(hstce,"clinsig_updt_dt_tm_ind",0)
  SET srvstat = uar_srvsetshort(hstce,"clinsig_updt_dt_tm_flag",3)
  SET srvstat = uar_srvsetshort(hstce,"publish_flag_ind",0)
  SET srvstat = uar_srvsetshort(hstce,"publish_flag",1)
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
  SET srvstat = uar_srvsetshort(hce,"publish_flag",1)
  SET srvstat = uar_srvsetshort(hce,"authentic_flag",1)
  SET srvstat = uar_srvsetdouble(hce,"parent_event_id",rooteventid)
  SET srvstat = uar_srvsetdouble(hce,"event_cd",eventcd)
  SET srvstat = uar_srvsetdate(hce,"event_start_dt_tm",cnvtdatetime(sysdate))
  SET hbr = uar_srvadditem(hce,"blob_result")
  SET srvstat = uar_srvsetdouble(hbr,"succession_type_cd",successiontypecd)
  SET srvstat = uar_srvsetdouble(hbr,"storage_cd",storagecdblob)
  SET srvstat = uar_srvsetdouble(hbr,"format_cd",formatcdrtf)
  SET srvstat = uar_srvsetdouble(hbr,"device_cd",0.0)
  SET hblob = uar_srvadditem(hbr,"blob")
  SET srvstat = uar_srvsetasis(hblob,"blob_contents",rtf_text,size(rtf_text))
  SET srvstat = uar_srvsetdouble(hblob,"compression_cd",uar_get_code_by("MEANING",120,"NOCOMP"))
 ELSE
  SET hreq = uar_crmgetrequest(hstep)
  SET srvstat = uar_srvsetshort(hreq,"ensure_type",4)
  SET hstce = uar_srvgetstruct(hreq,"clin_event")
  SET srvstat = uar_srvsetdouble(hstce,"event_id",childeventid)
  CALL logmessage("deleting")
 ENDIF
 SET iret = uar_crmperform(hstep)
 IF (iret != 0)
  SET reply->status_data.subeventstatus[1].operationname = "Event Ensure"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CLINICAL_EVENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
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
