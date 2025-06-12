CREATE PROGRAM dm_fill2:dba
 SET start_dt_tm = cnvtdatetime(curdate,curtime3)
 SET cust_schema_date = cnvtupper( $1)
 SET log_file_name = "dm_fill2.log"
 SET max_dsize = 0
 SET maxcolsize = 132
 SET valid_stat = "F"
 SET header_str = fillstring(80,"*")
 SET df_utc_ind = 1
 IF ((validate(curutc,- (1))=- (1))
  AND (validate(curutc,- (2))=- (2)))
  SET df_utc_ind = 0
 ENDIF
 FREE RECORD vcounts
 RECORD vcounts(
   1 del_dm_tables = i4
   1 del_dm_columns = i4
   1 del_dm_indexes = i4
   1 del_dm_ind_cols = i4
   1 del_dm_constraints = i4
   1 del_dm_cons_cols = i4
   1 ins_dm_ts = i4
   1 ins_dm_tables = i4
   1 ins_dm_columns = i4
   1 ins_dm_indexes = i4
   1 ins_dm_ind_cols = i4
   1 ins_dm_ref_cons = i4
   1 ins_dm_pk_cons = i4
   1 ins_dm_cons_cols = i4
   1 ins_dm_tables_doc = i4
   1 ins_dm_columns_doc = i4
   1 ins_dm_indexes_doc = i4
   1 ins_dm_seq = i4
   1 upd_dm_seq = i4
   1 user_tables = i4
   1 user_columns = i4
   1 user_indexes = i4
   1 user_ind_cols = i4
   1 user_ref_constraints = i4
   1 user_pk_constraints = i4
   1 user_cons_cols = i4
   1 user_seq = i4
 )
 SET errmsg = fillstring(132,"")
 SET errcode = error(errmsg,1)
 FREE RECORD err
 RECORD err(
   1 cnt = i4
   1 qual[*]
     2 errcode = i2
     2 errmsg = vc
     2 section = vc
 )
 DECLARE create_log_file(status,cust_schema_date,sdate) = null
 DECLARE disp_text("Display text ...",cnt) = null
 DECLARE init_values(dummy) = null
 DECLARE get_tablespace(cust_schema_date) = null
 DECLARE clean_dates(cust_schema_date) = null
 DECLARE get_tabs_cols(cust_schema_date) = null
 DECLARE get_indxs_cols(cust_schema_date) = null
 DECLARE get_cons(cust_schema_date) = null
 DECLARE get_cons_cols(cust_schema_date) = null
 DECLARE get_sequences(cust_schema_date) = null
 DECLARE check_counts(dummy) = null
 DECLARE store_errors(section,errcode,errmsg) = null
 DECLARE write_errors(dummy) = null
 DECLARE def_err_rec(rec_cnt) = null
 CALL create_log_file(0,cust_schema_date,start_dt_tm)
 CALL disp_text("Initialize values ...",- (1))
 CALL init_values(1)
 CALL disp_text("Save the tablespace information ...",- (1))
 CALL get_tablespace(cust_schema_date)
 CALL disp_text("Cleanup previous schema dates ...",- (1))
 CALL clean_dates(cust_schema_date)
 CALL disp_text("Save the tables & columns information ...",- (1))
 CALL get_tabs_cols(cust_schema_date)
 CALL disp_text("Save the indexes & columns information ...",- (1))
 CALL get_indxs_cols(cust_schema_date)
 CALL disp_text("Save the constraints information ...",- (1))
 CALL get_cons(cust_schema_date)
 CALL disp_text("Save the constraints-columns information ...",- (1))
 CALL get_cons_cols(cust_schema_date)
 CALL disp_text("Save the sequences information ...",- (1))
 CALL get_sequences(cust_schema_date)
 CALL disp_text("Check all the counts ...",- (1))
 CALL check_counts(1)
 GO TO end_program
 SUBROUTINE create_log_file(status,cust_schema_date,start_dt_tm)
   IF (status=0)
    SELECT INTO value(log_file_name)
     FROM dual
     HEAD REPORT
      sdate = format(start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
     DETAIL
      row 0, header_str, row + 1,
      "Start Date & Time: ", sdate, " with custom date: ",
      cust_schema_date, row + 1, header_str
     WITH nocounter, maxcol = value(maxcolsize)
    ;end select
   ELSE
    SET end_dt_tm = cnvtdatetime(curdate,curtime3)
    SET ttime = datetimediff(end_dt_tm,start_dt_tm,4)
    SELECT INTO value(log_file_name)
     FROM dual
     HEAD REPORT
      edate = format(end_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
     DETAIL
      row + 1, header_str, row + 1,
      "End Date & Time  : ", edate, " with custom date: ",
      cust_schema_date, row + 2, "Total Time       : ",
      ttime"#####.##;r", " (Minutes)", row + 1,
      header_str
     WITH nocounter, maxcol = value(maxcolsize), append
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE disp_text(disp_field,count)
   IF ((count=- (1)))
    CALL echo(build(header_str))
    CALL echo(disp_field)
    CALL echo(build(header_str))
    SELECT INTO value(log_file_name)
     FROM dual
     DETAIL
      disp_field, row + 1
     WITH nocounter, maxcol = value(maxcolsize), append
    ;end select
   ELSE
    SELECT INTO value(log_file_name)
     FROM dual
     DETAIL
      "... ", disp_field, col 60,
      ":", col 62, count"#######;l",
      row + 1
     WITH nocounter, maxcol = value(maxcolsize), append
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE store_errors(section,errcode,errmsg)
   IF (errcode != 0)
    SET err->cnt = (err->cnt+ 1)
    SET stat = alterlist(err->qual,err->cnt)
    SET err->qual[err->cnt].section = section
    SET err->qual[err->cnt].errcode = errcode
    SET err->qual[err->cnt].errmsg = errmsg
    CALL check_counts(1)
   ENDIF
   SET errmsg = fillstring(132,"")
   SET errcode = error(errmsg,1)
 END ;Subroutine
 SUBROUTINE write_errors(dummy)
  SET max_str_size = 110
  SELECT INTO value(log_file_name)
   FROM dual
   DETAIL
    IF ((err->cnt > 0))
     FOR (ytz = 1 TO err->cnt)
       str_len = 0, start_pos = 1, msg_hold = fillstring(value(max_str_size),""),
       str_len = textlen(err->qual[ytz].errmsg), ytz"####;r", ". ",
       "Sect: ", err->qual[ytz].section, row + 1
       IF (str_len <= max_str_size)
        "      Err : ", err->qual[ytz].errmsg, row + 1
       ELSE
        msg_hold = substring(1,max_str_size,err->qual[ytz].errmsg), "      Err : ", msg_hold,
        row + 1, str_len = (str_len - max_str_size)
        WHILE (str_len > 0)
          msg_hold = fillstring(value(max_str_size),""), start_pos = (start_pos+ max_str_size),
          msg_hold = substring(start_pos,max_str_size,err->qual[ytz].errmsg),
          "          : ", msg_hold, row + 1,
          str_len = (str_len - max_str_size)
        ENDWHILE
       ENDIF
     ENDFOR
    ELSE
     "... No Errors Encountered", row + 1
    ENDIF
   WITH nocounter, maxcol = value(maxcolsize), append
  ;end select
 END ;Subroutine
 SUBROUTINE def_err_rec(rec_cnt)
   FREE RECORD err1
   RECORD err1(
     1 cnt = i4
     1 qual[*]
       2 status = i2
       2 errnum = i4
       2 errmsg = vc
   ) WITH persistscript
   SET err1->cnt = value(rec_cnt)
   SET stat = alterlist(err1->qual,err1->cnt)
 END ;Subroutine
 SUBROUTINE init_values(dummy)
   SET vcounts->del_dm_tables = 0
   SET vcounts->del_dm_columns = 0
   SET vcounts->del_dm_indexes = 0
   SET vcounts->del_dm_ind_cols = 0
   SET vcounts->del_dm_constraints = 0
   SET vcounts->del_dm_cons_cols = 0
   SET vcounts->ins_dm_ts = 0
   SET vcounts->ins_dm_tables = 0
   SET vcounts->ins_dm_columns = 0
   SET vcounts->ins_dm_indexes = 0
   SET vcounts->ins_dm_ind_cols = 0
   SET vcounts->ins_dm_ref_cons = 0
   SET vcounts->ins_dm_pk_cons = 0
   SET vcounts->ins_dm_cons_cols = 0
   SET vcounts->ins_dm_tables_doc = 0
   SET vcounts->ins_dm_columns_doc = 0
   SET vcounts->ins_dm_indexes_doc = 0
   SET vcounts->ins_dm_seq = 0
   SET vcounts->upd_dm_seq = 0
   SET vcounts->user_tables = 0
   SET vcounts->user_columns = 0
   SET vcounts->user_indexes = 0
   SET vcounts->user_ind_cols = 0
   SET vcounts->user_ref_constraints = 0
   SET vcounts->user_pk_constraints = 0
   SET vcounts->user_cons_cols = 0
   SET vcounts->user_seq = 0
   SET err->cnt = 0
   SET stat = alterlist(err->qual,err->cnt)
 END ;Subroutine
 SUBROUTINE get_tablespace(cust_schema_date)
   INSERT  FROM dm_tablespace d
    (d.tablespace_name, d.initial_extent, d.next_extent,
    d.pctincrease, d.updt_applctx, d.updt_dt_tm,
    d.updt_cnt, d.updt_id, d.updt_task)(SELECT
     i.tablespace_name, i.initial_extent, i.next_extent,
     i.pct_increase, 0, cnvtdatetime(curdate,curtime3),
     0, 0, 0
     FROM dba_tablespaces i
     WHERE  NOT ( EXISTS (
     (SELECT
      d1.tablespace_name
      FROM dm_tablespace d1
      WHERE d1.tablespace_name=i.tablespace_name))))
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   COMMIT
   SET vcounts->ins_dm_ts = curqual
   CALL disp_text("Nbr of Tablespace rows added",vcounts->ins_dm_ts)
   CALL store_errors("Save the tablespace information",errcode,errmsg)
 END ;Subroutine
 SUBROUTINE clean_dates(cust_schema_date)
   IF (df_utc_ind)
    DELETE  FROM dm_cons_columns
     WHERE schema_date=cnvtdatetimeutc(cust_schema_date)
    ;end delete
   ELSE
    DELETE  FROM dm_cons_columns
     WHERE schema_date=cnvtdatetime(cust_schema_date)
    ;end delete
   ENDIF
   SET errcode = error(errmsg,0)
   COMMIT
   SET vcounts->del_dm_cons_cols = curqual
   CALL disp_text("Nbr of Constraint-Column rows deleted",vcounts->del_dm_cons_cols)
   CALL store_errors("Delete the constraint-columns information",errcode,errmsg)
   IF (df_utc_ind)
    DELETE  FROM dm_constraints
     WHERE schema_date=cnvtdatetimeutc(cust_schema_date)
    ;end delete
   ELSE
    DELETE  FROM dm_constraints
     WHERE schema_date=cnvtdatetime(cust_schema_date)
    ;end delete
   ENDIF
   SET errcode = error(errmsg,0)
   COMMIT
   SET vcounts->del_dm_constraints = curqual
   CALL disp_text("Nbr of Constraint rows deleted",vcounts->del_dm_constraints)
   CALL store_errors("Delete the constraints information",errcode,errmsg)
   IF (df_utc_ind)
    DELETE  FROM dm_index_columns
     WHERE schema_date=cnvtdatetimeutc(cust_schema_date)
    ;end delete
   ELSE
    DELETE  FROM dm_index_columns
     WHERE schema_date=cnvtdatetime(cust_schema_date)
    ;end delete
   ENDIF
   SET errcode = error(errmsg,0)
   COMMIT
   SET vcounts->del_dm_ind_cols = curqual
   CALL disp_text("Nbr of Index-Column rows deleted",vcounts->del_dm_ind_cols)
   CALL store_errors("Delete the index-columns information",errcode,errmsg)
   IF (df_utc_ind)
    DELETE  FROM dm_indexes
     WHERE schema_date=cnvtdatetimeutc(cust_schema_date)
    ;end delete
   ELSE
    DELETE  FROM dm_indexes
     WHERE schema_date=cnvtdatetime(cust_schema_date)
    ;end delete
   ENDIF
   SET errcode = error(errmsg,0)
   COMMIT
   SET vcounts->del_dm_indexes = curqual
   CALL disp_text("Nbr of Index rows deleted",vcounts->del_dm_indexes)
   CALL store_errors("Delete the indexes information",errcode,errmsg)
   IF (df_utc_ind)
    DELETE  FROM dm_columns
     WHERE schema_date=cnvtdatetimeutc(cust_schema_date)
    ;end delete
   ELSE
    DELETE  FROM dm_columns
     WHERE schema_date=cnvtdatetime(cust_schema_date)
    ;end delete
   ENDIF
   SET errcode = error(errmsg,0)
   COMMIT
   SET vcounts->del_dm_columns = curqual
   CALL disp_text("Nbr of Table-Column rows deleted",vcounts->del_dm_columns)
   CALL store_errors("Delete the table-columns information",errcode,errmsg)
   IF (df_utc_ind)
    DELETE  FROM dm_tables
     WHERE schema_date=cnvtdatetimeutc(cust_schema_date)
    ;end delete
   ELSE
    DELETE  FROM dm_tables
     WHERE schema_date=cnvtdatetime(cust_schema_date)
    ;end delete
   ENDIF
   SET errcode = error(errmsg,0)
   COMMIT
   SET vcounts->del_dm_tables = curqual
   CALL disp_text("Nbr of Table rows deleted",vcounts->del_dm_tables)
   CALL store_errors("Delete the tables information",errcode,errmsg)
 END ;Subroutine
 SUBROUTINE get_tabs_cols(cust_schema_date)
   FREE RECORD dm_tables
   RECORD dm_tables(
     1 tbl_cnt = i4
     1 qual[*]
       2 exist = i2
       2 tbl_name = vc
       2 ts_name = vc
       2 pct_free = f8
       2 pct_used = f8
       2 pct_increase = f8
       2 initial_extent = f8
       2 next_extent = f8
       2 col_cnt = i4
       2 col_qual[*]
         3 exist = i2
         3 col_name = vc
         3 data_type = vc
         3 data_length = f8
         3 data_precision = f8
         3 data_scale = f8
         3 data_default = vc
         3 nullable = vc
         3 column_id = f8
   )
   FREE RECORD dm_nncols
   RECORD dm_nncols(
     1 tbl_cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
   )
   SELECT INTO "nl:"
    ut.*, utc.*
    FROM user_tab_columns utc,
     user_tables ut
    WHERE findstring("$",ut.table_name)=0
     AND  NOT (ut.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*"))
     AND ut.table_name=utc.table_name
    ORDER BY ut.table_name, utc.column_id
    HEAD REPORT
     tbl_cnt = 0, stat = alterlist(dm_tables->qual,tbl_cnt)
    HEAD ut.table_name
     tbl_cnt = (tbl_cnt+ 1), stat = alterlist(dm_tables->qual,tbl_cnt), dm_tables->qual[tbl_cnt].
     exist = 0,
     dm_tables->qual[tbl_cnt].tbl_name = ut.table_name, dm_tables->qual[tbl_cnt].ts_name = ut
     .tablespace_name, dm_tables->qual[tbl_cnt].pct_free = ut.pct_free,
     dm_tables->qual[tbl_cnt].pct_used = ut.pct_used, dm_tables->qual[tbl_cnt].pct_increase = ut
     .pct_increase, dm_tables->qual[tbl_cnt].initial_extent = ut.initial_extent,
     dm_tables->qual[tbl_cnt].next_extent = ut.next_extent, col_cnt = 0
    DETAIL
     col_cnt = (col_cnt+ 1), stat = alterlist(dm_tables->qual[tbl_cnt].col_qual,col_cnt), dm_tables->
     qual[tbl_cnt].col_qual[col_cnt].exist = 0,
     dm_tables->qual[tbl_cnt].col_qual[col_cnt].col_name = utc.column_name, dm_tables->qual[tbl_cnt].
     col_qual[col_cnt].data_type = utc.data_type, dm_tables->qual[tbl_cnt].col_qual[col_cnt].
     data_length = utc.data_length,
     dm_tables->qual[tbl_cnt].col_qual[col_cnt].data_precision = utc.data_precision, dm_tables->qual[
     tbl_cnt].col_qual[col_cnt].data_scale = utc.data_scale, dm_tables->qual[tbl_cnt].col_qual[
     col_cnt].data_default = trim(substring(1,255,utc.data_default)),
     dm_tables->qual[tbl_cnt].col_qual[col_cnt].nullable = utc.nullable, dm_tables->qual[tbl_cnt].
     col_qual[col_cnt].column_id = utc.column_id
    FOOT  ut.table_name
     dm_tables->qual[tbl_cnt].col_cnt = col_cnt, vcounts->user_columns = (vcounts->user_columns+
     col_cnt)
    FOOT REPORT
     dm_tables->tbl_cnt = tbl_cnt, vcounts->user_tables = tbl_cnt
    WITH nocounter
   ;end select
   CALL disp_text("Nbr of User Table rows captured",vcounts->user_tables)
   CALL disp_text("Nbr of User Table-Column rows captured",vcounts->user_columns)
   CALL def_err_rec(dm_tables->tbl_cnt)
   SELECT INTO "nl:"
    FROM user_views
    WHERE view_name="DM2_USER_NOTNULL_COLS"
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL disp_text("Update NOT NULL columns using DM2_USER_NOTNULL_COLS view.",- (1))
    SELECT INTO "nl:"
     FROM dm2_user_notnull_cols d
     HEAD REPORT
      nn_cnt = 0, stat = alterlist(dm_nncols->qual,1000)
     DETAIL
      nn_cnt = (nn_cnt+ 1)
      IF (mod(nn_cnt,1000)=1
       AND nn_cnt != 1)
       stat = alterlist(dm_nncols->qual,(nn_cnt+ 999))
      ENDIF
      dm_nncols->qual[nn_cnt].table_name = trim(d.table_name), dm_nncols->qual[nn_cnt].column_name =
      trim(d.column_name)
     FOOT REPORT
      stat = alterlist(dm_nncols->qual,nn_cnt), dm_nncols->tbl_cnt = nn_cnt
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt t  WITH seq = value(dm_nncols->tbl_cnt))
     HEAD REPORT
      nn_tbl = 0, nn_col = 0
     DETAIL
      nn_tbl = 0, nn_col = 0, nn_tbl = locateval(nn_tbl,1,dm_tables->tbl_cnt,dm_nncols->qual[t.seq].
       table_name,dm_tables->qual[nn_tbl].tbl_name)
      IF (nn_tbl > 0)
       nn_col = locateval(nn_col,1,dm_tables->qual[nn_tbl].col_cnt,dm_nncols->qual[t.seq].column_name,
        dm_tables->qual[nn_tbl].col_qual[nn_col].col_name)
       IF (nn_col > 0)
        IF ((dm_tables->qual[nn_tbl].col_qual[nn_col].nullable="Y"))
         dm_tables->qual[nn_tbl].col_qual[nn_col].nullable = "N"
        ENDIF
       ENDIF
      ENDIF
     FOOT REPORT
      row + 0
     WITH nocounter
    ;end select
   ENDIF
   IF (df_utc_ind)
    INSERT  FROM dm_tables dt,
      (dummyt d  WITH seq = value(dm_tables->tbl_cnt))
     SET dt.seq = 1, dt.table_name = dm_tables->qual[d.seq].tbl_name, dt.schema_date =
      cnvtdatetimeutc(cust_schema_date),
      dt.tablespace_name = dm_tables->qual[d.seq].ts_name, dt.pct_free = dm_tables->qual[d.seq].
      pct_free, dt.pct_used = dm_tables->qual[d.seq].pct_used,
      dt.pct_increase = dm_tables->qual[d.seq].pct_increase, dt.updt_applctx = 0, dt.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      dt.updt_cnt = 0, dt.updt_id = 0, dt.updt_task = 0
     PLAN (d)
      JOIN (dt)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_tables dt,
      (dummyt d  WITH seq = value(dm_tables->tbl_cnt))
     SET dt.seq = 1, dt.table_name = dm_tables->qual[d.seq].tbl_name, dt.schema_date = cnvtdatetime(
       cust_schema_date),
      dt.tablespace_name = dm_tables->qual[d.seq].ts_name, dt.pct_free = dm_tables->qual[d.seq].
      pct_free, dt.pct_used = dm_tables->qual[d.seq].pct_used,
      dt.pct_increase = dm_tables->qual[d.seq].pct_increase, dt.updt_applctx = 0, dt.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      dt.updt_cnt = 0, dt.updt_id = 0, dt.updt_task = 0
     PLAN (d)
      JOIN (dt)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ENDIF
   COMMIT
   SET vcounts->ins_dm_tables = curqual
   CALL disp_text("Nbr of Table rows added",vcounts->ins_dm_tables)
   FOR (tyz = 1 TO value(dm_tables->tbl_cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the tables information",err1->qual[tyz].errnum,trim(err1->qual[tyz].
        errmsg))
     ENDIF
   ENDFOR
   CALL def_err_rec(dm_tables->tbl_cnt)
   IF (df_utc_ind)
    INSERT  FROM dm_columns dc,
      (dummyt d1  WITH seq = value(dm_tables->tbl_cnt)),
      (dummyt d2  WITH seq = value(max_dsize))
     SET dc.seq = 1, dc.table_name = dm_tables->qual[d1.seq].tbl_name, dc.column_name = dm_tables->
      qual[d1.seq].col_qual[d2.seq].col_name,
      dc.schema_date = cnvtdatetimeutc(cust_schema_date), dc.data_type = dm_tables->qual[d1.seq].
      col_qual[d2.seq].data_type, dc.data_length = dm_tables->qual[d1.seq].col_qual[d2.seq].
      data_length,
      dc.data_precision = dm_tables->qual[d1.seq].col_qual[d2.seq].data_precision, dc.data_scale =
      dm_tables->qual[d1.seq].col_qual[d2.seq].data_scale, dc.data_default = dm_tables->qual[d1.seq].
      col_qual[d2.seq].data_default,
      dc.nullable = dm_tables->qual[d1.seq].col_qual[d2.seq].nullable, dc.column_seq = dm_tables->
      qual[d1.seq].col_qual[d2.seq].column_id, dc.updt_applctx = 0,
      dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_cnt = 0, dc.updt_id = 0,
      dc.updt_task = 0
     PLAN (d1
      WHERE maxrec(d2,dm_tables->qual[d1.seq].col_cnt) > 0)
      JOIN (d2)
      JOIN (dc)
     WITH status(err1->qual[d1.seq].status,err1->qual[d1.seq].errnum,err1->qual[d1.seq].errmsg),
     nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_columns dc,
      (dummyt d1  WITH seq = value(dm_tables->tbl_cnt)),
      (dummyt d2  WITH seq = value(max_dsize))
     SET dc.seq = 1, dc.table_name = dm_tables->qual[d1.seq].tbl_name, dc.column_name = dm_tables->
      qual[d1.seq].col_qual[d2.seq].col_name,
      dc.schema_date = cnvtdatetime(cust_schema_date), dc.data_type = dm_tables->qual[d1.seq].
      col_qual[d2.seq].data_type, dc.data_length = dm_tables->qual[d1.seq].col_qual[d2.seq].
      data_length,
      dc.data_precision = dm_tables->qual[d1.seq].col_qual[d2.seq].data_precision, dc.data_scale =
      dm_tables->qual[d1.seq].col_qual[d2.seq].data_scale, dc.data_default = dm_tables->qual[d1.seq].
      col_qual[d2.seq].data_default,
      dc.nullable = dm_tables->qual[d1.seq].col_qual[d2.seq].nullable, dc.column_seq = dm_tables->
      qual[d1.seq].col_qual[d2.seq].column_id, dc.updt_applctx = 0,
      dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_cnt = 0, dc.updt_id = 0,
      dc.updt_task = 0
     PLAN (d1
      WHERE maxrec(d2,dm_tables->qual[d1.seq].col_cnt) > 0)
      JOIN (d2)
      JOIN (dc)
     WITH status(err1->qual[d1.seq].status,err1->qual[d1.seq].errnum,err1->qual[d1.seq].errmsg),
     nocounter
    ;end insert
   ENDIF
   COMMIT
   SET vcounts->ins_dm_columns = curqual
   CALL disp_text("Nbr of Table-Column rows added",vcounts->ins_dm_columns)
   FOR (tyz = 1 TO value(dm_tables->tbl_cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the table-columns information",err1->qual[tyz].errnum,trim(err1->qual[
        tyz].errmsg))
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_indxs_cols(cust_schema_date)
   FREE RECORD dm_indexes
   RECORD dm_indexes(
     1 indx_cnt = i4
     1 c_cnt = i4
     1 qual[*]
       2 exist = i2
       2 indx_name = vc
       2 c_ind = i2
       2 tbl_name = vc
       2 ts_name = vc
       2 pct_free = f8
       2 pct_increase = f8
       2 unique_ind = i2
       2 col_cnt = i4
       2 col_qual[*]
         3 col_name = vc
         3 col_position = i4
   )
   SET ind_qual1 = 0
   SET ind_qual2 = 0
   SELECT INTO "nl:"
    ui.*, uic.*
    FROM user_ind_columns uic,
     user_indexes ui
    WHERE findstring("$",ui.table_name)=0
     AND ui.index_name != "TMP*"
     AND ui.table_name=uic.table_name
     AND  NOT (ui.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*"))
     AND ui.index_name=uic.index_name
    ORDER BY ui.index_name, uic.column_position
    HEAD REPORT
     indx_cnt = 0, stat = alterlist(dm_indexes->qual,indx_cnt), dm_indexes->c_cnt = 0
    HEAD ui.index_name
     indx_cnt = (indx_cnt+ 1), stat = alterlist(dm_indexes->qual,indx_cnt), dm_indexes->qual[indx_cnt
     ].exist = 0,
     dm_indexes->qual[indx_cnt].indx_name = ui.index_name
     IF (findstring("$C",ui.index_name))
      dm_indexes->qual[indx_cnt].c_ind = 1, dm_indexes->c_cnt = (dm_indexes->c_cnt+ 1)
     ELSE
      dm_indexes->qual[indx_cnt].c_ind = 0
     ENDIF
     dm_indexes->qual[indx_cnt].tbl_name = ui.table_name, dm_indexes->qual[indx_cnt].ts_name = ui
     .tablespace_name, dm_indexes->qual[indx_cnt].pct_free = ui.pct_free,
     dm_indexes->qual[indx_cnt].pct_increase = ui.pct_increase
     IF (ui.uniqueness="UNIQUE")
      dm_indexes->qual[indx_cnt].unique_ind = 1
     ELSE
      dm_indexes->qual[indx_cnt].unique_ind = 0
     ENDIF
     col_cnt = 0
    DETAIL
     col_cnt = (col_cnt+ 1), stat = alterlist(dm_indexes->qual[indx_cnt].col_qual,col_cnt),
     dm_indexes->qual[indx_cnt].col_qual[col_cnt].col_name = uic.column_name,
     dm_indexes->qual[indx_cnt].col_qual[col_cnt].col_position = uic.column_position
    FOOT  ui.index_name
     dm_indexes->qual[indx_cnt].col_cnt = col_cnt, vcounts->user_ind_cols = (vcounts->user_ind_cols+
     col_cnt)
    FOOT REPORT
     dm_indexes->indx_cnt = indx_cnt, vcounts->user_indexes = indx_cnt
    WITH nocounter
   ;end select
   CALL disp_text("Nbr of User Index rows captured",vcounts->user_indexes)
   CALL disp_text("Nbr of User Index-Column rows captured",vcounts->user_ind_cols)
   CALL def_err_rec(dm_indexes->indx_cnt)
   IF ((dm_indexes->c_cnt > 0))
    SELECT INTO "nl:"
     dm_indexes->qual[d.seq].indx_name, r.original_name
     FROM (dummyt d  WITH seq = value(dm_indexes->indx_cnt)),
      renamed_objects r
     PLAN (d
      WHERE (dm_indexes->qual[d.seq].c_ind=1))
      JOIN (r
      WHERE r.owner="V500"
       AND r.object_type="INDEX"
       AND (r.new_name=dm_indexes->qual[d.seq].indx_name))
     HEAD REPORT
      row + 0
     DETAIL
      dm_indexes->qual[d.seq].indx_name = r.original_name
     FOOT REPORT
      ind_qual1 = count(r.original_name)
     WITH nocounter
    ;end select
    IF ((ind_qual1 < dm_indexes->c_cnt))
     SELECT INTO "nl:"
      dm_indexes->qual[d.seq].indx_name
      FROM (dummyt d  WITH seq = value(dm_indexes->indx_cnt))
      WHERE (dm_indexes->qual[d.seq].c_ind=1)
       AND findstring("$C",dm_indexes->qual[d.seq].indx_name) > 0
      HEAD REPORT
       c_pos = 0
      DETAIL
       c_pos = findstring("$C",dm_indexes->qual[d.seq].indx_name), dm_indexes->qual[d.seq].indx_name
        = substring(1,(c_pos - 1),dm_indexes->qual[d.seq].indx_name)
      FOOT REPORT
       ind_qual2 = count(dm_indexes->qual[d.seq].indx_name)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (df_utc_ind)
    INSERT  FROM dm_indexes di,
      (dummyt d  WITH seq = value(dm_indexes->indx_cnt))
     SET di.seq = 1, di.index_name = dm_indexes->qual[d.seq].indx_name, di.schema_date =
      cnvtdatetimeutc(cust_schema_date),
      di.table_name = dm_indexes->qual[d.seq].tbl_name, di.tablespace_name = dm_indexes->qual[d.seq].
      ts_name, di.pct_increase = dm_indexes->qual[d.seq].pct_increase,
      di.pct_free = dm_indexes->qual[d.seq].pct_free, di.unique_ind = dm_indexes->qual[d.seq].
      unique_ind, di.updt_applctx = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0, di.updt_id = 0,
      di.updt_task = 0
     PLAN (d)
      JOIN (di)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_indexes di,
      (dummyt d  WITH seq = value(dm_indexes->indx_cnt))
     SET di.seq = 1, di.index_name = dm_indexes->qual[d.seq].indx_name, di.schema_date = cnvtdatetime
      (cust_schema_date),
      di.table_name = dm_indexes->qual[d.seq].tbl_name, di.tablespace_name = dm_indexes->qual[d.seq].
      ts_name, di.pct_increase = dm_indexes->qual[d.seq].pct_increase,
      di.pct_free = dm_indexes->qual[d.seq].pct_free, di.unique_ind = dm_indexes->qual[d.seq].
      unique_ind, di.updt_applctx = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0, di.updt_id = 0,
      di.updt_task = 0
     PLAN (d)
      JOIN (di)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ENDIF
   COMMIT
   SET vcounts->ins_dm_indexes = curqual
   CALL disp_text("Nbr of Index rows added",vcounts->ins_dm_indexes)
   FOR (tyz = 1 TO value(dm_indexes->indx_cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the indexes information",err1->qual[tyz].errnum,trim(err1->qual[tyz].
        errmsg))
     ENDIF
   ENDFOR
   CALL def_err_rec(dm_indexes->indx_cnt)
   IF (df_utc_ind)
    INSERT  FROM dm_index_columns dic,
      (dummyt d1  WITH seq = value(dm_indexes->indx_cnt)),
      (dummyt d2  WITH seq = value(max_dsize))
     SET dic.seq = 1, dic.index_name = dm_indexes->qual[d1.seq].indx_name, dic.schema_date =
      cnvtdatetimeutc(cust_schema_date),
      dic.table_name = dm_indexes->qual[d1.seq].tbl_name, dic.column_name = dm_indexes->qual[d1.seq].
      col_qual[d2.seq].col_name, dic.column_position = dm_indexes->qual[d1.seq].col_qual[d2.seq].
      col_position,
      dic.updt_applctx = 0, dic.updt_dt_tm = cnvtdatetime(curdate,curtime3), dic.updt_cnt = 0,
      dic.updt_id = 0, dic.updt_task = 0
     PLAN (d1
      WHERE maxrec(d2,dm_indexes->qual[d1.seq].col_cnt) > 0)
      JOIN (d2)
      JOIN (dic)
     WITH status(err1->qual[d1.seq].status,err1->qual[d1.seq].errnum,err1->qual[d1.seq].errmsg),
     nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_index_columns dic,
      (dummyt d1  WITH seq = value(dm_indexes->indx_cnt)),
      (dummyt d2  WITH seq = value(max_dsize))
     SET dic.seq = 1, dic.index_name = dm_indexes->qual[d1.seq].indx_name, dic.schema_date =
      cnvtdatetime(cust_schema_date),
      dic.table_name = dm_indexes->qual[d1.seq].tbl_name, dic.column_name = dm_indexes->qual[d1.seq].
      col_qual[d2.seq].col_name, dic.column_position = dm_indexes->qual[d1.seq].col_qual[d2.seq].
      col_position,
      dic.updt_applctx = 0, dic.updt_dt_tm = cnvtdatetime(curdate,curtime3), dic.updt_cnt = 0,
      dic.updt_id = 0, dic.updt_task = 0
     PLAN (d1
      WHERE maxrec(d2,dm_indexes->qual[d1.seq].col_cnt) > 0)
      JOIN (d2)
      JOIN (dic)
     WITH status(err1->qual[d1.seq].status,err1->qual[d1.seq].errnum,err1->qual[d1.seq].errmsg),
     nocounter
    ;end insert
   ENDIF
   COMMIT
   SET vcounts->ins_dm_ind_cols = curqual
   CALL disp_text("Nbr of Index-Column rows added",vcounts->ins_dm_ind_cols)
   FOR (tyz = 1 TO value(dm_indexes->indx_cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the index-columns information",err1->qual[tyz].errnum,trim(err1->qual[
        tyz].errmsg))
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_cons(cust_schema_date)
   FREE RECORD dm_cons
   RECORD dm_cons(
     1 cnt = i4
     1 c_cnt = i4
     1 r_c_cnt = i4
     1 qual[*]
       2 child_tbl_name = vc
       2 parent_tbl_name = vc
       2 cons_name = vc
       2 c_ind = i2
       2 r_cons_name = vc
       2 r_c_ind = i2
       2 cons_type = vc
       2 status_ind = i2
       2 parent_table_columns = vc
   )
   SET cons_qual1 = 0
   SET cons_qual2 = 0
   SET rcons_qual1 = 0
   SET rcons_qual2 = 0
   SELECT INTO "nl:"
    child_table = uc2.table_name, constraint_name = uc2.constraint_name, parent_table = uc1
    .table_name,
    status_ind = uc2.status, r_constraint_name = uc1.constraint_name
    FROM user_constraints uc1,
     user_constraints uc2
    WHERE uc2.constraint_type="R"
     AND  NOT (uc2.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*"))
     AND findstring("$",uc2.table_name)=0
     AND uc2.r_constraint_name=uc1.constraint_name
     AND uc2.owner=uc1.owner
     AND findstring("$",uc1.table_name)=0
    ORDER BY uc2.table_name, uc2.constraint_name
    HEAD REPORT
     c_cnt = 0, stat = alterlist(dm_cons->qual,c_cnt), dm_cons->c_cnt = 0,
     dm_cons->r_c_cnt = 0
    DETAIL
     c_cnt = (c_cnt+ 1), stat = alterlist(dm_cons->qual,c_cnt), dm_cons->qual[c_cnt].child_tbl_name
      = child_table,
     dm_cons->qual[c_cnt].parent_tbl_name = parent_table, dm_cons->qual[c_cnt].cons_name =
     constraint_name
     IF (findstring("$C",constraint_name))
      dm_cons->qual[c_cnt].c_ind = 1, dm_cons->c_cnt = (dm_cons->c_cnt+ 1)
     ELSE
      dm_cons->qual[c_cnt].c_ind = 0
     ENDIF
     dm_cons->qual[c_cnt].r_cons_name = r_constraint_name
     IF (findstring("$C",r_constraint_name))
      dm_cons->qual[c_cnt].r_c_ind = 1, dm_cons->r_c_cnt = (dm_cons->r_c_cnt+ 1)
     ELSE
      dm_cons->qual[c_cnt].r_c_ind = 0
     ENDIF
     dm_cons->qual[c_cnt].cons_type = "R"
     IF (uc2.status="DISABLED")
      dm_cons->qual[c_cnt].status_ind = 0
     ELSE
      dm_cons->qual[c_cnt].status_ind = 1
     ENDIF
    FOOT REPORT
     dm_cons->cnt = c_cnt, vcounts->user_ref_constraints = c_cnt
    WITH nocounter
   ;end select
   CALL disp_text("Storing referential constraints ...",- (1))
   CALL disp_text("Nbr of User Referential Constraint rows captured",vcounts->user_ref_constraints)
   SELECT INTO "nl:"
    ucc.column_name, ucc.position
    FROM user_cons_columns ucc,
     (dummyt d  WITH seq = value(dm_cons->cnt))
    PLAN (d)
     JOIN (ucc
     WHERE (ucc.table_name=dm_cons->qual[d.seq].parent_tbl_name)
      AND (ucc.constraint_name=dm_cons->qual[d.seq].r_cons_name)
      AND ucc.owner=currdbuser)
    ORDER BY ucc.position
    DETAIL
     IF (ucc.position > 1)
      dm_cons->qual[d.seq].parent_table_columns = concat(dm_cons->qual[d.seq].parent_table_columns,
       ",")
     ENDIF
     dm_cons->qual[d.seq].parent_table_columns = concat(dm_cons->qual[d.seq].parent_table_columns,ucc
      .column_name)
    WITH nocounter
   ;end select
   CALL def_err_rec(dm_cons->cnt)
   IF ((dm_cons->c_cnt > 0))
    SELECT INTO "nl:"
     dm_cons->qual[d.seq].cons_name
     FROM (dummyt d  WITH seq = value(dm_cons->cnt)),
      renamed_objects r
     PLAN (d
      WHERE (dm_cons->qual[d.seq].c_ind=1))
      JOIN (r
      WHERE r.owner="V500"
       AND r.object_type="CONSTRAINT"
       AND (r.new_name=dm_cons->qual[d.seq].cons_name))
     HEAD REPORT
      row + 0
     DETAIL
      dm_cons->qual[d.seq].cons_name = r.original_name
     FOOT REPORT
      cons_qual1 = count(r.original_name)
     WITH nocounter
    ;end select
    IF ((cons_qual1 < dm_cons->c_cnt))
     SELECT INTO "nl:"
      dm_cons->qual[d.seq].cons_name
      FROM (dummyt d  WITH seq = value(dm_cons->cnt))
      PLAN (d
       WHERE (dm_cons->qual[d.seq].c_ind=1)
        AND findstring("$C",dm_cons->qual[d.seq].cons_name) > 0)
      HEAD REPORT
       c_pos = 0
      DETAIL
       c_pos = findstring("$C",dm_cons->qual[d.seq].cons_name), dm_cons->qual[d.seq].cons_name =
       substring(1,(c_pos - 1),dm_cons->qual[d.seq].cons_name)
      FOOT REPORT
       cons_qual2 = count(dm_cons->qual[d.seq].cons_name)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((dm_cons->r_c_cnt > 0))
    SELECT INTO "nl:"
     dm_cons->qual[d.seq].r_cons_name
     FROM (dummyt d  WITH seq = value(dm_cons->cnt)),
      renamed_objects r
     PLAN (d
      WHERE (dm_cons->qual[d.seq].r_c_ind=1))
      JOIN (r
      WHERE r.owner="V500"
       AND r.object_type="CONSTRAINT"
       AND (r.new_name=dm_cons->qual[d.seq].r_cons_name))
     HEAD REPORT
      row + 0
     DETAIL
      dm_cons->qual[d.seq].r_cons_name = r.original_name
     FOOT REPORT
      rcons_qual1 = count(r.original_name)
     WITH nocounter
    ;end select
    IF ((rcons_qual1 < dm_cons->r_c_cnt))
     SELECT INTO "nl:"
      dm_cons->qual[d.seq].r_cons_name
      FROM (dummyt d  WITH seq = value(dm_cons->cnt))
      PLAN (d
       WHERE (dm_cons->qual[d.seq].c_ind=1)
        AND findstring("$C",dm_cons->qual[d.seq].r_cons_name) > 0)
      HEAD REPORT
       c_pos = 0
      DETAIL
       c_pos = findstring("$C",dm_cons->qual[d.seq].r_cons_name), dm_cons->qual[d.seq].r_cons_name =
       substring(1,(c_pos - 1),dm_cons->qual[d.seq].r_cons_name)
      FOOT REPORT
       rcons_qual2 = count(dm_cons->qual[d.seq].r_cons_name)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (df_utc_ind)
    INSERT  FROM dm_constraints dc,
      (dummyt d  WITH seq = value(dm_cons->cnt))
     SET dc.seq = 1, dc.table_name = dm_cons->qual[d.seq].child_tbl_name, dc.schema_date =
      cnvtdatetimeutc(cust_schema_date),
      dc.constraint_name = dm_cons->qual[d.seq].cons_name, dc.parent_table_name = dm_cons->qual[d.seq
      ].parent_tbl_name, dc.constraint_type = dm_cons->qual[d.seq].cons_type,
      dc.status_ind = dm_cons->qual[d.seq].status_ind, dc.r_constraint_name = dm_cons->qual[d.seq].
      r_cons_name, dc.parent_table_columns = dm_cons->qual[d.seq].parent_table_columns,
      dc.updt_applctx = 0, dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_cnt = 0,
      dc.updt_id = 0, dc.updt_task = 0
     PLAN (d)
      JOIN (dc)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_constraints dc,
      (dummyt d  WITH seq = value(dm_cons->cnt))
     SET dc.seq = 1, dc.table_name = dm_cons->qual[d.seq].child_tbl_name, dc.schema_date =
      cnvtdatetime(cust_schema_date),
      dc.constraint_name = dm_cons->qual[d.seq].cons_name, dc.parent_table_name = dm_cons->qual[d.seq
      ].parent_tbl_name, dc.constraint_type = dm_cons->qual[d.seq].cons_type,
      dc.status_ind = dm_cons->qual[d.seq].status_ind, dc.r_constraint_name = dm_cons->qual[d.seq].
      r_cons_name, dc.parent_table_columns = dm_cons->qual[d.seq].parent_table_columns,
      dc.updt_applctx = 0, dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_cnt = 0,
      dc.updt_id = 0, dc.updt_task = 0
     PLAN (d)
      JOIN (dc)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ENDIF
   COMMIT
   SET vcounts->ins_dm_ref_cons = curqual
   CALL disp_text("Nbr of Referential Constraint rows added",vcounts->ins_dm_ref_cons)
   FOR (tyz = 1 TO value(dm_cons->cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the referential constraints information",err1->qual[tyz].errnum,trim(
        err1->qual[tyz].errmsg))
     ENDIF
   ENDFOR
   CALL disp_text("Storing primary/unique constraints ...",- (1))
   FREE RECORD dm_pcons
   RECORD dm_pcons(
     1 cnt = i4
     1 c_cnt = i4
     1 qual[*]
       2 tbl_name = vc
       2 cons_name = vc
       2 c_ind = i2
       2 cons_type = vc
       2 status_ind = i2
   )
   SET pcons_qual1 = 0
   SET pcons_qual2 = 0
   SELECT INTO "nl:"
    uc.table_name, uc.constraint_name, uc.constraint_type,
    uc.status
    FROM user_constraints uc
    WHERE uc.constraint_type IN ("P", "U")
     AND findstring("$",uc.table_name)=0
     AND  NOT (uc.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*"))
    ORDER BY uc.table_name, uc.constraint_name
    HEAD REPORT
     p_cnt = 0, stat = alterlist(dm_pcons->qual,p_cnt), dm_pcons->c_cnt = 0
    DETAIL
     p_cnt = (p_cnt+ 1), stat = alterlist(dm_pcons->qual,p_cnt), dm_pcons->qual[p_cnt].tbl_name = uc
     .table_name,
     dm_pcons->qual[p_cnt].cons_name = uc.constraint_name
     IF (findstring("$C",uc.constraint_name))
      dm_pcons->qual[p_cnt].c_ind = 1, dm_pcons->c_cnt = (dm_pcons->c_cnt+ 1)
     ELSE
      dm_pcons->qual[p_cnt].c_ind = 0
     ENDIF
     dm_pcons->qual[p_cnt].cons_type = uc.constraint_type
     IF (uc.status="DISABLED")
      dm_pcons->qual[p_cnt].status_ind = 0
     ELSE
      dm_pcons->qual[p_cnt].status_ind = 1
     ENDIF
    FOOT REPORT
     dm_pcons->cnt = p_cnt, vcounts->user_pk_constraints = p_cnt
    WITH nocounter
   ;end select
   CALL disp_text("Nbr of User Primary/Unique Constraint rows captured",vcounts->user_pk_constraints)
   CALL def_err_rec(dm_pcons->cnt)
   IF ((dm_pcons->c_cnt > 0))
    SELECT INTO "nl:"
     dm_pcons->qual[d.seq].cons_name
     FROM (dummyt d  WITH seq = value(dm_pcons->cnt)),
      renamed_objects r
     PLAN (d
      WHERE (dm_pcons->qual[d.seq].c_ind=1))
      JOIN (r
      WHERE r.owner="V500"
       AND r.object_type="CONSTRAINT"
       AND (r.new_name=dm_pcons->qual[d.seq].cons_name))
     HEAD REPORT
      row + 0
     DETAIL
      dm_pcons->qual[d.seq].cons_name = r.original_name
     FOOT REPORT
      pcons_qual1 = count(r.original_name)
     WITH nocounter
    ;end select
    IF ((pcons_qual1 < dm_pcons->c_cnt))
     SELECT INTO "nl:"
      dm_pcons->qual[d.seq].cons_name
      FROM (dummyt d  WITH seq = value(dm_pcons->cnt))
      PLAN (d
       WHERE (dm_pcons->qual[d.seq].c_ind=1)
        AND findstring("$C",dm_pcons->qual[d.seq].cons_name) > 0)
      HEAD REPORT
       c_pos = 0
      DETAIL
       c_pos = findstring("$C",dm_pcons->qual[d.seq].cons_name), dm_pcons->qual[d.seq].cons_name =
       substring(1,(c_pos - 1),dm_pcons->qual[d.seq].cons_name)
      FOOT REPORT
       pcons_qual2 = count(dm_pcons->qual[d.seq].cons_name)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (df_utc_ind)
    INSERT  FROM dm_constraints dc,
      (dummyt d  WITH seq = value(dm_pcons->cnt))
     SET dc.table_name = dm_pcons->qual[d.seq].tbl_name, dc.schema_date = cnvtdatetimeutc(
       cust_schema_date), dc.constraint_name = dm_pcons->qual[d.seq].cons_name,
      dc.parent_table_name = null, dc.constraint_type = dm_pcons->qual[d.seq].cons_type, dc
      .status_ind = dm_pcons->qual[d.seq].status_ind,
      dc.updt_applctx = 0, dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_cnt = 0,
      dc.updt_id = 0, dc.updt_task = 0
     PLAN (d)
      JOIN (dc)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_constraints dc,
      (dummyt d  WITH seq = value(dm_pcons->cnt))
     SET dc.table_name = dm_pcons->qual[d.seq].tbl_name, dc.schema_date = cnvtdatetime(
       cust_schema_date), dc.constraint_name = dm_pcons->qual[d.seq].cons_name,
      dc.parent_table_name = null, dc.constraint_type = dm_pcons->qual[d.seq].cons_type, dc
      .status_ind = dm_pcons->qual[d.seq].status_ind,
      dc.updt_applctx = 0, dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_cnt = 0,
      dc.updt_id = 0, dc.updt_task = 0
     PLAN (d)
      JOIN (dc)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ENDIF
   COMMIT
   SET vcounts->ins_dm_pk_cons = curqual
   CALL disp_text("Nbr of Primary/Unique Constraint rows added",vcounts->ins_dm_pk_cons)
   FOR (tyz = 1 TO value(dm_pcons->cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the primary/unique constraints information",err1->qual[tyz].errnum,trim
       (err1->qual[tyz].errmsg))
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_cons_cols(cust_schema_date)
   FREE RECORD dm_cons_cols
   RECORD dm_cons_cols(
     1 cnt = i4
     1 c_cnt = i4
     1 qual[*]
       2 tbl_name = vc
       2 cons_name = vc
       2 c_ind = i2
       2 col_name = vc
       2 position = i4
   )
   SET ccol_qual1 = 0
   SET ccol_qual2 = 0
   SELECT INTO "nl:"
    uc.table_name, uc.constraint_name, ucc.position,
    ucc.column_name
    FROM user_cons_columns ucc,
     user_constraints uc
    PLAN (uc
     WHERE uc.owner=currdbuser
      AND  NOT (uc.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*"))
      AND findstring("$",uc.table_name)=0
      AND uc.constraint_type IN ("P", "R", "U"))
     JOIN (ucc
     WHERE uc.owner=ucc.owner
      AND uc.table_name=ucc.table_name
      AND uc.constraint_name=ucc.constraint_name)
    HEAD REPORT
     cl_cnt = 0, stat = alterlist(dm_cons_cols->qual,cl_cnt), dm_cons_cols->c_cnt = 0
    DETAIL
     cl_cnt = (cl_cnt+ 1), stat = alterlist(dm_cons_cols->qual,cl_cnt), dm_cons_cols->qual[cl_cnt].
     tbl_name = uc.table_name,
     dm_cons_cols->qual[cl_cnt].cons_name = uc.constraint_name
     IF (findstring("$C",uc.constraint_name))
      dm_cons_cols->qual[cl_cnt].c_ind = 1, dm_cons_cols->c_cnt = (dm_cons_cols->c_cnt+ 1)
     ELSE
      dm_cons_cols->qual[cl_cnt].c_ind = 0
     ENDIF
     dm_cons_cols->qual[cl_cnt].col_name = ucc.column_name, dm_cons_cols->qual[cl_cnt].position = ucc
     .position
    FOOT REPORT
     dm_cons_cols->cnt = cl_cnt, vcounts->user_cons_cols = cl_cnt
    WITH nocounter
   ;end select
   CALL disp_text("Nbr of User Constraint-Column rows captured",vcounts->user_cons_cols)
   CALL def_err_rec(dm_cons_cols->cnt)
   IF ((dm_cons_cols->c_cnt > 0))
    SELECT INTO "nl:"
     dm_cons_cols->qual[d.seq].cons_name
     FROM (dummyt d  WITH seq = value(dm_cons_cols->cnt)),
      renamed_objects r
     PLAN (d
      WHERE (dm_cons_cols->qual[d.seq].c_ind=1))
      JOIN (r
      WHERE r.owner="V500"
       AND r.object_type="CONSTRAINT"
       AND (r.new_name=dm_cons_cols->qual[d.seq].cons_name))
     HEAD REPORT
      row + 0
     DETAIL
      dm_cons_cols->qual[d.seq].cons_name = r.original_name
     FOOT REPORT
      ccol_qual1 = count(r.original_name)
     WITH nocounter
    ;end select
    IF ((ccol_qual1 < dm_cons_cols->c_cnt))
     SELECT INTO "nl:"
      dm_cons_cols->qual[d.seq].cons_name
      FROM (dummyt d  WITH seq = value(dm_cons_cols->cnt))
      PLAN (d
       WHERE (dm_cons_cols->qual[d.seq].c_ind=1)
        AND findstring("$C",dm_cons_cols->qual[d.seq].cons_name) > 0)
      HEAD REPORT
       c_pos = 0
      DETAIL
       c_pos = findstring("$C",dm_cons_cols->qual[d.seq].cons_name), dm_cons_cols->qual[d.seq].
       cons_name = substring(1,(c_pos - 1),dm_cons_cols->qual[d.seq].cons_name)
      FOOT REPORT
       ccol_qual2 = count(dm_cons_cols->qual[d.seq].cons_name)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (df_utc_ind)
    INSERT  FROM dm_cons_columns dcc,
      (dummyt d  WITH seq = value(dm_cons_cols->cnt))
     SET dcc.table_name = dm_cons_cols->qual[d.seq].tbl_name, dcc.schema_date = cnvtdatetimeutc(
       cust_schema_date), dcc.constraint_name = dm_cons_cols->qual[d.seq].cons_name,
      dcc.position = dm_cons_cols->qual[d.seq].position, dcc.column_name = dm_cons_cols->qual[d.seq].
      col_name, dcc.updt_applctx = 0,
      dcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcc.updt_cnt = 0, dcc.updt_id = 0,
      dcc.updt_task = 0
     PLAN (d)
      JOIN (dcc)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_cons_columns dcc,
      (dummyt d  WITH seq = value(dm_cons_cols->cnt))
     SET dcc.table_name = dm_cons_cols->qual[d.seq].tbl_name, dcc.schema_date = cnvtdatetime(
       cust_schema_date), dcc.constraint_name = dm_cons_cols->qual[d.seq].cons_name,
      dcc.position = dm_cons_cols->qual[d.seq].position, dcc.column_name = dm_cons_cols->qual[d.seq].
      col_name, dcc.updt_applctx = 0,
      dcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcc.updt_cnt = 0, dcc.updt_id = 0,
      dcc.updt_task = 0
     PLAN (d)
      JOIN (dcc)
     WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
     nocounter
    ;end insert
   ENDIF
   COMMIT
   SET vcounts->ins_dm_cons_cols = curqual
   CALL disp_text("Nbr of Constraint rows added",vcounts->ins_dm_cons_cols)
   FOR (tyz = 1 TO value(dm_cons_cols->cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the constraints-columns information",err1->qual[tyz].errnum,trim(err1->
        qual[tyz].errmsg))
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_sequences(cust_schema_date)
   FREE RECORD dm_seq
   RECORD dm_seq(
     1 seq_cnt = i4
     1 qual[*]
       2 exist = i2
       2 seq_name = vc
       2 min_value = f8
       2 max_value = f8
       2 increment_by = f8
       2 cycle_flag = vc
       2 cache_size = f8
   )
   SELECT INTO "nl:"
    us.*
    FROM user_sequences us
    ORDER BY us.sequence_name
    HEAD REPORT
     seq_cnt = 0, stat = alterlist(dm_seq->qual,seq_cnt)
    DETAIL
     seq_cnt = (seq_cnt+ 1), stat = alterlist(dm_seq->qual,seq_cnt), dm_seq->qual[seq_cnt].exist = 0,
     dm_seq->qual[seq_cnt].seq_name = us.sequence_name, dm_seq->qual[seq_cnt].min_value = us
     .min_value, dm_seq->qual[seq_cnt].max_value = us.max_value,
     dm_seq->qual[seq_cnt].increment_by = us.increment_by, dm_seq->qual[seq_cnt].cycle_flag = us
     .cycle_flag, dm_seq->qual[seq_cnt].cache_size = us.cache_size
    FOOT REPORT
     dm_seq->seq_cnt = seq_cnt, vcounts->user_seq = seq_cnt
    WITH nocounter
   ;end select
   CALL disp_text("Nbr of User Sequence rows captured",vcounts->user_seq)
   SELECT INTO "nl:"
    FROM dm_sequences ds,
     (dummyt d  WITH seq = value(dm_seq->seq_cnt))
    PLAN (d
     WHERE (dm_seq->qual[d.seq].exist=0))
     JOIN (ds
     WHERE (ds.sequence_name=dm_seq->qual[d.seq].seq_name))
    DETAIL
     dm_seq->qual[d.seq].exist = 1
    WITH nocounter
   ;end select
   CALL def_err_rec(dm_seq->seq_cnt)
   INSERT  FROM dm_sequences ds,
     (dummyt d  WITH seq = value(dm_seq->seq_cnt))
    SET ds.seq = 1, ds.sequence_name = dm_seq->qual[d.seq].seq_name, ds.min_value = dm_seq->qual[d
     .seq].min_value,
     ds.max_value = dm_seq->qual[d.seq].max_value, ds.increment_by = dm_seq->qual[d.seq].increment_by,
     ds.cycle = dm_seq->qual[d.seq].cycle_flag,
     ds.cache = dm_seq->qual[d.seq].cache_size, ds.updt_applctx = 0, ds.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ds.updt_cnt = 0, ds.updt_id = 0, ds.updt_task = 0
    PLAN (d
     WHERE (dm_seq->qual[d.seq].exist=0))
     JOIN (ds)
    WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
    nocounter
   ;end insert
   COMMIT
   SET vcounts->ins_dm_seq = curqual
   CALL disp_text("Nbr of Sequence rows added",vcounts->ins_dm_seq)
   FOR (tyz = 1 TO value(dm_seq->seq_cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the sequences (insert) information",err1->qual[tyz].errnum,trim(err1->
        qual[tyz].errmsg))
     ENDIF
   ENDFOR
   CALL def_err_rec(dm_seq->seq_cnt)
   UPDATE  FROM dm_sequences ds,
     (dummyt d  WITH seq = value(dm_seq->seq_cnt))
    SET ds.seq = 1, ds.sequence_name = dm_seq->qual[d.seq].seq_name, ds.min_value = dm_seq->qual[d
     .seq].min_value,
     ds.max_value = dm_seq->qual[d.seq].max_value, ds.increment_by = dm_seq->qual[d.seq].increment_by,
     ds.cycle = dm_seq->qual[d.seq].cycle_flag,
     ds.cache = dm_seq->qual[d.seq].cache_size, ds.updt_applctx = 0, ds.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ds.updt_cnt = (ds.updt_cnt+ 1), ds.updt_id = 0, ds.updt_task = 0
    PLAN (d
     WHERE (dm_seq->qual[d.seq].exist=1))
     JOIN (ds
     WHERE (ds.sequence_name=dm_seq->qual[d.seq].seq_name))
    WITH status(err1->qual[d.seq].status,err1->qual[d.seq].errnum,err1->qual[d.seq].errmsg),
    nocounter
   ;end update
   COMMIT
   SET vcounts->upd_dm_seq = curqual
   CALL disp_text("Nbr of Sequence rows updated",vcounts->upd_dm_seq)
   FOR (tyz = 1 TO value(dm_seq->seq_cnt))
     IF ((err1->qual[tyz].status=0))
      CALL store_errors("Save the sequences (update) information",err1->qual[tyz].errnum,trim(err1->
        qual[tyz].errmsg))
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE check_counts(dummy)
   CALL disp_text("Generating error report ...",- (1))
   IF ((((vcounts->user_tables != vcounts->ins_dm_tables)) OR ((((vcounts->user_columns != vcounts->
   ins_dm_columns)) OR ((((vcounts->user_indexes != vcounts->ins_dm_indexes)) OR ((((vcounts->
   user_ind_cols != vcounts->ins_dm_ind_cols)) OR ((((vcounts->user_ref_constraints != vcounts->
   ins_dm_ref_cons)) OR ((((vcounts->user_pk_constraints != vcounts->ins_dm_pk_cons)) OR ((((vcounts
   ->user_cons_cols != vcounts->ins_dm_cons_cols)) OR ((err->cnt > 0))) )) )) )) )) )) )) )
    CALL write_errors(1)
    CALL disp_text("Schema capture failed ...",- (1))
    CALL disp_text("Please look in ccluserdir:dm_fill2.log for details ...",- (1))
    GO TO end_program
   ELSE
    CALL write_errors(0)
    CALL disp_text("Schema captured successfully...",- (1))
   ENDIF
   CALL create_log_file(1,cust_schema_date,start_dt_tm)
 END ;Subroutine
#end_program
END GO
