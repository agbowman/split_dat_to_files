CREATE PROGRAM dcp_get_conditional_info:dba
 RECORD reply(
   1 cond_expression_id = f8
   1 cond_expression_name = c100
   1 cond_expression_txt = c512
   1 cond_postfix_txt = c512
   1 multiple_ind = i2
   1 exp_comp[*]
     2 cond_comp_name = c30
     2 cond_expression_comp_id = f8
     2 operator_cd = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c60
     2 required_ind = i2
     2 trigger_assay_cd = f8
     2 result_value = f8
     2 cond_expression_id = f8
   1 cond_dtas[*]
     2 age_from_nbr = f8
     2 age_from_unit_cd = f8
     2 age_to_nbr = f8
     2 age_to_unit_cd = f8
     2 conditional_assay_cd = f8
     2 conditional_dta_id = f8
     2 cond_expression_id = f8
     2 gender_cd = f8
     2 location_cd = f8
     2 position_cd = f8
     2 required_ind = i2
     2 unknown_age_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE comp_cnt = i4 WITH noconstant(0)
 DECLARE dta_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM cond_expression ce
  PLAN (ce
   WHERE (ce.cond_expression_id=request->cond_expression_id)
    AND ce.active_ind=1)
  DETAIL
   reply->cond_expression_id = ce.cond_expression_id, reply->cond_expression_name = ce
   .cond_expression_name, reply->cond_expression_txt = ce.cond_expression_txt,
   reply->cond_postfix_txt = ce.cond_postfix_txt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cond_expression_comp cec
  PLAN (cec
   WHERE (cec.cond_expression_id=request->cond_expression_id)
    AND cec.active_ind=1)
  ORDER BY cec.cond_comp_name
  DETAIL
   comp_cnt = (comp_cnt+ 1)
   IF (mod(comp_cnt,5)=1)
    stat = alterlist(reply->exp_comp,(comp_cnt+ 4))
   ENDIF
   reply->exp_comp[comp_cnt].cond_comp_name = cec.cond_comp_name, reply->exp_comp[comp_cnt].
   cond_expression_comp_id = cec.cond_expression_comp_id, reply->exp_comp[comp_cnt].
   cond_expression_id = cec.cond_expression_id,
   reply->exp_comp[comp_cnt].operator_cd = cec.operator_cd, reply->exp_comp[comp_cnt].
   parent_entity_id = cec.parent_entity_id, reply->exp_comp[comp_cnt].parent_entity_name = cec
   .parent_entity_name,
   reply->exp_comp[comp_cnt].required_ind = cec.required_ind, reply->exp_comp[comp_cnt].result_value
    = cec.result_value, reply->exp_comp[comp_cnt].trigger_assay_cd = cec.trigger_assay_cd
  FOOT REPORT
   stat = alterlist(reply->exp_comp,comp_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM conditional_dta cd
  PLAN (cd
   WHERE (cd.cond_expression_id=request->cond_expression_id)
    AND cd.active_ind=1)
  DETAIL
   dta_cnt = (dta_cnt+ 1)
   IF (mod(dta_cnt,5)=1)
    stat = alterlist(reply->cond_dtas,(dta_cnt+ 4))
   ENDIF
   reply->cond_dtas[dta_cnt].age_from_nbr = cd.age_from_nbr, reply->cond_dtas[dta_cnt].
   age_from_unit_cd = cd.age_from_unit_cd, reply->cond_dtas[dta_cnt].age_to_nbr = cd.age_to_nbr,
   reply->cond_dtas[dta_cnt].age_to_unit_cd = cd.age_to_unit_cd, reply->cond_dtas[dta_cnt].
   cond_expression_id = cd.cond_expression_id, reply->cond_dtas[dta_cnt].conditional_assay_cd = cd
   .conditional_assay_cd,
   reply->cond_dtas[dta_cnt].conditional_dta_id = cd.conditional_dta_id, reply->cond_dtas[dta_cnt].
   gender_cd = cd.gender_cd, reply->cond_dtas[dta_cnt].location_cd = cd.location_cd,
   reply->cond_dtas[dta_cnt].position_cd = cd.position_cd, reply->cond_dtas[dta_cnt].required_ind =
   cd.required_ind, reply->cond_dtas[dta_cnt].unknown_age_ind = cd.unknown_age_ind
  FOOT REPORT
   stat = alterlist(reply->cond_dtas,dta_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (((comp_cnt=0) OR (dta_cnt=0)) )
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
