CREATE PROGRAM dcp_get_conditional_by_dta:dba
 RECORD reply(
   1 exp_list[*]
     2 cond_expression_id = f8
     2 cond_expression_name = c100
     2 cond_expression_txt = c512
     2 cond_postfix_txt = c512
     2 multiple_ind = i2
     2 exp_comp[*]
       3 cond_comp_name = c30
       3 cond_expression_comp_id = f8
       3 operator_cd = f8
       3 parent_entity_id = f8
       3 parent_entity_name = c60
       3 required_ind = i2
       3 trigger_assay_cd = f8
       3 result_value = f8
       3 cond_expression_id = f8
     2 cond_dtas[*]
       3 age_from_nbr = i4
       3 age_from_unit_cd = f8
       3 age_to_nbr = f8
       3 age_to_unit_cd = f8
       3 conditional_assay_cd = f8
       3 conditional_dta_id = f8
       3 cond_expression_id = f8
       3 gender_cd = f8
       3 location_cd = f8
       3 position_cd = f8
       3 required_ind = i2
       3 unknown_age_ind = i2
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
 DECLARE exp_cnt = i4 WITH noconstant(0)
 DECLARE expand_index = i4 WITH noconstant(0)
 DECLARE exp_pos = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM cond_expression ce
  PLAN (ce
   WHERE ce.active_ind=1
    AND ce.cond_expression_id IN (
   (SELECT
    cond_expression_id
    FROM cond_expression_comp cec
    WHERE (cec.trigger_assay_cd=request->trigger_dta_cd)
     AND cec.active_ind=1)))
  DETAIL
   exp_cnt = (exp_cnt+ 1)
   IF (mod(exp_cnt,5)=1)
    stat = alterlist(reply->exp_list,(exp_cnt+ 4))
   ENDIF
   reply->exp_list[exp_cnt].cond_expression_id = ce.cond_expression_id, reply->exp_list[exp_cnt].
   cond_expression_name = ce.cond_expression_name, reply->exp_list[exp_cnt].cond_expression_txt = ce
   .cond_expression_txt,
   reply->exp_list[exp_cnt].cond_postfix_txt = ce.cond_postfix_txt
  FOOT REPORT
   stat = alterlist(reply->exp_list,exp_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cond_expression_comp cec
  PLAN (cec
   WHERE cec.active_ind=1
    AND expand(expand_index,1,exp_cnt,cec.cond_expression_id,reply->exp_list[expand_index].
    cond_expression_id))
  ORDER BY cec.cond_expression_id
  HEAD cec.cond_expression_id
   comp_cnt = 0, exp_pos = locateval(num,1,exp_cnt,cec.cond_expression_id,reply->exp_list[num].
    cond_expression_id)
  DETAIL
   comp_cnt = (comp_cnt+ 1)
   IF (mod(comp_cnt,5)=1)
    stat = alterlist(reply->exp_list[exp_pos].exp_comp,(comp_cnt+ 4))
   ENDIF
   reply->exp_list[exp_pos].exp_comp[comp_cnt].cond_comp_name = cec.cond_comp_name, reply->exp_list[
   exp_pos].exp_comp[comp_cnt].cond_expression_comp_id = cec.cond_expression_comp_id, reply->
   exp_list[exp_pos].exp_comp[comp_cnt].cond_expression_id = cec.cond_expression_id,
   reply->exp_list[exp_pos].exp_comp[comp_cnt].operator_cd = cec.operator_cd, reply->exp_list[exp_pos
   ].exp_comp[comp_cnt].parent_entity_id = cec.parent_entity_id, reply->exp_list[exp_pos].exp_comp[
   comp_cnt].parent_entity_name = cec.parent_entity_name,
   reply->exp_list[exp_pos].exp_comp[comp_cnt].required_ind = cec.required_ind, reply->exp_list[
   exp_pos].exp_comp[comp_cnt].result_value = cec.result_value, reply->exp_list[exp_pos].exp_comp[
   comp_cnt].trigger_assay_cd = cec.trigger_assay_cd
  FOOT  cec.cond_expression_id
   stat = alterlist(reply->exp_list[exp_pos].exp_comp,comp_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM conditional_dta cd
  PLAN (cd
   WHERE cd.active_ind=1
    AND expand(expand_index,1,exp_cnt,cd.cond_expression_id,reply->exp_list[expand_index].
    cond_expression_id))
  ORDER BY cd.cond_expression_id
  HEAD cd.cond_expression_id
   dta_cnt = 0, exp_pos = locateval(num,1,exp_cnt,cd.cond_expression_id,reply->exp_list[num].
    cond_expression_id)
  DETAIL
   dta_cnt = (dta_cnt+ 1)
   IF (mod(dta_cnt,5)=1)
    stat = alterlist(reply->exp_list[exp_pos].cond_dtas,(dta_cnt+ 4))
   ENDIF
   reply->exp_list[exp_pos].cond_dtas[dta_cnt].age_from_nbr = cd.age_from_nbr, reply->exp_list[
   exp_pos].cond_dtas[dta_cnt].age_from_unit_cd = cd.age_from_unit_cd, reply->exp_list[exp_pos].
   cond_dtas[dta_cnt].age_to_nbr = cd.age_to_nbr,
   reply->exp_list[exp_pos].cond_dtas[dta_cnt].age_to_unit_cd = cd.age_to_unit_cd, reply->exp_list[
   exp_pos].cond_dtas[dta_cnt].cond_expression_id = cd.cond_expression_id, reply->exp_list[exp_pos].
   cond_dtas[dta_cnt].conditional_assay_cd = cd.conditional_assay_cd,
   reply->exp_list[exp_pos].cond_dtas[dta_cnt].conditional_dta_id = cd.conditional_dta_id, reply->
   exp_list[exp_pos].cond_dtas[dta_cnt].gender_cd = cd.gender_cd, reply->exp_list[exp_pos].cond_dtas[
   dta_cnt].location_cd = cd.location_cd,
   reply->exp_list[exp_pos].cond_dtas[dta_cnt].position_cd = cd.position_cd, reply->exp_list[exp_pos]
   .cond_dtas[dta_cnt].required_ind = cd.required_ind, reply->exp_list[exp_pos].cond_dtas[dta_cnt].
   unknown_age_ind = cd.unknown_age_ind
  FOOT  cd.cond_expression_id
   stat = alterlist(reply->exp_list[exp_pos].cond_dtas,dta_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
