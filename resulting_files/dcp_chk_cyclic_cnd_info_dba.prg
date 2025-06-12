CREATE PROGRAM dcp_chk_cyclic_cnd_info:dba
 RECORD reply(
   1 cyclic_dep_cnt = i4
   1 dep_list[*]
     2 cond_expression_id = f8
     2 dta_list[*]
       3 trigger_dta_cd = f8
       3 conditional_dta_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cond_cnt = i4 WITH protect, constant(size(request->cond_dtas,5))
 DECLARE comp_cnt = i4 WITH protect, constant(size(request->exp_comp,5))
 DECLARE expand1_index = i4 WITH protect, noconstant(0)
 DECLARE expand2_index = i4 WITH protect, noconstant(0)
 DECLARE dta_cnt = i4 WITH protect, noconstant(0)
 DECLARE dep_cnt = i4 WITH protect, noconstant(0)
 DECLARE dta_match_ind = i2 WITH protect, noconstant(0)
 SET reply->cyclic_dep_cnt = 0
 FOR (i = 1 TO cond_cnt)
   FOR (j = 1 TO comp_cnt)
     IF ((request->cond_dtas[i].conditional_assay_cd=request->exp_comp[j].trigger_assay_cd))
      SET dta_match_ind = 1
      SET stat = alterlist(reply->dep_list,1)
      SET stat = alterlist(reply->dep_list[1].dta_list,1)
      SET reply->dep_list[1].dta_list[1].trigger_dta_cd = request->exp_comp[j].trigger_assay_cd
      SET reply->dep_list[1].dta_list[1].conditional_dta_cd = request->exp_comp[j].trigger_assay_cd
      SET reply->cyclic_dep_cnt = 1
      GO TO exit_script
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM cond_expression_comp cec,
   cond_expression ce,
   conditional_dta cd
  PLAN (cec
   WHERE cec.active_ind=1
    AND expand(expand1_index,1,cond_cnt,cec.trigger_assay_cd,request->cond_dtas[expand1_index].
    conditional_assay_cd,
    cond_cnt))
   JOIN (ce
   WHERE ce.active_ind=1
    AND ce.cond_expression_id=cec.cond_expression_id)
   JOIN (cd
   WHERE cd.active_ind=1
    AND cd.cond_expression_id=ce.cond_expression_id
    AND expand(expand2_index,1,comp_cnt,cd.conditional_assay_cd,request->exp_comp[expand2_index].
    trigger_assay_cd,
    comp_cnt))
  ORDER BY cec.cond_expression_id, cd.conditional_assay_cd
  HEAD cec.cond_expression_id
   dta_cnt = 0, dep_cnt = (dep_cnt+ 1)
   IF (mod(dep_cnt,5)=1)
    stat = alterlist(reply->dep_list,(dep_cnt+ 4))
   ENDIF
   reply->dep_list[dep_cnt].cond_expression_id = cec.cond_expression_id
  HEAD cd.conditional_assay_cd
   dta_cnt = (dta_cnt+ 1)
   IF (mod(dta_cnt,5)=1)
    stat = alterlist(reply->dep_list[dep_cnt].dta_list,(dta_cnt+ 4))
   ENDIF
   reply->dep_list[dep_cnt].dta_list[dta_cnt].trigger_dta_cd = cec.trigger_assay_cd, reply->dep_list[
   dep_cnt].dta_list[dta_cnt].conditional_dta_cd = cd.conditional_assay_cd
  FOOT  cec.cond_expression_id
   stat = alterlist(reply->dep_list[dep_cnt].dta_list,dta_cnt)
  FOOT REPORT
   stat = alterlist(reply->dep_list,dep_cnt), reply->cyclic_dep_cnt = dep_cnt
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
