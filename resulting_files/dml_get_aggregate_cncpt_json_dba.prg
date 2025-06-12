CREATE PROGRAM dml_get_aggregate_cncpt_json:dba
 RECORD ncodereply(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 transaction_uid = vc
   1 json = gvc
 )
 DECLARE step_id = i4 WITH protect, constant(3070041)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hterminologies = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 DECLARE jsonsize = i4 WITH protect, noconstant(0)
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
 SET hterminologies = uar_srvgetstruct(hrequest,"terminologies")
 SET stat = uar_srvsetshort(hterminologies,"snomed_ind",ncoderequest->terminologies.snomed_ind)
 SET stat = uar_srvsetshort(hterminologies,"cpt_ind",ncoderequest->terminologies.cpt_ind)
 SET stat = uar_srvsetshort(hterminologies,"icd9_ind",ncoderequest->terminologies.icd9_ind)
 SET stat = uar_srvsetshort(hterminologies,"icd10cm_ind",ncoderequest->terminologies.icd10cm_ind)
 SET stat = uar_srvsetshort(hterminologies,"icd10pcs_ind",ncoderequest->terminologies.icd10pcs_ind)
 SET stat = uar_srvsetshort(hterminologies,"multum_ind",ncoderequest->terminologies.multum_ind)
 SET stat = uar_srvsetshort(hterminologies,"hpo_ind",ncoderequest->terminologies.hpo_ind)
 SET stat = uar_srvsetshort(hterminologies,"custom_ind",ncoderequest->terminologies.custom_ind)
 SET stat = uar_srvsetstring(hterminologies,"custom_vocab_name",nullterm(ncoderequest->terminologies.
   custom_vocab_name))
 SET stat = uar_srvsetstring(hrequest,"visit_date",nullterm(ncoderequest->visit_date))
 SET stat = uar_srvsetstring(hrequest,"specialty",nullterm(ncoderequest->specialty))
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
 SET jsonsize = uar_srvgetasissize(hreply,"json")
 SET ncodereply->json = substring(1,jsonsize,uar_srvgetasisptr(hreply,"json"))
#cleanup
 CALL uar_srvdestroyinstance(hrequest)
 CALL uar_srvdestroyinstance(hreply)
 CALL uar_srvdestroymessage(hstep)
END GO
