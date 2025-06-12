CREATE PROGRAM dcp_get_all_conditions_for_dta:dba
 RECORD reply(
   1 exp_list[*]
     2 cond_expression_id = f8
     2 cond_expression_name = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE exp_cnt = i4 WITH noconstant(0)
 DECLARE cur_date = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 IF ((request->trigger_flag=1))
  SELECT INTO "nl:"
   FROM cond_expression_comp cec,
    cond_expression ce
   PLAN (cec
    WHERE (cec.trigger_assay_cd=request->dta_cd)
     AND cec.active_ind=1
     AND cec.beg_effective_dt_tm <= cnvtdatetime(cur_date)
     AND cec.end_effective_dt_tm >= cnvtdatetime(cur_date))
    JOIN (ce
    WHERE cec.cond_expression_id=ce.cond_expression_id
     AND ce.active_ind=1
     AND ce.beg_effective_dt_tm <= cnvtdatetime(cur_date)
     AND ce.end_effective_dt_tm >= cnvtdatetime(cur_date))
   ORDER BY cec.cond_expression_id
   HEAD cec.cond_expression_id
    exp_cnt = (exp_cnt+ 1)
    IF (mod(exp_cnt,5)=1)
     stat = alterlist(reply->exp_list,(exp_cnt+ 4))
    ENDIF
    reply->exp_list[exp_cnt].cond_expression_id = ce.cond_expression_id, reply->exp_list[exp_cnt].
    cond_expression_name = ce.cond_expression_name
   FOOT REPORT
    stat = alterlist(reply->exp_list,exp_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM conditional_dta cd,
    cond_expression ce
   PLAN (cd
    WHERE (cd.conditional_assay_cd=request->dta_cd)
     AND cd.active_ind=1
     AND cd.beg_effective_dt_tm <= cnvtdatetime(cur_date)
     AND cd.end_effective_dt_tm >= cnvtdatetime(cur_date))
    JOIN (ce
    WHERE cd.cond_expression_id=ce.cond_expression_id
     AND ce.active_ind=1
     AND ce.beg_effective_dt_tm <= cnvtdatetime(cur_date)
     AND ce.end_effective_dt_tm >= cnvtdatetime(cur_date))
   ORDER BY cd.cond_expression_id
   HEAD cd.cond_expression_id
    exp_cnt = (exp_cnt+ 1)
    IF (mod(exp_cnt,5)=1)
     stat = alterlist(reply->exp_list,(exp_cnt+ 4))
    ENDIF
    reply->exp_list[exp_cnt].cond_expression_id = ce.cond_expression_id, reply->exp_list[exp_cnt].
    cond_expression_name = ce.cond_expression_name
   FOOT REPORT
    stat = alterlist(reply->exp_list,exp_cnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (exp_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
