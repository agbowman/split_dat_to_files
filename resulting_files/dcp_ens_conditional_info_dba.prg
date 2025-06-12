CREATE PROGRAM dcp_ens_conditional_info:dba
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
     2 age_from_nbr = i4
     2 age_from_unit_cd = f8
     2 age_to_nbr = i4
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
 RECORD exp_version(
   1 cond_expression_id = f8
   1 cond_expression_name = c100
   1 cond_expression_txt = c512
   1 cond_postfix_txt = c512
   1 multiple_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prev_cond_expression_id = f8
 )
 RECORD comp_version(
   1 cond_comp_name = c30
   1 cond_expression_comp_id = f8
   1 operator_cd = f8
   1 parent_entity_id = f8
   1 parent_entity_name = c60
   1 required_ind = i2
   1 trigger_assay_cd = f8
   1 result_value = f8
   1 cond_expression_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prev_cond_expression_comp_id = f8
 )
 RECORD dta_version(
   1 age_from_nbr = i4
   1 age_from_unit_cd = f8
   1 age_to_nbr = i4
   1 age_to_unit_cd = f8
   1 conditional_assay_cd = f8
   1 conditional_dta_id = f8
   1 cond_expression_id = f8
   1 gender_cd = f8
   1 location_cd = f8
   1 position_cd = f8
   1 required_ind = i2
   1 unknown_age_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prev_conditional_dta_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE insertnewconditionalexpression(null) = null
 DECLARE updateconditionalexpression(null) = null
 DECLARE insertnewconditionalcomponents(null) = null
 DECLARE insertnewconditionaldtas(null) = null
 DECLARE updateconditionalcomponents(null) = null
 DECLARE insertnewcomponentbyindex(index=i4) = null
 DECLARE insertnewconditionaldtabyindex(index=i4) = null
 DECLARE updateconditionalcomponentbyindex(index=i4) = null
 DECLARE updateconditionaldtas(null) = null
 DECLARE updateconditionaldtabyindex(index=i4) = null
 DECLARE failure_ind = i2 WITH public, noconstant(false)
 DECLARE active_exp_ind = i2 WITH public, noconstant(0)
 IF ((request->cond_expression_id=0))
  SELECT INTO "nl:"
   FROM cond_expression ce
   WHERE (ce.cond_expression_name=request->cond_expression_name)
    AND ce.active_ind=1
   DETAIL
    active_exp_ind = 1
   WITH nocounter
  ;end select
  IF (active_exp_ind=1)
   SET failure_ind = true
   SET reply->status_data.subeventstatus[1].operationstatus =
   "Conditional Expression name already exists"
   GO TO failure
  ENDIF
  CALL insertnewconditionalexpression(null)
 ELSE
  IF ((request->inactivate_ind=1))
   CALL inactivateconditionalexpression(null)
  ELSE
   CALL updateconditionalexpression(null)
  ENDIF
 ENDIF
#failure
 IF (failure_ind=true)
  CALL echo("*Ensure Conditional Info failed*")
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE insertnewconditionalexpression(null)
   DECLARE newseq = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     newseq = cnvtreal(j)
    WITH format, nocounter
   ;end select
   SET reply->cond_expression_id = newseq
   SET reply->cond_expression_name = request->cond_expression_name
   SET reply->cond_expression_txt = request->cond_expression_txt
   SET reply->cond_postfix_txt = request->cond_postfix_txt
   SET reply->multiple_ind = request->multiple_ind
   INSERT  FROM cond_expression ce
    SET ce.cond_expression_id = reply->cond_expression_id, ce.prev_cond_expression_id = reply->
     cond_expression_id, ce.active_ind = 1,
     ce.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ce.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), ce.cond_expression_name = request->cond_expression_name,
     ce.cond_expression_txt = request->cond_expression_txt, ce.cond_postfix_txt = request->
     cond_postfix_txt, ce.multiple_ind = request->multiple_ind,
     ce.updt_id = reqinfo->updt_id, ce.updt_dt_tm = cnvtdatetime(curdate,curtime3), ce.updt_applctx
      = reqinfo->updt_applctx,
     ce.updt_cnt = 0, ce.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL insertnewconditionalcomponents(null)
   CALL insertnewconditionaldtas(null)
 END ;Subroutine
 SUBROUTINE updateconditionalexpression(null)
   DECLARE prev_exp_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     prev_exp_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   SET reply->cond_expression_id = request->cond_expression_id
   SET reply->cond_expression_name = request->cond_expression_name
   SET reply->cond_expression_txt = request->cond_expression_txt
   SET reply->cond_postfix_txt = request->cond_postfix_txt
   SET reply->multiple_ind = request->multiple_ind
   SELECT INTO "nl:"
    FROM cond_expression ce
    WHERE (ce.cond_expression_id=request->cond_expression_id)
     AND ce.active_ind=1
    DETAIL
     exp_version->beg_effective_dt_tm = ce.beg_effective_dt_tm, exp_version->cond_expression_id =
     prev_exp_id, exp_version->cond_expression_name = ce.cond_expression_name,
     exp_version->cond_expression_txt = ce.cond_expression_txt, exp_version->cond_postfix_txt = ce
     .cond_postfix_txt, exp_version->end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     exp_version->multiple_ind = ce.multiple_ind, exp_version->prev_cond_expression_id = ce
     .prev_cond_expression_id
    WITH nocounter
   ;end select
   IF ((((exp_version->cond_expression_name != request->cond_expression_name)) OR ((((exp_version->
   cond_expression_txt != request->cond_expression_txt)) OR ((((exp_version->cond_postfix_txt !=
   request->cond_postfix_txt)) OR ((exp_version->multiple_ind != request->multiple_ind))) )) )) )
    INSERT  FROM cond_expression ce
     SET ce.cond_expression_id = prev_exp_id, ce.prev_cond_expression_id = exp_version->
      prev_cond_expression_id, ce.active_ind = 0,
      ce.beg_effective_dt_tm = cnvtdatetime(exp_version->beg_effective_dt_tm), ce.end_effective_dt_tm
       = cnvtdatetime(exp_version->end_effective_dt_tm), ce.cond_expression_name = exp_version->
      cond_expression_name,
      ce.cond_expression_txt = exp_version->cond_expression_txt, ce.cond_postfix_txt = exp_version->
      cond_postfix_txt, ce.multiple_ind = exp_version->multiple_ind,
      ce.updt_id = reqinfo->updt_id, ce.updt_dt_tm = cnvtdatetime(curdate,curtime3), ce.updt_applctx
       = reqinfo->updt_applctx,
      ce.updt_cnt = 0, ce.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    UPDATE  FROM cond_expression ce
     SET ce.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ce.cond_expression_name = request->
      cond_expression_name, ce.cond_expression_txt = request->cond_expression_txt,
      ce.cond_postfix_txt = request->cond_postfix_txt, ce.multiple_ind = request->multiple_ind, ce
      .updt_id = reqinfo->updt_id,
      ce.updt_dt_tm = cnvtdatetime(curdate,curtime3), ce.updt_applctx = reqinfo->updt_applctx, ce
      .updt_cnt = (ce.updt_cnt+ 1),
      ce.updt_task = reqinfo->updt_task
     WHERE (ce.cond_expression_id=request->cond_expression_id)
     WITH nocounter
    ;end update
   ENDIF
   CALL updateconditionalcomponents(null)
   CALL updateconditionaldtas(null)
 END ;Subroutine
 SUBROUTINE insertnewconditionalcomponents(null)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE comp_cnt = i4 WITH protect, noconstant(size(request->exp_comp,5))
   SET stat = alterlist(reply->exp_comp,comp_cnt)
   FOR (x = 1 TO comp_cnt)
     CALL insertnewcomponentbyindex(x)
   ENDFOR
 END ;Subroutine
 SUBROUTINE insertnewconditionaldtas(null)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE cond_cnt = i4 WITH protect, noconstant(size(request->cond_dtas,5))
   SET stat = alterlist(reply->cond_dtas,cond_cnt)
   FOR (x = 1 TO cond_cnt)
     CALL insertnewconditionaldtabyindex(x)
   ENDFOR
 END ;Subroutine
 SUBROUTINE updateconditionalcomponents(null)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE comp_cnt = i4 WITH protect, constant(size(request->exp_comp,5))
   DECLARE comp_exists = i2 WITH protect, noconstant(0)
   DECLARE expand_index = i4 WITH protect, noconstant(0)
   UPDATE  FROM cond_expression_comp cec
    SET cec.active_ind = 0
    WHERE (cec.cond_expression_id=request->cond_expression_id)
     AND cec.active_ind=1
     AND  NOT (expand(expand_index,1,comp_cnt,cec.cond_expression_comp_id,request->exp_comp[
     expand_index].cond_expression_comp_id))
    WITH nocounter
   ;end update
   SET stat = alterlist(reply->exp_comp,comp_cnt)
   FOR (x = 1 TO comp_cnt)
    SELECT INTO "nl:"
     FROM cond_expression_comp cec
     WHERE (request->exp_comp[x].cond_expression_comp_id != 0)
      AND (cec.cond_expression_comp_id=request->exp_comp[x].cond_expression_comp_id)
      AND cec.active_ind=1
     DETAIL
      comp_version->cond_comp_name = cec.cond_comp_name, comp_version->cond_expression_comp_id = cec
      .cond_expression_comp_id, comp_version->cond_expression_id = cec.cond_expression_id,
      comp_version->beg_effective_dt_tm = cec.beg_effective_dt_tm, comp_version->end_effective_dt_tm
       = cec.end_effective_dt_tm, comp_version->operator_cd = cec.operator_cd,
      comp_version->parent_entity_id = cec.parent_entity_id, comp_version->parent_entity_name = cec
      .parent_entity_name, comp_version->prev_cond_expression_comp_id = cec
      .prev_cond_expression_comp_id,
      comp_version->required_ind = cec.required_ind, comp_version->result_value = cec.result_value,
      comp_version->trigger_assay_cd = cec.trigger_assay_cd
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL updateconditionalcomponentbyindex(x)
    ELSE
     CALL insertnewcomponentbyindex(x)
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE insertnewcomponentbyindex(index)
   DECLARE newseq = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     newseq = cnvtreal(j)
    WITH format, nocounter
   ;end select
   SET reply->exp_comp[index].cond_comp_name = request->exp_comp[index].cond_comp_name
   SET reply->exp_comp[index].cond_expression_comp_id = newseq
   SET reply->exp_comp[index].operator_cd = request->exp_comp[index].operator_cd
   SET reply->exp_comp[index].parent_entity_id = request->exp_comp[index].parent_entity_id
   SET reply->exp_comp[index].parent_entity_name = request->exp_comp[index].parent_entity_name
   SET reply->exp_comp[index].required_ind = request->exp_comp[index].required_ind
   SET reply->exp_comp[index].trigger_assay_cd = request->exp_comp[index].trigger_assay_cd
   SET reply->exp_comp[index].result_value = request->exp_comp[index].result_value
   SET reply->exp_comp[index].cond_expression_id = reply->cond_expression_id
   INSERT  FROM cond_expression_comp cec
    SET cec.cond_expression_comp_id = reply->exp_comp[index].cond_expression_comp_id, cec
     .cond_expression_id = reply->cond_expression_id, cec.active_ind = 1,
     cec.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cec.end_effective_dt_tm = cnvtdatetime
     ("31-DEC-2100"), cec.cond_comp_name = request->exp_comp[index].cond_comp_name,
     cec.operator_cd = request->exp_comp[index].operator_cd, cec.parent_entity_id = request->
     exp_comp[index].parent_entity_id, cec.parent_entity_name = request->exp_comp[index].
     parent_entity_name,
     cec.prev_cond_expression_comp_id = reply->exp_comp[index].cond_expression_comp_id, cec
     .required_ind = request->exp_comp[index].required_ind, cec.result_value = request->exp_comp[
     index].result_value,
     cec.trigger_assay_cd = request->exp_comp[index].trigger_assay_cd, cec.updt_id = reqinfo->updt_id,
     cec.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cec.updt_applctx = reqinfo->updt_applctx, cec.updt_cnt = 0, cec.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE insertnewconditionaldtabyindex(index)
   DECLARE newseq = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     newseq = cnvtreal(j)
    WITH format, nocounter
   ;end select
   SET reply->cond_dtas[index].conditional_dta_id = newseq
   SET reply->cond_dtas[index].age_from_nbr = request->cond_dtas[index].age_from_nbr
   SET reply->cond_dtas[index].age_from_unit_cd = request->cond_dtas[index].age_from_unit_cd
   SET reply->cond_dtas[index].age_to_nbr = request->cond_dtas[index].age_to_nbr
   SET reply->cond_dtas[index].age_to_unit_cd = request->cond_dtas[index].age_to_unit_cd
   SET reply->cond_dtas[index].conditional_assay_cd = request->cond_dtas[index].conditional_assay_cd
   SET reply->cond_dtas[index].cond_expression_id = reply->cond_expression_id
   SET reply->cond_dtas[index].gender_cd = request->cond_dtas[index].gender_cd
   SET reply->cond_dtas[index].location_cd = request->cond_dtas[index].location_cd
   SET reply->cond_dtas[index].position_cd = request->cond_dtas[index].position_cd
   SET reply->cond_dtas[index].required_ind = request->cond_dtas[index].required_ind
   SET reply->cond_dtas[index].unknown_age_ind = request->cond_dtas[index].unknown_age_ind
   INSERT  FROM conditional_dta cd
    SET cd.conditional_dta_id = reply->cond_dtas[index].conditional_dta_id, cd.cond_expression_id =
     reply->cond_expression_id, cd.active_ind = 1,
     cd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cd.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), cd.age_from_nbr = request->cond_dtas[index].age_from_nbr,
     cd.age_from_unit_cd = request->cond_dtas[index].age_from_unit_cd, cd.age_to_nbr = request->
     cond_dtas[index].age_to_nbr, cd.age_to_unit_cd = request->cond_dtas[index].age_to_unit_cd,
     cd.prev_conditional_dta_id = reply->cond_dtas[index].conditional_dta_id, cd.required_ind =
     request->cond_dtas[index].required_ind, cd.gender_cd = request->cond_dtas[index].gender_cd,
     cd.location_cd = request->cond_dtas[index].location_cd, cd.position_cd = request->cond_dtas[
     index].position_cd, cd.unknown_age_ind = request->cond_dtas[index].unknown_age_ind,
     cd.conditional_assay_cd = request->cond_dtas[index].conditional_assay_cd, cd.updt_id = reqinfo->
     updt_id, cd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cd.updt_applctx = reqinfo->updt_applctx, cd.updt_cnt = 0, cd.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE updateconditionalcomponentbyindex(index)
   SET reply->exp_comp[index].cond_comp_name = request->exp_comp[index].cond_comp_name
   SET reply->exp_comp[index].cond_expression_comp_id = request->exp_comp[index].
   cond_expression_comp_id
   SET reply->exp_comp[index].operator_cd = request->exp_comp[index].operator_cd
   SET reply->exp_comp[index].parent_entity_id = request->exp_comp[index].parent_entity_id
   SET reply->exp_comp[index].parent_entity_name = request->exp_comp[index].parent_entity_name
   SET reply->exp_comp[index].required_ind = request->exp_comp[index].required_ind
   SET reply->exp_comp[index].trigger_assay_cd = request->exp_comp[index].trigger_assay_cd
   SET reply->exp_comp[index].result_value = request->exp_comp[index].result_value
   SET reply->exp_comp[index].cond_expression_id = request->exp_comp[index].cond_expression_id
   IF ((((comp_version->operator_cd != request->exp_comp[x].operator_cd)) OR ((((comp_version->
   parent_entity_id != request->exp_comp[x].parent_entity_id)) OR ((((comp_version->required_ind !=
   request->exp_comp[x].required_ind)) OR ((((comp_version->result_value != request->exp_comp[x].
   result_value)) OR ((((comp_version->trigger_assay_cd != request->exp_comp[x].trigger_assay_cd))
    OR ((comp_version->cond_comp_name != request->exp_comp[x].cond_comp_name))) )) )) )) )) )
    DECLARE prev_comp_id = f8 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      prev_comp_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    INSERT  FROM cond_expression_comp cec
     SET cec.cond_expression_comp_id = prev_comp_id, cec.cond_expression_id = comp_version->
      cond_expression_id, cec.active_ind = 0,
      cec.beg_effective_dt_tm = cnvtdatetime(comp_version->beg_effective_dt_tm), cec
      .end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cec.cond_comp_name = comp_version->
      cond_comp_name,
      cec.operator_cd = comp_version->operator_cd, cec.parent_entity_id = comp_version->
      parent_entity_id, cec.parent_entity_name = comp_version->parent_entity_name,
      cec.prev_cond_expression_comp_id = comp_version->prev_cond_expression_comp_id, cec.required_ind
       = comp_version->required_ind, cec.result_value = comp_version->result_value,
      cec.trigger_assay_cd = comp_version->trigger_assay_cd, cec.updt_id = reqinfo->updt_id, cec
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cec.updt_applctx = reqinfo->updt_applctx, cec.updt_cnt = 0, cec.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    UPDATE  FROM cond_expression_comp cec
     SET cec.cond_expression_id = request->exp_comp[index].cond_expression_id, cec.active_ind = 1,
      cec.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      cec.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cec.cond_comp_name = request->exp_comp[
      index].cond_comp_name, cec.operator_cd = request->exp_comp[index].operator_cd,
      cec.parent_entity_id = request->exp_comp[index].parent_entity_id, cec.parent_entity_name =
      request->exp_comp[index].parent_entity_name, cec.required_ind = request->exp_comp[index].
      required_ind,
      cec.result_value = request->exp_comp[index].result_value, cec.trigger_assay_cd = request->
      exp_comp[index].trigger_assay_cd, cec.updt_id = reqinfo->updt_id,
      cec.updt_dt_tm = cnvtdatetime(curdate,curtime3), cec.updt_applctx = reqinfo->updt_applctx, cec
      .updt_cnt = (cec.updt_cnt+ 1),
      cec.updt_task = reqinfo->updt_task
     WHERE (cec.cond_expression_comp_id=request->exp_comp[index].cond_expression_comp_id)
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE updateconditionaldtas(null)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE cond_cnt = i4 WITH protect, constant(size(request->cond_dtas,5))
   DECLARE cond_exists = i2 WITH protect, noconstant(0)
   DECLARE expand_index = i4 WITH protect, noconstant(0)
   UPDATE  FROM conditional_dta cd
    SET cd.active_ind = 0
    WHERE (cd.cond_expression_id=request->cond_expression_id)
     AND cd.active_ind=1
     AND  NOT (expand(expand_index,1,cond_cnt,cd.conditional_dta_id,request->cond_dtas[expand_index].
     conditional_dta_id))
    WITH nocounter
   ;end update
   SET stat = alterlist(reply->cond_dtas,cond_cnt)
   FOR (x = 1 TO cond_cnt)
    SELECT INTO "nl:"
     FROM conditional_dta cd
     WHERE (request->cond_dtas[x].conditional_dta_id != 0)
      AND (cd.conditional_dta_id=request->cond_dtas[x].conditional_dta_id)
      AND cd.active_ind=1
     DETAIL
      dta_version->age_from_nbr = cd.age_from_nbr, dta_version->age_from_unit_cd = cd
      .age_from_unit_cd, dta_version->age_to_nbr = cd.age_to_nbr,
      dta_version->age_to_unit_cd = cd.age_to_unit_cd, dta_version->beg_effective_dt_tm = cd
      .beg_effective_dt_tm, dta_version->end_effective_dt_tm = cd.end_effective_dt_tm,
      dta_version->cond_expression_id = cd.cond_expression_id, dta_version->conditional_assay_cd = cd
      .conditional_assay_cd, dta_version->conditional_dta_id = cd.conditional_dta_id,
      dta_version->gender_cd = cd.gender_cd, dta_version->location_cd = cd.location_cd, dta_version->
      position_cd = cd.position_cd,
      dta_version->required_ind = cd.required_ind, dta_version->unknown_age_ind = cd.unknown_age_ind,
      dta_version->prev_conditional_dta_id = cd.prev_conditional_dta_id
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL updateconditionaldtabyindex(x)
    ELSE
     CALL insertnewconditionaldtabyindex(x)
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE updateconditionaldtabyindex(index)
   SET reply->cond_dtas[index].age_from_nbr = request->cond_dtas[index].age_from_nbr
   SET reply->cond_dtas[index].age_from_unit_cd = request->cond_dtas[index].age_from_unit_cd
   SET reply->cond_dtas[index].age_to_nbr = request->cond_dtas[index].age_to_nbr
   SET reply->cond_dtas[index].age_to_unit_cd = request->cond_dtas[index].age_to_unit_cd
   SET reply->cond_dtas[index].conditional_assay_cd = request->cond_dtas[index].conditional_assay_cd
   SET reply->cond_dtas[index].conditional_dta_id = request->cond_dtas[index].conditional_dta_id
   SET reply->cond_dtas[index].cond_expression_id = request->cond_dtas[index].cond_expression_id
   SET reply->cond_dtas[index].gender_cd = request->cond_dtas[index].gender_cd
   SET reply->cond_dtas[index].location_cd = request->cond_dtas[index].location_cd
   SET reply->cond_dtas[index].position_cd = request->cond_dtas[index].position_cd
   SET reply->cond_dtas[index].required_ind = request->cond_dtas[index].required_ind
   SET reply->cond_dtas[index].unknown_age_ind = request->cond_dtas[index].unknown_age_ind
   IF ((((dta_version->age_from_nbr != request->cond_dtas[x].age_from_nbr)) OR ((((dta_version->
   age_from_unit_cd != request->cond_dtas[x].age_from_unit_cd)) OR ((((dta_version->age_to_nbr !=
   request->cond_dtas[x].age_to_nbr)) OR ((((dta_version->age_to_unit_cd != request->cond_dtas[x].
   age_to_unit_cd)) OR ((((dta_version->conditional_assay_cd != request->cond_dtas[x].
   conditional_assay_cd)) OR ((((dta_version->gender_cd != request->cond_dtas[x].gender_cd)) OR ((((
   dta_version->location_cd != request->cond_dtas[x].location_cd)) OR ((((dta_version->position_cd
    != request->cond_dtas[x].position_cd)) OR ((((dta_version->required_ind != request->cond_dtas[x].
   required_ind)) OR ((dta_version->unknown_age_ind != request->cond_dtas[x].unknown_age_ind))) ))
   )) )) )) )) )) )) )) )
    DECLARE prev_cond_id = f8 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      prev_cond_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    INSERT  FROM conditional_dta cd
     SET cd.conditional_dta_id = prev_cond_id, cd.cond_expression_id = dta_version->
      cond_expression_id, cd.active_ind = 0,
      cd.beg_effective_dt_tm = cnvtdatetime(dta_version->beg_effective_dt_tm), cd.end_effective_dt_tm
       = cnvtdatetime(curdate,curtime3), cd.age_from_nbr = dta_version->age_from_nbr,
      cd.age_from_unit_cd = dta_version->age_from_unit_cd, cd.age_to_nbr = dta_version->age_to_nbr,
      cd.age_to_unit_cd = dta_version->age_to_unit_cd,
      cd.prev_conditional_dta_id = prev_cond_id, cd.required_ind = dta_version->required_ind, cd
      .gender_cd = dta_version->gender_cd,
      cd.location_cd = dta_version->location_cd, cd.position_cd = dta_version->position_cd, cd
      .unknown_age_ind = dta_version->unknown_age_ind,
      cd.conditional_assay_cd = dta_version->conditional_assay_cd, cd.updt_id = reqinfo->updt_id, cd
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cd.updt_applctx = reqinfo->updt_applctx, cd.updt_cnt = 0, cd.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    UPDATE  FROM conditional_dta cd
     SET cd.cond_expression_id = request->cond_dtas[index].cond_expression_id, cd.active_ind = 1, cd
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      cd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cd.age_from_nbr = request->cond_dtas[
      index].age_from_nbr, cd.age_from_unit_cd = request->cond_dtas[index].age_from_unit_cd,
      cd.age_to_nbr = request->cond_dtas[index].age_to_nbr, cd.age_to_unit_cd = request->cond_dtas[
      index].age_to_unit_cd, cd.gender_cd = request->cond_dtas[index].gender_cd,
      cd.required_ind = request->cond_dtas[index].required_ind, cd.location_cd = request->cond_dtas[
      index].location_cd, cd.position_cd = request->cond_dtas[index].position_cd,
      cd.unknown_age_ind = request->cond_dtas[index].unknown_age_ind, cd.conditional_assay_cd =
      request->cond_dtas[index].conditional_assay_cd, cd.updt_id = reqinfo->updt_id,
      cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_applctx = reqinfo->updt_applctx, cd
      .updt_cnt = (cd.updt_cnt+ 1),
      cd.updt_task = reqinfo->updt_task
     WHERE (cd.conditional_dta_id=request->cond_dtas[index].conditional_dta_id)
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivateconditionalexpression(index)
   UPDATE  FROM cond_expression ce
    SET ce.active_ind = 0
    WHERE (ce.cond_expression_id=request->cond_expression_id)
    WITH nocounter
   ;end update
   UPDATE  FROM cond_expression_comp cec
    SET cec.active_ind = 0
    WHERE (cec.cond_expression_id=request->cond_expression_id)
    WITH nocounter
   ;end update
   UPDATE  FROM conditional_dta cd
    SET cd.active_ind = 0
    WHERE (cd.cond_expression_id=request->cond_expression_id)
    WITH nocounter
   ;end update
 END ;Subroutine
END GO
