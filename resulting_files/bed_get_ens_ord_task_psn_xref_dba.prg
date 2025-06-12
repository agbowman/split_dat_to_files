CREATE PROGRAM bed_get_ens_ord_task_psn_xref:dba
 FREE SET reply
 RECORD reply(
   1 olist[*]
     2 task_exists = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET listcount = 0
 SET listcount = size(request->olist,5)
 SET stat = alterlist(reply->olist,listcount)
 FOR (lvar = 1 TO listcount)
   IF ((request->action_flag="0"))
    SET reply->olist[lvar].task_exists = 0
    SELECT INTO "NL:"
     FROM order_task_position_xref otpx
     WHERE (otpx.reference_task_id=request->olist[lvar].order_task_id)
      AND (otpx.position_cd=request->position_cd)
     DETAIL
      reply->olist[lvar].task_exists = 1
     WITH nocounter
    ;end select
   ELSEIF ((request->action_flag="1"))
    SELECT INTO "NL:"
     FROM order_task_position_xref otpx
     WHERE (otpx.reference_task_id=request->olist[lvar].order_task_id)
      AND (otpx.position_cd=request->position_cd)
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM order_task_position_xref otpx
      SET otpx.reference_task_id = request->olist[lvar].order_task_id, otpx.position_cd = request->
       position_cd, otpx.updt_cnt = 0,
       otpx.updt_dt_tm = cnvtdatetime(curdate,curtime), otpx.updt_id = reqinfo->updt_id, otpx
       .updt_task = reqinfo->updt_task,
       otpx.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ELSEIF ((request->action_flag="3"))
    DELETE  FROM order_task_position_xref otpx
     WHERE (otpx.reference_task_id=request->olist[lvar].order_task_id)
      AND (otpx.position_cd=request->position_cd)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
END GO
