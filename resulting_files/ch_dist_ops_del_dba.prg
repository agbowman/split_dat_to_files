CREATE PROGRAM ch_dist_ops_del:dba
 RECORD reply(
   1 qual[*]
     2 op_number = f8
     2 op_descr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET code_value1 = 0.0
 SET cdf_meaning1 = fillstring(12," ")
 SET code_set1 = 48
 SET cdf_meaning1 = "INACTIVE"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET inactive_cd = code_value1
 CALL echo(build("request->dist_id = ",request->dist_id))
 CALL echo(build("request->law_id = ",request->law_id))
 CALL echo(build("inactive_cd = ",inactive_cd))
 IF (cnvtreal(request->dist_id) > 0)
  SELECT INTO "nl:"
   FROM charting_operations o
   WHERE o.param_type_flag=2
    AND (o.param=request->dist_id)
    AND o.active_ind=1
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].op_number = o
    .charting_operations_id,
    reply->qual[count].op_descr = o.batch_name
   WITH nocounter
  ;end select
 ELSEIF (cnvtreal(request->law_id) > 0)
  SELECT INTO "nl:"
   FROM charting_operations o
   WHERE o.param_type_flag=18
    AND (o.param=request->law_id)
    AND o.active_ind=1
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].op_number = o
    .charting_operations_id,
    reply->qual[count].op_descr = o.batch_name
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->qual,count)
 CALL echo(build("count = ",count))
 FOR (x = 1 TO count)
   CALL echo(reply->qual[count].op_number)
 ENDFOR
 SET cnt_delete = 0
 SET cnt_delete = size(reply->qual,5)
 FOR (x = 1 TO cnt_delete)
   UPDATE  FROM charting_operations co
    SET co.active_ind = 0, co.updt_dt_tm = cnvtdatetime(curdate,curtime3), co.active_status_cd =
     inactive_cd,
     co.active_status_prsnl_id = reqinfo->updt_id, co.active_status_dt_tm = cnvtdatetime(curdate,
      curtime), co.updt_id = reqinfo->updt_id
    WHERE (co.charting_operations_id=reply->qual[x].op_number)
   ;end update
 ENDFOR
 IF (curqual=0)
  CALL echo("Z")
  SET reply->status_data.status = "Z"
 ELSE
  CALL echo("successful")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
