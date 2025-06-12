CREATE PROGRAM ct_get_rule:dba
 RECORD reply(
   1 rule_list[10]
     2 ct_rule_id = f8
     2 description = c100
     2 action_cd = f8
     2 action_disp = c40
     2 action_mean = c12
     2 action_desc = c60
     2 duration_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 rule_type_name = vc
     2 ct_ruleset_rule_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT
  r.ct_rule_id, r.description, r.action_cd,
  r.duration_cd, r.beg_effective_dt_tm, r.end_effective_dt_tm,
  ct.ct_ruleset_cd
  FROM ct_ruleset_rule_reltn ct,
   ct_rule r,
   code_value c
  PLAN (ct
   WHERE (ct.ct_ruleset_cd=request->ct_ruleset_cd)
    AND ct.active_ind=1)
   JOIN (r
   WHERE ct.ct_rule_id=r.ct_rule_id
    AND r.active_ind=1)
   JOIN (c
   WHERE c.code_value=r.action_cd)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->rule_list,(cnt+ 9))
   ENDIF
   reply->rule_list[cnt].ct_rule_id = r.ct_rule_id, reply->rule_list[cnt].description = r.description,
   reply->rule_list[cnt].action_cd = r.action_cd,
   reply->rule_list[cnt].rule_type_name = c.cdf_meaning, reply->rule_list[cnt].duration_cd = r
   .duration_cd, reply->rule_list[cnt].beg_effective_dt_tm = r.beg_effective_dt_tm,
   reply->rule_list[cnt].end_effective_dt_tm = r.end_effective_dt_tm, reply->rule_list[cnt].
   ct_ruleset_rule_id = ct.ct_ruleset_rule_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CT_RULE"
 ENDIF
 SET stat = alter(reply->rule_list,cnt)
END GO
