CREATE PROGRAM bed_imp_br_of_depts:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET row_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO row_cnt)
   INSERT  FROM br_of_depts b
    SET b.of_dept_id = seq(bedrock_seq,nextval), b.of_dept_name = requestin->list_0[x].of_dept_name,
     b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
