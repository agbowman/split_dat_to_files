CREATE PROGRAM bhs_eks_check_active_tasks
 PROMPT
  "Enter CLINICAL_EVENT_ID: " = 0.00
 DECLARE tmp_cnt = i4
 DECLARE tmp_time = i4
 DECLARE check_form_status(zero=i2) = null
 SUBROUTINE check_form_status(zero)
   SELECT INTO "NL:"
    FROM dcp_forms_activity dfa
    PLAN (dfa
     WHERE dfa.dcp_forms_activity_id=tmp_ref_nbr
      AND dfa.flags != 1)
    DETAIL
     tmp_cnt = 999
    WITH nocounter
   ;end select
 END ;Subroutine
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
  DECLARE log_message = vc
  DECLARE retval = i4
  DECLARE log_clineventid = f8
  DECLARE log_encntrid = f8
  DECLARE log_misc1 = vc
 ENDIF
 IF (cnvtreal( $1) <= 0.00)
  SET log_message = "No CLINICAL_EVENT_ID given"
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET log_clineventid = cnvtreal( $1)
  SET log_message = build2("LOG_CLINEVENTID = ",trim(build2(log_clineventid),3))
 ENDIF
 DECLARE tmp_ref_nbr = f8
 DECLARE var_current_task_id = f8
 SELECT INTO "NL:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.clinical_event_id=cnvtreal( $1))
  DETAIL
   tmp_ref_nbr = cnvtreal(substring(1,(findstring("!",ce.reference_nbr) - 1),ce.reference_nbr)),
   log_encntrid = ce.encntr_id
  WITH nocounter
 ;end select
 IF (tmp_ref_nbr <= 0.00)
  SET log_message = build2(log_message," | Invalid CLINICAL_EVENT_ID")
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET log_message = build2(log_message," | DCP_FORMS_ACTIVITY_ID ",trim(build2(tmp_ref_nbr),3))
 ENDIF
 CALL check_form_status(0)
 WHILE (tmp_cnt < 5)
   SET tmp_cnt = (tmp_cnt+ 1)
   SET tmp_time = curtime2
   WHILE (tmp_time=curtime2)
     CALL pause(1)
   ENDWHILE
   CALL check_form_status(0)
 ENDWHILE
 IF (tmp_cnt < 999)
  SET log_message = build2(log_message," | Current form not completed.")
  SET retval = 100
  SET log_misc1 = "-1"
  GO TO exit_script
 ENDIF
 DECLARE var_telephone_triage_id = f8 WITH noconstant(- (1.00))
 DECLARE var_patient_medical_care_id = f8 WITH noconstant(- (1.00))
 DECLARE var_prescription_refill_id = f8 WITH noconstant(- (1.00))
 DECLARE var_referral_request_id = f8 WITH noconstant(- (1.00))
 SELECT INTO "NL:"
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE dfr.description IN ("Telephone Triage Form", "Patient Medical Care - Triage",
   "Prescription Refill - Triage", "Referral Request - Triage")
    AND dfr.active_ind=1
    AND dfr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   CASE (dfr.description)
    OF "Telephone Triage Form":
     var_telephone_triage_id = dfr.dcp_forms_ref_id
    OF "Patient Medical Care - Triage":
     var_patient_medical_care_id = dfr.dcp_forms_ref_id
    OF "Prescription Refill - Triage":
     var_prescription_refill_id = dfr.dcp_forms_ref_id
    OF "Referral Request - Triage":
     var_referral_request_id = dfr.dcp_forms_ref_id
   ENDCASE
  FOOT REPORT
   IF (var_telephone_triage_id <= 0.00)
    log_message = build2(log_message," | WARNING: Telephone Triage Form not found")
   ENDIF
   IF (var_patient_medical_care_id <= 0.00)
    log_message = build2(log_message," | WARNING: Patient Medical Care - Triage not found")
   ENDIF
   IF (var_prescription_refill_id <= 0.00)
    log_message = build2(log_message," | WARNING: Prescription Refill - Triage not found")
   ENDIF
   IF (var_referral_request_id <= 0.00)
    log_message = build2(log_message," | WARNING: Referral Request - Triage not found")
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET log_message = build2(log_message," | No DCP_FORM_REF_IDs found. Exitting Script")
  SET retval = - (1)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM dcp_forms_activity dfa
  PLAN (dfa
   WHERE dfa.encntr_id=log_encntrid
    AND dfa.dcp_forms_ref_id IN (var_telephone_triage_id, var_patient_medical_care_id,
   var_prescription_refill_id, var_referral_request_id)
    AND dfa.flags=1)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET retval = 0
 ELSE
  SET retval = 100
 ENDIF
 SET log_misc1 = trim(build2(retval),3)
 SET log_message = build2(log_message," | ",trim(build2(curqual),3)," inprocess Telephone Triage ",
  "form(s) for ENCNTR_ID ",
  trim(build2(log_encntrid),3))
#exit_script
 SET log_message = build2(log_message,". Exitting Script")
 CALL echo(build2("RETVAL: ",retval))
 CALL echo(build2("LOG_MESSAGE: ",log_message))
 FREE SET tmp_ref_nbr
 FREE SET var_current_task_id
 FREE SET tmp_cnt
 FREE SET tmp_time
 FREE SET var_telephone_triage_id
 FREE SET var_patient_medical_care_id
 FREE SET var_prescription_refill_id
 FREE SET var_referral_request_id
END GO
