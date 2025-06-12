CREATE PROGRAM dm_create_schema_main:dba
 IF (validate(dm_debug,0) > 0)
  SET message = nowindow
 ENDIF
 CALL echo("12/21/98")
 RECORD str(
   1 str = vc
 )
 EXECUTE dm_temp_check
 SET mbytes = (1024.0 * 1024.0)
 SET tempstr = fillstring(80," ")
 SET tempstr2 = fillstring(100," ")
 SET max_size = 0.0
 SET partition_size = 0.0
 SET system = fillstring(3," ")
 SET database_name = fillstring(30," ")
 SELECT INTO "nl:"
  de.target_operating_system, de.data_file_partition_size, de.max_file_size,
  de.database_name
  FROM dm_environment de
  WHERE (de.environment_id=dm_create_schema->environment_id)
  DETAIL
   database_name = de.database_name, system = de.target_operating_system, partition_size = (de
   .data_file_partition_size * mbytes),
   max_size = (de.max_file_size * mbytes)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Program aborted. No data available for this environment_id.")
  GO TO end_prg
 ENDIF
 IF (validate(dm_debug,0) > 0)
  CALL echo("Dynamically build the sequences for the tables in the target environment.")
 ENDIF
 SELECT INTO "dm_create_schema.sequence"
  us.*
  FROM user_sequences us
  DETAIL
   "RDB CREATE SEQUENCE ", us.sequence_name, " INCREMENT BY ",
   us.increment_by, row + 1, " start with ",
   us.last_number"############################.##", row + 1
   IF (us.cycle_flag="N"
    AND us.max_value=10000000000.00)
    " NOMAXVALUE ", row + 1
   ELSE
    " MAXVALUE ", us.max_value"############################.##", row + 1
   ENDIF
   IF (us.min_value=null)
    " NOMINVALUE ", row + 1
   ELSE
    " MINVALUE ", us.min_value"############################.##", row + 1
   ENDIF
   IF (us.cycle_flag="N")
    " NOCYCLE "
   ELSE
    " CYCLE "
   ENDIF
   IF (us.cache_size=0)
    " NOCACHE "
   ELSE
    " CACHE ", us.cache_size
   ENDIF
   IF (us.order_flag="N")
    " NOORDER "
   ELSE
    " ORDER "
   ENDIF
   " ", row + 1, "go",
   row + 1
  WITH nocounter, maxcol = 300, noformat,
   formfeed = none
 ;end select
 FREE SET db_objects
 RECORD db_objects(
   1 object[*]
     2 object_name = vc
     2 object_type = vc
     2 object_size = f8
     2 object_size_allocated = f8
     2 object_size_adjusted = f8
     2 source
       3 initial_extent = f8
       3 next_extent = f8
     2 target
       3 initial_extent = f8
       3 next_extent = f8
     2 object_tablespace = vc
     2 reference_ind = i4
   1 object_count = i4
   1 source
     2 total_allocated = f8
     2 total_used = f8
   1 target
     2 total_allocated = f8
     2 total_used = f8
 )
 SET stat = alterlist(db_objects->object,10)
 SET db_objects->object_count = 0
 SET db_objects->source.total_allocated = 0.0
 SET db_objects->source.total_used = 0.0
 SET db_objects->target.total_allocated = 0.0
 SET db_objects->target.total_used = 0.0
 FREE SET db_tspace
 RECORD db_tspace(
   1 tspace[*]
     2 tspace_name = vc
     2 tspace_size = f8
     2 partitioned_bytes = f8
   1 tspace_count = i4
   1 tspace_total_source = f8
   1 tspace_total_target = f8
 )
 SET db_tspace->tspace_count = 0
 SET db_block_size = 0.0
 SET db_5block_size = 0.0
 SELECT INTO "nl:"
  v.value
  FROM v$parameter v
  WHERE v.name="db_block_size"
  DETAIL
   db_block_size = cnvtreal(v.value), db_5block_size = (cnvtreal(v.value) * 5.0)
  WITH nocounter
 ;end select
 IF (validate(dm_debug,0) > 0)
  CALL echo("Perform ANALYZE if flag is set.")
 ENDIF
 IF ((dm_create_schema->perform_analyze=1))
  SELECT
   IF ((dm_create_schema->all_tablespaces=0))
    FROM user_tables dt,
     (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
    PLAN (d)
     JOIN (dt
     WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   ELSE
    FROM user_tables dt
   ENDIF
   INTO "nl:"
   dt.table_name
   ORDER BY dt.table_name
   DETAIL
    db_objects->object_count = (db_objects->object_count+ 1)
    IF (mod(db_objects->object_count,10)=1
     AND (db_objects->object_count != 1))
     stat = alterlist(db_objects->object,(db_objects->object_count+ 9))
    ENDIF
    db_objects->object[db_objects->object_count].object_name = dt.table_name, db_objects->object[
    db_objects->object_count].object_type = "TABLE"
   WITH nocounter
  ;end select
  IF ((dm_create_schema->all_tablespaces=0))
   SELECT INTO "nl:"
    dt.table_name, dt.index_name
    FROM user_indexes dt,
     (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
    PLAN (d)
     JOIN (dt
     WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
    ORDER BY dt.table_name
    DETAIL
     table_found = 0
     FOR (i = 1 TO db_objects->object_count)
       IF ((db_objects->object[i].object_name=dt.table_name))
        table_found = 1
       ENDIF
     ENDFOR
     IF (table_found=0)
      db_objects->object_count = (db_objects->object_count+ 1)
      IF (mod(db_objects->object_count,10)=1
       AND (db_objects->object_count != 1))
       stat = alterlist(db_objects->object,(db_objects->object_count+ 9))
      ENDIF
      db_objects->object[db_objects->object_count].object_name = dt.index_name, db_objects->object[
      db_objects->object_count].object_type = "INDEX"
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  FOR (i = 1 TO db_objects->object_count)
    IF ((db_objects->object[i].object_type="INDEX"))
     CALL echo(concat("analyzing index ",db_objects->object[i].object_name))
     CALL parser(concat("rdb analyze index ",db_objects->object[i].object_name,
       " estimate statistics go"))
    ELSE
     CALL echo(concat("analyzing table ",db_objects->object[i].object_name))
     CALL parser(concat("rdb analyze table ",db_objects->object[i].object_name,
       " estimate statistics go"))
    ENDIF
  ENDFOR
  SET db_objects->object_count = 0
 ENDIF
 IF (validate(dm_debug,0) > 0)
  CALL echo("Get the size of all the index objects")
 ENDIF
 SELECT
  IF ((dm_create_schema->all_tablespaces=0))
   di.index_name, tspace_name = dm_create_schema->tspace_list[d.seq].new_tspace_name, di.leaf_blocks,
   di.table_name, dtc.reference_ind, us.blocks,
   us.initial_extent, us.next_extent
   FROM dm_tables_doc dtc,
    user_indexes di,
    dm_segments us,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (di
    WHERE di.table_owner=currdbuser
     AND (di.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
    JOIN (dtc
    WHERE dtc.table_name=di.table_name)
    JOIN (us
    WHERE di.index_name=us.segment_name)
  ELSE
   di.index_name, tspace_name = di.tablespace_name, di.leaf_blocks,
   di.table_name, dtc.reference_ind, us.blocks,
   us.initial_extent, us.next_extent
   FROM dm_tables_doc dtc,
    user_indexes di,
    dm_segments us
   WHERE dtc.table_name=di.table_name
    AND di.table_owner=currdbuser
    AND di.index_name=us.segment_name
  ENDIF
  INTO "nl:"
  DETAIL
   db_objects->object_count = (db_objects->object_count+ 1)
   IF (mod(db_objects->object_count,10)=1
    AND (db_objects->object_count != 1))
    stat = alterlist(db_objects->object,(db_objects->object_count+ 9))
   ENDIF
   db_objects->object[db_objects->object_count].object_name = di.index_name, db_objects->object[
   db_objects->object_count].reference_ind = dtc.reference_ind, db_objects->object[db_objects->
   object_count].object_tablespace = tspace_name,
   db_objects->object[db_objects->object_count].object_size_allocated = (16 * 1024), db_objects->
   object[db_objects->object_count].source.initial_extent = us.initial_extent, db_objects->object[
   db_objects->object_count].source.next_extent = us.next_extent,
   db_objects->object[db_objects->object_count].object_size = ((ceil((di.leaf_blocks * 1.025))+ 3) *
   db_block_size), db_objects->object[db_objects->object_count].object_size_allocated = ((us.blocks+
   3) * db_block_size), db_objects->object[db_objects->object_count].object_type = "INDEX",
   db_objects->source.total_used = (db_objects->source.total_used+ db_objects->object[db_objects->
   object_count].object_size), db_objects->source.total_allocated = (db_objects->source.
   total_allocated+ db_objects->object[db_objects->object_count].object_size_allocated)
  WITH nocounter
 ;end select
 SET found = 0
 IF (validate(dm_debug,0) > 0)
  CALL echo("Get the size of all the table objects")
 ENDIF
 SELECT
  IF ((dm_create_schema->all_tablespaces=0))
   dt.table_name, tspace_name = dm_create_schema->tspace_list[d.seq].new_tspace_name, dt.blocks,
   dt.empty_blocks, dtc.reference_ind
   FROM dm_tables_doc dtc,
    user_tables dt,
    dm_segments us,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (dt
    WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
    JOIN (dtc
    WHERE dt.table_name=dtc.table_name)
    JOIN (us
    WHERE dt.table_name=us.segment_name)
  ELSE
   dt.table_name, tspace_name = dt.tablespace_name, dt.blocks,
   dt.empty_blocks, dtc.reference_ind
   FROM dm_tables_doc dtc,
    user_tables dt,
    dm_segments us
   WHERE dt.table_name=dtc.table_name
    AND dt.table_name=us.segment_name
  ENDIF
  INTO "nl:"
  ORDER BY dt.table_name
  DETAIL
   db_objects->object_count = (db_objects->object_count+ 1)
   IF (mod(db_objects->object_count,10)=1
    AND (db_objects->object_count != 1))
    stat = alterlist(db_objects->object,(db_objects->object_count+ 9))
   ENDIF
   db_objects->object[db_objects->object_count].object_name = dt.table_name, db_objects->object[
   db_objects->object_count].object_tablespace = tspace_name, db_objects->object[db_objects->
   object_count].reference_ind = dtc.reference_ind,
   db_objects->object[db_objects->object_count].object_size = (dt.blocks * db_block_size), db_objects
   ->source.total_used = (db_objects->source.total_used+ db_objects->object[db_objects->object_count]
   .object_size), db_objects->object[db_objects->object_count].object_size_allocated = ((dt.blocks+
   dt.empty_blocks) * db_block_size),
   db_objects->source.total_allocated = (db_objects->source.total_allocated+ db_objects->object[
   db_objects->object_count].object_size_allocated), db_objects->object[db_objects->object_count].
   object_type = "TABLE", db_objects->object[db_objects->object_count].source.initial_extent = us
   .initial_extent,
   db_objects->object[db_objects->object_count].source.next_extent = us.next_extent
  WITH nocounter
 ;end select
 IF ((dm_create_schema->all_tablespaces=1))
  SELECT INTO "nl:"
   FROM dm_env_functions def,
    dm_static_tablespaces dst
   WHERE (def.environment_id=dm_create_schema->environment_id)
    AND def.function_id=dst.function_id
   DETAIL
    db_tspace->tspace_count = (db_tspace->tspace_count+ 1), stat = alterlist(db_tspace->tspace,
     db_tspace->tspace_count), db_tspace->tspace[db_tspace->tspace_count].tspace_name = dst
    .tablespace_name,
    db_tspace->tspace[db_tspace->tspace_count].tspace_size = (dst.static_size * mbytes)
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO db_objects->object_count)
   IF ((((db_objects->object[i].reference_ind=1)) OR ((dm_create_schema->shrink_activity_objects=0)
   )) )
    IF ((dm_create_schema->use_object_actual_size=1))
     SET db_objects->object[i].object_size_adjusted = db_objects->object[i].object_size
    ELSE
     SET db_objects->object[i].object_size_adjusted = db_objects->object[i].object_size_allocated
    ENDIF
   ELSE
    IF ((db_objects->object[i].object_size_allocated >= mbytes))
     SET db_objects->object[i].object_size_adjusted = mbytes
    ELSEIF ((dm_create_schema->use_object_actual_size=1))
     SET db_objects->object[i].object_size_adjusted = db_objects->object[i].object_size
    ELSE
     SET db_objects->object[i].object_size_adjusted = db_objects->object[i].object_size_allocated
    ENDIF
   ENDIF
   IF ((db_objects->object[i].object_size_adjusted < (2 * db_block_size)))
    SET db_objects->object[i].object_size_adjusted = (2 * db_block_size)
   ENDIF
   IF ((dm_create_schema->preserve_source_iextent_size=1))
    SET db_objects->object[i].target.initial_extent = db_objects->object[i].source.initial_extent
   ELSE
    SET db_objects->object[i].target.initial_extent = (ceil(((db_objects->object[i].
     object_size_adjusted * dm_create_schema->percent_initial_extent)/ db_block_size)) *
    db_block_size)
   ENDIF
   IF ((dm_create_schema->preserve_source_nextent_size=1))
    SET db_objects->object[i].target.next_extent = db_objects->object[i].source.next_extent
   ELSE
    SET db_objects->object[i].target.next_extent = (ceil(((db_objects->object[i].object_size_adjusted
      * dm_create_schema->percent_next_extent)/ db_block_size)) * db_block_size)
   ENDIF
   IF ((db_objects->object[i].target.initial_extent < (2 * db_block_size)))
    SET db_objects->object[i].target.initial_extent = (2 * db_block_size)
   ENDIF
   IF ((db_objects->object[i].target.next_extent < (2 * db_block_size)))
    SET db_objects->object[i].target.next_extent = (2 * db_block_size)
   ENDIF
   IF ((db_objects->object[i].object_size_adjusted <= db_objects->object[i].target.initial_extent))
    SET db_objects->object[i].object_size_adjusted = (ceil((db_objects->object[i].target.
     initial_extent/ db_5block_size)) * db_5block_size)
   ELSE
    SET size_from_next_extents = (db_objects->object[i].object_size_adjusted - db_objects->object[i].
    target.initial_extent)
    SET size_from_next_extents = (ceil((size_from_next_extents/ db_objects->object[i].target.
     next_extent)) * db_objects->object[i].target.next_extent)
    SET db_objects->object[i].object_size_adjusted = ((ceil((db_objects->object[i].target.
     initial_extent/ db_5block_size)) * db_5block_size)+ size_from_next_extents)
   ENDIF
   SET db_objects->target.total_allocated = (db_objects->target.total_allocated+ db_objects->object[i
   ].object_size_adjusted)
   SET found = 0
   FOR (j = 1 TO db_tspace->tspace_count)
     IF ((db_tspace->tspace[j].tspace_name=db_objects->object[i].object_tablespace))
      SET found = 1
      SET db_tspace->tspace[j].tspace_size = (db_tspace->tspace[j].tspace_size+ db_objects->object[i]
      .object_size_adjusted)
     ENDIF
   ENDFOR
   IF (found=0)
    SET db_tspace->tspace_count = (db_tspace->tspace_count+ 1)
    SET stat = alterlist(db_tspace->tspace,db_tspace->tspace_count)
    SET db_tspace->tspace[db_tspace->tspace_count].tspace_name = db_objects->object[i].
    object_tablespace
    SET db_tspace->tspace[db_tspace->tspace_count].tspace_size = db_objects->object[i].
    object_size_adjusted
   ENDIF
 ENDFOR
 IF ((dm_create_schema->all_tablespaces=0))
  IF (validate(dm_debug,0) > 0)
   CALL echo("Produce the parfile for exporting")
  ENDIF
  SELECT INTO "dm_create_schema.parfile"
   tn = trim(dt.table_name)
   FROM user_tables dt,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (dt
    WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   ORDER BY dt.table_name
   HEAD REPORT
    "constraints=N", row + 1, "indexes=N",
    row + 1, "tables=(", row + 1,
    cnt = 0
   DETAIL
    IF (cnt > 0)
     ",", row + 1
    ENDIF
    cnt = (cnt+ 1), str->str = tn, str->str
   FOOT REPORT
    row + 1, ")"
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (validate(dm_debug,0) > 0)
   CALL echo("Produce the parfile for importing")
  ENDIF
  SELECT INTO "dm_create_schema.parfile2"
   dt.table_name
   FROM user_tables dt,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (dt
    WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   ORDER BY dt.table_name
   HEAD REPORT
    "indexes=N", row + 1, "buffer=100000",
    row + 1, "ignore=Y", row + 1,
    "tables=(", row + 1, cnt = 0
   DETAIL
    IF (cnt > 0)
     ",", row + 1
    ENDIF
    cnt = (cnt+ 1), str->str = dt.table_name, str->str
   FOOT REPORT
    row + 1, ")"
   WITH nocounter, formfeed = none, format = stream
  ;end select
  SELECT INTO "dm_create_schema.rename"
   tn = trim(dt.table_name), target_tn = trim(substring(1,25,dt.table_name))
   FROM user_tables dt,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (dt
    WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   ORDER BY dt.table_name
   DETAIL
    "rdb rename ", tn, " to temp_",
    target_tn, " go", row + 1,
    'oragen3 "temp_', target_tn, '" go',
    row + 1
   WITH nocounter
  ;end select
  SELECT INTO "dm_create_schema.unrename"
   tn = trim(dt.table_name), target_tn = trim(substring(1,25,dt.table_name))
   FROM user_tables dt,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (dt
    WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   ORDER BY dt.table_name
   DETAIL
    "rdb rename temp_", target_tn, " to ",
    tn, " go", row + 1
   WITH nocounter
  ;end select
  SELECT INTO "dm_create_schema.row_cnt1"
   tn = trim(dt.table_name), target_tn = trim(substring(1,25,dt.table_name))
   FROM user_tables dt,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (dt
    WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   ORDER BY dt.table_name
   HEAD REPORT
    "record dm_check", row + 1, "(",
    row + 1, "1 tlist[*]", row + 1,
    "2 tname = vc", row + 1, "1 tcount=i4",
    row + 1, "1 tmode=i4", row + 1,
    ") go", row + 2, "set dm_check->tcount=0 go",
    row + 1, "set dm_check->tmode=1 go", row + 1
   DETAIL
    "set dm_check->tcount=dm_check->tcount+1 go", row + 1,
    "set stat=alterlist(dm_check->tlist, dm_check->tcount) go",
    row + 1, 'set dm_check->tlist[dm_check->tcount]->tname = "', tn,
    '" go', row + 1
   FOOT REPORT
    "execute dm_check_row_counts go", row + 1
   WITH nocounter
  ;end select
  SELECT INTO "dm_create_schema.row_cnt2"
   tn = trim(dt.table_name), target_tn = trim(substring(1,25,dt.table_name))
   FROM user_tables dt,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (dt
    WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   ORDER BY dt.table_name
   HEAD REPORT
    "record dm_check", row + 1, "(",
    row + 1, "1 tlist[*]", row + 1,
    "2 tname = vc", row + 1, "1 tcount=i4",
    row + 1, "1 tmode=i4", row + 1,
    ") go", row + 2, "set dm_check->tcount=0 go",
    row + 1, "set dm_check->tmode=2 go", row + 1
   DETAIL
    "set dm_check->tcount=dm_check->tcount+1 go", row + 1,
    "set stat=alterlist(dm_check->tlist, dm_check->tcount) go",
    row + 1, 'set dm_check->tlist[dm_check->tcount]->tname = "', tn,
    '" go', row + 1
   FOOT REPORT
    "execute dm_check_row_counts go", row + 1
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "dm_create_schema.drop_cons"
   ducc.r_constraint_name, ducc.table_name, ducc.constraint_name
   FROM dm_user_cons_columns ducc,
    (dummyt d  WITH seq = value(db_objects->object_count))
   PLAN (d)
    JOIN (ducc
    WHERE (ducc.r_constraint_name=db_objects->object[d.seq].object_name))
   ORDER BY ducc.table_name, ducc.constraint_name
   DETAIL
    "rdb alter table ", ducc.table_name, row + 1,
    "   drop constraint ", ducc.constraint_name, " go",
    row + 2
   WITH nocounter, maxcol = 300, formfeed = none,
    maxrow = 1
  ;end select
  SELECT DISTINCT INTO "dm_create_schema.drop_cons"
   ducc.r_constraint_name, ducc.table_name, ducc.constraint_name
   FROM dm_user_cons_columns ducc,
    (dummyt d  WITH seq = value(db_objects->object_count))
   PLAN (d)
    JOIN (ducc
    WHERE (ducc.constraint_name=db_objects->object[d.seq].object_name))
   ORDER BY ducc.table_name, ducc.constraint_name
   DETAIL
    "rdb alter table ", ducc.table_name, row + 1,
    "   drop constraint ", ducc.constraint_name, " go",
    row + 2
   WITH nocounter, maxcol = 300, formfeed = none,
    maxrow = 1, append
  ;end select
  SET temp = fillstring(255," ")
  SELECT INTO "dm_create_schema.drop_tspace"
   d.*
   FROM (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
   ORDER BY dm_create_schema->tspace_list[d.seq].tspace_name
   HEAD REPORT
    "/*", row + 1
   DETAIL
    "rdb drop tablespace ", dm_create_schema->tspace_list[d.seq].tspace_name, row + 1,
    "   including contents cascade constraints go", row + 2
   FOOT REPORT
    "*/", row + 1
   WITH nocounter, formfeed = none, maxrow = 1
  ;end select
  SELECT INTO "dm_create_schema.del_tfiles"
   dt.*
   FROM dba_data_files dt,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (dt
    WHERE (dt.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   ORDER BY dt.tablespace_name
   DETAIL
    IF (system != "AIX")
     temp = build(dt.file_name,";*"), "$!delete ", temp,
     row + 2
    ELSE
     temp = substring(7,textlen(dt.file_name),dt.file_name), "#rmlv -f ", temp,
     row + 2
    ENDIF
   WITH nocounter, maxcol = 300, formfeed = none,
    maxrow = 1
  ;end select
 ELSE
  SELECT INTO "dm_create_schema.parfile3"
   FROM dual d
   DETAIL
    "constraints=N", row + 1, "indexes=N",
    row + 1, "owner = ", currdbuser,
    row + 1
   WITH nocounter, formfeed = none, format = stream
  ;end select
  SELECT INTO "dm_create_schema.parfile4"
   FROM dual d
   DETAIL
    "indexes=N", row + 1, "buffer=100000",
    row + 1, "ignore=Y", row + 1,
    "commit=Y", row + 1, "full=Y",
    row + 1
   WITH nocounter, formfeed = none, format = stream
  ;end select
 ENDIF
 SELECT INTO "dm_create_schema.parfile5"
  FROM dual d
  DETAIL
   "data=N", row + 1, "owner=",
   currdbuser, row + 1
  WITH nocounter, formfeed = none, format = stream
 ;end select
 SELECT INTO "dm_create_schema.drop_tables"
  db_objects->object[d.seq].object_name
  FROM (dummyt d  WITH seq = value(db_objects->object_count))
  PLAN (d
   WHERE (db_objects->object[d.seq].object_type="TABLE"))
  ORDER BY db_objects->object[d.seq].object_name
  HEAD REPORT
   "/*", row + 2
  DETAIL
   "rdb drop table ", db_objects->object[d.seq].object_name, row + 1,
   "   cascade constraints go", row + 2
  FOOT REPORT
   "*/", row + 2
  WITH nocounter, formfeed = none, maxrow = 1
 ;end select
 SET temp_tspace_size = 0.0
 DELETE  FROM dm_env_files def
  WHERE (def.environment_id=dm_create_schema->environment_id)
   AND def.file_type IN ("DATA", "INDEX")
  WITH nocounter
 ;end delete
 COMMIT
 IF (curqual != 0)
  CALL echo("File size info deleted for passed environment.")
 ENDIF
 DELETE  FROM dm_env_table def
  WHERE (def.environment_id=dm_create_schema->environment_id)
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM dm_env_index def
  WHERE (def.environment_id=dm_create_schema->environment_id)
  WITH nocounter
 ;end delete
 COMMIT
 IF (validate(dm_debug,0) > 0)
  CALL echo("calculate the starting size sequence")
 ENDIF
 RECORD file_sizes(
   1 scount = i4
   1 sizes[*]
     2 size = f8
     2 size_seq = f8
 )
 SET file_sizes->scount = 0
 SET db_length = size(trim(database_name),1)
 IF (system="AIX")
  IF ((dm_create_schema->all_tablespaces=0))
   IF (validate(dm_debug,0) > 0)
    CALL echo("AIX, dm_create_schema->all_tablespaces=0")
   ENDIF
   SET dclcom = build("ls /dev/r",cnvtlower(database_name),"_*  >vol_out.dat")
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
   SET sb_length = (db_length+ 8)
   SET ss_length = (sb_length+ 5)
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc "vol_out.dat"
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     size_found = 0, size_bytes = ((cnvtint(substring(sb_length,4,r.line)) - 1) * mbytes), size_seq
      = cnvtint(substring(ss_length,3,r.line))
     FOR (i = 1 TO file_sizes->scount)
       IF ((size_bytes=file_sizes->sizes[i].size))
        IF ((file_sizes->sizes[i].size_seq < size_seq)
         AND size_seq < 900)
         file_sizes->sizes[i].size_seq = size_seq
        ENDIF
        size_found = 1
       ENDIF
     ENDFOR
     IF (size_found=0)
      file_sizes->scount = (file_sizes->scount+ 1)
      IF (mod(file_sizes->scount,10)=1)
       stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
      ENDIF
      file_sizes->sizes[file_sizes->scount].size = size_bytes, file_sizes->sizes[file_sizes->scount].
      size_seq = size_seq
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   IF (validate(dm_debug,0) > 0)
    CALL echo("AIX, dm_create_schema->all_tablespaces != 0")
   ENDIF
   SET sb_length = (db_length+ 2)
   SET ss_length = (sb_length+ 5)
   SELECT INTO "nl:"
    derl.log_size
    FROM dm_env_redo_logs derl
    WHERE (derl.environment_id=dm_create_schema->environment_id)
    DETAIL
     size_found = 0, size_seq = cnvtint(substring(ss_length,3,derl.file_name))
     FOR (i = 1 TO file_sizes->scount)
       IF ((derl.log_size=file_sizes->sizes[i].size))
        IF ((size_seq > file_sizes->sizes[i].size_seq)
         AND size_seq < 900)
         file_sizes->sizes[i].size_seq = size_seq
        ENDIF
        size_found = 1
       ENDIF
     ENDFOR
     IF (size_found=0)
      file_sizes->scount = (file_sizes->scount+ 1)
      IF (mod(file_sizes->scount,10)=1)
       stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
      ENDIF
      file_sizes->sizes[file_sizes->scount].size = derl.log_size, file_sizes->sizes[file_sizes->
      scount].size_seq = size_seq
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    decf.file_size
    FROM dm_env_control_files decf
    WHERE (decf.environment_id=dm_create_schema->environment_id)
    DETAIL
     size_found = 0, size_seq = cnvtint(substring(ss_length,3,decf.file_name))
     FOR (i = 1 TO file_sizes->scount)
       IF ((decf.file_size=file_sizes->sizes[i].size))
        IF ((size_seq > file_sizes->sizes[i].size_seq)
         AND size_seq < 900)
         file_sizes->sizes[i].size_seq = size_seq
        ENDIF
        size_found = 1
       ENDIF
     ENDFOR
     IF (size_found=0)
      file_sizes->scount = (file_sizes->scount+ 1)
      IF (mod(file_sizes->scount,10)=1)
       stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
      ENDIF
      file_sizes->sizes[file_sizes->scount].size = decf.file_size, file_sizes->sizes[file_sizes->
      scount].size_seq = size_seq
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    def.file_size
    FROM dm_env_files def
    WHERE (def.environment_id=dm_create_schema->environment_id)
     AND  NOT (def.file_type IN ("DATA", "INDEX"))
    DETAIL
     size_found = 0, size_seq = cnvtint(substring(ss_length,3,def.file_name))
     FOR (i = 1 TO file_sizes->scount)
       IF ((def.file_size=file_sizes->sizes[i].size))
        IF ((size_seq > file_sizes->sizes[i].size_seq)
         AND size_seq < 900)
         file_sizes->sizes[i].size_seq = size_seq
        ENDIF
        size_found = 1
       ENDIF
     ENDFOR
     IF (size_found=0)
      file_sizes->scount = (file_sizes->scount+ 1)
      IF (mod(file_sizes->scount,10)=1)
       stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
      ENDIF
      file_sizes->sizes[file_sizes->scount].size = def.file_size, file_sizes->sizes[file_sizes->
      scount].size_seq = size_seq
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((dm_create_schema->all_tablespaces=0))
  SELECT INTO "nl:"
   ddf.tablespace_name, y = sum(ddf.bytes)
   FROM dba_data_files ddf,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count))
   PLAN (d)
    JOIN (ddf
    WHERE (ddf.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
   GROUP BY ddf.tablespace_name
   ORDER BY ddf.tablespace_name
   DETAIL
    db_tspace->tspace_total_source = (db_tspace->tspace_total_source+ y)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   ddf.tablespace_name, y = sum(ddf.bytes)
   FROM dba_data_files ddf,
    (dummyt d  WITH seq = value(db_tspace->tspace_count))
   PLAN (d)
    JOIN (ddf
    WHERE (ddf.tablespace_name=db_tspace->tspace[d.seq].tspace_name))
   GROUP BY ddf.tablespace_name
   ORDER BY ddf.tablespace_name
   HEAD REPORT
    db_tspace->tspace_total_source = 0.0
   DETAIL
    IF ((dm_create_schema->preserve_source_tspace_size=1))
     db_tspace->tspace[d.seq].tspace_size = y
    ENDIF
    db_tspace->tspace_total_source = (db_tspace->tspace_total_source+ y)
   WITH nocounter
  ;end select
 ENDIF
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
 FOR (kount = 1 TO db_tspace->tspace_count)
   SET row_count = 1
   SET db_tspace->tspace[kount].tspace_size = (db_tspace->tspace[kount].tspace_size *
   dm_create_schema->percent_tspace)
   SET db_tspace->tspace[kount].partitioned_bytes = (ceil((db_tspace->tspace[kount].tspace_size/
    partition_size)) * partition_size)
   SET total_size = db_tspace->tspace[kount].partitioned_bytes
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
      SET tspace_files->tname[tspace_files->fcount].size = (raw_size - mbytes)
     ELSE
      SET tspace_files->tname[tspace_files->fcount].size = raw_size
     ENDIF
     SET db_tspace->tspace_total_target = (db_tspace->tspace_total_target+ tspace_files->tname[
     tspace_files->fcount].size)
     SET tspace_files->tname[tspace_files->fcount].raw_size = raw_size
     SET tspace_files->tname[tspace_files->fcount].tspace_name = db_tspace->tspace[kount].tspace_name
     IF (system="AIX")
      SET size_found = 0
      FOR (i = 1 TO file_sizes->scount)
        IF (((raw_size - mbytes)=file_sizes->sizes[i].size))
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
       SET file_sizes->sizes[file_sizes->scount].size = (raw_size - mbytes)
       SET file_sizes->sizes[file_sizes->scount].size_seq = 1
       SET tspace_files->tname[tspace_files->fcount].size_seq = 1
      ENDIF
     ENDIF
     SET fname = fillstring(80," ")
     SET file_seq = format(cnvtstring(row_count),"###;P0")
     IF (system="AIX")
      SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024 * 1024))),
        "####;P0"),"_",format(cnvtstring(tspace_files->tname[tspace_files->fcount].size_seq),"###;P0"
        ))
     ELSE
      SET fname = build(db_tspace->tspace[kount].tspace_name,"_",file_seq)
     ENDIF
     SET row_count = (row_count+ 1)
     SET tspace_files->tname[tspace_files->fcount].fname = fname
     SELECT INTO "nl:"
      FROM dm_tablespace dt
      WHERE (dt.tablespace_name=tspace_files->tname[tspace_files->fcount].tspace_name)
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM dm_tablespace dt
       SET dt.initial_extent = ((16 * 1024) * 1024), dt.next_extent = ((16 * 1024) * 1024), dt
        .pctincrease = 0,
        dt.tablespace_name = tspace_files->tname[tspace_files->fcount].tspace_name
       WITH nocounter
      ;end insert
     ENDIF
     INSERT  FROM dm_env_files def
      SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
       def.updt_id = 0, def.updt_task = 0, def.file_type =
       IF (substring(1,1,tspace_files->tname[tspace_files->fcount].tspace_name)="I") "INDEX"
       ELSE "DATA"
       ENDIF
       ,
       def.file_size = tspace_files->tname[tspace_files->fcount].size, def.tablespace_exist_ind = 0,
       def.size_sequence = tspace_files->tname[tspace_files->fcount].size_seq,
       def.environment_id = dm_create_schema->environment_id, def.tablespace_name = tspace_files->
       tname[tspace_files->fcount].tspace_name, def.file_name = tspace_files->tname[tspace_files->
       fcount].fname
      WITH nocounter
     ;end insert
   ENDWHILE
 ENDFOR
 COMMIT
 SELECT
  IF ((dm_create_schema->all_tablespaces=0))
   uic.column_name, uic.data_type, uic.data_length,
   uic.nullable, uic.column_id, tspace_name = dm_create_schema->tspace_list[d.seq].new_tspace_name,
   tname = uic.table_name, default_value = substring(1,110,trim(uic.data_default)), init = db_objects
   ->object[d2.seq].target.initial_extent,
   next_e = db_objects->object[d2.seq].target.next_extent
   FROM dm_user_tab_cols uic,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count)),
    (dummyt d2  WITH seq = value(db_objects->object_count))
   PLAN (d)
    JOIN (uic
    WHERE (uic.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
    JOIN (d2
    WHERE (db_objects->object[d2.seq].object_name=uic.table_name))
  ELSE
   uic.column_name, uic.data_type, uic.data_length,
   uic.nullable, uic.column_id, tspace_name = uic.tablespace_name,
   tname = uic.table_name, default_value = substring(1,110,trim(uic.data_default)), init = db_objects
   ->object[d.seq].target.initial_extent,
   next_e = db_objects->object[d.seq].target.next_extent
   FROM dm_user_tab_cols uic,
    (dummyt d  WITH seq = value(db_objects->object_count))
   PLAN (d
    WHERE (db_objects->object[d.seq].object_type="TABLE"))
    JOIN (uic
    WHERE (db_objects->object[d.seq].object_name=uic.table_name))
  ENDIF
  INTO "dm_create_schema.table"
  ORDER BY tname, uic.column_id
  HEAD REPORT
   "%d echo", row + 1, "set trace rdbdebug go",
   row + 1, "%o dm_create_schema4.table", row + 1,
   "select into 'dm_create_schema3.table' d.* from dual d", row + 1, "detail",
   row + 1, "'dm_create_schema.table Error Log', row+1", row + 1,
   "with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1 go", row + 1,
   "set msg=fillstring(255,' ') go",
   row + 1, "set msgnum=0 go", row + 1
  HEAD tname
   "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "rdb CREATE TABLE ",
   tname, row + 1, "("
  DETAIL
   IF (uic.column_id > 1)
    ","
   ENDIF
   row + 1, uic.column_name, " ",
   uic.data_type
   IF (uic.data_type IN ("VARCHAR2", "VARCHAR", "CHAR", "RAW"))
    "(", uic.data_length"####;;I", ")"
   ENDIF
   IF (default_value != fillstring(110," "))
    row + 1, " DEFAULT ", default_value,
    row + 1
   ENDIF
   IF (uic.nullable="N")
    " NOT NULL"
   ENDIF
  FOOT  tname
   row + 1, ")", row + 1,
   "TABLESPACE ", tspace_name, row + 1,
   extent_size = init, next_extent_size = next_e
   IF (extent_size > 10240)
    tempstr = concat(" STORAGE ( INITIAL ",cnvtstring((extent_size/ 1024)),"K")
   ELSE
    tempstr = concat(" STORAGE ( INITIAL ",cnvtstring(extent_size))
   ENDIF
   IF (next_extent_size > 10240)
    tempstr2 = concat(trim(tempstr)," NEXT ",cnvtstring((next_extent_size/ 1024)),"K)")
   ELSE
    tempstr2 = concat(trim(tempstr)," NEXT ",cnvtstring(next_extent_size),")")
   ENDIF
   tempstr2, row + 1, "go",
   row + 3, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1,
   "select if (msg!=' ')", row + 1, "   into 'dm_create_schema3.table' d.* from dual d",
   row + 1, "   detail", row + 1,
   "       'Error occurred in create table ", tname, "       ', row+1",
   row + 1, "       msg, row+3", row + 1,
   "   with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1, append", row + 1,
   "else",
   row + 1, "   into 'nl:' d.* from dual d with nocounter", row + 1,
   "endif go", row + 1, "execute oragen3 '",
   tname, "' go", row + 2
  FOOT REPORT
   IF ((dm_create_schema->all_tablespaces=0))
    "execute dm_user_last_updt go", row + 2
   ENDIF
   "%o", row + 1, "set trace nordbdebug go",
   row + 1
  WITH format = stream, formfeed = none
 ;end select
 SET tspace_name = fillstring(32," ")
 SET i_name = fillstring(32," ")
 SELECT
  IF ((dm_create_schema->all_tablespaces=0))
   uic.column_name, uic.column_position, tspace_name = dm_create_schema->tspace_list[d.seq].
   new_tspace_name,
   tname = uic.table_name, i_name = uic.index_name, i_unique = uic.uniqueness,
   init = db_objects->object[d2.seq].target.initial_extent, next_e = db_objects->object[d2.seq].
   target.next_extent
   FROM dm_user_ind_columns uic,
    (dummyt d  WITH seq = value(dm_create_schema->tspace_count)),
    (dummyt d2  WITH seq = value(db_objects->object_count))
   PLAN (d)
    JOIN (uic
    WHERE (uic.tablespace_name=dm_create_schema->tspace_list[d.seq].tspace_name))
    JOIN (d2
    WHERE (db_objects->object[d2.seq].object_name=uic.index_name))
  ELSE
   uic.column_name, uic.column_position, tspace_name = uic.tablespace_name,
   tname = uic.table_name, init = db_objects->object[d.seq].target.initial_extent, next_e =
   db_objects->object[d.seq].target.next_extent,
   i_name = uic.index_name, i_unique = uic.uniqueness
   FROM dm_user_ind_columns uic,
    (dummyt d  WITH seq = value(db_objects->object_count))
   PLAN (d
    WHERE (db_objects->object[d.seq].object_type="INDEX"))
    JOIN (uic
    WHERE (db_objects->object[d.seq].object_name=uic.index_name))
  ENDIF
  INTO "dm_create_schema.index"
  ORDER BY uic.table_name, uic.index_name, uic.column_position
  HEAD REPORT
   "%d echo", row + 1, "set trace rdbdebug go",
   row + 1, "%o dm_create_schema4.index", row + 1,
   "select into 'dm_create_schema3.index' d.* from dual d", row + 1, "detail",
   row + 1, "'dm_create_schema.index Error Log', row+1", row + 1,
   "with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1 go", row + 1,
   "set msg=fillstring(255,' ') go",
   row + 1, "set msgnum=0 go", row + 1
  HEAD i_name
   "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "rdb CREATE "
   IF (i_unique="UNIQUE")
    "UNIQUE "
   ENDIF
   " INDEX ", i_name, " on ",
   tname, row + 1, "("
  DETAIL
   IF (uic.column_position > 1)
    ","
   ENDIF
   row + 1, uic.column_name
  FOOT  i_name
   row + 1, ")", row + 1,
   "TABLESPACE ", tspace_name, row + 1,
   extent_size = init, next_extent_size = next_e
   IF (extent_size > 10240)
    tempstr = concat(" STORAGE ( INITIAL ",cnvtstring((extent_size/ 1024)),"K")
   ELSE
    tempstr = concat(" STORAGE ( INITIAL ",cnvtstring(extent_size))
   ENDIF
   IF (next_extent_size > 10240)
    tempstr2 = concat(trim(tempstr)," NEXT ",cnvtstring((next_extent_size/ 1024)),"K)")
   ELSE
    tempstr2 = concat(trim(tempstr)," NEXT ",cnvtstring(next_extent_size),")")
   ENDIF
   tempstr2, row + 1, " UNRECOVERABLE",
   row + 1, "go", row + 2,
   "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "select if (msg!=' ')",
   row + 1, "   into 'dm_create_schema3.index' d.* from dual d", row + 1,
   "   detail", row + 1, "       'Error occurred in create index ",
   i_name, "       ', row+1", row + 1,
   "       msg, row+3", row + 1,
   "   with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1, append",
   row + 1, "else", row + 1,
   "   into 'nl:' d.* from dual d with nocounter", row + 1, "endif go",
   row + 1
  FOOT REPORT
   IF ((dm_create_schema->all_tablespaces=0))
    "execute dm_user_last_updt go", row + 2
   ENDIF
   "%o", row + 1, "set trace nordbdebug go",
   row + 1
  WITH format = stream, formfeed = none
 ;end select
 SELECT
  IF ((dm_create_schema->all_tablespaces=0))
   FROM dm_user_cons_columns c,
    (dummyt d  WITH seq = value(db_objects->object_count))
   PLAN (d)
    JOIN (c
    WHERE c.constraint_type IN ("P", "U")
     AND ((c.constraint_name=trim(db_objects->object[d.seq].object_name)) OR (c.table_name=trim(
     db_objects->object[d.seq].object_name))) )
  ELSE
   FROM dm_user_cons_columns c
   WHERE c.constraint_type IN ("P", "U")
  ENDIF
  DISTINCT INTO "dm_create_schema.primarykey"
  c.column_name, c.position, b.table_name,
  c.constraint_name, c.status, c.constraint_type
  ORDER BY c.table_name, c.constraint_name, c.position
  HEAD REPORT
   "%d echo", row + 1, "set trace rdbdebug go",
   row + 1, "%o dm_create_schema4.primarykey", row + 1,
   "select into 'dm_create_schema3.primarykey' d.* from dual d", row + 1, "detail",
   row + 1, "'dm_create_schema.primarykey Error Log', row+1", row + 1,
   "with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1 go", row + 1,
   "set msg=fillstring(255,' ') go",
   row + 1, "set msgnum=0 go", row + 1
  HEAD c.constraint_name
   "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "RDB ALTER TABLE ",
   c.table_name, row + 1, " ADD CONSTRAINT ",
   c.constraint_name, row + 1
   IF (c.constraint_type="P")
    " PRIMARY KEY ("
   ELSE
    " UNIQUE ("
   ENDIF
  HEAD c.position
   IF (c.position > 1)
    ","
   ENDIF
   row + 1, c.column_name
  FOOT  c.constraint_name
   row + 1, ")", row + 1
   IF (c.status="DISABLED")
    " DISABLE"
   ENDIF
   row + 1, "go", row + 2,
   "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "select if (msg!=' ')",
   row + 1, "   into 'dm_create_schema3.primarykey' d.* from dual d", row + 1,
   "   detail", row + 1, "       'Error occurred in create primary key ",
   c.constraint_name, "       ', row+1", row + 1,
   "       msg, row+3", row + 1,
   "   with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1, append",
   row + 1, "else", row + 1,
   "   into 'nl:' d.* from dual d with nocounter", row + 1, "endif go",
   row + 1
  FOOT REPORT
   IF ((dm_create_schema->all_tablespaces=0))
    "execute dm_user_last_updt go", row + 2
   ENDIF
   "%o", row + 1, "set trace nordbdebug go",
   row + 1
  WITH format = stream, noheading, formfeed = none
 ;end select
 SELECT
  IF ((dm_create_schema->all_tablespaces=0))
   FROM dm_user_cons_columns c,
    (dummyt d  WITH seq = value(db_objects->object_count))
   PLAN (d)
    JOIN (c
    WHERE c.constraint_type="R"
     AND ((c.table_name=trim(db_objects->object[d.seq].object_name)) OR (((c.parent_table_name=trim(
     db_objects->object[d.seq].object_name)) OR (c.r_constraint_name=trim(db_objects->object[d.seq].
     object_name))) )) )
  ELSE
   FROM dm_user_cons_columns c
   WHERE c.constraint_type="R"
  ENDIF
  DISTINCT INTO "dm_create_schema.foreignkey"
  c.column_name, c.position, c.table_name,
  c.constraint_name, c.parent_table_name, c.status
  ORDER BY c.table_name, c.constraint_name, c.position
  HEAD REPORT
   "%d echo", row + 1, "set trace rdbdebug go",
   row + 1, "%o dm_create_schema4.foreignkey", row + 1,
   "select into 'dm_create_schema3.foreignkey' d.* from dual d", row + 1, "detail",
   row + 1, "'dm_create_schema.foreignkey Error Log', row+1", row + 1,
   "with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1 go", row + 1,
   "set msg=fillstring(255,' ') go",
   row + 1, "set msgnum=0 go", row + 1
  HEAD c.constraint_name
   "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "RDB ALTER TABLE ",
   c.table_name, row + 1, " ADD CONSTRAINT ",
   c.constraint_name, row + 1, " FOREIGN KEY ("
  HEAD c.position
   IF (c.position > 1)
    ","
   ENDIF
   row + 1, c.column_name
  FOOT  c.constraint_name
   row + 1, ")", row + 1,
   "REFERENCES ", c.parent_table_name
   IF (c.status="DISABLED")
    " DISABLE"
   ENDIF
   row + 1, "go", row + 2,
   "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "select if (msg!=' ')",
   row + 1, "   into 'dm_create_schema3.foreignkey' d.* from dual d", row + 1,
   "   detail", row + 1, "       'Error occurred in create foreign key ",
   c.constraint_name, "       ', row+1", row + 1,
   "       msg, row+3", row + 1,
   "   with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1, append",
   row + 1, "else", row + 1,
   "   into 'nl:' d.* from dual d with nocounter", row + 1, "endif go",
   row + 1
  FOOT REPORT
   IF ((dm_create_schema->all_tablespaces=0))
    "execute dm_user_last_updt go", row + 2
   ENDIF
   "%o", row + 1, "set trace nordbdebug go",
   row + 1
  WITH format = stream, noheading, formfeed = none
 ;end select
 CALL echo(" ")
 CALL echo(" ")
 CALL echo(concat("Total space used by tablespaces in source ",cnvtstring(db_tspace->
    tspace_total_source)))
 CALL echo(concat("Total allocated space by objects in source ",cnvtstring(db_objects->source.
    total_allocated)))
 CALL echo(concat("Total used space by objects in source ",cnvtstring(db_objects->source.total_used))
  )
 CALL echo(" ")
 SET dm_create_schema->source_tspace_allocated = db_tspace->tspace_total_source
 SET dm_create_schema->source_space_allocated = db_objects->source.total_allocated
 SET dm_create_schema->source_space_used = db_objects->source.total_used
 SET dm_create_schema->target_tspace_allocated = db_tspace->tspace_total_target
 SET dm_create_schema->target_space_allocated = db_objects->target.total_allocated
 CALL echo(concat("Total space used by tablespaces in target ",cnvtstring(db_tspace->
    tspace_total_target)))
 CALL echo(concat("Total allocated space by objects in target ",cnvtstring(db_objects->target.
    total_allocated)))
#end_prg
END GO
