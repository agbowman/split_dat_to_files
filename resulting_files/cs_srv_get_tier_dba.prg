CREATE PROGRAM cs_srv_get_tier:dba
 CALL echo(concat("CS_SRV_GET_TIER - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(request)
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE tier_cnt = i2
 DECLARE cur_tier = f8
 DECLARE row_cnt = i2
 DECLARE col_cnt = i2
 DECLARE cur_row = i2
 DECLARE cur_col = i2
 SET tier_cnt = 0
 SET cur_tier = 0
 SET row_cnt = 0
 SET col_cnt = 0
 SET cur_row = 0
 SET cur_col = 0
 SELECT
  IF ((request->load_all=1))
   WHERE tm.active_ind=1
    AND tm.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND tm.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ELSE
   WHERE (tm.tier_group_cd=request->tier_group_cd)
    AND tm.active_ind=1
    AND tm.beg_effective_dt_tm <= cnvtdatetime(request->service_dt_tm)
    AND tm.end_effective_dt_tm >= cnvtdatetime(request->service_dt_tm)
  ENDIF
  INTO "nl"
  tm.tier_row_num, tm.tier_cell_type_cd, tm.tier_cell_value,
  tm.tier_cell_string, tm.tier_cell_value_id, tm.beg_effective_dt_tm,
  tm.end_effective_dt_tm
  FROM tier_matrix tm
  ORDER BY tm.tier_group_cd, tm.tier_row_num, tm.tier_col_num
  DETAIL
   IF (cur_tier != tm.tier_group_cd)
    cur_tier = tm.tier_group_cd, tier_cnt += 1, stat = alterlist(reply->tier_groups,tier_cnt),
    reply->tier_groups[tier_cnt].tier_group_cd = tm.tier_group_cd, cur_row = 0, row_cnt = 0
   ENDIF
   IF (cur_row=0)
    reply->tier_groups[tier_cnt].beg_effective_dt_tm = tm.beg_effective_dt_tm, reply->tier_groups[
    tier_cnt].end_effective_dt_tm = tm.end_effective_dt_tm
   ENDIF
   IF (cur_row != tm.tier_row_num)
    row_cnt += 1, stat = alterlist(reply->tier_groups[tier_cnt].tier_rows,row_cnt), cur_row = tm
    .tier_row_num,
    cur_col = 0, col_cnt = 0
   ENDIF
   IF (cur_col != tm.tier_col_num)
    cur_col = tm.tier_col_num, col_cnt += 1, stat = alterlist(reply->tier_groups[tier_cnt].tier_rows[
     row_cnt].tier_cols,col_cnt),
    reply->tier_groups[tier_cnt].tier_rows[row_cnt].tier_cols[col_cnt].tier_cell_type_cd = tm
    .tier_cell_type_cd, reply->tier_groups[tier_cnt].tier_rows[row_cnt].tier_cols[col_cnt].
    tier_cell_value = tm.tier_cell_value, reply->tier_groups[tier_cnt].tier_rows[row_cnt].tier_cols[
    col_cnt].tier_cell_string = tm.tier_cell_string,
    reply->tier_groups[tier_cnt].tier_rows[row_cnt].tier_cols[col_cnt].tier_cell_value_id = tm
    .tier_cell_value_id
   ENDIF
  WITH nocounter
 ;end select
 IF (row_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
