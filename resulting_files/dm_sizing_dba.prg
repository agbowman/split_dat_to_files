CREATE PROGRAM dm_sizing:dba
 SET block_size = 0.0
 SET s_rep_seq = start_rep
 SET e_rep_seq = end_rep
 IF (( $1 != 1)
  AND ( $1 != 2))
  CALL echo("The first parameter can be 1 0r 2 only")
 ENDIF
 SET partition_size = 0.0
 SET max_size = 0.0
 SET mbyte = (1024.0 * 1024.0)
 SET target_operating_system = fillstring(3," ")
 SET database_name = fillstring(6," ")
 SET root_dir_name = fillstring(80," ")
 SET disk_name = fillstring(30," ")
 SET total_size = 0.0
 SET filename1 = "ddl_object_alt1"
 SET filename2 = "ddl_object_alt2"
 SELECT INTO value(filename1)
  d.*
  FROM dual d
  DETAIL
   "select into ", filename2, " d.* from dual d",
   row + 1, "detail", row + 1,
   "'DDL_OBJECT_ALT Error Log', row+1", row + 1,
   "with  format = stream, noheading, formfeed = NONE, maxcol=512, maxrow=1 go",
   row + 1, "set msg=fillstring(255,' ') go", row + 1,
   "set msgnum=0 go", row + 1, "select into 'nl:' msgnum=error(msg,1) with nocounter go",
   row + 1
  WITH format = stream, noheading, maxcol = 512,
   maxrow = 1, formfeed = none
 ;end select
 SELECT INTO "nl:"
  a.environment_id, a.environment_name, a.database_name,
  a.data_file_partition_size, a.max_file_size, a.target_operating_system,
  a.root_dir_name, a.disk_name
  FROM dm_environment a
  WHERE a.environment_id=env_id
  DETAIL
   partition_size = a.data_file_partition_size, database_name = a.database_name, max_size = (a
   .max_file_size * mbyte),
   target_operating_system = a.target_operating_system, root_dir_name = a.root_dir_name
  WITH nocounter
 ;end select
 FREE SET tablespace_list
 RECORD tablespace_list(
   1 tablespace[*]
     2 e_rep_seq = i4
     2 s_rep_seq = i4
     2 instance_cd = i4
     2 tablespace_name = c30
     2 space_allocated = f8
     2 space_to_add = f8
     2 new_space_to_add = f8
     2 free_space = f8
     2 used_space = f8
     2 prev_used_space = f8
     2 space_over_allocated = f8
     2 space_consumed = f8
     2 space_consumed_daily = f8
     2 days_till_full = f8
     2 new_days_till_full = f8
     2 days_remaining = f8
     2 partitioned_bytes = f8
     2 exist_tablespace_ind = i4
     2 initial_extent = f8
     2 next_extent = f8
     2 pct_increase = f8
     2 object[*]
       3 tablespace_name = c30
       3 owner = c10
       3 object_name = c30
       3 object_type = c1
       3 instance_cd = f8
       3 sp_allocated = f8
       3 sp_total = f8
       3 sp_free = f8
       3 sp_used = f8
       3 sp_prev_used = f8
       3 sp_consumed = f8
       3 sp_consumed_daily = f8
       3 space_to_add = f8
       3 new_space_to_add = f8
       3 over_allocated_space = f8
       3 bytes_per_day = f8
       3 days_till_full = f8
       3 new_days_till_full = f8
       3 days_next_extent = f8
       3 extents = i4
       3 next_extent = f8
       3 next_extent_bytes = f8
       3 pct_increase = i4
       3 row_count = f8
       3 dropped = i4
       3 created = i4
       3 migrated = i4
     2 object_count = i4
     2 object_number = i4
     2 extent[*]
       3 file_id = i4
       3 blocks = f8
     2 extent_count = i4
     2 file_count = i4
     2 new_file_count = i4
     2 new_file[*]
       3 file_name = c40
       3 size = f8
       3 raw_size = f8
       3 size_meg = i4
       3 file_seq = f8
       3 size_sequence = f8
   1 tablespace_count = i4
 )
 FREE SET tablespace_list1
 RECORD tablespace_list1(
   1 tablespace[*]
     2 tablespace_name = c30
     2 extent[*]
       3 file_id = i4
       3 blocks = f8
     2 extent_count = i4
   1 tablespace_count = i4
 )
 FREE SET object_list
 RECORD object_list(
   1 object[*]
     2 tablespace_name = c30
     2 tablespace_name_old = c30
     2 owner = c10
     2 object_name = c30
     2 object_type = c1
     2 instance_cd = f8
     2 sp_allocated = f8
     2 sp_total = f8
     2 sp_free = f8
     2 sp_used = f8
     2 sp_prev_used = f8
     2 sp_consumed = f8
     2 sp_consumed_daily = f8
     2 space_to_add = f8
     2 new_space_to_add = f8
     2 over_allocated_space = f8
     2 bytes_per_day = f8
     2 days_till_full = f8
     2 new_days_till_full = f8
     2 days_next_extent = f8
     2 extents = i4
     2 next_extent = f8
     2 next_extent_bytes = f8
     2 pct_increase = i4
     2 row_count = f8
     2 dropped = i4
     2 created = i4
     2 migrated = i4
   1 object_count = i4
 )
 FREE SET object_list_sorted
 RECORD object_list_sorted(
   1 object[*]
     2 tablespace_name = c30
     2 owner = c10
     2 object_name = c30
     2 object_type = c1
     2 instance_cd = f8
     2 sp_allocated = f8
     2 sp_total = f8
     2 sp_free = f8
     2 sp_used = f8
     2 sp_prev_used = f8
     2 sp_consumed = f8
     2 sp_consumed_daily = f8
     2 space_to_add = f8
     2 new_space_to_add = f8
     2 over_allocated_space = f8
     2 bytes_per_day = f8
     2 days_till_full = f8
     2 new_days_till_full = f8
     2 days_next_extent = f8
     2 extents = i4
     2 next_extent = f8
     2 next_extent_bytes = f8
     2 pct_increase = i4
     2 row_count = f8
     2 dropped = i4
     2 created = i4
     2 migrated = i4
   1 object_count = i4
 )
 SET stat = alterlist(tablespace_list->tablespace,10)
 SET tablespace_list->tablespace_count = 0
 SET stat = alterlist(object_list->object,10)
 SET object_list->object_count = 0
 SELECT INTO "nl:"
  FROM v$parameter v
  WHERE v.name="db_block_size"
  HEAD REPORT
   block_size = 0
  DETAIL
   block_size = cnvtint(v.value)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.report_seq, b.report_seq, a.instance_cd,
  b.instance_cd, a.segment_name, b.segment_name,
  a.segment_type, b.segment_type, a.owner,
  b.owner, a.tablespace_name, b.tablespace_name,
  a.free_space, b.free_space, a.total_space,
  b.total_space, a.next_extent, b.next_extent
  FROM space_objects a,
   space_objects b
  WHERE a.report_seq=e_rep_seq
   AND b.report_seq=outerjoin(s_rep_seq)
   AND outerjoin(a.instance_cd)=b.instance_cd
   AND outerjoin(a.owner)=b.owner
   AND outerjoin(a.segment_name)=b.segment_name
   AND outerjoin(a.segment_type)=b.segment_type
  ORDER BY a.tablespace_name, a.segment_type DESC, a.segment_name
  HEAD a.tablespace_name
   tablespace_list->tablespace_count = (tablespace_list->tablespace_count+ 1)
   IF (mod(tablespace_list->tablespace_count,10)=1
    AND (tablespace_list->tablespace_count != 1))
    stat = alterlist(tablespace_list->tablespace,(tablespace_list->tablespace_count+ 9))
   ENDIF
   tablespace_list->tablespace[tablespace_list->tablespace_count].tablespace_name = a.tablespace_name,
   tablespace_list->tablespace[tablespace_list->tablespace_count].e_rep_seq = a.report_seq,
   tablespace_list->tablespace[tablespace_list->tablespace_count].s_rep_seq = b.report_seq,
   tablespace_list->tablespace[tablespace_list->tablespace_count].instance_cd = a.instance_cd,
   tablespace_list->tablespace[tablespace_list->tablespace_count].space_to_add = 0.0, tablespace_list
   ->tablespace[tablespace_list->tablespace_count].new_space_to_add = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].space_allocated = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].free_space = 0.0, tablespace_list->
   tablespace[tablespace_list->tablespace_count].used_space = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].prev_used_space = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].space_consumed = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].free_space = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].space_consumed_daily = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].space_over_allocated = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].new_days_till_full = 0.0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].exist_tablespace_ind = 0,
   tablespace_list->tablespace[tablespace_list->tablespace_count].object_count = 0, tablespace_list->
   tablespace[tablespace_list->tablespace_count].object_number = 0,
   stat = alterlist(tablespace_list->tablespace[tablespace_list->tablespace_count].object,10)
  DETAIL
   object_list->object_count = (object_list->object_count+ 1)
   IF (mod(object_list->object_count,10)=1
    AND (object_list->object_count != 1))
    stat = alterlist(object_list->object,(object_list->object_count+ 9))
   ENDIF
   object_list->object[object_list->object_count].tablespace_name = a.tablespace_name, object_list->
   object[object_list->object_count].tablespace_name_old = b.tablespace_name, object_list->object[
   object_list->object_count].instance_cd = a.instance_cd,
   object_list->object[object_list->object_count].owner = a.owner, object_list->object[object_list->
   object_count].object_name = a.segment_name, object_list->object[object_list->object_count].
   object_type = a.segment_type,
   object_list->object[object_list->object_count].sp_total = a.total_space, object_list->object[
   object_list->object_count].sp_free = a.free_space, object_list->object[object_list->object_count].
   sp_used = (a.total_space - a.free_space),
   object_list->object[object_list->object_count].sp_allocated = 0.0, object_list->object[object_list
   ->object_count].next_extent = 0.0
   IF (((b.segment_name=null) OR (a.tablespace_name != b.tablespace_name)) )
    IF (b.segment_name=null)
     object_list->object[object_list->object_count].created = 1
    ELSE
     object_list->object[object_list->object_count].migrated = 1
    ENDIF
    object_list->object[object_list->object_count].sp_prev_used = 0.0, object_list->object[
    object_list->object_count].sp_consumed = 999999, object_list->object[object_list->object_count].
    sp_consumed_daily = 999999
   ELSE
    object_list->object[object_list->object_count].created = 0, object_list->object[object_list->
    object_count].sp_prev_used = (b.total_space - b.free_space), object_list->object[object_list->
    object_count].sp_consumed = (object_list->object[object_list->object_count].sp_used - object_list
    ->object[object_list->object_count].sp_prev_used),
    object_list->object[object_list->object_count].sp_consumed_daily = (object_list->object[
    object_list->object_count].sp_consumed/ i_days_of_actual_activity)
   ENDIF
   IF ((object_list->object[object_list->object_count].sp_consumed_daily > 0.0)
    AND (object_list->object[object_list->object_count].created=0)
    AND (object_list->object[object_list->object_count].migrated=0))
    object_list->object[object_list->object_count].days_till_full = floor((object_list->object[
     object_list->object_count].sp_free/ object_list->object[object_list->object_count].
     sp_consumed_daily)), tablespace_list->tablespace[tablespace_list->tablespace_count].object_count
     = (tablespace_list->tablespace[tablespace_list->tablespace_count].object_count+ 1)
    IF (mod(tablespace_list->tablespace[tablespace_list->tablespace_count].object_count,10)=1
     AND (tablespace_list->tablespace[tablespace_list->tablespace_count].object_count != 1))
     stat = alterlist(tablespace_list->tablespace[tablespace_list->tablespace_count].object,(
      tablespace_list->tablespace[tablespace_list->tablespace_count].object_count+ 9))
    ENDIF
    tablespace_list->tablespace[tablespace_list->tablespace_count].object[tablespace_list->
    tablespace[tablespace_list->tablespace_count].object_count].owner = a.owner, tablespace_list->
    tablespace[tablespace_list->tablespace_count].object[tablespace_list->tablespace[tablespace_list
    ->tablespace_count].object_count].object_name = a.segment_name, tablespace_list->tablespace[
    tablespace_list->tablespace_count].object[tablespace_list->tablespace[tablespace_list->
    tablespace_count].object_count].object_type = a.segment_type,
    tablespace_list->tablespace[tablespace_list->tablespace_count].object[tablespace_list->
    tablespace[tablespace_list->tablespace_count].object_count].sp_free = a.free_space,
    tablespace_list->tablespace[tablespace_list->tablespace_count].object[tablespace_list->
    tablespace[tablespace_list->tablespace_count].object_count].sp_used = object_list->object[
    object_list->object_count].sp_used, tablespace_list->tablespace[tablespace_list->tablespace_count
    ].object[tablespace_list->tablespace[tablespace_list->tablespace_count].object_count].
    sp_prev_used = object_list->object[object_list->object_count].sp_prev_used,
    tablespace_list->tablespace[tablespace_list->tablespace_count].object[tablespace_list->
    tablespace[tablespace_list->tablespace_count].object_count].sp_consumed = object_list->object[
    object_list->object_count].sp_consumed, tablespace_list->tablespace[tablespace_list->
    tablespace_count].object[tablespace_list->tablespace[tablespace_list->tablespace_count].
    object_count].sp_consumed_daily = object_list->object[object_list->object_count].
    sp_consumed_daily, tablespace_list->tablespace[tablespace_list->tablespace_count].
    space_consumed_daily = (tablespace_list->tablespace[tablespace_list->tablespace_count].
    space_consumed_daily+ object_list->object[object_list->object_count].sp_consumed_daily),
    CALL echo(concat("Space cons daily: ",cnvtstring(tablespace_list->tablespace[tablespace_list->
      tablespace_count].space_consumed_daily))), tablespace_list->tablespace[tablespace_list->
    tablespace_count].space_consumed = (tablespace_list->tablespace[tablespace_list->tablespace_count
    ].space_consumed+ object_list->object[object_list->object_count].sp_consumed),
    CALL echo(concat("Space consumed: ",cnvtstring(tablespace_list->tablespace[tablespace_list->
      tablespace_count].space_consumed))),
    tablespace_list->tablespace[tablespace_list->tablespace_count].object[tablespace_list->
    tablespace[tablespace_list->tablespace_count].object_count].days_till_full = object_list->object[
    object_list->object_count].days_till_full
    IF ((object_list->object[object_list->object_count].days_till_full <= 1000))
     tablespace_list->tablespace[tablespace_list->tablespace_count].object_number = (tablespace_list
     ->tablespace[tablespace_list->tablespace_count].object_number+ 1)
    ENDIF
    tablespace_list->tablespace[tablespace_list->tablespace_count].object[tablespace_list->
    tablespace[tablespace_list->tablespace_count].object_count].next_extent = ceil((tablespace_list->
     tablespace[tablespace_list->tablespace_count].object[tablespace_list->tablespace[tablespace_list
     ->tablespace_count].object_count].sp_consumed_daily * 90)), tablespace_list->tablespace[
    tablespace_list->tablespace_count].object[tablespace_list->tablespace[tablespace_list->
    tablespace_count].object_count].new_days_till_full = 0.0, tablespace_list->tablespace[
    tablespace_list->tablespace_count].object[tablespace_list->tablespace[tablespace_list->
    tablespace_count].object_count].next_extent_bytes = (tablespace_list->tablespace[tablespace_list
    ->tablespace_count].object[tablespace_list->tablespace[tablespace_list->tablespace_count].
    object_count].next_extent * block_size),
    tablespace_list->tablespace[tablespace_list->tablespace_count].object[tablespace_list->
    tablespace[tablespace_list->tablespace_count].object_count].space_to_add = 0.0, tablespace_list->
    tablespace[tablespace_list->tablespace_count].object[tablespace_list->tablespace[tablespace_list
    ->tablespace_count].object_count].new_space_to_add = 0.0, tablespace_list->tablespace[
    tablespace_list->tablespace_count].object[tablespace_list->tablespace[tablespace_list->
    tablespace_count].object_count].over_allocated_space = 0.0
   ELSE
    object_list->object[object_list->object_count].days_till_full = 999999
   ENDIF
   IF ((((object_list->object[object_list->object_count].created=1)) OR ((object_list->object[
   object_list->object_count].migrated=1))) )
    object_list->object[object_list->object_count].next_extent = a.next_extent
   ELSE
    object_list->object[object_list->object_count].next_extent = ceil((object_list->object[
     object_list->object_count].sp_consumed_daily * 90))
   ENDIF
   object_list->object[object_list->object_count].next_extent_bytes = (object_list->object[
   object_list->object_count].next_extent * block_size), object_list->object[object_list->
   object_count].space_to_add = 0.0, object_list->object[object_list->object_count].new_space_to_add
    = 0.0,
   object_list->object[object_list->object_count].new_days_till_full = 0.0, object_list->object[
   object_list->object_count].over_allocated_space = 0.0, tablespace_list->tablespace[tablespace_list
   ->tablespace_count].used_space = ((tablespace_list->tablespace[tablespace_list->tablespace_count].
   used_space+ a.total_space) - a.free_space)
   IF ((object_list->object[object_list->object_count].created=0)
    AND (object_list->object[object_list->object_count].migrated=0))
    tablespace_list->tablespace[tablespace_list->tablespace_count].prev_used_space = ((
    tablespace_list->tablespace[tablespace_list->tablespace_count].prev_used_space+ b.total_space) -
    b.free_space)
   ENDIF
   tablespace_list->tablespace[tablespace_list->tablespace_count].free_space = (tablespace_list->
   tablespace[tablespace_list->tablespace_count].free_space+ a.free_space)
  WITH nocounter, orahint("a INDEX(XPKSPACE_OBJ)","b INDEX(XPKSPACE_OBJ)")
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET tablespace_list1->tablespace_count = 0
 SET stat = alterlist(tablespace_list1->tablespace,10)
 SELECT INTO "nl:"
  a.tablespace_name, a.file_id, a.blocks
  FROM dba_free_space a
  ORDER BY a.tablespace_name, a.blocks DESC
  HEAD a.tablespace_name
   tablespace_list1->tablespace_count = (tablespace_list1->tablespace_count+ 1)
   IF (mod(tablespace_list1->tablespace_count,10)=1
    AND (tablespace_list1->tablespace_count != 1))
    stat = alterlist(tablespace_list1->tablespace,(tablespace_list1->tablespace_count+ 9))
   ENDIF
   tablespace_list1->tablespace[tablespace_list1->tablespace_count].tablespace_name = a
   .tablespace_name, tablespace_list1->tablespace[tablespace_list1->tablespace_count].extent_count =
   0
  DETAIL
   tablespace_list1->tablespace[tablespace_list1->tablespace_count].extent_count = (tablespace_list1
   ->tablespace[tablespace_list1->tablespace_count].extent_count+ 1), stat = alterlist(
    tablespace_list1->tablespace[tablespace_list1->tablespace_count].extent,tablespace_list1->
    tablespace[tablespace_list1->tablespace_count].extent_count), tablespace_list1->tablespace[
   tablespace_list1->tablespace_count].extent[tablespace_list1->tablespace[tablespace_list1->
   tablespace_count].extent_count].file_id = a.file_id,
   tablespace_list1->tablespace[tablespace_list1->tablespace_count].extent[tablespace_list1->
   tablespace[tablespace_list1->tablespace_count].extent_count].blocks = a.blocks
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(tablespace_list1->tablespace_count))
  DETAIL
   FOR (cnt = 1 TO tablespace_list->tablespace_count)
     IF ((tablespace_list->tablespace[cnt].tablespace_name=tablespace_list1->tablespace[d.seq].
     tablespace_name))
      tablespace_list->tablespace[cnt].extent_count = 0
      FOR (count = 1 TO tablespace_list1->tablespace[d.seq].extent_count)
        tablespace_list->tablespace[cnt].extent_count = (tablespace_list->tablespace[cnt].
        extent_count+ 1), stat = alterlist(tablespace_list->tablespace[cnt].extent,tablespace_list->
         tablespace[cnt].extent_count), tablespace_list->tablespace[cnt].extent[tablespace_list->
        tablespace[cnt].extent_count].file_id = tablespace_list1->tablespace[d.seq].extent[count].
        file_id,
        tablespace_list->tablespace[cnt].extent[tablespace_list->tablespace[cnt].extent_count].blocks
         = tablespace_list1->tablespace[d.seq].extent[count].blocks
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 FREE SET tablespace_list1
 FOR (cnt = 1 TO tablespace_list->tablespace_count)
   IF ((tablespace_list->tablespace[cnt].object_count > 0)
    AND (tablespace_list->tablespace[cnt].object_number > 0))
    SET done_indicator = 0
    SET day_counter = - (1)
    WHILE (done_indicator=0)
      SET day_counter = (day_counter+ 1)
      CALL echo(concat("tablespace_name ",tablespace_list->tablespace[cnt].tablespace_name))
      CALL echo(concat("day counter ",cnvtstring(day_counter)))
      SET stop_ind = 1
      FOR (cnto = 1 TO tablespace_list->tablespace[cnt].object_count)
        IF ((tablespace_list->tablespace[cnt].object[cnto].days_till_full <= 1000))
         SET stop_ind = 0
         IF ((tablespace_list->tablespace[cnt].object[cnto].days_till_full <= day_counter))
          CALL echo(concat("next extent: ",cnvtstring(tablespace_list->tablespace[cnt].object[cnto].
             next_extent)))
          CALL echo(tablespace_list->tablespace[cnt].object[cnto].object_name)
          SET max_blocks = 0.0
          SET max_pos = 0
          FOR (j = 1 TO tablespace_list->tablespace[cnt].extent_count)
            IF ((tablespace_list->tablespace[cnt].extent[j].blocks > max_blocks))
             SET max_blocks = tablespace_list->tablespace[cnt].extent[j].blocks
             SET max_pos = j
            ENDIF
          ENDFOR
          CALL echo(concat("max_blocks ",cnvtstring(max_blocks)))
          IF ((tablespace_list->tablespace[cnt].object[cnto].next_extent <= max_blocks))
           SET tablespace_list->tablespace[cnt].object[cnto].space_to_add = (tablespace_list->
           tablespace[cnt].object[cnto].space_to_add+ tablespace_list->tablespace[cnt].object[cnto].
           next_extent)
           SET tablespace_list->tablespace[cnt].space_to_add = (tablespace_list->tablespace[cnt].
           space_to_add+ tablespace_list->tablespace[cnt].object[cnto].next_extent)
           SET tablespace_list->tablespace[cnt].object[cnto].days_till_full = (tablespace_list->
           tablespace[cnt].object[cnto].days_till_full+ floor((tablespace_list->tablespace[cnt].
            object[cnto].next_extent/ tablespace_list->tablespace[cnt].object[cnto].sp_consumed_daily
            )))
           CALL echo(concat("days till full",cnvtstring(tablespace_list->tablespace[cnt].object[cnto]
              .days_till_full)))
           SET tablespace_list->tablespace[cnt].extent[max_pos].blocks = (tablespace_list->
           tablespace[cnt].extent[max_pos].blocks - tablespace_list->tablespace[cnt].object[cnto].
           next_extent)
          ELSE
           SET done_indicator = 1
           SET tablespace_list->tablespace[cnt].days_remaining = day_counter
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      IF (stop_ind=1)
       SET done_indicator = 1
       SET tablespace_list->tablespace[cnt].days_remaining = day_counter
      ENDIF
    ENDWHILE
   ELSEIF ((tablespace_list->tablespace[cnt].object_count > 0)
    AND (tablespace_list->tablespace[cnt].object_number=0))
    SET tablespace_list->tablespace[cnt].days_remaining = 888888
   ELSE
    SET tablespace_list->tablespace[cnt].days_remaining = 999999
   ENDIF
 ENDFOR
 SET stat = alterlist(object_list_sorted->object,10)
 SET object_list_sorted->object_count = 0
 FOR (cnt = 1 TO tablespace_list->tablespace_count)
   IF ((tablespace_list->tablespace[cnt].days_remaining < 999999))
    SELECT INTO "nl:"
     *
     FROM (dummyt d  WITH seq = value(tablespace_list->tablespace[cnt].object_count))
     WHERE (tablespace_list->tablespace[cnt].object[d.seq].days_till_full < 999999)
     ORDER BY tablespace_list->tablespace[cnt].object[d.seq].days_till_full, tablespace_list->
      tablespace[cnt].object[d.seq].next_extent DESC
     DETAIL
      object_list_sorted->object_count = (object_list_sorted->object_count+ 1)
      IF (mod(object_list_sorted->object_count,10)=1
       AND (object_list_sorted->object_count != 1))
       stat = alterlist(object_list_sorted->object,(object_list_sorted->object_count+ 9))
      ENDIF
      object_list_sorted->object[object_list_sorted->object_count].tablespace_name = tablespace_list
      ->tablespace[cnt].tablespace_name, object_list_sorted->object[object_list_sorted->object_count]
      .instance_cd = tablespace_list->tablespace[cnt].object[d.seq].instance_cd, object_list_sorted->
      object[object_list_sorted->object_count].owner = tablespace_list->tablespace[cnt].object[d.seq]
      .owner,
      object_list_sorted->object[object_list_sorted->object_count].object_name = tablespace_list->
      tablespace[cnt].object[d.seq].object_name, object_list_sorted->object[object_list_sorted->
      object_count].object_type = tablespace_list->tablespace[cnt].object[d.seq].object_type,
      object_list_sorted->object[object_list_sorted->object_count].sp_total = tablespace_list->
      tablespace[cnt].object[d.seq].sp_total,
      object_list_sorted->object[object_list_sorted->object_count].sp_free = tablespace_list->
      tablespace[cnt].object[d.seq].sp_free, object_list_sorted->object[object_list_sorted->
      object_count].sp_used = tablespace_list->tablespace[cnt].object[d.seq].sp_used,
      object_list_sorted->object[object_list_sorted->object_count].sp_allocated = 0.0,
      object_list_sorted->object[object_list_sorted->object_count].next_extent = tablespace_list->
      tablespace[cnt].object[d.seq].next_extent, object_list_sorted->object[object_list_sorted->
      object_count].next_extent_bytes = tablespace_list->tablespace[cnt].object[d.seq].
      next_extent_bytes, object_list_sorted->object[object_list_sorted->object_count].sp_prev_used =
      tablespace_list->tablespace[cnt].object[d.seq].sp_prev_used,
      object_list_sorted->object[object_list_sorted->object_count].sp_consumed = tablespace_list->
      tablespace[cnt].object[d.seq].sp_consumed, object_list_sorted->object[object_list_sorted->
      object_count].sp_consumed_daily = tablespace_list->tablespace[cnt].object[d.seq].
      sp_consumed_daily, object_list_sorted->object[object_list_sorted->object_count].days_till_full
       = tablespace_list->tablespace[cnt].object[d.seq].days_till_full,
      object_list_sorted->object[object_list_sorted->object_count].space_to_add = tablespace_list->
      tablespace[cnt].object[d.seq].space_to_add, object_list_sorted->object[object_list_sorted->
      object_count].new_days_till_full = 0.0, object_list_sorted->object[object_list_sorted->
      object_count].new_space_to_add = 0.0,
      object_list_sorted->object[object_list_sorted->object_count].over_allocated_space = 0.0
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET nbr = 0
 SELECT
  *
  FROM (dummyt d  WITH seq = value(object_list_sorted->object_count))
  ORDER BY object_list_sorted->object[d.seq].days_till_full, object_list_sorted->object[d.seq].
   next_extent DESC, object_list_sorted->object[d.seq].object_name
  HEAD REPORT
   "                         How Many Days Each Object Will Last with a 90-day Next Extent", row + 2
  HEAD PAGE
   "Number     ", "Tablespace Name            ", "          Object Name                 ",
   "Owner     ", "     Days Till Full   ", "Space To Add  ",
   "     Next Extent  ", "    Space Free   ", "Space used      ",
   "Space prev used  ", "Space consumed  ", "Space cons daily  ",
   "Next Extent (bytes)", row + 1
  DETAIL
   nbr = (nbr+ 1), nbr"###########;C;I", " ",
   object_list_sorted->object[d.seq].tablespace_name, "  ", object_list_sorted->object[d.seq].
   object_name,
   "  ", object_list_sorted->object[d.seq].owner, "  ",
   object_list_sorted->object[d.seq].days_till_full, "  ", object_list_sorted->object[d.seq].
   space_to_add,
   "    ", object_list_sorted->object[d.seq].next_extent, "  ",
   object_list_sorted->object[d.seq].sp_free, "  ", object_list_sorted->object[d.seq].sp_used,
   "  ", object_list_sorted->object[d.seq].sp_prev_used, "  ",
   object_list_sorted->object[d.seq].sp_consumed, "  ", object_list_sorted->object[d.seq].
   sp_consumed_daily,
   "         ", object_list_sorted->object[d.seq].next_extent_bytes, row + 1
  WITH nocounter, maxrow = 20, maxcol = 300,
   format = variable
 ;end select
 SET day_counter = tablespace_list->tablespace[1].days_remaining
 SET total_space_used_daily = 0.0
 SET nbr = 0
 SELECT
  *
  FROM (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  ORDER BY tablespace_list->tablespace[d.seq].days_remaining, tablespace_list->tablespace[d.seq].
   tablespace_name
  HEAD REPORT
   "                         How Many Days Each Tablespace Will Last with a 90-day Next Extent", row
    + 2
  HEAD PAGE
   "Number     ", "Tablespace Name              ", "     Days Remaining  ",
   "Free Space  ", "Space Cons Daily  ", "Space To Add  ",
   row + 1
  DETAIL
   IF ((tablespace_list->tablespace[d.seq].days_remaining < day_counter))
    day_counter = tablespace_list->tablespace[d.seq].days_remaining
   ENDIF
   IF ((tablespace_list->tablespace[d.seq].days_remaining < 999999))
    total_space_used_daily = (total_space_used_daily+ tablespace_list->tablespace[d.seq].
    space_consumed_daily)
   ENDIF
   nbr = (nbr+ 1), nbr"###########;C;I", " ",
   tablespace_list->tablespace[d.seq].tablespace_name
   IF ((tablespace_list->tablespace[d.seq].days_remaining=888888))
    s_days_remaining = "> 1000"
   ELSE
    s_days_remaining = cnvtstring(tablespace_list->tablespace[d.seq].days_remaining)
   ENDIF
   s_days_remaining"#####################;C;C", tablespace_list->tablespace[d.seq].free_space,
   tablespace_list->tablespace[d.seq].space_consumed_daily,
   tablespace_list->tablespace[d.seq].space_to_add, row + 1
  FOOT REPORT
   BREAK, row + 2, "Total consumed space per day in blocks (consumed space > 0 only): ",
   total_space_used_daily, row + 1, x = ((total_space_used_daily * block_size)/ 1024.0),
   "Total consumed space per day in KB (consumed space > 0 only):     ", x, row + 1,
   "The database will last                                            ", day_counter, " days.",
   row + 1,
   " Note. '999999' indicates that the tablespace contains objects with a negative or zero space consumption ",
   row + 1,
   "between the selected space reports", row + 1
  WITH nocounter, maxrow = 20, maxcol = 300,
   format = variable
 ;end select
 IF (( $1=1))
  SET new_free_space = cnvtreal( $2)
  CALL echo(concat("New free space ",cnvtstring(new_free_space)))
  SET new_free_space = round((((new_free_space * 1024) * 1024)/ block_size),0)
  CALL echo(concat("New free space ",cnvtstring(new_free_space)))
  SET done_indicator = 0
  SET target_day_counter = 0
  WHILE (done_indicator=0)
    SET day_counter = (day_counter+ 1)
    CALL echo(concat("Day counter ",cnvtstring(day_counter)))
    SELECT INTO "nl:"
     *
     FROM (dummyt d  WITH seq = value(object_list_sorted->object_count))
     WHERE (object_list_sorted->object[d.seq].days_till_full <= 1000)
     ORDER BY object_list_sorted->object[d.seq].days_till_full, object_list_sorted->object[d.seq].
      next_extent DESC
     DETAIL
      CALL echo(object_list_sorted->object[d.seq].object_name)
      IF ((object_list_sorted->object[d.seq].days_till_full <= day_counter))
       IF ((object_list_sorted->object[d.seq].next_extent <= new_free_space))
        new_free_space = (new_free_space - object_list_sorted->object[d.seq].next_extent),
        CALL echo(concat("New free space inside ",cnvtstring(new_free_space))), object_list_sorted->
        object[d.seq].days_till_full = (object_list_sorted->object[d.seq].days_till_full+ floor((
         object_list_sorted->object[d.seq].next_extent/ object_list_sorted->object[d.seq].
         sp_consumed_daily))),
        CALL echo(concat("Days till full inside ",cnvtstring(object_list_sorted->object[d.seq].
          days_till_full))), object_list_sorted->object[d.seq].new_days_till_full = (
        object_list_sorted->object[d.seq].new_days_till_full+ floor((object_list_sorted->object[d.seq
         ].next_extent/ object_list_sorted->object[d.seq].sp_consumed_daily))), object_list_sorted->
        object[d.seq].space_to_add = (object_list_sorted->object[d.seq].space_to_add+
        object_list_sorted->object[d.seq].next_extent),
        CALL echo(concat("Space to add inside ",cnvtstring(object_list_sorted->object[d.seq].
          space_to_add))), object_list_sorted->object[d.seq].new_space_to_add = (object_list_sorted->
        object[d.seq].new_space_to_add+ object_list_sorted->object[d.seq].next_extent)
       ELSE
        done_indicator = 1, target_day_counter = day_counter
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET done_indicator = 1
     SET target_day_counter = day_counter
    ENDIF
  ENDWHILE
 ENDIF
 IF (( $1=2))
  SET target_day_counter =  $2
  SET done_indicator = 0
  WHILE (done_indicator=0)
   SET day_counter = (day_counter+ 1)
   IF (day_counter=target_day_counter)
    SET done_indicator = 1
   ELSE
    SELECT INTO "nl:"
     *
     FROM (dummyt d  WITH seq = value(object_list_sorted->object_count))
     WHERE (object_list_sorted->object[d.seq].days_till_full <= 1000)
     DETAIL
      IF ((object_list_sorted->object[d.seq].days_till_full <= day_counter))
       object_list_sorted->object[d.seq].space_to_add = (object_list_sorted->object[d.seq].
       space_to_add+ object_list_sorted->object[d.seq].next_extent), object_list_sorted->object[d.seq
       ].new_space_to_add = (object_list_sorted->object[d.seq].new_space_to_add+ object_list_sorted->
       object[d.seq].next_extent), object_list_sorted->object[d.seq].days_till_full = (
       object_list_sorted->object[d.seq].days_till_full+ floor((object_list_sorted->object[d.seq].
        next_extent/ object_list_sorted->object[d.seq].sp_consumed_daily))),
       object_list_sorted->object[d.seq].new_days_till_full = (object_list_sorted->object[d.seq].
       new_days_till_full+ floor((object_list_sorted->object[d.seq].next_extent/ object_list_sorted->
        object[d.seq].sp_consumed_daily)))
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET done_indicator = 1
    ENDIF
   ENDIF
  ENDWHILE
 ENDIF
 IF (( $3=1))
  SET total_over_allocated = 0.0
  CALL echo(concat("Target day counter:  ",cnvtstring(target_day_counter)))
  SELECT INTO "nl:"
   *
   FROM (dummyt d  WITH seq = value(object_list_sorted->object_count))
   WHERE (object_list_sorted->object[d.seq].days_till_full < 999999)
    AND (object_list_sorted->object[d.seq].days_till_full > target_day_counter)
   ORDER BY object_list_sorted->object[d.seq].days_till_full, object_list_sorted->object[d.seq].
    next_extent DESC
   DETAIL
    object_list_sorted->object[d.seq].over_allocated_space = (((object_list_sorted->object[d.seq].
    days_till_full - target_day_counter) * object_list_sorted->object[d.seq].sp_consumed_daily) -
    object_list_sorted->object[d.seq].next_extent),
    CALL echo(cnvtstring(object_list_sorted->object[d.seq].over_allocated_space))
    IF ((object_list_sorted->object[d.seq].over_allocated_space < 0))
     object_list_sorted->object[d.seq].over_allocated_space = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT
   *
   FROM (dummyt d  WITH seq = value(object_list_sorted->object_count)),
    (dummyt d1  WITH seq = value(tablespace_list->tablespace_count))
   PLAN (d
    WHERE (object_list_sorted->object[d.seq].days_till_full < 999999)
     AND (object_list_sorted->object[d.seq].over_allocated_space > 0))
    JOIN (d1
    WHERE (tablespace_list->tablespace[d1.seq].tablespace_name=object_list_sorted->object[d.seq].
    tablespace_name))
   ORDER BY tablespace_list->tablespace[d1.seq].tablespace_name, object_list_sorted->object[d.seq].
    over_allocated_space DESC
   HEAD REPORT
    "                         Over Allocated Space (blocks)", row + 2
   HEAD PAGE
    "Tablespace Name               ", "Object Name                     ", "Owner     ",
    "Over Allocated Space", row + 1
   HEAD d1.seq
    space_over_allocated = 0.0, tablespace_list->tablespace[d1.seq].tablespace_name, row + 1
   DETAIL
    space_over_allocated = (space_over_allocated+ object_list_sorted->object[d.seq].
    over_allocated_space), total_over_allocated = (total_over_allocated+ object_list_sorted->object[d
    .seq].over_allocated_space), "                              ",
    object_list_sorted->object[d.seq].object_name, "  ", object_list_sorted->object[d.seq].owner,
    object_list_sorted->object[d.seq].over_allocated_space, row + 1
   FOOT  d1.seq
    row + 1, tablespace_list->tablespace[d1.seq].space_over_allocated = space_over_allocated,
    "Over Allocated Space (blocks): ",
    space_over_allocated, row + 1, x = ((space_over_allocated * block_size)/ 1024.0),
    "Over Allocated Space (in KB):  ", x, row + 2
   FOOT REPORT
    BREAK, "Total over allocated space (blocks)", total_over_allocated,
    row + 1, y = ((total_over_allocated * block_size)/ 1024.0), "Total over allocated space (in KB )",
    y, row + 1
   WITH nocounter, maxrow = 20, maxcol = 250,
    format = variable
  ;end select
 ENDIF
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(object_list_sorted->object_count)),
   (dummyt d1  WITH seq = value(tablespace_list->tablespace_count))
  PLAN (d)
   JOIN (d1
   WHERE (tablespace_list->tablespace[d1.seq].tablespace_name=object_list_sorted->object[d.seq].
   tablespace_name))
  ORDER BY tablespace_list->tablespace[d1.seq].tablespace_name
  HEAD d1.seq
   days_remaining = 999999, tablespace_list->tablespace[d1.seq].space_to_add = 0.0
  DETAIL
   IF ((object_list_sorted->object[d.seq].days_till_full < days_remaining))
    days_remaining = object_list_sorted->object[d.seq].days_till_full
   ENDIF
   tablespace_list->tablespace[d1.seq].space_to_add = (tablespace_list->tablespace[d1.seq].
   space_to_add+ object_list_sorted->object[d.seq].space_to_add),
   CALL echo(concat("Object_list_sorted Space to add",cnvtstring(object_list_sorted->object[d.seq].
     space_to_add))), tablespace_list->tablespace[d1.seq].new_space_to_add = (tablespace_list->
   tablespace[d1.seq].new_space_to_add+ object_list_sorted->object[d.seq].new_space_to_add)
  FOOT  d1.seq
   tablespace_list->tablespace[d1.seq].days_remaining = days_remaining, tablespace_list->tablespace[
   d1.seq].partitioned_bytes = ((ceil(((tablespace_list->tablespace[d1.seq].new_space_to_add *
    block_size)/ (partition_size * mbyte))) * partition_size) * mbyte),
   CALL echo(concat("new_space_to_add: ",cnvtstring(tablespace_list->tablespace[d1.seq].
     new_space_to_add))),
   CALL echo(concat("new_space_to_add: ",cnvtstring(tablespace_list->tablespace[d1.seq].
     partitioned_bytes)))
  WITH nocounter
 ;end select
 SET nbr = 0
 SELECT
  *
  FROM (dummyt d  WITH seq = value(object_list_sorted->object_count))
  ORDER BY object_list_sorted->object[d.seq].days_till_full, object_list_sorted->object[d.seq].
   next_extent DESC, object_list_sorted->object[d.seq].object_name
  HEAD REPORT
   "                         Days Each Object will Last with New Added Space and a 90-day Next Extent",
   row + 2
  HEAD PAGE
   "Number     ", "Tablespace Name            ", "          Object Name                 ",
   "Owner     ", "   Days_Till_Full ", " New_Days_Till_Full ",
   "Space_to_Add  ", "New_Space_to_Add  ", "    Next Extent     ",
   "Space Free     ", "Space used    ", "Space prev used  ",
   "Space consumed  ", "Space cons daily  ", "Next Extent (bytes)",
   row + 1
  DETAIL
   nbr = (nbr+ 1), nbr"###########;C;I", " ",
   object_list_sorted->object[d.seq].tablespace_name, "  ", object_list_sorted->object[d.seq].
   object_name,
   "  ", object_list_sorted->object[d.seq].owner, "  ",
   object_list_sorted->object[d.seq].days_till_full, "  ", object_list_sorted->object[d.seq].
   new_days_till_full,
   "  ", object_list_sorted->object[d.seq].space_to_add, "  ",
   object_list_sorted->object[d.seq].new_space_to_add, "    ", object_list_sorted->object[d.seq].
   next_extent,
   "  ", object_list_sorted->object[d.seq].sp_free, "  ",
   object_list_sorted->object[d.seq].sp_used, "  ", object_list_sorted->object[d.seq].sp_prev_used,
   "  ", object_list_sorted->object[d.seq].sp_consumed, "  ",
   object_list_sorted->object[d.seq].sp_consumed_daily, "       ", object_list_sorted->object[d.seq].
   next_extent_bytes,
   row + 1
  WITH nocounter, maxrow = 20, maxcol = 300,
   format = variable
 ;end select
 SELECT INTO value(filename1)
  *
  FROM (dummyt d  WITH seq = value(object_list_sorted->object_count))
  ORDER BY object_list_sorted->object[d.seq].days_till_full, object_list_sorted->object[d.seq].
   next_extent DESC, object_list_sorted->object[d.seq].object_name
  DETAIL
   IF ((object_list_sorted->object[d.seq].object_type="T"))
    "rdb ALTER TABLE ", object_list_sorted->object[d.seq].object_name, " STORAGE (NEXT ",
    object_list_sorted->object[d.seq].next_extent_bytes, " K  PCTINCREASE 0) GO ", row + 1
   ELSE
    "rdb ALTER INDEX ", object_list_sorted->object[d.seq].object_name, " STORAGE (NEXT ",
    object_list_sorted->object[d.seq].next_extent_bytes, " K  PCTINCREASE 0) GO ", row + 1
   ENDIF
  WITH format = stream, noheading, maxcol = 512,
   maxrow = 1, formfeed = none, append
 ;end select
 SET total_space_to_add = 0.0
 SET total_space_used_daily = 0.0
 SET day_counter = tablespace_list->tablespace[1].days_remaining
 SET nbr = 0
 SELECT
  *
  FROM (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  ORDER BY tablespace_list->tablespace[d.seq].days_remaining, tablespace_list->tablespace[d.seq].
   tablespace_name
  HEAD REPORT
   "                         Days the Database will Last with New Added Space and a 90-day Next Extent",
   row + 2
  HEAD PAGE
   "Number     ", "Tablespace Name              ", "    Days Remaining ",
   "Space_To_Add ", "New_Space_to_Add  ", "Free Space  ",
   "Space Cons Daily  ", row + 2
  DETAIL
   IF ((tablespace_list->tablespace[d.seq].days_remaining < day_counter))
    day_counter = tablespace_list->tablespace[d.seq].days_remaining
   ENDIF
   total_space_to_add = (total_space_to_add+ tablespace_list->tablespace[d.seq].new_space_to_add)
   IF ((tablespace_list->tablespace[d.seq].days_remaining < 999999))
    total_space_used_daily = (total_space_used_daily+ tablespace_list->tablespace[d.seq].
    space_consumed_daily)
   ENDIF
   nbr = (nbr+ 1), nbr"###########;C;I", " ",
   tablespace_list->tablespace[d.seq].tablespace_name, tablespace_list->tablespace[d.seq].
   days_remaining, tablespace_list->tablespace[d.seq].space_to_add,
   tablespace_list->tablespace[d.seq].new_space_to_add, tablespace_list->tablespace[d.seq].free_space,
   tablespace_list->tablespace[d.seq].space_consumed_daily,
   row + 1
  FOOT REPORT
   BREAK, row + 2, "Total consumed space per day in blocks (used space > 0 only): ",
   total_space_used_daily, row + 1, x = ((total_space_used_daily * block_size)/ 1024.0),
   "Total consumed space per day in KB (consumed space > 0 only): ", x, row + 1,
   "New space to add in blocks:                                   ", total_space_to_add, row + 1,
   y = ((total_space_to_add * block_size)/ 1024.0),
   "New space to add in KB:                                       ", y,
   row + 1, "The database will last                                        ", day_counter,
   " days.", row + 1,
   " Note. '999999' indicates that the tablespace contains objects with a negative or zero space consumption ",
   row + 1, "between the selected space reports", row + 1
  WITH nocounter, maxrow = 20, maxcol = 300,
   format = variable
 ;end select
 SET nbr = 0
 SELECT
  *
  FROM (dummyt d  WITH seq = value(object_list->object_count))
  WHERE (object_list->object[d.seq].created=1)
  ORDER BY object_list->object[d.seq].tablespace_name, object_list->object[d.seq].object_name
  HEAD REPORT
   "               Object Added Since the Start Space Report", row + 2
  HEAD PAGE
   "Number     ", "Tablespace Name            ", "          Object Name                 ",
   "Owner     ", "     Days Till Full   ", "Space To Add  ",
   "   Next Extent  ", "    Space Free   ", "Space used      ",
   "Space prev used  ", "Space consumed  ", "Space cons daily  ",
   "Next Extent (bytes)", row + 1
  DETAIL
   nbr = (nbr+ 1), nbr"###########;C;I", " ",
   object_list->object[d.seq].tablespace_name, "  ", object_list->object[d.seq].object_name,
   "  ", object_list->object[d.seq].owner, "  ",
   object_list->object[d.seq].days_till_full, "  ", object_list->object[d.seq].space_to_add,
   "    ", object_list->object[d.seq].next_extent, "  ",
   object_list->object[d.seq].sp_free, "  ", object_list->object[d.seq].sp_used,
   "  ", object_list->object[d.seq].sp_prev_used, "  ",
   object_list->object[d.seq].sp_consumed, "  ", object_list->object[d.seq].sp_consumed_daily,
   "         ", object_list->object[d.seq].next_extent_bytes, row + 1
  FOOT REPORT
   row + 1,
   "These objects do not have size information;  '999999' indicates no available information"
  WITH nocounter, maxrow = 20, maxcol = 300,
   format = variable
 ;end select
 IF (curqual=0)
  SELECT
   *
   FROM dual
   DETAIL
    "No new objects between the selected space reports", row + 1
   WITH nocounter, maxrow = 1, maxcol = 100,
    format = variable
  ;end select
 ENDIF
 SET nbr = 0
 SELECT
  *
  FROM (dummyt d  WITH seq = value(object_list->object_count))
  WHERE (object_list->object[d.seq].migrated=1)
  ORDER BY object_list->object[d.seq].tablespace_name, object_list->object[d.seq].object_name
  HEAD REPORT
   "               Object Migrated Since the Start Space Report", row + 2
  HEAD PAGE
   "Number     ", "Tablespace Name            ", "Old Tablespace Name        ",
   "          Object Name                 ", "Owner     ", "     Days Till Full   ",
   "Space To Add  ", "   Next Extent  ", "    Space Free   ",
   "Space used      ", "Space prev used  ", "Space consumed  ",
   "Space cons daily  ", "Next Extent (bytes)", row + 1
  DETAIL
   nbr = (nbr+ 1), nbr"###########;C;I", " ",
   object_list->object[d.seq].tablespace_name, object_list->object[d.seq].tablespace_name_old, "  ",
   object_list->object[d.seq].object_name, "  ", object_list->object[d.seq].owner,
   "  ", object_list->object[d.seq].days_till_full, "  ",
   object_list->object[d.seq].space_to_add, "    ", object_list->object[d.seq].next_extent,
   "  ", object_list->object[d.seq].sp_free, "  ",
   object_list->object[d.seq].sp_used, "  ", object_list->object[d.seq].sp_prev_used,
   "  ", object_list->object[d.seq].sp_consumed, "  ",
   object_list->object[d.seq].sp_consumed_daily, "         ", object_list->object[d.seq].
   next_extent_bytes,
   row + 1
  FOOT REPORT
   row + 1,
   "These objects do not have size information;  '999999' indicates no available information"
  WITH nocounter, maxrow = 20, maxcol = 300,
   format = variable
 ;end select
 IF (curqual=0)
  SELECT
   *
   FROM dual
   DETAIL
    "No migrated objects between the selected space reports", row + 1
   WITH nocounter, maxrow = 1, maxcol = 100,
    format = variable
  ;end select
 ENDIF
 FREE SET size_list
 RECORD size_list(
   1 size[*]
     2 file_size = f8
     2 file_size_meg = f8
     2 size_cnt = f8
     2 size_seq = f8
   1 size_count = i4
 )
 SET size_list->size_count = 0
 SET size_sequence = 0
 IF (target_operating_system != "AIX")
  SELECT INTO "nl:"
   a.bytes, x = count(*)
   FROM dba_data_files a
   GROUP BY a.bytes
   DETAIL
    size_list->size_count = (size_list->size_count+ 1)
    IF (mod(size_list->size_count,10)=1)
     stat = alterlist(size_list->size,(size_list->size_count+ 9))
    ENDIF
    size_list->size[size_list->size_count].file_size = a.bytes, size_list->size[size_list->size_count
    ].size_cnt = x, size_list->size[size_list->size_count].size_seq = x
   WITH nocounter
  ;end select
 ELSE
  SET cnt = 0
  SET file_size_meg = 0
  SET max_seq = 0
  SELECT INTO "nl:"
   a.file_name, a.bytes
   FROM dba_data_files a
   ORDER BY a.file_name, a.bytes
   DETAIL
    IF (cnt=0)
     e = "_", pos = findstring(e,a.file_name)
    ENDIF
    IF (file_size_meg != cnvtint(substring((pos+ 1),4,a.file_name)))
     file_size_meg = cnvtint(substring((pos+ 1),4,a.file_name)), size_list->size_count = (size_list->
     size_count+ 1)
     IF (mod(size_list->size_count,10)=1)
      stat = alterlist(size_list->size,(size_list->size_count+ 9))
     ENDIF
     size_list->size[size_list->size_count].file_size_meg = file_size_meg
     IF (cnt > 0)
      size_list->size[(size_list->size_count - 1)].size_seq = max_seq,
      CALL echo(cnvtstring(size_list->size[(size_list->size_count - 1)].file_size_meg)),
      CALL echo(cnvtstring(size_list->size[(size_list->size_count - 1)].size_seq)),
      max_seq = 0
     ENDIF
    ENDIF
    file_seq = cnvtint(substring((pos+ 6),3,a.file_name))
    IF (file_seq > max_seq)
     max_seq = file_seq
    ENDIF
    cnt = (cnt+ 1)
   FOOT REPORT
    size_list->size[size_list->size_count].size_seq = max_seq,
    CALL echo(cnvtstring(size_list->size[size_list->size_count].file_size_meg)),
    CALL echo(cnvtstring(size_list->size[size_list->size_count].size_seq))
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM dm_env_files
  WHERE environment_id=env_id
 ;end delete
 DELETE  FROM dm_env_table
  WHERE environment_id=env_id
 ;end delete
 DELETE  FROM dm_env_index
  WHERE environment_id=env_id
 ;end delete
 FOR (cnt = 1 TO tablespace_list->tablespace_count)
   SET total_size = tablespace_list->tablespace[cnt].partitioned_bytes
   CALL echo(concat("Partitioned bytes: ",tablespace_list->tablespace[cnt].tablespace_name))
   CALL echo(concat("Partitioned bytes: ",cnvtstring(total_size)))
   SET tablespace_list->tablespace[cnt].file_count = 0
   SELECT INTO "nl:"
    a.tablespace_name, x = count(a.file_name)
    FROM dba_data_files a
    WHERE (a.tablespace_name=tablespace_list->tablespace[cnt].tablespace_name)
    DETAIL
     tablespace_list->tablespace[cnt].file_count = x
    WITH nocounter
   ;end select
   SET tablespace_list->tablespace[cnt].new_file_count = 0
   WHILE (total_size > 0.0)
     SET tablespace_list->tablespace[cnt].new_file_count = (tablespace_list->tablespace[cnt].
     new_file_count+ 1)
     SET stat = alterlist(tablespace_list->tablespace[cnt].new_file,tablespace_list->tablespace[cnt].
      new_file_count)
     IF (total_size > max_size)
      SET raw_size = max_size
     ELSE
      SET raw_size = total_size
     ENDIF
     SET total_size = (total_size - raw_size)
     CALL echo(concat("Max_size: ",cnvtstring(max_size)))
     CALL echo(concat("Inside total_size: ",cnvtstring(total_size)))
     IF (target_operating_system="AIX")
      SET tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].new_file_count].
      size = (raw_size - mbyte)
      SET tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].new_file_count].
      raw_size = raw_size
      SET tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].new_file_count].
      size_meg = cnvtint((raw_size/ (1024 * 1024)))
     ELSE
      SET tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].new_file_count].
      size = raw_size
      SET tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].new_file_count].
      file_seq = (tablespace_list->tablespace[cnt].file_count+ 1)
      SET tablespace_list->tablespace[cnt].file_count = (tablespace_list->tablespace[cnt].file_count
      + 1)
     ENDIF
     SET found = 0
     SET s = 1
     IF (target_operating_system="AIX")
      WHILE (found=0
       AND (s <= size_list->size_count))
        CALL echo(concat("Size count: ",cnvtstring(size_list->size_count)))
        IF ((size_list->size[s].file_size_meg=tablespace_list->tablespace[cnt].new_file[
        tablespace_list->tablespace[cnt].new_file_count].size_meg))
         SET size_list->size[s].size_seq = (size_list->size[s].size_seq+ 1)
         SET size_sequence = size_list->size[s].size_seq
         SET found = 1
        ENDIF
        SET s = (s+ 1)
      ENDWHILE
     ELSE
      WHILE (found=0
       AND (s <= size_list->size_count))
        CALL echo(concat("Size count: ",cnvtstring(size_list->size_count)))
        IF ((size_list->size[s].file_size=tablespace_list->tablespace[cnt].new_file[tablespace_list->
        tablespace[cnt].new_file_count].size))
         SET size_list->size[s].size_seq = (size_list->size[s].size_seq+ 1)
         SET size_sequence = size_list->size[s].size_seq
         SET found = 1
        ENDIF
        SET s = (s+ 1)
      ENDWHILE
     ENDIF
     IF (found=0)
      SET size_sequence = 1
      SET size_list->size_count = (size_list->size_count+ 1)
      SET stat = alterlist(size_list->size,size_list->size_count)
      SET size_list->size[size_list->size_count].size_seq = 1
      SET size_list->size[size_list->size_count].size_cnt = 1
      SET size_list->size[size_list->size_count].file_size = tablespace_list->tablespace[cnt].
      new_file[tablespace_list->tablespace[cnt].new_file_count].size
      SET size_list->size[size_list->size_count].file_size_meg = tablespace_list->tablespace[cnt].
      new_file[tablespace_list->tablespace[cnt].new_file_count].size_meg
     ENDIF
     IF (target_operating_system="AIX")
      SET raw_size = (tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].
      new_file_count].size+ mbyte)
      SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024 * 1024))),
        "####;P0"),"_",format(cnvtstring(size_sequence),"###;P0"))
     ELSE
      SET file_seq = format(cnvtstring(tablespace_list->tablespace[cnt].new_file[tablespace_list->
        tablespace[cnt].new_file_count].file_seq),"##;P0")
      SET fname = build(tablespace_list->tablespace[cnt].tablespace_name,"_",file_seq)
     ENDIF
     SET tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].new_file_count].
     file_name = fname
     SET tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].new_file_count].
     size_sequence = size_sequence
     INSERT  FROM dm_env_files def
      SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
       def.updt_id = 0, def.updt_task = 0, def.file_type =
       IF (substring(1,1,tablespace_list->tablespace[cnt].tablespace_name)="I") "INDEX"
       ELSEIF (substring(1,1,tablespace_list->tablespace[cnt].tablespace_name)="D") "DATA"
       ENDIF
       ,
       def.file_size = tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].
       new_file_count].size, def.size_sequence = size_sequence, def.environment_id = env_id,
       def.tablespace_name = tablespace_list->tablespace[cnt].tablespace_name, def.file_name =
       tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].new_file_count].
       file_name, def.tablespace_exist_ind = 1
      WITH nocounter
     ;end insert
     CALL echo(substring(1,1,tablespace_list->tablespace[cnt].tablespace_name))
     CALL echo(tablespace_list->tablespace[cnt].tablespace_name)
     CALL echo(cnvtstring(tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].
       new_file_count].size))
     CALL echo(cnvtstring(tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].
       new_file_count].file_seq))
     CALL echo(tablespace_list->tablespace[cnt].new_file[tablespace_list->tablespace[cnt].
      new_file_count].file_name)
   ENDWHILE
 ENDFOR
 SELECT INTO "nl:"
  a.tablespace_name
  FROM dm_tablespace a,
   (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  PLAN (d)
   JOIN (a
   WHERE (a.tablespace_name=tablespace_list->tablespace[d.seq].tablespace_name))
  ORDER BY a.tablespace_name
  DETAIL
   tablespace_list->tablespace[d.seq].exist_tablespace_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.tablespace_name, a.initial_extent, a.next_extent,
  a.pct_increase
  FROM user_tablespaces a,
   (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  PLAN (d)
   JOIN (a
   WHERE (tablespace_list->tablespace[d.seq].exist_tablespace_ind=0)
    AND (a.tablespace_name=tablespace_list->tablespace[d.seq].tablespace_name))
  ORDER BY a.tablespace_name
  DETAIL
   tablespace_list->tablespace[d.seq].initial_extent = a.initial_extent, tablespace_list->tablespace[
   d.seq].next_extent = a.next_extent, tablespace_list->tablespace[d.seq].pct_increase = a
   .pct_increase,
   CALL echo(tablespace_list->tablespace[cnt].tablespace_name)
  WITH nocounter
 ;end select
 FOR (cnt = 1 TO tablespace_list->tablespace_count)
   IF ((tablespace_list->tablespace[cnt].exist_tablespace_ind=0))
    CALL echo(tablespace_list->tablespace[cnt].tablespace_name)
    INSERT  FROM dm_tablespace dt
     SET dt.updt_applctx = 0, dt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dt.updt_cnt = 0,
      dt.updt_id = 0, dt.updt_task = 0, dt.tablespace_name = tablespace_list->tablespace[cnt].
      tablespace_name,
      dt.initial_extent = tablespace_list->tablespace[cnt].initial_extent, dt.next_extent =
      tablespace_list->tablespace[cnt].next_extent, dt.pctincrease = tablespace_list->tablespace[cnt]
      .pct_increase,
      dt.weighting = 0
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
#exit_script
END GO
