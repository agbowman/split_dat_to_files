CREATE PROGRAM dcp_get_all_conditional_info:dba
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
 SELECT INTO "nl:"
  FROM cond_expression ce
  WHERE ce.active_ind=1
  ORDER BY ce.cond_expression_name
  DETAIL
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
 CALL echorecord(reply)
#exit_script
 IF (exp_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
