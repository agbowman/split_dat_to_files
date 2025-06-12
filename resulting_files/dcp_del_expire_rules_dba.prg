CREATE PROGRAM dcp_del_expire_rules:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ex_rule_cnt = cnvtint(size(request->expire_rule,5))
 DELETE  FROM rule_definition rd,
   (dummyt d1  WITH seq = value(ex_rule_cnt))
  SET rd.seq = 1
  PLAN (d1)
   JOIN (rd
   WHERE (rd.parent_entity_id=request->expire_rule[d1.seq].rule_id)
    AND rd.parent_entity_name="EXPIRE_RULE")
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 UPDATE  FROM expire_rule er,
   rule_audit ra,
   (dummyt d2  WITH seq = value(ex_rule_cnt))
  SET er.active_ind = 0, er.obsolete_ind = 1
  PLAN (d2)
   JOIN (er
   WHERE (er.expire_rule_id=request->expire_rule[d2.seq].rule_id))
   JOIN (ra
   WHERE ra.parent_entity_name="EXPIRE_RULE"
    AND ra.rule_audit_id=er.expire_rule_id)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 DELETE  FROM expire_rule er,
   (dummyt d3  WITH seq = value(ex_rule_cnt))
  SET er.seq = 1
  PLAN (d3)
   JOIN (er
   WHERE (er.expire_rule_id=request->expire_rule[d3.seq].rule_id)
    AND er.obsolete_ind=0)
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus.operationname = "Delete Rules"
  SET reply->status_data.subeventstatus.targetobjectname = "Table:EXPIRE_RULE;RULE_DEFINITION"
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_del_rules.prg"
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus.operationname = "Delete_Rules"
  SET reply->status_data.subeventstatus.targetobjectname = "Table:EXPIRE_RULE;RULE_DEFINITION"
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_del_rules.prg"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
