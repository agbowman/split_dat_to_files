CREATE PROGRAM dm_sql_snapshot:dba
 PAINT
 SET starting_test_sequence = 1
 SET ending_test_sequence = 2
 SET delete_test_ans = "N"
#top
 SET delete_test_sequence = 0
 CALL video(r)
 CALL clear(1,1)
 CALL box(3,2,23,79)
 CALL text(2,2,"DM SQL Snapshot Reporting")
 CALL text(5,3,"1 - Test Sequence Report")
 CALL text(7,3,build("2 - Starting Test Sequence -",starting_test_sequence))
 CALL text(9,3,build("3 - Ending Test Sequence -",ending_test_sequence))
 CALL text(11,3,"4 - Create Test Sequence")
 CALL text(13,3,"5 - Script Analysis")
 CALL text(15,3,"6 - SQL Analysis")
 CALL text(17,3,"7 - SQL Plan Analysis")
 CALL text(19,3,"8 - Reload Analysis")
 CALL text(21,3,"9 - Drop Test Sequence")
 CALL text(21,55,"10 - Quit")
 CALL text(24,02,"Select 1,2,3,4,5,6,7,8,9 or 10: ")
 CALL accept(24,61,"PP;CU")
 IF (curaccept="10")
  GO TO done
 ELSEIF (curaccept="1")
  SELECT
   test_sequence, updt_dt_tm"dd-mmm-yyyy hh:mm:ss;;d", description,
   user_name
   FROM dm_sql_test_sequences
   ORDER BY test_sequence DESC
   WITH nocounter
  ;end select
  GO TO top
 ELSEIF (curaccept="5")
  EXECUTE FROM script2_analysis TO script2_analysis_end
  GO TO top
 ELSEIF (curaccept="6")
  EXECUTE FROM sql2_analysis TO sql2_analysis_end
  GO TO top
 ELSEIF (curaccept="2")
  CALL video(r)
  CALL clear(1,1)
  CALL box(14,1,16,79)
  CALL video(n)
  CALL text(15,02,"Enter the starting test sequence: ")
  CALL accept(15,61,"N(9)","1")
  SET starting_test_sequence = cnvtint(curaccept)
  GO TO top
 ELSEIF (curaccept="3")
  CALL video(r)
  CALL clear(1,1)
  CALL box(14,1,16,79)
  CALL video(n)
  CALL text(15,02,"Enter the ending test sequence: ")
  CALL accept(15,61,"N(9)","2")
  SET ending_test_sequence = cnvtint(curaccept)
  GO TO top
 ELSEIF (curaccept="8")
  EXECUTE FROM reload_analysis TO reload_analysis_end
  GO TO top
 ELSEIF (curaccept="7")
  CALL video(r)
  CALL clear(1,1)
  CALL box(14,1,16,79)
  CALL video(n)
  CALL text(15,02,"Enter the snapshot id of the statement to analyze: ")
  CALL accept(15,61,"N(9)","1")
  SET snapshot_id = cnvtint(curaccept)
  EXECUTE FROM sql_plan_analysis TO sql_plan_analysis_end
  GO TO top
 ELSEIF (curaccept="4")
  CALL video(r)
  CALL clear(1,1)
  CALL box(14,1,16,79)
  CALL video(n)
  CALL text(15,02,"Enter the test sequence for this snapshot HELP: <SHIFT><F5>: ")
  SET help =
  SELECT INTO "nl:"
   test_sequence";l", user_name, description
   FROM dm_sql_test_sequences
   ORDER BY test_sequence DESC
   WITH nocounter
  ;end select
  CALL accept(15,68,"N(9);S",ending_test_sequence)
  SET ending_test_sequence = curaccept
  SET test_sequence_description = fillstring(70," ")
  SELECT INTO "nl:"
   dst.description
   FROM dm_sql_test_sequences dst
   WHERE dst.test_sequence=ending_test_sequence
   DETAIL
    test_sequence_description = dst.description
   WITH nocounter
  ;end select
  CALL clear(1,1)
  CALL box(14,1,17,79)
  CALL video(n)
  CALL text(15,2,"Enter the description for this test sequence: ")
  CALL accept(16,2,"P(70);C",test_sequence_description)
  SET test_sequence_description = curaccept
  CALL video(r)
  CALL clear(1,1)
  CALL box(14,1,16,79)
  CALL video(n)
  CALL text(15,02,"Capturing Snapshot, Please Wait...")
  EXECUTE FROM dm_sql_snapshot_capture TO dm_sql_snapshot_capture_end
  GO TO top
 ELSEIF (curaccept="9")
  CALL video(r)
  CALL clear(1,1)
  CALL box(17,1,21,50)
  CALL video(n)
  CALL text(18,02,build("Enter the test sequence to be deleted : ",delete_test_sequence))
  SET help =
  SELECT INTO "nl:"
   test_sequence";l", user_name, description
   FROM dm_sql_test_sequences
   ORDER BY test_sequence DESC
   WITH nocounter
  ;end select
  CALL accept(18,41,"N(9);F")
  SET delete_test_sequence = cnvtint(curaccept)
  CALL video(r)
  CALL clear(1,1)
  CALL box(17,1,21,50)
  CALL video(n)
  CALL text(18,02,build("Enter the test sequence to be deleted : ",delete_test_sequence))
  CALL text(20,24,"Continue (Y / N) :")
  CALL accept(20,41,"P;CU",delete_test_ans
   WHERE curaccept IN ("Y", "N"))
  SET delete_test_ans = cnvtupper(curaccept)
  IF (delete_test_ans="Y")
   CALL video(rb)
   CALL clear(23,1)
   CALL text(23,1,"Processing ... ")
   CALL video(n)
   DELETE  FROM dm_sql_test_sequences dt
    WHERE dt.test_sequence=delete_test_sequence
   ;end delete
   COMMIT
   DELETE  FROM dm_sql_snapshot ds
    WHERE ds.test_sequence=delete_test_sequence
   ;end delete
   COMMIT
   CALL video(rb)
   CALL clear(23,1)
   CALL text(23,1,"Done ... ")
   CALL video(n)
  ENDIF
  GO TO top
 ELSE
  GO TO top
 ENDIF
#script2_analysis
 EXECUTE FROM get_snapshot_values TO get_snapshot_values_end
 FREE SET script_list
 RECORD script_list(
   1 script_count = i4
   1 total_hard_gets = f8
   1 total_soft_gets = f8
   1 list[*]
     2 script_name = c32
     2 net_soft_gets = f8
     2 net_hard_gets = f8
     2 net_executions = f8
 )
 SET script_list->script_count = 0
 SET last_script_name = fillstring(80," ")
 SET first_time = 1
 SET executions = 0.0
 SET hard_gets = 0.0
 SET soft_gets = 0.0
 SET script_list->total_hard_gets = 0.0
 SET script_list->total_soft_gets = 0.0
 SET ratio = 0.0
 FOR (i = 1 TO sql_list->sql_count)
   IF ((last_script_name != sql_list->list[i].script_name)
    AND first_time=0)
    SET script_list->script_count = (script_list->script_count+ 1)
    IF (mod(script_list->script_count,10)=1)
     SET stat = alterlist(script_list->list,(script_list->script_count+ 9))
    ENDIF
    SET script_list->list[script_list->script_count].script_name = last_script_name
    SET script_list->list[script_list->script_count].net_executions = executions
    SET script_list->list[script_list->script_count].net_soft_gets = soft_gets
    SET script_list->list[script_list->script_count].net_hard_gets = hard_gets
    SET executions = 0.0
    SET hard_gets = 0.0
    SET soft_gets = 0.0
    SET last_script_name = sql_list->list[i].script_name
   ENDIF
   IF (first_time=1)
    SET last_script_name = sql_list->list[i].script_name
    SET first_time = 0
   ENDIF
   IF ((sql_list->list[i].beg_executions != - (1)))
    SET executions = (executions+ (sql_list->list[i].end_executions - sql_list->list[i].
    beg_executions))
    SET soft_gets = (soft_gets+ (sql_list->list[i].end_soft_gets - sql_list->list[i].beg_soft_gets))
    SET hard_gets = (hard_gets+ (sql_list->list[i].end_hard_gets - sql_list->list[i].beg_hard_gets))
   ENDIF
 ENDFOR
 IF (first_time=0)
  SET script_list->script_count = (script_list->script_count+ 1)
  IF (mod(script_list->script_count,10)=1)
   SET stat = alterlist(script_list->list,(script_list->script_count+ 9))
  ENDIF
  SET script_list->list[script_list->script_count].script_name = last_script_name
  SET script_list->list[script_list->script_count].net_executions = executions
  SET script_list->list[script_list->script_count].net_soft_gets = soft_gets
  SET script_list->list[script_list->script_count].net_hard_gets = hard_gets
 ENDIF
 SELECT
  d.seq
  FROM (dummyt d  WITH seq = value(script_list->script_count))
  WHERE (script_list->list[d.seq].net_executions > 0)
  ORDER BY script_list->list[d.seq].net_soft_gets DESC
  HEAD REPORT
   "SCRIPT NAME", col 35, "BUFFER_GETS",
   col 50, "EXECUTIONS", col 65,
   "DISK GETS", col 80, "GETS/EXECUTION",
   row + 1
  DETAIL
   script_list->list[d.seq].script_name, col 35, script_list->list[d.seq].net_soft_gets,
   col 50, script_list->list[d.seq].net_executions, col 65,
   script_list->list[d.seq].net_hard_gets, col 80, script_list->total_soft_gets = (script_list->
   total_soft_gets+ script_list->list[d.seq].net_soft_gets),
   script_list->total_hard_gets = (script_list->total_hard_gets+ script_list->list[d.seq].
   net_hard_gets), ratio = (script_list->list[d.seq].net_soft_gets/ script_list->list[d.seq].
   net_executions), ratio,
   row + 1
  FOOT REPORT
   "Total", col 35, script_list->total_soft_gets,
   col 65, script_list->total_hard_gets, col 80,
   script_list->total_soft_gets = (script_list->total_soft_gets+ script_list->total_hard_gets),
   script_list->total_soft_gets, row + 1
  WITH nocounter, maxcol = 255
 ;end select
 SET script_list->total_hard_gets = 0.0
 SET script_list->total_soft_gets = 0.0
 SELECT
  d.seq
  FROM (dummyt d  WITH seq = value(script_list->script_count))
  WHERE (script_list->list[d.seq].net_executions > 0)
  ORDER BY script_list->list[d.seq].script_name
  HEAD REPORT
   "SCRIPT NAME", col 35, "BUFFER_GETS",
   col 50, "EXECUTIONS", col 65,
   "DISK GETS", col 80, "GETS/EXECUTION",
   row + 1
  DETAIL
   script_list->list[d.seq].script_name, col 35, script_list->list[d.seq].net_soft_gets,
   col 50, script_list->list[d.seq].net_executions, col 65,
   script_list->list[d.seq].net_hard_gets, col 80, script_list->total_soft_gets = (script_list->
   total_soft_gets+ script_list->list[d.seq].net_soft_gets),
   script_list->total_hard_gets = (script_list->total_hard_gets+ script_list->list[d.seq].
   net_hard_gets), ratio = (script_list->list[d.seq].net_soft_gets/ script_list->list[d.seq].
   net_executions), ratio,
   row + 1
  FOOT REPORT
   "Total", col 35, script_list->total_soft_gets,
   col 65, script_list->total_hard_gets, col 80,
   script_list->total_soft_gets = (script_list->total_soft_gets+ script_list->total_hard_gets),
   script_list->total_soft_gets, row + 1
  WITH nocounter, maxcol = 255
 ;end select
#script2_analysis_end
#dm_sql_snapshot_capture
 CALL parser(concat('rdb asis("begin dm_sql_snapshot_capture(',cnvtstring(ending_test_sequence),", '",
   test_sequence_description,"'",
   '); end;") go'))
#dm_sql_snapshot_capture_end
#sql_plan_analysis
 SET snapshot_id_str = cnvtstring(snapshot_id)
 FREE SET stmt
 RECORD stmt(
   1 current_stmt = vc
 )
 SELECT INTO "nl:"
  dm1.stmt
  FROM dm_sql_snapshot dm1
  WHERE dm1.snapshot_id=snapshot_id
  DETAIL
   stmt->current_stmt = trim(dm1.stmt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT
   d.*
   FROM dual d
   DETAIL
    "No statement found for snapshot_id = ", tempstr = snapshot_id_str, tempstr,
    row + 1, "Obtain a snapshot_id by running the SQL Analysis menu option", row + 1
   WITH nocounter, maxrow = 1, noformfeed,
    maxcol = 200
  ;end select
  GO TO top
 ENDIF
 DELETE  FROM dm_sql_plan
  WHERE statement_id=cnvtstring(snapshot_id)
 ;end delete
 SET new_snapshot_id_str = build("'",snapshot_id_str,"'")
 CALL parser(concat('rdb asis ("explain plan set statement_id = ',new_snapshot_id_str,
   " into dm_sql_plan for ",stmt->current_stmt,'") go'),1)
 FREE SET index_records
 RECORD index_records(
   1 index_count = i4
   1 indexes[*]
     2 index_name = vc
     2 column_string = vc
 )
 SET index_records->index_count = 0
 SET tempstr2 = fillstring(255," ")
 SELECT INTO "nl:"
  dsp.object_name, uic.column_name, uic.column_position
  FROM user_ind_columns uic,
   dm_sql_plan dsp
  WHERE dsp.statement_id=snapshot_id_str
   AND dsp.operation="INDEX"
   AND uic.index_name=dsp.object_name
  ORDER BY dsp.object_name, uic.column_position
  HEAD dsp.object_name
   index_records->index_count = (index_records->index_count+ 1), stat = alterlist(index_records->
    indexes,index_records->index_count), index_records->indexes[index_records->index_count].
   index_name = dsp.object_name,
   i = 0
  DETAIL
   i = (i+ 1)
   IF (i > 1)
    tempstr2 = trim(concat(trim(tempstr2),",",uic.column_name))
   ELSE
    tempstr2 = trim(uic.column_name)
   ENDIF
  FOOT  dsp.object_name
   index_records->indexes[index_records->index_count].column_string = tempstr2
  WITH nocounter
 ;end select
 FOR (i = 1 TO index_records->index_count)
  UPDATE  FROM dm_sql_plan dsp
   SET dsp.index_columns = index_records->indexes[i].column_string
   WHERE dsp.statement_id=snapshot_id_str
    AND dsp.operation="INDEX"
    AND (dsp.object_name=index_records->indexes[i].index_name)
  ;end update
  COMMIT
 ENDFOR
 SELECT
  p.statement_id, p.id, p.parent_id,
  x = cnvtint(p.parent_id), p.operation, p.options,
  p.object_name
  FROM dm_sql_plan p
  WHERE p.statement_id=snapshot_id_str
  ORDER BY p.id, p.parent_id
  HEAD REPORT
   line = fillstring(130,"=")
  HEAD p.statement_id
   "plan statement for ", p.statement_id, row + 1,
   loops = ((textlen(stmt->current_stmt)/ 125)+ 1)
   FOR (i = 1 TO loops)
     tempstr = substring((((i - 1) * 125)+ 1),125,stmt->current_stmt), tempstr, row + 1
   ENDFOR
   line, row + 1
  DETAIL
   p.id"#####", col + 1, col + (2 * x),
   p.parent_id"####", col + 2, p.operation,
   col + 1, p.options, col + 1,
   p.object_name, col + 1, p.index_columns,
   row + 1
  WITH nocounter, maxrow = 1, noformfeed,
   maxcol = 1024
 ;end select
#sql_plan_analysis_end
#sql2_analysis
 EXECUTE FROM get_snapshot_values TO get_snapshot_values_end
 SELECT
  buffer_gets = (sql_list->list[d.seq].end_soft_gets - sql_list->list[d.seq].beg_soft_gets), '"',
  executions = (sql_list->list[d.seq].end_executions - sql_list->list[d.seq].beg_executions),
  '"', hard_gets = (sql_list->list[d.seq].end_hard_gets - sql_list->list[d.seq].beg_hard_gets), '"',
  dm1.script_name, '"', dm1.snapshot_id,
  '"', dm1.stmt
  FROM dm_sql_snapshot dm1,
   (dummyt d  WITH seq = value(sql_list->sql_count))
  PLAN (d
   WHERE ((sql_list->list[d.seq].end_executions - sql_list->list[d.seq].beg_executions) > 0)
    AND (sql_list->list[d.seq].beg_executions != - (1)))
   JOIN (dm1
   WHERE dm1.test_sequence=ending_test_sequence
    AND (dm1.stmt_hash_value=sql_list->list[d.seq].stmt_hash_value))
  ORDER BY (sql_list->list[d.seq].end_soft_gets - sql_list->list[d.seq].beg_soft_gets) DESC
 ;end select
#sql2_analysis_end
#reload_analysis
 EXECUTE FROM get_snapshot_values TO get_snapshot_values_end
 SELECT
  executions = (sql_list->list[d.seq].end_executions - sql_list->list[d.seq].beg_executions), dm1
  .script_name, dm1.stmt
  FROM dm_sql_snapshot dm1,
   (dummyt d  WITH seq = value(sql_list->sql_count))
  PLAN (d
   WHERE (sql_list->list[d.seq].beg_executions=- (1)))
   JOIN (dm1
   WHERE dm1.test_sequence=ending_test_sequence
    AND (dm1.stmt_hash_value=sql_list->list[d.seq].stmt_hash_value))
  ORDER BY sql_list->list[d.seq].end_executions DESC, dm1.script_name
 ;end select
#reload_analysis_end
#get_snapshot_values
 SET load_structure_needed = 1
 IF (validate(sql_list,"NOT FOUND") != "NOT FOUND")
  IF ((sql_list->starting_test_sequence=starting_test_sequence)
   AND (sql_list->ending_test_sequence=ending_test_sequence))
   SET load_structure_needed = 0
  ENDIF
 ENDIF
 IF (load_structure_needed=1)
  RECORD sql_list(
    1 sql_count = i4
    1 ending_test_sequence = i4
    1 starting_test_sequence = i4
    1 list[*]
      2 script_name = c32
      2 end_soft_gets = f8
      2 end_hard_gets = f8
      2 end_executions = f8
      2 beg_soft_gets = f8
      2 beg_hard_gets = f8
      2 beg_executions = f8
      2 net_soft_gets = f8
      2 stmt_hash_value = f8
      2 first_load_time = dq8
  )
  SET sql_list->sql_count = 0
  SET sql_list->starting_test_sequence = starting_test_sequence
  SET sql_list->ending_test_sequence = ending_test_sequence
  SELECT INTO "nl:"
   dm1.script_name, dm1.soft_gets, dm1.executions,
   dm1.hard_gets, dm1.first_load_time
   FROM dm_sql_snapshot dm1
   WHERE dm1.test_sequence=ending_test_sequence
   ORDER BY dm1.script_name, dm1.stmt_hash_value
   DETAIL
    sql_list->sql_count = (sql_list->sql_count+ 1)
    IF (mod(sql_list->sql_count,10)=1)
     stat = alterlist(sql_list->list,(sql_list->sql_count+ 9))
    ENDIF
    sql_list->list[sql_list->sql_count].script_name = dm1.script_name, sql_list->list[sql_list->
    sql_count].end_soft_gets = dm1.soft_gets, sql_list->list[sql_list->sql_count].end_hard_gets = dm1
    .hard_gets,
    sql_list->list[sql_list->sql_count].end_executions = dm1.executions, sql_list->list[sql_list->
    sql_count].beg_soft_gets = 0.0, sql_list->list[sql_list->sql_count].beg_hard_gets = 0.0,
    sql_list->list[sql_list->sql_count].beg_executions = 0.0, sql_list->list[sql_list->sql_count].
    stmt_hash_value = dm1.stmt_hash_value, sql_list->list[sql_list->sql_count].first_load_time = dm1
    .first_load_time
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   dm2.stmt_hash_value, dm2.first_load_time, dm2.script_name,
   dm2.soft_gets, dm2.executions, dm2.hard_gets
   FROM dm_sql_snapshot dm2
   WHERE dm2.test_sequence=starting_test_sequence
   ORDER BY dm2.script_name, dm2.stmt_hash_value
   DETAIL
    FOR (i = 1 TO sql_list->sql_count)
      IF ((dm2.stmt_hash_value=sql_list->list[i].stmt_hash_value))
       IF ((dm2.first_load_time=sql_list->list[i].first_load_time)
        AND (dm2.soft_gets < sql_list->list[i].end_soft_gets)
        AND (dm2.hard_gets < sql_list->list[i].end_hard_gets))
        sql_list->list[i].beg_soft_gets = dm2.soft_gets, sql_list->list[i].beg_hard_gets = dm2
        .hard_gets, sql_list->list[i].beg_executions = dm2.executions
       ELSE
        sql_list->list[i].beg_soft_gets = sql_list->list[i].end_soft_gets, sql_list->list[i].
        beg_hard_gets = sql_list->list[i].end_hard_gets, sql_list->list[i].beg_executions = - (1.0)
       ENDIF
       sql_list->list[i].net_soft_gets = (sql_list->list[i].end_soft_gets - sql_list->list[i].
       beg_soft_gets)
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
#get_snapshot_values_end
#done
END GO
