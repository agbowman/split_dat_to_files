CREATE PROGRAM bsc_rec_audit_info:dba
 SET modify = predeclare
 CALL echo("****** Begin bsc_rec_audit_info ******")
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH protect, noconstant("")
 DECLARE mod_date = c10 WITH protect, noconstant("")
 DECLARE debug_ind = i2 WITH protect, noconstant(validate(request->debug_ind,0))
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE btablecheck = i2 WITH protect, noconstant(checkdic("ACUTE_CARE_AUDIT_INFO","T",0))
 DECLARE qeventdttm = dq8 WITH protect, noconstant(0)
 DECLARE bfailed = i2 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE qcurtime = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE recordauditinfo(lidx=i4) = null
 IF (btablecheck != 2)
  IF (debug_ind=1)
   CALL echo("acute_care_audit_info table does not exist")
  ENDIF
  GO TO exit_script
 ENDIF
 FOR (lcnt = 1 TO size(request->audit_events,5))
  IF ((request->audit_events[lcnt].audit_event_dt_tm > 0))
   SET qeventdttm = request->audit_events[lcnt].audit_event_dt_tm
  ELSE
   SET qeventdttm = qcurtime
  ENDIF
  CALL recordauditinfo(lcnt)
 ENDFOR
 SUBROUTINE recordauditinfo(lidx)
   INSERT  FROM acute_care_audit_info ac
    SET ac.acute_care_audit_info_id = seq(medadmin_seq,nextval), ac.audit_solution_cd = request->
     audit_events[lidx].audit_solution_cd, ac.audit_event_type_cd = request->audit_events[lidx].
     audit_event_cd,
     ac.audit_event_dt_tm = cnvtdatetime(qeventdttm), ac.audit_prsnl_id = validate(reqinfo->updt_id,0
      ), ac.position_cd = validate(reqinfo->position_cd,0),
     ac.audit_facility_cd = request->audit_events[lidx].audit_facility_cd, ac.audit_patient_id =
     request->audit_events[lidx].audit_patient_id, ac.audit_information_text = substring(1,255,
      request->audit_events[lidx].audit_info_text),
     ac.updt_id = validate(reqinfo->updt_id,0), ac.updt_dt_tm = cnvtdatetime(qcurtime), ac.updt_task
      = validate(reqinfo->updt_task,0),
     ac.updt_applctx = validate(reqinfo->updt_applctx,0), ac.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET bfailed = 1
    IF (debug_ind=1)
     CALL echo("Insert failed")
    ENDIF
   ELSE
    IF (debug_ind=1)
     CALL echo("Insert successful")
    ENDIF
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("Solution_cd: ",request->audit_events[lidx].audit_solution_cd))
    CALL echo(build("Event_cd: ",request->audit_events[lidx].audit_event_cd))
    CALL echo(build("Event_dt_tm: ",cnvtdatetime(qeventdttm)))
    CALL echo(build("Personnel_id: ",validate(reqinfo->updt_id,0)))
    CALL echo(build("Position_cd: ",validate(reqinfo->position_cd,0)))
    CALL echo(build("Facility_cd: ",request->audit_events[lidx].audit_facility_cd))
    CALL echo(build("Paitient_id: ",request->audit_events[lidx].audit_patient_id))
   ENDIF
 END ;Subroutine
#exit_script
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "ERROR"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "bsc_rec_audit_info"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrmsg
 ELSEIF (btablecheck=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "ERROR"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "bsc_rec_audit_info"
  SET reply->status_data.subeventstatus.targetobjectvalue = "Acute Care Audit Info table is missing"
 ELSEIF (bfailed=1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "ERROR"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "bsc_rec_audit_info"
  SET reply->status_data.subeventstatus.targetobjectvalue =
  "Insert into acute_care_audit_info table failed"
 ELSEIF (size(request->audit_events,5) < 1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "ERROR"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "bsc_rec_audit_info"
  SET reply->status_data.subeventstatus.targetobjectvalue = "No events were passed in to be inserted"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET last_mod = "000"
 SET mod_date = "05/05/2010"
 IF (debug_ind=1)
  CALL echorecord(reply)
  CALL echo(build("last_mod: ",last_mod))
  CALL echo(build("mod_date: ",mod_date))
 ENDIF
 CALL echo("****** Exiting bsc_rec_audit_info ******")
 SET modify = nopredeclare
END GO
