CREATE PROGRAM dm_calculate_sizing:dba
 FREE SET table_list
 RECORD table_list(
   1 table_count = i4
   1 total_row_count = f8
   1 list[*]
     2 tname = c32
     2 rowcount = f8
     2 bytes_per_row = f8
     2 table_ref_count = i4
     2 init = f8
     2 next = f8
     2 static_rows = f8
     2 delta_rows = f8
     2 dependency_count = i4
     2 dependency[30]
       3 dependency_resolved = i4
       3 dependency = c32
       3 dependency_flg = f8
       3 dependency_ratio = f8
     2 sum_index = f8
     2 index_count = i4
     2 index_name[*]
       3 iname = c32
       3 bytes_per_row = f8
       3 init = f8
       3 next = f8
 )
 SET table_list->table_count = 0
 FREE SET question_list
 RECORD question_list(
   1 question_count = i4
   1 question[*]
     2 question_number = f8
     2 description = c100
     2 question_type = i4
     2 question_answer = f8
 )
 SET question_list->question_count = 0
 FREE SET tspace_list
 RECORD tspace_list(
   1 tname[*]
     2 tspace_name = c32
     2 raw_bytes = f8
     2 partitioned_bytes = f8
     2 static_ind = i2
   1 tcount = i4
 )
 SET tspace_list->tcount = 0
 SET environment_id =  $1
 SET system = cnvtupper( $2)
 SET partition_size = 0.0
 SET schema_version = 0.0
 SET database_name = fillstring(6," ")
 SET target_size = 0.0
 SET total_static_space = 0.0
 SET static_count = 0.0
 SET target_total_space = 0.0
 SET total_space = 0.0
 SET total_part = 0.0
 SET kount = 0
 SET temp_sum = 0.0
 SET icnt = 0
 SET months = 0.0
 SET sum_static = 0.0
 SET sum_delta = 0.0
 SET first_flag = 0
 SET max_size = 0.0
 SET mbyte = (1024.0 * 1024.0)
 SELECT INTO "nl:"
  de.total_database_size, de.data_file_partition_size, de.schema_version,
  de.database_name
  FROM dm_environment de
  PLAN (de
   WHERE de.environment_id=environment_id)
  DETAIL
   target_size = de.total_database_size, partition_size = de.data_file_partition_size, schema_version
    = de.schema_version,
   database_name = de.database_name, max_size = (de.max_file_size * mbyte), col 0,
   target_size, col + 1, partition_size,
   col + 1, schema_version, col + 1,
   max_size, row + 1
  WITH nocounter, maxcol = 1000
 ;end select
 CALL echo(concat("Total size available ",cnvtstring(target_size)))
 SELECT INTO "nl:"
  dst.tablespace_name, dst.static_size
  FROM dm_static_tablespaces dst,
   dm_env_functions def
  PLAN (def
   WHERE def.environment_id=environment_id)
   JOIN (dst
   WHERE dst.function_id=def.function_id)
  ORDER BY dst.tablespace_name, dst.static_size
  DETAIL
   tspace_list->tcount = (tspace_list->tcount+ 1)
   IF (mod(tspace_list->tcount,10)=1)
    stat = alterlist(tspace_list->tname,(tspace_list->tcount+ 9))
   ENDIF
   tspace_list->tname[tspace_list->tcount].tspace_name = dst.tablespace_name, tspace_list->tname[
   tspace_list->tcount].raw_bytes = (dst.static_size * mbyte), tspace_list->tname[tspace_list->tcount
   ].partitioned_bytes = (((round((dst.static_size/ partition_size),0)+ 1) * partition_size) * mbyte),
   tspace_list->tname[tspace_list->tcount].static_ind = 1, total_static_space = (total_static_space+
   tspace_list->tname[tspace_list->tcount].partitioned_bytes)
  WITH nocounter
 ;end select
 SET static_count = tspace_list->tcount
 SET target_size = (target_size - (total_static_space/ mbyte))
 CALL echo(concat(trim(cnvtstring(static_count))," static tablespaces found."))
 CALL echo(concat("Static tablespaces require ",cnvtstring((total_static_space/ mbyte))))
 CALL echo(concat("This leaves ",cnvtstring(target_size)," remaining"))
 SET other_file_types = 0.0
 SELECT INTO "nl:"
  def.file_size
  FROM dm_env_files def
  WHERE def.environment_id=environment_id
   AND  NOT (def.file_type IN ("DATA", "INDEX"))
  DETAIL
   target_size = (target_size - (def.file_size/ mbyte)), other_file_types = (other_file_types+ (def
   .file_size/ mbyte))
  WITH nocounter
 ;end select
 CALL echo(concat("Other data file types require ",cnvtstring(other_file_types)))
 CALL echo(concat("This leaves ",cnvtstring(target_size)," remaining"))
 SET redo_log_size = 0.0
 SELECT INTO "nl:"
  derl.log_size
  FROM dm_env_redo_logs derl
  WHERE derl.environment_id=environment_id
  DETAIL
   target_size = (target_size - (derl.log_size/ mbyte)), redo_log_size = (redo_log_size+ (derl
   .log_size/ mbyte))
  WITH nocounter
 ;end select
 CALL echo(concat("Redo log files require ",cnvtstring(redo_log_size)))
 CALL echo(concat("This leaves ",cnvtstring(target_size)," remaining"))
 SET control_file_size = 0.0
 SELECT INTO "nl:"
  decf.file_size
  FROM dm_env_control_files decf
  WHERE decf.environment_id=environment_id
  DETAIL
   target_size = (target_size - (decf.file_size/ mbyte)), control_file_size = (control_file_size+ (
   decf.file_size/ mbyte))
  WITH nocounter
 ;end select
 CALL echo(concat("Control files require ",cnvtstring(control_file_size)))
 CALL echo(concat("This leaves ",cnvtstring(target_size)," remaining"))
 SET kount = 0
 SELECT DISTINCT INTO "nl:"
  dtd.table_name, dtd.bytes_per_row
  FROM dm_env_functions def,
   dm_schema_version dsv,
   dm_function_dm_section_r dfd,
   dm_tables_doc dtd,
   dm_tables dt
  WHERE def.environment_id=environment_id
   AND dsv.schema_version=schema_version
   AND dfd.function_id=def.function_id
   AND dtd.data_model_section=dfd.data_model_section
   AND dt.table_name=dtd.table_name
   AND dt.schema_date=dsv.schema_date
  ORDER BY dtd.table_name
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,10)=1)
    stat = alterlist(table_list->list,(kount+ 9))
   ENDIF
   table_list->list[kount].tname = dtd.table_name, table_list->list[kount].bytes_per_row = dtd
   .bytes_per_row, table_list->list[kount].delta_rows = 0.0,
   table_list->list[kount].static_rows = 0.0, table_list->list[kount].table_ref_count = 0, table_list
   ->list[kount].sum_index = 0.0,
   table_list->list[kount].static_rows = 1000, table_list->list[kount].dependency_count = 1,
   table_list->list[kount].dependency[1].dependency_resolved = 1,
   table_list->list[kount].dependency[1].dependency_flg = 3, table_list->list[kount].dependency[1].
   dependency = "1000", table_list->list[kount].dependency[1].dependency_ratio = 1
  WITH nocounter
 ;end select
 SET table_list->table_count = kount
 IF (curqual=0)
  CALL echo("Environment or schema date invalid.")
  GO TO end_prg
 ENDIF
 CALL echo(concat(trim(cnvtstring(kount)),
   " tables found under passed environment_id and schema date."))
 SELECT INTO "nl:"
  d.seq, dep.column_name, dep.data_type,
  dep.data_length, dep.table_name
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   dm_columns dep,
   dm_schema_version dsv
  PLAN (d)
   JOIN (dsv
   WHERE dsv.schema_version=schema_version)
   JOIN (dep
   WHERE (dep.table_name=table_list->list[d.seq].tname)
    AND dep.schema_date=dsv.schema_date)
  ORDER BY dep.table_name
  HEAD dep.table_name
   i_bytes_per_row = 0
  DETAIL
   IF (((dep.data_type="LONG") OR (dep.data_type="LONG_RAW")) )
    i_bytes_per_row = (i_bytes_per_row+ 32000)
   ELSE
    i_bytes_per_row = (i_bytes_per_row+ dep.data_length)
   ENDIF
  FOOT  dep.table_name
   IF ((table_list->list[d.seq].bytes_per_row > i_bytes_per_row))
    table_list->list[d.seq].bytes_per_row = i_bytes_per_row
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq, dep.dependency, dep.dependency_flg,
  dep.dependency_ratio, dep.table_name
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   dm_table_dependency dep
  PLAN (d)
   JOIN (dep
   WHERE (dep.table_name=table_list->list[d.seq].tname))
  ORDER BY dep.table_name
  HEAD dep.table_name
   table_list->list[d.seq].static_rows = 0, table_list->list[d.seq].dependency_count = 0, dep_cnt = 0
  DETAIL
   table_list->list[d.seq].dependency_count = (table_list->list[d.seq].dependency_count+ 1), dep_cnt
    = table_list->list[d.seq].dependency_count, table_list->list[d.seq].dependency[dep_cnt].
   dependency = dep.dependency,
   table_list->list[d.seq].dependency[dep_cnt].dependency_flg = dep.dependency_flg
   IF (dep.dependency_ratio=0)
    table_list->list[d.seq].dependency[dep_cnt].dependency_ratio = 1.0
   ELSE
    table_list->list[d.seq].dependency[dep_cnt].dependency_ratio = dep.dependency_ratio
   ENDIF
   table_list->list[d.seq].dependency[dep_cnt].dependency_resolved = 1
   IF (dep.dependency_flg=3)
    table_list->list[d.seq].static_rows = (table_list->list[d.seq].static_rows+ (cnvtint(dep
     .dependency) * dep.dependency_ratio))
   ELSEIF (dep.dependency_flg=4)
    table_list->list[d.seq].delta_rows = (table_list->list[d.seq].delta_rows+ (cnvtint(dep.dependency
     ) * dep.dependency_ratio))
   ELSEIF (dep.dependency_flg=2)
    table_list->list[d.seq].table_ref_count = (table_list->list[d.seq].table_ref_count+ 1),
    table_list->list[d.seq].dependency[dep_cnt].dependency_resolved = 0
   ENDIF
  WITH nocounter
 ;end select
 SET kount = 0
 SELECT DISTINCT INTO "nl:"
  d.seq, table_name = table_list->list[d.seq].tname, di.index_name,
  di.schema_date, did.bytes_per_row
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   dm_schema_version dsv,
   dm_indexes di,
   dm_indexes_doc did
  PLAN (d)
   JOIN (dsv
   WHERE dsv.schema_version=schema_version)
   JOIN (di
   WHERE (di.table_name=table_list->list[d.seq].tname)
    AND di.schema_date=dsv.schema_date)
   JOIN (did
   WHERE did.index_name=di.index_name)
  ORDER BY d.seq, di.index_name, did.bytes_per_row
  HEAD d.seq
   icnt = 0, temp_sum = 0
  DETAIL
   kount = (kount+ 1), icnt = (icnt+ 1)
   IF (mod(icnt,10)=1)
    stat = alterlist(table_list->list[d.seq].index_name,(icnt+ 9))
   ENDIF
   table_list->list[d.seq].index_name[icnt].iname = di.index_name, table_list->list[d.seq].
   index_name[icnt].bytes_per_row = did.bytes_per_row, temp_sum = (temp_sum+ did.bytes_per_row)
  FOOT  d.seq
   table_list->list[d.seq].sum_index = temp_sum, table_list->list[d.seq].index_count = icnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No indices found for passed environment_id and schema date.")
  GO TO end_prg
 ENDIF
 CALL echo(concat(trim(cnvtstring(kount))," indices found for passed environment_id and schema date."
   ))
 SELECT INTO "nl:"
  d.seq, dep.column_name, dep.data_type,
  dep.data_length, dep.table_name
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   dm_columns dep,
   dm_index_columns dic,
   dm_schema_version dsv
  PLAN (d)
   JOIN (dsv
   WHERE dsv.schema_version=schema_version)
   JOIN (dic
   WHERE dic.schema_date=dsv.schema_date
    AND (dic.table_name=table_list->list[d.seq].tname))
   JOIN (dep
   WHERE dic.column_name=dep.column_name
    AND dep.table_name=dic.table_name
    AND dep.schema_date=dic.schema_date)
  ORDER BY dep.table_name
  HEAD dep.table_name
   i_bytes_per_row = 0
  DETAIL
   IF (((dep.data_type="LONG") OR (dep.data_type="LONG_RAW")) )
    i_bytes_per_row = (i_bytes_per_row+ 32000)
   ELSE
    i_bytes_per_row = (i_bytes_per_row+ dep.data_length)
   ENDIF
  FOOT  dep.table_name
   IF ((table_list->list[d.seq].sum_index > i_bytes_per_row))
    table_list->list[d.seq].sum_index = i_bytes_per_row
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("getting the answers to the questions")
 SELECT INTO "nl:"
  dq.description, dq.question_type, dq.question_number,
  deq.question_answer
  FROM dm_question dq,
   dm_env_question deq
  WHERE deq.environment_id=environment_id
   AND dq.question_number=deq.question_number
  ORDER BY dq.question_number
  DETAIL
   question_list->question_count = (question_list->question_count+ 1)
   IF (mod(question_list->question_count,10)=1)
    stat = alterlist(question_list->question,(question_list->question_count+ 9))
   ENDIF
   question_list->question[question_list->question_count].description = dq.description, question_list
   ->question[question_list->question_count].question_type = dq.question_type, question_list->
   question[question_list->question_count].question_number = dq.question_number,
   question_list->question[question_list->question_count].question_answer = deq.question_answer
  WITH nocounter
 ;end select
 CALL echo("caclulating the row counts based on the answers to the questions")
 FOR (kount = 1 TO table_list->table_count)
   FOR (dcount = 1 TO table_list->list[kount].dependency_count)
     IF ((table_list->list[kount].dependency[dcount].dependency_flg=1))
      FOR (qcount = 1 TO question_list->question_count)
        IF ((cnvtint(table_list->list[kount].dependency[dcount].dependency)=question_list->question[
        qcount].question_number))
         IF ((question_list->question[qcount].question_type=1))
          SET table_list->list[kount].static_rows = (table_list->list[kount].static_rows+ (
          question_list->question[qcount].question_answer * table_list->list[kount].dependency[dcount
          ].dependency_ratio))
         ELSE
          SET table_list->list[kount].delta_rows = (table_list->list[kount].delta_rows+ (
          question_list->question[qcount].question_answer * table_list->list[kount].dependency[dcount
          ].dependency_ratio))
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 CALL echo("all of the questions have been resolved")
 SET max_attempts = 10
 SET attempts = 0
 SET unresolves_exist = 1
 SET global_unresolves_exist = 1
 WHILE (attempts < max_attempts
  AND global_unresolves_exist=1)
   SET attempts = (attempts+ 1)
   SET global_unresolves_exist = 0
   FOR (kount = 1 TO table_list->table_count)
     FOR (dcount = 1 TO table_list->list[kount].dependency_count)
       IF ((table_list->list[kount].dependency[dcount].dependency_flg=2)
        AND (table_list->list[kount].dependency[dcount].dependency_resolved=0))
        SET unresolves_exist = 0
        SET driver_table_found = 0
        FOR (tcount = 1 TO table_list->table_count)
          IF ((table_list->list[tcount].tname=table_list->list[kount].dependency[dcount].dependency))
           SET driver_table_found = 1
           FOR (pcount = 1 TO table_list->list[tcount].dependency_count)
             IF ((table_list->list[tcount].dependency[pcount].dependency_resolved=0))
              SET global_unresolves_exist = 1
              SET unresolves_exist = 1
             ENDIF
           ENDFOR
           IF (unresolves_exist=0)
            SET table_list->list[kount].dependency[dcount].dependency_resolved = 1
            SET table_list->list[kount].delta_rows = (table_list->list[kount].delta_rows+ (table_list
            ->list[tcount].delta_rows * table_list->list[kount].dependency[dcount].dependency_ratio))
            SET table_list->list[kount].static_rows = (table_list->list[kount].static_rows+ (
            table_list->list[tcount].static_rows * table_list->list[kount].dependency[dcount].
            dependency_ratio))
           ENDIF
          ENDIF
        ENDFOR
        IF (driver_table_found=0)
         CALL echo(build("Warning - ",table_list->list[kount].tname," is dependent on table ",
           table_list->list[kount].dependency[dcount].dependency,
           " which is not in the schema being built."))
         SET table_list->list[kount].dependency[dcount].dependency_resolved = 1
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 ENDWHILE
 IF (attempts=max_attempts)
  CALL echo(build("Max attempts reached to resolve dependencies"))
  GO TO end_prg
 ENDIF
 SELECT INTO dm_calculate_sizing
  *
  FROM dual
  DETAIL
   "table_name   delta_bytes_total     static_bytes_total   total_bytes   table_bytes/row",
   "delta_rows     static_rows    index_bytes/row", row + 1
   FOR (kount = 1 TO table_list->table_count)
     table_list->list[kount].tname, x = ((table_list->list[kount].bytes_per_row+ table_list->list[
     kount].sum_index) * table_list->list[kount].delta_rows), y = ((table_list->list[kount].
     bytes_per_row+ table_list->list[kount].sum_index) * table_list->list[kount].static_rows),
     z = (((table_list->list[kount].bytes_per_row+ table_list->list[kount].sum_index) * table_list->
     list[kount].delta_rows)+ ((table_list->list[kount].bytes_per_row+ table_list->list[kount].
     sum_index) * table_list->list[kount].static_rows)), x, y,
     z, table_list->list[kount].bytes_per_row, table_list->list[kount].delta_rows,
     table_list->list[kount].static_rows, table_list->list[kount].sum_index, row + 1
   ENDFOR
  WITH nocounter, maxcol = 255, maxrow = 1,
   formfeed = none, format = stream
 ;end select
 SET tab_str = char(9)
 SELECT INTO dm_calculate_sizing2
  *
  FROM dual
  DETAIL
   "table_name", tab_str, "total bytes/month",
   tab_str, "total static bytes", tab_str,
   "dependency", row + 1
   FOR (kount = 1 TO table_list->table_count)
     x = ((table_list->list[kount].bytes_per_row+ table_list->list[kount].sum_index) * table_list->
     list[kount].delta_rows), y = ((table_list->list[kount].bytes_per_row+ table_list->list[kount].
     sum_index) * table_list->list[kount].static_rows)
     FOR (dcount = 1 TO table_list->list[kount].dependency_count)
       table_list->list[kount].tname, x, y
       IF ((table_list->list[kount].dependency[dcount].dependency_flg=1))
        FOR (qcount = 1 TO question_list->question_count)
          IF ((cnvtint(table_list->list[kount].dependency[dcount].dependency)=question_list->
          question[qcount].question_number))
           IF ((question_list->question[qcount].question_type=1))
            "Static - "
           ELSE
            "Delta - "
           ENDIF
           question_list->question[qcount].question_answer, " * ", table_list->list[kount].
           dependency[dcount].dependency_ratio,
           " question answer ", question_list->question[qcount].description
          ENDIF
        ENDFOR
       ELSEIF ((table_list->list[kount].dependency[dcount].dependency_flg=2))
        FOR (tcount = 1 TO table_list->table_count)
          IF ((table_list->list[kount].dependency[dcount].dependency=table_list->list[tcount].tname))
           "This table will contain ", table_list->list[kount].dependency[dcount].dependency_ratio,
           " times the number of  rows in ",
           table_list->list[tcount].tname, " which has	", table_list->list[tcount].static_rows,
           " static rows and ", table_list->list[tcount].delta_rows, " dynamic rows."
          ENDIF
        ENDFOR
       ELSEIF ((table_list->list[kount].dependency[dcount].dependency_flg=3))
        "Static rows ", table_list->list[kount].static_rows, " * ",
        table_list->list[kount].dependency[dcount].dependency_ratio
       ELSEIF ((table_list->list[kount].dependency[dcount].dependency_flg=4))
        "Dynamic rows ", table_list->list[kount].delta_rows, " * ",
        table_list->list[kount].dependency[dcount].dependency_ratio
       ENDIF
       row + 1
     ENDFOR
   ENDFOR
  WITH nocounter, maxcol = 255, maxrow = 1,
   formfeed = none, format = stream
 ;end select
 SELECT INTO "nl:"
  table_name = table_list->list[d.seq].tname, static = ((table_list->list[d.seq].bytes_per_row+
  table_list->list[d.seq].sum_index) * table_list->list[d.seq].static_rows), delta = ((table_list->
  list[d.seq].bytes_per_row+ table_list->list[d.seq].sum_index) * table_list->list[d.seq].delta_rows)
  FROM (dummyt d  WITH seq = value(table_list->table_count))
  ORDER BY table_name, static, delta
  DETAIL
   col 1, sum_static = (sum_static+ static), col + 1,
   sum_delta = (sum_delta+ delta), col + 1, table_name,
   col + 1, delta, col + 1,
   sum_delta, col + 1, static,
   col + 1, sum_static, row + 1
  WITH nocounter
 ;end select
 CALL echo(build("Static tables alone require ",sum_static))
 CALL echo(build("Size available ",cnvtstring((target_size * mbyte))))
 IF ((sum_static > (target_size * mbyte)))
  CALL echo("Storage space is too small to hold the initial data.")
  SET length_string = "To hold just the intial data, you need "
  SET space_short = (sum_static - (target_size * mbyte))
  SET month_string = build(space_short," more bytes of storage space.")
  CALL echo(concat(length_string,month_string))
  GO TO end_prg
 ELSE
  IF (sum_delta=0)
   SET month_string = "until your system goes to computer heaven."
  ELSE
   SET months = ((((0.75 * target_size) * mbyte) - cnvtreal(sum_static))/ cnvtreal(sum_delta))
   IF (months < 0)
    SET months = 0.0
   ENDIF
   SET temp_year = cnvtint((months/ 12))
   SET year_string = concat(trim(cnvtstring(temp_year))," years, ")
   SET temp_month = cnvtint((months - (temp_year * 12)))
   SET mo_string = concat(trim(cnvtstring(temp_month))," months.")
   SET month_string = concat(trim(year_string)," ",trim(mo_string))
  ENDIF
  SET length_string = "With passed size, the database will last approximately "
 ENDIF
 CALL echo(concat(length_string,month_string))
 UPDATE  FROM dm_environment de
  SET de.month_cnt = months
  WHERE de.environment_id=environment_id
  WITH nocounter
 ;end update
 DELETE  FROM dm_env_table det
  WHERE det.environment_id=environment_id
  WITH nocounter
 ;end delete
 COMMIT
 IF (curqual != 0)
  CALL echo("Table sizing info deleted for passed environment.")
 ENDIF
 DELETE  FROM dm_env_index dei
  WHERE dei.environment_id=environment_id
  WITH nocounter
 ;end delete
 COMMIT
 IF (curqual != 0)
  CALL echo("Index sizing info deleted for passed environment.")
 ENDIF
 SELECT INTO "nl:"
  table_name = table_list->list[d.seq].tname
  FROM (dummyt d  WITH seq = value(table_list->table_count))
  ORDER BY table_name
  DETAIL
   table_list->list[d.seq].rowcount = (0.75 * (table_list->list[d.seq].static_rows+ (table_list->
   list[d.seq].delta_rows * months))), table_list->list[d.seq].init = (table_list->list[d.seq].
   rowcount * table_list->list[d.seq].bytes_per_row), table_list->list[d.seq].next = (table_list->
   list[d.seq].init/ 10),
   col 1, table_name, col + 1,
   months, col + 1, table_list->list[d.seq].rowcount,
   col + 1, table_list->list[d.seq].bytes_per_row, col + 1,
   table_list->list[d.seq].init, col + 1, table_list->list[d.seq].next,
   row + 1
  WITH nocounter
 ;end select
 INSERT  FROM dm_env_table dev,
   (dummyt d  WITH seq = value(table_list->table_count))
  SET dev.environment_id = environment_id, dev.table_name = table_list->list[d.seq].tname, dev
   .initial_extent = table_list->list[d.seq].init,
   dev.next_extent = table_list->list[d.seq].next, dev.updt_applctx = 0, dev.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dev.updt_cnt = 0, dev.updt_id = 0, dev.updt_task = 0
  PLAN (d)
   JOIN (dev)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL echo("Failed to insert sizing data for the tables.")
  GO TO end_prg
 ENDIF
 COMMIT
 SELECT INTO "nl:"
  table_name = table_list->list[d.seq].tname, index_name = table_list->list[d.seq].index_name[d2.seq]
  .iname
  FROM (dummyt d  WITH seq = value(table_list->table_count)),
   (dummyt d2  WITH seq = value(100))
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= table_list->list[d.seq].index_count))
  ORDER BY index_name, table_name
  DETAIL
   table_list->list[d.seq].index_name[d2.seq].init = (table_list->list[d.seq].rowcount * table_list->
   list[d.seq].index_name[d2.seq].bytes_per_row), table_list->list[d.seq].index_name[d2.seq].next = (
   table_list->list[d.seq].index_name[d2.seq].init/ 10), col 1,
   table_name, col + 1, index_name,
   col + 1, months, row + 1,
   col + 1, table_list->list[d.seq].rowcount, col + 1,
   table_list->list[d.seq].index_name[d2.seq].bytes_per_row, col + 1, table_list->list[d.seq].
   index_name[d2.seq].init,
   col + 1, table_list->list[d.seq].index_name[d2.seq].next, row + 1
  WITH nocounter
 ;end select
 INSERT  FROM dm_env_index dei,
   (dummyt d  WITH seq = value(table_list->table_count)),
   (dummyt d2  WITH seq = value(100))
  SET dei.environment_id = environment_id, dei.index_name = table_list->list[d.seq].index_name[d2.seq
   ].iname, dei.initial_extent = table_list->list[d.seq].index_name[d2.seq].init,
   dei.next_extent = table_list->list[d.seq].index_name[d2.seq].next, dei.updt_applctx = 0, dei
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dei.updt_cnt = 0, dei.updt_id = 0, dei.updt_task = 0
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= table_list->list[d.seq].index_count))
   JOIN (dei)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL echo("Failed to insert sizing data for the tables.")
  GO TO end_prg
 ENDIF
 COMMIT
 SELECT INTO "nl:"
  dt.tablespace_name, dt.table_name, det.initial_extent,
  det.next_extent
  FROM dm_tables dt,
   dm_schema_version dsv,
   dm_env_table det
  PLAN (dsv
   WHERE dsv.schema_version=schema_version)
   JOIN (dt
   WHERE dt.schema_date=dsv.schema_date)
   JOIN (det
   WHERE det.environment_id=environment_id
    AND det.table_name=dt.table_name)
  ORDER BY dt.tablespace_name, dt.table_name, det.initial_extent,
   det.next_extent
  HEAD dt.tablespace_name
   temp_sum = 0.0
  DETAIL
   temp_sum = ((temp_sum+ det.initial_extent)+ det.next_extent), col 1, dt.tablespace_name,
   col + 1, dt.table_name, col + 1,
   det.initial_extent, col + 1, det.next_extent,
   col + 1, temp_sum, row + 1
  FOOT  dt.tablespace_name
   tspace_list->tcount = (tspace_list->tcount+ 1)
   IF (mod(tspace_list->tcount,10)=1)
    stat = alterlist(tspace_list->tname,(tspace_list->tcount+ 9))
   ENDIF
   tspace_list->tname[tspace_list->tcount].tspace_name = dt.tablespace_name, tspace_list->tname[
   tspace_list->tcount].raw_bytes = temp_sum, tspace_list->tname[tspace_list->tcount].
   partitioned_bytes = (((round((temp_sum/ (partition_size * mbyte)),0)+ 1) * partition_size) * mbyte
   ),
   tspace_list->tname[tspace_list->tcount].static_ind = 0, total_space = (total_space+ temp_sum),
   total_part = (total_part+ tspace_list->tname[tspace_list->tcount].partitioned_bytes)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.tablespace_name, di.index_name, dei.initial_extent,
  dei.next_extent
  FROM dm_indexes di,
   dm_schema_version dsv,
   dm_env_index dei
  PLAN (dsv
   WHERE dsv.schema_version=schema_version)
   JOIN (di
   WHERE di.schema_date=dsv.schema_date)
   JOIN (dei
   WHERE dei.environment_id=environment_id
    AND dei.index_name=di.index_name)
  ORDER BY di.tablespace_name, di.index_name, dei.initial_extent,
   dei.next_extent
  HEAD di.tablespace_name
   temp_sum = 0.0
  DETAIL
   temp_sum = ((temp_sum+ dei.initial_extent)+ dei.next_extent), col 1, di.tablespace_name,
   col + 1, di.index_name, col + 1,
   dei.initial_extent, col + 1, dei.next_extent,
   col + 1, temp_sum, row + 1
  FOOT  di.tablespace_name
   tspace_list->tcount = (tspace_list->tcount+ 1), stat = alterlist(tspace_list->tname,tspace_list->
    tcount), tspace_list->tname[tspace_list->tcount].tspace_name = di.tablespace_name,
   tspace_list->tname[tspace_list->tcount].raw_bytes = temp_sum, tspace_list->tname[tspace_list->
   tcount].partitioned_bytes = (((round((temp_sum/ (partition_size * mbyte)),0)+ 1) * partition_size)
    * mbyte), tspace_list->tname[tspace_list->tcount].static_ind = 0,
   total_space = (total_space+ temp_sum), total_part = (total_part+ tspace_list->tname[tspace_list->
   tcount].partitioned_bytes)
  WITH nocounter
 ;end select
 CALL echo(concat(cnvtstring(total_space)," bytes initially allocated to the non-static tablespaces."
   ))
 CALL echo(concat(cnvtstring(total_part),
   " bytes allocated to the nearest partition size for non-static tablespaces."))
 CALL echo(concat("Tablespace count = ",cnvtstring(tspace_list->tcount)))
 SET target_total_space = ((target_size * mbyte) - total_part)
 CALL echo(concat("target_size ",cnvtstring(target_size)))
 CALL echo(concat("total_part ",cnvtstring(total_part)))
 CALL echo(concat("target_total_space ",cnvtstring(target_total_space)))
 CALL echo(concat("partition_size ",cnvtstring(partition_size)))
 CALL echo(concat("cnvtreal(tspace_list->tcount-static_count) ",cnvtstring(cnvtreal((tspace_list->
     tcount - static_count)))))
 CALL echo(concat("Partition size ",cnvtstring(partition_size)))
 SET total_part = 0.0
 SELECT INTO "nl:"
  tablespace_name = tspace_list->tname[d.seq].tspace_name
  FROM (dummyt d  WITH seq = value(tspace_list->tcount))
  PLAN (d
   WHERE (tspace_list->tname[d.seq].static_ind=0))
  DETAIL
   IF ((tspace_list->tname[d.seq].static_ind=0))
    total_part = (total_part+ tspace_list->tname[d.seq].partitioned_bytes)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(concat(cnvtstring(total_part),
   " bytes adjusted to the nearest partition size for non-static tablespaces."))
 DELETE  FROM dm_env_files def
  WHERE def.environment_id=environment_id
   AND def.file_type IN ("DATA", "INDEX")
  WITH nocounter
 ;end delete
 COMMIT
 IF (curqual != 0)
  CALL echo("File size info deleted for passed environment.")
 ENDIF
 RECORD file_sizes(
   1 scount = i4
   1 sizes[*]
     2 size = f8
     2 size_seq = f8
 )
 SET file_sizes->scount = 0
 SELECT INTO "nl:"
  derl.log_size
  FROM dm_env_redo_logs derl
  WHERE derl.environment_id=environment_id
  DETAIL
   size_found = 0
   FOR (i = 1 TO file_sizes->scount)
     IF ((derl.log_size=file_sizes->sizes[i].size))
      file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1), size_found = 1
     ENDIF
   ENDFOR
   IF (size_found=0)
    file_sizes->scount = (file_sizes->scount+ 1)
    IF (mod(file_sizes->scount,10)=1)
     stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
    ENDIF
    file_sizes->sizes[file_sizes->scount].size = derl.log_size, file_sizes->sizes[file_sizes->scount]
    .size_seq = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  decf.file_size
  FROM dm_env_control_files decf
  WHERE decf.environment_id=environment_id
  DETAIL
   size_found = 0
   FOR (i = 1 TO file_sizes->scount)
     IF ((decf.file_size=file_sizes->sizes[i].size))
      file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1), size_found = 1
     ENDIF
   ENDFOR
   IF (size_found=0)
    file_sizes->scount = (file_sizes->scount+ 1)
    IF (mod(file_sizes->scount,10)=1)
     stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
    ENDIF
    file_sizes->sizes[file_sizes->scount].size = decf.file_size, file_sizes->sizes[file_sizes->scount
    ].size_seq = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  def.file_size
  FROM dm_env_files def
  WHERE def.environment_id=environment_id
   AND  NOT (def.file_type IN ("DATA", "INDEX"))
  DETAIL
   size_found = 0
   FOR (i = 1 TO file_sizes->scount)
     IF ((def.file_size=file_sizes->sizes[i].size))
      file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1), size_found = 1
     ENDIF
   ENDFOR
   IF (size_found=0)
    file_sizes->scount = (file_sizes->scount+ 1)
    IF (mod(file_sizes->scount,10)=1)
     stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
    ENDIF
    file_sizes->sizes[file_sizes->scount].size = def.file_size, file_sizes->sizes[file_sizes->scount]
    .size_seq = 1
   ENDIF
  WITH nocounter
 ;end select
 RECORD tspace_files(
   1 fcount = i4
   1 tname[*]
     2 size = f8
     2 raw_size = f8
     2 tspace_name = c32
     2 fname = c40
     2 size_seq = f8
 )
 SET tspace_files->fcount = 0
 FOR (kount = 1 TO tspace_list->tcount)
   SET row_count = 1
   SET total_size = tspace_list->tname[kount].partitioned_bytes
   WHILE (total_size > 0.0)
     SET tspace_files->fcount = (tspace_files->fcount+ 1)
     IF (mod(tspace_files->fcount,10)=1)
      SET stat = alterlist(tspace_files->tname,(tspace_files->fcount+ 9))
     ENDIF
     IF (total_size > max_size)
      SET raw_size = max_size
     ELSE
      SET raw_size = total_size
     ENDIF
     SET total_size = (total_size - raw_size)
     IF (system="AIX")
      SET tspace_files->tname[tspace_files->fcount].size = (raw_size - mbyte)
     ELSE
      SET tspace_files->tname[tspace_files->fcount].size = raw_size
     ENDIF
     SET tspace_files->tname[tspace_files->fcount].raw_size = raw_size
     SET tspace_files->tname[tspace_files->fcount].tspace_name = tspace_list->tname[kount].
     tspace_name
     SET size_found = 0
     FOR (i = 1 TO file_sizes->scount)
       IF (((system="AIX"
        AND ((raw_size - mbyte)=file_sizes->sizes[i].size)) OR (system != "AIX"
        AND (raw_size=file_sizes->sizes[i].size))) )
        SET file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1)
        SET tspace_files->tname[tspace_files->fcount].size_seq = file_sizes->sizes[i].size_seq
        SET size_found = 1
       ENDIF
     ENDFOR
     IF (size_found=0)
      SET file_sizes->scount = (file_sizes->scount+ 1)
      IF (mod(file_sizes->scount,10)=1)
       SET stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
      ENDIF
      IF (system="AIX")
       SET file_sizes->sizes[file_sizes->scount].size = (raw_size - mbyte)
      ELSE
       SET file_sizes->sizes[file_sizes->scount].size = raw_size
      ENDIF
      SET file_sizes->sizes[file_sizes->scount].size_seq = 1
      SET tspace_files->tname[tspace_files->fcount].size_seq = 1
     ENDIF
     SET file_seq = format(cnvtstring(row_count),"##;P0")
     IF (system="AIX")
      SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024 * 1024))),
        "####;P0"),"_",format(cnvtstring(tspace_files->tname[tspace_files->fcount].size_seq),"###;P0"
        ))
     ELSE
      SET fname = build(tspace_list->tname[kount].tspace_name,"_",file_seq)
     ENDIF
     SET row_count = (row_count+ 1)
     SET tspace_files->tname[tspace_files->fcount].fname = fname
     INSERT  FROM dm_env_files def
      SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
       def.updt_id = 0, def.updt_task = 0, def.file_type =
       IF (substring(1,1,tspace_files->tname[tspace_files->fcount].tspace_name)="I") "INDEX"
       ELSE "DATA"
       ENDIF
       ,
       def.file_size = tspace_files->tname[tspace_files->fcount].size, def.size_sequence =
       tspace_files->tname[tspace_files->fcount].size_seq, def.environment_id = environment_id,
       def.tablespace_name = tspace_files->tname[tspace_files->fcount].tspace_name, def.file_name =
       tspace_files->tname[tspace_files->fcount].fname
      WITH nocounter
     ;end insert
   ENDWHILE
 ENDFOR
 COMMIT
#end_prg
END GO
