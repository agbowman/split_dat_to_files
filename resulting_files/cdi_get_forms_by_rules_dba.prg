CREATE PROGRAM cdi_get_forms_by_rules:dba
 RECORD reply(
   1 forms[*]
     2 cdi_form_id = f8
     2 required_ind = i2
     2 matching_criteria[*]
       3 variable_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE current_logical_domain_id = f8 WITH noconstant(0.0), protect
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 RECORD acm_get_curr_logical_domain_req(
   1 concept = i4
 )
 RECORD acm_get_curr_logical_domain_rep(
   1 logical_domain_id = f8
   1 status_block
     2 status_ind = i2
     2 error_code = i4
 )
 SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
 EXECUTE acm_get_curr_logical_domain
 SET current_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 DECLARE variable_cnt = i4 WITH noconstant(size(request->variables,5))
 DECLARE form_cnt = i4 WITH noconstant(0)
 DECLARE matching_criteria_cnt = i4 WITH noconstant(0)
 DECLARE rule_matched_ind = i2 WITH noconstant(0)
 DECLARE form_required_ind = i2 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE form_match_cnt = i4 WITH noconstant(0)
 DECLARE op_flag_equals = i2 WITH constant(0)
 DECLARE op_flag_lessthan = i2 WITH constant(1)
 DECLARE op_flag_grtrthan = i2 WITH constant(2)
 DECLARE op_flag_notequal = i2 WITH constant(3)
 DECLARE op_flag_ltorequal = i2 WITH constant(4)
 DECLARE op_flag_gtorequal = i2 WITH constant(5)
 RECORD temp(
   1 matching_criteria[*]
     2 variable_cd = f8
 )
 SELECT
  r.cdi_form_id, r.cdi_form_rule_id, r.criteria_cnt,
  c.cdi_form_criteria_id
  FROM cdi_form_criteria c,
   cdi_form_rule r,
   (dummyt d  WITH seq = value(variable_cnt)),
   cdi_form f
  PLAN (d)
   JOIN (c
   WHERE (c.variable_cd=request->variables[d.seq].variable_cd)
    AND ((c.comparison_flag=op_flag_equals
    AND (request->variables[d.seq].value_cd=c.value_cd)) OR (((c.comparison_flag=op_flag_notequal
    AND (request->variables[d.seq].value_cd != c.value_cd)) OR (((c.comparison_flag=op_flag_equals
    AND c.value_cd=null
    AND (request->variables[d.seq].value_nbr=c.value_nbr)) OR (((c.comparison_flag=op_flag_lessthan
    AND c.value_cd=null
    AND (request->variables[d.seq].value_nbr < c.value_nbr)) OR (((c.comparison_flag=op_flag_grtrthan
    AND c.value_cd=null
    AND (request->variables[d.seq].value_nbr > c.value_nbr)) OR (((c.comparison_flag=op_flag_notequal
    AND c.value_cd=null
    AND (request->variables[d.seq].value_nbr != c.value_nbr)) OR (((c.comparison_flag=
   op_flag_ltorequal
    AND c.value_cd=null
    AND (request->variables[d.seq].value_nbr <= c.value_nbr)) OR (((c.comparison_flag=
   op_flag_gtorequal
    AND c.value_cd=null
    AND (request->variables[d.seq].value_nbr >= c.value_nbr)) OR (((c.comparison_flag=op_flag_equals
    AND c.value_cd=null
    AND c.value_nbr=null
    AND cnvtdatetime(request->variables[d.seq].value_dt_tm)=c.value_dt_tm) OR (((c.comparison_flag=
   op_flag_lessthan
    AND c.value_cd=null
    AND c.value_nbr=null
    AND cnvtdatetime(request->variables[d.seq].value_dt_tm) < c.value_dt_tm) OR (((c.comparison_flag=
   op_flag_grtrthan
    AND c.value_cd=null
    AND c.value_nbr=null
    AND cnvtdatetime(request->variables[d.seq].value_dt_tm) > c.value_dt_tm) OR (((c.comparison_flag=
   op_flag_notequal
    AND c.value_cd=null
    AND c.value_nbr=null
    AND cnvtdatetime(request->variables[d.seq].value_dt_tm) != c.value_dt_tm) OR (((c.comparison_flag
   =op_flag_ltorequal
    AND c.value_cd=null
    AND c.value_nbr=null
    AND cnvtdatetime(request->variables[d.seq].value_dt_tm) <= c.value_dt_tm) OR (((c.comparison_flag
   =op_flag_gtorequal
    AND c.value_cd=null
    AND c.value_nbr=null
    AND cnvtdatetime(request->variables[d.seq].value_dt_tm) >= c.value_dt_tm) OR (c.comparison_flag=
   op_flag_equals
    AND c.value_cd=null
    AND c.value_nbr=null
    AND c.value_dt_tm=null
    AND (request->variables[d.seq].value_text=c.value_text))) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )
   JOIN (r
   WHERE r.cdi_form_rule_id=c.cdi_form_rule_id
    AND (((request->variables[d.seq].cdi_form_id=0.0)) OR ((request->variables[d.seq].cdi_form_id=r
   .cdi_form_id))) )
   JOIN (f
   WHERE r.cdi_form_id=f.cdi_form_id
    AND f.logical_domain_id=current_logical_domain_id
    AND f.active_ind=1)
  ORDER BY r.cdi_form_id, r.cdi_form_rule_id
  HEAD REPORT
   form_cnt = 0
  HEAD r.cdi_form_id
   rule_matched_ind = 0, form_required_ind = 0, form_match_cnt = 0,
   stat = alterlist(temp->matching_criteria,10)
  HEAD r.cdi_form_rule_id
   matching_criteria_cnt = 0
  DETAIL
   matching_criteria_cnt = (matching_criteria_cnt+ 1), form_match_cnt = (form_match_cnt+ 1)
   IF (mod(form_match_cnt,10)=1
    AND form_match_cnt > 1)
    stat = alterlist(temp->matching_criteria,(form_match_cnt+ 9))
   ENDIF
   temp->matching_criteria[form_match_cnt].variable_cd = c.variable_cd
  FOOT  r.cdi_form_rule_id
   IF (matching_criteria_cnt=r.criteria_cnt)
    rule_matched_ind = 1
    IF (r.required_ind=1)
     form_required_ind = 1
    ENDIF
   ELSE
    form_match_cnt = (form_match_cnt - matching_criteria_cnt)
   ENDIF
  FOOT  r.cdi_form_id
   IF (rule_matched_ind=1)
    form_cnt = (form_cnt+ 1)
    IF (mod(form_cnt,10)=1)
     stat = alterlist(reply->forms,(form_cnt+ 9))
    ENDIF
    reply->forms[form_cnt].cdi_form_id = r.cdi_form_id, reply->forms[form_cnt].required_ind =
    form_required_ind, stat = alterlist(reply->forms[form_cnt].matching_criteria,form_match_cnt)
    FOR (i = 1 TO form_match_cnt)
      reply->forms[form_cnt].matching_criteria[i].variable_cd = temp->matching_criteria[i].
      variable_cd
    ENDFOR
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->forms,form_cnt)
  WITH nocounter
 ;end select
 IF (form_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
