CREATE PROGRAM dm2_fix_rdds_ddl:dba
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
 FREE RECORD dm_seq_reply
 RECORD dm_seq_reply(
   1 status = c1
   1 msg = vc
 )
 FREE RECORD ddl_holder
 RECORD ddl_holder(
   1 qual[*]
     2 table_name = vc
     2 t_extent = f8
     2 tspace_name = vc
     2 dict_man_ind = i2
     2 qual[*]
       3 index_name = vc
       3 i_extent = f8
       3 index_tspace = vc
       3 dict_man_ind = i2
 )
 DECLARE ddl_table_cnt = i4
 DECLARE ddl_index_cnt = i4
 DECLARE ddl_table_loop = i4
 DECLARE ddl_index_loop = i4
 DECLARE ddl_error_ind = i2
 DECLARE ddl_error_msg = vc
 DECLARE t_extent_ind = i2
 DECLARE i_extent_ind = i2
 SET ddl_index_cnt = 0
 SET ddl_table_cnt = 0
 SET ddl_error_ind = error(ddl_error_msg,1)
 SET ddl_error_ind = 0
 EXECUTE dm_add_sequence "DM_MERGE_AUDIT_SEQ", 1, 10000,
 1, 0
 IF ((dm_seq_reply->status="F"))
  SET readme_data->status = dm_seq_reply->status
  GO TO exit_script
 ENDIF
 IF (currdb="ORACLE")
  SELECT INTO "NL:"
   FROM user_tables t
   WHERE t.table_name IN ("DM_CHG_LOG", "DM_CHG_LOG_EXCEPTION", "DM_CHG_LOG_AUDIT",
   "DM_MERGE_TRANSLATE")
   ORDER BY t.table_name
   DETAIL
    ddl_table_cnt = (ddl_table_cnt+ 1), stat = alterlist(ddl_holder->qual,ddl_table_cnt), ddl_holder
    ->qual[ddl_table_cnt].table_name = t.table_name,
    ddl_holder->qual[ddl_table_cnt].t_extent = t.next_extent, ddl_holder->qual[ddl_table_cnt].
    tspace_name = t.tablespace_name
   WITH nocounter
  ;end select
  IF (error(ddl_error_msg,0) > 0)
   SET ddl_error_ind = 1
   SET readme_data->message = ddl_error_msg
   SET readme_data->status = "F"
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ddl_table_cnt),
    user_tablespaces u
   PLAN (d)
    JOIN (u
    WHERE (u.tablespace_name=ddl_holder->qual[d.seq].tspace_name))
   DETAIL
    IF (u.extent_management="DICTIONARY")
     ddl_holder->qual[d.seq].dict_man_ind = 1
    ELSE
     ddl_holder->qual[d.seq].dict_man_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  IF (error(ddl_error_msg,0) > 0)
   SET ddl_error_ind = 1
   SET readme_data->message = ddl_error_msg
   SET readme_data->status = "F"
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ddl_table_cnt),
    user_indexes i
   PLAN (d)
    JOIN (i
    WHERE (i.table_name=ddl_holder->qual[d.seq].table_name))
   ORDER BY i.table_name
   HEAD i.table_name
    ddl_index_cnt = 0
   DETAIL
    ddl_index_cnt = (ddl_index_cnt+ 1), stat = alterlist(ddl_holder->qual[d.seq].qual,ddl_index_cnt),
    ddl_holder->qual[d.seq].qual[ddl_index_cnt].index_name = i.index_name,
    ddl_holder->qual[d.seq].qual[ddl_index_cnt].i_extent = i.next_extent, ddl_holder->qual[d.seq].
    qual[ddl_index_cnt].index_tspace = i.tablespace_name
   WITH nocounter
  ;end select
  IF (error(ddl_error_msg,0) > 0)
   SET ddl_error_ind = 1
   SET readme_data->message = ddl_error_msg
   SET readme_data->status = "F"
   GO TO exit_script
  ENDIF
  FOR (ddl_table_loop = 1 TO ddl_table_cnt)
    SET ddl_index_cnt = size(ddl_holder->qual[ddl_table_loop].qual,5)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = ddl_index_cnt),
      user_tablespaces u
     PLAN (d)
      JOIN (u
      WHERE (u.tablespace_name=ddl_holder->qual[ddl_table_loop].qual[d.seq].index_tspace))
     DETAIL
      IF (u.extent_management="DICTIONARY")
       ddl_holder->qual[ddl_table_loop].qual[d.seq].dict_man_ind = 1
      ELSE
       ddl_holder->qual[ddl_table_loop].qual[d.seq].dict_man_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (error(ddl_error_msg,0) > 0)
     SET ddl_error_ind = 1
     SET readme_data->message = ddl_error_msg
     SET readme_data->status = "F"
    ENDIF
  ENDFOR
  IF (ddl_error_ind=1)
   GO TO exit_script
  ENDIF
  FOR (ddl_table_loop = 1 TO ddl_table_cnt)
   IF ((ddl_holder->qual[ddl_table_loop].dict_man_ind=1))
    IF ((ddl_holder->qual[ddl_table_loop].t_extent < (128 * 1024.0)))
     CALL parser(concat("rdb alter table ",ddl_holder->qual[ddl_table_loop].table_name,
       " storage (next 128k) go"),1)
     IF (error(ddl_error_msg,0) > 0)
      SET ddl_table_loop = ddl_table_cnt
      SET ddl_error_ind = 1
      SET readme_data->message = ddl_error_msg
      SET readme_data->status = "F"
     ENDIF
    ENDIF
   ENDIF
   FOR (ddl_index_loop = 1 TO size(ddl_holder->qual[ddl_table_loop].qual,5))
     IF ((ddl_holder->qual[ddl_table_loop].qual[ddl_index_loop].dict_man_ind=1))
      IF ((ddl_holder->qual[ddl_table_loop].qual[ddl_index_loop].i_extent < (128 * 1024.0)))
       CALL parser(concat("rdb alter index ",ddl_holder->qual[ddl_table_loop].qual[ddl_index_loop].
         index_name," storage (next 128k) go"),1)
       IF (error(ddl_error_msg,0) > 0)
        SET ddl_index_loop = size(ddl_holder->qual[ddl_table_loop].qual,5)
        SET ddl_table_loop = ddl_table_cnt
        SET ddl_error_ind = 1
        SET readme_data->message = ddl_error_msg
        SET readme_data->status = "F"
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  ENDFOR
  IF (ddl_error_ind=1)
   GO TO exit_script
  ENDIF
  SET t_extent_ind = 0
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ddl_table_cnt),
    user_tables t
   PLAN (d
    WHERE (ddl_holder->qual[d.seq].dict_man_ind=1))
    JOIN (t
    WHERE (t.table_name=ddl_holder->qual[d.seq].table_name))
   DETAIL
    IF ((t.next_extent < (128 * 1024.0)))
     t_extent_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (error(ddl_error_msg,0) > 0)
   SET ddl_error_ind = 1
   SET readme_data->message = ddl_error_msg
   SET readme_data->status = "F"
   GO TO exit_script
  ENDIF
  IF (t_extent_ind=1)
   SET ddl_error_ind = 1
   SET readme_data->message = "One of the ALTER TABLE commands failed."
   SET readme_data->status = "F"
   GO TO exit_script
  ELSE
   FOR (ddl_table_loop = 1 TO ddl_table_cnt)
     SET i_extent_ind = 0
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = value(size(ddl_holder->qual[ddl_table_loop].qual,5))),
       user_indexes i
      PLAN (d
       WHERE (ddl_holder->qual[ddl_table_loop].qual[d.seq].dict_man_ind=1))
       JOIN (i
       WHERE (i.index_name=ddl_holder->qual[ddl_table_loop].qual[d.seq].index_name))
      DETAIL
       IF ((i.next_extent < (128 * 1024.0)))
        i_extent_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (error(ddl_error_msg,0) > 0)
      SET ddl_error_ind = 1
      SET readme_data->message = ddl_error_msg
      SET readme_data->status = "F"
      SET ddl_table_loop = ddl_table_cnt
     ENDIF
     IF (i_extent_ind=1)
      SET ddl_table_loop = ddl_table_cnt
      SET ddl_error_ind = 1
      SET readme_data->message = "One of the ALTER INDEX commands failed."
      SET readme_data->status = "F"
     ENDIF
   ENDFOR
   IF (ddl_error_ind=1)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (ddl_error_ind=0
  AND i_extent_ind=0
  AND t_extent_ind=0)
  SET readme_data->status = "S"
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  SET readme_data->message = "All requested DDL has been completed."
 ENDIF
 EXECUTE dm_readme_status
END GO
