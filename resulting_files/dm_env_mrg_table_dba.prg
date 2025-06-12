CREATE PROGRAM dm_env_mrg_table:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 err_num = i4
     2 err_msg = c255
 )
 SET merge_status_ind = 0
 SET front_sql_stmt = fillstring(132," ")
 SET back_sql_stmt = fillstring(132," ")
 SET parser_buf[4] = fillstring(132," ")
 UPDATE  FROM dm_env_mrg_table_list a
  SET a.insert_rows = 0, a.match_updt_rows = 0, a.match_skip_rows = 0,
   a.error_rows = 0
  WHERE (a.table_name=request->merge_table)
  WITH nocounter
 ;end update
 COMMIT
 IF (curqual=0)
  INSERT  FROM dm_env_mrg_table_list a
   SET a.table_name = request->merge_table, a.process_flg = 0, a.mrg_order = 0,
    a.dup_check_ind = 0, a.mode_flg = 0, a.commit_ind = 0,
    a.insert_rows = 0, a.match_updt_rows = 0, a.match_skip_rows = 0,
    a.error_rows = 0, a.restrict_clause = " ", a.child_tables = " ",
    a.dup_rows = 0, a.invalid_unique_ind = 0
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 UPDATE  FROM dm_env_mrg_control a
  SET a.db_link_name = request->db_link, a.enviro_source = request->enviro_source, a.merge_status_ind
    = 0,
   a.merge_ind = request->merge_ind, a.error_number = null, a.error_message = null,
   a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE a.control_name="MERGE_CONTROL"
  WITH nocounter
 ;end update
 COMMIT
 IF (curqual=0)
  INSERT  FROM dm_env_mrg_control a
   SET a.control_name = "MERGE_CONTROL", a.db_link_name = request->db_link, a.enviro_source = request
    ->enviro_source,
    a.merge_status_ind = 0, a.merge_ind = request->merge_ind, a.error_number = null,
    a.error_message = null, a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 IF (curqual=1)
  SET front_sql_stmt = concat('RDB ASIS(" begin DM_ENV_MRG_TABLE(',"'",trim(request->db_link),"','",
   trim(request->enviro_source),
   "','",trim(request->merge_table),"',",'") ')
  SET back_sql_stmt = concat(' ASIS(",',cnvtstring(request->merge_ind,5,0,r),",",cnvtstring(request->
    merge_mode_ind,5,0,r),",",
   cnvtstring(request->dup_ck_ind,5,0,r),'); end; ")'," GO")
  SET parser_buf[1] = front_sql_stmt
  SET parser_buf[2] = concat("'",substring(1,130,request->restrict_clause),"'")
  SET parser_buf[3] = concat(",'",substring(131,125,request->restrict_clause),"'")
  SET parser_buf[4] = back_sql_stmt
  FOR (cnt = 1 TO 4)
    CALL parser(parser_buf[cnt],1)
  ENDFOR
  SELECT INTO "nl:"
   a.error_number, a.error_message, a.merge_status_ind
   FROM dm_env_mrg_control a
   WHERE a.control_name="MERGE_CONTROL"
   DETAIL
    merge_status_ind = a.merge_status_ind, reply->status_data.err_num = a.error_number, reply->
    status_data.err_msg = a.error_message
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.err_num = 1
   SET reply->status_data.err_msg = "Error Retrieving Merge Control Entry"
  ELSE
   IF (merge_status_ind=2)
    SET reply->status_data.status = "S"
   ELSEIF (merge_status_ind=0)
    SET reply->status_data.status = "N"
   ELSEIF (merge_status_ind=1)
    SET reply->status_data.status = "I"
   ELSEIF (merge_status_ind=3)
    SET reply->status_data.status = "F"
   ENDIF
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.err_num = 1
  SET reply->status_data.err_msg = "Error Updating Merge Control Entry"
 ENDIF
 SET stat = 0
END GO
