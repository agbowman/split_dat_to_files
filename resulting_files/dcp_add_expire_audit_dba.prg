CREATE PROGRAM dcp_add_expire_audit:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE ex_audit_id = f8 WITH noconstant
 DECLARE ex_audit_cnt = i4 WITH noconstant
 SET reply->status_data.status = "S"
 SET ex_audit_id = 0
 SET ex_audit_cnt = cnvtint(size(request->expire_rule,5))
 FOR (x = 1 TO ex_audit_cnt)
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     ex_audit_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   INSERT  FROM rule_audit ra
    SET ra.rule_audit_id = ex_audit_id, ra.parent_entity_id = request->expire_rule[x].rule_id, ra
     .parent_entity_name = "EXPIRE_RULE",
     ra.parameter_definition = substring(1,250,request->expire_rule[x].rule_parameter), ra
     .run_prsnl_id = request->expire_rule[x].run_prsnl_id, ra.run_dt_tm = cnvtdatetime(request->
      expire_rule[x].run_dt_tm),
     ra.run_type_flag = request->expire_rule[x].run_type, ra.rows_updated = request->expire_rule[x].
     rows_updated
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus.operationname = "Add Audit"
  SET reply->status_data.subeventstatus.targetobjectname = "Table:RULE_AUDIT"
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_add_expire_audit.prg"
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus.operationname = "Add Audit"
  SET reply->status_data.subeventstatus.targetobjectname = "Table:RULE_AUDIT"
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_add_expire_audit.prg"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
