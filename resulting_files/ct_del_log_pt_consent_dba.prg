CREATE PROGRAM ct_del_log_pt_consent:dba
 RECORD reply(
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE continue_flag = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE lst_updt_dt_tm_str = vc WITH public, noconstant("")
 DECLARE pt_cons_id = f8 WITH protect, noconstant(0.0)
 DECLARE participant_name = vc WITH public, noconstant("")
 DECLARE cons_id_str = vc WITH public, noconstant("")
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET continue_flag = 0
 SET fail_flag = 0
 DECLARE lock_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE insert_error = i2 WITH private, constant(20)
 CALL echo(build("ECHO   Request->ConsentID = ",request->consentid))
 CALL echo(build("ECHO   lock  rows to update"))
 SELECT INTO "nl:"
  p_cn.*
  FROM pt_consent p_cn
  WHERE (p_cn.consent_id=request->consentid)
   AND p_cn.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
  DETAIL
   pt_cons_id = p_cn.consent_id, person_id = p_cn.person_id, lst_updt_dt_tm_str = build(
    "LST_UPDT_DT_TM: ",datetimezoneformat(p_cn.updt_dt_tm,0,"MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef
     ))
  WITH forupdate(p_cn)
 ;end select
 CALL echo(build("ECHO   (after LOCK of pt_consent) curqual =",curqual))
 IF (curqual > 0)
  SET continue_flag = 1
  CALL echo("Passed Lock Consent")
 ELSE
  SET continue_flag = 0
  SET fail_flag = lock_error
  SET reply->status_data.status = "L"
  CALL echo("Failed Lock Consent")
 ENDIF
 IF (continue_flag=1)
  UPDATE  FROM pt_consent p_cn
   SET p_cn.end_effective_dt_tm = cnvtdatetime(sysdate), p_cn.updt_cnt = (p_cn.updt_cnt+ 1), p_cn
    .updt_applctx = reqinfo->updt_applctx,
    p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id = reqinfo->updt_id, p_cn.updt_dt_tm =
    cnvtdatetime(sysdate)
   WHERE (p_cn.consent_id=request->consentid)
    AND p_cn.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
   WITH nocounter
  ;end update
  IF (curqual > 0)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   CALL echo("Passed Update Consent")
  ELSE
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
   SET fail_flag = update_error
   CALL echo("Failed Update Consent")
  ENDIF
  CALL echo(build("ECHO   (after UPDATE of pt_consent)   curqual =",curqual))
 ENDIF
 IF (fail_flag=0)
  INSERT  FROM ct_reason_deleted del
   SET del.reg_id = 0, del.ct_reason_del_id = seq(protocol_def_seq,nextval), del.deletion_dt_tm =
    cnvtdatetime(sysdate),
    del.deletion_prsnl_id = reqinfo->updt_id, del.deletion_reason = request->reason, del
    .pt_elig_tracking_id = 0,
    del.consent_id = request->consentid, del.updt_cnt = 0, del.updt_applctx = reqinfo->updt_applctx,
    del.updt_task = reqinfo->updt_task, del.updt_id = reqinfo->updt_id, del.updt_dt_tm = cnvtdatetime
    (sysdate),
    del.active_ind = 1, del.active_status_cd = reqdata->active_status_cd, del.active_status_dt_tm =
    cnvtdatetime(sysdate),
    del.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error inserting into ct_reason_deleted table."
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
   CALL echo("Failed inserting reason")
  ELSE
   SET cons_id_str = build3(3,"Consent_ID: ",pt_cons_id)
   SET participant_name = concat(cons_id_str," ",lst_updt_dt_tm_str," (UPDT_DT_TM)")
   EXECUTE cclaudit audit_mode, request->auditname, "Delete",
   "Person", "Patient", "Patient",
   "Destruction", person_id, participant_name
  ENDIF
 ENDIF
 CALL echo(build("ECHO   Status = ",reply->status_data.status))
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
 SET last_mod = "003"
 SET mod_date = "July 17, 2019"
END GO
