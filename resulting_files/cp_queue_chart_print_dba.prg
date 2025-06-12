CREATE PROGRAM cp_queue_chart_print:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE handleerror(status=c1,operationname=vc,targetvalue=vc) = null
 DECLARE unspooled_cd = f8
 DECLARE batch_seq = f8
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(28800,"UNSPOOLED",1,unspooled_cd)
 SELECT INTO "nl:"
  newid = seq(chart_seq,nextval)
  FROM dual
  DETAIL
   batch_seq = newid
  WITH nocounter
 ;end select
 IF (batch_seq=0)
  CALL handleerror("F","Select statement","Batch sequence creation failed")
 ENDIF
 INSERT  FROM chart_print_queue cpq,
   (dummyt d  WITH seq = value(size(request->batch,5)))
  SET cpq.chart_queue_id = seq(chart_seq,nextval), cpq.queue_status_cd = unspooled_cd, cpq.batch_id
    = batch_seq,
   cpq.request_id = request->request_id, cpq.distribution_id = request->distribution_id, cpq
   .dist_run_dt_tm = cnvtdatetime(request->dist_run_dt_tm),
   cpq.dist_terminator_ind = request->dist_term_ind, cpq.print_path = request->print_path, cpq
   .chart_path = cnvtlower(request->batch[d.seq].chart_path),
   cpq.num_copies = request->batch[d.seq].num_copies, cpq.begin_page = request->batch[d.seq].
   begin_page, cpq.end_page = request->batch[d.seq].end_page,
   cpq.queued_dt_tm = cnvtdatetime(curdate,curtime3), cpq.updt_cnt = 0, cpq.updt_dt_tm = cnvtdatetime
   (curdate,curtime3),
   cpq.updt_id = reqinfo->updt_id, cpq.updt_task = reqinfo->updt_task, cpq.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (cpq)
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  CALL handleerror("Z","Insert statement","Queue attempt failed")
 ENDIF
 SUBROUTINE handleerror(status,operationname,targetvalue)
   SET reqinfo->commit_ind = 0
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.operationname = operationname
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "Error Message"
    SET reply->status_data.targetobjectvalue = errmsg
   ELSE
    SET reply->status_data.status = status
    SET reply->status_data.operationname = operationname
    SET reply->status_data.operationstatus = "S"
    SET reply->status_data.targetobjectvalue = targetvalue
   ENDIF
   GO TO exit_script
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
END GO
