CREATE PROGRAM dcp_upd_parameter_text:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE paramcnt = i4 WITH constant(size(request->parameters,5))
 DECLARE x = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 FOR (x = 1 TO paramcnt)
   SELECT INTO "nl:"
    dpqp.query_type_cd, dpqp.parameter_seq
    FROM dcp_pl_query_parameter dpqp
    WHERE (dpqp.query_type_cd=request->query_type_cd)
     AND (dpqp.parameter_seq=request->parameters[x].sequence)
    DETAIL
     cur_updt_cnt = dpqp.updt_cnt
    WITH nocounter, forupdate(dpqp)
   ;end select
   IF (curqual=0)
    CALL echo("Lock row for update on table dcp_pl_query_parameter failed since curqual = 0")
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   UPDATE  FROM dcp_pl_query_parameter dpqp
    SET dpqp.parameter_name = request->parameters[x].name, dpqp.parameter_desc = request->parameters[
     x].description
    WHERE (dpqp.query_type_cd=request->query_type_cd)
     AND (dpqp.parameter_seq=request->parameters[x].sequence)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 ENDFOR
#exit_script
 CALL echorecord(reply)
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
