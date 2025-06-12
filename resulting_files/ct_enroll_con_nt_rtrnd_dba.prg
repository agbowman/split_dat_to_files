CREATE PROGRAM ct_enroll_con_nt_rtrnd:dba
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
 RECORD c(
   1 currentdatetime = dq8
   1 prot_amendment_id = f8
   1 consent_id = f8
   1 pt_consent_id = f8
   1 consenting_person_id = f8
   1 consenting_organization_id = f8
   1 consent_released_dt_tm = dq8
   1 consent_signed_dt_tm = dq8
   1 consent_received_dt_tm = dq8
   1 consent_nbr = i4
   1 updt_cnt = i4
   1 not_returned_dt_tm = dq8
   1 not_returned_reason_cd = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 not_returned_dt_tm = dq8
   1 not_returned_reason_cd = f8
   1 reason_for_consent_cd = f8
 )
 SET reply->status_data.status = "F"
 SET false = 0
 SET true = 1
 SET continue = 0
 SET conid = 0.0
 SET enrolling = 0.0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET cset = 17349
 SET cmean = "ENROLLING"
 EXECUTE ct_get_cv
 SET enrolling = cval
 SELECT INTO "nl:"
  p_cn.*
  FROM pt_consent p_cn
  WHERE (p_cn.consent_id=request->consent_id)
   AND p_cn.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   AND p_cn.reason_for_consent_cd=enrolling
  DETAIL
   c->currentdatetime = cnvtdatetime(curdate,curtime3), c->pt_consent_id = p_cn.pt_consent_id, c->
   consent_id = p_cn.consent_id,
   c->consenting_person_id = p_cn.consenting_person_id, c->consenting_organization_id = p_cn
   .consenting_organization_id, c->consent_released_dt_tm = p_cn.consent_released_dt_tm,
   c->consent_signed_dt_tm = p_cn.consent_signed_dt_tm, c->consent_received_dt_tm = p_cn
   .consent_received_dt_tm, c->consent_nbr = p_cn.consent_nbr,
   c->updt_cnt = p_cn.updt_cnt, c->beg_effective_dt_tm = p_cn.beg_effective_dt_tm, c->
   end_effective_dt_tm = p_cn.end_effective_dt_tm,
   c->not_returned_dt_tm = p_cn.not_returned_dt_tm, c->not_returned_reason_cd = p_cn
   .not_returned_reason_cd, c->prot_amendment_id = p_cn.prot_amendment_id,
   c->reason_for_consent_cd = p_cn.reason_for_consent_cd
  WITH nocounter, forupdate(p_cn)
 ;end select
 IF (curqual=1)
  SET continue = true
 ELSE
  SET continue = false
  SET reply->status_data.status = "L"
 ENDIF
 IF (continue=true)
  UPDATE  FROM pt_consent p_cn
   SET p_cn.end_effective_dt_tm = cnvtdatetime(c->currentdatetime), p_cn.updt_cnt = (p_cn.updt_cnt+ 1
    ), p_cn.updt_applctx = reqinfo->updt_applctx,
    p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id = reqinfo->updt_id, p_cn.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   WHERE (p_cn.pt_consent_id=c->pt_consent_id)
   WITH nocounter
  ;end update
  IF (curqual != 1)
   SET reply->status_data.status = "F"
   SET continue = false
  ENDIF
  IF (continue=true)
   CALL echo("ECHO   Get Unique ID for Consent")
   SELECT INTO "nl:"
    num = seq(protocol_def_seq,nextval)"########################;rpO"
    FROM dual
    DETAIL
     conid = cnvtreal(num)
    WITH format, counter
   ;end select
   INSERT  FROM pt_consent p_cn
    SET p_cn.prot_amendment_id = c->prot_amendment_id, p_cn.consenting_person_id = c->
     consenting_person_id, p_cn.consenting_organization_id = c->consenting_organization_id,
     p_cn.consent_released_dt_tm = cnvtdatetime(c->consent_released_dt_tm), p_cn.consent_signed_dt_tm
      = cnvtdatetime(c->consent_signed_dt_tm), p_cn.consent_received_dt_tm = cnvtdatetime(c->
      consent_received_dt_tm),
     p_cn.consent_nbr = c->consent_nbr, p_cn.not_returned_dt_tm = cnvtdatetime(request->
      not_returned_dt_tm), p_cn.not_returned_reason_cd = request->not_returned_reason_cd,
     p_cn.beg_effective_dt_tm = cnvtdatetime(c->currentdatetime), p_cn.end_effective_dt_tm =
     cnvtdatetime("31-DEC-2100 00:00:00.00"), p_cn.pt_consent_id = conid,
     p_cn.consent_id = c->consent_id, p_cn.reason_for_consent_cd = c->reason_for_consent_cd, p_cn
     .updt_cnt = 0,
     p_cn.updt_applctx = reqinfo->updt_applctx, p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id =
     reqinfo->updt_id,
     p_cn.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
    SET continue = false
   ENDIF
  ENDIF
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echo(build("Status = ",reply->status_data.status))
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
