CREATE PROGRAM cp_update_log:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nextseq = f8 WITH noconstant(0.0)
 SET count = 0
 SET qual_size = size(request->qual,5)
 FOR (x = 1 TO qual_size)
   SELECT INTO "nl:"
    seq1 = seq(chart_serv_log_seq,nextval)
    FROM dual
    DETAIL
     nextseq = seq1
    WITH nocounter
   ;end select
   CALL echo(build("seq = ",nextseq))
   UPDATE  FROM chart_serv_log cl
    SET cl.log_dt_tm = cnvtdatetime(curdate,curtime3), cl.log_level = request->qual[x].log_level, cl
     .chart_request_id = request->qual[x].chart_request_id,
     cl.message_text = request->qual[x].message_text, cl.server_name = cnvtupper(trim(request->qual[x
       ].server_name)), cl.updt_cnt = 0,
     cl.updt_dt_tm = cnvtdatetime(curdate,curtime3), cl.updt_id = reqinfo->updt_id, cl.updt_applctx
      = reqinfo->updt_applctx,
     cl.updt_task = reqinfo->updt_task
    WHERE cl.chart_log_num=nextseq
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM chart_serv_log cl
     SET cl.chart_log_num = nextseq, cl.log_dt_tm = cnvtdatetime(curdate,curtime3), cl.log_level =
      request->qual[x].log_level,
      cl.chart_request_id = request->qual[x].chart_request_id, cl.message_text = request->qual[x].
      message_text, cl.server_name = request->qual[x].server_name,
      cl.updt_cnt = 0, cl.updt_dt_tm = cnvtdatetime(curdate,curtime3), cl.updt_id = reqinfo->updt_id,
      cl.updt_applctx = reqinfo->updt_applctx, cl.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET count = (count+ 1)
    ENDIF
   ELSE
    SET count = (count+ 1)
   ENDIF
 ENDFOR
#exit_script
 IF (count != qual_size)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
