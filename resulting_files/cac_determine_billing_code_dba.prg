CREATE PROGRAM cac_determine_billing_code:dba
 RECORD ncodereply(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
     2 error_details[*]
       3 error_detail = vc
   1 transaction_uid = vc
   1 cac_code = vc
   1 record_id = vc
   1 computed_codes[*]
     2 guideline
       3 guideline_95_ind = i2
       3 guideline_97_ind = i2
     2 computed_code
       3 primary_code = vc
       3 secondary_codes[*]
         4 code = vc
         4 instance_cnt = i2
     2 advice
       3 advice_summary = vc
       3 full_advice = vc
 )
 DECLARE step_id = i4 WITH protect, constant(3070029)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hactualservicetype = i4 WITH protect, noconstant(0)
 DECLARE hcliniciancode = i4 WITH protect, noconstant(0)
 DECLARE hcodedservicetype = i4 WITH protect, noconstant(0)
 DECLARE hadditionaldata = i4 WITH protect, noconstant(0)
 DECLARE hpatientinformation = i4 WITH protect, noconstant(0)
 DECLARE hweight = i4 WITH protect, noconstant(0)
 DECLARE hweightunit = i4 WITH protect, noconstant(0)
 DECLARE hinitialcode = i4 WITH protect, noconstant(0)
 DECLARE hsecondarycodes = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 DECLARE herrordetail = i4 WITH protect, noconstant(0)
 DECLARE cliniciancodecnt = i2 WITH protect, noconstant(0)
 DECLARE weightcnt = i2 WITH protect, noconstant(0)
 DECLARE initialcodecnt = i2 WITH protect, noconstant(0)
 DECLARE secondarycodecnt = i2 WITH protect, noconstant(0)
 DECLARE errordetailssize = i2 WITH protect, noconstant(0)
 DECLARE errordetailscnt = i2 WITH protect, noconstant(0)
 DECLARE computedcodessize = i2 WITH protect, noconstant(0)
 DECLARE computedcodecnt = i2 WITH protect, noconstant(0)
 DECLARE secondarycodessize = i2 WITH protect, noconstant(0)
 DECLARE replysecondarycodecnt = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET hstep = uar_srvselectmessage(step_id)
 SET hrequest = uar_srvcreaterequest(hstep)
 IF ( NOT (hrequest))
  SET ncodereply->transaction_status.success_ind = 0
  SET ncodereply->transaction_status.debug_error_message = concat("SrvCreateRequest for ",build(" ",
    step_id)," failed.")
  GO TO cleanup
 ENDIF
 SET stat = uar_srvsetasis(hrequest,"document",nullterm(ncoderequest->document),size(ncoderequest->
   document))
 SET stat = uar_srvsetstring(hrequest,"provider_username",nullterm(ncoderequest->provider_username))
 SET stat = uar_srvsetstring(hrequest,"service_date",nullterm(ncoderequest->service_date))
 SET stat = uar_srvsetstring(hrequest,"specialty",nullterm(ncoderequest->specialty))
 SET hactualservicetype = uar_srvgetstruct(hrequest,"actual_service_type")
 SET stat = uar_srvsetshort(hactualservicetype,"new_patient_office_visit_ind",ncoderequest->
  actual_service_type.new_patient_office_visit_ind)
 SET stat = uar_srvsetshort(hactualservicetype,"est_patient_office_visit_ind",ncoderequest->
  actual_service_type.est_patient_office_visit_ind)
 SET stat = uar_srvsetshort(hactualservicetype,"initial_inpatient_care_ind",ncoderequest->
  actual_service_type.initial_inpatient_care_ind)
 SET stat = uar_srvsetshort(hactualservicetype,"subsequent_hospital_care_ind",ncoderequest->
  actual_service_type.subsequent_hospital_care_ind)
 SET stat = uar_srvsetshort(hactualservicetype,"discharge_day_management_ind",ncoderequest->
  actual_service_type.discharge_day_management_ind)
 SET stat = uar_srvsetshort(hactualservicetype,"office_consult_ind",ncoderequest->actual_service_type
  .office_consult_ind)
 IF (validate(ncoderequest->actual_service_type.inpatient_consult_ind))
  SET stat = uar_srvsetshort(hactualservicetype,"emergency_department_ind",ncoderequest->
   actual_service_type.emergency_department_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"inpatient_consult_ind",ncoderequest->
   actual_service_type.inpatient_consult_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"observation_inpatient_care_ind",ncoderequest->
   actual_service_type.observation_inpatient_care_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"observation_discharge_ind",ncoderequest->
   actual_service_type.observation_discharge_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"initial_observation_ind",ncoderequest->
   actual_service_type.initial_observation_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"subsequent_observation_ind",ncoderequest->
   actual_service_type.subsequent_observation_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"init_inptnt_ped_crit_care_ind",ncoderequest->
   actual_service_type.init_inptnt_ped_crit_care_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"subs_inptnt_ped_crit_care_ind",ncoderequest->
   actual_service_type.subs_inptnt_ped_crit_care_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"initial_intensive_care_ind",ncoderequest->
   actual_service_type.initial_intensive_care_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"continuing_intensive_care_ind",ncoderequest->
   actual_service_type.continuing_intensive_care_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"critical_care_ind",ncoderequest->actual_service_type
   .critical_care_ind)
 ENDIF
 IF (validate(ncoderequest->actual_service_type.new_patient_prevent_med_ind))
  SET stat = uar_srvsetshort(hactualservicetype,"new_patient_prevent_med_ind",ncoderequest->
   actual_service_type.new_patient_prevent_med_ind)
  SET stat = uar_srvsetshort(hactualservicetype,"est_patient_prevent_med_ind",ncoderequest->
   actual_service_type.est_patient_prevent_med_ind)
 ENDIF
 FOR (cliniciancodecnt = 1 TO value(size(ncoderequest->clinician_code,5)))
   SET hcliniciancode = uar_srvadditem(hrequest,"clinician_code")
   SET hcodedservicetype = uar_srvgetstruct(hcliniciancode,"coded_service_type")
   SET stat = uar_srvsetshort(hcodedservicetype,"new_patient_office_visit_ind",ncoderequest->
    clinician_code[cliniciancodecnt].coded_service_type.new_patient_office_visit_ind)
   SET stat = uar_srvsetshort(hcodedservicetype,"est_patient_office_visit_ind",ncoderequest->
    clinician_code[cliniciancodecnt].coded_service_type.est_patient_office_visit_ind)
   SET stat = uar_srvsetshort(hcodedservicetype,"initial_inpatient_care_ind",ncoderequest->
    clinician_code[cliniciancodecnt].coded_service_type.initial_inpatient_care_ind)
   SET stat = uar_srvsetshort(hcodedservicetype,"subsequent_hospital_care_ind",ncoderequest->
    clinician_code[cliniciancodecnt].coded_service_type.subsequent_hospital_care_ind)
   SET stat = uar_srvsetshort(hcodedservicetype,"discharge_day_management_ind",ncoderequest->
    clinician_code[cliniciancodecnt].coded_service_type.discharge_day_management_ind)
   SET stat = uar_srvsetshort(hcodedservicetype,"office_consult_ind",ncoderequest->clinician_code[
    cliniciancodecnt].coded_service_type.office_consult_ind)
   SET stat = uar_srvsetstring(hcliniciancode,"coded_level",nullterm(ncoderequest->clinician_code[
     cliniciancodecnt].coded_level))
 ENDFOR
 SET hadditionaldata = uar_srvgetstruct(hrequest,"additional_data")
 SET stat = uar_srvsetstring(hadditionaldata,"visit_identifier",nullterm(ncoderequest->
   additional_data.visit_identifier))
 SET stat = uar_srvsetstring(hadditionaldata,"document_identifier",nullterm(ncoderequest->
   additional_data.document_identifier))
 SET hpatientinformation = uar_srvgetstruct(hadditionaldata,"patient_information")
 SET stat = uar_srvsetstring(hpatientinformation,"identifier",nullterm(ncoderequest->additional_data.
   patient_information.identifier))
 SET stat = uar_srvsetstring(hpatientinformation,"first_name",nullterm(ncoderequest->additional_data.
   patient_information.first_name))
 SET stat = uar_srvsetstring(hpatientinformation,"middle_name",nullterm(ncoderequest->additional_data
   .patient_information.middle_name))
 SET stat = uar_srvsetstring(hpatientinformation,"last_name",nullterm(ncoderequest->additional_data.
   patient_information.last_name))
 SET stat = uar_srvsetstring(hpatientinformation,"gender",nullterm(ncoderequest->additional_data.
   patient_information.gender))
 IF (validate(ncoderequest->additional_data.patient_information.name_full_formatted))
  SET stat = uar_srvsetstring(hpatientinformation,"name_full_formatted",nullterm(ncoderequest->
    additional_data.patient_information.name_full_formatted))
 ENDIF
 IF (validate(ncoderequest->additional_data.patient_information.birth_date))
  SET stat = uar_srvsetstring(hpatientinformation,"birth_date",nullterm(ncoderequest->additional_data
    .patient_information.birth_date))
  FOR (weightcnt = 1 TO value(size(ncoderequest->additional_data.patient_information.weight,5)))
    SET hweight = uar_srvadditem(hpatientinformation,"weight")
    SET stat = uar_srvsetdouble(hweight,"value",ncoderequest->additional_data.patient_information.
     weight[weightcnt].value)
    SET hweightunit = uar_srvgetstruct(hweight,"unit")
    SET star = uar_srvsetshort(hweightunit,"lbs_ind",ncoderequest->additional_data.
     patient_information.weight[weightcnt].unit.lbs_ind)
    SET star = uar_srvsetshort(hweightunit,"oz_ind",ncoderequest->additional_data.patient_information
     .weight[weightcnt].unit.oz_ind)
    SET star = uar_srvsetshort(hweightunit,"kg_ind",ncoderequest->additional_data.patient_information
     .weight[weightcnt].unit.kg_ind)
    SET star = uar_srvsetshort(hweightunit,"g_ind",ncoderequest->additional_data.patient_information.
     weight[weightcnt].unit.g_ind)
  ENDFOR
 ENDIF
 IF (validate(ncoderequest->impersonate_username))
  SET stat = uar_srvsetstring(hrequest,"impersonate_username",nullterm(ncoderequest->
    impersonate_username))
 ENDIF
 IF (validate(ncoderequest->initial_code))
  FOR (initialcodecnt = 1 TO value(size(ncoderequest->initial_code,5)))
    SET hinitialcode = uar_srvadditem(hrequest,"initial_code")
    SET stat = uar_srvsetstring(hinitialcode,"primary_code",nullterm(ncoderequest->initial_code[
      initialcodecnt].primary_code))
    FOR (secondarycodecnt = 1 TO value(size(ncoderequest->initial_code[initialcodecnt].
      secondary_codes,5)))
      SET hsecondarycode = uar_srvadditem(hinitialcode,"secondary_codes")
      SET stat = uar_srvsetstring(hsecondarycode,"code",nullterm(ncoderequest->initial_code[
        initialcodecnt].secondary_codes[secondarycodecnt].code))
      SET stat = uar_srvsetshort(hsecondarycode,"instance_cnt",ncoderequest->initial_code[
       initialcodecnt].secondary_codes[secondarycodecnt].instance_cnt)
    ENDFOR
  ENDFOR
 ENDIF
 SET hreply = uar_srvcreatereply(hstep)
 SET stat = uar_srvexecute(hstep,hrequest,hreply)
 IF (stat != 0)
  SET ncodereply->transaction_status.success_ind = 0
  SET ncodereply->transaction_status.debug_error_message = concat("SrvExecute for ",build(" ",step_id
    )," failed.")
  GO TO cleanup
 ENDIF
 SET hstatus = uar_srvgetstruct(hreply,"transaction_status")
 SET ncodereply->transaction_status.success_ind = uar_srvgetshort(hstatus,"success_ind")
 SET ncodereply->transaction_status.debug_error_message = uar_srvgetstringptr(hstatus,
  "debug_error_message")
 SET errordetailssize = uar_srvgetitemcount(hstatus,"error_details")
 IF (errordetailssize > 0)
  SET stat = alterlist(ncodereply->transaction_status.error_details,errordetailssize)
  FOR (errordetailscnt = 1 TO errordetailssize)
   SET herrordetail = uar_srvgetitem(hstatus,"error_details",(errordetailscnt - 1))
   SET ncodereply->transaction_status.error_details[errordetailscnt].error_detail =
   uar_srvgetstringptr(herrordetail,"error_detail")
  ENDFOR
 ENDIF
 SET ncodereply->transaction_uid = uar_srvgetstringptr(hreply,"transaction_uid")
 SET ncodereply->cac_code = uar_srvgetstringptr(hreply,"cac_code")
 SET ncodereply->record_id = uar_srvgetstringptr(hreply,"record_id")
 IF (validate(ncodereply->computed_codes))
  SET computedcodessize = uar_srvgetitemcount(hreply,"computed_codes")
  IF (computedcodessize > 0)
   SET stat = alterlist(ncodereply->computed_codes,computedcodessize)
   FOR (computedcodecnt = 1 TO computedcodessize)
     SET hcomputedcode = uar_srvgetitem(hreply,"computed_codes",(computedcodecnt - 1))
     SET hcomputedcodeguideline = uar_srvgetstruct(hcomputedcode,"guideline")
     SET ncodereply->computed_codes[computedcodecnt].guideline.guideline_95_ind = uar_srvgetshort(
      hcomputedcodeguideline,"guideline_95_ind")
     SET ncodereply->computed_codes[computedcodecnt].guideline.guideline_97_ind = uar_srvgetshort(
      hcomputedcodeguideline,"guideline_97_ind")
     SET hcomputedcodecode = uar_srvgetstruct(hcomputedcode,"computed_code")
     SET ncodereply->computed_codes[computedcodecnt].computed_code.primary_code = uar_srvgetstringptr
     (hcomputedcodecode,"primary_code")
     SET secondarycodessize = uar_srvgetitemcount(hcomputedcodecode,"secondary_codes")
     IF (secondarycodessize > 0)
      SET stat = alterlist(ncodereply->computed_codes[computedcodecnt].computed_code.secondary_codes,
       secondarycodessize)
      FOR (replysecondarycodecnt = 1 TO secondarycodessize)
        SET hcomputedcodesecondary = uar_srvgetitem(hcomputedcodecode,"secondary_codes",(
         replysecondarycodecnt - 1))
        SET ncodereply->computed_codes[computedcodecnt].computed_code.secondary_codes[
        replysecondarycodecnt].code = uar_srvgetstringptr(hcomputedcodesecondary,"code")
        SET ncodereply->computed_codes[computedcodecnt].computed_code.secondary_codes[
        replysecondarycodecnt].instance_cnt = uar_srvgetshort(hcomputedcodesecondary,"instance_cnt")
      ENDFOR
     ENDIF
     SET hcomputedcodeadvice = uar_srvgetstruct(hcomputedcode,"advice")
     SET ncodereply->computed_codes[computedcodecnt].advice.advice_summary = uar_srvgetstringptr(
      hcomputedcodeadvice,"advice_summary")
     SET ncodereply->computed_codes[computedcodecnt].advice.full_advice = uar_srvgetstringptr(
      hcomputedcodeadvice,"full_advice")
   ENDFOR
  ENDIF
 ENDIF
#cleanup
 CALL uar_srvdestroyinstance(hrequest)
 CALL uar_srvdestroyinstance(hreply)
 CALL uar_srvdestroymessage(hstep)
END GO
