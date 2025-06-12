CREATE PROGRAM cp_update_chart_request:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "S"
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET status_cd = 0.0
 SET final_cd = 0.0
 SET addendum_cd = 0.0
 DECLARE inerr_evnt_nbr = i4 WITH noconstant(size(request->inerr_events,5))
 DECLARE section_nbr = i4 WITH noconstant(size(request->sections,5))
 DECLARE resub_cnt = i4 WITH noconstant(0)
 DECLARE resub_dt_tm = q8
 SET code_set = 18609
 SET cdf_meaning = request->status_cdf_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET status_cd = code_value
 UPDATE  FROM chart_request cr
  SET cr.chart_status_cd = status_cd, cr.handle_id = request->handle_id, cr.process_time = (cr
   .process_time+ request->process_time),
   cr.server_name = trim(substring(1,20,request->server_name)), cr.total_pages = request->total_pages,
   cr.active_ind = 1,
   cr.active_status_cd = reqdata->active_status_cd, cr.updt_cnt = (cr.updt_cnt+ 1), cr.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   cr.updt_id = reqinfo->updt_id, cr.updt_applctx = reqinfo->updt_applctx, cr.updt_task = reqinfo->
   updt_task
  WHERE (cr.chart_request_id=request->chart_request_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "1"
  GO TO exit_script
 ENDIF
 IF (inerr_evnt_nbr > 0)
  INSERT  FROM chart_req_inerr_event crie,
    (dummyt d  WITH seq = value(inerr_evnt_nbr))
   SET crie.chart_req_inerr_event_id = seq(chart_db_seq,nextval), crie.chart_request_id = request->
    chart_request_id, crie.event_id = request->inerr_events[d.seq].event_id,
    crie.updt_id = reqinfo->updt_id, crie.updt_dt_tm = cnvtdatetime(curdate,curtime), crie.updt_cnt
     = 0,
    crie.updt_applctx = reqinfo->updt_applctx, crie.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (crie)
   WITH nocounter
  ;end insert
 ENDIF
 IF (section_nbr > 0)
  SELECT INTO "nl:"
   FROM chart_request cr
   WHERE (cr.chart_request_id=request->chart_request_id)
   DETAIL
    resub_cnt = cr.resubmit_cnt, resub_dt_tm = cnvtdatetime(cr.resubmit_dt_tm)
   WITH nocounter
  ;end select
  CALL echo(build("resubmit count:  ",resub_cnt))
  CALL echo(build("resubmit datetime:  ",resub_dt_tm))
  INSERT  FROM chart_printed_sections cps,
    (dummyt d  WITH seq = value(section_nbr))
   SET cps.printed_section_id = seq(chart_db_seq,nextval), cps.chart_request_id = request->
    chart_request_id, cps.resubmit_nbr = resub_cnt,
    cps.resubmit_dt_tm = cnvtdatetime(resub_dt_tm), cps.chart_section_id = request->sections[d.seq].
    section_id, cps.updt_id = reqinfo->updt_id,
    cps.updt_dt_tm = cnvtdatetime(curdate,curtime), cps.updt_cnt = 0, cps.updt_applctx = reqinfo->
    updt_applctx,
    cps.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (cps)
   WITH nocounter
  ;end insert
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
