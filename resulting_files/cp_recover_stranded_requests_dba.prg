CREATE PROGRAM cp_recover_stranded_requests:dba
 RECORD temp(
   1 qual[*]
     2 chart_request_id = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count = 0
 SET req_count = 0
 SET failed = "S"
 SET reply->status_data.status = "F"
 SET dist_id = 0.0
 SET dist_run_type_cd = 0.0
 SET dist_run_dt_tm = cnvtdatetime(0,0)
 SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
 DECLARE chart_batch_id = f8 WITH noconstant(0.0)
 DECLARE unprocessed_status_cd = f8 WITH noconstant(0.0)
 DECLARE inprocess_status_cd = f8 WITH noconstant(0.0)
 DECLARE inrecovery_status_cd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(18609,"UNPROCESSED",1,unprocessed_status_cd)
 SET stat = uar_get_meaning_by_codeset(18609,"INPROCESS",1,inprocess_status_cd)
 SET stat = uar_get_meaning_by_codeset(18609,"INRECOVERY",1,inrecovery_status_cd)
 IF ((request->first_request != request->last_request))
  SELECT INTO "nl:"
   cr.distribution_id, cr.dist_run_type_cd, cr.dist_run_dt_tm,
   cr.chart_batch_id
   FROM chart_request cr
   WHERE (cr.chart_request_id=request->first_request)
   DETAIL
    dist_id = cr.distribution_id, dist_run_type_cd = cr.dist_run_type_cd, dist_run_dt_tm = cr
    .dist_run_dt_tm,
    chart_batch_id = cr.chart_batch_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT
  IF ((request->first_request=request->last_request))
   PLAN (cr
    WHERE (cr.chart_request_id=request->first_request)
     AND cr.chart_status_cd=inprocess_status_cd)
  ELSE
   PLAN (cr
    WHERE cr.chart_request_id BETWEEN request->first_request AND request->last_request
     AND ((cr.request_type=4) OR (cr.request_type=8))
     AND cr.chart_status_cd=inprocess_status_cd
     AND cr.distribution_id=dist_id
     AND cr.dist_run_type_cd=dist_run_type_cd
     AND cr.dist_run_dt_tm=cnvtdatetime(dist_run_dt_tm)
     AND cr.chart_batch_id=chart_batch_id)
  ENDIF
  INTO "nl:"
  cr.chart_request_id
  FROM chart_request cr
  PLAN (cr
   WHERE 1=0)
  ORDER BY cr.request_dt_tm, cr.chart_request_id
  HEAD REPORT
   req_count = 0
  DETAIL
   req_count = (req_count+ 1)
   IF (mod(req_count,10)=1)
    stat = alterlist(temp->qual,(req_count+ 9))
   ENDIF
   temp->qual[req_count].chart_request_id = cr.chart_request_id
  WITH outerjoin = d, nocounter, forupdate(cr)
 ;end select
 SET stat = alterlist(temp->qual,req_count)
 IF (req_count=0)
  SET failed = "Z"
  GO TO exit_script
 ENDIF
 UPDATE  FROM chart_request c,
   (dummyt d  WITH seq = value(req_count))
  SET c.chart_status_cd =
   IF (d.seq=1) inrecovery_status_cd
   ELSE unprocessed_status_cd
   ENDIF
   , c.recover_cnt =
   IF (d.seq=1) nullcheck((c.recover_cnt+ 1),1,nullind(c.recover_cnt))
   ELSE c.recover_cnt
   ENDIF
   , c.process_time =
   IF ((temp->qual[d.seq].chart_request_id=request->current_request)) (c.process_time+ request->
    process_time)
   ELSE 0.0
   ENDIF
   ,
   c.server_name = request->server_name, c.recover_dt_tm = cnvtdatetime(cur_dt_tm), c.active_ind = 1,
   c.active_status_cd = reqdata->active_status_cd, c.active_status_prsnl_id = reqinfo->updt_id, c
   .updt_cnt = (c.updt_cnt+ 1),
   c.updt_dt_tm = cnvtdatetime(cur_dt_tm), c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
   updt_applctx,
   c.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (c
   WHERE (c.chart_request_id=temp->qual[d.seq].chart_request_id))
  WITH nocounter
 ;end update
 IF (req_count=0)
  SET failed = "F"
 ENDIF
#exit_script
 IF (failed != "S")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = failed
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
