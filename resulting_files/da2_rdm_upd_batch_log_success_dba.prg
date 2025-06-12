CREATE PROGRAM da2_rdm_upd_batch_log_success:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script da2_rdm_upd_batch_log_success..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE maxlistsize = i4 WITH protect, noconstant(0)
 DECLARE loop = i4 WITH protect, noconstant(0)
 DECLARE successschedquerycount = i4 WITH protect, noconstant(0)
 DECLARE successschedreportcount = i4 WITH protect, noconstant(0)
 FREE RECORD da_batch_query_log
 RECORD da_batch_query_log(
   1 logs[*]
     2 da_batch_query_log_id = f8
     2 da_batch_sched_log_id = f8
 )
 FREE RECORD da_batch_report_log
 RECORD da_batch_report_log(
   1 logs[*]
     2 da_batch_report_log_id = f8
     2 da_batch_sched_log_id = f8
 )
 FREE RECORD successful_query_sched_log
 RECORD successful_query_sched_log(
   1 logs[*]
     2 da_batch_sched_log_id = f8
 )
 FREE RECORD successful_report_sched_log
 RECORD successful_report_sched_log(
   1 logs[*]
     2 da_batch_sched_log_id = f8
 )
 SET stat = alterlist(successful_query_sched_log->logs,100)
 SET stat = alterlist(successful_report_sched_log->logs,100)
 SELECT
  dbql.da_batch_query_log_id, dbql.da_batch_sched_log_id
  FROM da_batch_query_log dbql
  WHERE dbql.da_batch_query_log_id > 0
   AND dbql.success_ind=0
  ORDER BY dbql.da_batch_sched_log_id, dbql.da_batch_query_log_id
  HEAD REPORT
   stat = alterlist(da_batch_query_log->logs,100), pcount1 = 0
  HEAD dbql.da_batch_sched_log_id
   schedquerycount = 0, successquerycount = 0
  DETAIL
   schedquerycount += 1
   IF (dbql.created_document_id > 0
    AND dbql.error_txt_id=0
    AND dbql.batch_query_end_dt_tm != null)
    successquerycount += 1, pcount1 += 1
    IF (mod(pcount1,10)=1
     AND pcount1 > 100)
     stat = alterlist(da_batch_query_log->logs,(pcount1+ 9))
    ENDIF
    da_batch_query_log->logs[pcount1].da_batch_query_log_id = dbql.da_batch_query_log_id,
    da_batch_query_log->logs[pcount1].da_batch_sched_log_id = dbql.da_batch_sched_log_id
   ENDIF
  FOOT  dbql.da_batch_sched_log_id
   IF (schedquerycount=successquerycount)
    successschedquerycount += 1
    IF (mod(successschedquerycount,10)=1
     AND successschedquerycount > 100)
     stat = alterlist(successful_query_sched_log->logs,(successschedquerycount+ 9))
    ENDIF
    successful_query_sched_log->logs[successschedquerycount].da_batch_sched_log_id = dbql
    .da_batch_sched_log_id
   ENDIF
  FOOT REPORT
   stat = alterlist(da_batch_query_log->logs,pcount1), stat = alterlist(successful_query_sched_log->
    logs,successschedquerycount)
  WITH nocounter
 ;end select
 CALL check_for_errors("QUERY","DA_BATCH_QUERY_LOG")
 SELECT
  dbrl.da_batch_report_log_id, dbrl.da_batch_sched_log_id
  FROM da_batch_report_log dbrl
  WHERE dbrl.da_batch_report_log_id > 0
   AND dbrl.success_ind=0
  ORDER BY dbrl.da_batch_sched_log_id, dbrl.da_batch_report_log_id
  HEAD REPORT
   stat = alterlist(da_batch_report_log->logs,100), pcount2 = 0
  HEAD dbrl.da_batch_sched_log_id
   schedreportcount = 0, successreportcount = 0
  DETAIL
   schedreportcount += 1
   IF (dbrl.created_document_id > 0
    AND dbrl.error_txt_id=0
    AND dbrl.batch_report_end_dt_tm != null)
    successreportcount += 1, pcount2 += 1
    IF (mod(pcount2,10)=1
     AND pcount2 > 100)
     stat = alterlist(da_batch_report_log->logs,(pcount2+ 9))
    ENDIF
    da_batch_report_log->logs[pcount2].da_batch_report_log_id = dbrl.da_batch_report_log_id,
    da_batch_report_log->logs[pcount2].da_batch_sched_log_id = dbrl.da_batch_sched_log_id
   ENDIF
  FOOT  dbrl.da_batch_sched_log_id
   IF (schedreportcount=successreportcount)
    successschedreportcount += 1
    IF (mod(successschedreportcount,10)=1
     AND successschedreportcount > 100)
     stat = alterlist(successful_report_sched_log->logs,(successschedreportcount+ 9))
    ENDIF
    successful_report_sched_log->logs[successschedreportcount].da_batch_sched_log_id = dbrl
    .da_batch_sched_log_id
   ENDIF
  FOOT REPORT
   stat = alterlist(da_batch_report_log->logs,pcount2), stat = alterlist(successful_report_sched_log
    ->logs,successschedreportcount)
  WITH nocounter
 ;end select
 CALL check_for_errors("QUERY","DA_BATCH_REPORT_LOG")
 CALL echo(build("Query Logs to Update: ",size(da_batch_query_log->logs,5)))
 CALL echo(build("Report Logs to Update: ",size(da_batch_report_log->logs,5)))
 CALL echo(build("Schedule Logs to Update from Queries: ",size(successful_query_sched_log->logs,5)))
 CALL echo(build("Schedule Logs to Update from Reports: ",size(successful_report_sched_log->logs,5)))
 IF (size(successful_query_sched_log->logs,5) > 0)
  UPDATE  FROM da_batch_sched_log dbsl,
    (dummyt d3  WITH seq = value(size(successful_query_sched_log->logs,5)))
   SET dbsl.success_ind = 1, dbsl.updt_applctx = reqinfo->updt_applctx, dbsl.updt_cnt = (dbsl
    .updt_cnt+ 1),
    dbsl.updt_dt_tm = cnvtdatetime(sysdate), dbsl.updt_id = reqinfo->updt_id, dbsl.updt_task =
    reqinfo->updt_task
   PLAN (d3)
    JOIN (dbsl
    WHERE (dbsl.da_batch_sched_log_id=successful_query_sched_log->logs[d3.seq].da_batch_sched_log_id)
    )
   WITH nocounter
  ;end update
  CALL check_for_errors("UPDATE","DA_BATCH_SCHED_LOG - QUERY SCHEDULES")
 ENDIF
 IF (size(successful_report_sched_log->logs,5) > 0)
  UPDATE  FROM da_batch_sched_log dbsl,
    (dummyt d3  WITH seq = value(size(successful_report_sched_log->logs,5)))
   SET dbsl.success_ind = 1, dbsl.updt_applctx = reqinfo->updt_applctx, dbsl.updt_cnt = (dbsl
    .updt_cnt+ 1),
    dbsl.updt_dt_tm = cnvtdatetime(sysdate), dbsl.updt_id = reqinfo->updt_id, dbsl.updt_task =
    reqinfo->updt_task
   PLAN (d3)
    JOIN (dbsl
    WHERE (dbsl.da_batch_sched_log_id=successful_report_sched_log->logs[d3.seq].da_batch_sched_log_id
    ))
   WITH nocounter
  ;end update
  CALL check_for_errors("UPDATE","DA_BATCH_SCHED_LOG - REPORT SCHEDULES")
 ENDIF
 IF (size(da_batch_query_log->logs,5) > 0)
  UPDATE  FROM da_batch_query_log dbql,
    (dummyt d1  WITH seq = value(size(da_batch_query_log->logs,5)))
   SET dbql.success_ind = 1, dbql.updt_applctx = reqinfo->updt_applctx, dbql.updt_cnt = (dbql
    .updt_cnt+ 1),
    dbql.updt_dt_tm = cnvtdatetime(sysdate), dbql.updt_id = reqinfo->updt_id, dbql.updt_task =
    reqinfo->updt_task
   PLAN (d1)
    JOIN (dbql
    WHERE (dbql.da_batch_query_log_id=da_batch_query_log->logs[d1.seq].da_batch_query_log_id))
   WITH nocounter
  ;end update
  CALL check_for_errors("UPDATE","DA_BATCH_QUERY_LOG")
 ENDIF
 IF (size(da_batch_report_log->logs,5) > 0)
  UPDATE  FROM da_batch_report_log dbrl,
    (dummyt d1  WITH seq = value(size(da_batch_report_log->logs,5)))
   SET dbrl.success_ind = 1, dbrl.updt_applctx = reqinfo->updt_applctx, dbrl.updt_cnt = (dbrl
    .updt_cnt+ 1),
    dbrl.updt_dt_tm = cnvtdatetime(sysdate), dbrl.updt_id = reqinfo->updt_id, dbrl.updt_task =
    reqinfo->updt_task
   PLAN (d1)
    JOIN (dbrl
    WHERE (dbrl.da_batch_report_log_id=da_batch_report_log->logs[d1.seq].da_batch_report_log_id))
   WITH nocounter
  ;end update
  CALL check_for_errors("UPDATE","DA_BATCH_REPORT_LOG")
 ENDIF
 CALL echo("Readme Success: finished running script da2_rdm_upd_batch_log_success...")
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 FREE RECORD da_batch_query_log
 FREE RECORD da_batch_report_log
 FREE RECORD successful_query_sched_log
 FREE RECORD successful_report_sched_log
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SUBROUTINE (check_for_errors(operation=vc(val),tablename=vc(val)) =null)
  CALL echo(build("Checking for errors on the '",operation,"' operation of the table '",tablename,"'"
    ))
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to ",operation," table ",tablename,": ",
    errmsg)
   GO TO exit_script
  ELSE
   CALL echo(build("CURQUAL:",curqual))
   COMMIT
  ENDIF
 END ;Subroutine
END GO
