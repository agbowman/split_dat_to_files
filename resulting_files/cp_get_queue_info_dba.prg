CREATE PROGRAM cp_get_queue_info:dba
 RECORD reply(
   1 distribution_item[*]
     2 distribution_id = f8
     2 distribution_desc = vc
     2 dist_run_dt_tm = dq8
     2 batch_item[*]
       3 batch_id = f8
       3 request_id = f8
       3 file_item[*]
         4 queue_id = f8
         4 queue_dt_tm = dq8
         4 status_cd = f8
         4 status_disp = c40
         4 status_desc = c60
         4 status_mean = c12
         4 chart_path = vc
         4 num_copies = i4
         4 begin_page = i4
         4 end_page = i4
         4 print_path = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE handleerror(status=c1,operationname=vc,targetvalue=vc) = null
 DECLARE cr_req_cnt = i4
 DECLARE qual_chart_req = i2
 DECLARE begin_dt_tm = q8
 DECLARE end_dt_tm = q8
 DECLARE dist_qual_clause = vc
 DECLARE cr_qual_clause = vc
 DECLARE where_clause = vc
 DECLARE str = vc
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET cr_req_cnt = size(request->chart_requests,5)
 IF (cr_req_cnt > 0)
  SELECT DISTINCT INTO "nl:"
   FROM chart_print_queue cpq,
    (dummyt d  WITH seq = value(cr_req_cnt))
   PLAN (d)
    JOIN (cpq
    WHERE cpq.distribution_id > 0
     AND (cpq.request_id=request->chart_requests[d.seq].chart_request_id))
   ORDER BY cpq.distribution_id, cpq.dist_run_dt_tm
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), str = build("(cpq.distribution_id = ",cpq.distribution_id,
     " AND cpq.dist_run_dt_tm = CNVTDATETIME(",cpq.dist_run_dt_tm,"))")
    IF (count=1)
     dist_qual_clause = str
    ELSE
     dist_qual_clause = concat(dist_qual_clause," OR ",str)
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET qual_chart_req = 1
  ENDIF
  CALL echo(concat("dist_qual_clause = ",dist_qual_clause))
  SELECT DISTINCT INTO "nl:"
   FROM chart_print_queue cpq,
    (dummyt d  WITH seq = value(cr_req_cnt))
   PLAN (d)
    JOIN (cpq
    WHERE cpq.distribution_id=0
     AND (cpq.request_id=request->chart_requests[d.seq].chart_request_id))
   ORDER BY cpq.request_id
   HEAD REPORT
    count = 0, cr_qual_clause = "cpq.distribution_id = 0 AND cpq.request_id IN ("
   DETAIL
    count = (count+ 1)
    IF (count=1)
     cr_qual_clause = build(cr_qual_clause,cpq.request_id)
    ELSE
     cr_qual_clause = build(cr_qual_clause,", ",cpq.request_id)
    ENDIF
   FOOT REPORT
    cr_qual_clause = concat(cr_qual_clause,")")
   WITH nocounter
  ;end select
  CALL echo(concat("cr_qual_clause = ",cr_qual_clause))
  IF (curqual > 0)
   SET qual_chart_req = 1
  ENDIF
  IF (qual_chart_req=0)
   CALL handleerror("Z","Select statement","No queued charts")
  ENDIF
  IF (dist_qual_clause != null
   AND cr_qual_clause != null)
   SET where_clause = concat("(",dist_qual_clause,") OR (",cr_qual_clause,")")
  ELSE
   IF (dist_qual_clause != null)
    SET where_clause = dist_qual_clause
   ELSE
    SET where_clause = cr_qual_clause
   ENDIF
  ENDIF
 ELSE
  IF ((request->begin_dt_tm=null))
   SET begin_dt_tm = cnvtdatetime("01-Jan-1800")
  ELSE
   SET begin_dt_tm = request->begin_dt_tm
  ENDIF
  IF ((request->end_dt_tm=null))
   SET end_dt_tm = cnvtdatetime("31-Dec-2100")
  ELSE
   SET end_dt_tm = request->end_dt_tm
  ENDIF
  SET where_clause = concat("cpq.queued_dt_tm BETWEEN CNVTDATETIME(begin_dt_tm)",
   " AND CNVTDATETIME(end_dt_tm)")
 ENDIF
 CALL echo(concat("where_clause = ",where_clause))
 SELECT INTO "nl:"
  FROM chart_print_queue cpq,
   chart_distribution cd
  PLAN (cpq
   WHERE parser(where_clause))
   JOIN (cd
   WHERE cd.distribution_id=cpq.distribution_id)
  ORDER BY cpq.distribution_id, cpq.batch_id, cpq.chart_queue_id
  HEAD REPORT
   distitemcnt = 0, batchitemcnt = 0, fileitemcnt = 0
  HEAD cpq.distribution_id
   distitemcnt = (distitemcnt+ 1)
   IF (mod(distitemcnt,10)=1)
    stat = alterlist(reply->distribution_item,(distitemcnt+ 9))
   ENDIF
   reply->distribution_item[distitemcnt].distribution_id = cpq.distribution_id, reply->
   distribution_item[distitemcnt].distribution_desc = cd.dist_descr, reply->distribution_item[
   distitemcnt].dist_run_dt_tm = cpq.dist_run_dt_tm
  HEAD cpq.batch_id
   batchitemcnt = (batchitemcnt+ 1)
   IF (mod(batchitemcnt,10)=1)
    stat = alterlist(reply->distribution_item[distitemcnt].batch_item,(batchitemcnt+ 9))
   ENDIF
   reply->distribution_item[distitemcnt].batch_item[batchitemcnt].batch_id = cpq.batch_id, reply->
   distribution_item[distitemcnt].batch_item[batchitemcnt].request_id = cpq.request_id
  DETAIL
   fileitemcnt = (fileitemcnt+ 1)
   IF (mod(fileitemcnt,3)=1)
    stat = alterlist(reply->distribution_item[distitemcnt].batch_item[batchitemcnt].file_item,(
     fileitemcnt+ 2))
   ENDIF
   reply->distribution_item[distitemcnt].batch_item[batchitemcnt].file_item[fileitemcnt].queue_id =
   cpq.chart_queue_id, reply->distribution_item[distitemcnt].batch_item[batchitemcnt].file_item[
   fileitemcnt].queue_dt_tm = cpq.queued_dt_tm, reply->distribution_item[distitemcnt].batch_item[
   batchitemcnt].file_item[fileitemcnt].status_cd = cpq.queue_status_cd,
   reply->distribution_item[distitemcnt].batch_item[batchitemcnt].file_item[fileitemcnt].chart_path
    = cpq.chart_path, reply->distribution_item[distitemcnt].batch_item[batchitemcnt].file_item[
   fileitemcnt].num_copies = cpq.num_copies, reply->distribution_item[distitemcnt].batch_item[
   batchitemcnt].file_item[fileitemcnt].begin_page = cpq.begin_page,
   reply->distribution_item[distitemcnt].batch_item[batchitemcnt].file_item[fileitemcnt].end_page =
   cpq.end_page, reply->distribution_item[distitemcnt].batch_item[batchitemcnt].file_item[fileitemcnt
   ].print_path = cpq.print_path
  FOOT  cpq.batch_id
   stat = alterlist(reply->distribution_item[distitemcnt].batch_item[batchitemcnt].file_item,
    fileitemcnt), fileitemcnt = 0
  FOOT  cpq.distribution_id
   stat = alterlist(reply->distribution_item[distitemcnt].batch_item,batchitemcnt), batchitemcnt = 0
  FOOT REPORT
   stat = alterlist(reply->distribution_item,distitemcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handleerror("Z","Select statement","No queued charts")
 ENDIF
 SET reply->status_data.status = "S"
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
