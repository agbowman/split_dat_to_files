CREATE PROGRAM cdi_get_all_form_rules:dba
 RECORD reply(
   1 rules[*]
     2 cdi_form_rule_id = f8
     2 required_ind = i2
     2 criteria[*]
       3 cdi_form_criteria_id = f8
       3 variable_cd = f8
       3 comparison_flag = i2
       3 value_cd = f8
       3 value_nbr = f8
       3 value_dt_tm = dq8
       3 value_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE rule_cnt = i4 WITH noconstant(0)
 DECLARE criteria_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  r.cdi_form_rule_id, r.required_ind, c.cdi_form_criteria_id,
  c.variable_cd, c.comparison_flag, c.value_cd,
  c.value_nbr, c.value_dt_tm, c.value_text
  FROM cdi_form_rule r,
   cdi_form_criteria c
  PLAN (r
   WHERE r.cdi_form_id > 0
    AND (r.cdi_form_id=request->cdi_form_id))
   JOIN (c
   WHERE outerjoin(r.cdi_form_rule_id)=c.cdi_form_rule_id)
  ORDER BY r.cdi_form_rule_id, c.cdi_form_criteria_id
  HEAD REPORT
   rule_cnt = 0
  HEAD r.cdi_form_rule_id
   criteria_cnt = 0, rule_cnt = (rule_cnt+ 1)
   IF (mod(rule_cnt,10)=1)
    stat = alterlist(reply->rules,(rule_cnt+ 9))
   ENDIF
   reply->rules[rule_cnt].cdi_form_rule_id = r.cdi_form_rule_id, reply->rules[rule_cnt].required_ind
    = r.required_ind
  DETAIL
   IF (c.cdi_form_criteria_id != 0.0)
    criteria_cnt = (criteria_cnt+ 1)
    IF (mod(criteria_cnt,10)=1)
     stat = alterlist(reply->rules[rule_cnt].criteria,(criteria_cnt+ 9))
    ENDIF
    reply->rules[rule_cnt].criteria[criteria_cnt].cdi_form_criteria_id = c.cdi_form_criteria_id,
    reply->rules[rule_cnt].criteria[criteria_cnt].variable_cd = c.variable_cd, reply->rules[rule_cnt]
    .criteria[criteria_cnt].comparison_flag = c.comparison_flag,
    reply->rules[rule_cnt].criteria[criteria_cnt].value_cd = c.value_cd, reply->rules[rule_cnt].
    criteria[criteria_cnt].value_nbr = c.value_nbr, reply->rules[rule_cnt].criteria[criteria_cnt].
    value_dt_tm = c.value_dt_tm,
    reply->rules[rule_cnt].criteria[criteria_cnt].value_text = c.value_text
   ENDIF
  FOOT  r.cdi_form_rule_id
   stat = alterlist(reply->rules[rule_cnt].criteria,criteria_cnt)
  FOOT REPORT
   stat = alterlist(reply->rules,rule_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
