CREATE PROGRAM dm_calc_bpr_null:dba
 SET dm_schema_date = cnvtdatetime("01-AUG-1998")
 SET dm_schema_date = cnvtdatetime( $1)
 SET calc_bpr_mode = 0
 SET commit_mode = 0
 SET std_dev_factor = 1
 FREE SET table_list
 RECORD table_list(
   1 table_count = i4
   1 table_name[*]
     2 tname = c32
     2 tcur_bpr = f8
     2 tschema_max_bpr = f8
     2 tmin_bpr = f8
     2 tmax_bpr = f8
     2 tmean_bpr = f8
     2 tstd_dev = f8
     2 tnew_bpr = f8
     2 tclient_cnt = i4
     2 tclient[*]
       3 tbpr = f8
 )
 SET table_list->table_count = 0
 FREE SET table_list1
 RECORD table_list1(
   1 index_count = i4
   1 index_name[*]
     2 iname = c32
     2 cur_bpr = f8
     2 schema_max_bpr = f8
     2 min_bpr = f8
     2 max_bpr = f8
     2 mean_bpr = f8
     2 std_dev = f8
     2 new_bpr = f8
     2 client_cnt = i4
     2 client[*]
       3 bpr = f8
 )
 SET table_list1->index_count = 0
 SET partition_size = 0.0
 SET kount = 0
 SET temp_sum = 0.0
 SET icnt = 0
 SET kount = 0
 SELECT INTO "nl:"
  dtd.table_name, dtd.bytes_per_row
  FROM dm_tables_doc dtd,
   dm_tables dt
  WHERE dt.schema_date=cnvtdatetime(dm_schema_date)
   AND dtd.table_name=dt.table_name
   AND dtd.bytes_per_row=null
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,10)=1)
    stat = alterlist(table_list->table_name,(kount+ 9))
   ENDIF
   table_list->table_name[kount].tname = dtd.table_name, table_list->table_name[kount].tcur_bpr = dtd
   .bytes_per_row, table_list->table_name[kount].tclient_cnt = 0
  WITH nocounter
 ;end select
 SET table_list->table_count = kount
 IF (curqual=0)
  CALL echo("Zero tables found in dm_tables_doc.")
  GO TO end_program
 ENDIF
 CALL echo(concat(trim(cnvtstring(kount))," tables found in dm_tables_doc."))
 CALL echo(concat("CALCULATE SCHEMA MAX BPR FOR TABLES IN THE SCHEMA DATE."))
 SELECT INTO "nl:"
  d.seq, dep.column_name, dep.data_type,
  dep.data_length, dep.table_name
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   dm_columns dep
  PLAN (d)
   JOIN (dep
   WHERE (dep.table_name=table_list->table_name[d.seq].tname)
    AND dep.schema_date=cnvtdatetime(dm_schema_date))
  ORDER BY dep.table_name
  HEAD dep.table_name
   i_bytes_per_row = 0
  DETAIL
   IF (((dep.data_type="LONG") OR (dep.data_type="LONG_RAW")) )
    i_bytes_per_row = (i_bytes_per_row+ 8000)
   ELSE
    i_bytes_per_row = (i_bytes_per_row+ dep.data_length)
   ENDIF
  FOOT  dep.table_name
   table_list->table_name[d.seq].tschema_max_bpr = i_bytes_per_row
  WITH nocounter
 ;end select
 CALL echo(concat("DONE."))
 CALL echo(concat("GET INDEXES IN THE SCHEMA DATE FROM DM_INDEXES_DOC."))
 SET kount = 0
 SET icnt = 0
 SELECT INTO "nl:"
  di.index_name, di.schema_date, did.bytes_per_row
  FROM dm_indexes_doc did,
   dm_indexes di
  WHERE di.schema_date=cnvtdatetime(dm_schema_date)
   AND did.index_name=di.index_name
   AND did.bytes_per_row=null
  ORDER BY di.index_name
  DETAIL
   icnt = (icnt+ 1)
   IF (mod(icnt,10)=1)
    stat = alterlist(table_list1->index_name,(icnt+ 9))
   ENDIF
   table_list1->index_name[icnt].iname = di.index_name, table_list1->index_name[icnt].cur_bpr = did
   .bytes_per_row, table_list1->index_name[icnt].client_cnt = 0
  WITH nocounter
 ;end select
 SET table_list1->index_count = icnt
 IF (curqual=0)
  CALL echo("No indices found for schema date.")
  GO TO end_program
 ENDIF
 CALL echo(concat(trim(cnvtstring(icnt))," indices found for schema date."))
 CALL echo(concat("DONE."))
 CALL echo(concat("CALCULATE SCHEMA MAXIMUM BPR FOR EACH INDEX IN THE SCHEMA DATE."))
 SELECT INTO "nl:"
  dic.index_name, dep.column_name, dep.data_type,
  dep.data_length
  FROM dm_columns dep,
   dm_index_columns dic,
   (dummyt d  WITH seq = value(table_list1->index_count))
  PLAN (d)
   JOIN (dic
   WHERE (dic.index_name=table_list1->index_name[d.seq].iname)
    AND dic.schema_date=cnvtdatetime(dm_schema_date))
   JOIN (dep
   WHERE dep.table_name=dic.table_name
    AND dep.column_name=dic.column_name
    AND dep.schema_date=cnvtdatetime(dm_schema_date))
  ORDER BY dic.index_name
  HEAD dic.index_name
   i_bytes_per_row = 0
  DETAIL
   IF (((dep.data_type="LONG") OR (dep.data_type="LONG_RAW")) )
    i_bytes_per_row = (i_bytes_per_row+ 8000)
   ELSE
    i_bytes_per_row = (i_bytes_per_row+ dep.data_length)
   ENDIF
  FOOT  dic.index_name
   table_list1->index_name[d.seq].schema_max_bpr = i_bytes_per_row
  WITH nocounter
 ;end select
 CALL echo(concat("DONE."))
 CALL echo(concat("GET THE TABLE AND INDEX DATA FROM THE CLIENT SITE(S)."))
 SELECT DISTINCT INTO "nl:"
  so.report_seq, so.instance_cd, so.owner,
  so.segment_type, so.segment_name, so.total_space,
  so.free_space, so.row_count
  FROM space_objects@admin1 so
  WHERE so.report_seq IN (2465, 2485, 2505)
   AND so.owner="V500"
   AND ((so.segment_type="TABLE") OR (so.segment_type="INDEX"))
  ORDER BY so.segment_type, so.segment_name, so.report_seq
  DETAIL
   IF (so.segment_type="TABLE")
    FOR (tblcnt = 1 TO table_list->table_count)
      IF ((so.segment_name=table_list->table_name[tblcnt].tname))
       IF (so.row_count > 50
        AND ((so.total_space > so.free_space) OR (so.total_space=so.free_space))
        AND ((((so.total_space - so.free_space) * 8192)/ so.row_count) <= table_list->table_name[
       tblcnt].tschema_max_bpr))
        table_list->table_name[tblcnt].tclient_cnt = (table_list->table_name[tblcnt].tclient_cnt+ 1)
        IF (mod(table_list->table_name[tblcnt].tclient_cnt,10)=1)
         stat = alterlist(table_list->table_name[tblcnt].tclient,(kount+ 9))
        ENDIF
        table_list->table_name[tblcnt].tclient[table_list->table_name[tblcnt].tclient_cnt].tbpr = (((
        so.total_space - so.free_space) * 8192)/ so.row_count)
       ENDIF
       tblcnt = table_list->table_count
      ENDIF
    ENDFOR
   ENDIF
   IF (so.segment_type="INDEX")
    IF ((table_list1->index_count > 0))
     FOR (idxcnt = 1 TO table_list1->index_count)
       IF ((so.segment_name=table_list1->index_name[idxcnt].iname))
        IF (so.row_count > 50
         AND ((so.total_space > so.free_space) OR (so.total_space=so.free_space))
         AND ((((so.total_space - so.free_space) * 8192)/ so.row_count) <= table_list1->index_name[
        idxcnt].schema_max_bpr))
         table_list1->index_name[idxcnt].client_cnt = (table_list1->index_name[idxcnt].client_cnt+ 1)
         IF (mod(table_list1->index_name[idxcnt].client_cnt,10)=1)
          stat = alterlist(table_list1->index_name[idxcnt].client,(kount+ 9))
         ENDIF
         table_list1->index_name[idxcnt].client[table_list1->index_name[idxcnt].client_cnt].bpr = (((
         so.total_space - so.free_space) * 8192)/ so.row_count)
        ENDIF
        idxcnt = table_list1->index_count
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(concat("DONE."))
 CALL echo(concat("CALCULATE THE MIN, MEAN, STD_DEV BYTES PER ROW FOR THE DATA & INDEXES."))
 FOR (tblcnt = 1 TO table_list->table_count)
   IF ((table_list->table_name[tblcnt].tclient_cnt > 0))
    FREE SET list
    RECORD list(
      1 n[*]
        2 value = f8
      1 n_count = i4
      1 sum_values = f8
      1 mean_value = f8
      1 min_value = f8
      1 sum_sqr_mean_diff = f8
      1 std_dev = f8
    )
    SET list->n_count = 0
    SET list->sum_values = 0.0
    SET list->mean_value = 0.0
    SET list->min_value = 0.0
    SET list->sum_sqr_mean_diff = 0.0
    SET list->std_dev = 0.0
    FOR (ctblcnt = 1 TO table_list->table_name[tblcnt].tclient_cnt)
      IF ((table_list->table_name[tblcnt].tclient[ctblcnt].tbpr > 0))
       SET list->n_count = (list->n_count+ 1)
       IF (mod(list->n_count,10)=1)
        SET stat = alterlist(list->n,10)
       ENDIF
       SET list->n[list->n_count].value = table_list->table_name[tblcnt].tclient[ctblcnt].tbpr
      ENDIF
    ENDFOR
    FOR (i = 1 TO list->n_count)
      SET list->sum_values = (list->sum_values+ list->n[i].value)
    ENDFOR
    SET list->mean_value = (list->sum_values/ list->n_count)
    FOR (i = 1 TO list->n_count)
      SET list->sum_sqr_mean_diff = (list->sum_sqr_mean_diff+ ((list->mean_value - list->n[i].value)
      ** 2))
    ENDFOR
    SET list->std_dev = ((list->sum_sqr_mean_diff/ list->n_count)** 0.5)
    SELECT INTO "nl:"
     *
     FROM (dummyt d  WITH seq = value(list->n_count))
     PLAN (d)
     DETAIL
      x = 0
     FOOT REPORT
      table_list->table_name[tblcnt].tmin_bpr = min(list->n[d.seq].value), table_list->table_name[
      tblcnt].tmax_bpr = max(list->n[d.seq].value)
     WITH nocounter
    ;end select
    SET table_list->table_name[tblcnt].tmean_bpr = list->mean_value
    SET table_list->table_name[tblcnt].tstd_dev = list->std_dev
   ENDIF
 ENDFOR
 CALL echo(concat("DONE WITH TABLES."))
 IF ((table_list1->index_count > 0))
  FOR (idxcnt = 1 TO table_list1->index_count)
    IF ((table_list1->index_name[idxcnt].client_cnt > 0))
     FREE SET list
     RECORD list(
       1 n[*]
         2 value = f8
       1 n_count = i4
       1 sum_values = f8
       1 mean_value = f8
       1 min_value = f8
       1 sum_sqr_mean_diff = f8
       1 std_dev = f8
     )
     SET list->n_count = 0
     SET list->sum_values = 0.0
     SET list->mean_value = 0.0
     SET list->min_value = 0.0
     SET list->sum_sqr_mean_diff = 0.0
     SET list->std_dev = 0.0
     FOR (ctblcnt = 1 TO table_list1->index_name[idxcnt].client_cnt)
       IF ((table_list1->index_name[idxcnt].client[ctblcnt].bpr > 0))
        SET list->n_count = (list->n_count+ 1)
        IF (mod(list->n_count,10)=1)
         SET stat = alterlist(list->n,10)
        ENDIF
        SET list->n[list->n_count].value = table_list1->index_name[idxcnt].client[ctblcnt].bpr
       ENDIF
     ENDFOR
     FOR (i = 1 TO list->n_count)
       SET list->sum_values = (list->sum_values+ list->n[i].value)
     ENDFOR
     SET list->mean_value = (list->sum_values/ list->n_count)
     FOR (i = 1 TO list->n_count)
       SET list->sum_sqr_mean_diff = (list->sum_sqr_mean_diff+ ((list->mean_value - list->n[i].value)
       ** 2))
     ENDFOR
     SET list->std_dev = ((list->sum_sqr_mean_diff/ list->n_count)** 0.5)
     SELECT INTO "nl:"
      *
      FROM (dummyt d  WITH seq = value(list->n_count))
      PLAN (d)
      DETAIL
       x = 0
      FOOT REPORT
       table_list1->index_name[idxcnt].min_bpr = min(list->n[d.seq].value), table_list1->index_name[
       idxcnt].max_bpr = max(list->n[d.seq].value)
      WITH nocounter
     ;end select
     SET table_list1->index_name[idxcnt].mean_bpr = list->mean_value
     SET table_list1->index_name[idxcnt].std_dev = list->std_dev
    ENDIF
  ENDFOR
 ENDIF
 FREE DEFINE list
 CALL echo(concat("DONE WITH INDEXES."))
 CALL echo(concat("UPDATE DM_TABLES_DOC BYTES PER ROW."))
 SET best_bpr = 0.0
 SET default_bpr_mode = 0
 FOR (tblcnt = 1 TO table_list->table_count)
   SET best_bpr = 0.0
   IF (calc_bpr_mode=1)
    IF ((table_list->table_name[tblcnt].tmean_bpr > 0))
     SET best_bpr = (table_list->table_name[tblcnt].tmean_bpr+ (std_dev_factor * table_list->
     table_name[tblcnt].tstd_dev))
    ENDIF
    IF (((best_bpr < 10) OR ((best_bpr > table_list->table_name[tblcnt].tschema_max_bpr)
     AND (table_list->table_name[tblcnt].tschema_max_bpr > 0))) )
     SET default_bpr_mode = 1
    ELSE
     SET default_bpr_mode = 0
    ENDIF
   ENDIF
   IF (((calc_bpr_mode=0) OR (default_bpr_mode=1)) )
    SET best_bpr = table_list->table_name[tblcnt].tcur_bpr
    IF ((((table_list->table_name[tblcnt].tmax_bpr > best_bpr)) OR ((best_bpr >= table_list->
    table_name[tblcnt].tschema_max_bpr)))
     AND (table_list->table_name[tblcnt].tmax_bpr < table_list->table_name[tblcnt].tschema_max_bpr))
     SET best_bpr = table_list->table_name[tblcnt].tmax_bpr
    ENDIF
    IF (((best_bpr < 10) OR ((best_bpr > table_list->table_name[tblcnt].tschema_max_bpr)
     AND (table_list->table_name[tblcnt].tschema_max_bpr > 0))) )
     SET best_bpr = table_list->table_name[tblcnt].tschema_max_bpr
    ENDIF
   ENDIF
   SET table_list->table_name[tblcnt].tnew_bpr = best_bpr
   IF (best_bpr > 0)
    UPDATE  FROM dm_tables_doc td
     SET td.bytes_per_row = best_bpr, td.bpr_mean = table_list->table_name[tblcnt].tmean_bpr, td
      .bpr_min = table_list->table_name[tblcnt].tmin_bpr,
      td.bpr_max = table_list->table_name[tblcnt].tschema_max_bpr, td.bpr_std_dev = table_list->
      table_name[tblcnt].tstd_dev
     WHERE (td.table_name=table_list->table_name[tblcnt].tname)
     WITH nocounter
    ;end update
    IF (commit_mode=1)
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
 CALL echo(concat("DONE."))
 CALL echo(concat("UPDATE DM_INDEXES_DOC BYTES PER ROW."))
 SET best_bpr = 0.0
 SET default_bpr_mode = 0
 IF ((table_list1->index_count > 0))
  FOR (idxcnt = 1 TO table_list1->index_count)
    SET best_bpr = 0.0
    IF (calc_bpr_mode=1)
     IF ((table_list1->index_name[idxcnt].mean_bpr > 0))
      SET best_bpr = (table_list1->index_name[idxcnt].mean_bpr+ (std_dev_factor * table_list1->
      index_name[idxcnt].std_dev))
     ENDIF
     IF (((best_bpr < 10) OR ((best_bpr > table_list1->index_name[idxcnt].schema_max_bpr)
      AND (table_list1->index_name[idxcnt].schema_max_bpr > 0))) )
      SET default_bpr_mode = 1
     ELSE
      SET default_bpr_mode = 0
     ENDIF
    ENDIF
    IF (((calc_bpr_mode=0) OR (default_bpr_mode=1)) )
     SET best_bpr = table_list1->index_name[idxcnt].cur_bpr
     IF ((((table_list1->index_name[idxcnt].max_bpr > best_bpr)) OR ((best_bpr >= table_list1->
     index_name[idxcnt].schema_max_bpr)))
      AND (table_list1->index_name[idxcnt].max_bpr < table_list1->index_name[idxcnt].schema_max_bpr))
      SET best_bpr = table_list1->index_name[idxcnt].max_bpr
     ENDIF
     IF (((best_bpr < 10) OR ((best_bpr > table_list1->index_name[idxcnt].schema_max_bpr)
      AND (table_list1->index_name[idxcnt].schema_max_bpr > 0))) )
      SET best_bpr = table_list1->index_name[idxcnt].schema_max_bpr
     ENDIF
    ENDIF
    SET table_list1->index_name[idxcnt].new_bpr = best_bpr
    IF (best_bpr > 0)
     UPDATE  FROM dm_indexes_doc id
      SET id.bytes_per_row = best_bpr, id.bpr_mean = table_list1->index_name[idxcnt].mean_bpr, id
       .bpr_min = table_list1->index_name[idxcnt].min_bpr,
       id.bpr_max = table_list1->index_name[idxcnt].schema_max_bpr, id.bpr_std_dev = table_list1->
       index_name[idxcnt].std_dev
      WHERE (id.index_name=table_list1->index_name[idxcnt].iname)
      WITH nocounter
     ;end update
    ENDIF
  ENDFOR
  IF (commit_mode=1)
   COMMIT
  ENDIF
 ENDIF
 CALL echo(concat("DONE."))
 CALL echo(concat("Producing BPR report CCLUSERDIR:DM_CALC_BPR.DAT"))
 SELECT
  *
  FROM dual
  DETAIL
   FOR (kount = 1 TO table_list->table_count)
     col 0, "TNAME: ", table_list->table_name[kount].tname,
     " NEW: ", table_list->table_name[kount].tnew_bpr"#####.##", " CUR: ",
     table_list->table_name[kount].tcur_bpr"#####.##", " SCH: ", table_list->table_name[kount].
     tschema_max_bpr"#####.##",
     " MIN: ", table_list->table_name[kount].tmin_bpr"#####.##", " MAX: ",
     table_list->table_name[kount].tmax_bpr"#####.##", " MEAN: ", table_list->table_name[kount].
     tmean_bpr"#####.##",
     " STDDEV: ", table_list->table_name[kount].tstd_dev"#####.##", " NBR: ",
     table_list->table_name[kount].tclient_cnt"###"
     IF ((table_list->table_name[kount].tclient_cnt > 0))
      FOR (s = 1 TO table_list->table_name[kount].tclient_cnt)
       " SAMPLE: ",table_list->table_name[kount].tclient[s].tbpr"#####.##"
      ENDFOR
     ENDIF
     row + 1
   ENDFOR
   FOR (dount = 1 TO table_list1->index_count)
     col 0, "INAME: ", table_list1->index_name[dount].iname,
     " NEW: ", table_list1->index_name[dount].new_bpr"#####.##", " CUR: ",
     table_list1->index_name[dount].cur_bpr"#####.##", " SCH: ", table_list1->index_name[dount].
     schema_max_bpr"#####.##",
     " MIN: ", table_list1->index_name[dount].min_bpr"#####.##", " MAX: ",
     table_list1->index_name[dount].max_bpr"#####.##", " MEAN: ", table_list1->index_name[dount].
     mean_bpr"#####.##",
     " STDDEV: ", table_list1->index_name[dount].std_dev"#####.##", " NBR: ",
     table_list1->index_name[dount].client_cnt"###"
     IF ((table_list1->index_name[dount].client_cnt > 0))
      FOR (s = 1 TO table_list1->index_name[dount].client_cnt)
       " SAMPLE: ",table_list1->index_name[dount].client[s].bpr"#####.##"
      ENDFOR
     ENDIF
     row + 1
   ENDFOR
  WITH nocounter, maxcol = 1000
 ;end select
 CALL echo(concat("DONE."))
 IF (commit_mode=1)
  COMMIT
 ENDIF
#end_program
END GO
