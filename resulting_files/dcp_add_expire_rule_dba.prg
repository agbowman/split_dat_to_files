CREATE PROGRAM dcp_add_expire_rule:dba
 RECORD reply(
   1 expire_rule[*]
     2 rule_id = f8
     2 rule_name = vc
     2 prsnl_id = f8
     2 rule_dt_tm = dq8
     2 active_ind = i2
     2 authentic_flag_ind = i2
     2 rule_definition[*]
       3 rule_definition_id = f8
       3 rule_type_cd = f8
       3 param_name = vc
       3 param_value = vc
       3 merge_name = vc
       3 merge_id = f8
       3 loc_facility_cd = f8
       3 seq_num = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ex_rule_id = f8 WITH noconstant
 DECLARE ex_rule_cnt = i4 WITH noconstant
 DECLARE rule_def_id = f8 WITH noconstant
 SET reply->status_data.status = "S"
 SET ex_rule_id = 0
 SET ex_rule_cnt = cnvtint(size(request->expire_rule,5))
 SET stat = alterlist(reply->expire_rule,ex_rule_cnt)
 CALL echo(build("ex_rule_cnt = ",ex_rule_cnt))
 FOR (x = 1 TO ex_rule_cnt)
   CALL echo(build("x",x))
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     ex_rule_id = cnvtreal(j), reply->expire_rule[x].rule_id = ex_rule_id
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   CALL echo(build("ex_rule_id",request->expire_rule[x].rule_name))
   SET reply->expire_rule[x].rule_name = request->expire_rule[x].rule_name
   SET reply->expire_rule[x].prsnl_id = request->expire_rule[x].prsnl_id
   SET reply->expire_rule[x].rule_dt_tm = cnvtdatetime(request->expire_rule[x].rule_dt_tm)
   SET reply->expire_rule[x].active_ind = request->expire_rule[x].active_ind
   SET reply->expire_rule[x].authentic_flag_ind = request->expire_rule[x].authentic_flag_ind
   INSERT  FROM expire_rule er
    SET er.expire_rule_id = ex_rule_id, er.rule_name = request->expire_rule[x].rule_name, er.prsnl_id
      = request->expire_rule[x].prsnl_id,
     er.rule_dt_tm = cnvtdatetime(request->expire_rule[x].rule_dt_tm), er.active_ind = request->
     expire_rule[x].active_ind, er.active_dt_tm = cnvtdatetime(curdate,curtime3),
     er.active_status_prsnl_id = reqinfo->updt_id, er.active_status_cd = reqdata->active_status_cd,
     er.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     er.updt_id = reqinfo->updt_id, er.updt_task = reqinfo->updt_task, er.updt_applctx = reqinfo->
     updt_applctx,
     er.updt_cnt = 0, er.authentic_flag_ind = request->expire_rule[x].authentic_flag_ind, er
     .obsolete_ind = 0
    WITH nocounter
   ;end insert
   CALL echo(build("ex_rule_id2",reply->expire_rule[1].rule_name))
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   SET rule_def_id = 0
   SET rule_def_cnt = cnvtint(size(request->expire_rule[x].rule_definition,5))
   SET stat = alterlist(reply->expire_rule[x].rule_definition,rule_def_cnt)
   IF (rule_def_cnt > 0)
    INSERT  FROM rule_definition rd,
      (dummyt d1  WITH seq = value(rule_def_cnt))
     SET rd.rule_definition_id = seq(carenet_seq,nextval), rd.parent_entity_id = ex_rule_id, rd
      .parent_entity_name = "EXPIRE_RULE",
      rd.rule_type_cd = request->expire_rule[x].rule_definition[d1.seq].rule_type_cd, rd.param_name
       = request->expire_rule[x].rule_definition[d1.seq].param_name, rd.param_value = request->
      expire_rule[x].rule_definition[d1.seq].param_value,
      rd.merge_name = request->expire_rule[x].rule_definition[d1.seq].merge_name, rd.merge_id =
      request->expire_rule[x].rule_definition[d1.seq].merge_id, rd.loc_facility_cd = request->
      expire_rule[x].rule_definition[d1.seq].loc_facility_cd,
      rd.seq_num = request->expire_rule[x].rule_definition[d1.seq].seq_num, rd.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), rd.updt_id = reqinfo->updt_id,
      rd.updt_task = reqinfo->updt_task, rd.updt_applctx = reqinfo->updt_applctx, rd.updt_cnt = 0,
      reply->expire_rule[x].rule_definition[d1.seq].rule_type_cd = request->expire_rule[x].
      rule_definition[d1.seq].rule_type_cd, reply->expire_rule[x].rule_definition[d1.seq].
      rule_definition_id = rule_def_id, reply->expire_rule[x].rule_definition[d1.seq].param_name =
      request->expire_rule[x].rule_definition[d1.seq].param_name,
      reply->expire_rule[x].rule_definition[d1.seq].param_value = request->expire_rule[x].
      rule_definition[d1.seq].param_value, reply->expire_rule[x].rule_definition[d1.seq].merge_name
       = request->expire_rule[x].rule_definition[d1.seq].merge_name, reply->expire_rule[x].
      rule_definition[d1.seq].merge_id = request->expire_rule[x].rule_definition[d1.seq].merge_id,
      reply->expire_rule[x].rule_definition[d1.seq].loc_facility_cd = request->expire_rule[x].
      rule_definition[d1.seq].loc_facility_cd, reply->expire_rule[x].rule_definition[d1.seq].seq_num
       = request->expire_rule[x].rule_definition[d1.seq].seq_num
     PLAN (d1)
      JOIN (rd)
     WITH counter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus.operationname = "Add Rules"
  SET reply->status_data.subeventstatus.targetobjectname = "Table:EXPIRE_RULE;RULE_DEFINITION"
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_add_expire_rule.prg"
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus.operationname = "Add Rules"
  SET reply->status_data.subeventstatus.targetobjectname = "Table:EXPIRE_RULE;RULE_DEFINITION"
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_add_expire_rule.prg"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET stat = alterlist(reply->expire_rule,- (ex_rule_cnt))
 ENDIF
 CALL echorecord(reply)
END GO
