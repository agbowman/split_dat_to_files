CREATE PROGRAM ct_chg_pt_interest_settings:dba
 DECLARE prmpt_person_id = f8 WITH protect, constant(cnvtreal(value(parameter(1,0))))
 DECLARE prmpt_not_interested_ind = i2 WITH protect, constant(evaluate(cnvtint(value(parameter(2,0))),
   true,false,true))
 DECLARE filename = vc WITH protect, constant(build(cnvtlower(curprog),"_logging_",format(curdate,
    "MMDDYYYY;;D"),".dat"))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE last_mod = vc WITH protect, noconstant("")
 FREE RECORD ct_request
 RECORD ct_request(
   1 not_interested_ind = i2
   1 person_id = f8
 )
 FREE RECORD ct_reply
 RECORD ct_reply(
   1 not_interested_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET retval = - (1)
 SET log_message = build2("Error in ",curprog)
 IF (prmpt_person_id <= 0.0)
  SET retval = - (1)
  SET log_message = build("Invalid Person ID (",prmpt_person_id,
   "). Please enter a valid person ID as parameter 1")
  GO TO exit_script
 ENDIF
 SET ct_request->person_id = prmpt_person_id
 SET ct_request->not_interested_ind = prmpt_not_interested_ind
 EXECUTE ct_chg_pt_settings  WITH replace("REQUEST",ct_request), replace("REPLY",ct_reply)
 CASE (ct_reply->status_data.status)
  OF "S":
   SET retval = 100
   SET log_message = "The pre-screening interest field was successfully updated."
  OF "Z":
   SET retval = 0
   SET log_message = "The pre-screening interest field was not updated."
  ELSE
   SET retval = - (1)
   SET log_message = "The pre-screening interest field failed to update."
 ENDCASE
#exit_script
 IF (validate(ekmlog_ind,- (1)) > 0)
  CALL echo(concat("filename: ",filename))
  CALL echorecord(eksdata,filename,1)
  CALL echorecord(request,filename,1)
  CALL echorecord(ct_request,filename,1)
  CALL echorecord(ct_reply,filename,1)
  CALL echorecord(reply,filename,1)
 ENDIF
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET log_message = build2("Error: ",errmsg)
  SET retval = - (1)
 ENDIF
 CALL echo(log_message)
 SET last_mod = "000 04/09/2014 ML011047"
END GO
