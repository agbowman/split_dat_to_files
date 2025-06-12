CREATE PROGRAM dm_resizing:dba
 SET message = nowindow
#0100_start
 IF ((dm_resize->mode != 1)
  AND (dm_resize->mode != 2))
  CALL echo("The first parameter can be 1 or 2 only")
  GO TO exit_script
 ENDIF
 CALL echo("100_CREATE_TEST_FILE")
 EXECUTE FROM 100_create_test_file TO 100_create_test_file_end
 CALL echo("200_DELETE_DM_RESIZING_TEMP")
 EXECUTE FROM 200_delete_dm_resizing_temp TO 200_delete_dm_resizing_temp_end
 CALL echo("1000_INITIALIZE")
 EXECUTE FROM 1000_initialize TO 1000_initialize_end
 CALL echo("1100_CALL_DM_SPACE_CAPTURE")
 EXECUTE FROM 1100_call_dm_space_capture TO 1100_call_dm_space_capture_end
 CALL echo("2000_POPULATE_DATA_STRUCTURES")
 EXECUTE FROM 2000_populate_data_structures TO 2000_populate_data_structures_end
 CALL echo("3000_DETERMINE_DAYS_REMAINING")
 EXECUTE FROM 3000_determine_days_remaining TO 3000_determine_days_remaining_end
 CALL echo("4000_DISPLAY_DAYS_REMAINING")
 EXECUTE FROM 4000_display_days_remaining TO 4000_display_days_remaining_end
 IF (objects_not_considered=1)
  CALL echo("4500_SHOW_OBJECTS_NOT_CONSIDERED")
  EXECUTE FROM 4500_show_objects_not_considered TO 4500_show_objects_not_considered_end
 ENDIF
 IF ((dm_resize->mode=1))
  CALL echo("5000_CALCULATE_NEW_DAYS")
  EXECUTE FROM 5000_calculate_new_days TO 5000_calculate_new_days_end
 ELSE
  CALL echo("5000_CALCULATE_NEW_SIZE")
  EXECUTE FROM 5000_calculate_new_size TO 5000_calculate_new_size_end
 ENDIF
 CALL echo("5500_ROLLUP_OBJECT_LEVEL_CHANGES")
 EXECUTE FROM 5500_rollup_object_level_changes TO 5500_rollup_object_level_changes_end
 IF ((dm_resize->show_allocation_report=1))
  CALL echo("6001_CALCULATE_OVER_ALLOCATED")
  EXECUTE FROM 6001_calculate_over_allocated TO 6001_calculate_over_allocated_end
 ENDIF
 CALL echo("8000_GENERATE_OUTPUT_FILES")
 EXECUTE FROM 8000_generate_output_files TO 8000_generate_output_files_end
 CALL echo("9001_DISPLAY_NEW_DAYS_REMAINING")
 EXECUTE FROM 9001_display_new_days_remaining TO 9001_display_new_days_remaining_end
 CALL echo("9000_DISPLAY_NEW_DAYS_REMAINING")
 EXECUTE FROM 9000_display_new_days_remaining TO 9000_display_new_days_remaining_end
 CALL echo("10000_UPDATE_ENV_TABLES")
 EXECUTE FROM 10000_update_env_tables TO 10000_update_env_tables_end
 CALL echo("11000_OUTPUT_DEBUG_INFO")
 EXECUTE FROM 11000_output_debug_info TO 11000_output_debug_info_end
 GO TO exit_script
#100_create_test_file
 SELECT INTO "dm_resizing.tst"
  FROM dual d
  DETAIL
   "record dm_resize", row + 1, "(",
   row + 1, "1 mode=i4 ;1 for size, 2 for days", row + 1,
   "1 space_to_consume = f8 ;for mode 1, this is in megs", row + 1,
   "1 days_to_last = f8 ; for mode 2, this is how long it should last",
   row + 1, "1 show_allocation_report = i4; 0 for no report, 1 for report", row + 1,
   "1 s_rep_seq=i4 ; this is the starting report sequence", row + 1,
   "1 e_rep_seq=i4 ; this is the ending report sequence",
   row + 1, "1 actual_days_activity=f8; this is the actual time that this activity represents", row
    + 1,
   "1 env_id=i4 ; this is the environment_id", row + 1,
   "1 testing_mode=i4 ;this should be 0 normally",
   row + 1,
   "1 modify_next_extent_size = i4 ;this is 1 if the next extents for all objects should be modified",
   row + 1,
   "1 next_extent_size_days = f8 ; this is the number of days that the next extent should last", row
    + 1, "1 show_no_growth_objects=i4; this is 1 if the output should show objects with no growth",
   row + 1, ")", row + 1,
   "go", row + 1, "set dm_resize->mode = ",
   dm_resize->mode, " go", row + 1,
   "set dm_resize->space_to_consume = ", dm_resize->space_to_consume, " go",
   row + 1, "set dm_resize->days_to_last = ", dm_resize->days_to_last,
   " go", row + 1, "set dm_resize->show_allocation_report = ",
   dm_resize->show_allocation_report, " go", row + 1,
   "set dm_resize->s_rep_seq = ", dm_resize->s_rep_seq, " go",
   row + 1, "set dm_resize->e_rep_seq = ", dm_resize->e_rep_seq,
   " go", row + 1, "set dm_resize->actual_days_activity = ",
   dm_resize->actual_days_activity, " go", row + 1,
   "set dm_resize->env_id = ", dm_resize->env_id, " go",
   row + 1, "set dm_resize->testing_mode = ", dm_resize->testing_mode,
   " go", row + 1, "set dm_resize->modify_next_extent_size = ",
   dm_resize->modify_next_extent_size, " go", row + 1,
   "set dm_resize->next_extent_size_days = ", dm_resize->next_extent_size_days, " go",
   row + 1, "set dm_resize->show_no_growth_objects = ", dm_resize->show_no_growth_objects,
   " go", row + 1, "execute dm_resizing go",
   row + 1
  WITH nocounter
 ;end select
#100_create_test_file_end
#200_delete_dm_resizing_temp
 SELECT INTO "nl:"
  table_name
  FROM user_tables
  WHERE table_name="DM_RESIZING_TEMP"
 ;end select
 IF (curqual > 0)
  DELETE  FROM dm_resizing_temp
   WHERE 1=1
   WITH nocounter
  ;end delete
  COMMIT
 ELSE
  CALL echo("")
  CALL echo("--> DM_RESIZING_TEMP table does not exist !!!!")
  CALL echo("")
  GO TO exit_script
 ENDIF
#200_delete_dm_resizing_temp_end
#1000_initialize
 SET block_size = 0.0
 SET objects_not_considered = 0
 SET partition_size = 0.0
 SET max_size = 0.0
 SET mbyte = (1024.0 * 1024.0)
 SET target_operating_system = fillstring(3," ")
 SET database_name = fillstring(6," ")
 SET root_dir_name = fillstring(80," ")
 SET disk_name = fillstring(30," ")
 SET total_size = 0.0
 SET filename1 = "dm_database_resizing_output"
 SELECT INTO value(filename1)
  d.*
  FROM dual d
  DETAIL
   ";dm_database_resizing_output", row + 1
  WITH format = stream, noheading, maxcol = 512,
   maxrow = 1, formfeed = none
 ;end select
 SELECT INTO "nl:"
  a.environment_id, a.environment_name, a.database_name,
  a.data_file_partition_size, a.max_file_size, a.target_operating_system,
  a.root_dir_name, a.disk_name
  FROM dm_environment a
  WHERE (a.environment_id=dm_resize->env_id)
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
     2 initial_free_space = f8
     2 initial_max_block = f8
     2 max_block = f8
     2 used_space = f8
     2 prev_used_space = f8
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
       3 initial_days_till_full = f8
       3 new_days_till_full = f8
       3 days_next_extent = f8
       3 extents = i4
       3 initial_extents = i4
       3 new_extents = i4
       3 next_extent = f8
       3 next_extent_kbytes = f8
       3 new_next_extent = f8
       3 new_next_extent_kbytes = f8
       3 pct_increase = i4
       3 row_count = f8
       3 bytes_per_row = f8
       3 blocks_per_row = f8
       3 new_row_count = f8
       3 rows_per_day = f8
       3 created = i4
       3 no_initial_space_data = i4
       3 no_final_space_data = i4
       3 consider_in_resize = i4
     2 object_count = i4
     2 new_file_name = vc
     2 new_file_size = f8
     2 raw_size = f8
     2 raw_size_mbytes = f8
     2 new_file_sequence = i4
     2 extent[*]
       3 file_id = i4
       3 blocks = f8
       3 initial_blocks = f8
     2 extent_count = i4
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
 SET stat = alterlist(tablespace_list->tablespace,10)
 SET tablespace_list->tablespace_count = 0
 SELECT INTO "nl:"
  FROM v$parameter v
  WHERE v.name="db_block_size"
  HEAD REPORT
   block_size = 0
  DETAIL
   block_size = cnvtint(v.value)
  WITH nocounter
 ;end select
 SET block_mbyte = (block_size/ mbyte)
 SET block_kbyte = (block_size/ 1024.0)
#1000_initialize_end
#1100_call_dm_space_capture
 CALL echo(build("-- dm_space_capture('",currdbuser,"',",dm_resize->testing_mode,",",
   dm_resize->s_rep_seq,",",dm_resize->e_rep_seq,")"))
 CALL parser(build('rdb asis("begin dm_space_capture(',"'",currdbuser,"', ",dm_resize->testing_mode,
   ",",dm_resize->s_rep_seq,",",dm_resize->e_rep_seq,'); end;") go'))
 CALL echo("CAPTURE_OF_PHYSICAL_DATA_COMPLETE")
 CALL echo("")
#1100_call_dm_space_capture_end
#2000_populate_data_structures
 SELECT
  IF ((dm_resize->testing_mode=1))
   WHERE (a.report_seq=dm_resize->e_rep_seq)
    AND outerjoin(a.tablespace_name)=d.tablespace_name
    AND outerjoin(a.segment_name)=d.segment_name
    AND b.report_seq=outerjoin(dm_resize->s_rep_seq)
    AND outerjoin(a.instance_cd)=b.instance_cd
    AND a.owner=currdbuser
    AND outerjoin(a.owner)=b.owner
    AND outerjoin(a.segment_name)=b.segment_name
    AND outerjoin(a.segment_type)=b.segment_type
    AND a.tablespace_name IN ("D_ORGANIZATION", "I_ORGANIZATION", "D_CODE", "I_CODE", "D_SCHED",
   "I_SCHED", "D_PERSON", "I_PERSON")
  ELSE
   WHERE (a.report_seq=dm_resize->e_rep_seq)
    AND outerjoin(a.tablespace_name)=d.tablespace_name
    AND outerjoin(a.segment_name)=d.segment_name
    AND b.report_seq=outerjoin(dm_resize->s_rep_seq)
    AND outerjoin(a.instance_cd)=b.instance_cd
    AND a.owner=currdbuser
    AND outerjoin(a.owner)=b.owner
    AND outerjoin(a.segment_name)=b.segment_name
    AND outerjoin(a.segment_type)=b.segment_type
  ENDIF
  INTO "nl:"
  a.report_seq, b.report_seq, a.instance_cd,
  b.instance_cd, a.segment_name, b.segment_name,
  d.segment_name, a.segment_type, b.segment_type,
  d.segment_type, a.owner, b.owner,
  a.tablespace_name, b.tablespace_name, d.tablespace_name,
  a.free_space, b.free_space, d.ublocks,
  a.total_space, b.total_space, d.tblocks,
  a.next_extent, b.next_extent, a.extents
  FROM space_objects a,
   space_objects b,
   dm_resizing_temp d
  ORDER BY a.tablespace_name, a.segment_type DESC, a.segment_name
  HEAD a.tablespace_name
   tablespace_list->tablespace_count = (tablespace_list->tablespace_count+ 1), tcount =
   tablespace_list->tablespace_count
   IF (mod(tcount,10)=1
    AND tcount != 1)
    stat = alterlist(tablespace_list->tablespace,(tcount+ 9))
   ENDIF
   tablespace_list->tablespace[tcount].tablespace_name = a.tablespace_name, tablespace_list->
   tablespace[tcount].e_rep_seq = a.report_seq, tablespace_list->tablespace[tcount].s_rep_seq = b
   .report_seq,
   tablespace_list->tablespace[tcount].instance_cd = a.instance_cd, tablespace_list->tablespace[
   tcount].space_to_add = 0.0, tablespace_list->tablespace[tcount].new_space_to_add = 0.0,
   tablespace_list->tablespace[tcount].free_space = 0.0, tablespace_list->tablespace[tcount].
   max_block = 0.0, tablespace_list->tablespace[tcount].used_space = 0.0,
   tablespace_list->tablespace[tcount].prev_used_space = 0.0, tablespace_list->tablespace[tcount].
   initial_free_space = 0.0, tablespace_list->tablespace[tcount].initial_max_block = 0.0,
   tablespace_list->tablespace[tcount].new_days_till_full = 0.0, tablespace_list->tablespace[tcount].
   exist_tablespace_ind = 1, tablespace_list->tablespace[tcount].object_count = 0,
   stat = alterlist(tablespace_list->tablespace[tcount].object,10)
  DETAIL
   tablespace_list->tablespace[tcount].object_count = (tablespace_list->tablespace[tcount].
   object_count+ 1), ocount = tablespace_list->tablespace[tcount].object_count
   IF (mod(ocount,10)=1
    AND ocount != 1)
    stat = alterlist(tablespace_list->tablespace[tcount].object,(ocount+ 9))
   ENDIF
   tablespace_list->tablespace[tcount].object[ocount].consider_in_resize = 1
   IF (b.total_space=0)
    tablespace_list->tablespace[tcount].object[ocount].no_initial_space_data = 1, tablespace_list->
    tablespace[tcount].object[ocount].consider_in_resize = 0
   ELSE
    tablespace_list->tablespace[tcount].object[ocount].no_initial_space_data = 0
   ENDIF
   IF (a.total_space=0)
    tablespace_list->tablespace[tcount].object[ocount].no_final_space_data = 1, tablespace_list->
    tablespace[tcount].object[ocount].consider_in_resize = 0
   ELSE
    tablespace_list->tablespace[tcount].object[ocount].no_final_space_data = 0
   ENDIF
   IF ((d.tblocks=- (1)))
    tablespace_list->tablespace[tcount].object[ocount].no_initial_space_data = 1, tablespace_list->
    tablespace[tcount].object[ocount].no_final_space_data = 1, tablespace_list->tablespace[tcount].
    object[ocount].consider_in_resize = 0
   ELSE
    tablespace_list->tablespace[tcount].object[ocount].no_initial_space_data = 0, tablespace_list->
    tablespace[tcount].object[ocount].no_final_space_data = 0
   ENDIF
   tablespace_list->tablespace[tcount].object[ocount].extents = a.extents, tablespace_list->
   tablespace[tcount].object[ocount].initial_extents = a.extents, tablespace_list->tablespace[tcount]
   .object[ocount].tablespace_name = a.tablespace_name,
   tablespace_list->tablespace[tcount].object[ocount].instance_cd = a.instance_cd, tablespace_list->
   tablespace[tcount].object[ocount].owner = a.owner, tablespace_list->tablespace[tcount].object[
   ocount].object_name = a.segment_name,
   tablespace_list->tablespace[tcount].object[ocount].object_type = a.segment_type, tablespace_list->
   tablespace[tcount].object[ocount].row_count = a.row_count
   IF ((d.tblocks != - (1)))
    tablespace_list->tablespace[tcount].object[ocount].sp_total = d.tblocks, tablespace_list->
    tablespace[tcount].object[ocount].sp_free = d.ublocks, tablespace_list->tablespace[tcount].
    object[ocount].sp_used = (d.tblocks - d.ublocks),
    tablespace_list->tablespace[tcount].used_space = (tablespace_list->tablespace[tcount].used_space
    + (d.tblocks - d.ublocks))
   ELSE
    tablespace_list->tablespace[tcount].object[ocount].sp_total = 0, tablespace_list->tablespace[
    tcount].object[ocount].sp_free = 0, tablespace_list->tablespace[tcount].object[ocount].sp_used =
    0
   ENDIF
   tablespace_list->tablespace[tcount].object[ocount].sp_allocated = 0.0, tablespace_list->
   tablespace[tcount].object[ocount].next_extent = a.next_extent, tablespace_list->tablespace[tcount]
   .object[ocount].next_extent_kbytes = (a.next_extent * (block_size/ 1024))
   IF (a.row_count > 0.0)
    tablespace_list->tablespace[tcount].object[ocount].blocks_per_row = ((a.total_space - a
    .free_space)/ (a.row_count * 1.0)), tablespace_list->tablespace[tcount].object[ocount].
    bytes_per_row = (tablespace_list->tablespace[tcount].object[ocount].blocks_per_row * block_size)
   ELSE
    tablespace_list->tablespace[tcount].object[ocount].blocks_per_row = (256.0/ block_size),
    tablespace_list->tablespace[tcount].object[ocount].bytes_per_row = 256.0
   ENDIF
   IF (b.segment_name=null)
    tablespace_list->tablespace[tcount].object[ocount].created = 1, tablespace_list->tablespace[
    tcount].object[ocount].sp_prev_used = 0.0, tablespace_list->tablespace[tcount].prev_used_space =
    0.0,
    tablespace_list->tablespace[tcount].object[ocount].new_row_count = a.row_count, tablespace_list->
    tablespace[tcount].object[ocount].rows_per_day = (a.row_count/ dm_resize->actual_days_activity),
    tablespace_list->tablespace[tcount].object[ocount].sp_consumed = tablespace_list->tablespace[
    tcount].object[ocount].sp_used,
    tablespace_list->tablespace[tcount].object[ocount].consider_in_resize = 0
   ELSE
    tablespace_list->tablespace[tcount].object[ocount].created = 0, tablespace_list->tablespace[
    tcount].object[ocount].sp_prev_used = (b.total_space - b.free_space), tablespace_list->
    tablespace[tcount].prev_used_space = ((tablespace_list->tablespace[tcount].prev_used_space+ b
    .total_space) - b.free_space)
    IF (a.row_count < b.row_count)
     tablespace_list->tablespace[tcount].object[ocount].new_row_count = 0, tablespace_list->
     tablespace[tcount].object[ocount].rows_per_day = 0, tablespace_list->tablespace[tcount].object[
     ocount].sp_consumed = 0
    ELSE
     tablespace_list->tablespace[tcount].object[ocount].new_row_count = (a.row_count - b.row_count),
     tablespace_list->tablespace[tcount].object[ocount].rows_per_day = ((a.row_count - b.row_count)/
     dm_resize->actual_days_activity), tablespace_list->tablespace[tcount].object[ocount].sp_consumed
      = ((a.total_space - a.free_space) - (b.total_space - b.free_space))
    ENDIF
   ENDIF
   IF ((tablespace_list->tablespace[tcount].object[ocount].consider_in_resize=0))
    objects_not_considered = 1
   ENDIF
   tablespace_list->tablespace[tcount].object[ocount].sp_consumed_daily = (tablespace_list->
   tablespace[tcount].object[ocount].sp_consumed/ dm_resize->actual_days_activity)
   IF ((tablespace_list->tablespace[tcount].object[ocount].sp_consumed_daily > 0))
    tablespace_list->tablespace[tcount].object[ocount].days_till_full = floor((tablespace_list->
     tablespace[tcount].object[ocount].sp_free/ tablespace_list->tablespace[tcount].object[ocount].
     sp_consumed_daily))
   ELSE
    tablespace_list->tablespace[tcount].object[ocount].days_till_full = 99999
   ENDIF
   tablespace_list->tablespace[tcount].object[ocount].initial_days_till_full = tablespace_list->
   tablespace[tcount].object[ocount].days_till_full
   IF ((dm_resize->modify_next_extent_size=1))
    tablespace_list->tablespace[tcount].object[ocount].new_next_extent = ceil((tablespace_list->
     tablespace[tcount].object[ocount].sp_consumed_daily * dm_resize->next_extent_size_days)),
    tablespace_list->tablespace[tcount].object[ocount].new_next_extent_kbytes = ceil(((
     tablespace_list->tablespace[tcount].object[ocount].sp_consumed_daily * dm_resize->
     next_extent_size_days) * (block_size/ 1024.0)))
    IF ((tablespace_list->tablespace[tcount].object[ocount].new_next_extent=0))
     tablespace_list->tablespace[tcount].object[ocount].new_next_extent = 1, tablespace_list->
     tablespace[tcount].object[ocount].new_next_extent_kbytes = (block_size/ 1024.0)
    ENDIF
   ELSE
    tablespace_list->tablespace[tcount].object[ocount].new_next_extent = tablespace_list->tablespace[
    tcount].object[ocount].next_extent, tablespace_list->tablespace[tcount].object[ocount].
    new_next_extent_kbytes = tablespace_list->tablespace[tcount].object[ocount].next_extent_kbytes
   ENDIF
   tablespace_list->tablespace[tcount].object[ocount].new_days_till_full = 0.0, tablespace_list->
   tablespace[tcount].object[ocount].space_to_add = 0.0, tablespace_list->tablespace[tcount].object[
   ocount].new_space_to_add = 0.0,
   tablespace_list->tablespace[tcount].object[ocount].over_allocated_space = 0.0
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET tablespace_list1->tablespace_count = 0
 SET stat = alterlist(tablespace_list1->tablespace,10)
 SELECT
  IF ((dm_resize->testing_mode=1))
   WHERE ((a.tablespace_name="D_SCD") OR (((a.tablespace_name="I_SCD") OR (a.tablespace_name=
   "I_PERSON")) ))
  ELSE
  ENDIF
  INTO "nl:"
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
        extent_count+ 1), ecnt = tablespace_list->tablespace[cnt].extent_count, stat = alterlist(
         tablespace_list->tablespace[cnt].extent,ecnt),
        tablespace_list->tablespace[cnt].extent[ecnt].file_id = tablespace_list1->tablespace[d.seq].
        extent[ecnt].file_id, tablespace_list->tablespace[cnt].extent[ecnt].blocks = tablespace_list1
        ->tablespace[d.seq].extent[ecnt].blocks
        IF ((tablespace_list->tablespace[cnt].initial_max_block < tablespace_list1->tablespace[d.seq]
        .extent[ecnt].blocks))
         tablespace_list->tablespace[cnt].initial_max_block = tablespace_list1->tablespace[d.seq].
         extent[ecnt].blocks
        ENDIF
        tablespace_list->tablespace[cnt].initial_free_space = (tablespace_list->tablespace[cnt].
        initial_free_space+ tablespace_list1->tablespace[d.seq].extent[ecnt].blocks)
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 FREE SET tablespace_list1
 SELECT
  IF ((dm_resize->testing_mode=1))
   WHERE ((a.tablespace_name="D_SCD") OR (((a.tablespace_name="I_SCD") OR (a.tablespace_name=
   "I_PERSON")) ))
  ELSE
  ENDIF
  INTO "nl:"
  a.tablespace_name, y = sum(a.bytes)
  FROM dba_data_files a
  GROUP BY a.tablespace_name
  DETAIL
   FOR (cnt = 1 TO tablespace_list->tablespace_count)
     IF ((tablespace_list->tablespace[cnt].tablespace_name=a.tablespace_name))
      tablespace_list->tablespace[cnt].space_allocated = y
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
#2000_populate_data_structures_end
#3000_determine_days_remaining
 SET max_days = 10000
 FOR (cnt = 1 TO tablespace_list->tablespace_count)
   SET done_indicator = 0
   SET day_counter = - (1)
   WHILE (done_indicator=0
    AND day_counter < max_days)
     IF (day_counter < 100)
      SET day_counter = (day_counter+ 1)
     ELSEIF (day_counter < 500)
      SET day_counter = (day_counter+ 5)
     ELSEIF (day_counter < 1000)
      SET day_counter = (day_counter+ 10)
     ELSE
      SET day_counter = (day_counter+ 100)
     ENDIF
     SET stop_ind = 1
     FOR (cnto = 1 TO tablespace_list->tablespace[cnt].object_count)
      SET stop_ind = 0
      IF ((tablespace_list->tablespace[cnt].object[cnto].days_till_full <= day_counter)
       AND (tablespace_list->tablespace[cnt].object[cnto].consider_in_resize=1))
       SET max_blocks = 0.0
       SET max_pos = 0
       FOR (j = 1 TO tablespace_list->tablespace[cnt].extent_count)
         IF ((tablespace_list->tablespace[cnt].extent[j].blocks > max_blocks))
          SET max_blocks = tablespace_list->tablespace[cnt].extent[j].blocks
          SET max_pos = j
         ENDIF
       ENDFOR
       IF ((dm_resize->testing_mode=1))
        CALL echo(concat("max_blocks ",cnvtstring(max_blocks)))
       ENDIF
       SET extents_to_add = ceil((tablespace_list->tablespace[cnt].object[cnto].sp_consumed_daily/
        tablespace_list->tablespace[cnt].object[cnto].next_extent))
       SET space_to_add = (tablespace_list->tablespace[cnt].object[cnto].next_extent * extents_to_add
       )
       IF (space_to_add <= max_blocks)
        SET tablespace_list->tablespace[cnt].object[cnto].extents = (tablespace_list->tablespace[cnt]
        .object[cnto].extents+ extents_to_add)
        SET tablespace_list->tablespace[cnt].object[cnto].space_to_add = (tablespace_list->
        tablespace[cnt].object[cnto].space_to_add+ space_to_add)
        SET tablespace_list->tablespace[cnt].space_to_add = (tablespace_list->tablespace[cnt].
        space_to_add+ space_to_add)
        SET tablespace_list->tablespace[cnt].object[cnto].days_till_full = (tablespace_list->
        tablespace[cnt].object[cnto].days_till_full+ floor((space_to_add/ tablespace_list->
         tablespace[cnt].object[cnto].sp_consumed_daily)))
        SET tablespace_list->tablespace[cnt].extent[max_pos].blocks = (tablespace_list->tablespace[
        cnt].extent[max_pos].blocks - space_to_add)
       ELSE
        SET done_indicator = 1
       ENDIF
      ENDIF
     ENDFOR
     IF (stop_ind=1)
      SET done_indicator = 1
     ENDIF
   ENDWHILE
   SET tablespace_list->tablespace[cnt].days_till_full = 99999
   FOR (cnto = 1 TO tablespace_list->tablespace[cnt].object_count)
     IF ((tablespace_list->tablespace[cnt].object[cnto].consider_in_resize=1))
      SET tablespace_list->tablespace[cnt].object[cnto].new_days_till_full = tablespace_list->
      tablespace[cnt].object[cnto].days_till_full
      IF ((tablespace_list->tablespace[cnt].object[cnto].days_till_full < tablespace_list->
      tablespace[cnt].days_till_full))
       SET tablespace_list->tablespace[cnt].days_till_full = tablespace_list->tablespace[cnt].object[
       cnto].days_till_full
      ENDIF
      SET tablespace_list->tablespace[cnt].object[cnto].new_extents = tablespace_list->tablespace[cnt
      ].object[cnto].extents
     ENDIF
   ENDFOR
   FOR (i = 1 TO tablespace_list->tablespace[cnt].extent_count)
    SET tablespace_list->tablespace[cnt].free_space = (tablespace_list->tablespace[cnt].free_space+
    tablespace_list->tablespace[cnt].extent[i].blocks)
    IF ((tablespace_list->tablespace[cnt].max_block < tablespace_list->tablespace[cnt].extent[i].
    blocks))
     SET tablespace_list->tablespace[cnt].max_block = tablespace_list->tablespace[cnt].extent[i].
     blocks
    ENDIF
   ENDFOR
 ENDFOR
#3000_determine_days_remaining_end
#4000_display_days_remaining
 SET nbr = 0
 SELECT
  IF ((dm_resize->show_no_growth_objects=0))
   WHERE (tablespace_list->tablespace[d.seq].days_till_full != 99999)
  ELSE
  ENDIF
  d.*
  FROM (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  ORDER BY tablespace_list->tablespace[d.seq].days_till_full
  HEAD REPORT
   "                         Days Each Object Will Last"
  DETAIL
   row + 2, "Tablespace Name            ", col 30,
   "Days Til Full", col 50, "Initial Free Space(KB)",
   col 75, "Free Space(KB)", col 95,
   "Initial Largest Free Chunk(KB)", col 130, "Largest Free Chunk(KB)",
   row + 1, tablespace_list->tablespace[d.seq].tablespace_name, col 32,
   tablespace_list->tablespace[d.seq].days_till_full"#####", oad = (tablespace_list->tablespace[d.seq
   ].initial_free_space * block_kbyte), col 50,
   oad, oad = (tablespace_list->tablespace[d.seq].free_space * block_kbyte), col 71,
   oad, oad = (tablespace_list->tablespace[d.seq].initial_max_block * block_kbyte), col 95,
   oad, oad = (tablespace_list->tablespace[d.seq].max_block * block_kbyte), col 130,
   oad, row + 1, "Object Name",
   col 32, "Days Til Next Extend", col 60,
   "Days Til Full", col 80, "Next Extent(KB)",
   col 100, "Initial Extents", col 120,
   "Extents", col 140, "Space consumed(KB)",
   col 160, "Space cons daily(KB)", row + 1
   FOR (cout = 1 TO tablespace_list->tablespace[d.seq].object_count)
     IF ((((dm_resize->show_no_growth_objects=1)) OR ((tablespace_list->tablespace[d.seq].object[cout
     ].days_till_full != 99999)))
      AND (tablespace_list->tablespace[d.seq].object[cout].consider_in_resize=1))
      tablespace_list->tablespace[d.seq].object[cout].object_name, col 37, tablespace_list->
      tablespace[d.seq].object[cout].initial_days_till_full"#####",
      col 66, tablespace_list->tablespace[d.seq].object[cout].days_till_full"#####", oad = (
      tablespace_list->tablespace[d.seq].object[cout].next_extent * block_kbyte),
      col 75, oad, col 98,
      tablespace_list->tablespace[d.seq].object[cout].initial_extents, col 114, tablespace_list->
      tablespace[d.seq].object[cout].extents,
      oad = (tablespace_list->tablespace[d.seq].object[cout].sp_consumed * block_kbyte), col 136, oad,
      oad = (tablespace_list->tablespace[d.seq].object[cout].sp_consumed_daily * block_kbyte), col
      158, oad,
      row + 1
     ENDIF
   ENDFOR
  WITH nocounter, maxcol = 300, format = variable,
   formfeed = none, maxrow = 1
 ;end select
#4000_display_days_remaining_end
#4500_show_objects_not_considered
 SET nbr = 0
 SELECT
  IF ((dm_resize->show_no_growth_objects=0))
   WHERE (tablespace_list->tablespace[d.seq].days_till_full != 99999)
  ELSE
  ENDIF
  d.*
  FROM (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  ORDER BY tablespace_list->tablespace[d.seq].tablespace_name
  HEAD REPORT
   "Objects excluded from the resizing process", row + 2, "Tablespace Name",
   col 31, "Object Name", col 62,
   "Reason for Exclusion", row + 1
  DETAIL
   FOR (cout = 1 TO tablespace_list->tablespace[d.seq].object_count)
     IF ((tablespace_list->tablespace[d.seq].object[cout].created=1))
      tablespace_list->tablespace[d.seq].tablespace_name, col 31, tablespace_list->tablespace[d.seq].
      object[cout].object_name,
      col 62, "Newly created object. Object not found in starting summary report.", row + 1
     ELSEIF ((tablespace_list->tablespace[d.seq].object[cout].no_initial_space_data=1))
      tablespace_list->tablespace[d.seq].tablespace_name, col 31, tablespace_list->tablespace[d.seq].
      object[cout].object_name,
      col 62, "Space data not captured in starting summary report.", row + 1
     ELSEIF ((tablespace_list->tablespace[d.seq].object[cout].no_final_space_data=1))
      tablespace_list->tablespace[d.seq].tablespace_name, col 31, tablespace_list->tablespace[d.seq].
      object[cout].object_name,
      col 62, "Space data not captured in ending summary report.", row + 1
     ENDIF
   ENDFOR
  WITH nocounter, maxcol = 300, format = variable,
   formfeed = none, maxrow = 1
 ;end select
#4500_show_objects_not_considered_end
#9000_display_new_days_remaining
 SET nbr = 0
 SELECT
  IF ((dm_resize->show_no_growth_objects=0))
   WHERE (tablespace_list->tablespace[d.seq].new_days_till_full != 99999)
  ELSE
  ENDIF
  d.*
  FROM (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  ORDER BY tablespace_list->tablespace[d.seq].new_days_till_full
  HEAD REPORT
   "                         Days Each Object Will Last With New Space Added"
  DETAIL
   row + 2, "Tablespace Name            ", col 30,
   "Days Til Full", col 50, "Previous Days Til Full",
   col 80, "Space Added(KB)", row + 1,
   tablespace_list->tablespace[d.seq].tablespace_name, col 35, tablespace_list->tablespace[d.seq].
   new_days_till_full"#####",
   col 55, tablespace_list->tablespace[d.seq].days_till_full"#####", oad = (tablespace_list->
   tablespace[d.seq].new_space_to_add * block_kbyte),
   col 76, oad, row + 1,
   "Object Name                   Days Till Full    Previous Days Till Full     Extents    ",
   "Previous Extents     Space Added(KB)      Next Extent(KB)    Previous Next Extent(KB)    Space used daily(KB)",
   row + 1
   FOR (cout = 1 TO tablespace_list->tablespace[d.seq].object_count)
     IF ((((dm_resize->show_no_growth_objects=1)) OR ((tablespace_list->tablespace[d.seq].object[cout
     ].new_days_till_full != 99999)))
      AND (tablespace_list->tablespace[d.seq].object[cout].consider_in_resize=1))
      tablespace_list->tablespace[d.seq].object[cout].object_name, col 37, tablespace_list->
      tablespace[d.seq].object[cout].new_days_till_full"#####",
      col 55, tablespace_list->tablespace[d.seq].object[cout].days_till_full"#####", col 75,
      tablespace_list->tablespace[d.seq].object[cout].new_extents"#####", col 91, tablespace_list->
      tablespace[d.seq].object[cout].extents"#####",
      oad = (tablespace_list->tablespace[d.seq].object[cout].new_space_to_add * block_kbyte), col 106,
      oad,
      oad = (tablespace_list->tablespace[d.seq].object[cout].new_next_extent * block_kbyte), col 127,
      oad,
      oad = (tablespace_list->tablespace[d.seq].object[cout].next_extent * block_kbyte), col 147, oad,
      oad = (tablespace_list->tablespace[d.seq].object[cout].sp_consumed_daily * block_kbyte), col
      175, oad,
      row + 1
     ENDIF
   ENDFOR
  WITH nocounter, maxcol = 300, format = variable,
   formfeed = none, maxrow = 1
 ;end select
#9000_display_new_days_remaining_end
#9001_display_new_days_remaining
 SET nbr = 0
 SELECT
  *
  FROM (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  WHERE (tablespace_list->tablespace[d.seq].new_days_till_full != tablespace_list->tablespace[d.seq].
  days_till_full)
  ORDER BY tablespace_list->tablespace[d.seq].new_space_to_add DESC
  HEAD REPORT
   "                         Database Resizing Summary", total_space = 0.0, min_days = 99999.0
  DETAIL
   row + 2, "Tablespace Name            ", col 30,
   "Days Til Full", col 50, "Previous Days Til Full",
   col 80, "Space Added (MBytes)", row + 1,
   tablespace_list->tablespace[d.seq].tablespace_name, col 35, tablespace_list->tablespace[d.seq].
   new_days_till_full"#####",
   col 55, tablespace_list->tablespace[d.seq].days_till_full"#####", oad = ((tablespace_list->
   tablespace[d.seq].new_space_to_add * block_size)/ mbyte),
   col 76, oad, total_space = (total_space+ tablespace_list->tablespace[d.seq].new_space_to_add)
   IF ((tablespace_list->tablespace[d.seq].new_days_till_full < min_days))
    min_days = tablespace_list->tablespace[d.seq].new_days_till_full
   ENDIF
   row + 1
  FOOT REPORT
   row + 1, "Total", col 30,
   "Days Til Full", col 80, "Space Added (Mbytes)",
   row + 1, col 35, min_days"#####",
   oad = ((total_space * block_size)/ mbyte), col 76, oad,
   row + 1
  WITH nocounter, maxcol = 300, format = variable,
   formfeed = none, maxrow = 1
 ;end select
 IF (curqual=0)
  SELECT
   d.*
   FROM dual d
   DETAIL
    "                         Database Resizing Summary", row + 2, "No space added.",
    row + 1
   WITH nocounter
  ;end select
 ENDIF
#9001_display_new_days_remaining_end
#5000_calculate_new_days
 SET new_free_space = dm_resize->space_to_consume
 SET new_free_space = round(((new_free_space * mbyte)/ block_size),0)
 SET done_indicator = 0
 SET target_day_counter = 0
 SET day_counter = 0
 WHILE (done_indicator=0)
  IF (day_counter < 100)
   SET day_counter = (day_counter+ 1)
  ELSEIF (day_counter < 500)
   SET day_counter = (day_counter+ 5)
  ELSEIF (day_counter < 1000)
   SET day_counter = (day_counter+ 10)
  ELSE
   SET day_counter = (day_counter+ 100)
  ENDIF
  FOR (i = 1 TO tablespace_list->tablespace_count)
    FOR (cout = 1 TO tablespace_list->tablespace[i].object_count)
      IF ((tablespace_list->tablespace[i].object[cout].new_days_till_full <= day_counter)
       AND (tablespace_list->tablespace[i].object[cout].consider_in_resize=1))
       SET extents_to_add = ceil((tablespace_list->tablespace[i].object[cout].sp_consumed_daily/
        tablespace_list->tablespace[i].object[cout].new_next_extent))
       SET space_to_add = (tablespace_list->tablespace[i].object[cout].new_next_extent *
       extents_to_add)
       IF (space_to_add <= new_free_space)
        SET tablespace_list->tablespace[i].object[cout].new_extents = (tablespace_list->tablespace[i]
        .object[cout].new_extents+ extents_to_add)
        SET new_free_space = ((new_free_space - space_to_add) - ceil((mbyte/ block_size)))
        SET tablespace_list->tablespace[i].object[cout].new_days_till_full = (tablespace_list->
        tablespace[i].object[cout].new_days_till_full+ ceil((space_to_add/ tablespace_list->
         tablespace[i].object[cout].sp_consumed_daily)))
        SET tablespace_list->tablespace[i].object[cout].new_space_to_add = (tablespace_list->
        tablespace[i].object[cout].new_space_to_add+ space_to_add)
       ELSE
        SET done_indicator = 1
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDWHILE
#5000_calculate_new_days_end
#5000_calculate_new_size
 SET target_day_counter = dm_resize->days_to_last
 SET done_indicator = 0
 FOR (i = 1 TO tablespace_list->tablespace_count)
   FOR (cout = 1 TO tablespace_list->tablespace[i].object_count)
     IF ((tablespace_list->tablespace[i].object[cout].days_till_full <= target_day_counter)
      AND (tablespace_list->tablespace[i].object[cout].consider_in_resize=1))
      SET new_days = (target_day_counter - tablespace_list->tablespace[i].object[cout].days_till_full
      )
      SET number_of_extents = ceil(((tablespace_list->tablespace[i].object[cout].sp_consumed_daily *
       new_days)/ tablespace_list->tablespace[i].object[cout].new_next_extent))
      SET tablespace_list->tablespace[i].object[cout].new_extents = (tablespace_list->tablespace[i].
      object[cout].new_extents+ number_of_extents)
      SET tablespace_list->tablespace[i].object[cout].new_space_to_add = (number_of_extents *
      tablespace_list->tablespace[i].object[cout].new_next_extent)
      SET tablespace_list->tablespace[i].object[cout].new_days_till_full = (tablespace_list->
      tablespace[i].object[cout].new_days_till_full+ round(((number_of_extents * tablespace_list->
       tablespace[i].object[cout].new_next_extent)/ tablespace_list->tablespace[i].object[cout].
       sp_consumed_daily),1))
     ENDIF
   ENDFOR
 ENDFOR
#5000_calculate_new_size_end
#5500_rollup_object_level_changes
 FOR (i = 1 TO tablespace_list->tablespace_count)
  SET tablespace_list->tablespace[i].new_days_till_full = 99999
  FOR (cnto = 1 TO tablespace_list->tablespace[i].object_count)
    IF ((tablespace_list->tablespace[i].object[cnto].consider_in_resize=1))
     IF ((tablespace_list->tablespace[i].object[cnto].new_days_till_full < tablespace_list->
     tablespace[i].new_days_till_full))
      SET tablespace_list->tablespace[i].new_days_till_full = tablespace_list->tablespace[i].object[
      cnto].new_days_till_full
     ENDIF
     SET tablespace_list->tablespace[i].new_space_to_add = (tablespace_list->tablespace[i].
     new_space_to_add+ tablespace_list->tablespace[i].object[cnto].new_space_to_add)
    ENDIF
  ENDFOR
 ENDFOR
#5500_rollup_object_level_changes_end
#6001_calculate_over_allocated
 SET over_allocate_exist = 0
 FOR (i = 1 TO tablespace_list->tablespace_count)
   IF ((tablespace_list->tablespace[i].days_till_full=99999))
    SET over_allocate_exist = 1
   ENDIF
 ENDFOR
 IF (over_allocate_exist=1)
  SET oad = 0.0
  SELECT
   d.*
   FROM (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
   WHERE (tablespace_list->tablespace[d.seq].days_till_full=99999)
   ORDER BY tablespace_list->tablespace[d.seq].tablespace_name
   HEAD REPORT
    "Over Allocation Report", row + 2
   DETAIL
    row + 1,
    "Tablespace Name             Total Space(MBytes)       Used Space(MBytes)      Unallocated Space(MBytes)",
    r,
    tablespace_list->tablespace[d.seq].tablespace_name, oad = (tablespace_list->tablespace[d.seq].
    space_allocated/ mbyte), col 29,
    oad, oad = ((tablespace_list->tablespace[d.seq].used_space * block_size)/ mbyte), col 49,
    oad, oad = ((tablespace_list->tablespace[d.seq].initial_free_space * block_size)/ mbyte), col 74,
    oad, row + 1,
    "Object Name                 Allocated Space(MBytes)   Used Space(MBytes)      Rows",
    row + 1
    FOR (cout = 1 TO tablespace_list->tablespace[d.seq].object_count)
      IF ((tablespace_list->tablespace[d.seq].object[cout].consider_in_resize=1))
       tablespace_list->tablespace[d.seq].object[cout].object_name, oad = ((tablespace_list->
       tablespace[d.seq].object[cout].sp_total * block_size)/ mbyte), col 29,
       oad, oad = ((tablespace_list->tablespace[d.seq].object[cout].sp_used * block_size)/ mbyte),
       col 49,
       oad, col 74, tablespace_list->tablespace[d.seq].object[cout].row_count,
       row + 1
      ENDIF
    ENDFOR
   WITH nocounter, maxcol = 255, formfeed = none,
    maxrow = 1
  ;end select
 ELSE
  SELECT
   d.*
   FROM dual
   HEAD REPORT
    "Over Allocation Report", row + 2
   DETAIL
    row + 1, "No over allocated objects"
   WITH nocounter, maxcol = 255, formfeed = none,
    maxrow = 1
  ;end select
 ENDIF
#6001_calculate_over_allocated_end
#8000_generate_output_files
 FOR (i = 1 TO tablespace_list->tablespace_count)
   SELECT INTO value(filename1)
    d.*
    FROM (dummyt d  WITH seq = value(tablespace_list->tablespace[i].object_count))
    WHERE (tablespace_list->tablespace[i].object[d.seq].new_next_extent > 0)
     AND (tablespace_list->tablespace[i].object[d.seq].new_next_extent != tablespace_list->
    tablespace[i].object[d.seq].next_extent)
    DETAIL
     IF ((tablespace_list->tablespace[i].object[d.seq].object_type="T"))
      "rdb ALTER TABLE "
     ELSE
      "rdb ALTER INDEX "
     ENDIF
     tablespace_list->tablespace[i].object[d.seq].new_next_extent_kbytes = (tablespace_list->
     tablespace[i].object[d.seq].new_next_extent * (block_size/ 1024.0)), tablespace_list->
     tablespace[i].object[d.seq].object_name, row + 1,
     " STORAGE (NEXT ", tablespace_list->tablespace[i].object[d.seq].new_next_extent_kbytes"########",
     " K  ",
     "PCTINCREASE 0) GO ", row + 1
    WITH format = stream, noheading, maxcol = 512,
     maxrow = 1, formfeed = none, append
   ;end select
 ENDFOR
#8000_generate_output_files_end
#10000_update_env_tables
 DELETE  FROM dm_env_files
  WHERE (environment_id=dm_resize->env_id)
 ;end delete
 DELETE  FROM dm_env_table
  WHERE (environment_id=dm_resize->env_id)
 ;end delete
 DELETE  FROM dm_env_index
  WHERE (environment_id=dm_resize->env_id)
 ;end delete
 IF (target_operating_system != "AIX")
  SELECT INTO "nl:"
   y = count(*), a.tablespace_name
   FROM dba_data_files a
   GROUP BY a.tablespace_name
   DETAIL
    FOR (i = 1 TO tablespace_list->tablespace_count)
      IF ((a.tablespace_name=tablespace_list->tablespace[i].tablespace_name)
       AND (tablespace_list->tablespace[i].new_space_to_add > 0))
       tablespace_list->tablespace[i].new_file_name = build(tablespace_list->tablespace[i].
        tablespace_name,"_",format(cnvtstring(y),"##;P0")), tablespace_list->tablespace[i].
       new_file_size = (ceil((tablespace_list->tablespace[i].new_space_to_add * block_size))/ mbyte),
       tablespace_list->tablespace[i].new_file_size = (ceil((tablespace_list->tablespace[i].
        new_file_size/ partition_size)) * partition_size),
       tablespace_list->tablespace[i].new_file_size = (tablespace_list->tablespace[i].new_file_size
        * mbyte)
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ELSE
  FOR (i = 1 TO tablespace_list->tablespace_count)
    IF ((tablespace_list->tablespace[i].new_space_to_add > 0))
     SET tablespace_list->tablespace[i].raw_size_mbytes = ceil((((tablespace_list->tablespace[i].
      new_space_to_add * block_size)/ mbyte)+ 1))
     SET tablespace_list->tablespace[i].raw_size_mbytes = (ceil((tablespace_list->tablespace[i].
      raw_size_mbytes/ partition_size)) * partition_size)
     SET tablespace_list->tablespace[i].raw_size = (tablespace_list->tablespace[i].raw_size_mbytes *
     mbyte)
    ENDIF
  ENDFOR
  RECORD size_sequences(
    1 sseq[*]
      2 file_size_mbytes = f8
      2 file_count = i4
    1 size_sequence_count = i4
  )
  SET size_sequences->size_sequence_count = 0
  SELECT INTO "nl:"
   y = count(*), a.bytes
   FROM dba_data_files a
   GROUP BY a.bytes
   DETAIL
    found = 0
    FOR (i = 1 TO size_sequences->size_sequence_count)
      IF ((size_sequences->sseq[i].file_size_mbytes=(a.bytes * mbyte)))
       size_sequences->sseq[i].file_count = (size_sequences->sseq[i].file_count+ 1), found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     size_sequences->size_sequence_count = (size_sequences->size_sequence_count+ 1), stat = alterlist
     (size_sequences->sseq,size_sequences->size_sequence_count), size_sequences->sseq[size_sequences
     ->size_sequence_count].file_count = 1,
     size_sequences->sseq[size_sequences->size_sequence_count].file_size_mbytes = (a.bytes * mbyte)
    ENDIF
   WITH nocounter
  ;end select
  FOR (j = 1 TO tablespace_list->tablespace_count)
    SET found = 0
    FOR (i = 1 TO size_sequences->size_sequence_count)
      IF ((size_sequences->sseq[i].file_size_mbytes=tablespace_list->tablespace[j].raw_size_mbytes))
       SET size_sequences->sseq[i].file_count = (size_sequences->sseq[i].file_count+ 1)
       SET tablespace_list->tablespace[j].new_file_sequence = size_sequences->sseq[i].file_count
       SET found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     SET size_sequences->size_sequence_count = (size_sequences->size_sequence_count+ 1)
     SET stat = alterlist(size_sequences->sseq,size_sequences->size_sequence_count)
     SET size_sequences->sseq[size_sequences->size_sequence_count].file_count = 1
     SET size_sequences->sseq[size_sequences->size_sequence_count].file_size_mbytes = tablespace_list
     ->tablespace[j].raw_size_mbytes
     SET tablespace_list->tablespace[j].new_file_sequence = 1
    ENDIF
    SET tablespace_list->tablespace[j].new_file_name = build(cnvtlower(database_name),"_",format(
      cnvtstring(tablespace_list->tablespace[j].raw_size_mbytes),"####;P0"),"_",format(cnvtstring(
       tablespace_list->tablespace[j].new_file_sequence),"###;P0"))
    SET tablespace_list->tablespace[j].new_file_size = tablespace_list->tablespace[j].raw_size
  ENDFOR
 ENDIF
 FOR (i = 1 TO tablespace_list->tablespace_count)
   IF ((tablespace_list->tablespace[i].new_file_size > 0))
    INSERT  FROM dm_env_files def
     SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
      def.updt_id = 0, def.updt_task = 0, def.file_type =
      IF (substring(1,1,tablespace_list->tablespace[i].tablespace_name)="I") "INDEX"
      ELSEIF (substring(1,1,tablespace_list->tablespace[i].tablespace_name)="D") "DATA"
      ENDIF
      ,
      def.file_size = tablespace_list->tablespace[i].new_file_size, def.size_sequence =
      tablespace_list->tablespace[i].new_file_sequence, def.environment_id = dm_resize->env_id,
      def.tablespace_name = tablespace_list->tablespace[i].tablespace_name, def.file_name =
      tablespace_list->tablespace[i].new_file_name, def.tablespace_exist_ind = 1
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  a.tablespace_name
  FROM dm_tablespace a,
   (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  PLAN (d)
   JOIN (a
   WHERE (a.tablespace_name=tablespace_list->tablespace[d.seq].tablespace_name)
    AND  NOT (a.tablespace_name IN (
   (SELECT
    dt.tablespace_name
    FROM dm_tablespace dt))))
  DETAIL
   tablespace_list->tablespace[d.seq].exist_tablespace_ind = 0
  WITH nocounter
 ;end select
 FOR (cnt = 1 TO tablespace_list->tablespace_count)
   IF ((tablespace_list->tablespace[cnt].exist_tablespace_ind=0))
    INSERT  FROM dm_tablespace dt
     SET dt.updt_applctx = 0, dt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dt.updt_cnt = 0,
      dt.updt_id = 0, dt.updt_task = 0, dt.tablespace_name = tablespace_list->tablespace[cnt].
      tablespace_name,
      dt.initial_extent = tablespace_list->tablespace[cnt].initial_extent, dt.next_extent =
      tablespace_list->tablespace[cnt].next_extent, dt.pctincrease = 0,
      dt.weighting = 0
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 COMMIT
#10000_update_env_tables_end
#11000_output_debug_info
 SELECT
  IF ((dm_resize->testing_mode=1))INTO mine
  ELSE INTO "dm_resize"
  ENDIF
  d.*
  FROM (dummyt d  WITH seq = value(tablespace_list->tablespace_count))
  PLAN (d)
  DETAIL
   tablespace_list->tablespace[d.seq].tablespace_name, row + 1, " space_allocated     ",
   tablespace_list->tablespace[d.seq].space_allocated, " space_to_add                ",
   tablespace_list->tablespace[d.seq].space_to_add,
   " new_space_to_add    ", tablespace_list->tablespace[d.seq].new_space_to_add,
   " free_space                  ",
   tablespace_list->tablespace[d.seq].free_space, " initial_free_space  ", tablespace_list->
   tablespace[d.seq].initial_free_space,
   " initial_max_block   ", tablespace_list->tablespace[d.seq].initial_max_block,
   " max_block                   ",
   tablespace_list->tablespace[d.seq].max_block, row + 1, " used_space                  ",
   tablespace_list->tablespace[d.seq].used_space, " prev_used_space     ", tablespace_list->
   tablespace[d.seq].prev_used_space,
   " days_till_full              ", tablespace_list->tablespace[d.seq].days_till_full,
   " new_days_till_full  ",
   tablespace_list->tablespace[d.seq].new_days_till_full, " days_remaining              ",
   tablespace_list->tablespace[d.seq].days_remaining,
   " partitioned_bytes   ", tablespace_list->tablespace[d.seq].partitioned_bytes,
   " exist_tablespace_ind",
   tablespace_list->tablespace[d.seq].exist_tablespace_ind, row + 1, " object_count                ",
   tablespace_list->tablespace[d.seq].object_count, " new_file_name               ", tablespace_list
   ->tablespace[d.seq].new_file_name,
   " new_file_size               ", tablespace_list->tablespace[d.seq].new_file_size,
   " raw_size                    ",
   tablespace_list->tablespace[d.seq].raw_size, " raw_size_mbytes     ", tablespace_list->tablespace[
   d.seq].raw_size_mbytes,
   " new_file_sequence   ", tablespace_list->tablespace[d.seq].new_file_sequence, row + 4
  WITH counter, maxcol = 512
 ;end select
#11000_output_debug_info_end
#exit_script
END GO
