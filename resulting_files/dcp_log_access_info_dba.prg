CREATE PROGRAM dcp_log_access_info:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE user_found_ind = i2 WITH noconstant(0)
 DECLARE total_count = i2 WITH noconstant(0)
 DECLARE server_name_count = i2 WITH noconstant(0)
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE last_update_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE insert_required = i2 WITH noconstant(0)
 DECLARE record_index = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET insert_required = 1
 SELECT INTO "nl:"
  FROM nursing_usage_data nud
  WHERE (nud.audit_solution_cd=request->audit_solution_cd)
   AND nud.period_end_dt_tm > cnvtlookbehind("2,H")
  ORDER BY nud.period_end_dt_tm DESC
  HEAD nud.period_end_dt_tm
   IF (insert_required=1)
    last_update_dt_tm = nud.period_end_dt_tm
   ENDIF
   insert_required = 0
  WITH nocounter
 ;end select
 IF (insert_required=1)
  DECLARE currenttime = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
  DECLARE shiftedtime = dq8 WITH protect, noconstant(cnvtlookbehind("15,MIN",currenttime))
  SET last_update_dt_tm = datetimetrunc(shiftedtime,"HH")
 ENDIF
 FREE SET summaryitems
 RECORD summaryitems(
   1 insert_list[*]
     2 server_name = vc
     2 user_count = i4
     2 period_start_dt_tm = dq8
     2 period_end_dt_tm = dq8
 )
 WHILE (datetimediff(cnvtdatetime(curdate,curtime3),last_update_dt_tm,4) > 15)
   SET total_count = 0
   SELECT INTO "nl:"
    FROM nursing_user_access nua
    WHERE (nua.audit_solution_cd=request->audit_solution_cd)
     AND nua.last_access_dt_tm >= cnvtdatetime(last_update_dt_tm)
     AND nua.last_access_dt_tm < cnvtdatetime(cnvtlookahead("15,MIN",last_update_dt_tm))
    ORDER BY nua.server_name
    HEAD REPORT
     total_count = 0
    HEAD nua.server_name
     server_name_count = 0
    DETAIL
     server_name_count = (server_name_count+ 1), total_count = (total_count+ 1)
    FOOT  nua.server_name
     record_index = (record_index+ 1)
     IF (record_index > size(summaryitems->insert_list,5))
      stat = alterlist(summaryitems->insert_list,(record_index+ 9))
     ENDIF
     summaryitems->insert_list[record_index].server_name = nua.server_name, summaryitems->
     insert_list[record_index].user_count = server_name_count, summaryitems->insert_list[record_index
     ].period_start_dt_tm = last_update_dt_tm,
     summaryitems->insert_list[record_index].period_end_dt_tm = cnvtlookahead("15,MIN",
      last_update_dt_tm)
    WITH nocounter
   ;end select
   SET record_index = (record_index+ 1)
   SET stat = alterlist(summaryitems->insert_list,record_index)
   SET summaryitems->insert_list[record_index].server_name = ""
   SET summaryitems->insert_list[record_index].user_count = total_count
   SET summaryitems->insert_list[record_index].period_start_dt_tm = last_update_dt_tm
   SET summaryitems->insert_list[record_index].period_end_dt_tm = cnvtlookahead("15,MIN",
    last_update_dt_tm)
   SET last_update_dt_tm = cnvtlookahead("15,MIN",last_update_dt_tm)
 ENDWHILE
 IF (size(summaryitems->insert_list,5) > 0)
  INSERT  FROM nursing_usage_data nud,
    (dummyt d  WITH seq = value(size(summaryitems->insert_list,5)))
   SET nud.nursing_usage_data_id = seq(nursing_transaction_seq,nextval), nud.audit_solution_cd =
    request->audit_solution_cd, nud.period_start_dt_tm = cnvtdatetime(summaryitems->insert_list[d.seq
     ].period_start_dt_tm),
    nud.period_end_dt_tm = cnvtdatetime(summaryitems->insert_list[d.seq].period_end_dt_tm), nud
    .user_count = summaryitems->insert_list[d.seq].user_count, nud.server_name = summaryitems->
    insert_list[d.seq].server_name,
    nud.updt_id = reqinfo->updt_id, nud.updt_task = reqinfo->updt_task, nud.updt_applctx = reqinfo->
    updt_applctx,
    nud.updt_cnt = 0, nud.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (nud)
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  FROM nursing_user_access nua
  WHERE (nua.user_id=request->user_id)
   AND (nua.audit_solution_cd=request->audit_solution_cd)
  DETAIL
   user_found_ind = 1
  WITH nocounter
 ;end select
 IF (user_found_ind=0)
  SELECT INTO "nl:"
   FROM dual
  ;end select
  INSERT  FROM nursing_user_access nua
   SET nua.audit_solution_cd = request->audit_solution_cd, nua.nursing_user_access_id = seq(
     nursing_transaction_seq,nextval), nua.last_access_dt_tm = cnvtdatetime(curdate,curtime3),
    nua.user_id = request->user_id, nua.server_name = request->server_name, nua.updt_id = reqinfo->
    updt_id,
    nua.updt_task = reqinfo->updt_task, nua.updt_applctx = reqinfo->updt_applctx, nua.updt_cnt = 0,
    nua.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ELSE
  UPDATE  FROM nursing_user_access nua
   SET nua.last_access_dt_tm = cnvtdatetime(curdate,curtime3), nua.server_name = request->server_name,
    nua.updt_id = reqinfo->updt_id,
    nua.updt_task = reqinfo->updt_task, nua.updt_applctx = reqinfo->updt_applctx, nua.updt_cnt = (nua
    .updt_cnt+ 1),
    nua.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (nua.user_id=request->user_id)
    AND (nua.audit_solution_cd=request->audit_solution_cd)
   WITH nocounter
  ;end update
 ENDIF
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 SET last_mod = "000 10/31/13"
 SET modify = nopredeclare
END GO
