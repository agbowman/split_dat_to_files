CREATE PROGRAM dm_dcp_activity_log_rows:dba
 DECLARE token_nbr = i4 WITH noconstant(cnvtint(size(request->tokens,5)))
 DECLARE activitycount = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE retention_days = i4 WITH noconstant(0)
 FOR (i = 1 TO token_nbr)
   CASE (request->tokens[i].token_str)
    OF "RETENTIONDAYS":
     SET retention_days = cnvtint(request->tokens[i].value)
   ENDCASE
 ENDFOR
 SET interval = build(cnvtstring(retention_days),"D")
 SET target_dt = cnvtlookbehind(interval,cnvtdatetime(curdate,curtime3))
 SELECT INTO "nl:"
  FROM dcp_activity_log dal
  WHERE dal.activity_dt_tm < cnvtdatetime(target_dt)
   AND dal.activity_type_cd > 0
   AND dal.activity_log_id > 0
  ORDER BY dal.activity_dt_tm
  HEAD REPORT
   activitycount = 0, reply->err_code = 0, reply->table_name = "DCP_ACTIVITY_LOG",
   reply->rows_between_commit = 5000
  DETAIL
   activitycount = (activitycount+ 1), stat = alterlist(reply->rows,activitycount), reply->rows[
   activitycount].row_id = dal.rowid
  WITH nocounter, maxqual(dal,value(request->max_rows))
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reply->err_code = 0
 ELSE
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->err_code = 0
  ENDIF
 ENDIF
END GO
