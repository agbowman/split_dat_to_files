CREATE PROGRAM cac_get_users_audit_report:dba
 RECORD ncodereply(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 transaction_uid = vc
   1 audit_report = gvc
 )
 DECLARE step_id = i4 WITH protect, constant(3070030)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hguideline = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 DECLARE usercnt = i2 WITH protect, noconstant(0)
 DECLARE reportsize = i4 WITH protect, noconstant(0)
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
 IF (validate(ncoderequest->guideline))
  SET hguideline = uar_srvgetstruct(hrequest,"guideline")
  SET stat = uar_srvsetshort(hguideline,"guideline_95_ind",ncoderequest->guideline.guideline_95_ind)
  SET stat = uar_srvsetshort(hguideline,"guideline_97_ind",ncoderequest->guideline.guideline_97_ind)
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
 SET ncodereply->transaction_uid = uar_srvgetstringptr(hreply,"transaction_uid")
 SET reportsize = uar_srvgetasissize(hreply,"audit_report")
 SET ncodereply->audit_report = substring(1,reportsize,uar_srvgetasisptr(hreply,"audit_report"))
#cleanup
 CALL uar_srvdestroyinstance(hrequest)
 CALL uar_srvdestroyinstance(hreply)
 CALL uar_srvdestroymessage(hstep)
END GO
