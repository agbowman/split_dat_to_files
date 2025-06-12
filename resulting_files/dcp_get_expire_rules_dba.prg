CREATE PROGRAM dcp_get_expire_rules:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 expire_rule[*]
      2 expire_rule_id = f8
      2 rule_name = vc
      2 prsnl_id = f8
      2 rule_dt_tm = dq8
      2 active_ind = i2
      2 authentic_flag_ind = i2
      2 rule_definition[*]
        3 rule_definition_id = f8
        3 parent_entity_id = f8
        3 parent_entity_name = vc
        3 rule_type_cd = f8
        3 param_name = vc
        3 param_value = vc
        3 merge_name = vc
        3 merge_id = f8
        3 location_cd = f8
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
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT
  IF ((request->prsnl_id > 0))
   FROM expire_rule er,
    rule_definition rd
   PLAN (er
    WHERE (er.prsnl_id=request->prsnl_id)
     AND er.obsolete_ind=0)
    JOIN (rd
    WHERE rd.parent_entity_id=er.expire_rule_id)
  ELSE
   FROM expire_rule er,
    rule_definition rd
   PLAN (er
    WHERE er.obsolete_ind=0)
    JOIN (rd
    WHERE rd.parent_entity_id=er.expire_rule_id)
  ENDIF
  INTO "nl:"
  er.expire_rule_id, er.rule_name, er.prsnl_id,
  er.rule_dt_tm, er.active_ind, er.authentic_flag_ind,
  rd.rule_definition_id, rd.parent_entity_id, rd.parent_entity_name,
  rd.rule_type_cd, rd.param_name, rd.param_value,
  rd.merge_name, rd.merge_id, rd.seq_num
  ORDER BY er.expire_rule_id, rd.rule_type_cd
  HEAD REPORT
   count1 = 0
  HEAD er.expire_rule_id
   count1 = (count1+ 1), count2 = 0
   IF (count1 > size(reply->expire_rule,5))
    stat = alterlist(reply->expire_rule,count1)
   ENDIF
   reply->expire_rule[count1].expire_rule_id = er.expire_rule_id, reply->expire_rule[count1].
   rule_name = er.rule_name, reply->expire_rule[count1].prsnl_id = er.prsnl_id,
   reply->expire_rule[count1].rule_dt_tm = er.rule_dt_tm, reply->expire_rule[count1].active_ind = er
   .active_ind, reply->expire_rule[count1].authentic_flag_ind = er.authentic_flag_ind,
   CALL echo(build("filled into E.Rule table")),
   CALL echo(reply->expire_rule[count1].expire_rule_id)
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->expire_rule[count1].rule_definition,count2), reply->
   expire_rule[count1].rule_definition[count2].rule_definition_id = rd.rule_definition_id,
   reply->expire_rule[count1].rule_definition[count2].parent_entity_id = rd.parent_entity_id, reply->
   expire_rule[count1].rule_definition[count2].parent_entity_name = rd.parent_entity_name, reply->
   expire_rule[count1].rule_definition[count2].rule_type_cd = rd.rule_type_cd,
   reply->expire_rule[count1].rule_definition[count2].param_name = rd.param_name, reply->expire_rule[
   count1].rule_definition[count2].param_value = rd.param_value, reply->expire_rule[count1].
   rule_definition[count2].merge_name = rd.merge_name,
   reply->expire_rule[count1].rule_definition[count2].merge_id = rd.merge_id, reply->expire_rule[
   count1].rule_definition[count2].loc_facility_cd = rd.loc_facility_cd, reply->expire_rule[count1].
   rule_definition[count2].location_cd = rd.location_cd,
   reply->expire_rule[count1].rule_definition[count2].seq_num = rd.seq_num,
   CALL echo(build("filled into Rule def table"))
  FOOT  er.expire_rule_id
   stat = alterlist(reply->expire_rule[count1].rule_definition,count2)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->expire_rule,count1)
 IF (count1=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
