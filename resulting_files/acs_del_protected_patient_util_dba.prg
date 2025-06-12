CREATE PROGRAM acs_del_protected_patient_util:dba
 FREE RECORD registration_request
 RECORD registration_request(
   1 person_id = f8
   1 encntr_id = f8
   1 transaction_id = f8
   1 pm_hist_tracking_id = f8
   1 transaction_dt_tm = dq8
   1 transaction_type_txt = vc
   1 swap_person_id = f8
   1 swap_encntr_id = f8
   1 swap_transaction_id = f8
 )
 IF (validate(request->patientid)=1)
  SET registration_request->person_id = request->patientid
 ENDIF
 IF (validate(request->encounterid)=1)
  SET registration_request->encntr_id = request->encounterid
 ENDIF
 IF (validate(request->transactionid)=1)
  SET registration_request->transaction_id = request->transactionid
 ENDIF
 IF (validate(request->transactionhistoryid)=1)
  SET registration_request->pm_hist_tracking_id = request->transactionhistoryid
 ENDIF
 IF (validate(request->transactiondatetime)=1)
  SET registration_request->transaction_dt_tm = request->transactiondatetime
 ENDIF
 IF (validate(request->transactiontype)=1)
  SET registration_request->transaction_type_txt = request->transactiontype
 ENDIF
 IF (validate(request->swappatientid)=1)
  SET registration_request->swap_person_id = request->swappatientid
 ENDIF
 IF (validate(request->swapencounterid)=1)
  SET registration_request->swap_encntr_id = request->swapencounterid
 ENDIF
 IF (validate(request->swaptransactionid)=1)
  SET registration_request->swap_transaction_id = request->swaptransactionid
 ENDIF
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET registration_request->person_id = cnvtreal( $1)
 IF (validate(xxcclseclogin)=1)
  IF ((xxcclseclogin->loggedin != 1))
   EXECUTE cclseclogin
  ENDIF
 ENDIF
 EXECUTE acs_del_protected_patient
#exit_script
 IF ((reply->status_data.status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 CALL echorecord(reply)
END GO
