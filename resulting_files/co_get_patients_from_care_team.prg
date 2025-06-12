CREATE PROGRAM co_get_patients_from_care_team
 RECORD reply(
   1 result_limit_exceeded = i4
   1 patientids_list[*]
     2 patient_id = f8
     2 encounter_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE FROM 1000_read_by_list_id TO 1099_read_by_list_id_exit
#1000_read_by_list_id
 IF ((request->care_team_list_id >= 1))
  DECLARE num = i4
  DECLARE _app = i4 WITH protect, noconstant(0)
  DECLARE _task = i4 WITH protect, noconstant(0)
  DECLARE _happ = i4 WITH protect, noconstant(0)
  DECLARE _htask = i4 WITH protect, noconstant(0)
  DECLARE _hreq = i4 WITH protect, noconstant(0)
  DECLARE _hrep = i4 WITH protect, noconstant(0)
  DECLARE _hstat = i4 WITH protect, noconstant(0)
  SET _app = 600700
  SET _task = 600720
  SET _reqnum = 600123
  SET currentcount = size(reply->patientids_list,5)
  SET crmstatus = uar_crmbeginapp(_app,_happ)
  IF (crmstatus != 0)
   SET failed_text = fillstring(255," ")
   SET failed_text = concat("Error! uar_CrmBeginApp failed with status: ",build(crmstatus))
   CALL echo(failed_text)
   GO TO 9000_crm_fail_exit
  ELSE
   CALL echo(concat("Uar_CrmBeginApp success, app: ",build(_app)))
  ENDIF
  SET crmstatus = uar_crmbegintask(_happ,_task,_htask)
  IF (crmstatus != 0)
   SET failed_text = fillstring(255," ")
   SET failed_text = concat("Error! uar_CrmBeginTask failed with status: ",build(crmstatus))
   CALL echo(failed_text)
   CALL uar_crmendapp(_happ)
   GO TO 9000_crm_fail_exit
  ELSE
   CALL echo(concat("Uar_CrmBeginTask success, task: ",build(_task)))
  ENDIF
  SET crmstatus = uar_crmbeginreq(_htask,0,_reqnum,_hreq)
  IF (crmstatus != 0)
   SET failed_text = fillstring(255," ")
   SET failed_text = concat("Invalid CrmBeginReq return status of",build(crmstatus))
   CALL echo(failed_text)
   CALL uar_crmendtask(_htask)
   CALL uar_crmendapp(_happ)
   GO TO 9000_crm_fail_exit
  ELSE
   CALL echo("uar_CrmBeginReq success")
  ENDIF
  SET _hrequest = uar_crmgetrequest(_hreq)
  IF (_hrequest)
   IF (_hrequest=null)
    SET failed_text = "Invalid hRequest handle returned from CrmGetRequest"
    CALL echo(failed_text)
    GO TO 9000_crm_fail_exit
   ENDIF
   SELECT INTO "nl:"
    FROM dcp_patient_list pl,
     dcp_pl_argument pla
    PLAN (pl
     WHERE (pl.patient_list_id=request->care_team_list_id))
     JOIN (pla
     WHERE pla.patient_list_id=pl.patient_list_id
      AND pla.argument_name="careteam_id")
    HEAD REPORT
     stat = uar_srvsetdouble(_hrequest,"patient_list_id",pl.patient_list_id), stat = uar_srvsetdouble
     (_hrequest,"patient_list_type_cd",pl.patient_list_type_cd), stat = uar_srvsetshort(_hrequest,
      "best_encntr_flag",0),
     stat = uar_srvsetstring(_hrequest,"patient_list_name","VIRTUAL")
    DETAIL
     _hargument = uar_srvadditem(_hrequest,"arguments"), stat = uar_srvsetstring(_hargument,
      "argument_name",nullterm(pla.argument_name)), stat = uar_srvsetstring(_hargument,
      "argument_value",nullterm(pla.argument_value)),
     stat = uar_srvsetstring(_hargument,"parent_entity_name",nullterm(pla.parent_entity_name)), stat
      = uar_srvsetdouble(_hargument,"parent_entity_id",pla.parent_entity_id)
    WITH nocounter
   ;end select
   SET crmstatus = uar_crmperform(_hreq)
   IF (crmstatus != 0)
    SET failed_text = concat("Invalid CrmPerform return status of ",build(crmstatus))
    CALL echo(failed_text)
    GO TO 9000_crm_fail_exit
   ELSE
    CALL echo(" uar_CrmPerform() success")
   ENDIF
   SET _hreply = uar_crmgetreply(_hreq)
   SET _hstat = uar_srvgetstruct(_hreply,"status_data")
   SET _status = uar_srvgetstringptr(_hstat,"status")
   CALL echo(concat("Called process returned: ",_status))
   SET failed_status = "S"
   IF (_status != "S")
    CALL echo(build("status=",_status))
    IF (_status="Z")
     SET failed_status = "Z"
    ELSE
     SET failed_status = "F"
    ENDIF
    SET failed_text = fillstring(255," ")
    SET failed_text = concat("dcp_get_patient_list2 returned status= ",build(_status))
    CALL echo(failed_text)
    GO TO 9000_crm_fail_exit
   ELSE
    SET patientcnt = uar_srvgetitemcount(_hreply,"patients")
    SET stat = alterlist(reply->patientids_list,patientcnt)
    SET realcnt = currentcount
    FOR (i = 0 TO (patientcnt - 1))
     SET hpatient = uar_srvgetitem(_hreply,"patients",i)
     IF (hpatient=null)
      CALL echo("invalid Patient returned")
     ELSE
      SET encounter_id = uar_srvgetdouble(hpatient,"encntr_id")
      SET patient_id = uar_srvgetdouble(hpatient,"person_id")
      SET posfound = locateval(num,1,(patientcnt+ currentcount),encounter_id,reply->patientids_list[
       num].encounter_id)
      IF (encounter_id > 0.0
       AND posfound=0)
       SET realcnt = (realcnt+ 1)
       SET reply->patientids_list[realcnt].patient_id = uar_srvgetdouble(hpatient,"person_id")
       SET reply->patientids_list[realcnt].encounter_id = uar_srvgetdouble(hpatient,"encntr_id")
      ENDIF
     ENDIF
    ENDFOR
    SET stat = alterlist(reply->patientids_list,realcnt)
   ENDIF
  ENDIF
 ENDIF
#1099_read_by_list_id_exit
#9000_crm_fail_exit
 CALL echorecord(reply)
 SET reply->status_data.status = failed_status
END GO
