CREATE PROGRAM ct_conmngr_cancel_transfer:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 RECORD reply(
   1 reason_for_failure = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET transcancelcd = 0.0
 SET transcancel = 0.0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 RECORD c(
   1 consent[*]
     2 pt_consent_id = f8
 )
 SELECT INTO "nl:"
  prcr.pt_reg_consent_reltn_id
  FROM pt_reg_consent_reltn prcr,
   pt_consent pc
  PLAN (prcr
   WHERE (prcr.reg_id=request->regid))
   JOIN (pc
   WHERE pc.consent_id=prcr.consent_id
    AND (pc.prot_amendment_id=request->amendid)
    AND pc.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND pc.not_returned_reason_cd=0.0)
  DETAIL
   count += 1, stat = alterlist(c->consent,count), c->consent[count].pt_consent_id = pc.pt_consent_id,
   CALL echo(build("C->Consent[",count,"]->Pt_Consent_Id  =",c->consent[count].pt_consent_id))
  WITH nocounter
 ;end select
 CALL echo(build("Count =",count))
 CALL echo(build("AFTER GETTING CONSENT ID's - curqual =",curqual))
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->reason_for_failure = "No consent found for this registration"
  GO TO exit_script
 ENDIF
 SET cset = 17281
 SET cmean = "TRANSCANCEL"
 EXECUTE ct_get_cv
 SET transcancel = cval
 UPDATE  FROM pt_consent pc,
   (dummyt d  WITH seq = value(count))
  SET pc.not_returned_reason_cd = transcancel, pc.not_returned_dt_tm = cnvtdatetime(sysdate), pc
   .updt_cnt = (pc.updt_cnt+ 1),
   pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->
   updt_task,
   pc.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (pc
   WHERE (pc.pt_consent_id=c->consent[d.seq].pt_consent_id))
  WITH nocounter
 ;end update
 CALL echo(build("AFTER UPDATING CONSENT ID's - curqual =",curqual))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->reason_for_failure = "Failure to update Pt_Consent table"
 ENDIF
#exit_script
 CALL echo(build("Status:",reply->status_data.status))
 IF ((reply->status_data.status="F"))
  CALL echo(build("reason for failure:",reply->reason_for_failure))
 ENDIF
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
