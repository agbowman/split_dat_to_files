CREATE PROGRAM afc_ct_get_rules:dba
 DECLARE afc_ct_get_rules_version = vc WITH private, noconstant("318193.FT.001")
 RECORD reply(
   1 rule_cnt = i4
   1 rules[*]
     2 rule_id = f8
     2 ruleset_id = f8
     2 rule_name = vc
     2 long_text_id = f8
     2 long_text = vc
     2 priority_nbr = i4
     2 process_ind = i2
     2 rule_beg_dt_tm = dq8
     2 rule_end_dt_tm = dq8
     2 active_ind = i2
     2 updt_cnt = i4
     2 charge_status_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM cs_cpp_rule r,
   long_text_reference l
  PLAN (r
   WHERE r.cs_cpp_rule_id != 0
    AND r.active_ind=1)
   JOIN (l
   WHERE l.long_text_id=outerjoin(r.long_text_id))
  ORDER BY r.cs_cpp_ruleset_id, r.priority_nbr
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->rules,cnt), reply->rules[cnt].rule_id = r.cs_cpp_rule_id,
   reply->rules[cnt].ruleset_id = r.cs_cpp_ruleset_id, reply->rules[cnt].rule_name = r.rule_name,
   reply->rules[cnt].long_text_id = l.long_text_id,
   reply->rules[cnt].long_text = l.long_text, reply->rules[cnt].priority_nbr = r.priority_nbr, reply
   ->rules[cnt].process_ind = r.process_ind,
   reply->rules[cnt].rule_beg_dt_tm = r.rule_beg_dt_tm, reply->rules[cnt].rule_end_dt_tm = r
   .rule_end_dt_tm, reply->rules[cnt].active_ind = r.active_ind,
   reply->rules[cnt].updt_cnt = r.updt_cnt, reply->rules[cnt].charge_status_ind = r.charge_status_ind
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET reply->rule_cnt = size(reply->rules,5)
END GO
