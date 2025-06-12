CREATE PROGRAM cac_resolve_record:dba
 RECORD ncodereply(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
     2 error_details[*]
       3 error_detail = vc
   1 transaction_uid = vc
 )
 DECLARE step_id = i4 WITH protect, constant(3070031)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hdiagnosis = i4 WITH protect, noconstant(0)
 DECLARE hdiagnosisterminology = i4 WITH protect, noconstant(0)
 DECLARE hprocedure = i4 WITH protect, noconstant(0)
 DECLARE hprocedureterminology = i4 WITH protect, noconstant(0)
 DECLARE hresolvecode = i4 WITH protect, noconstant(0)
 DECLARE hsecondarycode = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 DECLARE herrordetail = i4 WITH protect, noconstant(0)
 DECLARE diagnosescnt = i2 WITH protect, noconstant(0)
 DECLARE diagnosestermcnt = i2 WITH protect, noconstant(0)
 DECLARE procedurescnt = i2 WITH protect, noconstant(0)
 DECLARE procedurestermcnt = i2 WITH protect, noconstant(0)
 DECLARE secondarycodescnt = i2 WITH protect, noconstant(0)
 DECLARE errordetailssize = i2 WITH protect, noconstant(0)
 DECLARE errordetailscnt = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET hstep = uar_srvselectmessage(step_id)
 SET hrequest = uar_srvcreaterequest(hstep)
 IF ( NOT (hrequest))
  SET ncodereply->transaction_status.success_ind = 0
  SET ncodereply->transaction_status.debug_error_message = concat("SrvCreateRequest for ",build(" ",
    step_id)," failed.")
  GO TO cleanup
 ENDIF
 SET stat = uar_srvsetstring(hrequest,"record_id",nullterm(ncoderequest->record_id))
 SET stat = uar_srvsetstring(hrequest,"final_code",nullterm(ncoderequest->final_code))
 FOR (diagnosescnt = 1 TO value(size(ncoderequest->diagnoses,5)))
   SET hdiagnosis = uar_srvadditem(hrequest,"diagnoses")
   SET stat = uar_srvsetstring(hdiagnosis,"code",nullterm(ncoderequest->diagnoses[diagnosescnt].code)
    )
   IF (validate(ncoderequest->diagnoses[diagnosescnt].terminology_type))
    FOR (diagnosestermcnt = 1 TO value(size(ncoderequest->diagnoses[diagnosescnt].terminology_type,5)
     ))
      SET hdiagnosesterminology = uar_srvadditem(hdiagnosis,"terminology_type")
      SET stat = uar_srvsetshort(hdiagnosesterminology,"icd9_ind",ncoderequest->diagnoses[
       diagnosescnt].terminology_type[diagnosestermcnt].icd9_ind)
      SET stat = uar_srvsetshort(hdiagnosesterminology,"icd10_ind",ncoderequest->diagnoses[
       diagnosescnt].terminology_type[diagnosestermcnt].icd10_ind)
    ENDFOR
   ENDIF
 ENDFOR
 FOR (procedurescnt = 1 TO value(size(ncoderequest->procedures,5)))
   SET hprocedure = uar_srvadditem(hrequest,"procedures")
   CALL echo(ncoderequest->procedures[procedurescnt].code)
   SET stat = uar_srvsetstring(hprocedure,"code",nullterm(ncoderequest->procedures[procedurescnt].
     code))
   IF (validate(ncoderequest->procedures[procedurescnt].terminology_type))
    FOR (procedurestermcnt = 1 TO value(size(ncoderequest->procedures[procedurescnt].terminology_type,
      5)))
     SET hprocedureterminology = uar_srvadditem(hprocedure,"terminology_type")
     SET stat = uar_srvsetshort(hprocedureterminology,"cpt_ind",ncoderequest->procedures[
      procedurescnt].terminology_type[procedurestermcnt].cpt_ind)
    ENDFOR
   ENDIF
 ENDFOR
 IF (validate(ncoderequest->resolve_code))
  SET hresolvecode = uar_srvgetstruct(hrequest,"resolve_code")
  SET stat = uar_srvsetstring(hresolvecode,"primary_code",nullterm(ncoderequest->resolve_code.
    primary_code))
  FOR (secondarycodescnt = 1 TO value(size(ncoderequest->resolve_code.secondary_codes,5)))
    SET hsecondarycode = uar_srvadditem(hresolvecode,"secondary_codes")
    SET stat = uar_srvsetstring(hsecondarycode,"code",nullterm(ncoderequest->resolve_code.
      secondary_codes[secondarycodescnt].code))
    SET stat = uar_srvsetshort(hsecondarycode,"instance_cnt",ncoderequest->resolve_code.
     secondary_codes[secondarycodescnt].instance_cnt)
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
#cleanup
 CALL uar_srvdestroyinstance(hrequest)
 CALL uar_srvdestroyinstance(hreply)
 CALL uar_srvdestroymessage(hstep)
END GO
